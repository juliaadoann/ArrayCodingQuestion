#
# CMPUT 229 Public Materials License
# Version 1.0
#
# Copyright 2023 University of Alberta
#
# Copyright 2017 Kristen Newbury
# Copyright 2023 Liam Houston
#
# This software is distributed to students in the course
# CMPUT 229 - Computer Organization and Architecture I at the University of
# Alberta, Canada.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the disclaimer below in the documentation
#    and/or other materials provided with the distribution.
#
# 2. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from this
#    software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
#-------------------------------
# Caesar Cipher
# Author: Liam Houston
# Date: May 3, 2023
#
# Adapted from:
# Reverse Polish Notation Calculator 
# Author: Kristen Newbury
# Date: August 9, 2017
#
# This program reads a file and places it in memory
# and then jumps to the student code under the label "encrypt5lettword" -
# and prints the output from the students function.
#
#-------------------------------

		.data
inputStream:    # space for input string to be stored
        .space 2048
noFileStr:
        .asciz "ERROR: Couldn't open specified file.\n"
inputErrStr:
		.asciz "ERROR: Input file is invalid.\n"
invalidStrAddress:
		.asciz "ERROR: You are returning a string that wrote over the original unencrypted string provided to you. See the webpage for this lab for details on how to allocate new memory for your string."
main_newline:
		.asciz "\n"

        
		.text
main:
        lw	 a0, 0(a1)	    # Put the filename pointer into a0
        li	 a1, 0		    # Flag: Read Only
        li	 a7, 1024	    # Service: Open File
        # File descriptor gets saved in a0 unless an error happens
        ecall
        bltz	a0, main_err        # Negative means open failed
    
        la	a1, inputStream	    # write into my binary space
        li	a2, 2048            # read a file of at max 2kb
        li      a7, 63              # Read File Syscall
        ecall
    	

        la	t0, inputStream # use t0 as a pointer to input from file
        li	t1, 10 # t1 <- '\n'
main_findUpperCaseKeyLoop: 
	lbu	t2, 0(t0) # t2 <- currentChar
	beq	t1, t2, main_foundUpperCaseKey # if currentChar == '\n', then next char is key
	addi 	t0, t0, 1 # else increment t0 to the next char
	j 	main_findUpperCaseKeyLoop 
        
main_foundUpperCaseKey: 
	sb	x0, 0(t0) # replace the newline character with a null terminator so we can deliver this string
	addi	a0, t0, 1 # a0 points to character after new line
	
	addi	sp, sp, -8
	sw	a0, 0(sp)
	sw	ra, 4(sp)
	jal	main_getNum # call main_getNum which will convert the pointer in a0 to its actual numerical value
	mv	a1, a0
	lw	a0, 0(sp) 
	lw	ra, 4(sp)
	addi	sp, sp, 8
	# a0 now holds the pointer to the start of the uppercase key string, a1 holds the uppercase key
	
main_lowercaseKey_Loop: # iterate through the uppercase key characters until the end of line is found
	lbu	t1, 0(a0) # current char
	li	t2, 10 # t2 <- '\n'
	beq	t1, t2, main_foundLowerCaseKey
	addi	a0, a0, 1 # point to the next char
	j	main_lowercaseKey_Loop

main_foundLowerCaseKey:
	addi a0, a0, 1 # t0 points to the character after the new line
	mv t0, a0
	addi sp, sp, -8
	sw	a1, 0(sp)
	sw	ra, 4(sp)
	jal	main_getNum # call main_getNum which will convert the pointer in a0 to its actual numerical value
	mv	a2, a0
	lw	a1, 0(sp) 
	lw	ra, 4(sp)
	addi	sp, sp, 8
	# a1 holds uppercase key, a2 holds lowercase key
	
	la	a0, inputStream
	li	a7, 4
   	ecall # print the original string

	la	a0, main_newline
	li	a7, 4
	ecall # print a newline
   	
    la	a0, inputStream # supply pointers as arguments
    jal     encrypt5lettword # call the student subroutine/jump to code under the label 'encrypt5lettword'
    la t0, inputStream
	beq a0, t0, main_stringOverwrite

   	li	a7, 4   # the number of a system call is specified in a7        
   	ecall           # Print the student's string whose address is in a0
   	
        j	main_done

main_inputErr:
	la 	a0, inputErrStr  # print error message in the event of an error when trying to read a file 
	li	a7, 4  # the number of a system call is specified in a7
	ecall  # Print string whose address is in a0
	j main_done

main_stringOverwrite:
	la a0, invalidStrAddress # print error message in the event of an error overwriting the string. 
    li a7, 4 # the number of a system call is specified in a7
	ecall # Print string whose address is in a0
	j main_done

main_err:
        la	a0, noFileStr       # print error message in the event of an error when trying to read a file                       
        li	a7, 4               # the number of a system call is specified in a7
        ecall                       # Print string whose address is in a0
    
main_done:
        li      a7, 10              # ecall 10 exits the program with code 0
        ecall
        
#---------------------------------------------------------------------------------------------
# main_getNum
# 
# Subroutine description: This function converts a string of numbers to their numerical representation. (main_getNum("123") -> 123)
#
# Arguments:
#      a0: a pointer to a string of numbers ending with an end of line or end of file indicator
#
# Return Values:
#      a0: the numerical value of the string of number
# Register Usage: 
#	s0: stores the pointer to the start of the string
#	s1: pointer that we increment through the string 
#	s2: base 10 exponent for the current char
#	s3: intermediate values for the number
#---------------------------------------------------------------------------------------------        
main_getNum:
	#Lowering the stack
	addi	sp, sp, -20
	#storing the s registers to be used in the stack
	sw	s0, 0(sp)
	sw	s1, 4(sp)
	sw	s2, 8(sp)
	sw	s3, 12(sp)
	sw 	ra, 16(sp)
	
	mv	s0, a0
	mv	s1, a0
main_getNumValidateLoop: # iterate through every num checking that has a valid numerical ascii code until the return key or end of file
	# check if the current char is the newline key
	li	t0, 10 # t0 <- '\n'
	lbu	t1, 0(s1) # t1 <- current char
	beq	t0, t1, main_getNumValidateExit # if char == '\n'
	beqz	t1, main_getNumValidateExit # if char == end of file
	li	t0, 48
	blt	t1, t0, main_inputErr # if char < '0'
	li	t0, 57
	bgt	t1, t0, main_inputErr # if char > '9'
	# otherwise valid num char and we can continue to the next char
	addi	s1, s1, 1
	j main_getNumValidateLoop
	
main_getNumValidateExit:
	beq	s0, s1, main_inputErr # if first char was newline or does not exist
	sub	s2, s1, s0 # exponent for first digit (e.g. for "324",  s2 = 2 because 3*(10^2)  )
	addi	s2, s2, -1 # subtract 1 from the exponent since the first exponent starts at 10 ^ 0
	mv	s1, s0 # set s1 to the original pointer
	li	s3, 0 # current value of num
main_getNumCalculateLoop: # add to s3 the value of the current char * 10^exponent
	bltz	s2, main_getNumCalculateExit
	lbu	t0, 0(s1)
	addi	t0, t0, -48
	
	li	a0, 10
	mv	a1, s2
	
	addi	sp, sp, -8
	sw	t0, 0(sp)
	sw	ra, 4(sp)
	jal	main_exponent
	lw	t0, 0(sp)
	lw	ra, 4(sp)
	addi	sp, sp, 8
	
	mul	t1, a0, t0 # t1 <- num * 10^exponent
	add	s3, s3, t1 # add the value of this digit
	addi	s1, s1, 1 # increment pointer
	addi	s2, s2, -1 # decrement exponent
	j main_getNumCalculateLoop
	
main_getNumCalculateExit:
	mv a0, s3 # a0 <- base 10 value of the string
	
	lw	s0, 0(sp)
	lw	s1, 4(sp)
	lw	s2, 8(sp)
	lw 	s3, 12(sp)
	lw 	ra, 16(sp)
	addi	sp, sp, 20
	ret
#---------------------------------------------------------------------------------------------
# main_exponent
# 
# Subroutine description: This function does exponents with positive integer bases and exponents.
#
# Arguments:
#      a0: base
#      a1: exponent
#
# Return Values:
#      a0: value
#---------------------------------------------------------------------------------------------
main_exponent:
	li 	t0, 1 # let t0 store intermediate values for the calculation
main_exponentLoop:
	beqz	a1, main_exponentexit # if the exponent is zero, return 1
	mul	t0, t0, a0 
	addi	a1, a1, -1
	j main_exponentLoop
	
main_exponentexit:
	mv a0, t0
	ret

	

#-------------------end of common file-------------------------------------------------
