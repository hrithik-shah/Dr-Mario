##############################################################################
# Example: Displaying Pixels
#
# This file demonstrates how to draw pixels with different colours to the
# bitmap display.
##############################################################################

######################## Bitmap Display Configuration ########################
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
##############################################################################
    .data
ADDR_DSPL:
    .word 0x10008000
CENTR_BTTL:
    .word 0x100081ac

    .text
	.globl 
	
main:
jal DrawBorder
    
jal InitializeCapsule
    
exit:
    li $v0, 10              # terminate the program gracefully
    syscall
    
    
############# Functions #############
    
DrawBorder:
    lw $t0, ADDR_DSPL       # $t0 = base address for display
    li $t1, 128             # $t1 = row delta
    li $t2, 0x808080        # $t2 = border color
    
    addi $t3, $t0, 648          # $t3 = current left position
    addi $t4, $t0, 3976         # $t4 = end left position
    left: beq $t3, $t4, end_left
        sw $t2, 0($t3)
        addu $t3, $t3, $t1
        j left
    end_left:
    
    addi $t3, $t0, 720          # $t3 = current right position
    addi $t4, $t0, 4048         # $t4 = end right position
    right: beq $t3, $t4, end_right
        sw $t2, 0($t3)
        addu $t3, $t3, $t1
        j right
    end_right:
    
    li $t1, 4                    # $t1 = column delta
    addi $t3, $t0, 3848          # $t3 = current bottom position
    addi $t4, $t0, 3924          # $t4 = end bottom position
    bottom: beq $t3, $t4, end_bottom
        sw $t2, 0($t3)
        addu $t3, $t3, $t1
        j bottom
    end_bottom:
    
    addi $t3, $t0, 648          # $t3 = current bottom position
    addi $t4, $t0, 724          # $t4 = end bottom position
    top: beq $t3, $t4, end_top
        sw $t2, 0($t3)
        addu $t3, $t3, $t1
        j top
    end_top:
    
    addi $t3, $t0, 420
    sw $t2, 0($t3)
    sw $t2, 128($t3)
    sw $t2, 16($t3)
    sw $t2, 144($t3)
    
    li $t2, 0x000000            # $t2 = black
    addi $t3, $t0, 680
    sw $t2, 0($t3)
    sw $t2, 4($t3)
    sw $t2, 8($t3)
    
    jr $ra
   
InitializeCapsule:
    addi $sp, $sp, -4           # put $ra onto stack
    sw $ra, 0($sp)
    
    jal RandomColor
    lw $t4, 0($sp)              # pop return value from stack
    addi $sp, $sp, 4
    jal RandomColor
    lw $t5, 0($sp)              # pop return value from stack
    addi $sp, $sp, 4
    
    lw $ra, 0($sp)              # restore return address
    addi $sp, $sp, 4
    
    lw $t3, CENTR_BTTL          # $t3 = position of bottle opening
    sw $t4, 0($t3)              # paint top of capsule
    sw $t5, 128($t3)            # paint bottom of capsule
    jr $ra
    
RandomColor:
    li $t0, 0xff0000            # $t0 = red
    li $t1, 0xffff00            # $t1 = yellow
    li $t2, 0x0000ff            # $t2 = blue
    
    li $v0, 42                  # 42 is system call code to generate random int
    li $a0, 0                   # $a0 is the lower bound
    li $a1, 3                   # $a1 is the upper bound
    syscall                     # your generated number will be at $a0
    
    addi $sp, $sp, -4
    beq $a0, 0, Else1
    beq $a0, 1, Else2
    sw $t2, 0($sp)
    j EndRandomColor
    Else2: 
        sw $t1, 0($sp)
        j EndRandomColor
    Else1: 
        sw $t0, 0($sp)
EndRandomColor: jr $ra