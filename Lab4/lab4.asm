####################################################################################################################
# Created by: Malhan, Yukti
#             ymalhan
#             31st May 2021
#
# Assignment: Lab 4: Functions and Graphics
#                    CSE 12, Computer Systems and Assembly Language
#                    UC Santa Cruz, Spring 2021
#
# Description: This program prints a graphic on a 128x128 pixel bit map
#
# Notes: This program is intended to be run from the MARS IDE
####################################################################################################################
# Spring 2021 CSE12 Lab 4 Template
######################################################
# Macros made for you (you will need to use these)
######################################################

# Macro that stores the value in %reg on the stack 
#	and moves the stack pointer.
.macro push(%reg)
	subi $sp $sp 4
	sw %reg 0($sp)
.end_macro 

# Macro takes the value on the top of the stack and 
#	loads it into %reg then moves the stack pointer.
.macro pop(%reg)
	lw %reg 0($sp)
	addi $sp $sp 4	
.end_macro

#################################################
# Macros for you to fill in (you will need these)
#################################################

# Macro that takes as input coordinates in the format
#	(0x00XX00YY) and returns x and y separately.
# args: 
#	%input: register containing 0x00XX00YY
#	%x: register to store 0x000000XX in
#	%y: register to store 0x000000YY in
.macro getCoordinates(%input %x %y)
	# YOUR CODE HERE
	push(%input)                  # push input to stack with push macro
	andi %y, %input, 0x000000FF   # and input with FF to store the correct y (masking)
	srl %input, %input, 16        # shift input by 16 bits and store in x
	andi %x, %input, 0x000000FF   # and input with FF to store the correct x (masking)
	pop(%input)                   # pop input to "reset" stack
.end_macro

# Macro that takes Coordinates in (%x,%y) where
#	%x = 0x000000XX and %y= 0x000000YY and
#	returns %output = (0x00XX00YY)
# args: 
#	%x: register containing 0x000000XX
#	%y: register containing 0x000000YY
#	%output: register to store 0x00XX00YY in
.macro formatCoordinates(%output %x %y)
	# YOUR CODE HERE
	push(%x)             # push x to stack
	push(%y)             # push y to stack
	sll %x, %x, 16       # shift x by 16 bits
	add %output, %x, %y  # add x and y and store to output
	pop(%y)              # pop y
	pop(%x)              # pop x
	
.end_macro 

# Macro that converts pixel coordinate to address
# 	  output = origin + 4 * (x + 128 * y)
# 	where origin = 0xFFFF0000 is the memory address
# 	corresponding to the point (0, 0), i.e. the memory
# 	address storing the color of the the top left pixel.
# args: 
#	%x: register containing 0x000000XX
#	%y: register containing 0x000000YY
#	%output: register to store memory address in
.macro getPixelAddress(%output %x %y)
	# YOUR CODE HERE
	push(%x)                           # push x,y
	push(%y)
	mul %output, %y, 128               # output = 128 * y
	add %output, %output, %x           # output = x + output
	mul %output, %output, 4            # output = output * 4 
	addi %output, %output, 0xFFFF0000  # output = output + origin
	pop(%y)
	pop(%x)                            # pop y,x
.end_macro


.text
# prevent this file from being run as main
li $v0 10 
syscall

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Subroutines defined below
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#*****************************************************
# Clear_bitmap: Given a color, will fill the bitmap 
#	display with that color.
# -----------------------------------------------------
# Inputs:
#	$a0 = Color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
clear_bitmap: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
# REGISTER USAGE
# t0 for origin, increment it by 4
# t1 for max pixel address
	li $t0, 0xFFFF0000         # t0 = origin address
	addi $t1, $t0, 65536       # t1 = max address to reach (address of last pixel) 128*128*4
	loop: nop
	    beq $t0, $t1, end      # loop through and add color, end if t0 = t1
	    nop
	    sw $a0, 0($t0)         # store given color
	    addi $t0, $t0, 4       # increment by 4
	    j loop
	    nop
	end: nop
 	    jr $ra
 	    nop

#*****************************************************
# draw_pixel: Given a coordinate in $a0, sets corresponding 
#	value in memory to the color given by $a1
# -----------------------------------------------------
#	Inputs:
#		$a0 = coordinates of pixel in format (0x00XX00YY)
#		$a1 = color of pixel in format (0x00RRGGBB)
#	Outputs:
#		No register outputs
#*****************************************************
draw_pixel: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
# REGISTER USAGE
# t0 to get x cord
# t1 to get y cord
# t2 to store pixel address
	push($t2)
	getCoordinates($a0 $t0 $t1)     # get x (t0) and y (t1) from input (a0)
	getPixelAddress($t2 $t0 $t1)    # get pixel address using x and y and store in t2
	sw $a1, ($t2)                   # store to a1
	pop($t2)
	jr $ra
	nop
	
#*****************************************************
# get_pixel:
#  Given a coordinate, returns the color of that pixel	
#-----------------------------------------------------
#	Inputs:
#		$a0 = coordinates of pixel in format (0x00XX00YY)
#	Outputs:
#		Returns pixel color in $v0 in format (0x00RRGGBB)
#*****************************************************
get_pixel: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
# REGISTER USAGE
# t0 to get x cord
# t1 to get y cord
# t2 for pixel address
	push($t2)
	getCoordinates($a0 $t0 $t1)     # get x (t0) and y (t1) from input (a0)
	getPixelAddress($t2 $t0 $t1)    # get pixel address using x and y and store in t2
	lw $v0, ($t2)                   # load to v0
	pop($t2)
	jr $ra
	nop

#*****************************************************
# draw_horizontal_line: Draws a horizontal line
# ----------------------------------------------------
# Inputs:
#	$a0 = y-coordinate in format (0x000000YY)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
draw_horizontal_line: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
# REGISTER USAGE
# t0 to get x cord
# t1 to get y cord
# t2 for pixel address, increment by 4
# t3 for counter, increment by 1 till 128
	push($t2)
	push($t3)
	getCoordinates($a0 $t0 $t1)   # get x (t0) and y (t1) from input (a0)
	getPixelAddress($t2 $t0 $t1)  # get pixel address using x and y and store in t2
	li $t3, 0                     # t3 = 0, set counter              
	loop1: nop
	    beq $t3, 128, end1     # loop through and add color, end if t3 = 128
	    nop
	    sw $a1, ($t2)          # store given color
	    addi $t2, $t2, 4       # increment t2 by 4
	    addi $t3, $t3, 1       # increment t3 by 1
	    j loop1                # loop again
	    nop
	end1: nop
	    pop($t3)
	    pop($t2)
 	    jr $ra
 	    nop

#*****************************************************
# draw_vertical_line: Draws a vertical line
# ----------------------------------------------------
# Inputs:
#	$a0 = x-coordinate in format (0x000000XX)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
draw_vertical_line: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
# REGISTER USAGE
# t0 to get x cord
# t1 to get y cord
# t2 for pixel address, increment by 512 (128 * 4)
# t3 for counter, increment by 1 till 128
	push($t2)
	push($t3)
	getCoordinates($a0 $t0 $t1)   # get x (t0) and y (t1) from input (a0)
	getPixelAddress($t2 $t1 $t0)  # get pixel address using x and y and store in t2, switch t1 and t0 positions for right x
	li $t3, 0                     # t3 = 0, set counter              
	loop2: nop
	    beq $t3, 128, end2     # loop through and add color, end if t3 = 128
	    nop
	    sw $a1, ($t2)          # store given color
	    addi $t2, $t2, 512     # increment t2 by 512
	    addi $t3, $t3, 1       # increment t3 by 1
	    j loop2                # loop again
	    nop
	end2:
	    pop($t3)
	    pop($t2)
 	    jr $ra
 	    nop

#*****************************************************
# draw_crosshair: Draws a horizontal and a vertical 
#	line of given color which intersect at given (x, y).
#	The pixel at (x, y) should be the same color before 
#	and after running this function.
# -----------------------------------------------------
# Inputs:
#	$a0 = (x, y) coords of intersection in format (0x00XX00YY)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
draw_crosshair: nop
	push($ra)
	
	# HINT: Store the pixel color at $a0 before drawing the horizontal and 
	# vertical lines, then afterwards, restore the color of the pixel at $a0 to 
	# give the appearance of the center being transparent.
	
	# Note: Remember to use push and pop in this function to save your t-registers
	# before calling any of the above subroutines.  Otherwise your t-registers 
	# may be overwritten.  
	
	# YOUR CODE HERE, only use t0-t7 registers (and a, v where appropriate)
# REGISTER USAGE
# t0 to save a0 (cords)
# t1 to get x cord
# t2 to get y cord
# t3 to get pixel address
# t4 to color intersection
	push($t0)
	push($t1)
	push($t2)
	push($t3)
	push($t4)
	
	move $t0, $a0                 # save a0 in t0
	getCoordinates($t0 $t1 $t2)   # get corrdinates x and y -> t1 and t2
	getPixelAddress($t3 $t1 $t2)  # get pixel address in t3
	lw $t4, ($t3)                 # load into t4
	
	move $a0, $t1                 # move x coordinate to a0
	jal draw_vertical_line        # draw vertical line using x coordinate
	nop
	
	move $a0, $t2                 # move y coordinate to a0
	jal draw_horizontal_line      # draw horizontal line with y coordinate
	nop
	
	sw $t4, ($t3)                 # store t3 to t4
	
	pop($t4)
	pop($t3)
	pop($t2)
	pop($t1)
	pop($t0)

	# HINT: at this point, $ra has changed (and you're likely stuck in an infinite loop). 
	# Add a pop before the below jump return (and push somewhere above) to fix this.
	pop($ra)
	jr $ra
	nop
