# MIPS Command-Line-Interface

This is a toy implementation for an encoder, simulator, and assembler for the MIPS assembly language.  This tool is written in the bash shell.

## Purpose:

1. To provide a learning tool to students
1. To build a prototype for a web-based MIPS simulation system
1. To learn more about bash scripting via an implementation project


## Leaning Tool:

The "mips_cli" utility provides three main purposes to students as a learning tool.  

   1. View the encoding of the instruction.  
      Three instruction types are supported:  R-encoding, I-encoding, J-encoding

   1. Observe the execution of these instructions via a summary output of:
      - Arithmetic, Logic, and Shift operations via the depiction of the ALU unit
      - Multiplication and Division operations via the depiction of the MDU unit
      - Load and Store Operations via the depiction of the ALU and MEM units
      - Branch and Jump operations via the depiction for ALU and PC-Update units
      - Syscall and Trap operations via the depiction of register modifications

   1. Retain the encoding of the both text and data segment

This tool can be used either in either interactive mode or in batch mode.  While in interactive mode, students are prompted to enter one instruction at a time.  The instruction is encoded and executed.  Additional commands can be provided to examine or alter the state of the machine (a limited debugger in some ways).

While in batch mode, the tool executes a mips subroutine based upon command line arguements.  For example, the following depict hows to invoke the mips_cli tool execute a mips subroutine called "subroutine"  (It is presumed that the subroutine is located in file named "subroutine.s")

   ```bash
   $ mips_cli subroutine  arg1 arg2 ... arg3
   ```
Command line options can also be provided to alter the operation of the program.

## Interactive Modes:

1. cli:   any shell or mips instruction can be executed from the prompt
   - each mips instruction is added as the next instruction in the interactive program being created

1. prefetch: any shell or mips instruction can be entered from the prompt
   - cause: a branch instruction that has an unresolved target has been entered
   - each MIPS instruction is added, but not executed to the interactive program

   - each shell command is executed
   - a MIPS instruction that is prepended with an "@" is executed but not added to the program

1. debug: you can step through the program
   - cause: a branch instruction that has a resolved target has been entered
   - debug commands are now active, unit completion of the code that that is part of the current interactive program
   - MIPS and shell instructions prepended with an "@" are executed but not added to the program




## MIPS Language Deviations
   1. Only the main processor is executed. That is to say:
      - floating point operations are not support
      - exception and trap handling is not supported
   1. Directives
      - the .text and .data directives are mute
        - i.e., the supported data-directives may appear anywhere
      - only a subset of directives are supported.  These include
        : byte, half, word, align, ...
      - NOTE, we anticipate the tool will be fronted by a parser
   
   1. Literal Values can be provided via based numbers, e.g., "2#1 0100 0001 0010"
      - see below
   1. There is limited syntax checking, it is presumed that
      - Spaces are provided between tokens, and proper shell quoting is provided
      - Commas placed legally are also supported 
   1. Load and Store instructions have an alternative syntax, e.g., `lw $t1, 4($t2)` must be entered as:
       ```
       lw $t1, $t2, 4
       ```  
   1. Commands that more than one syntactic form
      1. div :  div $t1, $t2  (native)
      1. div :  div $t1, $t2, $t3 (pseudo)
      * i.e. pseudo instructions that introduce ambiguity are not support.

   1. Limited set of pseudo instructions are provided
   1. Macro ares are not supported


## Usage Example

   ```bash
   $ mips_cli
   (mips) addi $t1, $t1, 1
   | op   | rs  | rt  | imm            |
   |------|-----|-----|----------------|
   | addi | $t1 | $t1 |               1|
   |001000|01001|01001|0000000000000001|

     cin:            0           0;             0;                                         0;
      t1:            8           8; 0x00 00 00 08; 0b0000 0000 0000 0000 0000 0000 0000 1000;
     imm:            1           1; 0x00 00 00 01; 0b0000 0000 0000 0000 0000 0000 0000 0001; "1"
          + ----------  ----------- -------------- ------------------------------------------
      t1:            9           9; 0x00 00 00 09; 0b0000 0000 0000 0000 0000 0000 0000 1001;

   C: 0; V: 0; S: 0; Z: 0
 
 Synonym for: addi $t2, $zero, 6
   | op   | rs  | rt  | imm            |
   |------|-----|-----|----------------|
   | addiu| $0  | $t2 |               6|
   |001001|00000|01010|0000000000000110|

     cin:            0           0;             0;                                         0;
       0:            0           0; 0x00 00 00 00; 0b0000 0000 0000 0000 0000 0000 0000 0000;
     imm:            6           6; 0x00 00 00 06; 0b0000 0000 0000 0000 0000 0000 0000 0110; "6"
          + ----------  ----------- -------------- ------------------------------------------
      t2:            6           6; 0x00 00 00 06; 0b0000 0000 0000 0000 0000 0000 0000 0110;

   C: 0; V: 0; S: 0; Z: 0

(mips) sub $t1, $t2, $t3

   | op   | rs  | rt  | rd  | sh  | func |
   |------|-----|-----|-----|-----|------|
   | REG  | $t2 | $t3 | $t1 |    0| sub  |
   |000000|01010|01011|01001|00000|100010|

     cin:            1           1;             1;                                         1;
      t2:            6           6; 0x00 00 00 06; 0b0000 0000 0000 0000 0000 0000 0000 0110;
     ~t3:           -9  4294967287; 0xFF FF FF F7; 0b1111 1111 1111 1111 1111 1111 1111 0111;
          + ----------  ----------- -------------- ------------------------------------------
      t1:           -2  4294967294; 0xFF FF FF FE; 0b1111 1111 1111 1111 1111 1111 1111 1110;

   C: 0; V: 0; S: 1; Z: 0
   ```

## Literal Values:
   1. ASCII:  (explain)
   1. Numbers:
      - numbers can be prefixed with the following unary operators: +, -, ~
      - numbers can be quoted, and then may include spaces and commas for readability
      - numbers with a leading zero, with an optional character, denotes a non-decimal number.  
        - Binary: 0b, 0B denotes the number is a binary or base 2 number
        - Octal:  0, 0o, 0O denotes the number is an octal or base 8 number
        - Hexadecimal: 0x, 0X  denotes the number is a hexadecimal or base 16 number
      - numbers can take the form of [base#]n, where base is a decimal number between 2 and 64 representing the arithmetic base, and n is a number in that base.
        - n can be prefixed with the following unary operators: +, -, ~
      - examples
        - "~ 0xFF FF EE 01"
        - "- 1,345,234
         - "2# + 1010 1110 1010 1010"

