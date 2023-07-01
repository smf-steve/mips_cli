#! /bin/bash


# mips_cli supports both assembler pseudo instructions and users macro-instructions.
# 
# Essentially, pseudo instructions and user macros are the same.  Pseudo instructions, however,
# can utilize and manipulate information known to the assembler
#   
# In the implementation mips_cli, pseudo instructions and user macros have been unified.  Thus,
# allowing users to reference specific assembler functions within their macros.  Two such 
# functions are: upper and lower.  These two functions return the upper 16-bits and the 
# lower 16-bits of a label.  
#
# The following is the definition of the 'la' pseudo instruction.  The address of the label is only
# known by the assembler, and the assembler breaks the address into two 16-bit quantities.  It then 
# inserts the appropriate MIPS instructions to place the label's address into the 'dst' register.
#
#   .pseudo la %dst, %label
#      lui $at, $(upper %label)
#      ori %dst, $at, $(lower %label)
#   .end_pseudo
#
# Here we have introduced the .pseudo directive to declare a pseudo instruction. This approach
# allows us to leverage the implementation of user macros for pseudo instructions, while 
# differentiating between the type of of instruction (assembler versus user provided).
#
# Also notice that via bash syntax, you can invoke any function/command to be executed to generate
# the value of a operand.  

# Functions
#   macro_type: returns true if a giving MIPS instruction is a macro/pseudo instruction
#   macro_prolog:
#   macro_epilog:
#   expand_
#   read_
#
# Use "macro_start" and "macro_end" to identify the execution boundaries of a macro
# Note: depending on final implemenations, 
#   - nested use of macros will not be allows
#   - this is in complemente with the MARS implementation
#
##   the use of MACRO might be used to appropriate define labels


# Labels within Macros.
# ==========
# 
# Macros have to be named with both filename and macro/linenum 
# e.g., stdin_test_23_a
# 
# MACRO=name_linenum
# FILE=
# Alternativelly, you can name the macro based upon number
# in the code below, I have insert macro_use as the uniq id
# This relates to the address in memory.
#
# i.e., labels within macros are NOT supported at this moment

function is_macro () {
   local name="$1"
   local argc="$(( $# - 1  ))"

   type=$(macro_type "${name}" "${argc}")
   if [[ $type != FALSE ]] ; then
    type="TRUE"
   fi
}

function macro_type () {
   local name="$1"
   local argc="$(( $# - 1  ))"

   local type=$(type -t "macro_${name}_${argc}")

   if [[ $type = "function" ]] ; then 
     echo "macro"
     return 0
   fi
   type=$(type -t "pseudo_${name}_${argc}")
   if [[ $type = "function" ]] ; then 
     echo "pseudo"
     return 0
   fi

   echo "FALSE"
   return 1
}


function macro_start () {
  local type="$1"
  local name="$2"
  local argc="$3"
  local use="$4"

  [[ "${EMIT_SYNOPSIS}" == "FALSE" ]] | { echo "Start of ${type} \"${name}\" (${argc})" ; echo ; }
  MACRO="${type}_${name}_${use}"

}
alias pseudo_end="macro_end"
function macro_end () {
  local type="$1"
  local name="$2"
  local argc="$3"
  local use="$4"

  [[ "${EMIT_SYNOPSIS}" == "FALSE" ]] | { echo "End of ${type} \"${name}\" (${argc})"; echo ; }
  MACRO=""
}

function expand_macro () {
  local type="$1" ; shift
  local name="$1" ; shift
  local args="$@"

  local count=$#
  local macro="${type}_${name}_${count}"

  # Protect the $ signs from being interpolated at this time
  args=$(sed -e 's/\$/\\$/g' <<< "$args" )
  eval ${macro} ${args}
  echo "${type}_end ${type} ${name} ${count} ${MACRO_COUNT}"
  (( MACRO_COUNT ++ ))
}

function apply_macro () {
  local name=$1
  shift;

  local instruction="$(remove_label $(rval $_ir) )"
  local type="$(macro_type ${instruction} )"

  local current_pc=$(rval $_pc)

   if (( (current_pc + 4) ==  ${TEXT_NEXT}  )) ; then 
     # The macro was the last instruction in the instruction stream
     # Hence we need to insert its definition into the stream.
     TEXT[${current_pc}]=nil
     assign $_pc $(( current_pc + 4 ))

     while cycle ; do
       :
     done < <(expand_macro ${type} $instruction)
   
   else
     # The macro has already been expanded.
     # Set up the environment for proper execution
     macro_start "${type}"  "${name}" "${count}"
   fi
}


function read_macro () {
  # function is invoked via ".macro" or ".pseudo" directive
  # function reads all lines until the final ".end_macro"
  type="$1" ; shift

  count=$(( $# ))
  name=$1
  patterns=( "$@" )

  local func_name="${type}_${name}_$((count-1))"
  { 
    cat <<-EOF
alias $name="apply_macro $name"

function ${func_name}  () {
    
  # remove optional commas
  # quote arg that contains a space
EOF
    for (( i=1 ; i < ${count} ; i++ )) ; do 
       echo  "  local arg$i=\"\$(sed -e 's/,$//' -e 's/\(.* .*\)/"\1"/' <<< \$$i)\""
    done

    cat <<-EOF

  # apply the parameter subsitution longest to shortest
  # for now, just first to last
EOF
  echo -n "  cat <<-EOF"
  local pattern
  local i

  if (( count == 0 )) ; then
    echo
  else
    echo " |\\"
      i=1
      pattern="${patterns[$i]}"
      echo "    sed -e \"s/${pattern}/\$arg$i/g\" \\"

      for (( i=2 ; i < ${count} ; i++ )) ; do 
        pattern="${patterns[$i]}"
        echo "        -e \"s/${pattern}/\$arg$i/g\" \\"
      done
      echo
    fi

    while read -e -p "(macro) " _command ; do 
      [[ "$_command" != ".end_${type}" ]] || break
      sed -e 's/^/  /' -e 's/\$/\\$/g' <<< $_command
    done 

    echo "EOF"  
    echo "}"
  } > ${MIPS_CLI_HOME}/tmp/${func_name}.bash

  source ${MIPS_CLI_HOME}/tmp/${func_name}.bash

}

