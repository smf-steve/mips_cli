# MIPS Command-Line-Interface

This is a toy implementation of the MIPS ALU instructions in bash shell. 

## Purpose:

1. To learn more about bash scripting via an implementation project
1. To build a prototype for a web-based MIPS simulation system
1. To provide a learning tool to students

## MIPS Language Deviations
   1. Registers can allow be referenced with names, e.g., $zero versus $0
   1. If a cmd that expects a registers is provided with a
      non $value, the integer is assumed to be the same as $in
      - for example:
      
   1. Constants can be provided via based numbers
   1. Spaces must be provided between tokens, and proper shell quoting is required.
   1. Characters may be entered either quoted or not.
      - Characters in the range 0..9 are assumed to be integers
   1. 


## Usage Example

   ```bash
   $ mips_cli
   (mips) addi $t1, $t1, 1

   addi $t1, $t1, 1
     cin:          0;             0;                                         0;
      t1:          0; 0x00 00 00 00; 0b0000 0000 0000 0000 0000 0000 0000 0000;
      imm:         1; 0x00 00 00 01; 0b0000 0000 0000 0000 0000 0000 0000 0001;  "1"
            +  ------ -------------- ------------------------------------------
      t1:          1; 0x00 00 00 01; 0b0000 0000 0000 0000 0000 0000 0000 0001;


  (mips) li $t2, 6   
   li $t2, 6
     1. addiu $t2, $zero, 6

     cin:          0;             0;                                         0;
      t2:          0; 0x00 00 00 00; 0b0000 0000 0000 0000 0000 0000 0000 0000;
     imm:          6; 0x00 00 00 06; 0b0000 0000 0000 0000 0000 0000 0000 0110; 
           +   ------ -------------- ------------------------------------------
      t2:          6; 0x00 00 00 06; 0b0000 0000 0000 0000 0000 0000 0000 0110;


   (mips) sub $t1, $t2, $t3
   sub $t1, $t2, $t3
     cin:          1;             1;                                         1;
      t2:          6; 0x00 00 00 05; 0b0000 0000 0000 0000 0000 0000 0000 0110;
     ~t3:         ~5; 0xFF FF FF FA; 0b1111 1111 1111 1111 1111 1111 1111 1010; 
           -   ------ -------------- ------------------------------------------
      t1:          0; 0x00 00 00 00; 0b0000 0000 0000 0000 0000 0000 0000 0000;


   ```

## CLI Commands:
   1. reset_registers: set all registers to 0
   1. set_registers: set all registers to a random value
   1. execute"filename":  execute the code in "filename"
   1. list_data: lists the contents of the .data segment
   1. print_register 

## Immediate Values:
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

   1. Floating point: not implemented


## Limitations:
   1. limited to the CPU (i.e., no floating point)
   1. No branching or labels
   1. No memory operations


## Issues:  
   1. commands that more than one syntactic form
      1. div :  div $t1, $t2  (native)
      1. div :  div $t1, $t2, $t3 (pseudo)
      * i.e. pseudo instructions that introduce ambigutiy are not provided.
