
.pseudo subi %dst, %src1, %src2
    addi $at, $zero, %src2
    sub %dst, %src1, $at          
.end_pseudo


.pseudo mul %rdst, %rsrc1, %src2
   mult %rsrc1, %src2
   mflo %rdst
.end_pseudo

.pseudo div %dst, %src1, %src2   # Presume %src2 is not zero
     bne %src, $zero, 4    ## look no label
       break   
     div %src1, %src2    
     mflo %dst
.end_pseudo


.pseudeo divu %rdst, %rsrc1, %rsrc2   # Unsigned remainder
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


.pseudeo remu %rdst, %rsrc1, %rsrc2   # Unsigned remainder
     bne %src, $zero, 4    ## look no label
       break   
     divu %src1, %src2    
     mfhi %dst
.end_pseudo


#
.pseudo abs %rdst, %rsrc 
     sra $at, %rsrc, 31        # $at is either 0, or -1
     xor %rdst, $at, %rsrc     # %rdst is either x or x-1
     subu %rdst, %rdst, $at    # either x + 0 or (x - 1) -1 
.end_pseudo


#
.pseudo not %rdst, %rsrc           # Not
    nor %rdst, %rsrc, $0
.end_pseudo



#
.pseudo mulo %rdst, %rsrc1, %src2     # Multiply (with overflow)
    mult %rsrc1, %src2   
    mfhi $at 
    mflo %rdst    
    sra %rdst, %rdst, 31    
    beq $at, %rdst, 4
      break   
    mflo %rdst
.end_pseudo


#
.pseudo mulou %rdst, %rsrc1, %src2    # Divide (without overflow)
    echo Not Implemented
.end_pseudo


#
.pseudo neg %rdst, %rsrc             # Negate value (with overflow)
    sub %rdst, $0, %rsrc 
.end_pseudo


#
.pseudo negu %rdst, %rsrc            # Negate value (without overflow)
    subu %rdst, $0, %rsrc 
.end_pseudo


