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
ADDR_CAPSULE:
    .word 0x100081ac:2      # stores the left/top position of capsule first
ADDR_COLOR_CAPSULE:
    .space 8                # stores the colors of the capsule (left/top then right/bottom)
ADDR_KBRD:
    .word 0xffff0000
CENTR_BTTL:
    .word 0x100081ac

    .text
	.globl 
	
main:
jal initialize_capsule

game_loop:      jal reset_screen
                jal draw_border
                jal draw_capsule
                
                # jal check_keyboard_input                # TODO
                lw $t0, ADDR_KBRD                       # $t0 = base address for keyboard
                lw $t8, 0($t0)                          # Load first word from keyboard
                beq $t8, 1, handle_keyboard_input       # If first word 1, key is pressed
                
                li $v0, 32
                li $a0, 66
                syscall

end_game_loop: b game_loop

exit:
    li $v0, 10              # terminate the program gracefully
    syscall
    
    
############# Functions #############

initialize_capsule:     addi $sp, $sp, -4           # put $ra onto stack
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
                        
                        la $t7, ADDR_CAPSULE        # $t7 = location to store position of capsule
                        la $t8, ADDR_COLOR_CAPSULE  # $t8 = location to colors of capsule
                        sw $t3, 0($t7)              # save top capsule position in memory
                        sw $t4, 0($t8)              # save top capsule color in memory
                        addi $t3, $t3, 128
                        sw $t3, 4($t7)              # save bottom capsule position in memory
                        sw $t5, 4($t8)              # save bottom capsule color in memory
                        
                        jr $ra
    
reset_screen:       lw $t0, ADDR_DSPL       # $t0 = start position
    
                    lw $t1, ADDR_DSPL
                    addi $t1, $t1, 4096     # $t1 = end position 
                    
                    reset_loop: beq $t0, $t1, end_reset_screen
                        sw $zero, 0($t0)    # set color to black at position $t0
                        addi $t0, $t0, 4    # $t0 = next position
                        j reset_loop
end_reset_screen:   jr $ra
    
draw_border:        lw $t0, ADDR_DSPL                   # $t0 = base address for display
                    li $t1, 128                         # $t1 = row delta
                    li $t2, 0x808080                    # $t2 = border color
                    
                    addi $t3, $t0, 648                  # $t3 = current left position
                    addi $t4, $t0, 3976                 # $t4 = end left position
                    left: beq $t3, $t4, end_left
                        sw $t2, 0($t3)
                        addu $t3, $t3, $t1
                        j left
                    end_left:
                    
                    addi $t3, $t0, 720                  # $t3 = current right position
                    addi $t4, $t0, 4048                 # $t4 = end right position
                    right: beq $t3, $t4, end_right
                        sw $t2, 0($t3)
                        addu $t3, $t3, $t1
                        j right
                    end_right:
                    
                    li $t1, 4                           # $t1 = column delta
                    addi $t3, $t0, 3848                 # $t3 = current bottom position
                    addi $t4, $t0, 3924                 # $t4 = end bottom position
                    bottom: beq $t3, $t4, end_bottom
                        sw $t2, 0($t3)
                        addu $t3, $t3, $t1
                        j bottom
                    end_bottom:
                    
                    addi $t3, $t0, 648                  # $t3 = current bottom position
                    addi $t4, $t0, 724                  # $t4 = end bottom position
                    top: beq $t3, $t4, end_top
                        sw $t2, 0($t3)
                        addu $t3, $t3, $t1
                        j top
                    end_top:
                    
                    bottle_opening:
                        addi $t3, $t0, 420
                        sw $t2, 0($t3)
                        sw $t2, 128($t3)
                        sw $t2, 16($t3)
                        sw $t2, 144($t3)
                        
                        li $t2, 0x000000                # $t2 = black
                        addi $t3, $t0, 680
                        sw $t2, 0($t3)
                        sw $t2, 4($t3)
                        sw $t2, 8($t3)
                    
                    jr $ra
    
draw_capsule:
    la $t0, ADDR_CAPSULE        # $t0 = array of address of capsule position
    la $t1, ADDR_COLOR_CAPSULE  # $t1 = array of address of capsule color
    lw $t2, 0($t0)              # $t2 = top/left capsule position
    lw $t3, 4($t0)              # $t3 = bottom/right capsule position
    lw $t4, 0($t1)              # $t4 = top/left capsule color
    lw $t5, 4($t1)              # $t5 = bottom/right capsule color
    sw $t4, 0($t2)              # paint top of capsule
    sw $t5, 0($t3)              # paint bottom of capsule
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

handle_keyboard_input:
    lw $a0, 4($t0)                  # Load second word from keyboard
    beq $a0, 0x71, exit             # Check if the key q was pressed
    beq $a0, 0x61, a_key_press
    beq $a0, 0x64, d_key_press
    beq $a0, 0x73, s_key_press
    beq $a0, 0x77, w_key_press

    li $v0, 1                       # ask system to print $a0
    syscall
    b game_loop
end_handle_keyboard_input:

a_key_press:        la $t0, ADDR_CAPSULE            # $t0 = capsule position pointers
                    lw $t2, 0($t0)                  # $t2 = top/left position
                    lw $t3, 4($t0)                  # $t3 = bottom/right position
                    
                    subu $t4, $t3, $t2
                    a_key_branch_vertical: bne $t4, 128, a_key_branch_horizontal       # if capsule is verticle
                        addi $t4, $t2, -4                                               # $t4 = position to the top left of capsule
                        addi $t5, $t3, -4                                               # $t5 = position to the bottom left of capsule
                        lw $t4, 0($t4)                                                  # $t4 = color at position to the top left of capsule
                        lw $t5, 0($t5)                                                  # $t5 = color at position to the bottom left of capsule
                        bne $t4, $zero, end_a_key_press                                 # if there if no space to move,
                        bne $t5, $zero, end_a_key_press                                 #       then exit function

                        addi $t2, $t2, -4               # $t2 = new top position of capsule
                        addi $t3, $t3, -4               # $t3 = new bottom position of capsule
                        
                        sw $t2, 0($t0)                  # save new top position
                        sw $t3, 4($t0)                  # save new bottom position
                        
                        j end_a_key_press
                    a_key_branch_horizontal:                   # else capsule is horizontal
                        addi $t4, $t2, -4                       # $t4 = position to the left of capsule
                        lw $t4, 0($t4)                          # $t4 = color at position to the left of capsule
                        bne $t4, $zero, end_a_key_press         # if there if no space to move, then exit function

                        addi $t2, $t2, -4               # $t2 = new left position of capsule
                        addi $t3, $t3, -4               # $t3 = new right position of capsule
                        
                        sw $t2, 0($t0)                  # save new left position
                        sw $t3, 4($t0)                  # save new right position
                    
end_a_key_press:    jr $ra

d_key_press:        la $t0, ADDR_CAPSULE            # $t0 = capsule position pointers
                    lw $t2, 0($t0)                  # $t2 = top/left position
                    lw $t3, 4($t0)                  # $t3 = bottom/right position
                    
                    subu $t4, $t3, $t2
                    d_key_branch_vertical: bne $t4, 128, d_key_branch_horizontal       # if capsule is verticle
                        addi $t4, $t2, 4                                                # $t4 = position to the top right of capsule
                        addi $t5, $t3, 4                                                # $t5 = position to the bottom right of capsule
                        lw $t4, 0($t4)                                                  # $t4 = color at position to the top right of capsule
                        lw $t5, 0($t5)                                                  # $t5 = color at position to the bottom right of capsule
                        bne $t4, $zero, end_d_key_press                                 # if there if no space to move,
                        bne $t5, $zero, end_d_key_press                                 #       then exit function

                        addi $t2, $t2, 4                # $t2 = new top position of capsule
                        addi $t3, $t3, 4                # $t3 = new bottom position of capsule
                        
                        sw $t2, 0($t0)                  # save new top position
                        sw $t3, 4($t0)                  # save new bottom position
                        
                        j end_d_key_press
                    d_key_branch_horizontal:                   # else capsule is horizontal
                        addi $t4, $t3, 4                        # $t4 = position to the right of capsule
                        lw $t4, 0($t4)                          # $t4 = color at position to the right of capsule
                        bne $t4, $zero, end_d_key_press         # if there if no space to move, then exit function

                        addi $t2, $t2, 4                # $t2 = new left position of capsule
                        addi $t3, $t3, 4                # $t3 = new right position of capsule
                        
                        sw $t2, 0($t0)                  # save new left position
                        sw $t3, 4($t0)                  # save new right position
                    
end_d_key_press:    jr $ra

s_key_press:        la $t0, ADDR_CAPSULE            # $t0 = capsule position pointers
                    lw $t2, 0($t0)                  # $t2 = top/left position
                    lw $t3, 4($t0)                  # $t3 = bottom/right position
                    
                    subu $t4, $t3, $t2
                    s_key_branch_vertical: bne $t4, 128, s_key_branch_horizontal        # if capsule is verticle
                        addi $t4, $t3, 128                                              # $t4 = position below the capsule
                        lw $t4, 0($t4)                                                  # $t4 = color at position below the capsule
                        bne $t4, $zero, end_s_key_press                                 # if there if no space to move, then exit function

                        addi $t2, $t2, 128              # $t2 = new top position of capsule
                        addi $t3, $t3, 128              # $t3 = new bottom position of capsule
                        
                        sw $t2, 0($t0)                  # save new top position
                        sw $t3, 4($t0)                  # save new bottom position
                        
                        j end_s_key_press
                    s_key_branch_horizontal:                    # else capsule is horizontal
                        addi $t4, $t2, 128                      # $t4 = position below the left capsule
                        addi $t5, $t3, 128                      # $t5 = position below the right capsule
                        lw $t4, 0($t4)                          # $t4 = color at position below the left capsule
                        lw $t5, 0($t5)                          # $t5 = color at position below the right capsule
                        bne $t4, $zero, end_s_key_press         # if there if no space to move,
                        bne $t5, $zero, end_s_key_press         #       then exit function

                        addi $t2, $t2, 128              # $t2 = new left position of capsule
                        addi $t3, $t3, 128              # $t3 = new right position of capsule
                        
                        sw $t2, 0($t0)                  # save new left position
                        sw $t3, 4($t0)                  # save new right position
                    
end_s_key_press:    jr $ra

w_key_press:        la $t0, ADDR_CAPSULE            # $t0 = capsule position pointers
                    lw $t2, 0($t0)                  # $t2 = top/left position
                    lw $t3, 4($t0)                  # $t3 = bottom/right position
                    
                    subu $t4, $t3, $t2
                    b1: bne $t4, 128, b1_else                   # if capsule is verticle
                        addi $t5, $t3, 4                        # $t5 = position to the right of capsule
                        lw $t5, 0($t5)                          # $t5 = color at position to the right of capsule
                        bne $t5, $zero, w_key_press_end         # if there if no space to rotate, then exit function
                    
                        la $t1, ADDR_COLOR_CAPSULE      # $t1 = capsule color pointers
                        lw $t5, 0($t1)                  # $t5 = top color
                        lw $t6, 4($t1)                  # $t6 = bottom color
                        
                        addi $t2, $t2, 132              # $t2 = new right position for capsule
                        sw $t3, 0($t0)                  # save new left position
                        sw $t6, 0($t1)                  # save new left color
                        sw $t2, 4($t0)                  # save new right position
                        sw $t5, 4($t1)                  # save new right color
                        
                        j w_key_press_end
                    b1_else:                                    # else capsule is horizontal
                        subi $t5, $t2, 128                      # $t5 = position to the top of capsule
                        lw $t5, 0($t5)                          # $t5 = color at position to the top of capsule
                        bne $t5, $zero, w_key_press_end         # if there if no space to rotate, then exit function
                        
                        move $t3, $t2               # $t3 = new bottom position for capsule
                        subi $t2, $t2, 128          # $t2 = new top position for capsule
                        sw $t2, 0($t0)              # save new top position
                        sw $t3, 4($t0)              # save new bottom position
w_key_press_end:    jr $ra