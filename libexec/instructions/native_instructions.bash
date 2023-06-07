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

alias      nor="execute_ArithLog nor  \~\|"
alias     nori="echo Instruction does not exist"    

# Set Instructions
alias      stl='execute_ArithLog  stl   "<"'
alias     sltu='execute_ArithLog  stlu  "<"'
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


## LoadImmediate
alias      lui='execute_LoadI lui --'
alias      lhi='execute_LoadI lhi --'       # Part of Hennessy&Pattrson
alias      llo='execute_LoadI llo --'

## LoadStore
alias       lb='execute_LoadStore lb --'
alias       lh='execute_LoadStore lh --'
alias       lw='execute_LoadStore lw --'
alias      lbu='execute_LoadStore lbu --'
alias      lhu='execute_LoadStore lhu --'
alias       sb='execute_LoadStore sb --'
alias       sh='execute_LoadStore sh --'
alias       sw='execute_LoadStore sw --'

## Jump and JumpR
alias        j='execute_Jump  j   --'
alias      jal='execute_Jump  jal  --'
alias       jr='execute_JumpR jr   --'
alias     jalr='execute_JumpR jalr --'

## Jump 
alias  syscall='echo To be implemented'


## Branch and BranchZ
alias      beq='execute_Branch beq --'
alias      bne='execute_Branch bne --'
alias     blez='execute_BranchZ blez --'
alias     bgtz='execute_BranchZ bgtz --'


## 

## This is soley a WB operation 
alias     movz='echo To be implemented'
alias     movn='echo To be implemented'





