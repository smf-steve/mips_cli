#! /bin/bash

declare -a INSTRUCTION
declare -a TEXT
declare -a DATA
declare -a HEAP
declare -a STACK

ENDIANNESS="LITTLE"

TEXT_START=0x00400000          ; TEXT_NEXT=$TEXT_START
TEXT_LAST=0x00000000
TEXT_END=0x0FFFFFFF


DATA_START=0x10010000          ; DATA_NEXT=$DATA_START
DATA_LAST=0x00000000
DATA_END=0x1003FFFF

HEAP_START=$((DATA_END + 1))   ; HEAP_NEXT=$(( HEAP_START + 4 ))
HEAP_LAST=${HEAP_START}
HEAP_END='HEAP[${HEAP_START}]' # Note: value has to be determined dynamically

HEAP[${HEAP_START}]=${HEAP_NEXT}  
   # Free Pointer is positioned as the first element of the heap


STACK_START=0x7FFFFFFF        ; STACK_NEXT=$STACK_START   # does this point to the top element or?
#stack_end='$(rval $fp)'      # Note: value has to be determined dynamically

STACK[${STACK_START}]=0xDEADBEAF
#assign $fp ${stark_start}
   # A "deadbeaf" value is stored on top of the stack!


EMIT_SYNOPSIS=TRUE
EXECUTE_INSTRUCTIONS=TRUE
EMIT_ENCODINGS=TRUE
EMIT_EXECUTION_SUMMARY=TRUE

INTERACTIVE=FALSE
DEBUG_MODE=FALSE

MACRO_COUNT=0
MACRO_EXECUTION=FALSE