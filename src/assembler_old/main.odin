package assembler

import "comlib:io"
import "core:fmt"
import "core:log"
import "core:mem"
import "core:os"
import "core:os/os2"
import "core:reflect"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:unicode/utf8"
/*
TODO:
    (Also refer to sections like @REFACTOR or @SPEED for other potential TODOs)

    - Printing assembler errors should be a convenient operation that doesn't require each call site invoking a print
    to manually specify the prefix \"Error\" 
    Bambo 16/03/25

    - Should uppercase all string tokens for arguments
    Bambo 23/03/25

    - Need to validate numerical literals aren't negative
    Bambo 23/03/25
    
*/

CLI_ARGS := [?]string{"f", "o", "d", "h"}

CLI_Args_Data :: struct {
    arg_idx: int,
    data:    string,
}

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

    cli_args_table, got_args := parse_cli_args()
    if cli_args_table == nil && got_args {
        output_help()
        return
    } else if !got_args {
        os.exit(1)
    }

    if "f" not_in cli_args_table {
        fmt.eprintln("No input file supplied! Try -h flag for help")
        os.exit(1)
    }

    if "o" not_in cli_args_table {
        fmt.eprintln("No output file path supplied! Try -h flag for help")
        os.exit(1)
    }

    LOGGER_OPTIONS :: log.Options{.Level, .Terminal_Color, .Short_File_Path, .Line}
    context.logger = log.create_console_logger(.Debug, LOGGER_OPTIONS)
    defer log.destroy_console_logger(context.logger)

    if "d" not_in cli_args_table {
        context.logger.lowest_level = .Fatal
    }

    err: os2.Error
    asm_file_contents, err = os2.read_entire_file(cli_args_table["f"].data, context.allocator)

    if err != os2.ERROR_NONE {
        fmt.eprintfln("Error: Unable to open input file %v", cli_args_table["f"].data)
        os.exit(1)
    }

    tokens := lexer_pass(asm_file_contents)
    defer delete(tokens)
    log.debugf("Tokens found: %v", tokens)

    instructions, ok := parse_instructions(tokens[:])
    defer delete(instructions)

    log.debugf("Valid instructions extracted: %v", instructions)

    ok = write_binary_output(instructions[:], cli_args_table["o"].data)

    if !ok {
        os.exit(1)
    }

    log.debugf("Instructions parsed: %v", instructions)
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

generate_operand_type_fancy_name :: proc() -> (out: [OPERAND_TYPE_COUNT]string) {
    for ot, index in Operand_Type {
        if ot == .COUNT {
            break
        }
        str := reflect.enum_string(ot)
        output, _ := strings.replace(str, "_", " ", -1)
        out[index] = output
    }

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
        log.debug("Allowed args type", allowed_arg_type)
        switch allowed_arg_type {
        case .Register:
            log.debug("Checking arg string", arg_string, "is", allowed_arg_type)
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
            if len(arg_string) < 3 {
                continue
            }

            hex_prefix_substring, got_prefix := strings.substring(arg_string, 0, 2)
            if !got_prefix || hex_prefix_substring != "0x" {
                continue
            }

            hex_str, _ := strings.substring_from(arg_string, 2)
            fmt.println(hex_str)

            uppercased := strings.to_upper(hex_str, context.temp_allocator)
            is_valid_hex := true
            for r in uppercased {
                if !is_hex_valid_rune(r) {
                    is_valid_hex = false
                    break
                }
            }

            if !is_valid_hex {
                continue
            }

            // Use arg string since the format 0x000 is read properly by atoi
            as_integer := strconv.atoi(arg_string)
            if as_integer > cast(int)max(u16) {
                fmt.eprintfln("Error: Argument '%v' on line %v exceeds maximum integer size of %v", arg_string, line_number, max(u8))
                break
            }

            operand = cast(u16)as_integer
            ok = true
            break

        case .COUNT:
            panic("Invalid enum state encountered")
        }
    }

    return
}

write_binary_output :: proc(instructions: []Instruction, output_file_name: string) -> bool {
    output_file_handle, error := io.os_open_agnostic(output_file_name, os.O_RDWR | os.O_CREATE | os.O_TRUNC)
    defer os.close(output_file_handle)

    if error != os.ERROR_NONE {
        fmt.eprintln("Error: Unable to open output file program.bin")
        return false
    }

    for instruction in instructions {
        os.write_byte(output_file_handle, cast(byte)instruction.opcode)
        write_operand(output_file_handle, instruction.operand_a)
        write_operand(output_file_handle, instruction.operand_b)
    }

    return true
}

write_operand :: proc(handle: os.Handle, operand: Operand_Data) {
    switch &arg_type in operand {
    case Registers:
        os.write_byte(handle, cast(byte)arg_type)
    case u8:
        os.write_byte(handle, arg_type)
    case u16:
        bytes := mem.ptr_to_bytes(&arg_type)
        os.write(handle, bytes)
    }

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

is_hex_valid_rune :: proc(r: rune) -> bool {
    if is_numeric_rune(r) do return true

    switch r {
    case 'A':
        fallthrough
    case 'B':
        fallthrough
    case 'C':
        fallthrough
    case 'D':
        fallthrough
    case 'E':
        fallthrough
    case 'F':
        return true
    }

    return false
}

@(require_results)
parse_cli_args :: proc() -> (out_args_table: map[string]CLI_Args_Data, ok: bool) {
    is_parsing_arg := false
    current_parsing_cli_index: int

    for arg, i in os.args {
        // Consume the first arg, it's the path to the binary
        // and we don't care about it
        if i == 0 {
            continue
        }

        cliad: CLI_Args_Data

        // @REFACTOR this is really messy with respect to the use of two flags
        // and there's a cleaner solution for sure.
        if !is_parsing_arg {
            if start_rune := arg[0]; start_rune == '-' {
                trimmed := strings.trim_left(arg, "-")

                found_matching_arg := true
                for &cli_arg, j in CLI_ARGS {
                    if cli_arg == trimmed {
                        is_parsing_arg = true
                        found_matching_arg = true
                        cliad.arg_idx = j
                        cliad.data = arg
                        current_parsing_cli_index = j
                        break
                    }
                }

                if !found_matching_arg {
                    fmt.eprintfln("No matching argument for flag -%v! Try --h", arg)
                    return {}, false
                }
            }
        } else {
            out_args_table[CLI_ARGS[current_parsing_cli_index]] = CLI_Args_Data {
                arg_idx = current_parsing_cli_index,
                data    = arg,
            }
            is_parsing_arg = false
        }
    }

    return out_args_table, true
}

output_help :: proc() {
    fmt.println("---------------- Available Flags ----------------")
    fmt.printfln("-f -- Path to assembly file to assemble")
    fmt.printfln("-o -- Output file path for assembled binary file")
    fmt.printfln("-d -- Debug tracing in assembler")
    fmt.printfln("-h -- Output help")
}

