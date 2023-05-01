# To Do List
 1. read_immediate
    >= 0x80 00 00 00 -- should return a negative number 
 1. read_shmat "2#- 11111"
    (mips) read_shmat "2#- 11111"
    -0
    (mips) read_shmat "2#111111"
    -0

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

 1. rename internal varables to match the name of the 
    instruction format, e.g., rd, rs, rt, etc

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

 1. Implement the mult/div functions
 1. Test the vari

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
