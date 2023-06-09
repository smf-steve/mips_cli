
ENDIANNESS="LITTLE"

text_start=0x00400000          ; text_next=$text_start
text_end=0x0FFFFFFF

data_start=0x10010000          ; data_next=$data_start
data_end=0x1003FFFF

heap_start=$((data_end + 1))   ; heap_next=$(( heap_start + 4 ))
heap_end='HEAP[${heap_start}]' # Note: value has to be determined dynamically

HEAP[${heap_start}]=${heap_next}  
   # Free Pointer is positioned as the first element of the heap


stack_start=0x7FFFFFFF        ; stack_next=$stack_start   # does this point to the top element or?
#stack_end='$(rval $fp)'      # Note: value has to be determined dynamically

STACK[${stack_start}]=0xDEADBEAF
#assign $fp ${stark_start}
   # A "deadbeaf" value is stored on top of the stack!
