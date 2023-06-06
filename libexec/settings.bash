
ENDIANNESS="LITTLE"

text_start=0x00400000
text_next=$text_start
text_end=0x0FFFFFFF

data_start=0x10010000
data_next=$data_start
data_end=0x1003FFFF

heap_start=$((data_end + 1))
heap_ptr_address=$heap_start
heap_next=$heap_start+4
MEM[$heap_ptr_address]=$heap_next;

stack_top=0x7FFFFFFF
# $sp = stack_top    # does this point to the top element or
# the program args shojuld be placed here
