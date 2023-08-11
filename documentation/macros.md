# Implementation of Macros

The implementation of macros pose an interesting challange within the context mips_cli.
This document provide our general thinking on how to accomplish this.

The following is an example of a user-defined macro

  ```mips
  .macro average ( %some, %two, %his )
    b:   add  %some, %two, %his
         srl  %some, $s0, 1
         beq  %some, $t1, b
  .end_macro
  ```

Via the prepocessing step, an alias and a function is defined.  These two components are subseqently
used within the assembly process to inline the correct code into the INSTRUCTION and TEXT data-structures

   ```bash
   alias average="prefetch_macro average"

   function macro_average_3 () { 
      local num=$(( LINE_NUM ))

      # issue if there are arguements like %s, %so, %som, %some
      # So the longest of these should be applied first
      # Make sure the $ are escaped within the HERE-Document
      cat <<EOF  | sed -e "s/%some/$1" \
                    -e "s/%two/$2"  \
                    -e "s/%his/$3"  
      b${num}:   add  %some, %two, %his
                 srl  %some, \$s0, 1
                 beq  %some, \$t1, b${num}
      EOF
   }
   ```
Points:
  1. the name of the macro becomes an alias that calles a helper function `prefetch_macro`
  1. the name of the function is defined as the concatenation of
     - the prefix "macro_": to differentiate it from other programming elements
     - the "name" of the macro: to be able to lookup the appropriate function at runtime
     - the number of actual parameters passed to the macro
       * Note macros can be overload, and are differentied by the parameter count.
  1. The macro code needs to be updated to protect "$" to allow proper shell transation
  1. Internal labels are updated with a line number corresponding to the use of the macro
     - this ensures that labels are uniq within the instruction stream
     - per MARS documentation a label is followed by '\_M#' where # will be a unique number for each macro expansion.

Issues:
  1. call of a macro inside of a macro -- which is valid within MARS

The `prefetch_macro` is a bash function that
  1. inserts the appropriate code into the input stream, during the prefetch stage
  1. sets global variables to allow proper execution, during the execution

The code that is inserted into the input stream is as follows

  ```bash
  INSTRUCTION[PC+0]=".macro_start average $s0, $t2, $fp"  TEXT[PC+0]="0{32}"
  INSTRUCTION[PC+1]="b_n: add $s0, $t2, $fp"              TEXT[PC+1]="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  INSTRUCTION[PC+2]="     srl $s0, $s0, $s0"              TEXT[PC+2]="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  INSTRUCTION[PC+2]="     beq $s0, $t1, b_n"              TEXT[PC+3]="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  INSTRUCTION[PC+4]=".macro_end average_3 PC"             TEXT[PC+4]="0{32}"
  ```


### ISSUES:
  1. macros with labels
     - if we use macro_end to modify state or notify the user of something
       - than branch and jumps to code outside the macro causes issues
     - 