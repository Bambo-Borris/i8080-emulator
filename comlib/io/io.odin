package comlib

import "core:os"

@(require_results)
os_open_agnostic :: proc(path: string, mode: int) -> (os.Handle, os.Error) {
    when ODIN_OS == .Windows {
        handle, err := os.open(path, mode)
    } else {
        handle, err := os.open(path, mode, os.S_IRUSR | os.S_IWUSR)
    }

    return handle, err
}
