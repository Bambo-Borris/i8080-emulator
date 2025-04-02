package basm

// import "comlib:osal"
import "core:fmt"
import "core:log"
import "core:os"
import "core:strings"

/*
TODO:
    - Lexing pass currently only accounts for generating tokens with 2 optional arguments, however
    some assembly instructions are source influencing only and they may have > 2 arguments depending
    on use.
    Bambo 02/04/25
*/

Token :: struct {
    // Generated during lexing
    label:    string,
    mnemonic: string,
    arg0:     string,
    arg1:     string,
    comment:  string,
    line_num: int,

    // Posted during opcode decoding
    offset:   int,
}

Instruction :: struct {
    offset:      int,
    byte_length: int,
    token_index: int,
    data:        []byte,
    type:        Instruction_Type,
}

Instruction_Type :: enum {
    Unknown,
    Standard,
    Pseudo,
    Data,
}

Symbol_Type :: enum {
    Label,
}

Symbol :: struct {
    name:        string,
    token_index: int,
    type:        Symbol_Type,
}

Assembler_State :: struct {
    output_file_name:    string,
    input_file_name:     string,
    input_file_contents: []byte,
    extracted_tokens:    [dynamic]Token,
    instructions:        [dynamic]Instruction,
    symbols:             [dynamic]Symbol,
}

CLI_ARGS := [?]string{"f", "o", "d", "h"}

CLI_Args_Data :: struct {
    arg_idx: int,
    data:    string,
}

main :: proc() {
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

    setup_instructions_maps()

    assembler_state: Assembler_State
    assembler_state.output_file_name = cli_args_table["o"].data
    assembler_state.input_file_name = cli_args_table["f"].data

    if !load_input_file(&assembler_state) {
        fmt.printfln("Error: Unable to open input file path: %v", assembler_state.input_file_name)
        os.exit(1)
    }

    if !lexer_pass(&assembler_state) {
        os.exit(1)
    }

    if !parser_pass(&assembler_state) {
        os.exit(1)
    }
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

load_input_file :: proc(asm_state: ^Assembler_State) -> (ok: bool) {
    assert(asm_state != nil)
    asm_state.input_file_contents, ok = os.read_entire_file(asm_state.input_file_name)
    return
}

lexer_pass :: proc(asm_state: ^Assembler_State) -> bool {
    file_as_string := strings.clone_from_bytes(asm_state.input_file_contents, context.temp_allocator)
    defer {
        free_all(context.temp_allocator)
    }

    lines := strings.split_lines(file_as_string, context.temp_allocator)

    asm_state.extracted_tokens = make([dynamic]Token)

    for &line, index in lines {
        // Don't process empty lines
        if len(line) == 0 {
            continue
        }

        line_num := index + 1
        _ = line_num

        // We'll process left->right across the line, trimming unneccessary spaces where
        // required. we are looking for:
        // [optional label] [mnemonic or directive] [operands a], [operand_b] [; comment?]

        // Trim whole line left/right spaces
        trimmed_line := strings.trim_space(line)
        token: Token
        token.line_num = line_num
        defer {
            append(&asm_state.extracted_tokens, token)
        }

        // Special case to handle comment starting lines
        if strings.index_rune(trimmed_line, ';') == 0 {
            token.comment = strings.clone(trimmed_line)
            continue
        }

        label_split, alloc_err := strings.split(trimmed_line, ":", context.temp_allocator)
        after_label_str: string

        // There's only a label if the length of this array is > 1, as an len(empty split) == 1
        if len(label_split) > 1 {
            label_string := label_split[0]
            label_rune_count := strings.rune_count(label_string)

            if label_rune_count <= 5 {
                token.label = strings.clone(label_string)
            } else if label_rune_count == 0 {
                output_syntax_error(line_num, "invalid label, must be between 1 and 5 characters in length")
            } else {
                err_str := fmt.tprintfln("label '%v' is more than 5 characters in length!", label_string)
                output_syntax_error(line_num, err_str)
                return false
            }
            after_label_str = label_split[1]
        } else {
            after_label_str = label_split[0]
        }

        // To identify the first mnemonic we first trim (since it's likely the user placed a space between the label: mnemonic
        // syntax, if they didn't we still get a valid result anyway.) This trimmed form then can be split again on the space character,

        after_label_str = strings.trim_left_space(after_label_str)

        if strings.contains_rune(after_label_str, ';') {
            line_split_semi_colon: []string
            line_split_semi_colon, alloc_err = strings.split(after_label_str, ";", context.temp_allocator)

            if alloc_err != .None {
                panic("IAE: Unable to allocate split strings for lexer stage")
            }

            assert(len(line_split_semi_colon) == 2)
            token.comment = strings.clone(line_split_semi_colon[1])
            after_label_str = line_split_semi_colon[0]
        }

        mnemonic_string: string

        // Beware this may break with a tab character
        space_idx := strings.index_rune(after_label_str, ' ')
        if space_idx >= 0 {
            mnemonic_string, _ = strings.substring_to(after_label_str, space_idx)
            // log.debug(mnemonic_string)

            if strings.rune_count(mnemonic_string) < 2 {
                err_str := fmt.tprintfln("invalid mnemonic length '%v' is too short to be a valid mnemonic!", mnemonic_string)
                output_syntax_error(line_num, err_str)
                return false
            }

            token.mnemonic = strings.clone(mnemonic_string)
        } else {
            // We can only get here if this is a label + comment, or label only or comment only
            continue
        }

        // Now analyse the middle section for the arguments (there may be none)
        args_combined_str, _ := strings.substring_from(after_label_str, space_idx)
        args_combined_str = strings.trim_right_space(args_combined_str)

        if len(args_combined_str) == 0 {
            continue
        }

        comma_split: []string
        comma_split, alloc_err = strings.split(args_combined_str, ",", context.temp_allocator)
        if alloc_err != .None {
            panic("IAE: Unable to allocate split strings for lexer stage")
        }

        arg0_str := comma_split[0]
        arg0_str = strings.trim_space(arg0_str)

        if len(arg0_str) > 0 {
            token.arg0 = strings.clone(arg0_str)
        }

        // There's only a second arg if the comma_split length > 0
        if len(comma_split) > 1 {
            arg1_str := comma_split[1]
            arg1_str = strings.trim_space(arg1_str)

            if len(arg1_str) > 0 {
                token.arg1 = strings.clone(arg1_str)
            }
        }

        log.debug("Middle portion of line", line_num, args_combined_str, "which was originally", line)
    }

    output_reassembled_line_from_tokens(asm_state.extracted_tokens[:])
    return true
}

output_syntax_error :: proc(line_number: int, error_string: string) {
    fmt.printfln("Error! Line %v, %v", line_number, error_string)
}

output_reassembled_line_from_tokens :: proc(tokens: []Token) {
    log.info("Lexer pass complete, tokens output for parsing is:")
    for &token in tokens {
        log.info(token)
    }

    // @TODO Reassemble source file from tokens data
    // for &t in tokens {
    //     label_str := ""
    //     // mnemonic_str := ""
    //     // operand_0_str := ""
    //     // operand_1_str := ""
    //     comment_str := ""

    //     if t.label != "" {
    //         label_str = fmt.tprintf("%v:", t.label)
    //     }

    //     // if t.mnemonic != "" {
    //     //     mnemonic_str = t.mnemonic
    //     // }

    //     if t.comment != "" {
    //         comment_str = fmt.tprintf("; %v", t.comment)
    //     }

    //     if t.arg1 != "" {
    //         log.infof("Line %v: %v %v %v, %v %v", t.line_num, label_str, mnemonic_str, operand_0_str, operand_1_str, comment_str)
    //     } else if t.arg0 != "" {
    //         log.infof("Line %v: %v %v %v, %v %v", t.line_num, label_str, mnemonic_str, operand_0_str, operand_1_str, comment_str)
    //     } else {
    //     }
    // }
}

parser_pass :: proc(asm_state: ^Assembler_State) -> bool {
    emit_symbol :: proc(asm_state: ^Assembler_State, symbol: Symbol) {
        append(&asm_state.symbols, symbol)
        log.debug("Emitting symbol", asm_state.symbols[len(asm_state.symbols) - 1])
    }

    for &token, index in asm_state.extracted_tokens {
        // We have no token, and no label and just a comment,
        // we ignore comments
        if len(token.label) == 0 && len(token.mnemonic) == 0 && len(token.comment) != 0 {
            log.debug("Comment only at line ", token.line_num)
            continue
        } else if len(token.label) > 0 && len(token.mnemonic) == 0 {
            log.debug("Label only line", token.line_num)
            emit_symbol(asm_state, Symbol{name = token.label, token_index = index, type = .Label})
            continue
        }

        instruction := Instruction {
            type = .Unknown,
        }

        if token.mnemonic in STANDARD_INSTRUCTION_STRINGS_MAP {
            instruction.type = .Standard
        } else if token.mnemonic in PSEUDO_INSTRUCTIONS_STRING_MAP {
            instruction.type = .Pseudo
        }

        // If we have a label on a line
        if len(token.label) > 0 {
            emit_symbol(asm_state, Symbol{name = token.label, token_index = index, type = .Label})
        }

        log.debug("Instruction type is", instruction.type, "for line", token.line_num, "with mnemonic", token.mnemonic)
    }

    return true
}

