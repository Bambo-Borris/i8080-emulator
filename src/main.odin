package i8080

import "core:fmt"
import "core:os"
import "core:os/os2"
import "core:reflect"
import "core:strings"
import "core:unicode/utf8"

/*
TODO:
    - Replace printf with logger
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

Operand :: union {
    Registers,
    u8,
}

Instruction :: struct {
    opcode:    Opcodes,
    operand_a: Operand,
    operand_b: Operand,
}

Token :: [3]string

MNEMONICS := generate_mnemonics_array()

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
                fmt.eprintfln("Unable to open input file %v", arg)
                os.exit(1)
            }

        }
    }

    tokens := lexer_pass(asm_file_contents)
    defer delete(tokens)
    fmt.printfln("Tokens found: %v", tokens)

    instructions := parse_instructions(tokens[:])
    defer delete(instructions)

    fmt.printfln("Instructions parsed: %v", instructions)
}

generate_mnemonics_array :: proc() -> (mnemonic_array: [int(Opcodes.COUNT)]string) {
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
                "Argument count mismatch on line %v, expected format mnemonic operand, operand but got %v instead",
                line_number,
                trimmed_line,
            )
        }

        token: Token
        token[0] = strings.clone(possible_tokens[0])
        token[1] = strings.clone(possible_tokens[1])
        token[2] = strings.clone(possible_tokens[2])

        append(&tokens_list, token)
    }

    return tokens_list
}

parse_instructions :: proc(tokens_list: []Token) -> [dynamic]Instruction {
    return {}
}

