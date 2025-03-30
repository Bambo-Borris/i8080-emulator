
For referring back to online resources  [[Useful Online Links]]

During chats to ChatGPT I collated some initial notes collated here: [[Pathway to Assembler & Emulator]]

Tasks are tracked over at [[Task List]]

Flow of assembler 
```mermaid
flowchart TD

    A[Lexer] --> B[Symbols Pass]

    B[Symbols Pass] --> C[Opcode Pass]

    C[Opcode Pass] --> D[Symbol Reconciliation]

    D[Symbol Reconciliation] --> E[Write to binary file]
```
