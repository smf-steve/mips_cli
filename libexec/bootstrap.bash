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
  echo "$1" 
  assign $_pc "$(( $(rval $_pc) - 4 ))"
  kill -n SIGUSR1 $$
}


for f in libexec/*.bash ; do
   [[ $f != libexec/bootstrap.bash ]] && source $f
done

echo "Entering the MIPS Command-Line-Interface"
echo
assign $_pc 0x04000000

PS1="(mips) "
text_segment=".text"
