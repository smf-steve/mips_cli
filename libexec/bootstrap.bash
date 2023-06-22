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
#
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
source libexec/settings.bash
source libexec/library.bash
source libexec/parse_literal.bash
source libexec/machine/machine.bash

source libexec/labels.bash
source libexec/execute.bash
source libexec/dump.bash
source libexec/encoding.bash

source libexec/instructions/instructions.bash




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


alias execute_batch="execute batch"
alias execute_debug="execute debug"
function execute () {
  local mode="$1"
  local label="$2"
  shift ; shift
  local args="$@"

  # Batch mode... currently execute what I have, but go into debug mode when I go into the base
  # Debug Mode..  go into debug mode ASAP
  [[ $mode == "batch" ]] 
  [[ $mode == "batch" ]] 

  INTERACTIVE=FALSE

  if [[ -z "$label" ]] ; then
    assign $_pc "$label"
  fi

  ## load the $aX registers

  [[ -n $_filename ]] || { _filename="/dev/tty" ; INTERACTIVE=TRUE ; }
  [[ -e $_filename ]] || { echo "$_filename not found" ; return 1; }

  # boot
  while cycle ; do
    :
  done < $_filename
  PS1="post "
}


function rewind () {
   assign $_pc  ${TEXT_START}
   assign $_npc 0x00400000
   assign $fp 0x00
   assign $gp 0x00
   assign $ra _exit
   # registers and memory are left as is...

}

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
  source libexec/settings.bash
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
    prefetch "$(rval $_pc)"  '!unresolvabe_label'  < "${file_name}"
  fi
  declare -p INSTRUCTION
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


