package basm

Mnemonics :: enum {
    NOP,
    MOV,
    MVI,
    LXI,
    LDA,
    STA,
    LHLD,
    SHLD,
    LDAX,
    STAX,
    XCHG,
    ADD,
    ADI,
    ADC,
    ACI,
    SUB,
    SUI,
    SBB,
    SBI,
    INR,
    DCR,
    INX,
    DCX,
    DAD,
    DAA,
    ANA,
    ANI,
    ORA,
    ORI,
    XRA,
    XRI,
    CMP,
    CPI,
    RLC,
    RRC,
    RAL,
    RAR,
    CMA,
    CMC,
    STC,
    JMP,
    JNZ,
    JZ,
    JNC,
    JC,
    JPO,
    JPE,
    JM,
    CALL,
    CNZ,
    CZ,
    CNC,
    CC,
    CPO,
    CPE,
    CP,
    CM,
    RET,
    RNZ,
    RZ,
    RNC,
    RC,
    RPO,
    RPE,
    RP,
    RM,
    RST,
    PCHL,
    PUSH,
    POP,
    XTHL,
    SPHL,
    IN,
    OUT,
    EI,
    DI,
    HLT,
}

Pseudo_Instruction :: enum {
    ORG,
}

MNEMONIC_STRINGS := [?]string {
    "NOP",
    "MOV",
    "MVI",
    "LXI",
    "LDA",
    "STA",
    "LHLD",
    "SHLD",
    "LDAX",
    "STAX",
    "XCHG",
    "ADD",
    "ADI",
    "ADC",
    "ACI",
    "SUB",
    "SUI",
    "SBB",
    "SBI",
    "INR",
    "DCR",
    "INX",
    "DCX",
    "DAD",
    "DAA",
    "ANA",
    "ANI",
    "ORA",
    "ORI",
    "XRA",
    "XRI",
    "CMP",
    "CPI",
    "RLC",
    "RRC",
    "RAL",
    "RAR",
    "CMA",
    "CMC",
    "STC",
    "JMP",
    "JNZ",
    "JZ",
    "JNC",
    "JC",
    "JPO",
    "JPE",
    "JM",
    "CALL",
    "CNZ",
    "CZ",
    "CNC",
    "CC",
    "CPO",
    "CPE",
    "CP",
    "CM",
    "RET",
    "RNZ",
    "RZ",
    "RNC",
    "RC",
    "RPO",
    "RPE",
    "RP",
    "RM",
    "RST",
    "PCHL",
    "PUSH",
    "POP",
    "XTHL",
    "SPHL",
    "IN",
    "OUT",
    "EI",
    "DI",
    "HLT",
}

Operand_Type :: enum {
    None,
    Register_A,
    Register_B,
    Register_C,
    Register_D,
    Register_E,
    Register_H,
    Register_L,
    SP, // Stack pointer
    M, // Memory addressed via H:L
    Byte,
    Word,
    Address,
}

Opcode :: struct {
    mnemonic:  Mnemonics,
    length:    int,
    operand_a: Operand_Type,
    operand_b: Operand_Type,
}

OPCODE_TABLE: [255]Opcode

build_opcode_table :: proc() {
    // NOP
    OPCODE_TABLE[0x00] = Opcode {
        mnemonic  = .NOP,
        length    = 1,
        operand_a = .None,
        operand_b = .None,
    }

    // LXI B, d16
    OPCODE_TABLE[0x01] = Opcode {
        mnemonic  = .LXI,
        length    = 3,
        operand_a = .Register_B,
        operand_b = .Word,
    }

    // STAX B
    OPCODE_TABLE[0x02] = Opcode {
        mnemonic  = .STAX,
        length    = 1,
        operand_a = .Register_B,
        operand_b = .None,
    }

    // INX B
    OPCODE_TABLE[0x03] = Opcode {
        mnemonic  = .INX,
        length    = 1,
        operand_a = .Register_B,
        operand_b = .None,
    }

    // INR B
    OPCODE_TABLE[0x04] = Opcode {
        mnemonic  = .INR,
        length    = 1,
        operand_a = .Register_B,
        operand_b = .None,
    }

    // DCR B
    OPCODE_TABLE[0x05] = Opcode {
        mnemonic  = .DCR,
        length    = 1,
        operand_a = .Register_B,
        operand_b = .None,
    }

    // MVI B, d8
    OPCODE_TABLE[0x06] = Opcode {
        mnemonic  = .MVI,
        length    = 2,
        operand_a = .Register_B,
        operand_b = .Byte,
    }

    // RLC
    OPCODE_TABLE[0x07] = Opcode {
        mnemonic  = .RLC,
        length    = 1,
        operand_a = .None,
        operand_b = .None,
    }

    // NOP
    OPCODE_TABLE[0x08] = Opcode {
        mnemonic  = .NOP,
        length    = 1,
        operand_a = .None,
        operand_b = .None,
    }

    // DAD B
    OPCODE_TABLE[0x09] = Opcode {
        mnemonic  = .DAD,
        length    = 1,
        operand_a = .Register_B,
        operand_b = .None,
    }

    // LDAX B
    OPCODE_TABLE[0x0A] = Opcode {
        mnemonic  = .LDAX,
        length    = 1,
        operand_a = .Register_B,
        operand_b = .None,
    }

    // DCX B
    OPCODE_TABLE[0x0B] = Opcode {
        mnemonic  = .DCX,
        length    = 1,
        operand_a = .Register_B,
        operand_b = .None,
    }

    // INR C
    OPCODE_TABLE[0x0C] = Opcode {
        mnemonic  = .INR,
        length    = 1,
        operand_a = .Register_C,
        operand_b = .None,
    }

    // DCR C
    OPCODE_TABLE[0x0D] = Opcode {
        mnemonic  = .DCR,
        length    = 1,
        operand_a = .Register_C,
        operand_b = .None,
    }

    // MVI C, d8
    OPCODE_TABLE[0x0E] = Opcode {
        mnemonic  = .MVI,
        length    = 2,
        operand_a = .Register_C,
        operand_b = .Byte,
    }

    // RRC
    OPCODE_TABLE[0x0F] = Opcode {
        mnemonic  = .RRC,
        length    = 1,
        operand_a = .None,
        operand_b = .None,
    }

    // NOP
    OPCODE_TABLE[0x10] = Opcode {
        mnemonic  = .NOP,
        length    = 1,
        operand_a = .None,
        operand_b = .None,
    }

    // LXI D, d16
    OPCODE_TABLE[0x11] = Opcode {
        mnemonic  = .LXI,
        length    = 3,
        operand_a = .Register_D,
        operand_b = .Word,
    }

    // STAX D
    OPCODE_TABLE[0x12] = Opcode {
        mnemonic  = .STAX,
        length    = 1,
        operand_a = .Register_D,
        operand_b = .Word,
    }

    // INX D
    OPCODE_TABLE[0x13] = Opcode {
        mnemonic  = .INX,
        length    = 1,
        operand_a = .Register_D,
        operand_b = .None,
    }

    // INR D
    OPCODE_TABLE[0x14] = Opcode {
        mnemonic  = .INR,
        length    = 1,
        operand_a = .Register_D,
        operand_b = .None,
    }

    // DCR D
    OPCODE_TABLE[0x15] = Opcode {
        mnemonic  = .DCR,
        length    = 1,
        operand_a = .Register_D,
        operand_b = .None,
    }

    // MVI D, d8
    OPCODE_TABLE[0x16] = Opcode {
        mnemonic  = .MVI,
        length    = 2,
        operand_a = .Register_D,
        operand_b = .Byte,
    }

    // RAL
    OPCODE_TABLE[0x17] = Opcode {
        mnemonic  = .RAL,
        length    = 1,
        operand_a = .Register_D,
        operand_b = .None,
    }

    // NOP
    OPCODE_TABLE[0x18] = Opcode {
        mnemonic  = .NOP,
        length    = 1,
        operand_a = .None,
        operand_b = .None,
    }

    // DAD D
    OPCODE_TABLE[0x19] = Opcode {
        mnemonic  = .DAD,
        length    = 1,
        operand_a = .Register_D,
        operand_b = .None,
    }

    // LDAX D
    OPCODE_TABLE[0x1A] = Opcode {
        mnemonic  = .LDAX,
        length    = 1,
        operand_a = .Register_D,
        operand_b = .None,
    }

    // DCX D
    OPCODE_TABLE[0x1B] = Opcode {
        mnemonic  = .DCX,
        length    = 1,
        operand_a = .Register_D,
        operand_b = .None,
    }

    // INR E
    OPCODE_TABLE[0x1C] = Opcode {
        mnemonic  = .INR,
        length    = 1,
        operand_a = .Register_E,
        operand_b = .None,
    }

    // DCR E
    OPCODE_TABLE[0x1D] = Opcode {
        mnemonic  = .DCR,
        length    = 1,
        operand_a = .Register_E,
        operand_b = .None,
    }

    // MVI E, d8
    OPCODE_TABLE[0x1E] = Opcode {
        mnemonic  = .MVI,
        length    = 2,
        operand_a = .Register_E,
        operand_b = .None,
    }

    // RAR
    OPCODE_TABLE[0x1F] = Opcode {
        mnemonic  = .MVI,
        length    = 2,
        operand_a = .None,
        operand_b = .None,
    }

    // NOP
    OPCODE_TABLE[0x20] = Opcode {
        mnemonic  = .NOP,
        length    = 1,
        operand_a = .None,
        operand_b = .None,
    }

    // LXI H, d16
    OPCODE_TABLE[0x21] = Opcode {
        mnemonic  = .LXI,
        length    = 3,
        operand_a = .Register_D,
        operand_b = .None,
    }

    // SHLD a16
    OPCODE_TABLE[0x22] = Opcode {
        mnemonic  = .SHLD,
        length    = 3,
        operand_a = .Address,
        operand_b = .None,
    }

    // INX H
    OPCODE_TABLE[0x23] = Opcode {
        mnemonic  = .INX,
        length    = 1,
        operand_a = .Register_H,
        operand_b = .None,
    }

    // INR H
    OPCODE_TABLE[0x24] = Opcode {
        mnemonic  = .INR,
        length    = 1,
        operand_a = .Register_H,
        operand_b = .None,
    }

    // DCR H
    OPCODE_TABLE[0x25] = Opcode {
        mnemonic  = .DCR,
        length    = 1,
        operand_a = .Register_H,
        operand_b = .None,
    }

    // MVI H, d8
    OPCODE_TABLE[0x26] = Opcode {
        mnemonic  = .MVI,
        length    = 2,
        operand_a = .Register_H,
        operand_b = .Byte,
    }

    // DAA
    OPCODE_TABLE[0x27] = Opcode {
        mnemonic  = .DAA,
        length    = 1,
        operand_a = .Register_H,
        operand_b = .None,
    }

    // NOP
    OPCODE_TABLE[0x28] = Opcode {
        mnemonic  = .NOP,
        length    = 1,
        operand_a = .None,
        operand_b = .None,
    }

    // DAD H
    OPCODE_TABLE[0x29] = Opcode {
        mnemonic  = .DAD,
        length    = 1,
        operand_a = .None,
        operand_b = .None,
    }

    // LHLD a16
    OPCODE_TABLE[0x2A] = Opcode {
        mnemonic  = .LHLD,
        length    = 3,
        operand_a = .Address,
        operand_b = .None,
    }

    // DCX H
    OPCODE_TABLE[0x2B] = Opcode {
        mnemonic  = .DCX,
        length    = 1,
        operand_a = .Register_H,
        operand_b = .None,
    }

    // INR L
    OPCODE_TABLE[0x2C] = Opcode {
        mnemonic  = .INR,
        length    = 1,
        operand_a = .Register_L,
        operand_b = .None,
    }

    // DCR L
    OPCODE_TABLE[0x2D] = Opcode {
        mnemonic  = .DCR,
        length    = 1,
        operand_a = .Register_L,
        operand_b = .None,
    }

    // MVI L, d8
    OPCODE_TABLE[0x2E] = Opcode {
        mnemonic  = .MVI,
        length    = 2,
        operand_a = .Register_L,
        operand_b = .Byte,
    }

    // CMA
    OPCODE_TABLE[0x2F] = Opcode {
        mnemonic  = .CMA,
        length    = 1,
        operand_a = .None,
        operand_b = .None,
    }

    // NOP
    OPCODE_TABLE[0x30] = Opcode {
        mnemonic  = .NOP,
        length    = 1,
        operand_a = .None,
        operand_b = .None,
    }

    // LXI SP, d16
    OPCODE_TABLE[0x31] = Opcode {
        mnemonic  = .LXI,
        length    = 3,
        operand_a = .SP,
        operand_b = .Word,
    }

    // STA a16
    OPCODE_TABLE[0x32] = Opcode {
        mnemonic  = .STA,
        length    = 3,
        operand_a = .Address,
        operand_b = .None,
    }

    // INX SP
    OPCODE_TABLE[0x33] = Opcode {
        mnemonic  = .INX,
        length    = 1,
        operand_a = .SP,
        operand_b = .None,
    }

    // INR M
    OPCODE_TABLE[0x34] = Opcode {
        mnemonic  = .INR,
        length    = 1,
        operand_a = .M,
        operand_b = .None,
    }

    // DCR M
    OPCODE_TABLE[0x35] = Opcode {
        mnemonic  = .DCR,
        length    = 1,
        operand_a = .M,
        operand_b = .None,
    }

    // MVI M, d8
    OPCODE_TABLE[0x36] = Opcode {
        mnemonic  = .MVI,
        length    = 3,
        operand_a = .M,
        operand_b = .Byte,
    }

    // STC
    OPCODE_TABLE[0x37] = Opcode {
        mnemonic  = .STC,
        length    = 1,
        operand_a = .None,
        operand_b = .None,
    }

    // NOP
    OPCODE_TABLE[0x38] = Opcode {
        mnemonic  = .NOP,
        length    = 1,
        operand_a = .None,
        operand_b = .None,
    }

    // DAD SP
    OPCODE_TABLE[0x39] = Opcode {
        mnemonic  = .DAD,
        length    = 1,
        operand_a = .SP,
        operand_b = .None,
    }

    // LDA a16
    OPCODE_TABLE[0x3A] = Opcode {
        mnemonic  = .LDA,
        length    = 3,
        operand_a = .Address,
        operand_b = .None,
    }

    // DCX SP
    OPCODE_TABLE[0x3B] = Opcode {
        mnemonic  = .DCX,
        length    = 1,
        operand_a = .SP,
        operand_b = .None,
    }

    // INR A
    OPCODE_TABLE[0x3C] = Opcode {
        mnemonic  = .INR,
        length    = 1,
        operand_a = .Register_A,
        operand_b = .None,
    }

    // DCR A
    OPCODE_TABLE[0x3D] = Opcode {
        mnemonic  = .DCR,
        length    = 1,
        operand_a = .Register_A,
        operand_b = .None,
    }

    // MVI A, d8
    OPCODE_TABLE[0x3E] = Opcode {
        mnemonic  = .MVI,
        length    = 2,
        operand_a = .Register_A,
        operand_b = .Byte,
    }

    // CMC
    OPCODE_TABLE[0x3F] = Opcode {
        mnemonic  = .CMC,
        length    = 1,
        operand_a = .None,
        operand_b = .None,
    }

    // MOV B, B
    OPCODE_TABLE[0x40] = Opcode {
        mnemonic  = .MOV,
        length    = 1,
        operand_a = .Register_B,
        operand_b = .Register_B,
    }

    // MOV B, C
    OPCODE_TABLE[0x41] = Opcode {
        mnemonic  = .MOV,
        length    = 1,
        operand_a = .Register_B,
        operand_b = .Register_C,
    }

    // MOV B, D
    OPCODE_TABLE[0x42] = Opcode {
        mnemonic  = .MOV,
        length    = 1,
        operand_a = .Register_B,
        operand_b = .Register_D,
    }

    // MOV B, E
    OPCODE_TABLE[0x43] = Opcode {
        mnemonic  = .MOV,
        length    = 1,
        operand_a = .Register_B,
        operand_b = .Register_E,
    }

    // MOV B, H
    OPCODE_TABLE[0x44] = Opcode {
        mnemonic  = .MOV,
        length    = 1,
        operand_a = .Register_B,
        operand_b = .Register_H,
    }

    // MOV B, L
    OPCODE_TABLE[0x45] = Opcode {
        mnemonic  = .MOV,
        length    = 1,
        operand_a = .Register_B,
        operand_b = .Register_L,
    }

    // MOV B, M
    OPCODE_TABLE[0x46] = Opcode {
        mnemonic  = .MOV,
        length    = 1,
        operand_a = .Register_B,
        operand_b = .M,
    }

    // MOV B, A
    OPCODE_TABLE[0x47] = Opcode {
        mnemonic  = .MOV,
        length    = 1,
        operand_a = .Register_B,
        operand_b = .Register_A,
    }


    // MOV C, B
    OPCODE_TABLE[0x48] = Opcode {
        mnemonic  = .MOV,
        length    = 1,
        operand_a = .Register_C,
        operand_b = .Register_B,
    }

    // MOV C, C
    OPCODE_TABLE[0x49] = Opcode {
        mnemonic  = .MOV,
        length    = 1,
        operand_a = .Register_C,
        operand_b = .Register_C,
    }

    // MOV C, D
    OPCODE_TABLE[0x4A] = Opcode {
        mnemonic  = .MOV,
        length    = 1,
        operand_a = .Register_C,
        operand_b = .Register_D,
    }

    // MOV C, E
    OPCODE_TABLE[0x4B] = Opcode {
        mnemonic  = .MOV,
        length    = 1,
        operand_a = .Register_C,
        operand_b = .Register_E,
    }

    // MOV C, H
    OPCODE_TABLE[0x4C] = Opcode {
        mnemonic  = .MOV,
        length    = 1,
        operand_a = .Register_C,
        operand_b = .Register_H,
    }

    // MOV C, L
    OPCODE_TABLE[0x4D] = Opcode {
        mnemonic  = .MOV,
        length    = 1,
        operand_a = .Register_C,
        operand_b = .Register_L,
    }

    // MOV C, M
    OPCODE_TABLE[0x4E] = Opcode {
        mnemonic  = .MOV,
        length    = 1,
        operand_a = .Register_C,
        operand_b = .M,
    }

    // MOV C, A
    OPCODE_TABLE[0x4F] = Opcode {
        mnemonic  = .MOV,
        length    = 1,
        operand_a = .Register_B,
        operand_b = .Register_A,
    }
}
