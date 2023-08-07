#! /bin/bash

## "execute.bash"
## Purpose:
##   - to contain all of the various functions related to "execution" of an instruction.

# Function list
#   cycle
#     - using the current value of PC,
#       - fetch, decode, execute, memory, and write-back operations
#     - uses prefetch if the optional address has not been read yet
#       - this allows for support of interactive operations
#
#   prefetch next_pc [label]
#     - prefetches the next instruction, 
#       - or all instructions until the we reach the provided label
#       - a defined and unresolved label --- effectively reads all instructions
#     - loads each instruction into INSTRUCTION[{next_pc}]="{instruction}"
#     - additionally 
#       - records all labels encountered
#         - into LABELS[{LINE_NUM}]={name}, and
#         - into text_label_{name}={address} or data_label_{labels}={address}
#           > The approach to use:  text_label_{name}={address}
#           > was done due to not having hashed arrays
#       - handles all assembler directives


# We presume we have a MIPS front-end that updates various instructions to use
#    the  secondary syntax
#
# Syntax:
#   line:          [ label:] [instruction  #comment]   
#   instruction:   op one two three four
#   instruction:   op one two (three)              -->  op one two three
#   instruction:   op ( one two three four ... )  -->  op one two ... )<-- force  macro
#      note commas are optional but must be part of the token
#      allows the current engine deal with the immediate and comments

declare -i LINE_NUM=0    # This is a global variable
declare -a INSTRUCTION   # List of Instructions index by Address

function cycle () {

  # IR <- Mem[PC]   

  #    The potential PC is stored in 'local {potential_pc}'
  #  
  #    1. Determine if the value of PC is an address or a label
  #       If it is an address, set PC to be text_end
  #    1. Based upon the value of PC
  #       1. PC <  text_next  -- no prefetch is needed
  #       1. PC == text_next  -- 1 prefetch is needed
  #       1. PC >  text_next  -- N prefetches are needed
  #            i.e., its an unresolved label)
  #
  #       - if it is a label then
  #         * the associated instruction has not read in yet
  #       - hence we need to prefetch a bunch of instructions
  #    
  #    If it's a label or equal to text_next, we need to read the instruction.
  #    When it is read, it is stored in Text Memory @ text_next
  #    Then we can read it from memory

  local next_pc=${TEXT_NEXT}  #  This is the next available address
                              #  Is this just an alias for readability
  local target_label
  
  local potential_pc=$(rval $_pc)  

  # If the PC is a label, so search for that label
  if [[ ${potential_pc:0:1} =~ [[:alpha:]] ]] ; then 
    target_label=${potential_pc}
    potential_pc=${TEXT_END}   
  fi

  #################################################
  #  preload   -- loads a number of instructions into memory
  #  interactive-load:

  #  PC == text_next -- 1 prefetch is needed
  if (( potential_pc == next_pc )) ; then 
     # The next instruction has not been read into memory. So read it!
     PS1="(mips) "
     prefetch "${next_pc}" ""
     if [[ $? != 0 ]] ; then 
       return 1
     fi
  fi

  #  PC > text_next -- N prefetches are needed
  #  If there is a target label, then it has not been resolved... N prefetches
  if [[ -n "${target_label}" ]] ; then        ## (( potential_pc > next_pc )) 
     # We need to search the future for the right instruction.
     PS1="(prefetch: ${target_label}) "
     prefetch "${next_pc}" "${target_label}"
     if [[ $? != 0 ]] ; then 
       return 1
     fi
     potential_pc=$(( next_pc - 4 ))
  fi

  assign $_pc $potential_pc
  # end: interactive-load
  #################################################


  fetch #  Fetch the next instruction into the _ir register
  local instruction="$(remove_label $(rval $_ir) )"

  # NPC <- PC + 4 ; Next Program Counter
  #   Execute the instruction or the command
  #      If it is an instruction the "npc" will be updated inside the instruction
  #      If it is a command "npc" remains the same
  assign $_npc $(( $(rval $_pc) + 4 )) 


  ###############################################
  ## IF WE ARE IN BATCH MODE... THEN SKIP THIS CONDITION
  ## IF DEBUG MODE THEN CHECK THE FOLLOWING LOOP

  if [[ DEBUG_MODE == "TRUE" ]] ; then
  {  
     if (( $(rval _pc) < next_pc )) ; then 
       echo "Ready to execute: \"$(rval $_ir)\""

       # Here we anticipate debugger command.
       while true ; do
         read -p "(debug) " _command
         if [[ $? != 0 ]] ; then 
            return 1
         fi
         case $_command in 
           step | s ) 
                      break
                      ;;
                  *)
                      echo "Only s[tep] is implemented in DEBUG mode"
         esac
       done
     fi
  }
  fi
  ###############################################



  # Here is where we might want to change the syntax of the LoadStore instructions
  #   from: "[label:]  op rt imm ( rs )"
  #   to: "[label:]  op rt rs imm"

  # Echo the instruction if the user did not type it in.
  if [[ ${INTERACTIVE} == "TRUE"  && ${MACRO_EXECUTION} == "TRUE" ]] ; then 
     echo "  --> $(rval $_ir)"
  fi
  [[ ${INTERACTIVE} == "TRUE" ]] || echo "\$ $(rval $_ir)"


  history -s "$(rval $_ir)"   

  ## IF INTERACTIVE MODE, SHOULD I SLEEP SOME AMOUNT OF TIME.

  # If the instruction is a MIPS instruction, it
  #   2. performs the Decode step:
  #   3. performs the Execute step:
  #   4. performs the WB step 
  eval $instruction 

  assign $_pc $(rval $_npc)
  # Issue arises here if the value of pc is unsolved


  return 0;
}

function prefetch () {
    local next_pc="$1"
    local target_label="$2"

    local first
    local rest
    local labels=()

    # if next_pc is null, then we place the instruction at the end of the instruction stream
    if [[ "${next_pc}" ]] ; then
      next_pc=${TEXT_NEXT}
    fi  
    # If target_label is null, then we just return the next line
    # otherwise, we continue to get the next line until the label is found

    while true ; do 
      (( LINE_NUM ++ ))

      # -p "(prefetch) "
      read -e  -p "$PS1" first rest

      [[ $? == 0 ]] || return 1           # Test for EOF
      [[ -n  "${first}" ]] ||  continue   # Skip over blank lines

      if [[ $(is_label "$first") == "TRUE" ]] ; then 
        label="${first}"
        instruction="${rest}"

        name=$(label_name $label)
        labels+=( "$name" )

        ## Record the label in the database
        LABELS[${LINE_NUM}]=${name}

        if [[ ${target_label} == ${name} ]] ; then
          # We have found the target_label so make it blank
          target_label=""
        fi
      else
        label=""
        instruction="${first} ${rest}"
      fi
 
      [[ -z "${instruction}" ]]  || break   # Test for found instruction
    done 

    ## We know have a line is either a directive or is executable
    case "$instruction" in 
       .* )

            # For allocation directives, we have a bug since DATA_NEXT might move if
            # we have to align 
            eval ${instruction}
            if [[ -z "${labels}" ]] ; then 
               history -s "$instruction"
            else
               history -s "${labels[0]}: $instruction"
            fi
            for i in ${labels[@]} ; do
              # labels only make sense on data allocation 
              # if the instruction is not an allocation, it can be deemed a bug
              assign_data_label "$i" "${DATA_LAST}"
            done
            prefetch "${next_pc}" "${target_label}"
            ;;

       "shell "* )
            :  # this is a shell command
               # to be consistent with gdb
               # goal here is NOT to record this instruction in the final code
            (( LINE_NUM -- ))
            #CURRENT=$(LVAL $_PC)
            eval $instruction
            #ASSIGN $_PC $_current
            
            prefetch "${next_pc}"  "${target_label}"
            ;;
        * ) 
            # 
            for i in ${labels[@]} ; do
              assign_text_label "$i" "${next_pc}"
            done
            ;;
    esac

    ## At this point, we should have a legal MIPS instruction
    ## Record the instruction
    if [[ $(is_label "$label" ) == TRUE ]] ; then 
      instruction="$label $instruction"
    fi

    # Record the instruction, and advance the location of TEXT_NEXT
    INSTRUCTION[${next_pc}]="${instruction}"
    TEXT_LAST=${next_pc}
    (( next_pc = next_pc + 4))
    TEXT_NEXT=${next_pc}

    ## Test to see if the Instruction is a MACRO
    if [[ $INTERACTIVE == "FALSE" ]] ; then 
      local type=$(type_of_macro $instruction)
      if [[ ${type} != "FALSE" ]] ; then
         prefetch ${TEXT_NEXT} '!macro_end' < <(expand_macro ${type} $instruction)
      fi
    fi


    ## But is it the right one.   
    if [[ -n "${target_label}" ]] ; then 
      # i.e., we have not found the right one, so continue
      prefetch "${next_pc}" "${target_label}"
    fi

    # The instruction to be executed has been stored in TEXT Memory.
    return 0
}


function fetch () {
  # This is an _ir specific operation.

  # It places a text string into the register
  # Place a text string into the _ir register
  # Because text is going into the regisrter, we can't use the function "assign"

  REGISTER[$_ir]="${INSTRUCTION[ $(rval $_pc) ]}"
}

