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
# 	a1: uppercase key, represented by a positive integer value
#	a2: lowercase key, represented by a positive integer value
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
    la      t0, inputStream          # t0 is the pointer to the input string
    li      t2, 0                    # Initialize a counter
    li      a1, 1                    # Initialize a value to be added to the characters
    

getLength:
    lb      t1, 0(t0)                # Get the character being pointed to
    beqz    t1, getLengthDone        # Check if the character is the null terminator
    addi    t2, t2, 1                # If not, increment the counter by 1
    addi    t0, t0, 1                # Move pointer to the next character
    j       getLength                # Go through the loop again
    
    # Dynamically allocate memory for the input string
getLengthDone:            
    li      a7, 9                    # Set a7 (syscall number) to 9 (sbrk system call)
    addi    a0, t2, 1                # a0 contains the length of string + 1 (for null terminator)
    ecall                            # Now a0 stores a pointer to 64 bytes of contiguous memory
    mv      s1, a0                   # Save the value of a0 to s1 (pointer to the allocated memory block)
    
    # Reset input string pointer
    la      t0, inputStream          # Move the pointer back to the beginning of the string

 # Loop through each character of the input string
encryptLoop:
    lb      t3, 0(t0)                # Get the character currently being pointed to
    beqz    t3, encryptDone          # If the character is null, done encrypting
    
    # Check if the character is lowercase
    li      t4, 97                   # t4 stores ASCII value for 'a'
    li      t5, 122                  # t5 stores ASCII value for 'z'
    blt     t3, t4, uppercase        # If character is less than 'a', check if it's uppercase
    bgt     t3, t5, storeCharacter   # If character is greater than 'z', it's not a letter, store in output string as is
    
    # Character is lowercase
    addi    t3, t3, -97              # Get value of character in the range 0-25
    add     x7, t3, a1               # Increment value of character by the lowercase key
    addi    a1, a1, 1
    li      t6, 26                   # t6 stores the value 26 (number of letters in the alphabet)
    # remu    x7, x7, t6               # Ensure it wraps around the alphabet
    addi    x7, x7, 97         
    j       storeLetter              # Done encrypting this character, go to continue to store it into the output string
    
# Check if character is uppercase
uppercase:
    li      t4, 65                   # t4 stores ASCII value for 'A'
    li      t5, 90                   # t5 stores ASCII value for 'Z'
    blt     t3, t4, storeCharacter   # If character is less than 'A', it's not a letter, store in output string as is
    bgt     t3, t5, storeCharacter   # If character is greater than 'Z', it's not a letter, store in output string as is
    
    addi    t3, t3, -65              # Get value of character in the range 0-25
    add     x7, t3, a1               # Increment value of character by the uppercase key
    addi    a1, a1, 1
    li      t6, 26                   # t6 stores the value 26 (number of letters in the alphabet)
    # remu    x7, x7, t6               # Ensure it wraps around the alphabet
    addi    x7, x7, 65               # Add 65 go back within the ASCII range
    j       storeLetter              # Done encrypting this character, go to continue to store it into the output string
    
storeCharacter:
    add     t3, t3, a1
    sb      t3, 0(a0)
    addi     a1, a1, 1
    addi     t0, t0, 1               # Move to the next position in the output string
    addi     a0, a0, 1               # Move to the next position in the input string
    j       encryptLoop              # Jump back to the encryptLoop to continue encrypting next character
    
storeLetter:
    sb      x7, 0(a0)                # Store the encyrpted character in the output string
    addi    t0, t0, 1                # Move to the next position in the output string
    addi    a0, a0, 1                # Move to the next position in the input string
    j       encryptLoop              # Jump back to encryptLoop to continue encrypting next character
    
encryptDone:
    sb      x0, 0(a0)                # Null-terminate the output string
    
    mv      a0, s1                   # Return the pointer to the encrypted string
    ret
