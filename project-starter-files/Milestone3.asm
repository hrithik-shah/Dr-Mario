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
INNER_BOTTLE:
    .word 0:408             # stores the grid inside the bottle
CAPSULE:
    .word 0x100081ac:2      # stores the left/top position of capsule first
COLOR_CAPSULE:
    .space 8                # stores the colors of the capsule (left/top then right/bottom)
NEXT_CAPSULE:
    .word 0x100083e8        # stores the position of the next capsule
NEXT_CAPSULE_COLOR:
    .space 8                # stores the colors of the next capsule (top then bottom)
ADDR_KBRD:
    .word 0xffff0000
CENTR_BTTL:
    .word 0x100081ac
TOP_LEFT_BOTTLE:
    .word 0x1000830c

    .text
	.globl 
	
main:
jal initialize_capsule
jal create_next_capsule
jal initialize_viruses
jal draw_border
jal draw_next_capsule

game_loop:      jal draw_inner_screen
                jal clear_bottle_opening
                jal draw_capsule
                
                jal sleep
                
                lw $t0, ADDR_KBRD                       # $t0 = base address for keyboard
                lw $t8, 0($t0)                          # Load first word from keyboard
                beq $t8, 1, handle_keyboard_input       # If first word 1, key is pressed

end_game_loop: b game_loop

exit:
    li $v0, 10              # terminate the program gracefully
    syscall
    
################################# Functions ##################################

############################ Memory Initializers #############################


initialize_capsule:     addi $sp, $sp, -4           # put $ra onto stack
                        sw $ra, 0($sp)
                        jal random_color
                        lw $t4, 0($sp)              # pop return value from stack
                        addi $sp, $sp, 4
                        jal random_color
                        lw $t5, 0($sp)              # pop return value from stack
                        addi $sp, $sp, 4
                        
                        lw $ra, 0($sp)              # restore return address
                        addi $sp, $sp, 4
                        
                        lw $t3, CENTR_BTTL          # $t3 = position of bottle opening
                        
                        la $t7, CAPSULE             # $t7 = location to store position of capsule
                        la $t8, COLOR_CAPSULE       # $t8 = location to colors of capsule
                        sw $t3, 0($t7)              # save top capsule position in memory
                        sw $t4, 0($t8)              # save top capsule color in memory
                        addi $t3, $t3, 128
                        sw $t3, 4($t7)              # save bottom capsule position in memory
                        sw $t5, 4($t8)              # save bottom capsule color in memory
                        
                        jr $ra
                        
initialize_viruses:     addi $sp, $sp, -4                   # save $ra 
                        sw $ra, 0($sp)                      #       on the stack
                        
                        jal generate_random_virus_position  # generate random virus positions
                        jal generate_random_virus_position  # generate random virus positions
                        jal generate_random_virus_position  # generate random virus positions
                        jal generate_random_virus_position  # generate random virus positions
                        
                        lw $s0, 0($sp)                      # $s0 = position offset of virus 0  
                        addi $sp, $sp, 4                                   
                        
                        lw $s1, 0($sp)                      # $s1 = position offset of virus 1
                        addi $sp, $sp, 4                        
                        
                        lw $s2, 0($sp)                      # $s2 = position offset of virus 2 
                        addi $sp, $sp, 4                        
                        
                        lw $s3, 0($sp)                      # $s3 = position offset of virus 3
                        addi $sp, $sp, 4                   
                        
                        jal random_color                    # generate random virus color
                        jal random_color                    # generate random virus color                    
                        jal random_color                    # generate random virus color
                        jal random_color                    # generate random virus color
                        
                        la $t0, INNER_BOTTLE                # $t0 = bottle grid pointer
                        
                        lw $t1, 0($sp)                      # $t1 = color of virus 0
                        addi $sp, $sp, 4            
                        add $s0, $s0, $t0                   # $s0 = position of virus 0
                        sw $t1, 0($s0)                      # save virus 0 color in memory
                        
                        lw $t1, 0($sp)                      # $t1 = color of virus 1
                        addi $sp, $sp, 4            
                        add $s1, $s1, $t0                   # $s1 = position of virus 1
                        sw $t1, 0($s1)                      # save virus 1 color in memory
                        
                        lw $t1, 0($sp)                      # $t1 = color of virus 2
                        addi $sp, $sp, 4            
                        add $s2, $s2, $t0                   # $s2 = position of virus 2
                        sw $t1, 0($s2)                      # save virus 2 color in memory
                        
                        lw $t1, 0($sp)                      # $t1 = color of virus 3
                        addi $sp, $sp, 4            
                        add $s3, $s3, $t0                   # $s3 = position of virus 3
                        sw $t1, 0($s3)                      # save virus 3 color in memory
                        
                        lw $ra, 0($sp)                      # restore $ra
                        addi $sp, $sp, 4                    #       from the stack
                        
                        jr $ra
                        
create_next_capsule:    addi $sp, $sp, -4           # put $ra onto stack
                        sw $ra, 0($sp)
                        jal random_color
                        lw $t4, 0($sp)              # pop return value from stack
                        addi $sp, $sp, 4
                        jal random_color
                        lw $t5, 0($sp)              # pop return value from stack
                        addi $sp, $sp, 4
                        
                        lw $ra, 0($sp)              # restore return address
                        addi $sp, $sp, 4
                        
                        la $t8, NEXT_CAPSULE_COLOR  # $t8 = location to colors of capsule
                        sw $t4, 0($t8)              # save top capsule color in memory
                        sw $t5, 4($t8)              # save bottom capsule color in memory
                        
                        jr $ra 
                        
generate_random_virus_position:     addi $sp, $sp, -4
                                    sw $s0, 0($sp)          # save $s0 on stack
                                    addi $sp, $sp, -4
                                    sw $s1, 0($sp)          # save $s1 on stack
                                    
                                    li $v0, 42              # 42 is system call code to generate random int
                                    li $a0, 0               # $a0 is the lower bound
                                    li $a1, 17              # $a1 is the upper bound
                                    syscall                 # your generated number will be at $a0
                                    sll $s0, $a0, 2         # $s0 = random x offset
                                    
                                    li $v0, 42              # 42 is system call code to generate random int
                                    li $a0, 0               # $a0 is the lower bound
                                    li $a1, 19              # $a1 is the upper bound
                                    syscall                 # your generated number will be at $a0
                                    li $t0, 68              # $t0 = number of cols
                                    mult $a0, $t0
                                    mflo $s1       
                                    addi $s1, $s1, 340       # $s0 = random y offset
                                    
                                    add $t0, $s0, $s1       # $t0 = overall offset
                                    
                                    lw $s1, 0($sp)          # restore $s1 from stack
                                    addi $sp, $sp, 4
                                    lw $s0, 0($sp)          # restore $s0 from stack
                                    
                                    sw $t0, 0($sp)          # save return value on stack

                                    jr $ra
                        
##############################################################################
                        
                        
################################## Drawers ###################################

clear_bottle_opening:   li $t0, 0               # $t0 = black
                        lw $t1, CENTR_BTTL      # $t1 = center of bottle opening
                        
                        # first row
                        sw $t0, -4($t1)
                        sw $t0, 0($t1)
                        sw $t0, 4($t1)
                        
                        # middle row
                        sw $t0, 124($t1)
                        sw $t0, 128($t1)
                        sw $t0, 132($t1)
                        
                        # last row
                        sw $t0, 252($t1)
                        sw $t0, 256($t1)
                        sw $t0, 260($t1)
                        
                        jr $ra

draw_inner_screen:      la $t0, INNER_BOTTLE                    # $t0 = inner screen pointer
                        lw $t1, TOP_LEFT_BOTTLE                 # $t1 = display pointer at top left bottle
                        
                        addi $t2, $t0, 1632                     # $t2 = inner screen end value
draw_inner_screen_loop: beq $t0, $t2, end_draw_inner_screen     # if screen is draw, leave
                        
                        addi $t3, $t0, 68                       # $t3 = row end value
inner_row_loop:         beq $t0, $t3, post_inner_row_loop       # if row is done, go to outer loop
                        
                        lw $t4, 0($t0)                          # $t4 = pixel to be drawn
                        sw $t4, 0($t1)                          # paint pixel onto screen
                        
                        addi $t0, $t0, 4                        # move inner bottle pointer to next position
                        addi $t1, $t1, 4                        # move screen pointer to next position
                        j inner_row_loop
                        
post_inner_row_loop:    addi $t1, $t1, 60                       # set pointer to start of next row
                        j draw_inner_screen_loop
                        
end_draw_inner_screen:  jr $ra
    
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
    
draw_capsule:       la $t0, CAPSULE             # $t0 = array of address of capsule position
                    la $t1, COLOR_CAPSULE       # $t1 = array of address of capsule color
                    lw $t2, 0($t0)              # $t2 = top/left capsule position
                    lw $t3, 4($t0)              # $t3 = bottom/right capsule position
                    lw $t4, 0($t1)              # $t4 = top/left capsule color
                    lw $t5, 4($t1)              # $t5 = bottom/right capsule color
                    sw $t4, 0($t2)              # paint top of capsule
                    sw $t5, 0($t3)              # paint bottom of capsule
                    
                    jr $ra
    
draw_next_capsule:  lw $t0, NEXT_CAPSULE        # $t0 = next capsule top position
                    la $t1, NEXT_CAPSULE_COLOR  # $t1 = array of address of next capsule color
                    lw $t4, 0($t1)              # $t4 = top next capsule color
                    lw $t5, 4($t1)              # $t5 = bottom next capsule color
                    sw $t4, 0($t0)              # paint top of capsule
                    sw $t5, 128($t0)            # paint bottom of capsule
                    
                    jr $ra
    
random_color:
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
    
    jr $ra
    Else2: 
        sw $t1, 0($sp)
    jr $ra
    Else1: 
        sw $t0, 0($sp)
    jr $ra

##############################################################################
                        
                        
############################## Event Handlers ################################

sleep:      li $v0, 32      # $v0 = system call for sleeping
            li $a0, 66      # $a0 = time (in milliseconds) to sleep
            syscall         # sleep
            jr $ra

handle_keyboard_input:      addi $sp, $sp, -4               # save 
                            sw $ra, 0($sp)                  #   return address

                            lw $a0, 4($t0)                  # Load second word from keyboard
                            beq $a0, 0x71, exit             # Check if the key q was pressed
                            beq $a0, 0x61, a_key_press
                            beq $a0, 0x64, d_key_press
                            beq $a0, 0x73, s_key_press
                            beq $a0, 0x77, w_key_press
                            
                            # li $v0, 1                       # ask system to print $a0
                            # syscall
                            
end_handle_keyboard_input:  lw $ra, 0($sp)                  # restore
                            addi $sp, $sp, 4                #   return address
                            jr $ra

a_key_press:        la $t0, CAPSULE                 # $t0 = capsule position pointers
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
                    
end_a_key_press:    j end_handle_keyboard_input

d_key_press:        la $t0, CAPSULE                 # $t0 = capsule position pointers
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
                    
end_d_key_press:    j end_handle_keyboard_input

s_key_press:        la $t0, CAPSULE                 # $t0 = capsule position pointers
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
                    
end_s_key_press:    j end_handle_keyboard_input

w_key_press:        la $t0, CAPSULE                 # $t0 = capsule position pointers
                    lw $t2, 0($t0)                  # $t2 = top/left position
                    lw $t3, 4($t0)                  # $t3 = bottom/right position
                    
                    subu $t4, $t3, $t2
                    b1: bne $t4, 128, b1_else                   # if capsule is verticle
                        addi $t5, $t3, 4                        # $t5 = position to the right of capsule
                        lw $t5, 0($t5)                          # $t5 = color at position to the right of capsule
                        bne $t5, $zero, w_key_press_end         # if there if no space to rotate, then exit function
                    
                        la $t1, COLOR_CAPSULE           # $t1 = capsule color pointers
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
w_key_press_end:    j end_handle_keyboard_input
