# To Do List
  1. Why in subl 'mult' is not blue  -- even though it is a native 

  1. separate machine.bash and registers.bash
     - machine is about MIPS
     - registers are the access to the registers, or is it just a rename

  1. implement the encodings for
     I, J, R

  1. Implement the Shifts toghether
     - execute_Shift

  1. reimplement the shifts, note srlv, this should be the pattern
  ```
sllv $t5, $t2, $t4
      t2:              10; 0x00 00 00 0A; 0b0000 0000 0000 0000 0000 0000 0000 1010;
      t4:              24; 0x00 00 00 18; 0b0000 0000 0000 0000 0000 0000 0001 1000;
          <<   ----------- -------------- ------------------------------------------
      t5:       167772160; 0x0A 00 00 00; 0b0000 1010 0000 0000 0000 0000 0000 0000;

srlv $t1, $t3, $t4
      t3:              11; 0x00 00 00 0B; 0b0000 0000 0000 0000 0000 0000 0000 1011;
     imm:              24; 0x00 00 00 18; 0b0000 0000 0000 0000 0000 0000 0001 1000; "$t3 & 0x1F"
          >>>  ----------- -------------- ------------------------------------------
      t1:               0; 0x00 00 00 00; 0b0000 0000 0000 0000 0000 0000 0000 0000;

srav $t5, $t2, $t4
      t2:              10; 0x00 00 00 0A; 0b0000 0000 0000 0000 0000 0000 0000 1010;
      t4:              24; 0x00 00 00 18; 0b0000 0000 0000 0000 0000 0000 0001 1000;
          >>   ----------- -------------- ------------------------------------------
      t5:               0; 0x00 00 00 00; 0b0000 0000 0000 0000 0000 0000 0000 0000;

```

 1. Possible, clear the environment as part of mps_cli invocation


 1. Parseing of each command is trivially done
    - the third argument could be a immediate or a register -- there is no telling.

 1. need to make the output better for
     - sub $t4, $t5, $t6
     - the output is correct, but the dst values don't easily match up (?)
       - the comment for the rt register should be "~ register"

 1. should the abstract names for the registers be printed: rt, rt, rs

```
(mips) sub $t4, $t5, $t6
     c:                   1              1                                          1
     rs: t5;               0; 0x00 00 00 00; 0b0000 0000 0000 0000 0000 0000 0000 0000;
     rt: t6;              -1; 0xFF FF FF FF; 0b1111 1111 1111 1111 1111 1111 1111 1111;
   + ------ --------------- -------------- ------------------------------------------
     rd: t4;               0; 0x00 00 00 00; 0b0000 0000 0000 0000 0000 0000 0000 0000;
```
 1. If we get ride of the base markers we can save 4 spaces -- don't like
 1. If we get reide of the nibble spaceing, we can save 4 spaces -- don't like
 1. rename cin, to "c"

```
(mips) sub $t4, $t5, $t6
    cin:                1              1                                          1
    rs: t5;               0; 00 00 00 00; 00000000 00000000 00000000 00000000;
    rt: t6;              -1; FF FF FF FF; 11111111 11111111 11111111 11111111;
  + ------- --------------- -------------- ------------------------------------------
    rd: t4;               0; 00 00 00 00; 00000000 00000000 00000000 00000000;
```


 1. read_immediate
    >= 0x80 00 00 00 -- should return a negative number 
 1. read_shmat "2#- 11111"
    (mips) read_shmat "2#- 11111"
    -0
    (mips) read_shmat "2#111111"
    -0

1. Review conversion routines
   - to binary  prefix, group, bits, value
   - to hex     prefix, group, bits, value

     to_binary "0b" 25, 16
     to_hex    "--" 8 16 n

1. need to move to the loop, eval ... approach

1. (mips) move $t1, $t2
move $t1, $t2 # is a synonym for:      cin:               0              0  

 1. Modify errors to call:  instruction_error "message"
 1. quandary:
    1. bash uses 64 bits, so
    >>  1. perform all operations as 64 bits
         - store all values as 64 bit quanitiies
         - store only values in the correct range
           * hence check in the range of -2^31 .. 2^31
         - present as is...  

       1. store all values in the range -2^63 .. 2^63
         - perform all operations in 64 bits 
         - ensure the values are in the range -2^31 .. 2^31 
         - present the numbers as is....

       1. perform all operations as 32 bits
         - if numbers are negative in 32 bits,
           * perform sign extention
           * perform operation
           * perfrom sign contraction if negative


 1. immediate values should be only 32-bit number
    - for xxxi statements, test that it is 16bits
    - for sxx  statements, test that it is 5bits (unsiged)

 1. Add test for sxxv to ensure the value in the register is 5bits.

 1. consider only providing the immediate text format if
    - the orignal input is a non decimal number
    - moreover, don't include the comment....
    - use the comment as a comment.

    ```bash
    "nop" is a synonym for: ssl $zero, $zero, 0     # "0"
      zero:                0; 0x00 00 00 00; 0b0000 0000 0000 0000 0000 0000 0000 0000;
      imm:                0; 0x00 00 00 00; 0b0000 0000 0000 0000 0000 0000 0000 0000; "0"
           <<   ----------- -------------- ------------------------------------------
     zero:                0; 0x00 00 00 00; 0b0000 0000 0000 0000 0000 0000 0000 0000;


    ```
 1. Add the addu & subu statements
    - decimal outputs should be present as a positive number
    - current all statements are deemed signed

 1. Validate that non_u statements present a signed number for output


 1. Have flags that inform the execution to..
    1. execute every instruction
    1. execute psuedo instructions as one instruction
    1. execute macro instructions as one instructions

 1. Add in error checking for immediates.
    - exit on illegal values.

 1. For performance reasons
    - determine where we need to check for values out of range
    - currently it is done in several locations
    - E.g., 
      - putting it into a register
      - pulling it out of a register
      - printing a register
      - after a calcuation  <<
    - this will require pulling about sign-extenion and sign-contraction

 1. Consider the error output
    1. bash: slr: command not found
    1. --> mips: slr: statement undefined

 1. Consider adding memory operations.

 (mips) .data
 (mips-data)  A:  value
 &A = 0x1001 0000
 (mips-data) .text
 (mips) 

 1. Add to output the status flags
    - for specific causes -- emit if we trap to the OS
    - for "unsigned" commands -- emit that we Don't trap to the OS

 1. Consider adding branch instrucions..
    1. Augment PS1 to include the value of PC
    1. Augment execute to increment PC +4 
    1. ALU output shows the value of the PC
    1. if labels are know... allow the instructions
    1. if label is unknown.. please xxxx in the PC instruction
    1. have a flag to either exectue the instruction or not
    1. once the label is found, place into database:

 1. Implement pseudo_on and pseudo_off
    1. print the initial statment
    1. augment the output of execution to show its in a pseudo instruction

    ```
    li $t1, 1
      1.  addiu $t1, $zero, 1
    ```
1. Implement synonym_on and synonym_off





#alias srlv="R_operation "
   # max = 0111111111111111
   # sra =
