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
    .word 0x100083e4        # stores the position of the next capsule
NEXT_CAPSULE_COLOR:
    .space 8                # stores the colors of the next capsule (top then bottom)
ADDR_KBRD:
    .word 0xffff0000
CENTR_BTTL:
    .word 0x10008124
INITIAL_CAPSULE_POSITION:
    .word 0x1000832c
INNER_BOTTLE_INITIAL_CAPSULE_POSITION:
    .space 4
TOP_LEFT_BOTTLE:
    .word 0x10008304
RED:
    .word 0x00ff0000
YELLOW:
    .word 0x00ffff00
BLUE:
    .word 0x000000ff
LIGHT_PINK:
    .word 0x00ff80a0
ORANGE:
    .word 0x00ff9000
LIGHT_BLUE:
    .word 0x008888ff
SCORE_POSITION:
    .word 0x10008cd0
SCORE:
    .word 0x00000000
GAME_LOOP_COUNT:
    .word 0x00000000
DR_MARIO_POSITION:
    .word 0x10008550
RED_VIRUS_POSITION:
    .word 0x10008a5c
YELLOW_VIRUS_POSITION:
    .word 0x10008ae4
BLUE_VIRUS_POSITION:
    .word 0x10008a6c
FALLING_SPEED:
    .word 0xf
    
    .text
	.globl 
	
main:
jal initialize_capsule
# jal initialize_inner_bottle
jal create_next_capsule
jal initialize_viruses
jal draw_border
jal draw_dr_mario
jal draw_viruses
jal initialize_score

game_loop:      jal draw_next_capsule
                jal draw_inner_screen
                jal clear_bottle_opening
                jal clear_score_from_display
                jal draw_score
                jal draw_capsule
                
                jal sleep
                
                jal update_falling_speed
                jal make_capsule_fall
                jal update_game_loop_count
                
                jal handle_keyboard_input
                
                jal handle_capsule_bottom_collision     # checks if the current capsule has hit something
                lw $t0, 0($sp)                          # $t0 = return value (updated) from handle_capsule_bottom_collision
                
                sw $t0, 0($sp)                          # set argument for update_inner_bottle_state
                jal update_inner_bottle_state           # checks for 4 or more blocks, deletes, does gravity, and repeats
                
                jal handle_virus_deletion
                
                b game_loop

exit:
    li $v0, 10              # terminate the program gracefully
    syscall
    
################################# Functions ##################################

############################ Memory Initializers #############################


initialize_capsule:         addi $sp, $sp, -4                           # put $ra onto stack
                            sw $ra, 0($sp)
                            jal random_color
                            lw $t4, 0($sp)                              # pop return value from stack
                            addi $sp, $sp, 4
                            jal random_color
                            lw $t5, 0($sp)                              # pop return value from stack
                            addi $sp, $sp, 4
                            
                            lw $ra, 0($sp)                              # restore return address
                            addi $sp, $sp, 4
                            
                            lw $t3, CENTR_BTTL                          # $t3 = position of bottle opening
                            
                            la $t7, CAPSULE                             # $t7 = location to store position of capsule
                            la $t8, COLOR_CAPSULE                       # $t8 = location to colors of capsule
                            sw $t3, 0($t7)                              # save top capsule position in memory
                            sw $t4, 0($t8)                              # save top capsule color in memory
                            addi $t3, $t3, 128
                            sw $t3, 4($t7)                              # save bottom capsule position in memory
                            sw $t5, 4($t8)                              # save bottom capsule color in memory
                            
                            jr $ra
                        
initialize_inner_bottle:    # save the initial capsule position on inner bottle
                            la $t0, INNER_BOTTLE
                            addi $t0, $t0, 32
                            la $t1, INNER_BOTTLE_INITIAL_CAPSULE_POSITION
                            sw $t0, 0($t1)
                            
                            jr $ra
                        
initialize_viruses:         addi $sp, $sp, -4                   # save $ra 
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
                            
                            jal random_virus_color              # generate random virus color
                            
                            la $t0, INNER_BOTTLE                # $t0 = bottle grid pointer
                            
                            lw $t1, 0($sp)                      # $t1 = color of virus 0
                            addi $sp, $sp, 4            
                            add $s0, $s0, $t0                   # $s0 = position of virus 0
                            sw $t1, 0($s0)                      # save virus 0 color in memory
                            
                            lw $t1, LIGHT_PINK                  # $t1 = color of virus 1
                            add $s1, $s1, $t0                   # $s1 = position of virus 1
                            sw $t1, 0($s1)                      # save virus 1 color in memory
                            
                            lw $t1, ORANGE                      # $t1 = color of virus 2
                            add $s2, $s2, $t0                   # $s2 = position of virus 2
                            sw $t1, 0($s2)                      # save virus 2 color in memory
                            
                            lw $t1, LIGHT_BLUE                  # $t1 = color of virus 3
                            add $s3, $s3, $t0                   # $s3 = position of virus 3
                            sw $t1, 0($s3)                      # save virus 3 color in memory
                            
                            lw $ra, 0($sp)                      # restore $ra
                            addi $sp, $sp, 4                    #       from the stack
                            
                            jr $ra
                        
create_next_capsule:        addi $sp, $sp, -4           # put $ra onto stack
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
                                    
initialize_score:                   jr $ra
                        
##############################################################################
                        
                        
################################## Drawers ###################################

clear_bottle_opening:   li $t0, 0               # $t0 = black
                        lw $t1, CENTR_BTTL      # $t1 = center of bottle opening
                        
                        # first row
                        sw $t0, -4($t1)
                        sw $t0, 0($t1)
                        sw $t0, 4($t1)
                        
                        # second row
                        sw $t0, 124($t1)
                        sw $t0, 128($t1)
                        sw $t0, 132($t1)
                        
                        # third row
                        sw $t0, 252($t1)
                        sw $t0, 256($t1)
                        sw $t0, 260($t1)
                        
                        # fourth row
                        sw $t0, 380($t1)
                        sw $t0, 384($t1)
                        sw $t0, 388($t1)
                        
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
    
                    addi $t1, $t0, 4096     # $t1 = end position 
                    
                    reset_loop: beq $t0, $t1, end_reset_screen
                        sw $zero, 0($t0)    # set color to black at position $t0
                        addi $t0, $t0, 4    # $t0 = next position
                        j reset_loop
end_reset_screen:   jr $ra

draw_dr_mario:          lw $t0, DR_MARIO_POSITION       # $t0 = position of mario on display

                        # draw skin
                        li $t1, 0xfeb46b                # $t1 = peach color
                        
                        sw $t1, 640($t0)
                        sw $t1, 644($t0)
                        sw $t1, 516($t0)
                        sw $t1, 648($t0)
                        sw $t1, 520($t0)
                        sw $t1, 524($t0)
                        sw $t1, 396($t0)
                        sw $t1, 656($t0)
                        
                        sw $t1, 404($t0)
                        sw $t1, 408($t0)
                        sw $t1, 532($t0)
                        sw $t1, 536($t0)
                        sw $t1, 540($t0)
                        sw $t1, 660($t0)
                        sw $t1, 664($t0)
                        
                        sw $t1, 788($t0)
                        sw $t1, 792($t0)
                        sw $t1, 796($t0)
                        sw $t1, 800($t0)
                        
                        sw $t1, 904($t0)
                        sw $t1, 908($t0)
                        sw $t1, 912($t0)
                        sw $t1, 916($t0)
                        sw $t1, 920($t0)
                        sw $t1, 924($t0)
                        sw $t1, 928($t0)
                        
                        sw $t1, 548($t0)
                        sw $t1, 676($t0)
                        
                        # draw mousestach
                        li $t1, 0x30140c                # $t1 = dark brown color
                        
                        sw $t1, 772($t0)
                        sw $t1, 776($t0)
                        sw $t1, 780($t0)
                        sw $t1, 784($t0)
                        
                        sw $t1, 652($t0)
                        
                        # draw eyes
                        li $t1, 0x000000                # $t1 = dark black color
                        
                        sw $t1, 528($t0)
                        sw $t1, 400($t0)
                        
                        # draw hair
                        li $t1, 0x8b7216                # $t1 = some dirty color for hair
                        
                        sw $t1, 8($t0)
                        sw $t1, 136($t0)
                        
                        sw $t1, 148($t0)
                        sw $t1, 152($t0)
                        sw $t1, 156($t0)
                        sw $t1, 160($t0)
                        
                        sw $t1, 412($t0)
                        sw $t1, 416($t0)
                        sw $t1, 420($t0)
                        sw $t1, 544($t0)
                        sw $t1, 672($t0)
                        sw $t1, 668($t0)
                        
                        sw $t1, 552($t0)
                        sw $t1, 680($t0)
                        sw $t1, 808($t0)
                        sw $t1, 804($t0)
                        
                        # draw headband
                        li $t1, 0x0854bc                    # $t1 = blue   
                        
                        sw $t1, 276($t0)
                        sw $t1, 280($t0)
                        sw $t1, 284($t0)
                        sw $t1, 288($t0)
                        sw $t1, 292($t0)
                        
                        li $t1, 0xd5d5d5                    # $t1 = grey   
                        
                        sw $t1, 272($t0)
                        sw $t1, 144($t0)
                        
                        li $t1, 0xfefefe                    # $t1 = light grey   
                        
                        sw $t1, 268($t0)
                        sw $t1, 140($t0)
                            
                        jr $ra
                        
draw_viruses:           lw $t0, RED_VIRUS_POSITION
                        lw $t1, LIGHT_PINK
                        sw $t1, 0($t0)                      # draw red virus
                        
                        lw $t0, YELLOW_VIRUS_POSITION
                        lw $t1, ORANGE
                        sw $t1, 0($t0)                      # draw yellow virus
                        
                        lw $t0, BLUE_VIRUS_POSITION
                        lw $t1, LIGHT_BLUE
                        sw $t1, 0($t0)                      # draw blue virus
                        
                        jr $ra
    
draw_border:        lw $t0, TOP_LEFT_BOTTLE             # $t0 = address pointer to top left of bottle
                    li $t1, 128                         # $t1 = row delta
                    li $t2, 0x808080                    # $t2 = border color
                    
                    addi $t3, $t0, -132                 # $t3 = current left position
                    addi $t4, $t3, 3328                 # $t4 = end left position
                    left: beq $t3, $t4, end_left
                        sw $t2, 0($t3)
                        addu $t3, $t3, $t1
                        j left
                    end_left:
                    
                    addi $t3, $t0, -60                  # $t3 = current right position
                    addi $t4, $t3, 3328                 # $t4 = end right position
                    right: beq $t3, $t4, end_right
                        sw $t2, 0($t3)
                        addu $t3, $t3, $t1
                        j right
                    end_right:
                    
                    li $t1, 4                           # $t1 = column delta
                    addi $t3, $t0, 3068                 # $t3 = current bottom position
                    addi $t4, $t3, 76                   # $t4 = end bottom position
                    bottom: beq $t3, $t4, end_bottom
                        sw $t2, 0($t3)
                        addu $t3, $t3, $t1
                        j bottom
                    end_bottom:
                    
                    addi $t3, $t0, -132                 # $t3 = current bottom position
                    addi $t4, $t3, 76                   # $t4 = end bottom position
                    top: beq $t3, $t4, end_top
                        sw $t2, 0($t3)
                        addu $t3, $t3, $t1
                        j top
                    end_top:
                    
                    bottle_opening:
                        lw $t3, CENTR_BTTL
                        sw $t2, 120($t3)
                        sw $t2, 136($t3)
                        sw $t2, 248($t3)
                        sw $t2, 264($t3)
                        
                        li $t2, 0x000000                # $t2 = black
                        sw $t2, 380($t3)
                        sw $t2, 384($t3)
                        sw $t2, 388($t3)
                    
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
    lw $t0, RED                 # $t0 = red
    lw $t1, YELLOW              # $t1 = yellow
    lw $t2, BLUE                # $t2 = blue
    
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
    
random_virus_color:         lw $t0, LIGHT_PINK                  # $t0 = light pink
                            lw $t1, ORANGE                      # $t1 = orange
                            lw $t2, LIGHT_BLUE                  # $t2 = desaturated blue
    
                            li $v0, 42                          # 42 is system call code to generate random int
                            li $a0, 0                           # $a0 is the lower bound
                            li $a1, 3                           # $a1 is the upper bound
                            syscall                             # your generated number will be at $a0
    
                            addi $sp, $sp, -4
                            
                            beq $a0, 0, red_color               # if $a0 == 0, then return red color
                            beq $a0, 1, yellow_color            # if $a0 == 1, then return yellow color
                            
                            # otherwise return blue color
                            sw $t2, 0($sp)
                            jr $ra

red_color:                  sw $t0, 0($sp)
                            jr $ra
                        
yellow_color:               sw $t1, 0($sp)
                            jr $ra
                            
clear_score_from_display:   lw $t0, SCORE_POSITION       
                            addi $t1, $t0, 640
                            
clear_score_row_loop:       beq $t0, $t1, clear_score_end           # if done with all rows, exit

                            addi $t2, $t0, 44

clear_score_col_loop:       beq $t0, $t2, clear_score_col_loop_end  # if reached last col, go to next row

                            sw $zero, 0($t0)                        # delete pixel at $t3
                            addi $t0, $t0, 4                        # increment display address offset
                            
                            j clear_score_col_loop

clear_score_col_loop_end:   addi $t0, $t0, 84
                            
                            j clear_score_row_loop
                            
clear_score_end:            jr $ra
                            
draw_score:                 addi $sp, $sp, -4
                            sw $ra, 0($sp)                      # save return address on stack
                            
                            lw $s0, SCORE_POSITION
                            lw $s7, SCORE                       # $s7 = current score
                            
                            # 1's place
                            li $s6, 10
                            div $s7, $s6
                            mfhi $s3                            # $s3 = remainder
                            mflo $s7                            # $s7 = quotient
                            
                            addi $s1, $s0, 32
                            addi $sp, $sp, -4
                            sw $s1, 0($sp)                      # save address for 1's place on stack
                            
                            addi $sp, $sp, -4
                            sw $s3, 0($sp)                      # save number to be drawn on stack
                            
                            jal draw_number
                            
                            # 10's place
                            li $s6, 10
                            div $s7, $s6
                            mfhi $s3                            # $s3 = remainder
                            mflo $s7                            # $s7 = quotient
                            
                            addi $s1, $s0, 16 
                            addi $sp, $sp, -4
                            sw $s1, 0($sp)                      # save address for 10's place on stack
                            
                            addi $sp, $sp, -4
                            sw $s3, 0($sp)                      # save number to be drawn on stack
                            
                            jal draw_number
                            
                            # 100's place
                            li $s6, 10
                            div $s7, $s6
                            mfhi $s3                            # $s3 = remainder
                            mflo $s7                            # $s7 = quotient
                            
                            addi $s1, $s0, 0
                            addi $sp, $sp, -4
                            sw $s1, 0($sp)                      # save address for 100's place on stack
                            
                            addi $sp, $sp, -4
                            sw $s3, 0($sp)                      # save number to be drawn on stack
                            
                            jal draw_number
                                    
                            lw $ra, 0($sp)                      # restore return address from stack
                            addi $sp, $sp, 4
                            jr $ra
                            
draw_game_over:             jr $ra
                            
##############################################################################
                        
                        
################################ Draw Numbers ################################

draw_number:                lw $t0, 0($sp)                      # $t0 = number
                            addi $sp, $sp, 4
                            
                            beq $t0, 0, draw_zero
                            beq $t0, 1, draw_one
                            beq $t0, 2, draw_two
                            beq $t0, 3, draw_three
                            beq $t0, 4, draw_four
                            beq $t0, 5, draw_five
                            beq $t0, 6, draw_six
                            beq $t0, 7, draw_seven
                            beq $t0, 8, draw_eight
                            beq $t0, 9, draw_nine
                            
                            j draw_E
                            
draw_zero:                  lw $t0, 0($sp)                      # $t0 = position
                            addi $sp, $sp, 4
                            
                            li $t1, 0xffffff                    # $t1 = white
                            
                            # top
                            sw $t1, 0($t0)
                            sw $t1, 4($t0)
                            sw $t1, 8($t0)
                            
                            # bottom 
                            sw $t1, 512($t0)
                            sw $t1, 516($t0)
                            sw $t1, 520($t0)
                            
                            # left
                            sw $t1, 128($t0)
                            sw $t1, 256($t0)
                            sw $t1, 384($t0)
                            
                            # right
                            sw $t1, 136($t0)
                            sw $t1, 264($t0)
                            sw $t1, 392($t0)
                            
                            jr $ra
                            
draw_one:                   lw $t0, 0($sp)                      # $t0 = position
                            addi $sp, $sp, 4
                            
                            li $t1, 0xffffff                    # $t1 = white
                            
                            # middle
                            sw $t1, 4($t0)
                            sw $t1, 132($t0)
                            sw $t1, 260($t0)
                            sw $t1, 388($t0)
                            sw $t1, 516($t0)
                            
                            # nose
                            sw $t1, 128($t0)
                            
                            # bottom
                            sw $t1, 512($t0)
                            sw $t1, 520($t0)
                            
                            jr $ra
                            
draw_two:                   lw $t0, 0($sp)                      # $t0 = position
                            addi $sp, $sp, 4
                            
                            li $t1, 0xffffff                    # $t1 = white
                            
                            # top
                            sw $t1, 0($t0)
                            sw $t1, 4($t0)
                            sw $t1, 8($t0)
                            
                            # bottom 
                            sw $t1, 512($t0)
                            sw $t1, 516($t0)
                            sw $t1, 520($t0)
                            
                            # diagonal
                            sw $t1, 136($t0)
                            sw $t1, 264($t0)
                            sw $t1, 260($t0)
                            sw $t1, 384($t0)
                            
                            jr $ra
                            
draw_three:                 lw $t0, 0($sp)                      # $t0 = position
                            addi $sp, $sp, 4
                            
                            li $t1, 0xffffff                    # $t1 = white
                            
                            # top
                            sw $t1, 0($t0)
                            sw $t1, 4($t0)
                            sw $t1, 8($t0)
                            
                            # bottom 
                            sw $t1, 512($t0)
                            sw $t1, 516($t0)
                            sw $t1, 520($t0)
                            
                            # right
                            sw $t1, 136($t0)
                            sw $t1, 264($t0)
                            sw $t1, 392($t0)
                            
                            # middle
                            sw $t1, 260($t0)
                            
                            jr $ra
                            
draw_four:                  lw $t0, 0($sp)                      # $t0 = position
                            addi $sp, $sp, 4
                            
                            li $t1, 0xffffff                    # $t1 = white
                            
                            # right
                            sw $t1, 8($t0)
                            sw $t1, 136($t0)
                            sw $t1, 264($t0)
                            sw $t1, 392($t0)
                            sw $t1, 520($t0)
                            
                            # weird sticking out thingy
                            sw $t1, 260($t0)
                            sw $t1, 256($t0)
                            sw $t1, 128($t0)
                            sw $t1, 0($t0)
                            
                            jr $ra
                            
draw_five:                  lw $t0, 0($sp)                      # $t0 = position
                            addi $sp, $sp, 4
                            
                            li $t1, 0xffffff                    # $t1 = white
                            
                            # top
                            sw $t1, 0($t0)
                            sw $t1, 4($t0)
                            sw $t1, 8($t0)
                            
                            # bottom 
                            sw $t1, 512($t0)
                            sw $t1, 516($t0)
                            sw $t1, 520($t0)
                            
                            # swiggly line
                            sw $t1, 128($t0)
                            sw $t1, 256($t0)
                            sw $t1, 260($t0)
                            sw $t1, 264($t0)
                            sw $t1, 392($t0)
                            
                            jr $ra
                            
draw_six:                   lw $t0, 0($sp)                      # $t0 = position
                            addi $sp, $sp, 4
                            
                            li $t1, 0xffffff                    # $t1 = white
                            
                            # top
                            sw $t1, 0($t0)
                            sw $t1, 4($t0)
                            sw $t1, 8($t0)
                            
                            # left
                            sw $t1, 128($t0)
                            sw $t1, 256($t0)
                            sw $t1, 384($t0)
                            sw $t1, 512($t0)
                            
                            # circle 
                            sw $t1, 516($t0)
                            sw $t1, 520($t0)
                            sw $t1, 392($t0)
                            sw $t1, 264($t0)
                            sw $t1, 260($t0)
                            
                            jr $ra
                            
draw_seven:                 lw $t0, 0($sp)                      # $t0 = position
                            addi $sp, $sp, 4
                            
                            li $t1, 0xffffff                    # $t1 = white
                            
                            # top
                            sw $t1, 0($t0)
                            sw $t1, 4($t0)
                            sw $t1, 8($t0)
                            
                            # diagonal
                            sw $t1, 136($t0)
                            sw $t1, 264($t0)
                            sw $t1, 388($t0)
                            sw $t1, 516($t0)
                            
                            jr $ra
                            
draw_eight:                 lw $t0, 0($sp)                      # $t0 = position
                            addi $sp, $sp, 4
                            
                            li $t1, 0xffffff                    # $t1 = white
                            
                            # top
                            sw $t1, 0($t0)
                            sw $t1, 4($t0)
                            sw $t1, 8($t0)
                            
                            # bottom 
                            sw $t1, 512($t0)
                            sw $t1, 516($t0)
                            sw $t1, 520($t0)
                            
                            # left
                            sw $t1, 128($t0)
                            sw $t1, 256($t0)
                            sw $t1, 384($t0)
                            
                            # right
                            sw $t1, 136($t0)
                            sw $t1, 264($t0)
                            sw $t1, 392($t0)
                            
                            # middle
                            sw $t1, 260($t0)
                            
                            jr $ra
                            
draw_nine:                  lw $t0, 0($sp)                      # $t0 = position
                            addi $sp, $sp, 4
                            
                            li $t1, 0xffffff                    # $t1 = white
                            
                            # right
                            sw $t1, 8($t0)
                            sw $t1, 136($t0)
                            sw $t1, 264($t0)
                            sw $t1, 392($t0)
                            sw $t1, 520($t0)
                            
                            # circle 
                            sw $t1, 4($t0)
                            sw $t1, 0($t0)
                            sw $t1, 128($t0)
                            sw $t1, 256($t0)
                            sw $t1, 260($t0)
                            
                            jr $ra
                            
##############################################################################
                        
                        
############################### Draw Letters #################################

draw_G:                     lw $t0, 0($sp)                      # $t0 = position
                            addi $sp, $sp, 4
                            
                            li $t1, 0xffffff                    # $t1 = white
                            
                            # top
                            sw $t1, 0($t0)
                            sw $t1, 4($t0)
                            sw $t1, 8($t0)
                            sw $t1, 12($t0)
                            
                            # bottom 
                            sw $t1, 512($t0)
                            sw $t1, 516($t0)
                            sw $t1, 520($t0)
                            sw $t1, 524($t0)
                            
                            # left
                            sw $t1, 128($t0)
                            sw $t1, 256($t0)
                            sw $t1, 384($t0)
                            
                            # turn
                            sw $t1, 396($t0)
                            sw $t1, 268($t0)
                            sw $t1, 264($t0)
                            
                            jr $ra
                            
draw_A:                     lw $t0, 0($sp)                      # $t0 = position
                            addi $sp, $sp, 4
                            
                            li $t1, 0xffffff                    # $t1 = white
                            
                            # top
                            sw $t1, 0($t0)
                            sw $t1, 4($t0)
                            sw $t1, 8($t0)
                            
                            # left
                            sw $t1, 128($t0)
                            sw $t1, 256($t0)
                            sw $t1, 384($t0)
                            sw $t1, 512($t0)
                            
                            # right
                            sw $t1, 136($t0)
                            sw $t1, 264($t0)
                            sw $t1, 392($t0)
                            sw $t1, 520($t0)
                            
                            # middle
                            sw $t1, 260($t0)
                            
                            jr $ra
                            
draw_M:                     lw $t0, 0($sp)                      # $t0 = position
                            addi $sp, $sp, 4
                            
                            li $t1, 0xffffff                    # $t1 = white
                            
                            # left
                            sw $t1, 0($t0)
                            sw $t1, 128($t0)
                            sw $t1, 256($t0)
                            sw $t1, 384($t0)
                            sw $t1, 512($t0)
                            
                            # right
                            sw $t1, 16($t0)
                            sw $t1, 144($t0)
                            sw $t1, 272($t0)
                            sw $t1, 400($t0)
                            sw $t1, 528($t0)
                            
                            # middle
                            sw $t1, 132($t0)
                            sw $t1, 264($t0)
                            sw $t1, 140($t0)
                            
                            jr $ra
                            
draw_E:                     lw $t0, 0($sp)                      # $t0 = position
                            addi $sp, $sp, 4
                            
                            li $t1, 0xffffff                    # $t1 = white
                            
                            # top
                            sw $t1, 0($t0)
                            sw $t1, 4($t0)
                            sw $t1, 8($t0)
                            
                            # bottom 
                            sw $t1, 512($t0)
                            sw $t1, 516($t0)
                            sw $t1, 520($t0)
                            
                            # left
                            sw $t1, 128($t0)
                            sw $t1, 256($t0)
                            sw $t1, 384($t0)
                            
                            # middle
                            sw $t1, 260($t0)
                            
                            jr $ra
                        
draw_O:                     lw $t0, 0($sp)                      # $t0 = position
                            addi $sp, $sp, 4
                            
                            li $t1, 0xffffff                    # $t1 = white
                            
                            # top
                            sw $t1, 0($t0)
                            sw $t1, 4($t0)
                            sw $t1, 8($t0)
                            
                            # bottom 
                            sw $t1, 512($t0)
                            sw $t1, 516($t0)
                            sw $t1, 520($t0)
                            
                            # left
                            sw $t1, 128($t0)
                            sw $t1, 256($t0)
                            sw $t1, 384($t0)
                            
                            # right
                            sw $t1, 136($t0)
                            sw $t1, 264($t0)
                            sw $t1, 392($t0)
                            
                            jr $ra
                            
draw_V:                     lw $t0, 0($sp)                      # $t0 = position
                            addi $sp, $sp, 4
                            
                            li $t1, 0xffffff                    # $t1 = white
                            
                            # left
                            sw $t1, 0($t0)
                            sw $t1, 128($t0)
                            sw $t1, 256($t0)
                            sw $t1, 384($t0)
                            
                            # right
                            sw $t1, 8($t0)
                            sw $t1, 136($t0)
                            sw $t1, 264($t0)
                            sw $t1, 392($t0)
                            
                            # bottom 
                            sw $t1, 516($t0)
                            
                            jr $ra
                            
draw_R:                     lw $t0, 0($sp)                      # $t0 = position
                            addi $sp, $sp, 4
                            
                            li $t1, 0xffffff                    # $t1 = white
                            
                            # left
                            sw $t1, 0($t0)
                            sw $t1, 128($t0)
                            sw $t1, 256($t0)
                            sw $t1, 384($t0)
                            sw $t1, 512($t0)
                            
                            # circle
                            sw $t1, 4($t0)
                            sw $t1, 136($t0)
                            sw $t1, 264($t0)
                            
                            # bottom tick 
                            sw $t1, 388($t0)
                            sw $t1, 520($t0)
                            
                            jr $ra

##############################################################################
                        
                        
############################## Event Handlers ################################

sleep:      li $v0, 32      # $v0 = system call for sleeping
            li $a0, 67      # $a0 = time (in milliseconds) to sleep
            syscall         # sleep
            jr $ra
            
update_game_loop_count:         lw $t0, GAME_LOOP_COUNT
                                addi $t0, $t0, 1
                                sw $t0, GAME_LOOP_COUNT
                                
update_game_loop_count_end:     jr $ra

update_falling_speed:           lw $t0, SCORE
                                blt $t0, 60, speed_phase_one
                                blt $t0, 110, speed_phase_two
                                blt $t0, 155, speed_phase_three
                                blt $t0, 225, speed_phase_four
                                blt $t0, 345, speed_phase_five
                                
                                j speed_phase_six

speed_phase_one:                li $t1, 0
                                sub $t0, $t0, $t1
                                li $t1, 10
                                
                                div $t0, $t1
                                mflo $t0                                            # quotient to $t0
                                
                                li $t1, 15
                                sub $t1, $t1, $t0
                                
                                sw $t1, FALLING_SPEED
                                j update_falling_speed_end

speed_phase_two:                li $t1, 50
                                sub $t0, $t0, $t1
                                li $t1, 15
                                
                                div $t0, $t1
                                mflo $t0                                            # quotient to $t0
                                
                                li $t1, 10
                                sub $t1, $t1, $t0
                                
                                sw $t1, FALLING_SPEED
                                j update_falling_speed_end

speed_phase_three:              li $t1, 95
                                sub $t0, $t0, $t1
                                li $t1, 20
                                
                                div $t0, $t1
                                mflo $t0                                            # quotient to $t0
                                
                                li $t1, 7
                                sub $t1, $t1, $t0
                                
                                sw $t1, FALLING_SPEED
                                j update_falling_speed_end

speed_phase_four:               li $t1, 135
                                sub $t0, $t0, $t1
                                li $t1, 30
                                
                                div $t0, $t1
                                mflo $t0                                            # quotient to $t0
                                
                                li $t1, 5
                                sub $t1, $t1, $t0
                                
                                sw $t1, FALLING_SPEED
                                j update_falling_speed_end

speed_phase_five:               li $t1, 195
                                sub $t0, $t0, $t1
                                li $t1, 75
                                
                                div $t0, $t1
                                mflo $t0                                            # quotient to $t0
                                
                                li $t1, 3
                                sub $t1, $t1, $t0
                                
                                sw $t1, FALLING_SPEED
                                j update_falling_speed_end

speed_phase_six:                li $t1, 1
                                
                                sw $t1, FALLING_SPEED
                                j update_falling_speed_end

update_falling_speed_end:       jr $ra
            
make_capsule_fall:              lw $t0, GAME_LOOP_COUNT
                                lw $t1, FALLING_SPEED
                                div $t0, $t1
                                mfhi $t0 # remainder to $t0
                                bne $t0, 0, make_capsule_fall_end                   # if not divisible by 15, don't fall

                                la $t0, CAPSULE                                     # $t0 = capsule position pointers
                                lw $t2, 0($t0)                                      # $t2 = top/left position
                                lw $t3, 4($t0)                                      # $t3 = bottom/right position
                            
                                subu $t4, $t3, $t2
                            
capsule_fall_vertical:          bne $t4, 128, capsule_fall_horizontal               # if capsule is not vertical, go to horizontal

                                addi $t4, $t3, 128                                  # $t4 = position below the capsule
                                lw $t4, 0($t4)                                      # $t4 = color at position below the capsule
                                bne $t4, $zero, make_capsule_fall_end               # if there if no space to move, then exit function
        
                                addi $t2, $t2, 128                                  # $t2 = new top position of capsule
                                addi $t3, $t3, 128                                  # $t3 = new bottom position of capsule
                                
                                sw $t2, 0($t0)                                      # save new top position
                                sw $t3, 4($t0)                                      # save new bottom position
                                
                                j make_capsule_fall_end
                                
capsule_fall_horizontal:        addi $t4, $t2, 128                                  # $t4 = position below the left capsule
                                addi $t5, $t3, 128                                  # $t5 = position below the right capsule
                                lw $t4, 0($t4)                                      # $t4 = color at position below the left capsule
                                lw $t5, 0($t5)                                      # $t5 = color at position below the right capsule
                                bne $t4, $zero, make_capsule_fall_end               # if there if no space to move,
                                bne $t5, $zero, make_capsule_fall_end               #       then exit function
        
                                addi $t2, $t2, 128                                  # $t2 = new left position of capsule
                                addi $t3, $t3, 128                                  # $t3 = new right position of capsule
                                
                                sw $t2, 0($t0)                                      # save new left position
                                sw $t3, 4($t0)                                      # save new right position
                            
make_capsule_fall_end:          jr $ra

handle_keyboard_input:          addi $sp, $sp, -4                           # save 
                                sw $ra, 0($sp)                              #   return address on stack
                            
                                lw $t0, ADDR_KBRD                           # $t0 = base address for keyboard
                                lw $t8, 0($t0)                              # Load first word from keyboard
                                bne $t8, 1, end_handle_keyboard_input       # If first word is not 1, key is not pressed, so exit
    
                                lw $a0, 4($t0)                              # Load second word from keyboard
                                beq $a0, 0x71, exit                         # Check if the key q was pressed
                                beq $a0, 0x61, a_key_press
                                beq $a0, 0x64, d_key_press
                                beq $a0, 0x73, s_key_press
                                beq $a0, 0x77, w_key_press
                                
                                # li $v0, 1                       # ask system to print $a0
                                # syscall
                                
end_handle_keyboard_input:      lw $ra, 0($sp)                  # restore
                                addi $sp, $sp, 4                #   return address from stack
                                jr $ra

a_key_press:        la $t0, CAPSULE                 # $t0 = capsule position pointers
                    lw $t2, 0($t0)                  # $t2 = top/left position
                    lw $t3, 4($t0)                  # $t3 = bottom/right position
                    
                    subu $t4, $t3, $t2
                    a_key_branch_vertical: bne $t4, 128, a_key_branch_horizontal        # if capsule is verticle
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

handle_capsule_bottom_collision:        la $t0, CAPSULE                             # $t0 = capsule position pointer
                                        lw $t1, 0($t0)                              # $t1 = top/left capsule position
                                        lw $t2, 4($t0)                              # $t2 = bottom/right capsule position
                                        
                                        addi $sp, $sp, -4
                                        sw $zero, 0($sp)                            # set default return value to false
                                    
                                        sub $t3, $t2, $t1
                                        bne $t3, 128, horizontal_collision_test     # if not vertical, go to horizontal branch

vertical_collision_test:                lw $t3, 128($t2)                            # $t3 = color of position below capsule
                                        bne $t3, 0, collision                       # if there is no space below, handle it
                                        
                                        j bottom_collision_end
                                        
collision:                              li $t0, 1
                                        sw $t0, 0($sp)                              # set return value to true

                                        # save blocks to inner screen
                                        lw $t0, TOP_LEFT_BOTTLE                     # $t0 = pointer to top left of bottle on display
                                        la $t3, INNER_BOTTLE                        # $t3 = pointer of inner bottle
                                        la $t4, COLOR_CAPSULE                       # $t4 = pointer of capsule color array
                                        
                                        # top/left capsule
                                        sub $t1, $t1, $t0                           # $t1 = position of top/left capsule minus display address offset
                                        
                                        li $t9, 128                                 # $t9 = bytes per row for display array
                                        divu $t1, $t9                               # divide relative position of top/left capsule by bytes per row
                                        mfhi $a2                                    # remainder to $a2
                                        mflo $v0                                    # quotient to $v0
                                        
                                        li $t9, 68                                  # $t9 = bytes per row for inner bottle array
                                        multu $v0, $t9                               
                                        mflo $t8                                    # $t8 = y offset
                                        add $t1, $t8, $a2                           # $t1 = y offset + x offset
                                        
                                        blt $t1, $zero, handle_collision_game_over  # if the position offset is negative, then game is over
                                        
                                        add $t1, $t1, $t3                           # $t1 = position of top/left capsule translated to inner bottle positioning
                                        lw $t5, 0($t4)                              # $t5 = color of top/left capsule
                                        sw $t5, 0($t1)                              # save top/left capsule on inner bottle
                                        
                                        # bottom/right capsule
                                        sub $t2, $t2, $t0                           # $t2 = position of top/left capsule minus display address offset
                                        
                                        li $t9, 128                                 # $t9 = bytes per row for display array
                                        divu $t2, $t9                                # divide relative position of top/left capsule by bytes per row
                                        mfhi $a2                                    # remainder to $a2
                                        mflo $v0                                    # quotient to $v0
                                        
                                        li $t9, 68                                  # $t8 = bytes per row for inner bottle array
                                        multu $v0, $t9                               
                                        mflo $t8                                    # $t8 = y offset
                                        add $t2, $t8, $a2                           # $t2 = y offset + x offset
                                        
                                        blt $t2, $zero, handle_collision_game_over  # if the position offset is negative, then game is over
                                        
                                        add $t2, $t2, $t3                           # $t2 = position of top/left capsule translated to inner bottle positioning
                                        lw $t5, 4($t4)                              # $t5 = color of top/left capsule
                                        sw $t5, 0($t2)                              # save top/left capsule on inner bottle
                                        
                                        # set new capsule
                                        la $t0, CAPSULE                             # $t0 = capsule position pointer
                                        la $t1, COLOR_CAPSULE                       # $t1 = capsule color pointer
                                        lw $t2, CENTR_BTTL                          # $t2 = next capsule position pointer
                                        la $t3, NEXT_CAPSULE_COLOR                  # $t3 = next capsule color pointer
                                        
                                        sw $t2, 0($t0)                              # save new top capsule position on memory
                                        addi $t2, $t2, 128                          # $t2 = new bottom capsule position
                                        sw $t2, 4($t0)                              # save new bottom/right capsule position on memory
                                        
                                        lw $t4, 0($t3)                              # $t4 = next top/left capsule color
                                        sw $t4, 0($t1)                              # save new top/left capsule color on memory
                                        lw $t4, 4($t3)                              # $t4 = next bottom/right capsule color
                                        sw $t4, 4($t1)                              # save new bottom/right capsule color on memory
                                        
                                        addi $sp, $sp, -4
                                        sw $ra, 0($sp)                              # save return address on stack 
                                        
                                        jal create_next_capsule                     # set new capsule color
                                        
                                        lw $ra, 0($sp)                              # restore return address from stack 
                                        addi $sp, $sp, 4
                                        
                                        j bottom_collision_end
                                        
handle_collision_game_over:             jal game_over                               # checks if game over, and handles it
                                        j bottom_collision_end
                                        
horizontal_collision_test:              lw $t3, 128($t1)                            # $t3 = color of position below left capsule
                                        bne $t3, 0, collision                       # if there is no space below, handle it
                                        lw $t3, 128($t2)                            # $t3 = color of position below right capsule
                                        bne $t3, 0, collision                       # if there is no space below, handle it
                                        
                                        j bottom_collision_end
                          
bottom_collision_end:                   jr $ra

update_inner_bottle_state:              lw $s0, 0($sp)                              # $s0 = argument (updated)
                                        sw $ra, 0($sp)                              # save return address on stack
                                        
                                        bne $s0, 1, update_inner_bottle_state_end   # if not updated, exit
                                        jal draw_inner_screen                       # necessary because algorithm utilizes the display 
                                        
run_loop:                               move $s0, $zero                             # set updated to false by default
                                        
                                        li $s1, 0                                   # $s1 = current inner bottle x-coordinate
                                        li $s2, 0                                   # $s2 = current inner bottle y-coordinate
                
row_loop:                               beq $s2, 24, row_loop_end                   # if we have reached the last row, exit loop
                
col_loop:                               beq $s1, 17, col_loop_end                  # if we have reached the last col, exit loop
                                        
                                        addi $sp, $sp, -4
                                        sw $s2, 0($sp)                              # place y-coordinate on stack for check_four_or_more
                                        addi $sp, $sp, -4
                                        sw $s1, 0($sp)                              # place x-coordinate on stack for check_four_or_more
                                        jal check_four_or_more
                                        lw $t0, 0($sp)                              # $t0 = return (updated) from check_four_or_more
                                        addi $sp, $sp, 4
                                        
                                        bne $t0, 1, skip_append_run_loop            # if not updated, don't set run_again
                                        move $s0, $t0                               # make loop run again
                                        
                                        # jal gravitify_blocks
                                        
skip_append_run_loop:                   addi $s1, $s1, 1                            # increment col pointer
                                        
                                        j col_loop
                                        
col_loop_end:                           li $s1, 0                                   # reset col pointer
                                        addi $s2, $s2, 1                            # increment row pointer
                                        j row_loop
                                        
row_loop_end:                           bne $s0, 1, update_inner_bottle_state_end   # if not updated, exit

                                        # draw deleted screen
                                        jal draw_inner_screen
                                        jal sleep
                                        
                                        jal gravitify_blocks
                                        
                                        j run_loop
                                    
update_inner_bottle_state_end:          lw $ra, 0($sp)                              # restore return address from stack
                                        addi $sp, $sp, 4
                                        jr $ra

check_four_or_more:                     lw $t0, 0($sp)                              # $t0 = x-coordinate argument on stack
                                        addi $sp, $sp, 4
                                        lw $t1, 0($sp)                              # $t1 = y-coordinate argument on stack
                                        sw $zero, 0($sp)                            # store return value (updated) on stack: default is 0
                                        
                                        lw $t2, TOP_LEFT_BOTTLE                     # $t2 = top left bottle display pointer
                                        sll $t4, $t0, 2
                                        sll $t5, $t1, 7
                                        add $t4, $t4, $t5
                                        add $t4, $t4, $t2                           # $t4 = current position on display
                                        lw $t8, 0($t4)                              # $t5 = current color on display
                                        bne $t8, 0, set_color                       # if not empty, check the horizontal direction
                                        
                                        jr $ra
                                    
set_color:                              lw $t2, RED
                                        beq $t8, $t2, set_color_red                 # if red, set color to red
                                        lw $t2, LIGHT_PINK
                                        beq $t8, $t2, set_color_red                 # if red, set color to red
                                        
                                        lw $t2, YELLOW
                                        beq $t8, $t2, set_color_yellow              # if yellow, set color to yellow
                                        lw $t2, ORANGE
                                        beq $t8, $t2, set_color_yellow              # if yellow, set color to yellow
                                        
                                        lw $t2, BLUE
                                        beq $t8, $t2, set_color_blue                # if blue, set color to blue
                                        lw $t2, LIGHT_BLUE
                                        beq $t8, $t2, set_color_blue                # if blue, set color to blue
                                        
                                        j check_four_or_more_end                    # should not hit, but just in case
                                        
set_color_red:                          li $t8, 1                                   # $t8 represent red color
                                        j horizontal_direction_start
                                    
set_color_yellow:                       li $t8, 2                                   # $t8 represent yellow color
                                        j horizontal_direction_start
                        
set_color_blue:                         li $t8, 3                                   # $t8 represent blue color
                                        j horizontal_direction_start
                                        
horizontal_direction_start:             lw $t2, TOP_LEFT_BOTTLE                     # $t2 = top left bottle display pointer
                                        addi $t3, $t0, 1                            # $t3 = current x-coordinate
check_horizontal_direction:             beq $t3, 17, horizontal_direction_end       # if reached last column, leave
                                        
                                        sll $t4, $t3, 2                             # $t4 = x position offset
                                        sll $t5, $t1, 7                             # $t5 = y position offset
                                        add $t4, $t4, $t5
                                        add $t4, $t4, $t2                           # $t4 = current position on display
                                        lw $t5, 0($t4)                              # $t5 = current color on display
                                        
                                        beq $t8, 1, check_red_block_horizontal      # if we are checking red, ensure it
                                        beq $t8, 2, check_yellow_block_horizontal   # if we are checking yellow, ensure it
                                        beq $t8, 3, check_blue_block_horizontal     # if we are checking blue, ensure it
                                        
check_red_block_horizontal:             lw $t6, RED
                                        beq $t5, $t6, same_block_horizontal         # if same block, deal with it
                                        lw $t6, LIGHT_PINK
                                        beq $t5, $t6, same_block_horizontal         # if same block, deal with it
                                        j horizontal_direction_end

check_yellow_block_horizontal:          lw $t6, YELLOW
                                        beq $t5, $t6, same_block_horizontal         # if same block, deal with it
                                        lw $t6, ORANGE
                                        beq $t5, $t6, same_block_horizontal         # if same block, deal with it
                                        j horizontal_direction_end

check_blue_block_horizontal:            lw $t6, BLUE
                                        beq $t5, $t6, same_block_horizontal         # if same block, deal with it
                                        lw $t6, LIGHT_BLUE
                                        beq $t5, $t6, same_block_horizontal         # if same block, deal with it
                                        j horizontal_direction_end
                                        
same_block_horizontal:                  addi $t3, $t3, 1                            # $t3 = increment x-coordinate
                                        
                                        j check_horizontal_direction
                                        
horizontal_direction_end:               sub $t4, $t3, $t0                           # $t4 = number of same blocks
                                        blt $t4, 4, vertical_direction_start        # if not 4 or more blocks, check the vertical direction 
                                        
                                        li $t4, 1                                   # $t4 = 1, to set return value
                                        sw $t4, 0($sp)                              # set return value (updated), to true
                                
                                        la $t2, INNER_BOTTLE                        # $t2 = inner bottle array pointer
                                        
horizontal_delete_loop:                 beq $t3, $t0, vertical_direction_start      # if all blocks have been deleted, check vertical direction
                                        
                                        addi $t3, $t3, -1                           # $t3 = decrement x-coordinate
                                        
                                        sll $t4, $t3, 2                             # $t4 = x position offset
                                        
                                        li $t6, 68                                  # $t6 = bytes per row for inner bottle array
                                        multu $t1, $t6                               
                                        mflo $t5                                    # $t5 = y position offset
                                        
                                        add $t4, $t4, $t5
                                        add $t4, $t4, $t2                           # $t4 = current position on inner bottle array
                                        
                                        lw $t6, 0($t4)                              # $t6 = color at current position
                                        bne $t6, $zero, horizontal_inc_score        # if there is a block, increment the score
                                        
continue_horizontal_delete_loop:        sw $zero, 0($t4)                            # delete current block
                                        
                                        j horizontal_delete_loop
                                        
horizontal_inc_score:                   lw $t7, SCORE                               # $t7 = current score
                                        addi $t7, $t7, 1                            # increment score
                                        sw $t7, SCORE                               # save new score in memory
                                        
                                        j continue_horizontal_delete_loop
                                        
vertical_direction_start:               lw $t2, TOP_LEFT_BOTTLE                     # $t2 = top left bottle display pointer
                                        addi $t3, $t1, 1                            # $t3 = current y-coordinate
                                        
check_vertical_direction:               beq $t3, 24, veritcal_direction_end         # if reached last row, leave
                                        
                                        sll $t4, $t3, 7                             # $t4 = y position offset
                                        sll $t5, $t0, 2                             # $t5 = x position offset
                                        add $t4, $t4, $t5
                                        add $t4, $t4, $t2                           # $t4 = current position on display
                                        lw $t5, 0($t4)                              # $t5 = current color on display
                                        
                                        beq $t8, 1, check_red_block_vertical        # if we are checking red, ensure it
                                        beq $t8, 2, check_yellow_block_vertical     # if we are checking yellow, ensure it
                                        beq $t8, 3, check_blue_block_vertical       # if we are checking blue, ensure it
                                        
check_red_block_vertical:               lw $t6, RED
                                        beq $t5, $t6, same_block_vertical         # if same block, deal with it
                                        lw $t6, LIGHT_PINK
                                        beq $t5, $t6, same_block_vertical         # if same block, deal with it
                                        j veritcal_direction_end

check_yellow_block_vertical:            lw $t6, YELLOW
                                        beq $t5, $t6, same_block_vertical         # if same block, deal with it
                                        lw $t6, ORANGE
                                        beq $t5, $t6, same_block_vertical         # if same block, deal with it
                                        j veritcal_direction_end

check_blue_block_vertical:              lw $t6, BLUE
                                        beq $t5, $t6, same_block_vertical         # if same block, deal with it
                                        lw $t6, LIGHT_BLUE
                                        beq $t5, $t6, same_block_vertical         # if same block, deal with it
                                        j veritcal_direction_end
                                        
same_block_vertical:                    addi $t3, $t3, 1                            # $t3 = increment x-coordinate
                                        
                                        j check_vertical_direction
            
veritcal_direction_end:                 sub $t4, $t3, $t1                           # $t4 = number of same blocks
                                        blt $t4, 4, check_four_or_more_end          # if not 4 or more blocks, exit 
                                        
                                        li $t4, 1                                   # $t4 = 1, to set return value
                                        sw $t4, 0($sp)                              # set return value (updated), to true

                                        la $t2, INNER_BOTTLE                        # $t2 = inner bottle array pointer
veritcal_delete_loop:                   beq $t3, $t1, check_four_or_more_end        # if all blocks have been deleted, exit
                                        
                                        addi $t3, $t3, -1                           # $t3 = decrement x-coordinate
                                        
                                        sll $t4, $t0, 2                             # $t4 = x position offset
                                        
                                        li $t6, 68                                  # $t6 = bytes per row for inner bottle array
                                        multu $t3, $t6                               
                                        mflo $t5                                    # $t5 = y position offset
                                        
                                        add $t4, $t4, $t5
                                        add $t4, $t4, $t2                           # $t4 = current position on inner bottle array
                                        
                                        lw $t6, 0($t4)                              # $t6 = color at current position
                                        bne $t6, $zero, vertical_inc_score          # if there is a block, increment the score
                                        
continue_vertical_delete_loop:          sw $zero, 0($t4)                            # delete current block
                                        
                                        j veritcal_delete_loop
                                        
vertical_inc_score:                     lw $t7, SCORE                               # $t7 = current score
                                        addi $t7, $t7, 1                            # increment score
                                        sw $t7, SCORE                               # save new score in memory
                                        
                                        j continue_vertical_delete_loop

check_four_or_more_end:                 jr $ra
                                        
                                        
gravitify_blocks:                       addi $sp, $sp, -4                           
                                        sw $ra, 0($sp)                              # save return address on stack
                                        
gravity_loop:                           la $t2, INNER_BOTTLE                        # $t2 = inner bottle array pointer
                                        li $t9, 0                                   # set default updated value to false
                                        li $t0, 16                                  # $t0 = x-coordinate
                                        li $t1, 22                                  # $t1 = y-coordinate
                                        
gravity_row_loop:                       beq $t1, -1, gravity_row_loop_end           # if reached last row, handle it

gravity_col_loop:                       beq $t0, -1, gravity_col_loop_end           # if reached last col, handle it
   
                                        sll $t3, $t0, 2                             # $t3 = x position offset
                                        
                                        li $t4, 68                                  # $t4 = bytes per row for inner bottle array
                                        multu $t1, $t4                               
                                        mflo $t4                                    # $t4 = y position offset
                                        
                                        add $t3, $t3, $t4
                                        add $t3, $t3, $t2                           # $t3 = current position on inner bottle array
                                        
                                        lw $t4, 0($t3)                              # $t4 = color at current position
                                        
                                        beq $t4, $zero, skip_gravitify_block        # if empty block, skip
                                        
                                        lw $t5, LIGHT_PINK                          
                                        beq $t4, $t5, skip_gravitify_block          # if virus, skip
                                        lw $t5, ORANGE                          
                                        beq $t4, $t5, skip_gravitify_block          # if virus, skip
                                        lw $t5, LIGHT_BLUE                          
                                        beq $t4, $t5, skip_gravitify_block          # if virus, skip
                                        
                                        lw $t5, 68($t3)                             # $t5 = color below current position
                                        bne $t5, 0, skip_gravitify_block            # if no space to fall, skip
                                        
                                        # move block down
                                        sw $t4, 68($t3)                             # move current  
                                        sw $zero, 0($t3)                            #    pixel down
                                        
                                        li $t9, 1                                   # set updated to true
                                        
skip_gravitify_block:                   addi $t0, $t0, -1                           # decrement x-coordinate
                                        j gravity_col_loop
                                        
gravity_col_loop_end:                   addi $t1, $t1, -1                           # decrement y-coordinate
                                        li $t0, 16                                  # reset x-coordinate
                                        j gravity_row_loop

gravity_row_loop_end:                   bne $t9, 1, gravitify_blocks_end            # if not updated, exit
                                        
gravitify_blocks_update_display:        jal clear_bottle_opening
                                        jal draw_inner_screen
                                        jal draw_capsule
                                        
                                        jal sleep
                                        
                                        j gravity_loop
                                        
gravitify_blocks_end:                   lw $ra, 0($sp)                              # restore return address from stack
                                        addi $sp, $sp, 4
                                        jr $ra
                                        
handle_virus_deletion:                  addi $sp, $sp, -4
                                        sw $ra, 0($sp)                              # save return address on stack
                                        
                                        jal handle_red_virus_deletion
                                        jal handle_yellow_virus_deletion
                                        jal handle_blue_virus_deletion
                                        
                                        lw $ra, 0($sp)
                                        addi $sp, $sp, 4                            # restore return address from stack
                                        jr $ra
                                        
handle_red_virus_deletion:              la $t0, INNER_BOTTLE
                                        li $t1, 0                                   # $t1 = current inner bottle x-coordinate
                                        li $t2, 0                                   # $t2 = current inner bottle y-coordinate
                                        lw $t5, LIGHT_PINK                          # $t5 = red virus color
                
red_virus_row_loop:                     beq $t2, 24, delete_red_virus               # if we have reached the last row, then we have not found virus, so delete it
                
red_virus_col_loop:                     beq $t1, 17, red_virus_col_loop_end         # if we have reached the last col, exit loop
                                        
                                        # do logic
                                        sll $t3, $t1, 2                             # $t3 = x position offset
                                        
                                        li $t4, 68                                  # $t4 = bytes per row for inner bottle array
                                        multu $t2, $t4                               
                                        mflo $t4                                    # $t4 = y position offset
                                        
                                        add $t3, $t3, $t4
                                        add $t3, $t3, $t0                           # $t3 = current position on inner bottle array
                                        
                                        lw $t4, 0($t3)                              # $t4 = color at current position
                                        beq $t4, $t5, red_virus_deletion_end        # if we find the virus, exit
                                        
                                        addi $t1, $t1, 1                            # increment col pointer
                                        j red_virus_col_loop
                                        
red_virus_col_loop_end:                 li $t1, 0                                   # reset col pointer
                                        addi $t2, $t2, 1                            # increment row pointer
                                        j red_virus_row_loop
                                        
delete_red_virus:                       lw $t0, RED_VIRUS_POSITION  
                                        lw $t1, 0($t0)                  
                                        
                                        beq $t1, $zero, skip_score_incrememnt_red   # if there was no virus, don't increment score
                                        lw $t1, SCORE
                                        addi $t1, $t1, 5
                                        sw $t1, SCORE
                                        
 skip_score_incrememnt_red:             sw $zero, 0($t0)
                                        j red_virus_deletion_end
                                        
red_virus_deletion_end:                 jr $ra
                                        
handle_yellow_virus_deletion:           la $t0, INNER_BOTTLE
                                        li $t1, 0                                   # $t1 = current inner bottle x-coordinate
                                        li $t2, 0                                   # $t2 = current inner bottle y-coordinate
                                        lw $t5, ORANGE                              # $t5 = red virus color
                
yellow_virus_row_loop:                  beq $t2, 24, delete_yellow_virus            # if we have reached the last row, then we have not found virus, so delete it
                
yellow_virus_col_loop:                  beq $t1, 17, yellow_virus_col_loop_end      # if we have reached the last col, exit loop
                                        
                                        # do logic
                                        sll $t3, $t1, 2                             # $t3 = x position offset
                                        
                                        li $t4, 68                                  # $t4 = bytes per row for inner bottle array
                                        multu $t2, $t4                               
                                        mflo $t4                                    # $t4 = y position offset
                                        
                                        add $t3, $t3, $t4
                                        add $t3, $t3, $t0                           # $t3 = current position on inner bottle array
                                        
                                        lw $t4, 0($t3)                              # $t4 = color at current position
                                        beq $t4, $t5, yellow_virus_deletion_end     # if we find the virus, exit
                                        
                                        addi $t1, $t1, 1                            # increment col pointer
                                        j yellow_virus_col_loop
                                        
yellow_virus_col_loop_end:              li $t1, 0                                   # reset col pointer
                                        addi $t2, $t2, 1                            # increment row pointer
                                        j yellow_virus_row_loop
                                        
delete_yellow_virus:                    lw $t0, YELLOW_VIRUS_POSITION  
                                        lw $t1, 0($t0)                  
                                        
                                        beq $t1, $zero, skip_score_incrememnt_yellow    # if there was no virus, don't increment score
                                        lw $t1, SCORE
                                        addi $t1, $t1, 5
                                        sw $t1, SCORE
                                        
 skip_score_incrememnt_yellow:          sw $zero, 0($t0)
                                        j yellow_virus_deletion_end

yellow_virus_deletion_end:              jr $ra
                                        
handle_blue_virus_deletion:             la $t0, INNER_BOTTLE
                                        li $t1, 0                                   # $t1 = current inner bottle x-coordinate
                                        li $t2, 0                                   # $t2 = current inner bottle y-coordinate
                                        lw $t5, LIGHT_BLUE                          # $t5 = red virus color
                
blue_virus_row_loop:                    beq $t2, 24, delete_blue_virus              # if we have reached the last row, then we have not found virus, so delete it
                
blue_virus_col_loop:                    beq $t1, 17, blue_virus_col_loop_end        # if we have reached the last col, exit loop
                                        
                                        # do logic
                                        sll $t3, $t1, 2                             # $t3 = x position offset
                                        
                                        li $t4, 68                                  # $t4 = bytes per row for inner bottle array
                                        multu $t2, $t4                               
                                        mflo $t4                                    # $t4 = y position offset
                                        
                                        add $t3, $t3, $t4
                                        add $t3, $t3, $t0                           # $t3 = current position on inner bottle array
                                        
                                        lw $t4, 0($t3)                              # $t4 = color at current position
                                        beq $t4, $t5, blue_virus_deletion_end       # if we find the virus, exit
                                        
                                        addi $t1, $t1, 1                            # increment col pointer
                                        j blue_virus_col_loop
                                        
blue_virus_col_loop_end:                li $t1, 0                                   # reset col pointer
                                        addi $t2, $t2, 1                            # increment row pointer
                                        j blue_virus_row_loop
                                        
delete_blue_virus:                      lw $t0, BLUE_VIRUS_POSITION     
                                        lw $t1, 0($t0)                  
                                        
                                        beq $t1, $zero, skip_score_incrememnt_blue  # if there was no virus, don't increment score
                                        lw $t1, SCORE
                                        addi $t1, $t1, 5
                                        sw $t1, SCORE
                                        
 skip_score_incrememnt_blue:            sw $zero, 0($t0)
                                        j blue_virus_deletion_end

blue_virus_deletion_end:                jr $ra
                                        
game_over:                              jal reset_screen
                                        jal draw_game_over
                                        
                                        j exit
                                        
game_over_end:                          jr $ra