#! /bin/bash

#################################################################################
# This file contains the functions required to support both 
#   - pseudo instructions
#   - user macros
# 
# Pseudo instructions are part of the mips_cli environment, and 
# some of these instructions need to directly access information
# known only to the assembler.
#
# In the implementation mips_cli, pseudo instructions and user macros 
# have been unified.  That is to say, they are implemented using the
# same set of bash functions.  The only difference between the two is
# in the way in which they are defined.  Pseudo instructions use the 
# `.pseudo` directive, whereas user macros use the `.macro` directive.
# This also allows us to have different descriptive output when either
# a pseudo instruction or user macro is executed.
#
# As an example, the following is the definition of the 'la' pseudo
# instruction.  Notice that the definition includes a call to a bash
# function. It manipulates the address of the label (which is only)
# known by the assembler.
# 
#   .pseudo la %dst, %label
#      lui $at, $(upper %label)
#      ori %dst, $at, $(lower %label)
#   .end_pseudo
#
# Access to the internal bash functions are also available to user macros.
# Or more accurately, we do not take steps to prevent the user from accessing
# these internal functions. 
#################################################################################

# Functions
#   is_macro ( instruction ): returns TRUE or FALSE, if the instruction uses a macro 
#   macro_type( name, argc ): returns pseudo, macro, or FALSE
#   list_macros
#   macro_prologue: called when a macro is invoked
#   macro_epilogue: called when a macro is finished
#   expand_macro
#   read_macro
#  
#
# The functions "macro_prologue" and "macro_eplilogue" are used identify the execution
# boundaries of a macro.

# Current Limitations:
#   1. labels are current not supported -- i.e., no control flow can be performed
#   1. nested calls to macros are not currently supported (tested)
#   1. nested definition are NOT supported

# Pending: Labels within Macros.
# ==========
# 
# A global variable {MACRO_COUNT} has been introduced.
# This variable it incremented each time a macro is expanded.
# As such, a label within a macro definition can be expanded
# to  {label}_${MACRO_COUNT} to ensure it has a unique name.
#
# In MARS:
#
# If a label name is passed it, it is not expanded with the MACRO_COUNT.
# In the following p_label is defined twice
#   .macro test ( %1, %2, %3 )
#       m_label:   beq $t1, $t2, p_label 
#       %3:        beq $t1, $t2, m_label
#   .end_macro 
#    
#                test $t1, $t2, p_label
#   p_label:    nop
#
# In the following, bizarre results can occur
#   .macro test ( %1, %2, %3 )
#                  beq $t1, $t2, m_label
#       m_label:   beq $t1, $t2, m_label     <-- the trouble maker
#       %3:        beq $t1, $t2, m_label
#    .end_macro 
#
# Question:  If a label is referenced in a macro, yet it is no yet
#     defined, when does the .e., labels within macros are NOT supported at this moment




function is_macro () {
   local name="$1"
   local argc="$(( $# - 1  ))"  # we need to remove the name of the op

   type=$(macro_type "${name}" "${argc}")
   if [[ $type != FALSE ]] ; then
    type="TRUE"
   fi
   echo "$type"
}

function macro_type () {
   local name="$1"
   local argc="$(( $# - 1 ))"

   local type=$(type -t "macro_${name}_${argc}")

   if [[ $type == "function" ]] ; then 
     echo "macro"
     return 0
   fi
   type=$(type -t "pseudo_${name}_${argc}")
   if [[ $type == "function" ]] ; then 
     echo "pseudo"
     return 0
   fi

   echo "FALSE"
   return 1
}


function macro_prologue () {
  local type="$1"
  local name="$2"
  local argc="$3"
  local use="$4"

  [[ "${EMIT_SYNOPSIS}" == "FALSE" ]] | { echo "Start of ${type} \"${name}\" (${argc})" ; echo ; }
  MACRO="${type}_${name}_${use}"
  MACRO_EXECUTION=TRUE

}
alias pseudo_epilogue="macro_epilogue"
function macro_epilogue () {
  local type="$1"
  local name="$2"
  local argc="$3"
  local use="$4"

  [[ "${EMIT_SYNOPSIS}" == "FALSE" ]] | { echo "End of ${type} \"${name}\" (${argc})"; echo ; }
  MACRO_EXECUTION=FALSE
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
  echo "${type}_epilogue ${type} ${name} ${count} ${MACRO_COUNT}"
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

     MACRO_EXECUTION=TRUE
     while cycle ; do
       :
     done < <(expand_macro ${type} $instruction)
   
   else
     # The macro has already been expanded.
     # Set up the environment for proper execution
     macro_prologue "${type}"  "${name}" "${count}"
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
      pattern="$(sed -e 's/,$//' <<< ${patterns[$i]} )"
      echo "    sed -e \"s/${pattern}/\$arg$i/g\" \\"

      for (( i=2 ; i < ${count} ; i++ )) ; do 
        pattern="$(sed -e 's/,$//' <<< ${patterns[$i]} )"
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

