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
    la $t0, YELLOW
    lw $t0, 0($t0)
    la $t1, ADDR_BALL 
    lw $t1, 0($t1)
    sw $t0, 0($t1)
    
    b game_loop            
    
exit:
    li $v0, 10              # terminate the program gracefully
    syscall

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

    li $v0, 1                       # ask system to print $a0
    syscall

    b main
    
    respond_to_Q:
        li $v0, 10
        syscall                      # Quit gracefully

    
    respond_to_A:
        la $t0, WHITE
        lw $t0, 0($t0)
        la $t1, ADDR_PADDLE
        lw $t1, 0($t1)
        sw $t0, -4($t1)
        sw $0, 8($t1)
        addi $t0, $t1, -4
        sw $t0, ADDR_PADDLE
        b game_loop
        
        li $v0, 10
        syscall                      # Quit gracefully

    
    respond_to_D:
        la $t0, WHITE
        lw $t0, 0($t0)
        la $t1, ADDR_PADDLE
        lw $t1, 0($t1)
        sw $t0, 12($t1)
        sw $0, 0($t1)
        addi $t0, $t1, 4
        sw $t0, ADDR_PADDLE
        b game_loop
 	li $v0, 10
	syscall                      # Quit gracefully

    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep

    #5. Go back to 1
    b game_loop
