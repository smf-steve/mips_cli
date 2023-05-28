assign_data_label A
allocate_data_memory 4
assign_data_label B
allocate_data_memory 4
assign_data_label C
allocate_data_memory 4
list_labels

li $t1, 4
la $t2, A
sw $t1, $t2, 4   # writes to B old style for now
