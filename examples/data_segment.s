        .data
        .asciiz "This is a string\n"
        .word  0xDEFACE00
A:      .byte  0xAA
B:      .byte  0xBB
C:      .byte  0xCC
D:      .byte  0xDD
F:      .byte  0xFF
H1:     .half  0x0101 
H2:     .half  0x0202
H3:     .half  0x0303
SPACE:  .space 1
DEFACE: .word  0xDEFACE00 

AA: .half 24
BB: .half 24
CC: .half 24
DD: .half 24


AAAA: .word 48
BBBB: .word 48
CCCC: .word 48
DDDD: .word 48
#list_labels


print_memory
