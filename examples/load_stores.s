assign_label data A
allocate_data 4
assign_label data B
allocate_data 4
assign_label data C
allocate_data 4
print_labels

li $t1, 4
la $t2, A
sw $t1, 4 ($t2)    # writes to B
