
# Bugs

1. Branch instructions -- need to validate the calculation of the address
  - is it off of npc or pc
  - 

1. beq instructions 
   1. the seem to be working but going into an infinite loop
      - it should be going into debug mode
      ```
      a: nop
         beq $zero, $zero, a
      ```
      - forward loop also goes into a problem
      ```
      b:      beq $t1, $t2, c
      c:      nop
      ```
      - It might have something to do with TEXT_NEXT and/or instruction


1. `libexec/cycle.bash:  local original_instruction="$(remove_label $(rval $_ir) )"`
   - this but has been found and fixed
   - valid and commit

1. load causes the history to be corrupted.
   - under step, the last instruction is added to history
   - what should be placed in TEXt and INSTRUCTIONS for a load..
     * shouldn't be load?
   - strange behavior
   - this is due to possible use of a global variable instruction
     1. ```
        bin/mips_cli
        step
        li 
        load examples/macros.s
        ```
      1. ```
         bin/mips_cli
         step
         load examples/macros.s
         ```
      -  the second one goes into an infinite loop
      -- note the value of original and instruction are different... -- key to the bug

1. step ; load examples/macro.s
   -- works fine if typed in verbatum
   -- the prefetch section is executed
   -- the history is off
      - each .macro_stop references the load instruction 
      - this makes some sense, but wrong
   -- text and instructions look fine

1. reimplement offset to be provided with constants...
     -  bne $zero, $zero, 4

1. output prompts are different under
   - load and interactive

1. label  a  garbage
   - perform a check to ensure the value of garbage is in the proper range
   
# ToDo

1. Installation Proceducers
   1. proper call anywhere where files are staged in ~/class/comp122/bin


1. Review INSTRUCTIONS.. 
   1. determine which instructions get put into the insturction loop
   1. such instructions allow PC + 4 is applied

    -- only MIPS instructions should be placed into the INSTRUCTION data structure
       - such instructions should also include the directives
       - hence "macro_begin" -- is executed as a noop and updates the pc
       - blank lines don't get added to the Instructions, 
       - blank lines with comments are implicit nops.


1. Review "Command History", determine what should go into the command history
   * only commands that are typed added to the Command history
   * all directives are added to the command history
   * Hence, individual instructions part of the macro are not added to the history
     -- need to determine how to handle load
     -- it excutes a lot of instructions under the covers
     -- if the last instruction is a comment, it places it in history/etc
     -- Should it be:
        * "load blah"  
          - gets put into the history
          - TEXT and INSTRUCTIONS are added the interal stuff...
        * as such, we need to differentate between MIPS instruction and debugger insturctions



1. data_memory_write  little endian to write
   - validate that we are always in little endian mode...

1. review the sourceing of files.
   -- alias must be define in the right order.

#### Testing: Aug 8
  1. arithmetic.s
     --good

  1. data_segment.s
     - good, but need to revise print-memory for execution step
     - need to echo out the commands, under interactive "load"

  1. load_stores.s
     * under step,
       - the instructions on the end are added to the instruction stream but not executed
       - but with other files, they are executed...

     * individual instructions look good, but need further validation test


  1. loadi.s
     -- good
  1. set.s
     -- good

  1. logical.s
     -- good

  1. shifts.s
     -- status bits are based upon the add operation
     -- under step; load examples/shifts.s
        ```
         $ li $at, 0       # value is to low -- but no error
         Start of pseudo "li" ()
        ```
        the li does ont execute in total?
        history shows it is there as a native instruction

  1. mult-div.s
     -- status bits are wonky
        -- perhaps no status bits should be shown..  since the ALU is not used for MULT
        -- but then the ALU is always used, and C and V should be based upon the add operation
     -- need to deal with div 2
        -- maybe native_div  ... 
        -- because if there is a pseudo/macro it takes precedencs , hence use native_ to overide



  1. macros.s
     -- good
     -- note, no warning on redefining macro
     -- but under step ; load
        * the entire file is not executed.
     -- spaces in input 


  1. loops.s
     - deferred until cli being flushed out


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
      - example, the div_3 macro overrides the div native instruction
        - perhaps  prefetch_macro div -- if returns false
          -- than calls native_div
        - requires an alias for all native instructions

   1. macros that have quoted args
      ```
      (mips) li $t2, "2#101 1111 1111"
      $t2 is assign 2#101 
      ```
      might need a special step to normalize an instruction first
      is this done before the "eval" step in cycle
      but how do I know that it is 

      reexame the output of these..

   1. Macros need to be executed within the cycle component of the machine
      - the list of commands that work at the top-level are
        1. execute label:  batch execute starting at label
        1. debug   label:  debug execute starting at label
        1. step    : step execution via interactive mode
        1. encode  : encode each instruction provided


### load
    ```
    step
    load
    ```
    - you drop out of step mode
    - In INSTURCTION: 
      - the load instruction does not appear  
      - the none mips instructios take up space appears in INSTRUCTIONS, but not TEXT
        - this might be okay... since it is effectively a NOP -- should it be encoded as anop?

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



### Command History / TEXT / INSTRUCTIONS

| name                 | HISTORY | TEXT     | INSTRUCTIONS |
|----------------------|---------|----------| -------------|
| instruction          |  Yes    | Yes      | expanded     |
| macro                |  yes    | expanded | expanded     |
| directive            |  yes    | no       | no           |
| mult-line directive  |  yes    | no       | no           |
| shell * / @*         |  yes    | no       | no           |

1. history is being updated when we enter instructions
   - mips instructions are added to the command history
   - mips macros: the prologue, the individual instructions, and the epilogue are added
   - mips directives are added to the history
   - mulit-line mips directories are not added to the history
   - shell * or @* are not added to the history




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


## Documenations
   1. New directives
      1. Labels: .lab, .label
         - usage .label label [address]
      1. Macros
         - .macro_apply
         - .macro_define  (synmous with .macro )
      1. Pseudo
         - .pseudo .pseudo_define
         - .pseudo_appy
         - .end_pseudo

   1. create a list of functions exposed to the user

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

   1. Implementation of labels
      1. if a set of lines with labels all for the same instruction
         - only the last one, is associated with the instruction in the INSTRUCTION struct
      1. if a label is associated with a macro or pseudo instruciton
         - no label is associated with the expande instruction in the INSTRUCTION struct


   1. with the following  extensions
      - immediates can be use 2# notation
      - labels are within two name space, i.e., the label A can be used both for data and for text
        - can't have self modifing code
      - At most one label can be depicted per line.
        - Labels: blank lines with labels, are stored anyways.


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




--

# Improvements


## Documentation
  1. create a list of functions exposed to the user

## Readability
   ```
   instead of $(( offset = DATA_NEXT % size ))
   let "offset = DATA_NEXT % size"
   ```

   1. output of special registers could be changed from
      - \_mar --> MAR 
      - see print_value_i
      - as straight change to \$(name \$reg)  may not work


## ALU update for the future
  1. consider making the ALU work via just the latches
  1. hence had a Latch C for the ALU
  1. each instruction that uses the alu should pass in a function to be applied
  1.   - this is nessarey because some instructions require more than two values


## Symbols:
   1. Consider using digital gates for output symbols
      - & --> U+2227  ? 
      - nor --> U+22BD  (V with a bar)  or down arrow 
      - U+2213      MINUS-OR-PLUS SIGN      ∓

## Data directives
   1.   implemente value list to data directives


## Error handling
   - determine error messages and how to restart

## Syscalls
   1. Implement syscalls, trap, and break
      - don't go through the kernel in V0.1 -- just perform the operations

## Special2 instructions
   1. consider implementation

## Kernel
   1. .ktext
      - allows us to put things into the kernel space.
      - need a flag so that 
        ```
        if [[ ${IN_KERNEL} == TRUE ]] ; then 
          text_next ==
        ```
        * text_next  <-->  ktext_next
        * data_next  <-->  kdata_next
   1. add some kernel code that..
      - prints out the banners
      - sets ra code that perfroms "exit"

   1. make rewind install a label
      - "\_exit: \_exit "
      - the label should be placed into kernel space...
 

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

   This might be nice
   * alias !='fc -s'
   * 