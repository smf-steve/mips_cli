# Plann..  add "trap_on_V" command if a "signed" command

alias   add="trap_on_V; execute_RRR +"
alias  addu="execute_RRR +"
alias  addi="execute_RRI +"
alias addiu="execute_RRI +"
alias   sub="trap_on_V; execute_RRR -"
alias  subu="execute_RRR -"



alias   sll="execute_RRI '<<'"
alias   sra="execute_RRI '>>'"
alias  sllv="execute_RRR '<<'"
alias  srav="execute_RRR '>>'"

alias   srl="execute_srl '>>>'"

alias   and="execute_RRR \&"
alias    or="execute_RRR \|"
alias   xor="execute_RRR ^"
alias   nor="execute_nor \| ~"

alias  andi="execute_RRI \&"
alias   ori="execute_RRI \|"
alias  xori="execute_RRI ^"
alias  nori="nori"                           # command does not exist


alias  mthi="execute_RR mthi move _hi"       # mfhi $t0
alias  mtlo="execute_RR mtlo move _lo"       # mflo $t0


alias  mfhi="reverse_op mthi move _hi"       # mthi $t0
alias  mflo="reverse_op mthi move _lo"       # mtlo $t0

alias   mul="execute_MD mul \*"
alias   div="execute_MD div /"
