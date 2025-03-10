package i8080

import "core:fmt"
import "core:os"
import "core:os/os2"
import "core:strings"

Opcodes :: enum {
    Move,
    // Load,
    // Store,
    Add,
    Sub,
}

Registers :: enum {
    A = 0x01,
    B = 0x02,
    C = 0x03,
    D = 0x04,
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
                fmt.eprintfln("Unable to open input file %v", arg)
                os.exit(1)
            }

            fmt.println(asm_file_contents)
        }
        fmt.println(arg)
    }
}
