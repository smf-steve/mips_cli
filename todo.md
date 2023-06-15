# To Do List

1. Jump/R instructions
  - need to do the NPCWB and the 
  - RA assignment
  - is the Branch instruction a model for the output?

1. For forward labels,
   - need to put in a message..
     ```
      Paused execution of:  beq $t1, $t2, next
      (prefetch next)  next: nop
      Ready to execute: "beq $t1, $t2, next"
      (debug) s
      Ready to execute: "next: nop"
     ```


1. get rid of the _deferred_, change to unresolved or ??????

1. execute a file...
   - should this force it to got into preload first, then execute no stop...
1. newline after NPCWB_stage

1. Debug Mode..
   - need some message to say comming out of debug mode.
   - yes the prompt changes but...

1. add a l list to debug mode to proint out current lines.

1. validate an instruction error
  - interactive mode= abort instructions
  - batch mode -> aborts program and dump core

1. reveiw all of the promps.
   - e.g., the execute prompt should not be $

1.  Currently recording non MIPS instructions
    ```
    
    (mips) dump_instructions
    declare -a INSTRUCTION=(
     [4194304]="a: nop"
     [4194308]="b: nop"
     [4194312]="c: nop"
     [4194316]="dump_segment DATA"
     [4194320]="dump_instructions "
    )
    ```
    - update prefetch loop to ignore non-MIPS instructions
    - I.e., need a list of supported instructions


1. Test forward loop
1. Add test case of forward and backward loops

# Testing: May 26
  1. set.s
  1. logical.s
  1. shifts.s
  1. mult-div.s
  1. load_stores.s
     - deferred
 
  1. arithmetic.s
     - need more test exampls

     - sub  when you do a ~t6, the comment should be the original signed Dec Number
     - modify the unsigned to signal a trap on overflow  
       - v-trap (on):  V=1  --> trap
       - V-trap (off): V=1  --> off
       - no trap:

      1. Consider how to handle traps (on overflow)


## Traps Error Handling

1. Error Handling
   - Modify errors to call:  instruction_error "message"
   - Consider the error output
     1. bash: slr: command not found
     1. --> mips: slr: statement undefined

1. Implement Traps


## Syscalls
  1. Syscall and trap, break?
     - output would be the input and then the output variables


## Status Bits Review
 1. Validate the following syntax don't or do make use of the ALU
      * DivMult, LoadI, Move {From, To}, Trap, Syscall
    - If the use the ALU (to pass values through), then make an appropriate call to the ALU
    - Ensure the status bits are set



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




# Notes:
  1. build  routines to print out memory and the like
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


  1. Read notes.txt to deal with Jump and JumpR instructions
  1. Execution for the branch, BranZ, Jump must be completed

  1. create a list of functions exposed to the user
  1. Revise the approach to convering to hex, binary... 
     - leave the formating for the print routines.

  1. Implement the functions
     * SE and ZE for sign_extension and zero_extension
  1. double check that the ArithLogI use zE for logical operations



# Bugs

1. 

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

## Installation
1. proper call anywhere where files are staged in ~/class/comp122/bin


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



1. Usage
   ```
   mips_cli  
       --encode:          provide the encoding of an instruction
       --execute       :  execute the code
       --single-pseudo :  execute the macro as a single instruction 
          -- how to show the results of the operation
       --single-macro  :  execute the pseudo instruction as a single 

   ```



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



## Improvements
1. Consider completting the carry in ... operations..
   (It's for educational purposes..)

1. READLINE:
  - use of readline for file line completion


1. Consider using digital gates for output symbols
   - & --> U+2227  ? 
   - nor --> U+22BD  (V with a bar)  or down arrow 
   - U+2213      MINUS-OR-PLUS SIGN      ∓


  1. Labels:
      - currently a label is only associated with a single location in memory
      - for data labels, we have no notion of the size
      - for text labels, we do know it is a size of four bytes
      - Should we include a size with a label

      ```
      function lookup_data_size() {
        eval echo \$data_size_${1}
      }
      ```

     - size can be determined here as:  (( DATA_NEXT - DATA_LAST))
     ```
     assign_data_label "$i" "${DATA_LAST}"
     ```








