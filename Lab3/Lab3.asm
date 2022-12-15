####################################################################################################################
# Created by: Malhan, Yukti
#             ymalhan
#             14th May 2021
#
# Assignment: Lab 3: ASCII-risks (Asterisks)
#                    CSE 12, Computer Systems and Assembly Language
#                    UC Santa Cruz, Spring 2021
#
# Description: This program asks for user input and prints a pattern based on the integer entered
#
# Notes: This program is intended to be run from the MARS IDE
####################################################################################################################

###### PSEUDOCODE ######
## USER INPUT LOOP
# start loop:
#       ask for input “enter num > 0”
#       if entered num <=0: jump to invalid entry
#              store user input in register, uR
#              set a userCount to 0
#              jump to outermost loop start
# invalid entry:
#       print “Invalid Entry!”
#       jump to start loop:

## OUTERMOST LOOP
# outermost loop start:
#       if userCount = uR: jump to exit Program
#              count1 = 0
#              jump to print tab loop start
# exit Program:
#       exit program syscall

## PRINT BEGINNING TAB LOOP
# print tab loop start:
#       if count1= uR - userCount - 1: jump to pattern print start
#              print tab
#              count1 += 1
#              count2 = 0
#              jump to print tab loop start

## PRINT PATTERN LOOP
# pattern print start:
#       endLoop = 2 * userCount + 1
#       if count2 < endloop: jump to first inner if
#              userCount += 1
#              print new line
#              jump to outermost loop start
#              first inner if: count2 != 0: jump to second inner if 
#                    print num
#                    if count2 < 2 * userCount: jump to inner tab print
#                           num += 1
#                           count2 +=1
#                           jump to pattern print start
#              second inner if: count2 != 2*userCount: jump to else
#                    print num
#                    if count2 < 2 * userCount: jump to inner tab print
#                           num += 1
#                           count2 +=1
#                           jump to pattern print start
# inner tab print:
#       print tab
#       num += 1
#       count2 += 1
#       jump to pattern print start
# else:
#       print star and tab
#       count2 += 1
#       jump to pattern print start
##################################################################################################################

# REGISTER USAGE
# s0 = 1, num in pseudo - is the integers in pattern
# s1 = user input, uR in pseudo
# s2 = 2 * userCount + 1, endLoop in pseudo
# s3 = 2 * userCount, used in multiplication and if statements
# t0 = s1 - t1 - 1 (uR - userCount - 1)
# t1 = 0, userCount in pseudo
# t2 = 0, count1 in pseudo
# t3 = 0, count2 in pseudo

.data
prompt: .asciiz "Enter the height of the pattern (must be greater than 0):\t"
invalid_num: .asciiz "Invalid Entry!\n"
newLine: .asciiz "\n"
tab: .asciiz "\t"
starAndTab: .asciiz "*\t" 

.text
li $s0, 1     # set s0 to 1, will be the number to print in pattern (num)

###user input loop from pseudo###
startUserLoop:
    la $a0, prompt        # while loop to print prompt to enter a number
    li $v0, 4             # $v0 = 4 to print prompt with address in $a0
    syscall

    li $v0, 5             # read an int in $v0
    syscall
    
    move $s1, $v0         # save user int to register $s1
    
    blez $s1, invalid     # check if input is less than or equal to zero, jump to invalid if it is
    NOP
       li $t1, 0          # set t1 to 0, this will be our userCounter
       j outermostLoopStart     # jump to next loop after setting a counter and saving the user input
       NOP   

invalid:
    la $a0, invalid_num   # print invalid entry
    li $v0, 4             # $v0 = 4 to print string with syscall
    syscall
    j startUserLoop       # go to user loop to prompt user again
    NOP
    
###outermost loop from pseudo###
outermostLoopStart:
    beq $t1, $s1, exitProgram     # exit the program if userCount = user input (uR in pseudo)
    NOP
        li $t2, 0                 # set a "count1" from pseudo to 0, will be our counter when printing beginning tabs
        j printTabLoopStart
        NOP
    
exitProgram:
    li $v0, 10            # store 10 in v0 and exit program
    syscall
    
###print beginning tab loop from pseudo###
printTabLoopStart:
    sub $t0, $s1, $t1                     # subtract user input (uR) by userCount and store in t0
    subi $t0, $t0, 1                      # subtract t0 by 1 and store in t0
    beq $t2, $t0, patternPrintStart2       # if counter(count1) = s1 - t1 - 1 then initialize counter (count2)
    NOP
        la $a0, tab              # load tab into a0
        li $v0, 4                # load 4 into v0 to print out tab string
        syscall
        addi $t2, $t2, 1         # increment t2 (count1) by 1        
        j printTabLoopStart      # jump to start of print tab loop
        NOP
        
patternPrintStart2: 
li $t3, 0                        # initialize count2 to 0 ($t3)

###print pattern loop from pseudo###
patternPrintStart:
     li $s3, 2                     # set s3 to 2, we will use this to multiply and find "endLoop" from pseudo
     mul $s3, $s3, $t1             # multipy s3 (2) by t1 (userCount) and store in s3
     addi $s2, $s3, 1              # add 1 to s3 and store in s2, this is our endLoop checker
     blt $t3, $s2, firstInnerIf    # if t3 (count2) < s2 (endloop) go to first inner if
     NOP
         addi $t1, $t1, 1          # increment t1 (userCount) by 1
         la $a0, newLine           # store new line in a0
         li $v0, 4                 # store 4 in v0 so syscall can print a new line
         syscall
         j outermostLoopStart     # jump to outermost loop
         NOP
         
firstInnerIf:
    beq $t3, $zero, code    # if t3 (count2) != zero, jump to second inner if
    NOP
    bne $t3, $s3, else          # if t3 (count2) != s3 (2*userCount), jump to else
    NOP
    code:
        la $a0, ($s0)                # load contents of s0 (num) to a0
        li $v0, 1                    # v0 = 1 to print integer num
        syscall
        blt $t3, $s3, innerTabPrint    # if t3 (count2) < s3 (2*userCount), jump to innerTabPrint
        NOP
             addi $s0, $s0, 1          # increment s0 (num) by 1
             addi $t3, $t3, 1          # increment t3  (count2) by 1
             j patternPrintStart       # jump to print pattern start
             NOP

innerTabPrint:
    la $a0, tab            # load tab into a0
    li $v0, 4              # load 4 into v0 to print out tab string
    syscall
    
    addi $s0, $s0, 1         # increment s0 (num) by 1
    addi $t3, $t3, 1         # increment t3  (count2) by 1
    j patternPrintStart      # jump to print pattern start
    NOP
    
else:
    la $a0, starAndTab            # load star and tab into a0
    li $v0, 4                     # load 4 into v0 to print out string
    syscall
    
    addi $t3, $t3, 1              # increment t3 (count2) by 1
    j patternPrintStart
    NOP