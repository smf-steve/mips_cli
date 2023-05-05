# Plan..  add "trap_on_V" command if a "signed" command

## ARITHMETIC
alias   add="trap_on_V; execute_RRR +"
alias  addu="execute_RRR +"
alias  addi="trap_on_V; execute_RRI +"
alias addiu="execute_RRI +"
alias   sub="trap_on_V; execute_RRR -"
alias  subu="execute_RRR -"

# LOGICAL
alias   and="execute_RRR \&"
alias    or="execute_RRR \|"
alias   xor="execute_RRR ^"
alias   nor="execute_nor nor"

alias  andi="execute_RRI \&"
alias   ori="execute_RRI \|"
alias  xori="execute_RRI ^"
alias  nori="nori"                      # command does not exist

# SHIFT
alias   sll="execute_RRI '<<'"
alias   sra="execute_RRI '>>'"

alias  sllv="execute_RRR '<<'"
alias  srav="execute_RRR '>>'"

alias   srl="execute_srl '>>>'"
alias  srlv="execute_srlv '>>>'"


# MULT-DIV
alias   mult="execute_MD \*"
alias    div="execute_MD /"

# SPECIAL
alias  mthi="execute_RR move _hi"       # mfhi $t0
alias  mtlo="execute_RR move _lo"       # mflo $t0

alias  mfhi="reverse_op move _hi"       # mthi $t0
alias  mflo="reverse_op move _lo"       # mtlo $t0
alias   lui="lui"
