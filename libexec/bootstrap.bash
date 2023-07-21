#! /bin/bash


# It is intended that this script is called via
#  $ bash --init-file libexec/bootstrap.bash -i
#
# Within a new interactive shell, this script
#
#  1. source all of the appropriate *.bash supporting scripts
#  1. sets a trap for on exit, to go to the next executing line
#  1. emits a banner
#  1. resets the prompt
#
#  At this point, this subshell can execute the various MIPS cli
#  commands.

trap "break 1" SIGUSR1  # when an error occurs, go to the next line

# The trap should go different places depending on which mode I am in.
# 

# execute subroutine [args]
#   0. sets batch mode: execution is true,
#   1. honors summary flags: encoding and execution
#   1. may provide a time-step in summary mode
#   1. no prompt is necessary  
#   1. requires a subroutine to execute
#   2. executes all code till completion
#   3. returns to the manual mode upon completion
#
# debug subroutine [args] ]
#   0. sets debug mode:  execution is true
#   1. honors summary flags: encoding and execution
#   1. prompt = "(debug) "
#   1. requires a subroutine to execute
#   2. execute an instruction one step at a time
#   3. returns to the manual mode upon completion
#      1. return value is set based upon the last instruction being jr $ra, where ra=$(rval pc)
#      1. if debug mode entered based upon a call, then return must be success
#      1. if debug mode entered due to a backward reference, then return doe snot have to be success
#   3. does not record any extra instructions, i.e., must use @for known mips instructions
#
# interactive
# manual (this is manual or on the fly mode)  this will become the default mode.
#   0. sets manual mode
#   1. prompt = "(mips) "
#   1. records instructions as you go
#   2. goes into debug mode when a back reference is use
#   3. stays in manual mode till... when forward reference is hit
#   4.  unset debug mode  
# manual "filename" -- executes filename instead of /dev/tty

# cli:  This is defualt mode.
#   1. prompt= "(cli) "
#   1. allows execution of non-control flow and no label mips instructions
#   1. it updates the machine, but not the PC, 
#   1. does not update labels nor instructions
#   =--  what good is this..
#    1. just to run the cli commands
#    1. just to run the encoding tool
#   IF we provid a tool to clean the history... then this is just manual mode


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
source ${MIPS_CLI_HOME}/libexec/settings.bash
source ${MIPS_CLI_HOME}/libexec/library.bash
source ${MIPS_CLI_HOME}/libexec/parse_literal.bash
source ${MIPS_CLI_HOME}/libexec/machine/machine.bash

source ${MIPS_CLI_HOME}/libexec/cycle.bash
source ${MIPS_CLI_HOME}/libexec/execute.bash

source ${MIPS_CLI_HOME}/libexec/labels.bash
source ${MIPS_CLI_HOME}/libexec/dump.bash
source ${MIPS_CLI_HOME}/libexec/encoding.bash

source ${MIPS_CLI_HOME}/libexec/instructions/native_instructions.bash
source ${MIPS_CLI_HOME}/libexec/instructions/directives.bash
source ${MIPS_CLI_HOME}/libexec/macros.bash


mkdir -p ${MIPS_CLI_HOME}/tmp


###  Interactive:  (and on the fly)
#  execute
# execute subroutine [args] ;  executes the subroutines in batch mode after loading the registers
# execute

##  Debug
##  load - this assembles it
##  execute PC=${PC_START}


#     --  no more than 4 arguements, assume all to be ints
#     --  for i in "$@" ;  assign $a0 $i
#     --  jal subroutine
#
function load_args () {
   (( $# != 0 )) || return;
   (( $# <= 4 )) || { instruction_error "to many args" ; return; }

   i=0
   for arg in "$@" ; do
    eval assign \$a$i "$arg"
    (( i = i + 1 ))
   done
}

alias execute="run BATCH"
alias debug="run DEBUG"
alias step="run INTERACTIVE"
alias encode="run ENCODE"
function run () {
  local mode="$1"
  local label="$2"  ## only makes sense for DEBUG and BATCH
  shift ; shift

  # Here we assume that label is good.
  load_args "$@"    ## Does NOT make sense for Encodings

  case $mode in 
    DEBUG )
       [[ -n "$label" ]] || instruction_warning "Usage: must provide a label"
       PS1="(debug) "
       DEBUG_MODE=TRUE
       INTERACTIVE=TRUE
       EXECUTE_INSTRUCTIONS=TRUE
       EMIT_ENCODINGS=TRUE
       EMIT_EXECUTION_SUMMARY=TRUE
       assign $_pc "$(lookup_text_label $label)"
             ;;
    BATCH )
       [[ -n "$label" ]] || instruction_warning "Usage: must provide a label"
       PS1="(batch) "
       DEBUG_MODE=FALSE
       INTERACTIVE=FALSE
       EXECUTE_INSTRUCTIONS=TRUE
       EMIT_ENCODINGS=TRUE
       EMIT_EXECUTION_SUMMARY=TRUE
       assign $_pc "$(lookup_text_label $label)"
       ;;

    ENCODE )
       PS1="(encode) "
       INTERACTIVE=FALSE
       DEBUG_MODE=FALSE
       EMIT_ENCODINGS=TRUE
       EXECUTE_INSTRUCTIONS=FALSE
       EMIT_EXECUTION_SUMMARY=FALSE
       assign $_pc "${TEXT_START}"
       ;;

    INTERACTIVE )
       PS1="(step) "
       INTERACTIVE=TRUE
       DEBUG_MODE=TRUE
       EMIT_ENCODINGS=TRUE
       EXECUTE_INSTRUCTIONS=TRUE
       EMIT_EXECUTION_SUMMARY=TRUE
       assign $_pc "${TEXT_NEXT}"
  esac

  # boot
  while cycle ; do
    :
    # Break from the loop at the end of the stored program, unless we are in interactive mode
    if [[ $INTERACTIVE == FALSE ]] ; then 
      if (( $(rval $_pc) == ${TEXT_NEXT} )) ; then
        break;
      fi
    fi
  done
  PS1="(top) "
  echo
  print_register $v0
  print_register $v1
}


function rewind () {
   assign $_pc  ${TEXT_START}
   assign $_npc 0x00400000
   assign $fp 0x00
   assign $gp 0x00
   # assign $ra _exit

   # registers and memory are left as is...

}

alias    shell=""    # to allow shell commands to be executed without being recorded

alias    init=" initialize"
alias    reset="initialize"
function initialize () {
  # clears the core and calls rewinds
  # leaves registers alone

  TEXT=()
  DATA=()
  HEAP=()
  STACK=()
  INSTRUCTION=()
  LABELS=()
  reset_macros
  source ${MIPS_CLI_HOME}/libexec/settings.bash
  rewind

}

alias    include="  load_file include"
alias    load_core="load_file core"
alias    load="     load_file --"
function load_file () {
  local file_type="$1"
  local file_name="$2"

  if [[ ! -f ${file_name} ]] ; then
    instruction_error "\"${file_name}\": file not found."
    return
  fi
  
  [[ "$file_type" == "include" ]] || initialize
  
  if [[ "$file_type" == "core" ]] ; then
    source ${file_name}
  else
      local temp=$INTERACTIVE
      INTERACTIVE=FALSE
      prefetch "${TEXT_NEXT}"  '!unresolvabe_label'  < "${file_name}"
      INTERACTIVE=$temp
  fi
}



##
function crt0 () {
  columns=$(tput cols)
  if (( columns <  95 )) ; then
    echo "Width of window is to small -- resize to a minimum width of 95"
  fi
  
  echo "Entering the MIPS Command-Line-Interface"
  echo
  rewind
}


function _exit () {
  echo
  echo "Exiting the MIPS Command-Line-Interface"
  exit
}


crt0
echo "Warning: top mode is only for testing"
echo "Macros and Labels do not work appropriately within this mode"
echo
PS1="(top) "

while read _file ; do
  source $_file
done < <(ls ${MIPS_CLI_HOME}/tmp/pseudo*.bash) 

