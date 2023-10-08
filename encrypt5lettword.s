#----------------------------------------------------------------
#
# CMPUT 229 Student Submission License
# Version 1.0
# Copyright 2023 Julia Doan
#
# Unauthorized redistribution is forbidden in all circumstances. Use of this
# software without explicit authorization from the author or CMPUT 229
# Teaching Staff is prohibited.
#
# This software was produced as a solution for an assignment in the course
# CMPUT 229 - Computer Organization and Architecture I at the University of
# Alberta, Canada. This solution is confidential and remains confidential 
# after it is submitted for grading.
#
# Copying any part of this solution without including this copyright notice
# is illegal.
#
# If any portion of this software is included in a solution submitted for
# grading at an educational institution, the submitter will be subject to
# the sanctions for plagiarism at that institution.
#
# If this software is found in any public website or public repository, the
# person finding it is kindly requested to immediately report, including 
# the URL or other repository locating information, to the following email
# address:
#
#          cmput229@ualberta.ca
#
#---------------------------------------------------------------
# Name:  Julia Doan               
# Lecture Section:   A1
# Instructor:    J Nelson Amaral       
# Lab Section:    D04      
# Teaching Assistant:   
#---------------------------------------------------------------


.include "common.s"
.text
# -----------------------------------------------------------------------------
# encrypt5lettword: This function encrypts a string by adding the ASCII value by 1 to the first letter, 2 to the second letter, 3 to the third letter, 4 to the fourth letter, and 5 to the fifth letter.
#
# Args:
# 	a0: pointer to a string to encrypt
# 	a1: a key, represented by a positive integer value (will not need this)
#	a2: a key, represented by a positive integer value (will not need this)
# Returns:
#	a0: pointer to the encrypted string
#
# Register Usage:
# -----------------------------------------------------------------------------

encrypt5lettword:
#----------------------------------
#        STUDENT SOLUTION
#----------------------------------
    # Get length of input string
    li      t1, 5                    # Load length of input string in t1
    li      a1, 1                    # Initialize a value to be added to the characters
    
    # Dynamically allocate memory for the input string
getLengthDone:            
    li      a7, 9                    # Set a7 (syscall number) to 9 (sbrk system call)
    addi    a0, t1, 1                # a0 contains the length of string + 1 (for null terminator)
    ecall                            # Now a0 stores a pointer to 64 bytes of contiguous memory
    mv      s1, a0                   # Save the value of a0 to s1 (pointer to the allocated memory block)
    
    # Reset input string pointer
    la      t0, inputStream          # Move the pointer back to the beginning of the string
    
    # Loop through each character of the input string
encryptLoop:
    lb      t2, 0(t0)                # Get the character currently being pointed to
    beqz    t2, encryptDone          # If the character is null, done encrypting
    #add     t2, t1, a1               
    add     t2, t2, a1               # Increment value of character by the key
    sb      t2, 0(a0)                # Replace the encrypted character in the string
    addi     t0, t0, 1               # Move to the next position in the output string
    addi     a0, a0, 1               # Move to the next position in the input string
    addi    a1, a1, 1
    j       encryptLoop              # Jump back to the encryptLoop to continue encrypting next character
    
encryptDone:
    sb      x0, 0(a0)                # Null-terminate the output string
    
    mv      a0, s1                   # Return the pointer to the encrypted string
    ret
