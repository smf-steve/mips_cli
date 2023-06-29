#! /bin/bash

# Use "macro_start" and "macro_end" to identify the execution boundaries of a macro
# Note: depending on final implemenations, 
#   - nested use of macros will not be allows
#   - this is in complemente with the MARS implementation
#
##   the use of MACRO might be used to appropriate define labels



function is_macro () {
   name="$1"
   num_args=$(( $# - 1 ))

   type=$(type -t "macro_${name}_${num_args}")
   if [[ $type = "function" ]] ; then 
     echo "TRUE"
     return 0
   else
     echo "FALSE"
     return 1
   fi
}

function macro_start () {
  macro_name="$1"
  macro_use="$2"
  macro_use="$3"

  [[ $synopsis == FALSE ]] | { echo "Start of macro \"${macro_name}\" (${arg_count})" ; echo ; }
  MACRO="${macro_name}_${macro_use}"

}
function macro_end () {
   macro_name="$1"
   arg_count="$2"

  [[ $synopsis == FALSE ]] | { echo "End of macro \"${macro_name}\" (${arg_count})"; echo ; }
  MACRO=""
}

function expand_macro () {
  local name="$1" ; shift
  local args="$@"

  local count=$#
  local macro="macro_${name}_$count"

  # Protect the $ signs from being interpolated at this time
  args=$(sed -e 's/\$/\\$/g' <<< "$args" )
  eval $macro $args
  echo "macro_end ${name} ${count} ${current_pc}"
}

function apply_macro () {
  local name=$1
  shift;

  local count=$#
  local macro="macro_${name}_$count"

  local current_pc=$(rval $_pc)

   if (( (current_pc + 4) ==  ${TEXT_NEXT}  )) ; then 
     # The macro was the last instruction in the instruction stream
     # Henc we need to insert its definition into the stream.
     local instruction="$(remove_label $(rval $_ir) )"
     TEXT[${current_pc}]=nil
     assign $_pc $(( current_pc + 4 ))

     while cycle ; do
       :
     done < <(expand_macro $instruction)
   
   
     # The above works in INTERACTIVE mode.
     # if we are in batch mode, when need to expand the macro during 
     # the prefetch stage
     # hence we need update the prefetch stage to execute the first
     # iteration of the loop... or at least identify the number of slots it needs
   else
     # The macro has already been expanded.
     # Set up the environment for promper execution
     macro_start "${name}" "${count}" "${current_pc}"
   fi
}


function read_macro () {
  # function is invoked via ".macro"
  # function reads all lines until the final ".end_macro"
  count=$(( $# ))
  name=$1
  patterns=( "$@" )

  local func_name="macro_${name}_$((count-1))"
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
      [[ "$_command" != ".end_macro" ]] || break
      sed -e 's/^/  /' -e 's/\$/\\$/g' <<< $_command
    done 

    echo "EOF"  
    echo "}"
  } > ${MIPS_CLI_HOME}/tmp/${func_name}.bash

  source ${MIPS_CLI_HOME}/tmp/${func_name}.bash

}

