package basm

import "core:testing"

@(test)
test_file_one :: proc(t: ^testing.T) {
    test_one :: #load("../../test_files/test.asm", []byte)

    assembler_state: Assembler_State
    assembler_state.input_file_contents = test_one

    testing.expect(t, lexer_pass(&assembler_state), "Expect this file to lex")
    defer clean_up_tokens(&assembler_state)
}

@(test)
test_file_two :: proc(t: ^testing.T) {
    test_source :: #load("../../test_files/test_2.asm", []byte)

    assembler_state: Assembler_State
    assembler_state.input_file_contents = test_source

    testing.expect(t, lexer_pass(&assembler_state), "Expect this file to lex")
    defer clean_up_tokens(&assembler_state)
}

@(test)
test_file_three :: proc(t: ^testing.T) {
    test_source :: #load("../../test_files/test_3.asm", []byte)

    assembler_state: Assembler_State
    assembler_state.input_file_contents = test_source

    testing.expect(t, lexer_pass(&assembler_state), "Expect this file to lex")
    defer clean_up_tokens(&assembler_state)
}

@(private = "file")
clean_up_tokens :: proc(assembler_state: ^Assembler_State) {
    for &token in assembler_state.extracted_tokens {
        delete(token.label)
        delete(token.mnemonic)
        delete(token.arg0)
        delete(token.arg1)
        delete(token.comment)
    }
    delete(assembler_state.extracted_tokens)

}

