
# Helper macro for grabbing two command line arguments
.macro load_two_args
	lw $t0, 0($a1)
	sw $t0, arg1
	lw $t0, 4($a1)
	sw $t0, arg2
.end_macro

# Helper macro for grabbing one command line argument
.macro load_one_arg
	lw $t0, 0($a1)
	sw $t0, arg1
.end_macro

############################################################################
##
##  TEXT SECTION
##
############################################################################
.text
.globl main

main:
#check if command line args are provided
#if zero command line arguments are provided exit
beqz $a0, exit_program
li $t0, 1
#check if only one command line argument is given and call marco to save them
beq $t0, $a0, one_arg
#else save the two command line arguments
load_two_args()
j done_saving_args

#if there is only one arg, call macro to save it
one_arg:
	load_one_arg()

#you are done saving args now, start writing your code.
done_saving_args:
	
Load_File:
	li $v0, 13
	lw $a0, arg1
	li $a1, 0
	li $a2, 0
	syscall
	
	move $a0, $v0
	li $a1, -1#bg
	li $a2, -1#fg
	jal load_code_chunk
	
	#jal apply_java_syntax
	
	#jal apply_java_line_comments
	la $a0, prompt #string
	li $a1, 0x4 #BG
	li $a2, 0x3 #FG
	li $a3, 0xf #defaultBG
	li $t0, 0x2 #defaultFG
	
	addi $sp, $sp, -4
	sw $t0, ($sp)
	
	jal search_screen	
	addi $sp, $sp, 4
	
	
	la $a0, prompt #string
	li $a1, 0x4 #BG
	li $a2, 0x3 #FG
	li $a3, 0xf #defaultBG
	li $t0, 0x2 #defaultFG
	
	addi $sp, $sp, -4
	sw $t0, ($sp)
	
	jal search_screen	
	addi $sp, $sp, 4
	
	#lw $t0, arg1
	#move $a0, $t0
	#li $v0 4
	#syscall
# YOUR CODE SHOULD START HERE
li $a0, 1
li $a1, 1
li $a2, 0x2
li $a3, 0xD
jal apply_cell_color

li $a0, 0x4d
jal clear_Screen_Specific_Color

jal clear_screen

exit_program:
#jal load_code_chunk
li $v0, 10
syscall

############################################################################
##
##  DATA SECTION
##
############################################################################
.data

.align 2

#for arguments read in
arg1: .word 0
arg2: .word 0

#prompts to display asking for user input
prompt: .asciiz " "
search_prompt: .asciiz "\nEnter search string: "




#################################################################
# Student defined functions will be included starting here
#################################################################

.include "hw3.asm"

