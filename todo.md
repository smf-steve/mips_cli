# To Do List

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

   - assign: appears to be strange
     - because it then calls assign status bits: so it passes in 4 things

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

      - The ALU depicts the status flags of: C, V, S, & Z
        - even though the MIPS arch only provides the Z bit for branching

      - Implements only one form of Endianess: Big
      
      - Memory Interface utilizes a MAR & MBR
        - maybe implement a memory module to illustrate allignment 

   1. with the following  extensions
      - immediates can be use 2# notation
      - labels are within two name space, i.e., the label A can be used both for data and for text
        - can't have self modifing code

   1. mini-mips: purpose
      - Generates appropriate encoding for mips insturctions
      - Depicts the operation of the ALU and Write Back
      - Proves a minuture simulator
      - Serves as a prototype for a more robust simulator



## Implement Labels:
   1. Develop a pre-executes process that
      - reads the file
      - generates a list of labels
      - emits any errors w.r.t. missing labels
   1. Develop a process to 
      - declare and define labels upon initial introduction
      - declare labels upon first usage
      - defines labels after first usage
      * The execution engine needs to be shut off until the
        label is defined.

   1. Memory Labels:
      - Assert that the data section must be provided first!
        -- i.e., 'la' must not yield an error

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


## Structure


## Bugs
1. implement
   - Validate the Add/u addi/u and Sub/u functionality

1. need more spacing for 
   - >>>

   1. High encodings for adding does not work correctlry
       - carry bit, overflow bit
         - assign $t1 0x7FFFFFFF # overflow
         -  addi $t1, $t1, 1
         - assign $t1 0x80000000 # overflow
         -  addi $t1, $t1, -1
       - double check the subu, addu

   
   1. encode_address is not implemented




1. validate output

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

 1. Implementation: use of 64-bits for calculation: bash assumption
    1. We perform all operations as 64-bit quantities
       - values stored in the correct range: -2^31 .. 2^31-1
       - sll: performs a sign contraction before the operation to ensure an unsigned number
         -- execpt shift operations.


---


