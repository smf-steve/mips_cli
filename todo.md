# To Do List

reveiw the jump and JumpR
  -- need to update the value of the PC
  -- need to store the encoding of the instructions


1. change read_blah ==> parse_blah  ???
1. come up with a way to identify GLOBAL_VARS -- i.e., all CAPS


# Testing: May 26
  1. set.s
  1. logical.s
  1. shifts.s
  1. mult-div.s
 
  1. arithmetic.s
     - need more test exampls

     - sub  when you do a ~t6, the comment should be the original signed Dec Number
     - modify the unsigned to signal a trap on overflow  
       - v-trap (on):  V=1  --> trap
       - V-trap (off): V=1  --> off
       - no trap:
  1. load_stores.s
     - deferred

# Execute a file
  - read with file completion, etc.
    -- and readline completion

1. validate an instruction error
  - interactive mode= abort instructions
  - batch mode -> aborts program and dump core


# Notes:
  1. build  
       print_text_memory  <-- this has different output

       print_data_memory
       print_heap_memory
       print_stack_memory

(mips) print_data_memory 
address   :     4       3       2       1
0x10010000:  0x73    0x69    0x68    0x74
0x10010004:  0x20    0x73    0x69    0x20
0x10010008:  0x20    0x65    0x68    0x74
0x1001000c:  0x69    0x67    0x65    0x62
0x10010010:  0x6e    0x69    0x6e    0x6e
0x10010014:  0x66    0x6f    0x20    0x67
0x10010018:  0x65    0x68    0x74    0x20
0x1001001c:  0x69    0x72    0x73    0x20
0x10010020:  0x00    0x00    0x67    0x6e

verses

(mips) print_data_memory 
address   :                   2       1
0x10010000:  0x73    's' ;   0x6973 (26995);  0x74686973 (1952999795)
0x10010000:  0x69    'i' ;  
0x10010000:  0x68    'h' ;   0x7468 (29800);
0x10010000:  0x74    't' ;
0x10010004:  0x20    ' ' ; 
0x10010005:  0x73    's' ;  
0x10010006:  0x69    'i' ;  
0x10010007:  0x20    ' ' ;
0x10010008:  0x20    ' ' ; 
0x10010009:  0x65    'e' ; 
0x1001000a:  0x68    'h' ;
0x1001000b:  0x74    't' ;
0x1001000c:  0x69    'i' ;  

"this' ' is ' 'the ' 'begi' 'nnin'  'g of'  ' the' ' sri' 'ng"

C escape of interest:  \t \n \r \f \a \b \e
Special characes \0

  1. relook at list_labels
      - current prints the value in memory but does not account for the size of the data, type
      - I would need to also record the type of each label for proper print out.
      - 

  1. Restruction
     ```
     ## encode_R_instruction $_name $_rs "0" "0" "0"
     ## print_R_encoding $_name $_rs "0" "0" "0"
     [[ ${execute_instructions} == "TRUE" ]] || return
     ```
  1. Read notes.txt to deal with Jump and JumpR instructions


  1. Rename INstructions to INstrution
  
  1. Execution for the branch, BranZ, Jump must be completed

  1. create a list of functions exposed to the user
  1. Revise the approach to convering to hex, binary... 
     - leave the formating for the print routines.

  1. Implement the functions
     * SE and ZE for sign_extension and zero_extension
  1. double check that the ArithLogI use zE for logical operations


  1. Syscall and trap, break?
     - output would be the input and then the output variables

  1. check the iput values for LoadI, is it:
     ```version 1
     llo $t1, 0xFFFF FFFF AAAA AAAA
     lhi $t2, 0xFFFF FFFF AAAA AAAA
     ```
     ```version2 
     llo $t1,           0xAAAA AAAA
     lhi $t2, 0xFFFF FFFF 
     ```
     - can the registers be the same.  I.e., an implicit | is performed
     - per the document:  HH ($t) = i,  hence 
       - it is version 2
       - with an implicit |
   1. double check all echo and printf that the args are quoted

# NAMEing
  - Develop Glossary of variable names and definitions for encodings
    - offset:  and immediate that is an address
    - immediate
    - encoded_address: 
  - Develop a programming naming convention
    - All Global Variables associated with the machine are ALL UPPERCASE
      - MEMORY
    - all global constanstant associated with the machine, are
      - e.g., text_start, data_start
    - all with an initial _  means?

# Bugs
   - modify assign_data_label A -->  assign_label data A

   - loadStore
     - validate the use of imm and literal
       * it appears I should be using the literal value, but am using the immediate
         - an immediate is only 16 bits, where a literal is 32 bits
         - the issue will be with sign extenion, i.e., if the offset is by a negative amount
   - structure
     1. look for code that uses dst  and transfor to rd format
     1. validate the use of the A latch versus B latch
        - should they match the architecture or be abastract
        - if they match the architecture, should the A and B side be denoted in the ALU output?
        * make the A latch always present...

        ```
        (mips) addi $t1, $t2, 4
        | op   | rs  | rt  | imm            |
        |------|-----|-----|----------------|
        | addi | $t2 | $t1 |               4|
        |001000|01010|01001|0000000000000100|

      (cin)                0           0;             0;                                         0;
      (A)   t2:            0           0; 0x00 00 00 00; 0b0000 0000 0000 0000 0000 0000 0000 0000;
      (B)  imm:            4           4; 0x00 00 00 04; 0b0000 0000 0000 0000 0000 0000 0000 0100; "4"
                 + ----------  ----------- -------------- ------------------------------------------
            t1:            4           4; 0x00 00 00 04; 0b0000 0000 0000 0000 0000 0000 0000 0100;

        ```
   - assign: appears to be strange
     - because it then calls assign status bits: so it passes in 4 things
     - review how/when the status bits are updated...
     - maybe its only the V and C that need to be defined in particular situations.
       - ie..,  assign_SZ_bits ; assign_CV_bits


## Documenations
   1. Presume that a syntax checker is placed in front of mini-mips

   1. mini-mips:  a language based upon the MIPS ISA, with the following restrictions
      - Presume code is correct -- i.e., lack checking
      - Utilizes the Bash shell for processing
        - hence syntax is based upon what is legit in Bash

      - Syntax of Load/Stores are
        * NOT  {l,s}{size} rt, rs(rd)
        * BUT  {l,s}{size} rt, rd, rs
      - Syntax of Macros:  macro ( a b c d e )
      - Syntax; commas are optional, but if present must be part of the token

      - Immediates have richer syntax, but must be quoted
      - Floating Point is not supported

      - Data Segment:
        - must appear first (i.e., data segments labels MUST be defined before use)
        - i.e., 'la' must not yield an error

      - The ALU depicts the status flags of: C, V, S, & Z
        - even though the MIPS arch only provides the Z bit for branching

      - Implements only one form of Endianess: Big
      
      - Memory Interface utilizes a MAR & MBR
        - maybe implement a memory module to illustrate allignment 

   1. with the following  extensions
      - immediates can be use 2# notation
      - labels are within two name space, i.e., the label A can be used both for data and for text
        - can't have self modifing code
      - At most one lable can be depicted per line.
        - Labels: blank lines with labels, are ignored, but labels are stored anyways.


   1. mini-mips: purpose
      - Generates appropriate encoding for mips insturctions
      - Depicts the operation of the ALU and Write Back
      - Proves a minuture simulator
      - Serves as a prototype for a more robust simulator

## Use Cases
   1. Interactive mode:
      - individual instruction: encoding and execution
   1. Batch mode:
      - simulation of code.

## Process:
   1. CLI Batch.
      1. preload: generate the labels
      1. execute: each instruction
      1. output as approprate

   1. Interactive "execute filename"  # just replace "execute" with mips_cli
      - next: command to move forward
      - cont: 
      - time-step:  amount of time between steps

   1. Interactive 
      - read each line
      - process label/s
      - print encoding
      - executed the code
        - place the encoding and the "instruction" into the text_segment
          *  read \_line
          *    encoding=execute the line
          *    text_line = ( line, IR )
          ?    issue is how do I get the encoding has to go into the IR.
      - if deferred label
        - scan ahead for label
      - execute line 

      ? If the label is backwards:
        - then the label address is know
        - how do I rewind


## CLI
   - mips_cli  filename  arg1 arg2 arg3  # entry is the same as filename
   - mips_cli  filename.s  entry arg1, arg2 arg3
   - mips_cli  -I filename.s  entry arg1, arg2 arg3
   - mips_cli  -I <dir>  entry arg1, arg2 arg3  # Include all the files in the spacified directory


   - mips_cli  --encodings  --assemble --simulation --with-core 
     - encodings:  print out the encodings for each of the instructions
     - assemble: generate the filename.text and filename.labels for the input 
     - simulation: execute the program that is provided to system
     - with-core: execute the program and then dump core

## Files:
   - filename.s  : a MIPS program
   - filename.core:  a bash script that
       - enumerates the contents of the data, stack, and heap segments of the program
       - enumerates the contents of the registers (which include the PC)

## CLI commands:
   - file filename:  sets the current filename
   - load filename:
     - preprocess the file to use or produce the filename.labels file
   - execute filename
   - reset : resets machine to defaults

   - set: to set particular options
     - time step

   - dump core

   - print J_encoding  op address/Label
   - print R_encoding  func rs rt rd sh
   - print I_encoding  op rs rt imm
   - print addr_encoding    label
   - print offset_encoding  label  [ PC ]   # 
   - print register_encoding $reg
   - print shamt_encoding    num
   - print registers [ $t1 ]
   - print register $t1
   - print labels data|text
   - print memory [segment] [address [ ... [address] ]  # restricted to a segment?

   - LB  Least Sign
   - LH  Least Sign Half
   - MH  Most Sign Half
   - Byte {1,2,3,4} reg|value
   - Flip-Endianness 
   - SE  imm imm imm        # 16 -> 32 bits
   - ZE                     # 16 -> 32 bits
   - base2  
   - base8
   - base10
   - base10
   - ascii.index
   - ascii.char




## Memory and Alignment
   - Should we have a memory module that shows how
     - values are placed into the MAR / MBR





## Validate
   - Refine, Test, and Validate examples
     - Branch Instructions: Need Labels
     - Jump Instructions: Need Labels
     - Load and Stores: Need Labels


## Traps Error Handling

1. Error Handling
   - Modify errors to call:  instruction_error "message"
   - Consider the error output
     1. bash: slr: command not found
     1. --> mips: slr: statement undefined

1. Implement Traps

## Extended Instructions
   1. Implement Pseudo Instructions
   1. Implement Synonym Instructions
      - e.g., "nop" is a synonym for: sll $zero, $zero, 0     # "0"
      - only provide a comment if the immediate value is a non decimal number
   1. Review how this are done to see if we can simply to be small include file or other.

      ```this
      function rem () {
         echo "Pseudo instruction for:"
         sub_execute div \$$(name $2), \$$(name $3)
         sub_execute mfhi \$$(name $1)
         pseudo_off
      }
      ```

      ```to
      function rem () {
         div $rs, $rt
         mfhi $rd
      }

      echo "Pseudo instruction for:"
      local rs=$2
      local rt=$3
      local rd=$1
      rem
      pseudo_off
}
      ```


## Bugs
1. implement
   - Validate the Add/u addi/u and Sub/u functionality

   1. High encodings for adding does not work correctlry
       - carry bit, overflow bit
         - assign $t1 0x7FFFFFFF # overflow
         -  addi $t1, $t1, 1
         - assign $t1 0x80000000 # overflow
         -  addi $t1, $t1, -1
       - double check the subu, addu

## Improvements
1. Consider completting the carry in ... operations..
   (It's for educational purposes..)


1. Consider using digital gates for output symbols
   - & --> U+2227  ? 
   - nor --> U+22BD  (V with a bar)  or down arrow 
   - U+2213      MINUS-OR-PLUS SIGN      ∓


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


Here the value of the register t3 should be presented in the comment
(mips) sub $t1, $t2, $t3

   | op   | rs  | rt  | rd  | sh  | func |
   |------|-----|-----|-----|-----|------|
   | REG  | $t2 | $t3 | $t1 |    0| sub  |
   |000000|01010|01011|01001|00000|100010|

     cin:            1           1;             1;                                         1;
      t2:            6           6; 0x00 00 00 06; 0b0000 0000 0000 0000 0000 0000 0000 0110;
     ~t3:           -9  4294967287; 0xFF FF FF F7; 0b1111 1111 1111 1111 1111 1111 1111 0111;  t3: 8
          + ----------  ----------- -------------- ------------------------------------------
      t1:           -2  4294967294; 0xFF FF FF FE; 0b1111 1111 1111 1111 1111 1111 1111 1110;

   C: 0; V: 0; S: 1; Z: 0


