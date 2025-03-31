package basm

// import "comlib:osal"
import "core:fmt"
import "core:log"
import "core:os"
import "core:strings"

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

Assembler_State :: struct {
    output_file_name:    string,
    input_file_name:     string,
    input_file_contents: []byte,
    extracted_tokens:    [dynamic]Token,
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
    log.debug(lines)

    asm_state.extracted_tokens = make([dynamic]Token)

    for &line, index in lines {
        line_num := index + 1
        _ = line_num

        // We'll process left->right across the line, trimming unneccessary spaces where
        // required. we are looking for:
        // [optional label] [mnemonic or directive] [operands?] [; comment?]

        // Trim whole line left/right spaces
        trimmed_line := strings.trim_space(line)
        token: Token

        // If there's a label marker ':', then we shall try tokenize a label
        if strings.contains_rune(trimmed_line, ':') {
            line_split_colon, alloc_err := strings.split(trimmed_line, ":", context.temp_allocator)

            if alloc_err != .None {
                panic("IAE: Unable to allocate split strings for lexer stage")
            }

            label_rune_count := strings.rune_count(line_split_colon[0])

            if label_rune_count <= 5 {
                log.debug("Valid label length of <=5 found :", line_split_colon[0])
                token.label = strings.clone(line_split_colon[0])
            } else if label_rune_count == 0 {
                output_syntax_error(line_num, "invalid label, must be between 1 and 5 characters in length")
            } else {
                err_str := fmt.tprintfln("label '%v' is more than 5 characters in length!", line_split_colon[0])
                output_syntax_error(line_num, err_str)
                return false
            }
        }


        append(&asm_state.extracted_tokens, token)
    }


    log.info("Tokens extracted:\n", asm_state.extracted_tokens)

    return true
}

output_syntax_error :: proc(line_number: int, error_string: string) {
    fmt.printfln("Error! Line %v, %v", line_number, error_string)
}
