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
}
