package i8080

import "core:fmt"
import "core:os"
import "core:os/os2"
import "core:reflect"
import "core:slice"
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
    Hex_Literal,
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

MNEMONICS := generate_mnemonics_array()
OPCODES_COUNT :: int(Opcodes.COUNT)

// Need to map instruction mnemonic, to operand type
// This should map Mnemnonic => Operand_A, Operand_B, Types_Allowed_A, Types_Allowed_B
// @REFACTOR The naming of this array feels bad, should return to fix this up 16/03/25
MNEMONIC_OPERANDS := [OPCODES_COUNT]Opcode_Args_Rules {
    // LOAD
    {
        {.Register}, // Arg0 
        {.Integer_Literal, .Hex_Literal}, // Arg1
    },

    // STORE
    {
        {.Register}, // Arg0
        {.Hex_Literal}, // Arg1
    },

    // ADD
    {
        {.Register}, // Arg0,
        {.Integer_Literal, .Hex_Literal}, // Arg1
    },

    // SUB
    {
        {.Register}, // Arg0,
        {.Integer_Literal, .Hex_Literal}, // Arg1
    },
}

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

    for &token in tokens_list {
        // First identify the mnemonic we're dealing with and find its opcode
        // (do search on uppercase form to be safe)
        uppercase_mnemonic := strings.to_upper(token.elements[0], context.temp_allocator)
        mnemonic_index, did_find_token := slice.linear_search(MNEMONICS[:], uppercase_mnemonic)
        if !did_find_token {
            fmt.eprintfln("Error: Encountered unknown mnemonic '%v' on line %v", token.elements[0], token.line)
            return
        }

        opcode := cast(Opcodes)mnemonic_index
        opcode_index := int(opcode)

        args_info := &MNEMONIC_OPERANDS[opcode_index]
        found_valid_type_for_arg := false

        // There is definitely a more elegant solution here, but for now what we'll do is
        // we'll iterate over the types allowed for this opcode in the arg 0 slot,
        // then interrogate if the argument 0 for this token can be treated as any of
        // the accepted types, if not we have an error and we can halt and exit. We
        // will then repeat the same for the argument 1

        // @REFACTOR find a better solution here, there is definitely one, maybe
        // we should parse the token containing the argument and do some deduction
        // on it to determine if it's actually something valid

        for allowed_arg_type in args_info[0] {
            fmt.println("Allowed args type", allowed_arg_type)
            switch allowed_arg_type {
            case .Register:
            case .Integer_Literal:
            case .Hex_Literal:
            }
        }

        // Validate the first operand type is correct for the opcode extracted
        // MNEMONIC_OPERANDS[]
    }

    return
}
