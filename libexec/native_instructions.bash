## ARITHMETIC
alias   add="trap_on_V; execute_ArithLog  add   +"
alias  addu="           execute_ArithLog  addu  +"
alias  addi="trap_on_V; execute_ArithLogI addi  +"
alias addiu="           execute_ArithLogI addiu +"
alias   sub="trap_on_V; execute_ArithLog  sub   -"
alias  subu="           execute_ArithLog  subu  -"

# LOGICAL
alias   and="execute_ArithLog  and  \&"
alias  andi="execute_ArithLogI andi \&"
alias    or="execute_ArithLog  or   \|"
alias   ori="execute_ArithLogI ori  \|"
alias   xor="execute_ArithLog  xor  ^"
alias  xori="execute_ArithLogI xori ^"

alias   nor="execute_ArithLog nor  \~\|"
alias  nori="echo Instruction does not exist"    

# SET Instructions
alias      slt='execute_ArithLog  slt "<"'
alias     sltu='execute_ArithLog  sltu "<"'
alias     slti='execute_ArithLogI slti "<"'
alias    sltiu='execute_ArithLogI sltiu "<"'

# SHIFTs
alias   sll="execute_Shift  sll '<<'"
alias   sra="execute_Shift  sra '>>'"
alias   srl="execute_Shift  srl '>>>'" 
alias  sllv="execute_ShiftV sllv '<<'"
alias  srav="execute_ShiftV srav '>>'"
alias  srlv="execute_ShiftV srlv '>>>'"

# MULT-DIV
alias  mult="execute_MD mult \*"
alias  multu="execute_MD multu \*"

alias   div="execute_MD div /"
alias   divu="execute_MD div /"

alias  mthi="execute_MoveTo   mthi "=" _hi"       # mfhi $t0
alias  mtlo="execute_MoveTo   mtlo "=" _lo"       # mflo $t0
alias  mfhi="execute_MoveFrom mfhi "=" _hi"       # mthi $t0
alias  mflo="execute_MoveFrom mflo "=" _lo"       # mtlo $t0

## LoadStore
#
alias       lb='echo To be implemented'
alias       lh='echo To be implemented'
alias       lw='echo To be implemented'
alias      lbu='echo To be implemented'
alias     lbhu='echo To be implemented'
alias       sb='echo To be implemented'
alias       sh='echo To be implemented'
alias       sw='echo To be implemented'

## Jump and JumpR
alias        j='echo To be implemented'
alias      jal='echo To be implemented'
alias       jr='echo To be implemented'
alias     jalr='echo To be implemented'
alias  syscall='echo To be implemented'


## Branch and BranchZ
alias      beq='echo To be implemented'
alias      bne='echo To be implemented'
alias     blez='echo To be implemented'
alias     bgtz='echo To be implemented'


## 

alias     movz='echo To be implemented'
alias     movn='echo To be implemented'





