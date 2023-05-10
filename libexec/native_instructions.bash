# Plan..  add "trap_on_V" command if a "signed" command

## ARITHMETIC
alias   add="trap_on_V; execute_RRR add +"
alias  addu="execute_RRR addu +"
alias  addi="trap_on_V; execute_RRI addi +"
alias addiu="execute_RRI addiu +"
alias   sub="trap_on_V; execute_RRR sub -"
alias  subu="execute_RRR subu -"

# LOGICAL
alias   and="execute_RRR and \&"
alias    or="execute_RRR or \|"
alias   xor="execute_RRR xor ^"
alias   nor="execute_nor nor"

alias  andi="execute_RRI \&"
alias   ori="execute_RRI \|"
alias  xori="execute_RRI ^"
alias  nori="nori"                      # command does not exist

# SHIFT
alias   sll="execute_RRI sll '<<'"
alias   sra="execute_RRI sll '>>'"

alias  sllv="execute_RRR sslv '<<'"
alias  srav="execute_RRR srav '>>'"

alias   srl="execute_srl srl '>>>'"
alias  srlv="execute_srlv srlv '>>>'"


# MULT-DIV
alias   mult="execute_MD mult \*"
alias    div="execute_MD div /"

# SPECIAL
alias  mthi="execute_RR mthi move _hi"       # mfhi $t0
alias  mtlo="execute_RR mtlo move _lo"       # mflo $t0

alias  mfhi="reverse_op mfhi move _hi"       # mthi $t0
alias  mflo="reverse_op mflo move _lo"       # mtlo $t0
alias   lui="lui"
