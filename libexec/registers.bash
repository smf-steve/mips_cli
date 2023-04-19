
# REGISTERS
                      declare -a NAME ; declare -a REGISTER

declare -r zero='0' ;  NAME[$zero]="zero" ; REGISTER[$zero]="";
declare -r at='1'	  ;  NAME[1]="at"	  ; REGISTER[1]="0"
declare -r v0='2'	  ;  NAME[2]="v0"	  ; REGISTER[2]="0"
declare -r v1='3'	  ;  NAME[3]="v1"	  ; REGISTER[3]="0"
declare -r a0='4'	  ;  NAME[4]="a0"	  ; REGISTER[4]="0"
declare -r a1='5'	  ;  NAME[5]="a1"	  ; REGISTER[5]="0"
declare -r a2='6'	  ;  NAME[6]="a2"	  ; REGISTER[6]="0"
declare -r a3='7'	  ;  NAME[7]="a3"	  ; REGISTER[7]="0"
declare -r t0='8'	  ;  NAME[8]="t0"	  ; REGISTER[8]="0"
declare -r t1='9'	  ;  NAME[9]="t1"	  ; REGISTER[9]="0"
declare -r t2='10'	;  NAME[10]="t2"  ; REGISTER[10]="0"
declare -r t3='11'	;  NAME[11]="t3"  ; REGISTER[11]="0"
declare -r t4='12'	;  NAME[12]="t4"  ; REGISTER[12]="0"
declare -r t5='13'	;  NAME[13]="t5"  ; REGISTER[13]="0"
declare -r t6='14'	;  NAME[14]="t6"  ; REGISTER[14]="0"
declare -r t7='15'	;  NAME[15]="t7"  ; REGISTER[15]="0"
declare -r s0='16'	;  NAME[16]="s0"  ; REGISTER[16]="0"
declare -r s1='17'	;  NAME[17]="s1"  ; REGISTER[17]="0"
declare -r s2='18'	;  NAME[18]="s2"  ; REGISTER[18]="0"
declare -r s3='19'	;  NAME[19]="s3"  ; REGISTER[19]="0"
declare -r s4='20'	;  NAME[20]="s4"  ; REGISTER[20]="0"
declare -r s5='21'	;  NAME[21]="s5"  ; REGISTER[21]="0"
declare -r s6='22'	;  NAME[22]="s6"  ; REGISTER[22]="0"
declare -r s7='23'	;  NAME[23]="s7"  ; REGISTER[23]="0"
declare -r t8='24'	;  NAME[24]="t8"  ; REGISTER[24]="0"
declare -r t9='25'	;  NAME[25]="t9"  ; REGISTER[25]="0"
declare -r k0='26'	;  NAME[26]="k0"  ; REGISTER[26]="0"
declare -r k1='27'	;  NAME[27]="k1"  ; REGISTER[27]="0"
declare -r gp='28'	;  NAME[28]="gp"  ; REGISTER[28]="0"
declare -r sp='29'	;  NAME[29]="sp"  ; REGISTER[29]="0"
declare -r fp='30'	;  NAME[30]="fp"  ; REGISTER[30]="0"
declare -r ra='31'	;  NAME[31]="ra"  ; REGISTER[31]="0"
declare -r _pc='32'	;  NAME[32]="pc"  ; REGISTER[32]="0"
declare -r _hi='33'	;  NAME[33]="hi"  ; REGISTER[33]="0"
declare -r _lo='34'	;  NAME[34]="lo"  ; REGISTER[34]="0"

function name() {
   echo ${NAME[$1]}
}
function rval() {
   echo ${REGISTER[$1]}
}

function assign() {
  [[ $1 == 0 ]] ||  REGISTER[$1]="$2"
}

function reset_registers () {
  assign $zero "0"  
  for ((i=1; i<32; i++)) ; do
  	assign $i "0"
  done
  # assign $_pc "0"
  assign $_hi "0"
  assign $_lo "0" 
}

function set_registers () {
  if [[ $# == 0 ]] ; then
     set_registers_random
     return
  fi

  _value=$(read_immediate "$1")
  _value=$(sign_contraction $_value)     # ensure its a number in the right range
  
  assign $zero "0";  
  for ((i=1; i<32; i++)) ; do
   assign $i "$_value"
  done
  # assign $_pc "0"
  assign $_hi "$_value"
  assign $_lo "$_value"
}

function set_registers_random () {
  assign $zero "0";  
  for ((i=1; i<32; i++)) ; do
  	assign $i "$(( $RANDOM % 0xFF << 24 ))"
  done
  # assign $_pc "0"
  assign $_hi "$(( $RANDOM % 0xFF << 24 ))"
  assign $_lo "$(( $RANDOM % 0xFF << 24 ))"
}

function print_registers () {

  for ((i=0; i<32; i++)) ; do
  	print_register $i
  done
  echo
  print_register $_pc
  print_register $_hi
  print_register $_lo

}

function print_register () {
   register="$1"
   
   _prefix=${register:0:1}
   if [[ $_prefix == '~' ]] ; then
     register=${register:1}
   else
     _prefix=""
   fi

   _rval=$(( ${_prefix}$(rval $register) ))
   _name=${_prefix}$(name $register)

   _decimal=$(sign_extension ${_rval})
   _hex=$(to_hex 8 $(sign_contraction $_rval ))
   _binary=$(to_binary "${_hex}")
   
   printf "  %4s:      %11d; 0x%s; 0b%s;\n" "${_name}" "${_decimal}" "${_hex}" "${_binary}"
}

function print_immediate () {
   if [[ $# == 1 ]] ; then
	 _name=$(read_immediate "$1")
	 _text="$1"
   else
     _name="$1"   # the simplified name: +5, ~5
     _text="$2"   # how the text was actually entered
   fi

   
#   _name=${_rval}
#   _decimal=${_value}
   _hex=$(to_hex 8 $(sign_contraction $_value ) )
   _binary=$(to_binary "${_hex}")
   
   printf "   %4s      %11s; 0x%s; 0b%s; \"%s\"\n" "imm:" \
         "${_name}" "${_hex}" "${_binary}" "${_text}"
}

function print_op () {
   _op="$1"
      
   printf "    %2s  %-4s ----------- -------------- ------------------------------------------\n" "" "${_op}"      
}


function print_cin() {
   _bit="$1"
   : ${_bit:-0}

   printf "    %2s               %c              %c                                          %c\n" "cin:" "${_bit}" "${_bit}" "${_bit}"
}

