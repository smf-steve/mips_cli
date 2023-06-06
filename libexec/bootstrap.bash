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
source libexec/execute.bash
source libexec/labels.bash
source libexec/encoding.bash
source libexec/instructions/directives.bash
source libexec/instructions/native_instructions.bash
source libexec/instructions/pseudo_instructions.bash
source libexec/instructions/synonym_instructions.bash

function error () {

  echo "$1"

}

echo "Entering the MIPS Command-Line-Interface"
echo
assign $_pc 0x04000000

PS1="(mips) "



# At this point, the shell will process things interactive.
#  - one issue is that we are not keeping track of our history
#  - hence we can't assign values to the branch/jump label
    #  * perhaps the history shell function can help us out
#
# Another problem is that labels can be implicitly created.
#   hence on there first use, they is a command not found error
#     (mips) foo: add $t1, $t2, $t4
#     bash: foo:: command not found
#     (mips) echo !!
#     echo foo: add $t1, $t2, $t4
#     foo: add 9, 10, 12

# Solutions:
#  1. predeclare the notion of label name
#     label l:
#  1. do a two pass scan of the input file -- will not work for interactive
#  1. capture the error message and use the history command to extract what was typed
#     1. assert the value of the label, anbd then execute the command
#  1. use a input loop to parse the command line, and then call eval
#       echo -n "$PS1"
#       while read -a _line; do
#         if [[ _line[0] ~= "*:" ]] ; then
#            # first token is a label
#         echo $_line
#         shift _line
#         eval $_line
#         sleep 2
#         echo -n "$PS1"
#       done

