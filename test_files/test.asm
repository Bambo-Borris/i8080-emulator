; Test asm file
BEGIN:                    ; Test case
        ORG    0x0100
        MVI    A, 0x05    ; Load 5 into A
LOOP:   DCR    A          ; Decrement A
        JNZ    LOOP       ; If not zero, jump back
        HLT               ; Halt when A == 0
