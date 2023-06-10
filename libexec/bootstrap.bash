#! /bin/bash

# It is intended that this script is called via
#  $ bash --init-file libexec/bootstrap.bash -i
#
# Within a new interactive shell, this script
#
#  1. source all of the appropriate *.bash supporting scripts
#  1. sets a trap for on exit, to go to the next executing line
#  1. emits a banner
#  1. sets the default segment [.text]
#  1. resets the prompt
#
#  At this point, this subshell can execute the various MIPS cli
#  commands.

trap "" SIGUSR1  # when an error occurs, go to the next line
instruction_error () {
  echo "$1" 1>&2 
  echo
  assign $_pc "$(( $(rval $_pc) - 4 ))"
  kill -n SIGUSR1 $$
}

instruction_warning () {
  echo "$1" 1>&2 
  echo
  assign $_pc "$(( $(rval $_pc) - 4 ))"
}


# Inclue the support files:
source libexec/settings.bash
source libexec/library.bash
source libexec/read_literal.bash
source libexec/machine/machine.bash

source libexec/labels.bash
source libexec/execute.bash
source libexec/dump.bash
source libexec/encoding.bash
source libexec/instructions/directives.bash
source libexec/instructions/native_instructions.bash
source libexec/instructions/pseudo_instructions.bash
source libexec/instructions/synonym_instructions.bash



function error () {

  echo "$1"

}



function execute () {
  _filename="$1"

  [[ -f $_filename ]] ||  { echo "$_filename not found" ; return 1; }
  while read _line; do
    echo $_line
    eval $_line
    sleep 1
  done < $_filename
}

function execute () {
  _filename="$1"

  [[ -f $_filename ]] ||  { echo "$_filename not found" ; return 1; }
  while cycle ; do
    :
  done < $_filename
}


function assemble_file () {
   local source_filename="$1"
   local core_file="$(basename -e .s ${source_file}).core"

   if [[ ${source_file} -nt ${core_file} ]] ; then
     rm -f ${core_file}
   fi

   prefetch ${TEXT_END}

}



## We need a boot process to set registers and such
assign $_npc ${TEXT_START}
assign $_pc ${TEXT_START}
assign $sp ${SP_START}

echo "Entering the MIPS Command-Line-Interface"
echo


#PS1="(mips) "

# while cycle ; do
#   :
# done
# 
# echo
# echo "Exiting the MIPS Command-Line-Interface"
# exit
