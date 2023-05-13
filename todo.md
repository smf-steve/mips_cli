# To Do List


## Structure

  1. separate machine.bash and registers.bash
     - machine is about MIPS
     - registers are the access to the registers, or is it just a rename


## Bugs
1. implement
   - Validate the Add/u addi/u and Sub/u functionality

1. need more spacing for 
   - >>>

   1. Restructure Test Cases
     1. test cases for multiple/div
     1. test and set
 
   1. High encodings for adding does not work correctlry
       - carry bit, overflow bit
         - assign $t1 0x7FFFFFFF # overflow
         -  addi $t1, $t1, 1
         - assign $t1 0x80000000 # overflow
         -  addi $t1, $t1, -1
       - double check the subu, addu

   
   1. encode_address is not implemented


 1. Implement Pseudo Instructions
 1. Implement Synonym Instructions
    - e.g., "nop" is a synonym for: sll $zero, $zero, 0     # "0"
      - only provide a comment if the immediate value is a non decimal number


1. Error Handling
   - Modify errors to call:  instruction_error "message"

1. validate output

## Improvements
1. Consider using digital gates for output symbols
   - & --> U+2227  ? 
   - nor --> U+22BD  (V with a bar)  or down arrow 
   - U+2213      MINUS-OR-PLUS SIGN      ∓

1. Consider the error output
    1. bash: slr: command not found
    1. --> mips: slr: statement undefined

1. Incorporate a syntax checker at the beginning

1. Move to a move to the loop, eval ... approach
   1. Needed to handle labels

1. Add labels:


 1. Consider adding branch instructions..
    1. Augment PS1 to include the value of PC
    1. Augment execute to increment PC +4 
    1. ALU output shows the value of the PC
    1. if labels are know... allow the instructions
    1. if label is unknown.. please xxxx in the PC instruction
    1. have a flag to either exectue the instruction or not
    1. once the label is found, place into database:



1. Consider how to handle traps (on overflow)


1. Usage
   ```
   mips_cli  
       --encode:          provide the encoding of an instruction
       --execute       :  execute the code
       --single-pseudo :  execute the macro as a single instruction 
          -- how to show the results of the operation
       --single-macro  :  execute the pseudo instruction as a single 

   ```


 1. Consider adding memory operations.

 (mips) .data
 (mips-data)  A:  value
 &A = 0x1001 0000
 (mips-data) .text
 (mips) 

lb

     MAR:    -16777216  4278190080; 0xFF 00 00 00; 0b1111 1111 0000 0000 0000 0000 0000 0000;
     MBR:                      252; 0x00 00 00 00; 0b0000 0000 0000 0000 0000 0000 1111 1100;
          lb ----------  ----------- -------------- ------------------------------------------
      t1:         xxxx        xxx ; 0xFF FF FF FC; 0b1111 1111 1111 1111 1111 1111 1111 1100;



1. proper call anywhere where files are staged in ~/class/comp122/bin



## Documentation
 1. Min col COLUMNS=94
 1. Note that the Parsing of each command is trivially done
    - the third argument could be a immediate or a register -- there is no telling.
    - you can shoe-horn in a parser after all is done

1. Print the abstract names of the registers in the execution and the encoding


```
(mips) sub $t4, $t5, $t6
    | op   |  rs |  rt | rd  | sh  | func |
    |------|-----|-----|-----|-----|------|
    | REG  | $t5 | $t6 | $t4 |    0| sub  |
    |000000|11110|01011|01000|00000|100010|

    cin:                1;             1;                                                        1;
    rs:  t5;   4294967291;             0; 0x00 00 00 00; 0b0000 0000 0000 0000 0000 0000 0000 0000;
    rt: ~t6;   4294967291;            -1; 0xFF FF FF FF; 0b1111 1111 1111 1111 1111 1111 1111 1111;
    -------- + ----------- ------------- -------------- ------------------------------------------
    rd:  t4;          -16;             0; 0x00 00 00 00; 0b0000 0000 0000 0000 0000 0000 0000 0000;

    C: 0;       V: 0;       S: 1;       Z: 0

```

 1. Implementation: use of 64-bits for calculation: bash assumption
    1. We perform all operations as 64-bit quantities
       - values stored in the correct range: -2^31 .. 2^31-1
       - sll: performs a sign contraction before the operation to ensure an unsigned number
         -- execpt shift operations.


---


