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
# caesarEncrypt: This function encrypts a string using a Caesar Cipher with both uppercase and lowercase keys.
#
# Args:
# 	a0: pointer to a string to encrypt
# 	a1: uppercase key, represented by a positive integer value
#	a2: lowercase key, represented by a positive integer value
# Returns:
#	a0: pointer to the encrypted string
#
# Register Usage:
#   t0: A pointer to inputStream; after finding the string length, reset to point back to the beginning of inputStream
#   t1: Used when getting string length to temporarily store the character
#   t2: Used as a counter to count the length of input string
#   a0: Stores a pointer to 64 bytes of contiguous memory; used to papss arguments to system call
#   a7: Used to specify the system call when allocating memory for the encrypted string
#   s1: Pointer that points to the block of memory allocated for the encrypted string
#   t3: Used while encrypting characters to temporarily store the original character
#   t4: Used while encrypting characters to store the ASCII value for 'a' and later 'A'
#   t5: Used while encrypting characters to store the ASCII value for 'z' and later 'Z'
#   t6: Used while encrypting characters to store the value 26 (to make sure the encrypted character wraps around the alphabet)
#   x7: Used while encrypting characters to store the encrypted character 
# -----------------------------------------------------------------------------