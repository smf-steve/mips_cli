MIPS32 Release 1


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

