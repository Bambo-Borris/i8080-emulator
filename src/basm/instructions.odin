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
    SP,
    Byte,
    Word,
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
}
