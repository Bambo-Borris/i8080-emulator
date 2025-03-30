package basm

// import "comlib:osal"
import "core:fmt"
import "core:log"
import "core:os"
import "core:strings"

Assembler_State :: struct {
    output_file_name:    string,
    input_file_name:     string,
    input_file_contents: []byte,
    debug_log:           bool,
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

