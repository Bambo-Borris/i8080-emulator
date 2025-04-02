# Project Goals

Produce 3 individual software tools:
  - Intel 8080 CPU Emulator (basic functionality?)
  - Intel 8080 Assembler (take i8080 asm -> binary file to be run by emulator)
  - Intel 8080 Disassembler (potentially gets rolled into the 8080 assembler tool as a mode)

# How to Build

Open terminal and do:

```
./build.ps1 # Windows
./build.sh # Linux
```

# How to use Assmebler

```
# To assemble a file
./basm -f input_source.asm -o output_file.obj

# To assemble with internal debug logging
./basm -f input_source.asm -o output_file.obj -d
```
