################ CSC258H1F Fall 2022 Assembly Final Project ##################
# This file contains our implementation of Breakout.
#
# Student 1: Name, Student Number
# Student 2: Name, Student Number
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       8
# - Unit height in pixels:      8
# - Display width in pixels:    256
# - Display height in pixels:   256
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000

ADDR_PADDLE:
   .word 0x10008f38  

ADDR_BALL:
   .word 0x10008ebc 

BALL_X:
   .word 29
      
BALL_Y:
   .word 16


WALL:
    .word 0x808080

RED:
    .word	0xff0000    # red

GREEN:
    .word	0x00ff00    # green

BLUE:
    .word	0x0000ff    # blue

WHITE:
    .word	0xffffff    # white
    
YELLOW:
    .word	0xffff00    # white

##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################
	.text
	.globl main

	# Run the Brick Breaker game.
main:
    # Initialize the game 
    
    la $a0, ADDR_DSPL
    lw $a0, 0($a0)
    la $a1, WALL
    la $a2, 32
    jal draw_line
    
    
    jal draw_side_walls
    
    la $a0, ADDR_DSPL
    lw $a0, 0($a0)
    addi $a0, $a0, 388
    la $a1, RED
    li $a2, 30
    jal draw_line	# draw red line
    addi $a0, $a0, 8
    la $a1, GREEN 	
    jal draw_line	# draw green line
    addi $a0, $a0, 8
    la $a1, BLUE
    jal draw_line	# draw blue line
    addi $a0, $a0, 8
    la $a1, RED
    jal draw_line	# draw red line
    addi $a0, $a0, 8
    la $a1, GREEN 	
    jal draw_line	# draw green line
    addi $a0, $a0, 8
    la $a1, BLUE
    jal draw_line	# draw blue line
    
    # draw the paddle
    li $a0, 14
    li $a1, 30
    jal get_location_address
    addi $a0, $v0, 0
    la $a1, WHITE
    li $a2, 4
    
    jal draw_line
    
    # draw the ball
     li $a0, 15
     li $a1, 29
     jal get_location_address
     add $a0, $v0, 0, 
     la $a1, YELLOW
     li $a2, 1
     jal draw_line
    
    
    
    j end

# draw_line(start, colour_address, width) -> void
#   Draw a line with width units horizontally across the display using the
#   colour at colour_address and starting from the start address.
#   Preconditions:
#       - The start address can "accommodate" a line of width units
draw_line:
    # Retrieve the colour
    lw $t0, 0($a1)              # colour = *colour_address

    # Iterate $a2 times, drawing each unit in the line
    li $t1, 0                   # i = 0
draw_line_loop:
    slt $t2, $t1, $a2           # i < width ?
    beq $t2, $0, draw_line_epi  # if not, then done

        sw $t0, 0($a0)          # Paint unit with colour
        addi $a0, $a0, 4        # Go to next unit

    addi $t1, $t1, 1            # i = i + 1
    b draw_line_loop

draw_line_epi:
    jr $ra
	
#draw_side_walls(start, colour_address) -> void
# Draw the side walls on both sides for height units vertically 
# color loaded from color_address
draw_side_walls:
	lw $t0, 0($a1)		# load the colour_address
	li $t1, 31		# load the height	
	li $t2, 0		# i = 0
draw_side_walls_loop: 

	slt $t3, $t2, $t1	# set $t4 = 0 
	beq $t3, $0, draw_side_walls_epi	# end loop if $t4 = 0
		sw $t0, 0($a0)		
		sw $t0, 124($a0)	
		addi $a0, $a0, 128	# move the unit pointer to the next line
	
	addi $t2, $t2, 1		# i = i + 1
	
	j draw_side_walls_loop
	
draw_side_walls_epi:
	jr $ra


# get_location_address(x, y) -> int:
# return the location address corresponding to x columns(units) and y(rows) where 1 unit = 4 bits
get_location_address:
	sll $a0, $a0, 2 		# loc_x = x * 4
	sll $a1, $a1, 7 	# loc_y = y * 128
	la $v0, ADDR_DSPL	
	lw $v0, 0($v0)	
	add $v0, $v0, $a0
	add $v0, $v0, $a1
	
	jr $ra
	
end: 

# game_loop:
	# 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep

    #5. Go back to 1
    # b game_loop
