; Check load
load b, 20 ; Check inline comment
load a, 0x50

; Check Add
add a, 1
add b, 2

; Check store
; Leave these commented out for now as store
; will require us to validate u16 vs u8 bytes
store a, 0x200
store b, 0x300
