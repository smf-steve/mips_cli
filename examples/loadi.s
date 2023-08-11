        .text

        li $t1, 0xAAAA    # Should be 0xFFFFAAAA
        li $t2, 0x7FFF    # Should be 0x7FFF
        lui $t2, 0x7FFF   # Should be 0x7FFF0000
        llo $t3, 0xBEEF
        lhi $t3, 0xDEAD   # $t3 should be 0xDEAD_BEAF
        llo $t3, 0xBEEF   # $t3 should be 0xDEAD_BEAF
