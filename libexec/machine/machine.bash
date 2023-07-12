#! /bin/bash

source ${MIPS_CLI_HOME}/libexec/machine/registers.bash
source ${MIPS_CLI_HOME}/libexec/machine/encodings.bash
source ${MIPS_CLI_HOME}/libexec/machine/memory.bash

# CONSTANTS
min_shamt=0
max_shamt=$(( 2 ** 5 ))

max_immediate_unsigned=$(( 2 ** 16 - 1))
min_immediate=$(( - 2 ** 15  ))
max_immediate=$(( - min_immediate - 1 ))

max_word_unsigned=$(( 2 ** 32 - 1))
min_word=$(( - 2 ** 31  ))
max_word=$(( - min_word - 1 ))

max_dword_unsigned=$(( 2 ** 64 - 1))
min_dword=$(( - 2 ** 63 ))
max_dword=$(( - max_dword -1  ))


declare -a LATCH_A=()   # whence registers, value
declare -a LATCH_B=()   # whence register/imm, value, text

declare -i cin 
 alias unset_cin="cin=-1"     # unset to prevent printing
 alias set_cin="cin=1"        # set to 1 for subraction
 alias reset_cin="cin=0"      # set to 0 for addition
 unset_cin

declare -r _c_bit=0 ;  STATUS_BITS[$_c_bit]="0" 
declare -r _v_bit=1 ;  STATUS_BITS[$_v_bit]="0" 
declare -r _s_bit=2 ;  STATUS_BITS[$_s_bit]="0" 
declare -r _z_bit=3 ;  STATUS_BITS[$_z_bit]="0" 


function reset_trap_on() {
  trap_C="FALSE"
  trap_V="FALSE"
  trap_S="FALSE"
  trap_V="FALSE"
}

alias trap_on_C="trap_C=TRUE"
alias trap_on_V="trap_V=TRUE"
alias trap_on_S="trap_S=TRUE"
alias trap_on_Z="trap_Z=TRUE"

alias C_trap=":"
alias S_trap=":"
alias Z_trap=":"
function V_trap () {
  if [[ "${trap_V}" == "TRUE" ]] ; then 
    # trap 12
    echo "Trap due to overflow"
  fi
}

function reset_status_bits() {
  STATUS_BITS[$_c_bit]=0
  STATUS_BITS[$_v_bit]=0
  STATUS_BITS[$_s_bit]=0
  STATUS_BITS[$_z_bit]=0
}

##  In Bash, our values are stored using 64-bit 2's complement encoding
##  Hence, determining the status bits for values within the range -2^31 .. 2^31-1
##  is defined by the following calculations.
#
#  Sign Calculation: (regardless of the size of representation)
#
#  Zero Calculation: (regardless of the size of representation)
#
#  Overflow Calculations: (regardless of size of representation)
#    - Overflow is true if..  the sign of final value is flipped  
#
#  Carry Calculations:  Using unsigned representation of 32-bit values
#    - Carry is true if..  rs + rt > max_unsigned_word 
#      * i.e., mask the values of rs and rt first to get the 32-bit representation

function assign_status_bits() {
  local _value="$1"
  local _rs_value="$2"
  local _rt_value="$3"

  STATUS_BITS[$_s_bit]=$(( _value < 0 ))
  STATUS_BITS[$_z_bit]=$(( _value == 0 ))

  # Technically, the Carry and oVerflow bit is only relevant if it is an Add operation
  # But since the class shows that the ALU computes all values always
  # These bits are defined.
  { 
    local _both_pos=$(( _rs_value >= 0 && _rt_value >= 0 ))
    local _both_neg=$(( _rs_value <  0 && _rt_value  < 0 ))
  
    local flipped_to_neg=$(( _value < 0 && _both_pos ))
    local flipped_to_pos=$(( _value > 0 && _both_neg ))
  
    STATUS_BITS[$_v_bit]=$(( flipped_to_neg | flipped_to_pos ))
  }

  (( _rs_value = _rs_value & 0xFFFFFFFF ))
  (( _rt_value = _rt_value & 0xFFFFFFFF ))
  STATUS_BITS[$_c_bit]=$(( (_rs_value + _rt_value ) > max_word_unsigned ? 1 : 0))

}

function print_status_bits() {
  printf "\tC: %c;\tV: %c;\tS: %c;\tZ: %c\n\n" \
      ${STATUS_BITS[$_c_bit]} \
      ${STATUS_BITS[$_v_bit]} \
      ${STATUS_BITS[$_s_bit]} \
      ${STATUS_BITS[$_z_bit]}
}

function trap_on_status_bits () {
  # If a trap_on_<bit> is set, echo out a message
  [[ ${STATUS_BITS[$_c_bit]} == "1" ]]  && C_trap
  [[ ${STATUS_BITS[$_v_bit]} == "1" ]]  && V_trap
  [[ ${STATUS_BITS[$_s_bit]} == "1" ]]  && S_trap
  [[ ${STATUS_BITS[$_z_bit]} == "1" ]]  && Z_trap
  reset_trap_on
}

function print_ALU_state() {
  # Print values on the two input latches with the op and output register/s
  local _op="$1"
  local _dst1="$2"
  local _dst2="$3"

  [[ "${EMIT_EXECUTION_SUMMARY}" == "TRUE" ]] || return

  print_cin $cin  $(( LATCH_A[1] ^ LATCH_B[1] ^  $(rval $_dst1) ))
  [[ $LATCH_A != "" ]]  &&  print_value "${LATCH_A[@]}"
  [[ $LATCH_B != "" ]]  &&  print_value "${LATCH_B[@]}"

  print_op "$_op"

  print_value $_dst1
  [[ $_dst2 != "" ]]  && print_value $_dst2
  echo 
  print_status_bits
  trap_on_status_bits
  echo
}

function print_immediate() {
  local _text="$1"
  local _value=$(parse_immediate "$_text")

  print_value imm $_value "$_text"
}


# the value in the register is a string, which is one of the following
# -5
# ~5
# X where X=$(( 0xFF FF FF FB ))
#
# output: 
#   simple: -5, or ~5 in the text area
#   signed: $(signed_extention $(( value )) )
#   unsigned:  $(signed_contraction $((value )) )

function print_value() {
  # if the input is one value, 
  #   then print it as a register
  #   otherwise print as an immediate
  local _register="$1"
  local _value="$2"
  local _text="$3"
  local _name
  local _rval
  local _prefix

  _prefix=${_register:0:1}
  if [[ $_prefix == '~' ]] ; then
   _register=${_register:1}
  else
   _prefix=""
  fi

  case ${#} in
      1) # print the current contents of the register
         _name=${_prefix}$(name ${_register})
         _rval=$(( $(rval ${_register}) ))
         ;;
      2) # print the old value of the register
         _name=${_prefix}$(name ${_register})
         _rval=$(( ${_value} ))
         ;;
      3) # print as is since _text_ was provided
         _name="$_register"    
         _rval=$(( ${_value} ))
         ;;
  esac

  # What does the following -- before the print_value_i do?
  # if [[ -z "$_text" ]] ; then
  #   _prefix=${_rval:0:1}
  # fi
  # if [[ $_prefix == '~' || $_prefix == '-' ]] ; then
  #   _text=        #  "~ 0x$(to_hex 8 $(rval $_register))"
  #   _register=${_register:1}

  # else
  #   _prefix=""
  # fi
  if [[ -z "$_text" && ${_value:0:1} == "~"  ]] ; then
    _text=$_value
  fi
  print_value_i "$_name" "$_rval" "$_text"
}

function print_value_i () {
  local _name="$1"
  local _rval="$2"
  local _text="$3"

  if [[ -z "$_rval" ]] ; then 
    # its an _unresolved_ value
    local _dec="?"
    local _unsigned="?"
    local _hex="????????"
    local _bin="????????????????????????????????"
  else
    local _dec=${_rval}
    local _unsigned=$(( _rval & 0xFFFFFFFF ))
    local _hex=$(base16_digits 8 $_unsigned )
    local _bin=$(base2_digits 32 $_unsigned )
  fi
  printf "   %6s:  %11s %11s; 0x%s; 0b%s;"  \
        "${_name}" "${_dec}" "${_unsigned}" "$(group_4_2 ${_hex})" "$(group_8_4 ${_bin})"

  if [[ "$_text" != "" ]] ; then
    printf " \"%s\"" "${_text}"
  fi
  printf "\n"
}


function print_op() {
   local _op="$1"
      
   printf "   %9s   --------  ----------- -------------- ------------------------------------------\n" \
          "${_op}"      
}


function print_cin() {
   local cin="$1"
   local carry_row="$2"

    local _hex=$(base16_digits 8 ${carry_row} )
    local _bin=$(base2_digits 32 ${carry_row} )

   [[ $cin == -1 ]]  && return

   printf "     %5s  %11s %11s; %13s;   %s; \"%s\"\n" \
             "cin:" "${cin}" "${cin}" "${cin}" "$(group_8_4 ${_bin})" "cin=${cin}"
}

function print_Z() {
   local value=${STATUS_BITS[$_z_bit]}

   printf "     %5s         %4s        %4s;             %c;                                        %c;\n" \
             "Z  :" "${value}" "${value}" "${value}" "${value}"
}


#Maybe rename to:
# print_mem_WB_stage
# print_pc_WB_stage  


function print_NPCWB_stage () {
  local z_bit="$1"
  local _current="$2"
  local _addr="$3"
  local _label="$4"

  [[ "${EMIT_EXECUTION_SUMMARY}" == "TRUE" ]] || return

  print_value_i "#0" "$_current" "npc"
  print_value_i "#1" "$_addr" "$_label"
  print_op "mux (Z=${z_bit})"

  # Now handle the special case where the address in NPC is an unresolved reference
  local _next=$(rval $_npc)
  if [[ ${_next:0:1} =~ [[:alpha:]]   ]] ; then 
    print_value_i "npc" "" "$_next"
  else
    print_value_i "npc" "$_next"  
  fi
  echo
}


#      #0:           0           0; 0x00 00 00 00; 0b0000 0000 0000 0000 0000 0000 0000 0000; "pc"
#      #1:           5           5; 0x00 00 00 05; 0b0000 0000 0000 0000 0000 0000 0000 0101; "_address"
#      Z:            0           0;             0;                                         0;
#       mux ----------  ----------- -------------- ------------------------------------------
#     npc:           5           5; 0x00 00 00 05; 0b0000 0000 0000 0000 0000 0000 0000 0101;



alias print_WB_stage="print_MEMWB_stage"
function print_MEMWB_stage() {
  # The WB stage is responsible for 
  #   1. summarizing the operation that was perfromed via a load store
  #      -- print the values in the last two latches
  #   1. summaryizig the operation that was performed via a jal and jalr operation
  #      - print the values of the old pc --> $ra


  # Print values on the two input latches with the op and output register/s

  local _name="$1"
  local _register="$2"
  local _size="$3"


  [[ "${EMIT_EXECUTION_SUMMARY}" == "TRUE" ]] || return
  case "$_name" in
    l*)
       print_mem_value "$(name $_mbr)" $(rval $_mbr) $_size
       print_op "$_name"
       print_mem_value "$(name $_register)" $(rval $_register)
       ;;
    s*)
       print_mem_value "$(name $_register)" $(rval $_register)
       print_op "$_name"
       print_mem_value "$(name $_mbr)" $(rval $_mbr) $_size
       ;;
  esac
  echo 
}


# how does print_mem_value differ from print_value_i
#  size versus text for one...

# rename: print_wb_value
function print_mem_value () {
  local _name="$1"
  local _rval="$2"
  local _size="$3"   # The number of raw bits trnansfered

  [[ $_size == "" ]] && _size=4

  local _dec=${_rval}
  local _unsigned=$(( _rval & 0xFFFFFFFF ))
  local _hex=$(hex_digits $(( _size * 2 )) $_unsigned )

  local _bin=$(bin_digits "${_hex}")

  printf "   %6s:  %11d %11d; 0x%11s; 0b%39s;"  \
        "${_name}" "${_dec}" "${_unsigned}" "$(group_4_2 ${_hex})" "$(group_8_4 ${_bin})"
  printf "\n"
}

#     load/read:  lb
#       LATCH_IN        xxxx xxxx xxxx s???      MBR
#                 $name -------- ------   ------     
#       Latch_out       ssss ssss ssss s???      rt
#
#     store/write: sb
#       LATCH_IN        ???? ???? ???? ????     rt
#                 $name -------- ------   ------     
#       Latch_out                      ????     MBR


