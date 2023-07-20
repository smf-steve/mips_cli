#! /bin/bash

#################################################################################
# This file contains the declarations of all supported MIPS native instructions
#
# Each instruction is implemented as an alias that calls the correct,
#   based upon type and syntax, "execute" function. The function accepts two 
#   additional parameters:
#      1. the name of the instruction
#      1. the corresponding bash ARITHMETIC EXPRESSION operator
#
# Reference: "documentation/mips_encoding_reference.pdf"
#################################################################################


## ARITHMETIC
alias      add="trap_on_V; execute_ArithLog  add   +"
alias     addu="           execute_ArithLog  addu  +"
alias     addi="trap_on_V; execute_ArithLogI addi  +"
alias    addiu="           execute_ArithLogI addiu +"
alias      sub="trap_on_V; execute_ArithLog  sub   -"
alias     subu="           execute_ArithLog  subu  -"

# LOGICAL
alias      and="execute_ArithLog  and  \&"
alias     andi="execute_ArithLogI andi \&"
alias       or="execute_ArithLog  or   \|"
alias      ori="execute_ArithLogI ori  \|"
alias      xor="execute_ArithLog  xor  ^"
alias     xori="execute_ArithLogI xori ^"
alias      nor="execute_ArithLog  nor  \~\|"

# SET
alias      slt='execute_ArithLog  slt   "<"'
alias     sltu='execute_ArithLog  sltu  "<"'
alias     slti='execute_ArithLogI slti  "<"'
alias    sltiu='execute_ArithLogI sltiu "<"'

# SHIFTs
alias      sll="execute_Shift  sll  '<<'"
alias      sra="execute_Shift  sra  '>>'"
alias      srl="execute_Shift  srl  '>>>'" 
alias     sllv="execute_ShiftV sllv '<<'"
alias     srav="execute_ShiftV srav '>>'"
alias     srlv="execute_ShiftV srlv '>>>'"

# MULT-DIV
alias     mult="execute_DivMult mult \*"
alias    multu="execute_DivMult multu \*"

alias      div="execute_DivMult div /"
alias     divu="execute_DivMult div /"

alias     mthi="execute_MoveTo   mthi "=" _hi"       # mfhi $t0
alias     mtlo="execute_MoveTo   mtlo "=" _lo"       # mflo $t0
alias     mfhi="execute_MoveFrom mfhi "=" _hi"       # mthi $t0
alias     mflo="execute_MoveFrom mflo "=" _lo"       # mtlo $t0

## LOAD IMMEDIATE
alias      lui='execute_LoadI lui --'      
alias      lhi='execute_LoadI lhi --'               # Part of Hennessy & Patterson
alias      llo='execute_LoadI llo --'

## LOAD STORE
alias       lb='execute_LoadStore lb  --'
alias       lh='execute_LoadStore lh  --'
alias       lw='execute_LoadStore lw  --'
alias      lbu='execute_LoadStore lbu --'
alias      lhu='execute_LoadStore lhu --'
alias       sb='execute_LoadStore sb  --'
alias       sh='execute_LoadStore sh  --'
alias       sw='execute_LoadStore sw  --'

## JUMP and JUMPR
alias        j='execute_Jump  j    --'
alias      jal='execute_Jump  jal  --'
alias       jr='execute_JumpR jr   --'
alias     jalr='execute_JumpR jalr --'

## BRANCH and BRANCHZ
alias      beq='execute_Branch beq --'
alias      bne='execute_Branch bne --'
alias     blez='execute_BranchZ blez --'
alias     bgtz='execute_BranchZ bgtz --'

## TRAP 
alias  syscall='echo execute_Trap syscall --'
alias     trap='echo execute_Trap trap --' 



## This is soley a WB operation 
alias     movz='echo execute_Test movn -n'
alias     movn='echo execute_Test movz -z'
   #  movn $8, $11, $4  ;  copies the contents of register 11 into register 8  if $4 == 0


