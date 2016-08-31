 # Homework #3
 # name: Tejas Prasad
 # sbuid: 110334994


##############################
#
# TEXT SECTION
#
##############################
 .text

##############################
# PART I FUNCTIONS
##############################

##############################
# This function reads a byte at a time from the file and puts it
# into the appropriate position into the MMIO with the correct
# FG and BG color.
# The function begins each time at position [0,0].
# If a newline character is encountered, the function must
# populate the rest of the row in the MMIO with the spaces and
# then continue placing the bytes at the start of the next row.
#
# @param fd file descriptor of the file.
# @param BG four-bit value indicating background color
# @param FG four-bit value indication foreground color
# @return int 1 means EOF has not been encountered yet, 0 means
# EOF reached, -1 means invalid file.
##############################
load_code_chunk:
	addi $sp, $sp, -32
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $ra, 28($sp)
	
	move $s0, $a0 #File Descriptor
	move $s1, $a1 #BG param
	move $s2, $a2 #FG param
	
	la $s3, 0xffff0000 #character in array
	la $s4, 0xffff0001 #color
	la $s5, 0xffff0f9f #address of last element in array
	
	blt $a0, 3, Invalid_File

checkBackground:
	blt $s1, 0, Default_Background
	bgt $s1, 15, Default_Background
	
checkForeground:
	blt $s2, 0, Default_Foreground
	bgt $s2, 15, Default_Foreground
	j prepValues
	
Default_Background:
	li $s1, 0xf
	j checkForeground

Default_Foreground:
	li $s2, 0x0
		
prepValues:
	sll $t2, $s1, 4
	add $s6, $t2, $s2
	
	move $a0, $s6
	jal clear_Screen_Specific_Color
	
	la $s1, 0xffff0000
	li $s2, 160
	
	li $t0, 0 #counter for row
	li $t1, 0 #counter for column
	
	j Load_Code_Loop

#need to fill in with spaces at end
Load_Code_Loop:
	bgt $s4, $s5, Not_EOF #check if addr is greater than last addr in MMIO
	bgt $t0, 24, Not_EOF #check if row # is greater than 24
	
	li $v0, 14
	move $a0, $s0
	move $a1, $s3
	li $a2, 1
	syscall
	
	lb $t2, ($s3) #get char stored in MMIO
	
	beq $t2, 10, nextRow #Check if newline
	beq $v0, 0, End_Of_File #Check if EOF
	bltz $v0, Invalid_File #check if invalid file
	
	sb $s6, ($s4) #load color into MMIO
	
	addi $s3, $s3, 2
	addi $s4, $s4, 2
	addi $t1, $t1, 1
	
	beq $t1, 80, nextRow
	j Load_Code_Loop
	
nextRow:
	li $t1, 0 #reset columns
	addi $t0, $t0, 1 #row++
	mul $t9, $t0, $s2 #row * 160
	add $s3, $t9, $s1 #0xffff0000 + (row * 160)
	addi $s4, $s3, 1 #0xffff0000 + (row * 160) + 1
	j Load_Code_Loop

	
Invalid_File:
	li $v0, -1
	j load_code_chunk_done

End_Of_File:
	li $v0, 0
	j load_code_chunk_done

Not_EOF:
	li $v0, 1

load_code_chunk_done:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	lw $ra, 28($sp)
	addi $sp, $sp, 32
	jr $ra


##############################
# PART II FUNCTIONS
##############################

##############################
# This function should go through the whole memory array and clear the contents of the screen.
##############################
clear_screen:
	addi $sp, $sp, -28
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	
	la $s0, 0xffff0000 #character in array
	la $s1, 0xffff0001 #color
	li $s2, 0 #counter for row
	li $s3, 0 #counter for column
	li $s4, 0
	la $s5, 0xffff0f9f
	li $s6, 32

Clear_Screen_Loop:
	bgt $s1, $s5, Clear_Screen_Done
	bgt $s2, 24, Clear_Screen_Done
	
	sb $s6, ($s0)
	sb $s4, ($s1)
	
	addi $s0, $s0, 2
	addi $s1, $s1, 2
	addi $s3, $s3, 1
	
	beq $s3, 80, next_Clean_Row
	j Clear_Screen_Loop
	
next_Clean_Row:
	li $s3, 0
	addi $s2, $s2, 1
	j Clear_Screen_Loop

Clear_Screen_Done:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	addi $sp, $sp, 28
	jr $ra

#Clear Screen function for custom Color
#Fills MMIO with space and specified color
#@param Color for MMIO
clear_Screen_Specific_Color:
	addi $sp, $sp, -28
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	
	la $s0, 0xffff0000 #character in array
	la $s1, 0xffff0001 #color
	li $s2, 0 #counter for row
	li $s3, 0 #counter for column
	move $s4, $a0
	la $s5, 0xffff0f9f
	li $s6, 0x20

Clear_Screen_Specific_Color_Loop:
	bgt $s1, $s5, Clear_Screen_SpecColor_Done
	bgt $s2, 24, Clear_Screen_SpecColor_Done
	
	sb $s6, ($s0)
	sb $s4, ($s1)
	
	addi $s0, $s0, 2
	addi $s1, $s1, 2
	addi $s3, $s3, 1
	
	beq $s3, 80, next_Clean_Row_SpecColor
	j Clear_Screen_Specific_Color_Loop
	
next_Clean_Row_SpecColor:
	li $s3, 0
	addi $s2, $s2, 1
	j Clear_Screen_Specific_Color_Loop

Clear_Screen_SpecColor_Done:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	addi $sp, $sp, 28
	jr $ra

##############################
# PART III FUNCTIONS
##############################

##############################
# This function updates the color specifications of the cell
# specified by the cell index. This function should not modify
# the text in any fashion.
#
# @param i row of MMIO to apply the cell color.
# @param j column of MMIO to apply the cell color.
# @param FG the four bit value specifying the foreground color
# @param BG the four bit value specifying the background color
##############################
apply_cell_color:
	addi $sp, $sp, -20
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	
	move $s0, $a0 #i
	move $s1, $a1 #j
	move $s2, $a2 #FG
	move $s3, $a3 #BG
	li $s4, 0
	
	bltz $s0, apply_cell_color_done #check i
	bgt $s0, 24, apply_cell_color_done

	bltz $s1, apply_cell_color_done #check j
	bgt $s1, 79, apply_cell_color_done
	
prepValueApplyColor:
	li $t0, 160 #number of elements in row
	li $t1, 2
	mul $t2, $s0, $t0
	mul $t3, $s1, $t1
	addi $t3, $t3, 1
	
	la $t9, 0xffff0000
	add $t4, $t2, $t3
	add $t9, $t9, $t4
	
checkFG:
	li $s4, 0x10
	bltz $s2, checkBG #check FG
	bgt $s2, 15, checkBG
	li $s4, 0x0
	
checkBG:
	addi $s4, $s4, 0x1
	bltz $s3, checkEqual #check BG
	bgt $s3, 15, checkEqual
	andi $s4, $s4, 0xf0
checkEqual:
	#if 0x00 then both FG BG are in bounds
	#if 0x01 then FG in bounds but BG out of bounds
	#if 0x10 then FG out of bounds but BG is in bounds
	#if 0x11 then both FG BG out of bounds
	beq $s4, 0x0, apply_both_FGBG
	beq $s4, 0x1, apply_only_FG
	beq $s4, 0x10, apply_only_BG
	beq $s4, 0x11, apply_cell_color_done
	
apply_only_FG:
	lb $t0, ($t9) #get color value
	andi $t1, $t0, 0xf0 #mask color value to get bg value only
	add $t2, $t1, $s2 #add FG to current BG value
	sb $t2, ($t9) #store new color to MMIO
	j apply_cell_color_done

apply_only_BG:
	lb $t0, ($t9) #get color value
	andi $t1, $t0, 0xf #mask color value to get FG value only
	sll $t2, $s3, 4 #shift BG value over by 4 bits
	add $t3, $t1, $t2 #add current FG to new BG
	
	sb $t3, ($t9) #store new color to MMIO
	
	j apply_cell_color_done

apply_both_FGBG:
	sll $t5, $s3, 4 #shift BG over by 4 bits
	add $t6, $t5, $s2 #add FG to shifted value
	
	sb $t6, ($t9) #store color to MMIO

apply_cell_color_done:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	addi $sp, $sp, 20
	jr $ra

#Applies a color value to the entire MMIO
#Doesnt change characters in MMIO, only color values
#@param FGBG
Apply_SpecBGFG:
	la $t1, 0xffff0001 #color
	li $t2, 0 #counter for row
	li $t3, 0 #counter for column
	move $t4, $a0 #get FGBG
	la $t5, 0xffff0f9f

Apply_Specific_BGFG_Loop:
	bgt $t1, $t5, Apply_SpecBGFG_Done
	bgt $t2, 24, Apply_SpecBGFG_Done
	
	sb $t4, ($t1) #store new color to MMIO
	
	addi $t1, $t1, 2
	addi $t3, $t3, 1
	
	beq $t3, 80, next_Row_SpecBGFG
	j Apply_Specific_BGFG_Loop
	
next_Row_SpecBGFG:
	li $t3, 0
	addi $t2, $t2, 1
	j Apply_Specific_BGFG_Loop

Apply_SpecBGFG_Done:
	jr $ra

##############################
# This function goes through and clears any cell with oldBG color
# and sets it to the newBG color. It preserves the foreground
# color of the text that was present.
#
# @param oldBG old background color specs.
# @param newBG new background color defining the color specs
##############################
clear_background:
	addi $sp, $sp, -24
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	
	la $s0, 0xffff0001 #color
	li $s3, 0 #counter for row
	li $s4, 0 #counter for column
	la $s5, 0xffff0f9f 
	
	bltz $a0, Clear_Background_Done # Check if params are within bounds
	bgt $a0, 15, Clear_Background_Done
	bltz $a1, Default_Background_Clear
	bgt $a1, 15, Default_Background_Clear
	
	sll $s1, $a0, 4 #Prev BG
	sll $s2, $a1, 4 #New BG
	j Clear_Background_Loop
	
Default_Background_Clear:
	sll $s1, $a0, 4 #Prev BG
	li $s2, 0xf0

Clear_Background_Loop:
	bgt $s0, $s5, Clear_Background_Done #check if at end of array
	bgt $s3, 24, Clear_Background_Done #additional check for end of array
	
	lb $t9, ($s0) #get color value of the array cell
	andi $t0, $t9, 0xf0 #mask foreground color to get only background value
	
	beq $t0, $s1, Set_New_Background #check if backgroudn is equal to param, if it is then change color
	
	addi $s0, $s0, 2 #increment adress of array
	addi $s4, $s4, 2 #increment column counter
	
	beq $s4, 80, next_Background_Row #check if at max column
	j Clear_Background_Loop
	
next_Background_Row:
	li $s4, 0
	addi $s3, $s3, 1
	j Clear_Background_Loop
	
Set_New_Background:
	andi $t1, $t9, 0x0f #mask background color to get only foreground value
	add $t2, $t1, $s2 #add new background to current foreground
	
	sb $t2, ($s0) #store new color into array
	addi $s0, $s0, 2
	addi $s4, $s4, 2
	
	beq $s4, 80, next_Background_Row
	j Clear_Background_Loop

Clear_Background_Done:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	addi $sp, $sp, 24
	jr $ra


##############################
# This function will compare cmp_string to the string in the MMIO
# starting at position (i,j). If there is a match the function
# will return (1, length of the match).
#
# @param cmp_string start address of the string to look for in
# the MMIO
# @param i row of the MMIO to start string compare.
# @param j column of MMIO to start string compare.
# @return int length of match. 0 if no characters matched.
# @return int 1 for exact match, 0 otherwise
##############################
string_compare:
	#Define your code here
	addi $sp, $sp, -20
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	
	li $t0, 160
	li $t1, 2
	mul $t2, $a1, $t0
	mul $t3, $a2, $t1
	
	la $s1, 0xffff0000
	la $s4, 0xffff0f9f
	add $t4, $t2, $t3
	add $s1, $s1, $t4
	
	li $v0, 0
	li $v1, 0
	li $t9, 0
	move $s0, $a0 #string to cmp
	
checkLengthLoop:
	add $t0, $s0, $t9
	lb $t2, 0($t0)
	beqz $t2, saveLength
	addi $t9, $t9, 1
	
	j checkLengthLoop
	
saveLength:
	move $s2, $t9
	
strcmpZero:
	li $t9, 0
	li $t8, 0

strComparisonLoop:
	add $t0, $s0, $t9 #increase addr of string
	add $t1, $s1, $t8 #increase addr of MMIO
	bgt $t1, $s4, strcmpDone #check if addr of MMIO is greater than max MMIO
	lb $t2, 0($t0) #get char of string
	lb $t3, ($t1) #get char of MMIO
	bne $t2, $t3, strcmpDone #if not equal, exit
	beqz $t2, sameString #if string char is null char, then return 1
	addi $t9, $t9, 1 #inc adder for string
	addi $t8, $t8, 2 #inc adder for MMIO
	addi $v0, $v0, 1 #add 1 to num chars which match
	beq $v0, $s2, sameString #if (num_char == length) return 1
	
	j strComparisonLoop

sameString:
	li $v1, 1

strcmpDone:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	addi $sp, $sp, 20
	jr $ra

##############################
# This function goes through the whole MMIO screen and searches
# for any string matches to the search_string provided by the
# user. This function should clear the old highlights first.
# Then it will call string_compare on each cell in the MMIO
# looking for a match. If there is a match it will apply the
# background color using the apply_cell_color function.

#Change color of MMIO to default BG and default FG
#
# @param search_string Start address of the string to search for
# in the MMIO.
# @param BG background color specs defining.
# @param FG
# @param defaultBG
# @param defaultFG
##############################
search_screen:
	lw $t0, 0($sp)#grab defaultFG from stack

	addi $sp, $sp, -36 #preserve registers
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $ra, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	sw $s6, 28($sp)
	sw $s7, 32($sp)
	
	move $s0, $a0 #char[] search_string
	move $s1, $a1 #BG
	move $s2, $a2 #FG
	move $s3, $a3 #defaultBG
	move $s4, $t0 #defaultFG
	
	bltz $s3, search_screen_done
	bgt $s3, 15, search_screen_done
	
	bltz $s4, search_screen_done
	bgt $s4, 15, search_screen_done
	
	move $a0, $s1 #bg
	move $a1, $s3 #default BG
	jal clear_background
	
	#move $a0, $s4
	#jal Apply_SpecFG
	
	la $s3, 0xffff0000 #starting address for char
	la $s4, 0xffff0001 #starting address for color
	li $s5, 0 #row counter
	li $s6, 0 #column counter
	
searchScreenLoop:
	bgt $s5, 24, search_screen_done #check if at row 26 or more
	move $a0, $s0 #addr for string to cmp
	move $a1, $s5 #i location in array to start from
	move $a2, $s6 #j location in array to start from
	
	jal string_compare
	
	move $s7, $v0
	beq $v1, 1, highlightString #check if string matched
	bgtz $s7, increaseByMatch
	
increaseBy1:
	addi $s6, $s6, 1 #column++
	bgt $s6, 79, nextRowSearchScreen #check if at row 81 or more
	
	j searchScreenLoop

increaseByMatch:
	
	add $s6, $s6, $s7 #column += characters matched
	bgt $s6, 79, nextRowSearchScreen #check if at row 81 or more
	
	j searchScreenLoop
	
nextRowSearchScreen:
	li $s6, 0 #reset column
	addi $s5, $s5, 1 #row++
	j searchScreenLoop	
	
highlightString:
	move $a2, $s2
	move $a3, $s1
	li $s3, 0 #characters highlighted
	
highlightString_Loop:
	bge $s3, $s7, searchScreenLoop
	bgt $s5, 24, search_screen_done
	move $a0, $s5
	move $a1, $s6
	
	#addi $sp, $sp, -4
	#sw $t0, 0($sp)
	
	jal apply_cell_color
	
	#lw $t0, 0($sp)
	#addi $sp, $sp, 4
	
	addi $s3, $s3, 1
	addi $s6, $s6, 1
	
	bgt $s6, 79, nextRowHighlight
	
	j highlightString_Loop

nextRowHighlight:
	li $s6, 0
	addi $s5, $s5, 1
	
	j highlightString_Loop

search_screen_done:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $ra, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	lw $s6, 28($sp)
	lw $s7, 32($sp)
	addi $sp, $sp, 36
	jr $ra

##############################
# PART IV FUNCTIONS
##############################

##############################
# This function goes through the whole MMIO screen and searches
# for Java syntax keywords, operators, data types, etc and
# applies the appropriate color specifications for to that match.
##############################
apply_java_syntax:
	addi $sp, $sp, -28
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $ra, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	
	la $s0, java_keywords
	la $s1, java_datatypes
	la $s2, java_operators
	la $s3, java_brackets
	
	li $s4, 0
	
apply_java_syntax_Keyword_Loop:
	add $s5, $s4, $s0
	lw $t0, 0($s5)
	lb $t1, 0($t0)
	
	beq $t1, -1, apply_java_syntax_Datatype
	
	#la $t0, 0($s5)
	
	move $a0, $t0 #string to search for
	li $a1, 0x0 #BG
	li $a2, 0x9 #FG Bright Red
	li $a3, 0x0 #defaultBG
	li $t1, 0xf #defaultFG
	addi $sp, $sp, -4
	sw $t1, 0($sp) #defaultFG stored
	
	jal search_screen
	addi $sp, $sp, 4
	
	addi $s4, $s4, 4
	
	j apply_java_syntax_Keyword_Loop

apply_java_syntax_Datatype:
	li $s4, 0	
			
apply_java_syntax_Datatype_Loop:
	add $s5, $s4, $s1
	lw $t0, 0($s5)
	lb $t1, 0($t0)
	
	beq $t1, -1, apply_java_syntax_Operator
	
	#la $t0, 0($s5)
	
	move $a0, $t0
	li $a1, 0x0 #BG
	li $a2, 0xe #FG Bright Cyan
	li $a3, 0x0 #defaultBG
	li $t1, 0xf #defaultFG
	addi $sp, $sp, -4
	sw $t1, 0($sp)
	
	jal search_screen
	addi $sp, $sp, 4
	
	addi $s4, $s4, 4
	
	j apply_java_syntax_Datatype_Loop
	
apply_java_syntax_Operator:
	li $s4, 0
	
apply_java_syntax_Operator_Loop:
	add $s5, $s4, $s2
	lw $t0, 0($s5)
	lb $t1, 0($t0)
	
	beq $t1, -1, apply_java_syntax_Bracket
	
	#la $t0, 0($s5)
	
	move $a0, $t0
	li $a1, 0x0 #BG
	li $a2, 0xa #FG Bright Green
	li $a3, 0x0 #defaultBG
	li $t1, 0xf #defaultFG
	addi $sp, $sp, -4
	sw $t1, 0($sp)
	
	jal search_screen
	addi $sp, $sp, 4
	
	addi $s4, $s4, 4
	
	j apply_java_syntax_Operator_Loop

apply_java_syntax_Bracket:
	li $s4, 0
	
apply_java_syntax_Bracket_Loop:	
	add $s5, $s4, $s3
	lw $t0, 0($s5)
	lb $t1, 0($t0)
	
	beq $t1, -1, apply_java_syntax_Done
	
	#la $t0, 0($s5)
	
	move $a0, $t0
	li $a1, 0x0 #BG
	li $a2, 0xd #FG Bright Magenta
	li $a3, 0x0 #defaultBG
	li $t1, 0xf #defaultFG
	addi $sp, $sp, -4
	sw $t1, 0($sp)
	
	jal search_screen
	addi $sp, $sp, 4
	
	addi $s4, $s4, 4
	
	j apply_java_syntax_Bracket_Loop
	
apply_java_syntax_Done:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $ra, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	addi $sp, $sp, 28
	jr $ra

##############################
# This function goes through the whole MMIO screen finds any java
# comments and applies a blue foreground color to all of the text
# in that line.
##############################
apply_java_line_comments:
	addi $sp, $sp, -28
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $ra, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	
	la $s0, java_line_comment
	li $s1, 0 #i
	li $s2, 0 #j
	la $s3, 0xc #bright blue
	li $s4, 0 #i
	li $s5, 0 #j
	
searchCommentLoop:
	bgt $s2, 79, nextRowSearchComment #check if at row 80 or more
	bgt $s1, 24, apply_java_line_comments_Done #check if at row 25 or more
	move $a0, $s0 #addr for string to cmp
	move $a1, $s1 #i location in array to start from
	move $a2, $s2 #j location in array to start from
	
	jal string_compare
	
	move $s4, $v0
	beq $v1, 1, highlightComment #check if string matched
	
	addi $s2, $s2, 1 #column++

	j searchCommentLoop
	
nextRowSearchComment:
	li $s2, 0 #reset column
	addi $s1, $s1, 1 #row++
	j searchCommentLoop	

highlightComment: #i, j, FG, BG
	move $a2, $s3 #move FG into arg 3
	li $a3, 16 #load 16 into arg 4 so current BG is preserved

highlightComment_Loop:
	move $a0, $s1
	move $a1, $s2
	
	jal apply_cell_color
	
	addi $s2, $s2, 1
	
	bgt $s2, 79, nextRowHighlightComment
	
	j highlightComment_Loop

nextRowHighlightComment:
	li $s2, 0
	addi $s1, $s1, 1
	
	j searchCommentLoop
	
apply_java_line_comments_Done:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $ra, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	addi $sp, $sp, 28
	jr $ra

##############################
#
# DATA SECTION
#
##############################
.data
#put the users search string in this buffer

.align 2
negative: .word -1

#java keywords red
java_keywords_public: .asciiz "public"
java_keywords_private: .asciiz "private"
java_keywords_import: .asciiz "import"
java_keywords_class: .asciiz "class"
java_keywords_if: .asciiz "if"
java_keywords_else: .asciiz "else"
java_keywords_for: .asciiz "for"
java_keywords_return: .asciiz "return"
java_keywords_while: .asciiz "while"
java_keywords_sop: .asciiz "System.out.println"
java_keywords_sop2: .asciiz "System.out.print"

.align 2
java_keywords: .word java_keywords_public, java_keywords_private, java_keywords_import, java_keywords_class, java_keywords_if, java_keywords_else, java_keywords_for, java_keywords_return, java_keywords_while, java_keywords_sop, java_keywords_sop2, negative

#java datatypes
java_datatype_int: .asciiz "int "
java_datatype_byte: .asciiz "byte "
java_datatype_short: .asciiz "short "
java_datatype_long: .asciiz "long "
java_datatype_char: .asciiz "char "
java_datatype_boolean: .asciiz "boolean "
java_datatype_double: .asciiz "double "
java_datatype_float: .asciiz "float "
java_datatype_string: .asciiz "String "

.align 2
java_datatypes: .word java_datatype_int, java_datatype_byte, java_datatype_short, java_datatype_long, java_datatype_char, java_datatype_boolean, java_datatype_double, java_datatype_float, java_datatype_string, negative

#java operators
java_operator_plus: .asciiz "+"
java_operator_minus: .asciiz "-"
java_operator_division: .asciiz "/"
java_operator_multiply: .asciiz "*"
java_operator_less: .asciiz "<"
java_operator_greater: .asciiz ">"
java_operator_and_op: .asciiz "&&"
java_operator_or_op: .asciiz "||"
java_operator_not_op: .asciiz "!="
java_operator_equal: .asciiz "="
java_operator_colon: .asciiz ":"
java_operator_semicolon: .asciiz ";"

.align 2
java_operators: .word java_operator_plus, java_operator_minus, java_operator_division, java_operator_multiply, java_operator_less, java_operator_greater, java_operator_and_op, java_operator_or_op, java_operator_not_op, java_operator_equal, java_operator_colon, java_operator_semicolon, negative

#java brackets
java_bracket_paren_open: .asciiz "("
java_bracket_paren_close: .asciiz ")"
java_bracket_square_open: .asciiz "["
java_bracket_square_close: .asciiz "]"
java_bracket_curly_open: .asciiz "{"
java_bracket_curly_close: .asciiz "}"

.align 2
java_brackets: .word java_bracket_paren_open, java_bracket_paren_close, java_bracket_square_open, java_bracket_square_close, java_bracket_curly_open, java_bracket_curly_close, negative

java_line_comment: .asciiz "//"

.align 2
user_search_buffer: .space 101
