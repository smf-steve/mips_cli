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
source libexec/parse_literal.bash
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

function reinitialize () {

  assign $_npc ${TEXT_START}
  assign $_pc ${TEXT_START}
  assign $sp ${SP_START}

}

function execute () {
  local _filename="$1"

  INTERACTIVE=FALSE

  old_PS1="$PS1 "
  [[ -n $_filename ]] || { _filename="/dev/tty" ; INTERACTIVE=TRUE ; }
  [[ -e $_filename ]] || { echo "$_filename not found" ; return 1; }

  # boot
  while cycle ; do
    :
  done < $_filename
  PS1="post "
}


function assemble_file () {
   local source_filename="$1"
   local core_file="$(basename -e .s ${source_file}).core"

   if [[ ${source_file} -nt ${core_file} ]] ; then
     rm -f ${core_file}
   fi

   prefetch "${TEXT_START}"  "!unresolvabe_label"

}

##
columns=$(tput cols)
if (( columns <  95 )) ; then
  echo "Width of window is to small -- resize to a minimum width of 95"
fi


echo "Entering the MIPS Command-Line-Interface"
echo
reinitialize
# execute

echo
echo "Exiting the MIPS Command-Line-Interface"
exit
