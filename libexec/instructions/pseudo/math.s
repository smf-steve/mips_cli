.pseudo subi %dst, %src1, %src2
    addi $at, $zero, %src2
    sub %dst, %src1, $at          
.end_pseudo


.pseudo mul %dst, %src1, %src2
   mult %src1, %src2
   mflo %dst
.end_pseudo

.pseudo div %dst, %src1, %src2   # Presume %src2 is not zero
     bne %src, $zero, 4    ## look no label
       break   
     div %src1, %src2    
     mflo %dst
.end_pseudo

.pseudo divu %dst, %src1, %src2   # Unsigned remainder
     bne %src, $zero, 4    ## look no label
       break   
     divu %src1, %src2    
     mflo %dst
.end_pseudo

.pseudo rem %dst, %src1, %src2   # Presume %src2 is not zero
     bne %src, $zero, 4    ## look no label
       break   
     div %src1, %src2    
     mfhi %dst
.end_pseudo

.pseudo remu %dst, %src1, %src2   # Unsigned remainder
     bne %src, $zero, 4    ## look no label
       break   
     divu %src1, %src2    
     mfhi %dst
.end_pseudo


.pseudo abs %dst, %src 
     sra $at, %src, 31       # $at is either 0, or -1
     xor %dst, $at, %src     # %dst is either x or x-1
     subu %dst, %dst, $at    # either x + 0 or (x - 1) -1 
.end_pseudo


.pseudo not %dst, %src           
    nor %dst, %src, $zero
.end_pseudo


.pseudo mulo %dst, %src1, %src2     # Multiply (with overflow)
    mult %src1, %src2   
    mfhi $at 
    mflo %dst    
    sra %dst, %dst, 31    
    beq $at, %dst, 4
      break   
    mflo %dst
.end_pseudo

.pseudo mulou %dst, %src1, %src2    # Divide (without overflow)
    echo Not Implemented
.end_pseudo


.pseudo neg %dst, %src             # Negate value (with overflow)
    subu %dst, $zero, %src         # Note the MARS implements this as a sub, but a V trap will occur
.end_pseudo


.pseudo negu %dst, %src            # Negate value (without overflow)
    subu %dst, $zero, %src 
.end_pseudo


