assign_data_label A 4
assign_data_label B 4
assign_data_label C 2

li $t1, 4
la $t2, A
sw $t1, 4($t2)    # writes to B

alias data_label_A
alias data_label_B
alias data_label_C
