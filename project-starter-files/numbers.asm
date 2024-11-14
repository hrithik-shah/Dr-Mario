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

    .text
	.globl main

main:
    li $t1, 0xff0000        # $t1 = red
    li $t2, 0x00ff00        # $t2 = green
    li $t3, 0x0000ff        # $t3 = blue

    lw $t0, ADDR_DSPL       # $t0 = base address for display
    addi $t0, $t0, 264
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    jal draw_zero
    
    lw $t0, ADDR_DSPL       # $t0 = base address for display
    addi $t0, $t0, 284
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    jal draw_one
    
    lw $t0, ADDR_DSPL       # $t0 = base address for display
    addi $t0, $t0, 304
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    jal draw_two
    
    lw $t0, ADDR_DSPL       # $t0 = base address for display
    addi $t0, $t0, 324
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    jal draw_three
    
    lw $t0, ADDR_DSPL       # $t0 = base address for display
    addi $t0, $t0, 344
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    jal draw_four
    
    lw $t0, ADDR_DSPL       # $t0 = base address for display
    addi $t0, $t0, 364
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    jal draw_five
    
    lw $t0, ADDR_DSPL       # $t0 = base address for display
    addi $t0, $t0, 1160
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    jal draw_six
    
    lw $t0, ADDR_DSPL       # $t0 = base address for display
    addi $t0, $t0, 1180
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    jal draw_seven
    
    lw $t0, ADDR_DSPL       # $t0 = base address for display
    addi $t0, $t0, 1200
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    jal draw_eight
    
    lw $t0, ADDR_DSPL       # $t0 = base address for display
    addi $t0, $t0, 1220
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    jal draw_nine
    
exit:
    li $v0, 10              # terminate the program gracefully
    syscall

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