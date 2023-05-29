assign_data_label A
allocate_data_memory 1
assign_data_label B
allocate_data_memory 1
assign_data_label C
allocate_data_memory 1
assign_data_label D
allocate_data_memory 1

assign_data_label AA
allocate_data_memory 2
assign_data_label BB
allocate_data_memory 2
assign_data_label CC
allocate_data_memory 2
assign_data_label DD
allocate_data_memory 2


assign_data_label AAAA
allocate_data_memory 4
assign_data_label BBBB
allocate_data_memory 4
assign_data_label CCCC
allocate_data_memory 4
assign_data_label DDDD
allocate_data_memory 4
list_labels

li $t0, 4
li $t1, 8
la $s0, A
la $s1, B
la $s2, C
sb $t0, $s0, 0    #A = 4
sb $t1, $s1, 0    #B = 8
lb $t2, $s0, 0 
lb $t3, $s1, 0
add $t4, $t2, $t3
sb $t4, $s2, 0    #C = 12

li $t0, 4
li $t1, 8
la $s0, AA
la $s1, BB
la $s2, CC
sh $t0, $s0, 0    #A = 4
sh $t1, $s1, 0    #B = 8
lh $t2, $s0, 0 
lh $t3, $s1, 0
add $t4, $t2, $t3
sh $t4, $s2, 0    #C = 12


li $t0, 4
li $t1, 8
la $s0, AAAA
la $s1, BBBB
la $s2, CCCC
sw $t0, $s0, 0    #A = 4
sw $t1, $s1, 0    #B = 8
lw $t2, $s0, 0 
lw $t3, $s1, 0
add $t4, $t2, $t3
sw $t4, $s2, 0    #C = 12

print_data_memory
