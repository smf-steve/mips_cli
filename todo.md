# To Do List
1. reset_macros, list_macros  -- done

## Labels
1. reset_labels, list_labels

1. labels still use old memory model

1. labels should be implemented via arrays and not via the alias method
  - to keep it consistent with the other stuff put into the CORE file

1. use of upper and lower with unresolved label?

1. escape sequences in ascii...
   -->  ascii.index


----

## Status Bits Review
 1. Validate the following syntax don't or do make use of the ALU
      * DivMult, LoadI, Move {From, To}, Trap, Syscall
    - If the use the ALU (to pass values through), then make an appropriate call to the ALU
    - Ensure the status bits are set

---

1. output of special registers need to be updated
   - "$(name $\_mar)""

1. dumping of dump_symbol_table is broken 
   1. ehn you try to load_core the attribute of "declare" makes the varibles local
   1. hence you need to remove the declare in front of them.


## Memory and Alignment
   - Should we have a memory module that shows how
     - values are placed into the MAR / MBR



## Encoding of directives
   1. double check .word, etc for final output
   1. ensure that it is always presented with the correct endianess
   1. determine the output for  .ascii 


1. Encoding of .word, w.r.t ENDIANNESS
   - currently, the value is show without respect to ENDIANESS
   - stored byte order is Big endian
   - print byt 0, byte 1, byte 2, byte 3, byte 4
   - maybe the prinout of it should be:
   ```
   | address    | value                                         |
   |------------|-----------------------------------------------|
   |            | byte: 0   | byte: 1   | byte: 2   | byte: 3   | "BIG ENDIAN"
   | 0x10010010 | 0000 0000 | 0000 0000 | 1111 1111 | 1111 1111 | "0x00 00 FF FF"
   ```
   - separate the notion of encoding various endiananss

   ```
   Encoding:
   | address    | value                                   |
   |------------|-----------------------------------------|
   | 0x10010010 | 0000 0000 0000 0000 1111 1111 1111 1111 | "0x00 00 FF FF"
   ```
   ```
   Memory: BIG ENDIAN"

  | address    | value     |  ascii  |  half      | word
  |------------|-----------|---------|------------|-----------
  | 0x10010013 | 1111 1111 |         |            |
  | 0x10010012 | 1111 1111 |         |  0xFF FF   |
  | 0x10010011 | 0000 0000 |         |            |
  | 0x10010010 | 0000 0000 |         |  0x00 00   |  0x00 00 FF FF |

   ```

   print_memory address address


function print_mem_value () {
    -- prints stuff from the MAR/MBR
    -- rename based upn the unit?

function print_memory() {
    -- not called
    -- pass inthe data segment

function print_memory_value 
    -- then encoding of .word, etc


  1. build  routines to print out memory and the like

print_data  
print_text : provides the encoding for each
   [address]:  encoding ; { labels }: instructions

verses

(mips) print_data
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


(top) .word 36

   | address    | value                               |
   |------------|-------------------------------------|
   | 0x10010000 | 00000000 00000000 00000000 00100010 | "0x00000024"
   | 0x10010004 |

   Memory: BIG ENDIAN
   | address    | byte      | ASCII |  half         |   word          |         
   |------------|-----------|-------|---------------|-----------------|
   | 0x10010003 | 0x00 (0)  | \0    |               |                 |
   | 0x10010002 | 0x00 (0)  | \0    |  0x0000 (0)   |                 |
   | 0x10010001 | 0x00 (0)  | \0    |               |                 |
   | 0x10010000 | 0x24 (36) | '$'   |  0x0024 (36)  | 0x00000024 (36) |


(top) .dword "0x0000004800000024"

   | address    | value                            |
   |------------|----------------------------------|
   | 0x10010000 | 00000000 00000000 00000000 00100010 / 
                / 00000000 00000000 00000000 00100010 |  "0x0000004800000024"
   | 0x10010008 |

   Memory: BIG ENDIAN
   | address    | byte      | ASCII |  half         |   word          |         
   |------------|-----------|-------|---------------|-----------------|
   | 0x10010007 | 0x00 (0)  | \0    |               |                 |
   | 0x10010006 | 0x00 (0)  | \0    |  0x0000 (0)   |                 |
   | 0x10010005 | 0x00 (0)  | \0    |               |                 |
   | 0x10010004 | 0x48 (72) | 'H'   |  0x0048 (72)  | 0x00000048 (72) |
   |------------|-----------|-------|---------------|-----------------|
   | 0x10010003 | 0x00 (0)  | \0    |               |                 |
   | 0x10010002 | 0x00 (0)  | \0    |  0x0000 (0)   |                 |
   | 0x10010001 | 0x00 (0)  | \0    |               |                 |
   | 0x10010000 | 0x24 (36) | '$'   |  0x0024 (36)  | 0x00000024 (36) |

(top) .ascii "hello world!"
    0x68 0x65 0x6c 0x6c 0x6f 0x20 0x77 0x6f 0x72 0x6c 0x64 0x21

   | address    | value                               |
   |------------|-------------------------------------|
   | 0x10010000 | 01101000 01100101 01101100 01101100 /  "0x68 65 6c 6c"
                / 01101111 00100000 01110111 01101111 /  "0x6f 20 77 6f"
                / 01110010 01101100 01100100 00100001 |  "0x72 6c 64 21"
   | 0x1001000C |

   Memory: BIG ENDIAN

   blah...

(top) .align 4

   | address    | value             |
   |------------|-------------------|
   | 0x10010002 | -------- -------- | "word align"
   | 0x10010004 |

   -- nothing written to memory


========================



## Implementetion of .macro
   1. address labels
   1. further testing
   1. issue what if comments are added
      should these be removed?
   1. nested macro... support or not support?
      - will need the ability to temporary change settings
   1. macros can be redefined
      - pseduo instructions take precedence
      - the last define takes precence


### Modes
1. For forward labels,
   - need to put in a message..
     ```
      Paused execution of:  beq $t1, $t2, next
      (prefetch next)  next: nop
      Ready to execute: "beq $t1, $t2, next"
      (debug) s
      Ready to execute: "next: nop"
     ```

1. Debug Mode..
   - need some message to say comming out of debug mode.
   - yes the prompt changes but...

1. reveiw all of the promps.
   - e.g., the execute prompt should not be $

1. when in the current top mode, what should be valid instrtions
  - why: applications of macros don't work  (PC value is off)
  - we also can't have labels

### ALU Extension or Forward Unit

1. should the LoadI be use the ALU for the operation
   -- or should there be a separate forward unit
      - forward might be cleaner, but the ALU can do the work
      - the wiring is similar to the extended sign


### Command History

1. history is being updated when we enter instructions
   - validate that @instruction are inserted correctly in history
     - the @ sign is removed
     - they are not recorded
     - which ???  (leaning towards the @ sign removed)
1. The ! might be a good thing to execute
   * alias !='fc -s'
   * 

### Top level errors

1. might be nice to add in a post ech to determine if a command was not executed correct
   ```

   $ trap 'echo hello' ERR
   bash-3.2$ !f
   bash: !f: command not found
   hello
   bash-3.2$ !f 2>/dev/null
   hello
   ```


### Debugging mode

1. add a l list to debug mode to proint out current lines.

1. validate an instruction error
  - interactive mode= abort instructions
  - batch mode -> aborts program and dump core


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



#### Testing: May 26
  1. data_segment.s
  1. load_stores.s
  1. loadi.s

  1. set.s
  1. logical.s
  1. shifts.s
  1. mult-div.s
  
  1. loops.s

  1. arithmetic.s
     - need more test exampls
     - sub  when you do a ~t3, the comment should be the original HEX Number
     ```
     (mips) sub $t1, $t2, $t3
     
        | op   | rs  | rt  | rd  | sh  | func |
        |------|-----|-----|-----|-----|------|
        | REG  | $t2 | $t3 | $t1 |    0| sub  |
        |000000|01010|01011|01001|00000|100010|
     
          cin:            1           1;             1;                                         1;
           t2:            6           6; 0x00 00 00 06; 0b0000 0000 0000 0000 0000 0000 0000 0110;
          ~t3:           -9  4294967287; 0xFF FF FF F7; 0b1111 1111 1111 1111 1111 1111 1111 0111; "~ 0x00 00 00 08
               + ----------  ----------- -------------- ------------------------------------------
           t1:           -2  4294967294; 0xFF FF FF FE; 0b1111 1111 1111 1111 1111 1111 1111 1110;
     
        C: 0; V: 0; S: 1; Z: 0
     ```



## Traps Error Handling

1. Error Handling
   - Modify errors to call:  instruction_error "message"
   - Consider the error output
     1. bash: slr: command not found
     1. --> mips: slr: statement undefined

1. Implement Traps


## Kernel
   1. rewind needs to have a lable install called is the instruction
     - "\_exit: \_exit "
     - the label should be placed into kernel space...
   1. .ktext
     - allows us to put things into the kernel space.
     - need a flag so that 
       ```
       if [[ ${IN_KERNEL} == TRUE ]] ; then 
         text_next ==
       ```
       * text_next  <-->  ktext_next
       * data_next  <-->  kdata_next

## Syscalls
  1. Syscall and trap, break?
     - output would be the input and then the output variables




# Notes:

# Bugs

  1. create a list of functions exposed to the user


  1. Implement the functions
     * SE and ZE for sign_extension and zero_extension
  1. double check that the ArithLogI use zE for logical operations



1. 

H
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

   - print encode_address    label
   - print encode_offset     label  [ PC ]   # 
   - print encode_register   $reg

   - print encode_shamt      num


   - print registers [ $t1 ]
   - print register $t1
   - print labels data|text
   - print memory [segment] [address [ ... [address] ]  # restricted to a segment?





## Improvements
1. Consider completting the carry in ... operations..
   (It's for educational purposes..)


1. Consider using digital gates for output symbols
   - & --> U+2227  ? 
   - nor --> U+22BD  (V with a bar)  or down arrow 
   - U+2213      MINUS-OR-PLUS SIGN      ∓


1. ALU Latches
   print_ALU uses the latches, but assign_bits don't
   this is inconsistent



1. add some kernel code that..
   1. prints out the banners
   1. ra should be set to the code that perfroms "exit"

(mips) ascii.index 'hello world!' | base16


1. Should .ascii print out a list of codes before the major emcoding
   ```
   (top) .ascii "hello world!"
         0x68 0x65 0x6c 0x6c 0x6f 0x20 0x77 0x6f 0x72 0x6c 0x64 0x21
   ```
   