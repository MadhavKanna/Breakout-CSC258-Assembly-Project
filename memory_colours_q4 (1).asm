################ CSC258H1F Fall 2022 Assembly Final Project ##################
# This file contains our implementation of Breakout.
#
# Student 1: Madhav Kanna Thenappan, 1007841659
# Student 2: Mugdha Banthwan, 1007630324
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

# The base address of the paddle
ADDR_PADDLE:
   .word 0x10008f38  

# The base address of the ball
ADDR_BALL:
   .word 0x10008ebc 

# The initial X coordinate of the ball
BALL_VEL_X:
   .word 15

# The initial Y coordinate of the ball    
BALL_VEL_Y:
   .word 29

# The color of the wall
WALL:
   .word 0x808080

# The color of the first layer of bricks
RED:
    .word	0xff0000    # red

# The color of the third layer of bricks   
GREEN:
    .word	0x00ff00    # green

# The color of the second layer of bricks
BLUE:
    .word	0x0000ff    # blue

# The color of the paddle
WHITE:
    .word	0xffffff    # white

# The color of the ball   
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
    la $a1, BLUE	
    jal draw_line	# draw blue line
    addi $a0, $a0, 8
    la $a1, GREEN
    jal draw_line	# draw green line
   
    
    # draw the paddle at the  base address
    
    lw $a0, ADDR_PADDLE
    la $a1, WHITE
    li $a2, 3
    jal draw_line
    
    
    # get the  base address for ball according to X and Y coordinates
    lw $a3, BALL_VEL_X
    lw $a1, BALL_VEL_Y
    jal get_location_address

    # draw the paddle at the  base address
    addi $a3, $v0, 0            
    li $a2, 27
    jal draw_ball
    
   b game_loop

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
	sll $a3, $a3, 2 		# loc_x = x * 4
	sll $a1, $a1, 7 	# loc_y = y * 128
	la $v0, ADDR_DSPL	
	lw $v0, 0($v0)	
	add $v0, $v0, $a3
	add $v0, $v0, $a1
	
	jr $ra


		
draw_ball:
    # Retrieve the colour
    lw $t0, YELLOW             
    lw $t1, ($a3)  
    lw $t7, -128($a3)   


bgeu $a3, 0x10008f78, end                                 
beq $t7, $0, draw_ball_loop
beq $t7, 0x808080, bounce
bne $t7, $0, remove 

bounce:
    sw $0, 0($a3)  
    lw $t6, BALL_VEL_Y
    li $t7, 29
    sub $t6, $t7, $t6
    li $t7, 128
    mult $t6, $t7  
    mfhi $t6
    add $a3, $a3, $t6
    jal game_loop
    j draw_ball
    
remove:
     sw $0, -128($a3)          # Paint unit with colour
     addi $a3, $a3, 2048
     jal game_loop
     j draw_ball
     
draw_ball_loop:
     sw $t0, 0($a3)          # Paint unit with colour
     addi $a3, $a3, -128        # Go to next unit
     lw $t6, BALL_VEL_Y
     addi $t6, $t6, -1
     sw $t6, BALL_VEL_Y  
    
   li $v0, 32			#Load syscall for sleep
   li $a0, 50			#Sleep for 500ms
   syscall
										
   sw $0, 128($a3)
   jal game_loop
   b draw_ball       


game_loop:
        li $v0, 32			# run loop(check for key press) every 50ms only
  	li $a0, 50	
  	syscall
	# 1a. Check if key has been pressed
   	 lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
   	 lw $t8, 0($t0)                  # Load first word from keyboard
   	 beq $t8, 1, handle_keyboard_input      # If first word 1, key is pressed
    
    
  	  	
    	 b main
    	
    
    	# 1b. Check which key has been pressed
    	handle_keyboard_input:          # A key is pressed
    	lw $a0, 4($t0)                  # Load second word from keyboard
    	beq $a0, 0x71, respond_to_q     # Check if the key q was pressed, quit game
    	beq $a0, 0x61, respond_to_a     # Check if the key a was pressed, move paddle left
    	beq $a0, 0x64, respond_to_d     # Check if the key d was pressed, move paddle right
    
    	respond_to_q:		     
    	li $v0, 10                      
    	syscall

    	respond_to_a:
        la $t1, ADDR_PADDLE
        lw $t1, 0($t1)
        li $t2, 0x10008f08
        slt $t4, $t1, $t2
        beq $t4, 1, game_loop
        la $t1, ADDR_PADDLE
        lw $t1, 0($t1)
        la $t0, WHITE
        lw $t0, 0($t0)
        sw $t0, -4($t1)
        sw $0, 8($t1)
        addi $t0, $t1, -4
        sw $t0, ADDR_PADDLE
        b game_loop
    
    	respond_to_d: 
        la $t1, ADDR_PADDLE
        lw $t1, 0($t1)
        li $t2, 0x10008f70
        slt $t4, $t1, $t2
        beq $t4, 0, game_loop
        la $t0, WHITE
        lw $t0, 0($t0)
        la $t1, ADDR_PADDLE
        lw $t1, 0($t1)
        sw $t0, 12($t1)
        sw $0, 0($t1)
        addi $t0, $t1, 4
        sw $t0, ADDR_PADDLE
        b game_loop
    
end: 
	li $v0, 10		    # end the program gracefully 
	syscall
