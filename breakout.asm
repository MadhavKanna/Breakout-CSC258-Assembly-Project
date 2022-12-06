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
  
ADDR_PADDLE:  
   .word 0x10008f38    
  
ADDR_BALL:  
   .word 0x10008ebc   

ADDR_BRICK:  
   .word 0x000000  
  
BALL_VEL_X:  
   .word 1  
        
BALL_VEL_Y:  
   .word 1  
  
  
WALL:  
    .word 0x808080  
  
RED:  
    .word   0xff0000    # red  
  
GREEN:  
    .word   0x00ff00    # green  
  
BLUE:  
    .word   0x0000ff    # blue  
  
WHITE:  
    .word   0xffffff    # white  
      
YELLOW:  
    .word   0xffff00    # white  
      
BLACK:   
    .word   0x000000    # black  
   
CYAN:
 .word 0x00ffff		# cyan
 
PURPLE:
.word  0xa020f0		# purple

ORANGE:
 .word 0xffa500		# orange
  
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
      
    addi $a0, $a0, 128  
    jal draw_side_walls  
    
      
    la $a0, ADDR_DSPL  
    lw $a0, 0($a0)  
    addi $a0, $a0, 388 
    
    la $a1, RED  
    li $a2, 30  
    jal draw_line   # draw red line  
    addi $a0, $a0, 384
    jal draw_line   # draw red line
    
    addi $a0, $a0, -256
    la $a1, BLUE  
    jal draw_line   # draw blue line  
    addi $a0, $a0, 384
    jal draw_line   # draw blue line
    
    addi $a0, $a0, -256
    la $a1, GREEN     
    jal draw_line   # draw green line  
    
    
    
     
    # draw unbreakable bricks multi-hit bricks
    li $a0, 14
    li $a1, 3
    la $a2, ADDR_DSPL
    lw $a2, 0($a2)
    jal get_location_address
    
    
    
    addi $a0, $v0, 0
    la $a1, WHITE
    li $a2, 12
    jal draw_brick_pair
    
    addi $a0, $a0, -12
    la $a1, ORANGE
    li $a2, 36
    jal draw_brick_pair
    
    li $a0, 12
    li $a1, 4
    la $a2, ADDR_DSPL
    lw $a2, 0($a2)
    jal get_location_address
    
    addi $a0, $v0, 0
    la $a1, WHITE
    li $a2, 28
    jal draw_brick_pair
    
    li $a0, 10
    li $a1, 5
    la $a2, ADDR_DSPL
    lw $a2, 0($a2)
    jal get_location_address
    
    addi $a0, $v0, 0
    la $a1, WHITE
    li $a2, 44
    jal draw_brick_pair
    
    li $a0, 8
    li $a1, 6
    la $a2, ADDR_DSPL
    lw $a2, 0($a2)
    jal get_location_address
    
    addi $a0, $v0, 0
    la $a1, WHITE
    li $a2, 60
    jal draw_brick_pair
    
    li $a0, 7
    li $a1, 7
    la $a2, ADDR_DSPL
    lw $a2, 0($a2)
    jal get_location_address
    
    addi $a0, $v0, 0
    la $a1, WHITE
    li $a2, 68
    jal draw_brick_pair
    
    addi $a0, $a0, 16
    la $a1, CYAN
    li $a2, 36
    jal draw_brick_pair
    
    # draw multi-hit bricks
    # double hit bricks and triple-hit-bricks
    
    
    
    
    
    

      
      
    # draw the paddle and set initial x position address  
      
    li $a0, 14  
    li $a1, 30  
    la $a2, ADDR_DSPL  
    lw $a2, 0($a2)  
    jal get_location_address  
    addi $a0, $v0, 0  
    addi $s0, $v0, 0    # load paddle position address initially  
    la $a1, WHITE  
    li $a2, 4  
      
    jal draw_line  
      
    # draw the ball  
     li $a0, 15  
     li $a1, 29  
     la $a2, ADDR_DSPL  
     lw $a2, 0($a2)  
     jal get_location_address  
     addi $a0, $v0, 0     
     addi $s1, $v0, 0   # load ball position address initially  
     li $s2, 0      # load x component of ball velocity  
     li $s3, 1      # load y component of ball velocity  
     la $a1, YELLOW  
     li $a2, 1  
     jal draw_line  
      
    # check if the user has started the game by pressing 's' key                   
      
check_start_loop:  
    lw $t0, ADDR_KBRD               # $t0 = base address for keyboard  
    lw $t8, 0($t0)                  # Load first word from keyboard  
    beq $t8, 1, check_s      # If first word 1, key is pressed  
    j check_start_loop  
check_s:  
       
    lw $t7, 4($t0)  
       
    beq $t7, 0x73, game_loop        # if key pressed is 's', we start the game  
      
    li $v0, 32              # run loop(check for key press) every 50ms only  
    li $a0, 50  
    syscall               
    j check_start_loop          # if key pressed isn't 's' we check again  
      
    j end  

# draw_unbreakable_bricks(start_address, color_address, separation)-> void
    draw_brick_pair:
    # PROLOGUE
    addi $sp, $sp, -20
    sw $a0, 4($sp)
    sw $a1, 8($sp)
    sw $a2, 12($sp)
    sw $t1, 16($sp)
    sw $ra, 0($sp)
    
    # BODY
    addi $t1, $a2, 0
    
    li $a2, 1
    jal draw_line
    
    add $a0, $a0, $t1 
    
    jal draw_line
    
    
    
    # EPILOGUE
    
    lw $a0, 4($sp)
    lw $a1, 8($sp)
    lw $a2, 12($sp)
    lw $t1, 16($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 20
    
    jr $ra


# draw_line(start, colour_address, width) -> void  
#   Draw a line with width units horizontally across the display using the  
#   colour at colour_address and starting from the start address.  
#   Preconditions:  
#       - The start address can "accommodate" a line of width units  
# NOTE: This function is not a pure function, necessary to take care to reinitialize variables in case of bugs  
draw_line:  
    # PROLOGUE  
    addi $sp, $sp, -28  
    sw $ra, 0($sp)  
    sw $a0, 4($sp)  
    sw $a1, 8($sp)  
    sw $a2, 12($sp)  
    sw $t0, 16($sp)  
    sw $t1, 20($sp)  
    sw $t2, 24($sp)  
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
    lw $ra, 0($sp)  
    lw $a0, 4($sp)  
    lw $a1, 8($sp)  
    lw $a2, 12($sp)  
    lw $t0, 16($sp)  
    lw $t1, 20($sp)  
    lw $t2, 24($sp)  
    addi $sp, $sp, 28  
    jr $ra  
      

#draw_side_walls(start, colour_address) -> void  
# Draw the side walls on both sides for height units vertically   
# color loaded from color_address  
draw_side_walls:  
    lw $t0, 0($a1)      # load the colour_address  
    li $t1, 31      # load the height     
    li $t2, 0       # i = 0  
draw_side_walls_loop:   
  
    slt $t3, $t2, $t1   # set $t4 = 0   
    beq $t3, $0, draw_side_walls_epi    # end loop if $t4 = 0  
        sw $t0, 0($a0)        
        sw $t0, 124($a0)      
        addi $a0, $a0, 128  # move the unit pointer to the next line  
      
    addi $t2, $t2, 1        # i = i + 1  
      
    j draw_side_walls_loop  
      
draw_side_walls_epi:  
    jr $ra  
  
 
draw_ball:
    # Retrieve the colour
    lw $t0, PURPLE            # colour = *colour_address

    # Iterate $a2 times, drawing each unit in the line
    li $t1, 0 
    li $t5, 8                  # i = 0
draw_ball_loop:
    slt $t2, $t1, $t5           # i < width ?
    beq $t2, $0, update_ball # if not, then done
        sw $t0, 0($a3)          # Paint unit with colour
        addi $a3, $a3, 128        # Go to next unit

    addi $t1, $t1, 1   
    
             li $a0, 50			#Sleep for 500ms
   li $v0, 32			#Load syscall for sleep
   syscall
										#Execute
   sw $0, -128($a3)
   b draw_ball_loop         # i = i + 1

draw_ball_epi:
    jr $ra 
    
    
# get_location_address(x, y, start) -> int:  
# return the location address corresponding to x columns(units) and y(rows) where 1 unit = 4 bits  
# from the start address  
get_location_address:  
    # PROLOGUE
    # only $a0 and $a1 are modified
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    sw $a1, 8($sp)
    # BODY
    
    sll $a0, $a0, 2         # loc_x = x * 4  
    sll $a1, $a1, 7         # loc_y = y * 128  
    addi $v0, $a2, 0  
    add $v0, $v0, $a0  
    add $v0, $v0, $a1  
      
      
    # EPILOGUE
    lw $ra, 0($sp)
    lw $a0, 4($sp)
    lw $a1, 8($sp)
    addi $sp, $sp, 12
    
    jr $ra  
      
invert_velocity_x:   
    # PROLOGUE  
    
        addi $sp, $sp, -16  
        sw $ra, 0($sp)  
        sw $t2, 4($sp)  
        sw $t5, 8($sp)  
        sw $t6, 12($sp)  
        
        li		$a0, 100		#Pitch
	    li		$a1, 300		#Duration
	    li		$a2, 24			#Instrument
	    li		$a3, 127		#Volume
	    li		$v0, 31			#Load syscall
	    syscall					#Execute
	    
    # BODTY  
        li $t5, -1          # else invert velocity vector  
            mult $t2, $t5         
            mflo $t2  
              
            la $t6, BALL_VEL_X      # update BALL_VEL_X with the new x velocity component  
            sw $t2, 0($t6)  
              
        # EPILOGUE  
            lw $ra, 0($sp)  
        lw $t2, 4($sp)  
        lw $t5, 8($sp)  
        lw $t6, 12($sp)  
          
        jr $ra  
      
      
invert_velocity_y:  
    # PROLOGUE  
        addi $sp, $sp, -16  
        sw $ra, 0($sp)  
        sw $t2, 4($sp)  
        sw $t5, 8($sp)  
        sw $t6, 12($sp)  
        
        li		$a0, 100		#Pitch
	    li		$a1, 300		#Duration
	    li		$a2, 24			#Instrument
	    li		$a3, 127		#Volume
	    li		$v0, 31			#Load syscall
	    syscall					#Execute
          
    # BODY   
        li $t5, -1          # else invert velocity vector  
            mult $t3, $t5         
            mflo $t3  
              
            la $t6, BALL_VEL_Y      # update BALL_VEL_X with the new x velocity component  
            sw $t3, 0($t6)  
        # EPILOGUE  
            lw $ra, 0($sp)  
        lw $t2, 4($sp)  
        lw $t5, 8($sp)  
        lw $t6, 12($sp)  
          
        jr $ra   
  
  
  
# x-component of velocity of the ball can take values -1 and 1 only  
# -1 indicates leftward velocity of ball  
# 1 indicates rightward velocity of ball  
  
# y-component of velocity of the ball can take values -1 and 1 only  
# -1 indicates downward velocity of ball  
# 1 indicates upward velocity of ball  
game_loop:  
    # li $v0, 1     # ask the system to print 999 if game_loop has started  
    # li $a0, 999  
    # syscall  
    # 1a. Check if key has been pressed  
    lw $t0, ADDR_KBRD               # $t0 = base address for keyboard  
        lw $t8, 0($t0)                  # Load first word from keyboard  
          
        li $v0, 1                       # ask system to print $a0  
        addi $a0, $t8, 0  
        syscall  
          
        beq $t8, 1, handle_keyboard_input      # If first word 1, key is pressed  
   
    j move_ball  
 after_moving_ball:   
        li $v0, 32          # run loop(check for key press) every 50ms only  
        li $a0, 250   
        syscall  
         j game_loop  
          
      
        # 1b. Check which key has been pressed  
        handle_keyboard_input:          # A key is pressed  
        lw $a3, 4($t0)                  # Load second word from keyboard  
        beq $a3, 0x71, respond_to_q     # Check if the key q was pressed, quit game  
        beq $a3, 0x61, respond_to_a     # Check if the key a was pressed, move paddle left  
        beq $a3, 0x64, respond_to_d     # Check if the key d was pressed, move paddle right  
        #beq $a3, 0x78, respond_to_x     # Check if the key x was pressed, reset game  
        beq $a3, 0x70, respond_to_p 
          
        # move the ball according to the x and y component velocity vectors BALL_VEC_X and BALL_VEC_Y  
        move_ball:  
            la $t1, ADDR_BALL   # load all parameters of ball  
            lw $t1, 0($t1)    
            la $t2, BALL_VEL_X  
            lw $t2, 0($t2)  
            la $t3, BALL_VEL_Y  
            lw $t3, 0($t3)  
              
            # erase previous ball  
              
            addi $a0, $t1, 0  
            la $a1, BLACK  
            li $a2, 1  
            jal draw_line   # draw_line modifies the address that is passed into it, have to reload ADDR_BALL every time  
              
              
            # update position of new ball, check collision conditions and update  
            detect_collission_x:    # detect if there is a collision and change the velocity vectors accordingly  
            # beq $t2, $0, detect_collision_y   # if ball has no velocity in x axis, there can be no colision wrt x  
            # no sound here as well
            addi $a0, $t2, 0        # here, we check in the direction of x velocity component  
            li $a1, 0           # y-component is ignored for x direction collision  
            la $a2, ADDR_BALL  
            lw $a2, 0($a2)  
            jal get_location_address    # find address of potential next position of ball  
            addi $t4, $v0, 0  
             # no sound here.makes sound whenever ball shifts
            lw $t5, 0($t4)      # get color stored in address at next position of ball        
            beq $t5, $0, detect_collision_y # if the next position is empty(black), detect if there is collision in y axis  
            li		$a0, 100		#Pitch
	    li		$a1, 300		#Duration
	    li		$a2, 24			#Instrument
	    li		$a3, 127		#Volume
	    li		$v0, 31			#Load syscall
	    syscall					#Execute
	     
            jal invert_velocity_x  
              
            la $t0, WALL  
            lw $t0, 0($t0)  
            la $t1, WHITE  
            lw $t1, 0($t1)  
            
            # no sound here
              
            beq $t5, $t0, update_ball   # if there's a wall or paddle at next position of ball, skip to drawing next position of ball  
            beq $t5, $t1, update_ball  # don't delete the wall/paddle  
            
            
           # no sound
            addi $a0, $t4, 0		# load potential next position of the ball
            jal handle_brick_collision
            			
            
            detect_collision_y:  
            
               
            li $a0, 0           # x component is ignored for y direction collision  
            addi $a1, $t3, 0        # we chekc in the direction of y velocity component  
            la $a2, ADDR_BALL  
            lw $a2, 0($a2)  
            jal get_location_address    # find address of potential next position of ball  
            addi $t4, $v0, 0  
              
              
            lw $t5, 0($t4)          # get color stored in address at next position of ball  
            beq $t5, $0, detect_collision_diagonal    # if the next position is empty(black), draw new ball in the new position. There was no collision  
            li		$a0, 100		#Pitch
	    li		$a1, 300		#Duration
	    li		$a2, 24			#Instrument
	    li		$a3, 127		#Volume
	    li		$v0, 31			#Load syscall
	    syscall					#Execute
	    
            jal invert_velocity_y  
              
            la $t0, WALL  
            lw $t0, 0($t0)  
            la $t1, WHITE  
            lw $t1, 0($t1)  
            beq $t5, $t0, update_ball# if there's a wall or paddle at next position of ball, skip to drawing next position of ball  
            beq $t5, $t1, update_ball  # don't delete the wall/paddle  
            					#Execute  
            
            addi $a0, $t4, 0		# load potential next position of the ball
            jal handle_brick_collision
            
            
            
            detect_collision_diagonal:
            addi $a0, $t2, 0         
            addi $a1, $t3, 0        # we check in the direction of ball taking into account both x and y components
            la $a2, ADDR_BALL  
            lw $a2, 0($a2)  
            jal get_location_address    # find address of potential next position of ball  
            addi $t4, $v0, 0  
              
              
            lw $t5, 0($t4)          # get color stored in address at next position of ball  
            beq $t5, $0, update_ball    # if the next position is empty(black), draw new ball in the new position. There was no collision  
            li		$a0, 100		#Pitch
	    li		$a1, 300		#Duration
	    li		$a2, 24			#Instrument
	    li		$a3, 127		#Volume
	    li		$v0, 31			#Load syscall
	    syscall					#Execute
	    
            jal invert_velocity_y 
            jal invert_velocity_x 
              
            la $t0, WALL  
            lw $t0, 0($t0)  
            la $t1, WHITE  
            lw $t1, 0($t1)  
            beq $t5, $t0, update_ball   # if there's a wall or paddle at next position of ball, skip to drawing next position of ball  
            beq $t5, $t1, update_ball   # don't delete the wall/paddle  
            					#Execute  
            addi $a0, $t4, 0		# load potential next position of the ball        
            jal handle_brick_collision
            
            # update new position of ball after calculating new velcity vectors  
            update_ball:  
            # no sound
            la $a0, BALL_VEL_X  
            lw $a0, 0($a0)  
            la $a1, BALL_VEL_Y  
            lw $a1, 0($a1)  
            la $a2, ADDR_BALL  
            lw $a2, 0($a2)  
              
            jal get_location_address  
            addi $t0, $v0, 0          
            la $t1, ADDR_BALL  
            sw $t0, 0($t1)   
            
            # check if the ball is behind the paddle
            # and game is over
            li $a0, 0
            li $a1, 31
            la $a2, ADDR_DSPL	
            lw $a2, 0($a2)
            jal get_location_address
            bge $t0, $v0, end
            # no sound  
              
            draw_new_ball:  
            la $a0, ADDR_BALL  
            lw $a0, 0($a0)  
            la $a1, YELLOW  
            li $a2, 1  
            jal draw_line  
              
        j after_moving_ball       
  
      	
      	# handle_brick_collision(potential_position_of_ball)
      	handle_brick_collision:
      	    
            
            lw $t0, 0($a0)	# get color at previous position of ball
            
            la $t1, CYAN
            lw $t1, 0($t1)
            la $t2, ORANGE
            lw $t2, 0($t2)
            # select which color to draw in place of the potential_position_of_ball
            beq $t0, $t2, load_cyan
            beq $t0, $t1, load_green
            j load_black
            # else 
            la $a1, BLACK
            
            load_cyan:
            	la $a1, CYAN
            	j draw_color
            load_green:
            	la $a1, GREEN
            	j draw_color
            load_black:
            	la $a1, BLACK
            	
            
            draw_color:
            # previous location of ball already in $a0
            li $a2, 1  
            jal draw_line  
            addi $a3, $a0, 128
            sw $a0, ADDR_BRICK
            jal draw_ball	
            	
        jr $ra
      	
        respond_to_q:  
        
        li $v0, 10                       # ask system to quit  
        syscall  
        
        respond_to_p: 
        li $a0, 50
        li $v0, 32                       # ask system to pause
        syscall
        j check_start_loop
  
        respond_to_a:  
  
    # update screen and position variables to reflect movement to the left  
          
        la $t5, ADDR_PADDLE  
        lw $t7, 0($t5)  
          
        # check if the position to right of paddle isn't wall (paddle collides)  
        addi $t3, $t7, -4  
        lw $t4, 0($t3)  
        la $t2, WALL  
        lw $t2, 0($t2)  
          
          
        beq $t4, $t2, game_loop # go back to game_loop, and don't update position of paddle if there is collision.   
                    # collision occurs when the the unit to right of paddle isn't empty space  
          
        addi $a0, $t7, 0  
        la $a1, BLACK            # erasing the previous paddle  
        li $a2, 4  
        jal draw_line  
  
        li $t0, 4  
        sub $t7, $t7, $t0  
        sw $t7, 0($t5)           # save the newly calculated position of paddle to ADDR_PADDLE  
          
        addi $a0, $t7, 0  
        la $a1, WHITE            # drawing the new paddle with the new position  
        li $a2, 4  
        jal draw_line     
          
    j move_ball        
          
      
        respond_to_d:   
        # update screen and position variables to reflect movement to the right  
          
        la $t5, ADDR_PADDLE  
        lw $t7, 0($t5)  
          
        # check if the position to right of paddle isn't wall (paddle collides)  
        addi $t3, $t7, 16  
        lw $t4, 0($t3)  
        la $t2, WALL  
        lw $t2, 0($t2)  
          
          
        beq $t4, $t2, game_loop # go back to game_loop, and don't update position of paddle if there is collision.   
                    # collision occurs when the the unit to right of paddle isn't empty space  
          
        addi $a0, $t7, 0  
        la $a1, BLACK            # erasing the previous paddle  
        li $a2, 4  
        jal draw_line  
  
        li $t0, 4  
        add $t7, $t7, $t0  
        sw $t7, 0($t5)           # save the newly calculated position of paddle to ADDR_PADDLE  
          
        addi $a0, $t7, 0  
        la $a1, WHITE            # drawing the new paddle with the new position  
        li $a2, 4  
        jal draw_line     
          
    j move_ball   
      
      
end:   
    
    li $v0, 10          # end the program gracefully   
    syscall  
