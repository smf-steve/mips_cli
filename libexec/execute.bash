#! /bin/bash


## "execute.bash"
## Purpose:
##   - to contain all of the versious functions related to "execution" of an instruction.


# Function list
#   function cycle 
#     - performs the prefetch, fetch, decode, execute, memory, and write-back operations
#     - prefetch is used to support interactive operations
#
#   function prefetch [address]
#     - prefetches the next instruction, 
#       - or all instructions until the give address
#       - an address of {text_end} effecively reads all instructions
#     - loads each instruction into INSTRUCTION[{address}]="{instruction}"
#     - additionaly 
#       - records all labels encounted
#         - into LABELS[line_num]={name}, and
#         - into text_label_{name}={address} or data_label_{labels}={address}
#           > The approach to use:  text_label_{name}={address}
#           > was done due to not having hashed arrays
#       - handles all assembler directives


# The following are the functions that decode and execute 
# the various instructions based upon their syntax.
#   See:  documentation/mips_encoding_reference.pdf
#
#   function execute_ArithLog 
#   function execute_ArithLogI
#   function execute_Shift    
#   function execute_ShiftV   
#   function execute_MoveTo   
#   function execute_MoveFro  
#   function execute_DivMult  
#   function execute_LoadI    
#   function execute_Branch   
#   function execute_BranchZ  
#   function execute_LoadStore
#   function execute_Jump     
#   function execute_JumpR    


_cmd_indent=" "

function native_on () {
  :
}
function pseudo_on () {
  printf "$1 # is psuedo instruction:\n"
  CMD_INDENT="${_cmd_indent}"

}
function pseudo_off () {
  CMD_INDENT="  "
}




# Presume we have a front't that changes things.
# Syntax:
#   line:          [ label:] [instruction  #comment]   
#   instruction:   op one two three four
#   instruction:   op one two (three)              <-- force
#   instruction:   op ( one two three four .... )  <-- force  macro
#      note commas are optional but must be part of the token
#      allow the current engine deal with the immediates and comments

declare -i line_num=0     # This is a global variable
declare -a INSTRUCTION   # List of Instructions index by Address

function cycle () {
  # IR <- Mem[PC] ; Instruction Register, Program Counter 
  # NPC <- PC + 4 ; Next Program Counter

  local label
  local instruction 

  # IR <- Mem[PC] ; Instruction Register, Program Counter 
  #    Determine if the PC is an address or a label
  #    
  #    If it's a label or equal to text_next, we need to read the instruction.
  #    When it is read, it is stored in Text Memory @ text_next
  #    Then we can read it from memory

  # Determine if the PC is an address or a label
  #   If a label, the instruction is in the future. 
  local target_label=
  local PC=$(rval $_pc)

  if [ $PC != "^[[:digit:]]*$" ] ; then 
    target_label=$PC
    PC=$text_next
  fi

  if (( PC == text_next )) ; then 
     # Prefetch the instruction which places the instruction into INSTRUCTION
     PS1="(mips) "
     prefetch ${text_next} ""
  fi
  if (( PC > $text_next )) ; then 
     # We need to search the future for the right instruction.
     PS1="(searching for ${target_label}) "
     prefetch ${text_next} ${target_label}
     PC=$(( text_next - 4 ))
     assign $_pc $PC
  fi

  fetch $_ir "${INSTRUCTION[${PC}]}"       #  Fetech
  instruction="$(remove_label $(rval $_ir) )"


  if (( PC < $text_next )) ; then 
    echo "Ready to execute: \"$(rval $_ir)\""

    # Here we antipate debugger command.
    PS1="(debug) "

    while read -p "$PS1" _command ; do 
      case $_command in 
        step | s ) 
                   break
                   ;;
               *)
      esac
    done
  fi

  # NPC <- PC + 4 ; Next Program Counter
  #   Execute the instruction or the command
  #      If it is an instruction the "npc" will be updated inside the instruction
  #      If it is a command "npc" remains the same

  # assign $_npc $(( $(rval $_pc) + 4 )) 

  eval $instruction 
}

function prefetch () {
    local next_pc="$1"
    local target_label="$2"

    local first
    local rest
    local labels=()

    # If target_label is null, then we just return the next line
    # otherwise, we cantion to get the next line until the label is found

    while true ; do 
      (( line_num ++ ))

      read -e -p "$PS1" first rest
      if [[ $? != 0 ]] ; then
        # EOF found: All has been processed
        return
      fi

      # Continue to read blank lines
      if [[ -z  "${first}" ]] ; then 
         # We have a blank line
         continue;
      fi

      if [[ $(is_label "$first") == "TRUE" ]] ; then 
        label="${first}"
        instruction="${rest}"

        name=$(label_name $label)
        labels+=( "$name" )

        ## Record the label in the database
        LABELS[line_num]=${name}

        if [[ ${target_label} == ${name} ]] ; then
          # We have found the target_label so make it blank
          target_label=""
        fi
      else
        label=""
        instruction="${first} ${rest}"
      fi
 
      if [[ -z "${instruction}" ]] ; then
         continue;
      fi

      break;
    done 

    ## We know have a line is either a directive or is executable
    case "$instruction" in 
       .* )
            for i in ${labels[@]} ; do
              assign_data_label "$i" "${data_next}"
            done
            eval ${instruction}
            prefetch "${next_pc}"  "${target_label}"
            ;;

       "shell "* )
            :  # this is a shell command
               # to be consistent with gdb
            (( line_num -- ))
            eval $instruction
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

    INSTRUCTION[${next_pc}]="${instruction}"

    ## But is it the right one.   
    if [[ -n "${target_label}" ]] ; then 
      # i.e., we have not found the right one, so continue
      prefetch "$((${next_pc} + 4))"  "${target_label}"
    fi

    # We now have the next instruction to be executed queued up.
}




################################################################################



### Syntax
##alias ArithLog
##alias ArithLogI
##alias Shift
##alias ShiftV

##alias MoveX
##alias DivMult

##alias LoadI
##alias LoadStore
##alias Branch
##alias BranchZ
##alias Jump
##alias JumpR
execute_instructions=TRUE
emit_execution_summary=TRUE

function execute_ArithLog() {
  local _name="$1"
  local _op="$2"
  local _rd="$(sed -e 's/,$//' <<< $3)"
  local _rs="$(sed -e 's/,$//' <<< $4)"
  local _rt="$(sed -e 's/,$//' <<< $5)"
  local _shamt="0"

  assign $_npc $(( $(rval $_pc) + 4 )) 
  print_R_encoding $_name $_rs $_rt $_rd $_shamt
  [[ ${execute_instructions} == "TRUE" ]] || return

  local _carry_in=0
  local _rt_prefix=""
  local _value

  case $_op in
      +) reset_cin
         ;;

      -) set_cin
           _op="+"
           _carry_in=1
           _rt_prefix="~"
         ;;

      *) unset_cin
         ;;
  esac

  local _rs_value=$(rval $_rs)
  local _rt_value=${_rt_prefix}$(rval $_rt)
  LATCH_A=($_rs $_rs_value )
  LATCH_B=(${_rt_prefix}$_rt ${_rt_prefix}$_rt_value ) 

  case $_name in
     slt*u) # Use 32-bits as unsigned
         _rs_value=$(( _rs_value & 0xFFFFFFFF ))
         _rt_value=$(( _rt_value & 0xFFFFFFFF ))
         ;;
  esac

  case "$_op" in
    "~|")  _value=$(( ~ ( _rs_value | _rt_value ) ))
           ;;
       *)  _value=$(( ( _rs_value $_op _rt_value ) + _carry_in ))
           ;;
  esac

  alu_assign $_rd $_value $_rs_value $_rt_value
  print_ALU_state "$_op" $_rd
  unset_cin
}

function execute_ArithLogI () {
  local _name="$1"
  local _op="$2"
  local _rt="$(sed -e 's/,$//' <<< $3)"
  local _rs="$(sed -e 's/,$//' <<< $4)"
  local _text="$5"
  local _imm=$(read_immediate "$_text")
  local _literal=$(sign_extension "$_imm")
  local _value

  assign $_npc $(( $(rval $_pc) + 4 )) 
  print_I_encoding $_name $_rs $_rt $_imm
  [[ ${execute_instructions} == "TRUE" ]] || return

  if [[ $_op == "+" ]] ; then 
    reset_cin
  fi

  local _rs_value=$(rval $_rs)
  LATCH_A=( $_rs $_rs_value )
  LATCH_B=( imm ${_literal} "$_text" )

  _value=$(( _rs_value $_op _literal ))

  alu_assign $_rt $_value $_rs_value $_literal
  print_ALU_state "$_op" $_rt
  unset_cin
}

function execute_Shift () {
  # Effectively the syntax of a ArithLogI
  # but with a R format
  local _name="$1"
  local _op="$2"
  local _func_op="$(sed -e 's/>>>/>>/' <<< $_op)"
  local _rd="$(sed -e 's/,$//' <<< $3)"
  local _rt="$(sed -e 's/,$//' <<< $4)"
  local _text="$5"
  local _shamt=$(read_shamt "$_text")
  local _value

  assign $_npc $(( $(rval $_pc) + 4 )) 
  print_R_encoding $_name "0" $_rt $_rd $_shamt
  [[ ${execute_instructions} == "TRUE" ]] || return

  local _rt_value=$(rval $_rt)
  LATCH_A=( $_rt $_rt_value )
  LATCH_B=( imm ${_shamt} "$_text" )

  if [[ $_op != ">>" ]] ; then
    # We are doing srl, we need to clear
    # the top most bits
    _rt_value=$(( _rt_value & 0xFFFFFFFF ))
  fi
  _value=$(( _rt_value $_func_op _shamt ))
  if (( _value > max_word )) ; then
    # we need to drop off the shifted bits
    _value=$(( _value & 0xFFFFFFFF ))
  fi

  alu_assign $_rd $_value $_rt_value $_shamt 
  print_ALU_state "$_op" $_rd
}

function execute_ShiftV () {
  local _name="$1"
  local _op="$2"
  local _func_op="$(sed -e 's/>>>/>>/' <<< $_op)"
  local _rd="$(sed -e 's/,$//' <<< $3)"
  local _rt="$(sed -e 's/,$//' <<< $4)"
  local _rs="$(sed -e 's/,$//' <<< $5)"

  assign $_npc $(( $(rval $_pc) + 4 )) 
  print_R_encoding $_name "$_rs" $_rt $_rd "0"
  [[ ${execute_instructions} == "TRUE" ]] || return

  local _rt_value=$(rval $_rt)
  local _rs_value=$(rval $_rs)

  if (( $_rs_value >= 32 || $_rs_value < 0 )) ; then
    _msg="Notice: the value of \$$(name $_rs) is not in the range 0..31"
    instruction_warning "$_msg"
  fi

  LATCH_A=( $_rt $_rt_value )
  LATCH_B=( $_rs $_rs_value )

  if [[ $_op != ">>" ]] ; then
    # We are doing srlv, we need to clear
    # the top most bits
    _rt_value=$(( _rt_value & 0xFFFFFFFF ))
  fi
  _value=$(( _rt_value $_func_op _rs_value ))
  if (( _value > max_word  || _value < - max_word )) ; then
    # we need to drop off the shifted bits
    _value=$(( _value & 0xFFFFFFFF ))
  fi

  alu_assign $_rd $_value $_rt_value $_rs_value 
  print_ALU_state "$_op" $_rd
}


function execute_MoveTo ()  {
	# Example: mthi move _hi
  local _name="$1"
  local _op="$2"
  local _dst="$(sed -e 's/,$//' <<< $3)"
  local _src="$4"

  assign $_npc $(( $(rval $_pc) + 4 )) 
  case $_name in
     mt*)  print_R_encoding $_name $_src "0" "0" "0"
           ;;
     mf*)  print_R_encoding $_name "0" "0" $_dst "0"
           ;;
  esac

  [[ ${execute_instructions} == "TRUE" ]] || return

  LATCH_A=($_src $(rval $_src) )
  LATCH_B=()

  assign "$_dst" "$(rval $_src)"
  print_ALU_state "$_op" $_dst
}

function execute_MoveFrom() {
  execute_MoveTo $1 $2 $4 $3
}

function execute_DivMult () {
  local _name="$1"
  local _op="$2"
  local _rs="$(sed -e 's/,$//' <<< $3)"
  local _rt="$4"

  assign $_npc $(( $(rval $_pc) + 4 )) 
  print_R_encoding $_name $_rs $_rt "0" "0"
  [[ ${execute_instructions} == "TRUE" ]] || return


  local _rs_value=$(rval $_rs)
  local _rt_value=$(rval $_rt)

  case $_name in
     *u) # Use 32-bits as unsigned
         _rs_value=$(( _rs_value & 0xFFFFFFFF ))
         _rt_value=$(( _rt_value & 0xFFFFFFFF ))
         ;;
  esac

  LATCH_A=( $_rs $_rs_value )
  LATCH_B=( $_rt $_rt_value )

  ## execute
  if [[ $_op == "*" ]] ; then 
    local _value="$(( ${LATCH_A[1]} * ${LATCH_B[1]} ))"
    assign $_lo $((  _value & 0xFFFFFFFF ))
    assign $_hi $(( (_value >> 32) & 0xFFFFFFFF ))
  else
    assign $_lo $(( ${LATCH_A[1]} / ${LATCH_B[1]} )) 
    assign $_hi $(( ${LATCH_A[1]} % ${LATCH_B[1]} )) 
  fi
  print_ALU_state "$_op" $_hi $_lo
}


# Syntax: name rt imm
function execute_LoadI () {
  # Usage: name -- rt, im
  # Herre the immediate is a word...??
  echo "Bug in this code"

  local _name="$1"
  local _op="$2"
  local _rt="$(sed -e 's/,$//' <<< $3)"
  local _text="$4"
  local _imm=$(read_immediate "$_text")
  local _literal=$(sign_extension "$_imm")
  local _value

  assign $_npc $(( $(rval $_pc) + 4 )) 
  print_I_encoding $_name $zero $_rt $_imm $_text
  [[ ${execute_instructions} == "TRUE" ]] || return

  # Determine value 
  case $_name in 

    lui|lhi)
         _value=$(( $_imm << 16 ))
         ;;
    llo) _value=$(( $_imm ))
         ;;
  esac

  LATCH_A=()
  LATCH_B=( imm ${_literal} "$_text" )

  alu_assign "$_rt" "$_value"
  print_ALU_state "$_op" $_rt
}

function execute_Branch () {
  local _name="$1"
  local _op="$2"
  local _rs="$(sed -e 's/,$//' <<< $3)"
  local _rt="$(sed -e 's/,$//' <<< $4)"
  local _label="$5"
  
  local _imm=$(encode_offset $_label)

  ## Print the Encoding
  {
    print_I_encoding $_name $_rs $_rt $_imm $_label

    emit_p=${emit_encodings}
    emit_encodings=FALSE

    # assign $_npc $(( $(rval $_pc) + 4 ))   -- perform by execute_ArithLog
    execute_ArithLog "sub" "-" $zero $_rs $zero 
    emit_encodings=$emit_p

  }
  [[ ${execute_instructions} == "TRUE" ]] || return

  local _current=${REGISTER[$_pc]}
  local _addr=$(lookup_text_label $_label)

  case "$_name" in 
    beq) if [[ ${STATUS_BITS[$_z_bit]} == "1" ]] ; then
           REGISTER[$_pc]=$_addr
         else
           :
         fi
         ;;
    bne) if [[ ${STATUS_BITS[$_z_bit]} == "0" ]] ; then
           REGISTER[$_pc]=$_addr
         else
           :
         fi
         ;;
  esac
  print_PC_update "mux" ${STATUS_BITS[$_z_bit]} $_current  $_addr $_label
  echo "Not Implemented"

}


function execute_BranchZ () {
  local _name="$1"
  local _op="$2"
  local _rs="$(sed -e 's/,$//' <<< $3)"
  local _label="$4"

  ## Print the Encoding
  {
    print_I_encoding $_name $_rs $_rt $_imm $_label

    emit_p=${emit_encodings}
    emit_encodings=FALSE

    # assign $_npc $(( $(rval $_pc) + 4 ))    # Performed by execute_ArithLog
    execute_ArithLog "add" "-" $_zero $_rs $_zero 
    emit_encodings=$emit_p
  }
  [[ ${execute_instructions} == "TRUE" ]] || return

  local _current=${REGISTER[$_pc]}
  local _addr=$(lookup_text_label $_label)

  case "$_name" in 
    bgtz) if [[ ${STATUS_BITS[$_s_bit]} == 0 && ${STATUS_BITS[$_z_bit]} == 0 ]] ; then 
             # result is positive, hence '$_rs > 0'
             REGISTER[$_pc]=$_addr
          else
            :
          fi
          ;;
    blez) if [[ ${STATUS_BITS[$_s_bit]} == 1 || ${STATUS_BITS[$_z_bit]} == 1 ]] ; then 
             # result is positive, hence '$_rs <= 0'
             REGISTER[$_pc]=$_addr
          else
            :
          fi
          ;;
  esac

  print_PC_update "mux" ${STATUS_BITS[$_z_bit]} $_current  $_addr $_label
  echo "Not Implemented"

}




# Syntax: name rt imm(rs)
#    Note that this function can't follow the appropriate syntax
#    As such we need to have a parser call this routine
#    Here we presume the input will followin the following
#    LoadStore name -- rt rs imm
function execute_LoadStore () {
  # Usage:  name -- rt imm (rs)
  local _name="$1"
  local _op="$2"
  local _rt="$(sed -e 's/,$//' <<< $3)"
  local _rs="$(sed -e 's/,$//' <<< $4)"
  local _text="$5"
  local _imm=$(read_immediate "$_text")
  local _literal=$(sign_extension "$_imm")
  local _value

  ## Print the Encoding
  { 
    print_I_encoding $_name $_rs $_rt $_imm

    emit_p=${emit_encodings}
    emit_encodings=FALSE

    # assign $_npc $(( $(rval $_pc) + 4 ))    # Performed by execute_ArithLogI
    execute_ArithLogI "addi" "+" $_mar $_rs $_imm $_text
    emit_encodings=$emit_p
  }
  [[ ${execute_instructions} == "TRUE" ]] || return


   # Determine size of the operation
   case $_name in 
      *b*) _size=1
           ;;
      *h*) _size=2
           ;;
      *)   _size=4
           ;;
   esac

   # Perform the Memory operation
   case "$_name" in
      l*)
          data_memory_read $_size
          _rt_value=$(rval $_mbr)

          case "$_name" in 
            *u) ;;
            *)  (( _size == 2 ))  &&  _rt_value=$(sign_extension "$_rt_value")
                (( _size == 1 ))  &&  _rt_value=$(sign_extension_byte "$_rt_value")
                ;;
          esac     

          alu_assign $_rt $_rt_value   # Operation is being run through the ALU
          ;;
      s*)
          _rt_value=$(rval $_rt)

          alu_assign $_mbr $_rt_value
          data_memory_write $_size
          ;;
   esac
   print_WB_stage "$_name" $_rt $_size

}


function execute_Jump () {
  # Usage:  name -- _label
  local _name="$1"
  local _op="$2"
  local _label="$(sed -e 's/,$//' <<< $3)"

  assign $_npc $(( $(rval $_pc) + 4 )) 
  print_J_encoding $_name $_label
  [[ ${execute_instructions} == "TRUE" ]] || return

  case $_name in 
    jal) 
         assign $ra $(( REGISTER[$_pc]+4 ))     # Operation is NOT being run through the ALU
         # Note that the [not the ALU] writeback stage needs to show pc --> ra
        ;;
  esac
  assign $_npc $(lookup_text_label $_label)
  echo NOT IMPLMENTED
}



function execute_JumpR () {
  # Usage:  name -- rs   # R-format
  local _name="$1"
  local _op="$2"
  local _rs="$(sed -e 's/,$//' <<< $3)"

  ## encode_R_instruction $_name $_rs "0" "0" "0"
  ## print_R_encoding $_name $_rs "0" "0" "0"
  [[ ${execute_instructions} == "TRUE" ]] || return

  case $_name in 
    jalr) 
          assign $ra $(( $(rval $_pc) + 4 ))  # Operation is NOT being run through the ALU
          ;;
  esac

  assign $_npc $(lookup_text_label $_label)
  echo NOT IMPLMENTED
}
