        ORG   0100H      ; Program start (example origin)

        MVI   A, 0       ; A = 0 (loop counter initialization)

LOOP:   CPI   6         ; Compare A with 6
        JZ    DONE      ; If A == 6, exit the loop

        ; --- Your loop body here ---
        ; For example, do something with A or memory

        INR   A         ; A = A + 1
        JMP   LOOP      ; Repeat

DONE:   HLT             ; Halt once done

