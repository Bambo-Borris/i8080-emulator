
## Emulation 

Produce a basic emulator for a basic ASM set 
### . Define a Simplified Instruction Set

- **Instruction Types:**  
    Focus on basic operations such as:
    
    - **Load/Store:** e.g., `LOAD R1, 5`, `STORE R1, 0x200`
    - **Arithmetic:** e.g., `ADD R1, 3`, `SUB R2, 1`
- **Opcode Mapping:**  
    Create a table that maps each mnemonic to a specific binary opcode. For example:
	
| Mneomic | Operation          | Binary Opcode |
| ------- | ------------------ | ------------- |
| LOAD    | Load immediate     | 0x01          |
| STORE   | Store register     | 0x02          |
| ADD     | Add immediate      | 0x03          |
| SUB     | Subtract immediate | 0x04          |
Fixed width: 3 bytes, 1 for opcode, 1 for register, and 1 for immedaite

    
    You can expand this table based on your design. For simplicity, assume each instruction has a fixed length (e.g., 3 bytes: 1 for the opcode, 1 for the register, and 1 for the immediate value).

Further detail on simple CPU can be found under assembler here: [[#^d38e2d]]


## Assembler 

For an assembler there are the following required

To build an assembler that reads assembly code from a text file and outputs a binary file, you'll need several key components:

1. **Instruction Set Specification:**
    
    - A clear definition of your CPU's instruction set, including opcodes, registers, addressing modes, and any special instructions.
2. **Lexical Analyzer (Tokenizer):**
    
    - A tool or module to read the assembly text and break it down into tokens (mnemonics, operands, labels, etc.).
3. **Parser:**
    
    - A parser to process the tokens according to the assembly language grammar. This typically builds an intermediate representation (IR) or an abstract syntax tree (AST) of your instructions.
4. **Symbol Table & Label Resolution:**
    
    - A mechanism to manage labels and symbols. In many assemblers, a two-pass process is used:
        - **Pass One:** Scans the code to record label addresses and determine the structure of the code.
        - **Pass Two:** Uses the information from pass one to generate the correct binary instructions.
5. **Binary Encoding Module:**
    
    - A component that translates the intermediate representation into the actual binary opcodes and operand encodings according to your CPU’s specification.
6. **File I/O:**
    
    - Code to read the input assembly file and write the resulting binary data to an output file.
7. **Command-Line Interface (CLI):**
    
    - A user-friendly CLI that accepts arguments (like input file path, output file path, and any optional flags) to control the assembling process.
8. **Error Handling and Reporting:**
    
    - Robust error detection to catch syntax errors, undefined labels, or illegal instructions, and provide meaningful messages to the user.
9. **Development Language and Libraries:**
    
    - Choose a programming language that suits your needs (e.g., Python for ease-of-use, C/C++ for performance). You might also use libraries for argument parsing (like Python’s `argparse`), file handling, and potentially even for building parsers (like Python’s `pyparsing` or similar tools).

In summary, you'll be constructing an assembler tool with components for parsing, symbol management, binary encoding, and command-line operations. This modular approach will help you manage complexity and allow for easier debugging and future enhancements.

### Labels and parser passes 
Labels in assembly language serve as symbolic names for memory addresses, and internally, the assembler typically manages them through a symbol table. Here’s how they are generally treated:

1. **Symbol Table Creation:**
    
    - When the assembler processes the assembly source, it records each label in a symbol table. The table maps label names to their corresponding memory addresses or offsets within the program.
2. **Two-Pass Assembly Process:**
    
    - **First Pass:**
        - The assembler scans the code to determine the address of each instruction or data item.
        - As labels are encountered, their names are recorded along with the current address in the symbol table.
        - This pass sets up the groundwork for resolving any forward references (where a label is used before it’s defined).
    - **Second Pass:**
        - With the symbol table complete, the assembler revisits the code.
        - It replaces all label references in the instructions with the actual addresses derived during the first pass.
        - Any unresolved references from the first pass can now be patched correctly.
3. **Handling Forward References:**
    
    - In cases where a label is used before its definition (a forward reference), the assembler may initially insert a placeholder or mark the instruction for backpatching.
    - During the second pass, once the label’s address is known, the placeholder is replaced with the actual address.
4. **Relocation and Linking:**
    
    - For more complex systems that involve multiple modules or relocatable code, labels might also interact with relocation records.
    - These records help adjust addresses when the code is loaded into memory, ensuring that references to labels remain correct even if the program isn’t loaded at a fixed address.

In summary, labels are essentially placeholders for memory addresses that are resolved during the assembly process, usually with the aid of a symbol table and a multi-pass approach to handle both backward and forward references effectively.


### Basic Assembler

Requires: 
1. Lexer/Tokenizer - Convert information into tokens (mnemonics, registers, numerical literals)
2. Parser - Convert token stream into internal representation of instructions 
3. Instruction encoding - Convert instructions from parser into their binary form
4. Writing instruction data to binary file - What it says


^d38e2d

