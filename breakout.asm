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
    
    # draw the paddle and set initial x position address
    
    li $a0, 14
    li $a1, 30
    jal get_location_address
    addi $a0, $v0, 0
    addi $s0, $v0, 0 	# load paddle position address initially
    la $a1, WHITE
    li $a2, 4
    
    jal draw_line
    
    # draw the ball
     li $a0, 15
     li $a1, 29
     jal get_location_address
     addi $a0, $v0, 0	
     addi $s1, $v0, 0	# load ball position address initially
     li $s2, 0		# load x component of ball velocity
     li $s3, 1		# load y component of ball velocity
     la $a1, YELLOW
     li $a2, 1
     jal draw_line
    
    # check if the user has started the game by pressing 's' key
    lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
check_start_loop:
    lw $t0, 0($t0)                  # Load first word from keyboard
    beq $t0, 0, check_start_loop      # If first word 0, key is not pressed, we check again
    lw $t0, 4($t0)
    beq $t0, 0x73, game_loop	    # if key pressed is 's', we start the game
    
    li $v0, 32			    # run loop(check for key press) every 50ms only
    li $a0, 50				
    j check_start_loop		    # if key pressed isn't 's' we check again
    
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
	
	


# let $s0 represent the current address of the left most unit of the paddle(length 4 units)
# let $s1 represent the current address of the ball
# let $s2 represent the current x-component of velocity of the ball(can take values -1 and 1 only)
# -1 indicates leftward velocity of ball
# 1 indicates rightward velocity of ball
# let $s3 represent the current y-component of velocity of the ball(can take values -1 and 1 only)
# -1 indicates downward velocity of ball
# 1 indicates upward velocity of ball
game_loop:
	# 1a. Check if key has been pressed
    lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t0, 0($t0)                  # Load first word from keyboard
    beq $t0, 1, handle_keyboard_input      # If first word 1, key is pressed
    
    
    li $v0, 32			    # run loop(check for key press) every 50ms only
    li $a0, 50	
    j game_loop
    
handle_ball_movement: 
	# ball moves
    
    # 1b. Check which key has been pressed
    handle_keyboard_input:          # A key is pressed
    lw $a0, 4($t0)                  # Load second word from keyboard
    beq $a0, 0x71, respond_to_q     # Check if the key q was pressed, quit game
    beq $a0, 0x61, respond_to_a     # Check if the key a was pressed, move paddle left
    beq $a0, 0x64, respond_to_d     # Check if the key d was pressed, move paddle right
    beq $a0, 0x78, respond_to_x     # Check if the key x was pressed, reset game
    # beq $a0, 0x73, respond_to_s	    # Check if the key s was presserd, start the game, this case has been dealt with in main
    li $v0, 1                       # ask system to print $a0
    syscall

    b main
    
    respond_to_q:		     ## would be beneficial to add quit message
    li $v0, 10                       # ask system to quit
    syscall
    
    respond_to_x:		     # resetting game
    j main			     ## would be beneficial to add reset game message


end: 
	li $v0, 10		    # end the program gracefully 
	syscall