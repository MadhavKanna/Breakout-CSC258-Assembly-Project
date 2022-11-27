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
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000

ADDR_PADDLE:
   .word 0x10008f38  

ADDR_BALL:
   .word 0x10008ebc 

X:
   .word 16
      
Y:
   .word 29


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
    la $t0, WALL
    lw $t0, WALL       
    la $t1, ADDR_DSPL 
    lw $t1, 0($t1)     
    la $t5, ADDR_DSPL 
    lw $t5, 0($t5)       
    li $t2, 32
    li $t3, 0
    li $t6, 0
    li $t7, 0
    

draw_line_loop:
    slt $t4, $t3, $t2
    beq $t4, $0, draw_column_loop
        sw $t0, 0($t1)
        addi $t1, $t1,4
    addi $t3, $t3, 1      
    b draw_line_loop 
draw_column_loop:
    slt $t4, $t6, $t2
    beq $t4, $0, next
        sw $t0, 0($t5)
        sw $t0, 124($t5)
        addi $t5, $t5, 128
    addi $t6, $t6, 1 
    b draw_column_loop
 
next:      
    la $t1, ADDR_DSPL 
    lw $t1, 0($t1)
    addi $t1, $t1, 256           
    li $t2, 32
    li $t3, 0

draw_brick_loop:
    slt $t4, $t3, $t2
    beq $t4, $0, draw_padle_and_ball
        la $t0, RED
        lw $t0, 0($t0)
        sw $t0, 0($t1)
        
        la $t0, BLUE
        lw $t0, 0($t0)
        sw $t0, 128($t1)
        
        la $t0, GREEN
        lw $t0, 0($t0)
        sw $t0, 256($t1)
        
        addi $t1, $t1, 4
    addi $t3, $t3, 1  
    b draw_brick_loop
    
get_location_address:
    # Each unit is 4 bytes. Each row has 32 units (128 bytes)
	sll 	$a3, $a3, 2				# x = x * 4
	sll 	$a1, $a1, 7             # y = y * 128

    # Calculate return value
	la $v0, ADDR_DSPL 			# res = address of ADDR_DSPL
        lw      $v0, 0($v0)             # res = address of (0, 0)
	add 	$v0, $v0, $a3			# res = address of (x, 0)
	add 	$v0, $v0, $a1           # res = address of (x, y)

       jr $ra

draw_ball:
    # Retrieve the colour
    lw $t0, YELLOW             # colour = *colour_address

    # Iterate $a2 times, drawing each unit in the line
    li $t1, 0                   # i = 0
draw_ball_loop:
    slt $t2, $t1, $a2           # i < width ?
    beq $t2, $0, game_loop  # if not, then done
        sw $t0, 0($a3)          # Paint unit with colour
        addi $a3, $a3, -128        # Go to next unit

    addi $t1, $t1, 1   
    
             li $a0, 50			#Sleep for 500ms
   li $v0, 32			#Load syscall for sleep
   syscall
										#Execute
   sw $0, 128($a3)
   b draw_ball_loop         # i = i + 1

draw_line_epi:
    jr $ra
        
   
draw_padle_and_ball:   

    #paddle
    la $t0, WHITE
    lw $t0, 0($t0)
    la $t1, ADDR_PADDLE
    lw $t1, 0($t1)
    sw $t0, 0($t1)
    sw $t0, 4($t1)
    sw $t0, 8($t1)
    #ball

    lw $a3, X
    lw $a1, Y
    jal get_location_address

    addi $a3, $v0, 0            # Put return value in $a0
    li $a2, 20
    jal draw_ball               # Draw red line

game_loop:
	# 1a. Check if key has been pressed
	li 		$v0, 32
	li 		$a0, 1
	syscall

    lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t0)                  # Load first word from keyboard
    beq $t8, 1, keyboard_input      # If first word 1, key is pressed
    b main
    
    # 1b. Check which key has been pressed
    keyboard_input:                     # A key is pressed
    lw $a0, 4($t0)                  # Load second word from keyboard
    beq $a0, 0x71, respond_to_Q     # Check if the key q was pressed
    beq $a0, 0x61, respond_to_A     # Check if the key a was pressed
    beq $a0, 0x64, respond_to_D     # Check if the key d was pressed
    beq $a0, 0x78, respond_to_X     # Check if the key x was pressed

    li $v0, 1                       # ask system to print $a0
    syscall

    b main
    
    respond_to_X:
    li $v0, 10                       # ask system to quit
    syscall
    
    respond_to_Q:
   
    
    respond_to_A:
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
        

                        
    respond_to_D:
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
                   
