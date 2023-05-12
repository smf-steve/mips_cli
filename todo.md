# To Do List


## Bugs
   1. sllv $t5, $t2, $t4
   1. no encoding for MULTDIV

   1. validate the semantics of the shifts
      - treat the number as unsigned, and max value is 0x1F
      - or treat the number as $t4 & 0x1F
      - should the output pattern be
        ```
        sllv $t5, $t2, $t4
              t2:              10; 0x00 00 00 0A; 0b0000 0000 0000 0000 0000 0000 0000 1010;
              t4:              24; 0x00 00 00 18; 0b0000 0000 0000 0000 0000 0000 0001 1000;  "$t4 & 0x1F"
                  <<   ----------- -------------- ------------------------------------------
              t5:       167772160; 0x0A 00 00 00; 0b0000 1010 0000 0000 0000 0000 0000 0000;
        ```


   1. Validate
      * addi $t2, $t2, 0xFFFF
        - but it detects it as a large positive number
        - where as  -32769 is okay.
        - need to make read_immedat
        - take the number and sign extention to
        - a 64bit number, and then test the value


 1. Read Constant --> literals:  Test and validate
    1. read_immediate
       >= 0x80 00 00 00 -- should return a negative number 
    1. read_shmat "2#- 11111"
       (mips) read_shmat "2#- 11111"
       -0
       (mips) read_shmat "2#111111"
       -0


    1. immediate values should be only 32-bit number
       - for xxxi statements, test that it is 16bits
       - for sxx  statements, test that it is 5bits (unsiged)


1. validate the use of ~ for sub operations
     - sub $t4, $t5, $t6
     - the output is correct, but the dst values don't easily match up (?)
       - the comment for the rt register should be "~ register"


 1. Implement Pseudo Instructions
 1. Implement Synonym Instructions
    - e.g., "nop" is a synonym for: sll $zero, $zero, 0     # "0"
      - only provide a comment if the immediate value is a non decimal number



## Improvements

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


1. Error Handling
   - Add in error checking for immediate.
   - exit on illegal values.
   - Modify errors to call:  instruction_error "message"


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


## Structure

  1. separate machine.bash and registers.bash
     - machine is about MIPS
     - registers are the access to the registers, or is it just a rename



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


