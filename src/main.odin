package i8080

import "core:fmt"
import "core:os"
import "core:os/os2"
import "core:reflect"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:unicode/utf8"

/*
TODO:
    - Printing assembler errors should be a convenient operation that doesn't require each call site invoking a print
    to manually specify the prefix \"Error\" 16/03/25
*/

Opcodes :: enum {
    Load,
    Store,
    Add,
    Sub,
    COUNT,
}

Registers :: enum {
    A = 0x01,
    B = 0x02,
    C = 0x03,
    D = 0x04,
}

Operand_Type :: enum {
    Register,
    Integer_Literal,
    Address_Literal,
    COUNT,
}

Operand_Data :: union {
    Registers,
    u8,
    u16,
}

Operand_Allowed_Args_Types :: bit_set[Operand_Type;byte]
Opcode_Args_Rules :: [2]Operand_Allowed_Args_Types

Instruction :: struct {
    opcode:    Opcodes,
    operand_a: Operand_Data,
    operand_b: Operand_Data,
}

Token :: struct {
    elements: [3]string,
    line:     int,
}

OPERAND_TYPE_FANCY_NAMES := generate_operand_type_fancy_name()
MNEMONICS := generate_mnemonics_array()

OPCODES_COUNT :: int(Opcodes.COUNT)
OPERAND_TYPE_COUNT :: int(Operand_Type.COUNT)

// @REFACTOR this may not be necessary, if deleted also remove func 'generate_register_string_table'
// REGISTER_STRING_TABLE := generate_register_string_table()

// Need to map instruction mnemonic, to operand type
// This should map Mnemnonic => Operand_A, Operand_B, Types_Allowed_A, Types_Allowed_B
// @REFACTOR The naming of this array feels bad, should return to fix this up 16/03/25
MNEMONIC_OPERANDS := [OPCODES_COUNT]Opcode_Args_Rules {
    // LOAD
    {
        {.Register}, // Arg0 
        {.Integer_Literal}, // Arg1
    },

    // STORE
    {
        {.Register}, // Arg0
        {.Address_Literal}, // Arg1
    },

    // ADD
    {
        {.Register}, // Arg0,
        {.Integer_Literal, .Integer_Literal}, // Arg1
    },

    // SUB
    {
        {.Register}, // Arg0,
        {.Integer_Literal, .Integer_Literal}, // Arg1
    },
}

TOKEN_SLOT_OPCODE :: 0
TOKEN_SLOT_ARG0 :: 1
TOKEN_SLOT_ARG1 :: 2


main :: proc() {
    asm_file_contents: []byte

    for arg, i in os.args {
        // Consume the first arg, it's the path to the binary
        // and we don't care about it
        if i == 0 {
            continue
        }

        if strings.contains(arg, ".asm") {
            err: os2.Error
            asm_file_contents, err = os2.read_entire_file(arg, context.allocator)

            if err != os2.ERROR_NONE {
                fmt.eprintfln("Error: Unable to open input file %v", arg)
                os.exit(1)
            }

        }
    }

    tokens := lexer_pass(asm_file_contents)
    defer delete(tokens)
    fmt.printfln("Tokens found: %v", tokens)

    instructions, ok := parse_instructions(tokens[:])
    defer delete(instructions)

    fmt.printfln("Valid instructions extracted: %v", instructions)

    ok = write_binary_output(instructions[:])

    if !ok {
        os.exit(1)
    }

    fmt.printfln("Instructions parsed: %v", instructions)
}

generate_mnemonics_array :: proc() -> (mnemonic_array: [OPCODES_COUNT]string) {
    for opcode, i in Opcodes {
        if opcode == .COUNT {
            break
        }

        mnemonic_array[i] = strings.to_upper(reflect.enum_string(opcode))
    }
    return
}

// generate_register_string_table :: proc() -> (table: [OPCODES_COUNT]string) {
//     for &str, index in table {
//         str = reflect.enum_string(cast(Opcodes)index)
//     }
//     return table
// }

generate_operand_type_fancy_name :: proc() -> (out: [OPERAND_TYPE_COUNT]string) {
    for ot, index in Operand_Type {
        if ot == .COUNT {
            break
        }
        str := reflect.enum_string(ot)
        output, _ := strings.replace(str, "_", " ", -1)
        out[index] = output
    }
    fmt.println(out)
    return
}

lexer_pass :: proc(asm_file: []byte) -> [dynamic]Token {
    file_as_string := strings.clone_from_bytes(asm_file, context.temp_allocator)
    defer {
        free_all(context.temp_allocator)
    }

    split_strings := strings.split_lines(file_as_string, context.temp_allocator)

    tokens_list := make([dynamic]Token)
    reserve(&tokens_list, len(split_strings))

    for i in 0 ..< len(split_strings) {
        line := split_strings[i]
        line_number := i + 1

        if len(line) == 0 {
            continue
        }

        if utf8.rune_at_pos(line, 0) == ';' {
            continue
        }

        comments := strings.split(line, ";", context.temp_allocator)

        before_comment := comments[0]
        trimmed_line := strings.trim_space(before_comment)
        comma_removed_line, _ := strings.remove_all(trimmed_line, ",", context.temp_allocator)
        possible_tokens := strings.split(comma_removed_line, " ")

        if len(possible_tokens) != 3 {
            fmt.eprintfln(
                "Error: Argument count mismatch on line %v, expected format mnemonic operand, operand but got %v instead",
                line_number,
                trimmed_line,
            )
        }

        token: Token
        token.elements[0] = strings.clone(possible_tokens[0])
        token.elements[1] = strings.clone(possible_tokens[1])
        token.elements[2] = strings.clone(possible_tokens[2])
        token.line = line_number

        append(&tokens_list, token)
    }

    return tokens_list
}

parse_instructions :: proc(tokens_list: []Token) -> (instructions_list: [dynamic]Instruction, ok: bool) {
    fmt.println("Received tokens %v into ", #line, tokens_list)
    defer free_all(context.temp_allocator)

    instructions_list = make(type_of(instructions_list))
    reserve(&instructions_list, len(tokens_list))

    for &token in tokens_list {
        // First identify the mnemonic we're dealing with and find its opcode
        // (do search on uppercase form to be safe)
        uppercase_mnemonic := strings.to_upper(token.elements[TOKEN_SLOT_OPCODE], context.temp_allocator)
        mnemonic_index, did_find_token := slice.linear_search(MNEMONICS[:], uppercase_mnemonic)
        if !did_find_token {
            fmt.eprintfln("Error: Encountered unknown mnemonic '%v' on line %v", token.elements[0], token.line)
            return
        }

        opcode := cast(Opcodes)mnemonic_index
        opcode_index := int(opcode)

        args_info := &MNEMONIC_OPERANDS[opcode_index]

        operand_a, got_operand_a := convert_arg_string_to_operand(token.elements[TOKEN_SLOT_ARG0], args_info[0], token.line)
        if !got_operand_a {
            return
        }

        operand_a_type := operand_data_to_operand_type(operand_a)

        if operand_a_type not_in MNEMONIC_OPERANDS[int(opcode)][0] {
            /// @REFACTOR Rework the below error message to also list valid argument types
            fmt.eprintfln(
                "Error: Invalid first operand type found on line %v, '%v' was deduced to be of type %v",
                token.line,
                token.elements[1],
                OPERAND_TYPE_FANCY_NAMES[int(operand_a_type)],
            )
        }

        operand_b, got_operand_b := convert_arg_string_to_operand(token.elements[TOKEN_SLOT_ARG1], args_info[1], token.line)
        if !got_operand_b {
            return
        }

        operand_b_type := operand_data_to_operand_type(operand_b)

        if operand_b_type not_in MNEMONIC_OPERANDS[int(opcode)][1] {
            fmt.eprintfln(
                "Error: Invalid second operand type found on line %v, '%v' was deduced to be of type %v",
                token.line,
                token.elements[1],
                OPERAND_TYPE_FANCY_NAMES[int(operand_a_type)],
            )
        }

        instruction := Instruction {
            opcode    = opcode,
            operand_a = operand_a,
            operand_b = operand_b,
        }

        // @TODO Validate all instructions
        append(&instructions_list, instruction)
    }

    return
}

convert_arg_string_to_operand :: proc(
    arg_string: string,
    arg_info: Operand_Allowed_Args_Types,
    line_number: int,
) -> (
    operand: Operand_Data,
    ok: bool,
) {

    // @REFACTOR In assembly we don't tend to support different arg types
    // per instruction mnemonic, instead each instruction mnemonic is specifically
    // tied to 1-2 arg types, this means we could collapse this down to a lookup
    // table to lookup the arg type for the instruction and then instead we'd be able
    // to do some very simple validation checks and the complexity of this loop vanishes.

    for allowed_arg_type in arg_info {
        fmt.println("Allowed args type", allowed_arg_type)
        switch allowed_arg_type {
        case .Register:
            fmt.println("Checking arg string", arg_string, "is", allowed_arg_type)
            uppercase_register_name := strings.to_upper(arg_string, context.temp_allocator)
            register_enum_value, found_correct_enum_value := reflect.enum_from_name(Registers, uppercase_register_name)
            if found_correct_enum_value {
                ok = true
                operand = register_enum_value
                break
            }

        case .Integer_Literal:
            // Deduce if we're an integer literal
            is_hex_literal := strings.contains(arg_string, "0x")

            is_decimal_literal := true
            for r in arg_string {
                if !is_numeric_rune(r) {
                    is_decimal_literal = false
                    break
                }
            }

            if is_decimal_literal || is_hex_literal {
                literal_as_int := strconv.atoi(arg_string)
                if literal_as_int > cast(int)max(u8) {
                    fmt.printfln("Error: Argument '%v' on line %v exceeds maximum integer size of %v", arg_string, line_number, max(u8))
                    break
                }
                operand = cast(u8)literal_as_int
                ok = true
                break
            }


        case .Address_Literal:
            fmt.println("Checking arg string is", allowed_arg_type)

        case .COUNT:
            panic("Invalid enum state encountered")
        }
    }

    return
}

write_binary_output :: proc(instructions: []Instruction) -> bool {
    output_file_handle, error := os_open_agnostic("program.bin", os.O_RDWR | os.O_CREATE | os.O_TRUNC)
    defer os.close(output_file_handle)

    if error != os.ERROR_NONE {
        fmt.eprintln("Error: Unable to open output file program.bin")
        return false
    }

    for instruction in instructions {
        os.write_byte(output_file_handle, cast(byte)instruction.opcode)
    }

    // os.write_byte(output_file_handle, {})
    return true
}

@(require_results)
os_open_agnostic :: proc(path: string, mode: int) -> (os.Handle, os.Error) {
    when ODIN_OS == .Windows {
        handle, err := os.open(path, mode)
    } else {
        handle, err := os.open(path, mode, os.S_IRUSR | os.S_IWUSR)
    }

    return handle, err
}

@(require_results)
operand_data_to_operand_type :: #force_inline proc(data: Operand_Data) -> (type: Operand_Type) {
    switch union_type in data {
    case Registers:
        type = .Register
    case u8:
        type = .Integer_Literal
    case u16:
        type = .Address_Literal
    }

    return
}

is_numeric_rune :: #force_inline proc(r: rune) -> bool {
    switch r {
    case '0':
        fallthrough
    case '1':
        fallthrough
    case '2':
        fallthrough
    case '3':
        fallthrough
    case '4':
        fallthrough
    case '5':
        fallthrough
    case '6':
        fallthrough
    case '7':
        fallthrough
    case '8':
        fallthrough
    case '9':
        return true
    }
    return false
}

