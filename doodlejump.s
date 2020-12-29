# Demo for painting
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 512
# - Base Address for Display: 0x10008000 ($gp)
.data
	displayAddress: .word 0x10008000
	platformX: .space 104
	platformY: .space 104
 	tempPlatformX: .space 104
	tempPlatformY: .space 104
	score: .word 0
	name: .word 0:8
	charOne: .word 0x10009c80
	charTwo: .word 0x10009c90
	charThree: .word 0x10009ca0
	charFour: .word 0x10009cb0
	charFive: .word 0x10009cc0
	charSix: .word 0x10009cd0
	charSeven: .word 0x10009ce0
	charEight: .word 0x10009cf0
	G: .word 0x100082a0
	A: .word 0x100082b0
	M: .word 0x100082c0
	E1: .word 0x100082d0
	O: .word 0x10008620
	V: .word 0x10008630
	E2: .word 0x10008640
	R: .word 0x10008650
	nameAddress: .space 32
	F1: .word 0x100090b0
	F2: .word 0x100090c0
	F3: .word 0x100090d0
	F4: .word 0x100090e0
	F5: .word 0x100090f0
.text
main:
	#main function that controls the game, the main loop
	setUp:
	jal colorAllBlack
	sw $zero, score
	jal keyPressStart
	li $t0, 0
	sw $zero, name($t0)
	addi $t0, $t0, 4
	sw $zero, name($t0)
	addi $t0, $t0, 4
	sw $zero, name($t0)
	addi $t0, $t0, 4
	sw $zero, name($t0)
	addi $t0, $t0, 4
	sw $zero, name($t0)
	addi $t0, $t0, 4
	sw $zero, name($t0)
	addi $t0, $t0, 4
	sw $zero, name($t0)
	addi $t0, $t0, 4
	sw $zero, name($t0)
	li $t0, 0
	jal getName	
	jal fillArrays
	jal fillPlatformArrays
	jal drawTwentySix	
	jal drawTwentySixLoop
	jal drawSprite
	jal startJump
	jal startJumpLoop
	jal fallDown
	jal drawScore
	j GameLoop
	
	GameLoop:
	jal startJump
	jal startJumpLoop
	jal undrawScore
	jal fallDown
	jal drawScore
	bgt  $a0, 0x10008b80, GameLoop
		InnerGameLoop:
		addi $sp, $sp, -4
		sw $a0, 0($sp)
		sw $a0, 4($sp)
		li $v0, 32
		li $a0, 50
		syscall #sleeps for 50ms (20 frames/second)
		lw $a0, 0($sp)
		jal undrawSprite
		jal undrawTwentySix
		jal undrawTwentySixLoop
		jal updateArrays
		jal updateArraysLoop
		jal drawTwentySix
		jal drawTwentySixLoop
		lw $a0, 0($sp)
		addi $sp, $sp, 4
		addi $a0, $a0, 2560
		jal drawSprite
		j GameLoop
	exitPattern:
	jal colorAllBlack
	jal drawExitScreen
	li $a0, 0x10009bb8
	jal drawSprite
	li $v0, 32
	li $a0, 10000
	syscall #sleeps for 10s
	j main
	

#colors the whole screen black
colorAllBlack:
	lw $a0, displayAddress
	li $t0, 0
	LoopPart:
	sw $t0, 0($a0)
	addi $a0, $a0, 4
	blt $a0, 0x1000a000, LoopPart
	jr $ra

#gets the users name and stores it in the appropriate array
getName:
lw $t1, 0xffff0000 #loads memory address where we record keystroke event
beq $t1, 0, getName
lw $t1, 0xffff0004 #loads memory address where ascii value of key is stored
beq $t1, 0x0a, exitStart
sw $t1, name($t0)
addi $t0, $t0, 4
beq $t0, 32, exitStart
j getName
	exitStart:
	jr $ra

keyPressStart:
lw $t0, 0xffff0000 #loads memory address where we record keystroke event
beq $t0, 0, keyPressStart
lw $t1, 0xffff0004 #loads memory address where ascii value of key is stored
bne $t1, 0x73, keyPressStart
jr $ra

#begins to fill x and y values of the different platforms
fillArrays:
li $t0, 0 #iterator
li $s0, 0 #height param
li $t1, 104 # stores 104 (number of platforms(26)*4)
jr $ra
fillPlatformArrays:#function generates two starting coordinates per four rows
#generating random number for x-coordinate of starting point of platform
li $v0, 42
li $a0, 0
li $a1, 22
syscall
sw $a0, platformX($t0)
#generating random number for y-coordinate of platform
li $v0, 42
li $a0, 0
li $a1, 3
syscall
add $a0, $a0, $s0
sw $a0, platformY($t0)
addi $t0, $t0, 4 #increment the iterator
addi $s0, $s0, 4 #increment height param
#generating random number for x-coordinate of starting point of platform
li $v0, 42
li $a0, 0
li $a1, 22
syscall
sw $a0, platformX($t0)
#generating random number for y-coordinate of platform
li $v0, 42
li $a0, 0
li $a1, 3
syscall
add $a0, $a0, $s0
sw $a0, platformY($t0)
addi $t0, $t0, 4 #increment the iterator
blt $t0, $t1, fillPlatformArrays
jr $ra

#draws 26 platforms using a random number generator
drawTwentySix: 
lw $t0, displayAddress # $t0 stores the base address for display
li $t1, 104 # stores 104 (number of platforms on screen)*4
li $t2, 0 # iterator
jr $ra

drawTwentySixLoop: #draws each platform
lw $t3, platformX($t2) #loads x-coordinate of platform to $t3
lw $t4, platformY($t2) #loads y-coordinate of platform to $t4
li $t5, 0xff9933 #loads color of platform to $t5
addi $a0, $t0, 7096 #starting point for sprite
#computing memory address
li $s0, 128 #multiplicant
mul $t4, $t4, $s0
li $s0, 4 #multiplicant
mul $t3, $t3, $s0
add $t6, $t4, $t0
add $t6, $t6, $t3 #memory address of first block of platform
#drawing platform of length 10
sw $t5, 0($t6)
sw $t5, 4($t6)
sw $t5, 8($t6)
sw $t5, 12($t6)
sw $t5, 16($t6) 
sw $t5, 20($t6)
sw $t5, 24($t6) 
sw $t5, 28($t6) 
sw $t5, 32($t6) 
sw $t5, 36($t6) 
addi $t2, $t2, 4
blt $t2, $t1, drawTwentySixLoop#checks for when iterator, $t2, reaches 2048
jr $ra

#draws our sprite at specified position
drawSprite:
#loading colors for nice Sprite
li $t0, 0x3cd070
li $t1, 0x65da8e
li $t2, 0x33ff99
li $t3, 0x2fc363
li $t4, 0x259a4e
li $t5, 0xa9a9a9
li $t6, 0xdcdcdc
#row1
sw $t0, 0($a0)
sw $t0, 4($a0)
sw $t1, 8($a0)
sw $t1, 12($a0)
#row2
sw $t0, 124($a0)
sw $t0, 128($a0)
sw $t0, 132($a0)
sw $t1, 136($a0)
sw $t1, 140($a0)
sw $t1, 144($a0)
#row3
sw $t0, 248($a0)
sw $t0, 252($a0)
sw $t0, 256($a0)
sw $t0, 260($a0)
sw $t1, 264($a0)
sw $t1, 268($a0)
sw $t1, 272($a0)
sw $t2, 276($a0)
#row4
sw $t1, 376($a0)
sw $t3, 380($a0)
sw $zero, 384($a0)
sw $zero, 388($a0)
sw $zero, 392($a0)
sw $zero, 396($a0)
sw $t2, 400($a0)
sw $t2, 404($a0)
#row5
sw $t4, 504($a0)
sw $t3, 508($a0)
sw $t5, 512($a0)
sw $zero, 516($a0)
sw $zero, 520($a0)
sw $t6, 524($a0)
sw $t2, 528($a0)
sw $t2, 532($a0)
#row 6
sw $t0, 632($a0)
sw $t3, 636($a0)
sw $t5, 640($a0)
sw $t5, 644($a0)
sw $t6, 648($a0)
sw $t6, 652($a0)
sw $t2, 656($a0)
sw $t2, 660($a0)
#row 7
sw $t0, 764($a0)
sw $t0, 768($a0)
sw $t5, 772($a0)
sw $t6, 776($a0)
sw $t1, 780($a0)
sw $t2, 784($a0)
#row 8
sw $t3, 888($a0)
sw $t0, 896($a0)
sw $t0, 900($a0)
sw $t2, 904($a0)
sw $t2, 908($a0)
sw $t1, 916($a0)
#row 9
sw $t3, 1020($a0)
sw $t0, 1024($a0)
sw $t0, 1028($a0)
sw $t2, 1032($a0)
sw $t1, 1036($a0)
sw $t1, 1040($a0)
jr $ra

#colors pixels black if the new location of the sprite has not overwritten them, to prevent double images while having to redraw the minimum number of blocks
undrawSprite: #undraws relevant parts of sprite
#row 6
#loading colors for nice Sprite
li $t0, 0
li $t1, 0
li $t2, 0
li $t3, 0
li $t4, 0
li $t5, 0
li $t6, 0
#row1
sw $t0, 0($a0)
sw $t0, 4($a0)
sw $t1, 8($a0)
sw $t1, 12($a0)
#row2
sw $t0, 124($a0)
sw $t0, 128($a0)
sw $t0, 132($a0)
sw $t1, 136($a0)
sw $t1, 140($a0)
sw $t1, 144($a0)
#row3
sw $t0, 248($a0)
sw $t0, 252($a0)
sw $t0, 256($a0)
sw $t0, 260($a0)
sw $t1, 264($a0)
sw $t1, 268($a0)
sw $t1, 272($a0)
sw $t2, 276($a0)
#row4
sw $t1, 376($a0)
sw $t3, 380($a0)
sw $zero, 384($a0)
sw $zero, 388($a0)
sw $zero, 392($a0)
sw $zero, 396($a0)
sw $t2, 400($a0)
sw $t2, 404($a0)
#row5
sw $t4, 504($a0)
sw $t3, 508($a0)
sw $t5, 512($a0)
sw $zero, 516($a0)
sw $zero, 520($a0)
sw $t6, 524($a0)
sw $t2, 528($a0)
sw $t2, 532($a0)
#row 6
sw $t0, 632($a0)
sw $t3, 636($a0)
sw $t5, 640($a0)
sw $t5, 644($a0)
sw $t6, 648($a0)
sw $t6, 652($a0)
sw $t2, 656($a0)
sw $t2, 660($a0)
#row 7
sw $t0, 764($a0)
sw $t0, 768($a0)
sw $t5, 772($a0)
sw $t6, 776($a0)
sw $t1, 780($a0)
sw $t2, 784($a0)
#row 8
sw $t3, 888($a0)
sw $t0, 896($a0)
sw $t0, 900($a0)
sw $t2, 904($a0)
sw $t2, 908($a0)
sw $t1, 916($a0)
#row 9
sw $t3, 1020($a0)
sw $t0, 1024($a0)
sw $t0, 1028($a0)
sw $t2, 1032($a0)
sw $t1, 1036($a0)
sw $t1, 1040($a0)
jr $ra

#initiates jump
startJump:
li $a1, 20 # jump height
li $a2, 0 # iterator
jr $ra
startJumpLoop: #launches sprite
addiu $sp, $sp, -8
sw $ra, 0($sp)
#stores a0 value in stack pointer
sw $a0, 4($sp)
li $v0, 32
li $a0, 50
syscall #sleeps for 50ms (20 frames/second)
lw $a0, 4($sp)
#undraws sprite and redraws platforms
jal undrawSprite
jal drawTwentySix
jal drawTwentySixLoop
#loads $a0 from stack
lw $a0, 4($sp)
jal checkLeftRight
subi $a0, $a0, 128 #moves sprite up by one
#draws updated sprite
jal drawSprite
addi $a2, $a2, 1 #increments jump iterator
lw $ra, 0($sp)
addiu $sp, $sp, 8
bgt $a1, $a2, startJumpLoop#checks for how much the iterator should have jumped by now
jr $ra

#checks for user input to see whether sprite should move left or right
checkLeftRight:
	checkNewPress:
	lw $t0, 0xffff0000 #loads memory address where we record keystroke event
	beq $t0, 1, checkLetter
	jr $ra #exits of no new key sroke, else moves to checkLetter
	checkLetter:
	lw $t1, 0xffff0004 #loads memory address where ascii value of key is stored
	beq $t1, 0x6a, moveLeft #checks if j
	beq $t1, 0x6b, moveRight #checks if k
	jr $ra #exits if j or k is not pressed
	moveLeft: #moves drawSprite location one block left
	subi $a0, $a0, 8
	jr $ra
	moveRight: #moves drawSprite location one blockRight
	addi $a0, $a0, 8
	jr $ra

#controls fall down animation after max jump height of 20 blocks is reached
fallDown:
addiu $sp, $sp, -8
sw $ra, 0($sp)
#stores a0 value in stack pointer
sw $a0, 4($sp)
li $v0, 32
li $a0, 50
syscall #sleeps for 12ms (83 frames/second)
lw $a0, 4($sp)
#undraws sprite and redraws platforms
jal undrawSprite
jal drawTwentySix
jal drawTwentySixLoop
#loads $a0 from stack
lw $a0, 4($sp)
jal checkLeftRight
addi $a0, $a0, 128 #moves sprite down by one
#draws updated sprite
jal drawSprite
lw $ra, 0($sp)
addiu $sp, $sp, 8
lw $a1, 1152($a0) #checks if bottom of $a0 tile nine units down is orange
addi $a2, $a0, 1152
bgt $a2, 0x10009b80, exitPattern #retry if falls to illegal area
bne $a1, 0xff9933, fallDown#checks if we have hit a tile
blt $a2, 0x10009000, setScoreTwenty
jr $ra
setScoreTwenty:
li $t0, 20
lw $t1, score
add $t0, $t0, $t1
sw $t0, score
jr $ra

#updates platform arrays for redrawing once the sprite reaches a certain height so screen can eb redrawn with platforms higher than the sprite moving down and generating new ones to replace the ones that disappear
updateArrays:
li $t0, 64 # stores 64 (number of platforms to preserve on screen)*4
li $t1, 0 # iterator
jr $ra
updateArraysLoop: #updates arrays everytime we are 20 above base height
	updateFunction:
	lw $t4, platformY($t1)
	addiu $t5, $t1, 40
	addiu $t4, $t4, 20
	sw $t4, tempPlatformY($t5)
	lw $t4, platformX($t1) 
	sw $t4, tempPlatformX($t5)
	addi $t1, $t1, 4
	blt $t1, $t0, updateFunction
	li $t0, 0 #iterator
	li $s0, 0 #height param
	li $t1, 32 # stores 104 (number of platforms(26)*4)
	fillEmptyBase: #shifts all registers 
	#generating random number for x-coordinate of starting point of platform
	li $v0, 42
	li $a0, 0
	li $a1, 22
	syscall
	sw $a0, tempPlatformX($t0)
	#generating random number for y-coordinate of platform
	li $v0, 42
	li $a0, 0
	li $a1, 3
	syscall
	add $a0, $a0, $s0
	sw $a0, tempPlatformY($t0)
	addi $t0, $t0, 4 #increment the iterator
	#generating random number for x-coordinate of starting point of platform
	li $v0, 42
	li $a0, 0
	li $a1, 22
	syscall
	sw $a0, tempPlatformX($t0)
	#generating random number for y-coordinate of platform
	li $v0, 42
	li $a0, 0
	li $a1, 3
	syscall
	add $a0, $a0, $s0
	sw $a0, tempPlatformY($t0)
	addi $s0, $s0, 4 #increment height param
	addi $t0, $t0, 4 #increment the iterator
	blt $t0, $t1, fillEmptyBase
	li $t0, 0 #iterator
	li $s0, 0 #height param
	li $t1, 104 # stores 104 (number of platforms(26)*4)
	CopyTempToPermanent:
	lw $t2, tempPlatformX($t0)
	sw $t2, platformX($t0)
	lw $t2, tempPlatformY($t0)
	sw $t2, platformY($t0)
	addi $t0, $t0, 4
	blt $t0, $t1, CopyTempToPermanent
	jr $ra

#erases old platforms
undrawTwentySix: #draws 26 platforms using a random number generator
lw $t0, displayAddress # $t0 stores the base address for display
li $t1, 104 # stores 144 (number of platforms on screen)*4
li $t2, 0 # iterator
jr $ra
undrawTwentySixLoop: #draws each platform
lw $t3, platformX($t2) #loads x-coordinate of platform to $t3
lw $t4, platformY($t2) #loads y-coordinate of platform to $t4
li $t5, 0x0 #loads black to $t5
#computing memory address
li $s0, 128 #multiplicant
mul $t4, $t4, $s0
li $s0, 4 #multiplicant
mul $t3, $t3, $s0
add $t6, $t4, $t0
add $t6, $t6, $t3 #memory address of first block of platform
#drawing platform of length 10
sw $t5, 0($t6)
sw $t5, 4($t6)
sw $t5, 8($t6)
sw $t5, 12($t6)
sw $t5, 16($t6) 
sw $t5, 20($t6)
sw $t5, 24($t6) 
sw $t5, 28($t6) 
sw $t5, 32($t6) 
sw $t5, 36($t6) 
addi $t2, $t2, 4
blt $t2, $t1, undrawTwentySixLoop#checks for when iterator, $t2, reaches 2048
jr $ra

#function that controls drawing numbers to update score	
drawNumber:
beq $a2, 0, drawZero
beq $a2, 1, drawOne
beq $a2, 2, drawTwo
beq $a2, 3, drawThree
beq $a2, 4, drawFour
beq $a2, 5, drawFive
beq $a2, 6, drawSix
beq $a2, 7, drawSeven
beq $a2, 8, drawEight
beq $a2, 9, drawNine

drawZero:
#$a0 is digit start
sw $a3, 0($a1)
sw $a3, 4($a1)
sw $a3, 8($a1)
sw $a3, 128($a1)
sw $a3, 136($a1)
sw $a3, 256($a1)
sw $a3, 264($a1)
sw $a3, 384($a1)
sw $a3, 392($a1)
sw $a3, 512($a1)
sw $a3, 516($a1)
sw $a3, 520($a1)
jr $ra

drawOne:
#$a0 is digit start
sw $a3, 4($a1)
sw $a3, 132($a1)
sw $a3, 260($a1)
sw $a3, 388($a1)
sw $a3, 516($a1)
jr $ra

drawTwo:
#$a0 is digit start
sw $a3, 0($a1)
sw $a3, 4($a1)
sw $a3, 8($a1)
sw $a3, 136($a1)
sw $a3, 256($a1)
sw $a3, 260($a1)
sw $a3, 264($a1)
sw $a3, 384($a1)
sw $a3, 512($a1)
sw $a3, 516($a1)
sw $a3, 520($a1)
jr $ra

drawThree:
#$a0 is digit start
sw $a3, 0($a1)
sw $a3, 4($a1)
sw $a3, 8($a1)
sw $a3, 136($a1)
sw $a3, 256($a1)
sw $a3, 260($a1)
sw $a3, 264($a1)
sw $a3, 392($a1)
sw $a3, 512($a1)
sw $a3, 516($a1)
sw $a3, 520($a1)
jr $ra

drawFour:
#$a0 is digit start
sw $a3, 0($a1)
sw $a3, 8($a1)
sw $a3, 128($a1)
sw $a3, 136($a1)
sw $a3, 256($a1)
sw $a3, 260($a1)
sw $a3, 264($a1)
sw $a3, 392($a1)
sw $a3, 520($a1)
jr $ra


drawFive:
#$a0 is digit start
sw $a3, 0($a1)
sw $a3, 4($a1)
sw $a3, 8($a1)
sw $a3, 128($a1)
sw $a3, 256($a1)
sw $a3, 260($a1)
sw $a3, 264($a1)
sw $a3, 392($a1)
sw $a3, 512($a1)
sw $a3, 516($a1)
sw $a3, 520($a1)
jr $ra

drawSix:
#$a0 is digit start
sw $a3, 0($a1)
sw $a3, 4($a1)
sw $a3, 8($a1)
sw $a3, 128($a1)
sw $a3, 256($a1)
sw $a3, 260($a1)
sw $a3, 264($a1)
sw $a3, 384($a1)
sw $a3, 392($a1)
sw $a3, 512($a1)
sw $a3, 516($a1)
sw $a3, 520($a1)
jr $ra

drawSeven:
#$a0 is digit start
sw $a3, 0($a1)
sw $a3, 4($a1)
sw $a3, 8($a1)
sw $a3, 136($a1)
sw $a3, 264($a1)
sw $a3, 392($a1)
sw $a3, 520($a1)
jr $ra

drawEight:
#$a0 is digit start
sw $a3, 0($a1)
sw $a3, 4($a1)
sw $a3, 8($a1)
sw $a3, 128($a1)
sw $a3, 136($a1)
sw $a3, 256($a1)
sw $a3, 260($a1)
sw $a3, 264($a1)
sw $a3, 384($a1)
sw $a3, 392($a1)
sw $a3, 512($a1)
sw $a3, 516($a1)
sw $a3, 520($a1)
jr $ra

drawNine:
#$a0 is digit start
sw $a3, 0($a1)
sw $a3, 4($a1)
sw $a3, 8($a1)
sw $a3, 128($a1)
sw $a3, 136($a1)
sw $a3, 256($a1)
sw $a3, 260($a1)
sw $a3, 264($a1)
sw $a3, 392($a1)
sw $a3, 520($a1)
jr $ra
	
#controls how score board is updated
drawScore:
addiu $sp, $sp, -4
sw $ra 0($sp)
lw $t0, score
divu $t1, $t0, 500
mfhi $t1
beq $t1, 0, drawScoreWow
divu $t1, $t0, 200
mfhi $t1
beq $t1, 0, drawScoreAwesome
divu $t1, $t0, 100
mfhi $t1
beq $t1, 0, drawScorePoggers
li $a3, 0xc8df52
#first digit
divu $a2, $t0, 10000
mflo $a2
lw $a1, charFour
jal drawNumber
mfhi $a2
sub $t0, $t0, $a2 
#second digit
divu $a2, $a2, 1000
mflo $a2
lw $a1, charFive
jal drawNumber
mfhi $a2
sub $t0, $t0, $a2 
#third digit
divu $a2, $a2, 100
mflo $a2
lw $a1, charSix
jal drawNumber
mfhi $a2
sub $t0, $t0, $a2
#fourth digit
divu $a2, $a2, 10
mflo $a2
lw $a1, charSeven
jal drawNumber
mfhi $a2
sub $t0, $t0, $a2
#fifth digit
lw $a1, charEight
jal drawNumber
lw $ra 0($sp)
addiu $sp, $sp, 4
jr $ra 
	drawScoreWow:
	li $a3, 0xff087f
	lw $a1, charThree
	jal drawW
	lw $a1, charFour
	jal drawO
	lw $a1, charFive
	jal drawW
	lw $a1, charSix
	jal drawExclamation
	lw $ra 0($sp)
	addiu $sp, $sp, 4
	jr $ra 
	drawScoreAwesome:
	li $a3, 0x40e0d0
	lw $a1, charOne
	jal drawA
	lw $a1, charTwo
	jal drawW
	lw $a1, charThree
	jal drawE
	lw $a1, charFour
	jal drawS
	lw $a1, charFive
	jal drawO
	lw $a1, charSix
	jal drawM
	lw $a1, charSeven
	jal drawE
	lw $a1, charEight
	jal drawExclamation
	lw $ra 0($sp)	
	addiu $sp, $sp, 4
	jr $ra 
	drawScorePoggers:
	li $a3, 0xa32cc4
	lw $a1, charOne
	jal drawP
	lw $a1, charTwo
	jal drawO
	lw $a1, charThree
	jal drawG
	lw $a1, charFour
	jal drawG
	lw $a1, charFive
	jal drawE
	lw $a1, charSix
	jal drawR
	lw $a1, charSeven
	jal drawS
	lw $a1, charEight
	jal drawExclamation
	lw $ra 0($sp)	
	addiu $sp, $sp, 4
	jr $ra 

#deletes old score so it can be instantaneously updated
undrawScore:
addiu $sp, $sp, -4
sw $ra 0($sp)
lw $t0, score
divu $t1, $t0, 500
mfhi $t1
beq $t1, 0, undrawScoreWow
divu $t1, $t0, 200
mfhi $t1
beq $t1, 0, undrawScoreAwesome
divu $t1, $t0, 100
mfhi $t1
beq $t1, 0, undrawScorePoggers
li $a3, 0x0
#first digit
divu $a2, $t0, 10000
mflo $a2
lw $a1, charFour
jal drawNumber
mfhi $a2
sub $t0, $t0, $a2 
#second digit
divu $a2, $a2, 1000
mflo $a2
lw $a1, charFive
jal drawNumber
mfhi $a2
sub $t0, $t0, $a2 
#third digit
divu $a2, $a2, 100
mflo $a2
lw $a1, charSix
jal drawNumber
mfhi $a2
sub $t0, $t0, $a2
#fourth digit
divu $a2, $a2, 10
mflo $a2
lw $a1, charSeven
jal drawNumber
mfhi $a2
sub $t0, $t0, $a2
#fifth digit
lw $a1, charEight
jal drawNumber
lw $ra 0($sp)
addiu $sp, $sp, 4
jr $ra 
	undrawScoreWow:
	li $a3, 0x0
	lw $a1, charThree
	jal drawW
	lw $a1, charFour
	jal drawO
	lw $a1, charFive
	jal drawW
	lw $a1, charSix
	jal drawExclamation
	lw $ra 0($sp)
	addiu $sp, $sp, 4
	jr $ra 
	undrawScoreAwesome:
	li $a3, 0x0
	lw $a1, charOne
	jal drawA
	lw $a1, charTwo
	jal drawW
	lw $a1, charThree
	jal drawE
	lw $a1, charFour
	jal drawS
	lw $a1, charFive
	jal drawO
	lw $a1, charSix
	jal drawM
	lw $a1, charSeven
	jal drawE
	lw $a1, charEight
	jal drawExclamation
	lw $ra 0($sp)	
	addiu $sp, $sp, 4
	jr $ra 
	undrawScorePoggers:
	li $a3, 0x0
	lw $a1, charOne
	jal drawP
	lw $a1, charTwo
	jal drawO
	lw $a1, charThree
	jal drawG
	lw $a1, charFour
	jal drawG
	lw $a1, charFive
	jal drawE
	lw $a1, charSix
	jal drawR
	lw $a1, charSeven
	jal drawS
	lw $a1, charEight
	jal drawExclamation
	lw $ra 0($sp)	
	addiu $sp, $sp, 4
	jr $ra 

drawA:
#$a0 is digit start
sw $a3, 0($a1)
sw $a3, 4($a1)
sw $a3, 8($a1)
sw $a3, 128($a1)
sw $a3, 136($a1)
sw $a3, 256($a1)
sw $a3, 260($a1)
sw $a3, 264($a1)
sw $a3, 384($a1)
sw $a3, 392($a1)
sw $a3, 512($a1)
sw $a3, 520($a1)
jr $ra

drawB:
#$a0 is digit start
sw $a3, 0($a1)
sw $a3, 128($a1)
sw $a3, 256($a1)
sw $a3, 260($a1)
sw $a3, 264($a1)
sw $a3, 384($a1)
sw $a3, 392($a1)
sw $a3, 512($a1)
sw $a3, 516($a1)
sw $a3, 520($a1)
jr $ra

drawC:
#$a0 is digit start
sw $a3, 0($a1)
sw $a3, 4($a1)
sw $a3, 8($a1)
sw $a3, 128($a1)
sw $a3, 256($a1)
sw $a3, 384($a1)
sw $a3, 512($a1)
sw $a3, 516($a1)
sw $a3, 520($a1)
jr $ra

drawD:
#$a0 is digit start
sw $a3, 8($a1)
sw $a3, 136($a1)
sw $a3, 256($a1)
sw $a3, 260($a1)
sw $a3, 264($a1)
sw $a3, 384($a1)
sw $a3, 392($a1)
sw $a3, 512($a1)
sw $a3, 516($a1)
sw $a3, 520($a1)
jr $ra

drawE:
#$a0 is digit start
sw $a3, 0($a1)
sw $a3, 4($a1)
sw $a3, 8($a1)
sw $a3, 128($a1)
sw $a3, 256($a1)
sw $a3, 260($a1)
sw $a3, 264($a1)
sw $a3, 384($a1)
sw $a3, 512($a1)
sw $a3, 516($a1)
sw $a3, 520($a1)
jr $ra

drawF:
#$a0 is digit start
sw $a3, 0($a1)
sw $a3, 4($a1)
sw $a3, 8($a1)
sw $a3, 128($a1)
sw $a3, 256($a1)
sw $a3, 260($a1)
sw $a3, 264($a1)
sw $a3, 384($a1)
sw $a3, 512($a1)
jr $ra

drawG:
#$a0 is digit start
sw $a3, 0($a1)
sw $a3, 4($a1)
sw $a3, 8($a1)
sw $a3, 128($a1)
sw $a3, 136($a1)
sw $a3, 256($a1)
sw $a3, 260($a1)
sw $a3, 264($a1)
sw $a3, 392($a1)
sw $a3, 512($a1)
sw $a3, 516($a1)
sw $a3, 520($a1)
jr $ra

drawH:
#$a0 is digit start
sw $a3, 0($a1)
sw $a3, 8($a1)
sw $a3, 128($a1)
sw $a3, 136($a1)
sw $a3, 256($a1)
sw $a3, 260($a1)
sw $a3, 264($a1)
sw $a3, 384($a1)
sw $a3, 392($a1)
sw $a3, 512($a1)
sw $a3, 520($a1)
jr $ra

drawI:
#$a0 is digit start
sw $a3, 0($a1)
sw $a3, 4($a1)
sw $a3, 8($a1)
sw $a3, 132($a1)
sw $a3, 260($a1)
sw $a3, 388($a1)
sw $a3, 512($a1)
sw $a3, 516($a1)
sw $a3, 520($a1)
jr $ra

drawJ:
#$a0 is digit start
sw $a3, 0($a1)
sw $a3, 4($a1)
sw $a3, 8($a1)
sw $a3, 132($a1)
sw $a3, 260($a1)
sw $a3, 388($a1)
sw $a3, 512($a1)
sw $a3, 516($a1)
jr $ra

drawK:
#$a0 is digit start
sw $a3, 0($a1)
sw $a3, 128($a1)
sw $a3, 256($a1)
sw $a3, 264($a1)
sw $a3, 384($a1)
sw $a3, 388($a1)
sw $a3, 512($a1)
sw $a3, 520($a1)
jr $ra

drawL:
#$a0 is digit start
sw $a3, 0($a1)
sw $a3, 128($a1)
sw $a3, 256($a1)
sw $a3, 384($a1)
sw $a3, 512($a1)
sw $a3, 516($a1)
jr $ra

drawM:
#$a0 is digit start
sw $a3, 0($a1)
sw $a3, 8($a1)
sw $a3, 128($a1)
sw $a3, 132($a1)
sw $a3, 136($a1)
sw $a3, 256($a1)
sw $a3, 264($a1)
sw $a3, 384($a1)
sw $a3, 392($a1)
sw $a3, 512($a1)
sw $a3, 520($a1)
jr $ra

drawN:
#$a0 is digit start
sw $a3, 0($a1)
sw $a3, 128($a1)
sw $a3, 132($a1)
sw $a3, 136($a1)
sw $a3, 256($a1)
sw $a3, 264($a1)
sw $a3, 384($a1)
sw $a3, 392($a1)
sw $a3, 512($a1)
sw $a3, 520($a1)
jr $ra

drawO:
#$a0 is digit start
sw $a3, 0($a1)
sw $a3, 4($a1)
sw $a3, 8($a1)
sw $a3, 128($a1)
sw $a3, 136($a1)
sw $a3, 256($a1)
sw $a3, 264($a1)
sw $a3, 384($a1)
sw $a3, 392($a1)
sw $a3, 512($a1)
sw $a3, 516($a1)
sw $a3, 520($a1)
jr $ra

drawP:
#$a0 is digit start
sw $a3, 0($a1)
sw $a3, 4($a1)
sw $a3, 8($a1)
sw $a3, 128($a1)
sw $a3, 136($a1)
sw $a3, 256($a1)
sw $a3, 260($a1)
sw $a3, 264($a1)
sw $a3, 384($a1)
sw $a3, 512($a1)
jr $ra

drawQ:
#$a0 is digit start
sw $a3, 0($a1)
sw $a3, 4($a1)
sw $a3, 8($a1)
sw $a3, 128($a1)
sw $a3, 136($a1)
sw $a3, 256($a1)
sw $a3, 260($a1)
sw $a3, 264($a1)
sw $a3, 392($a1)
sw $a3, 520($a1)
jr $ra

drawR:
#$a0 is digit start
sw $a3, 0($a1)
sw $a3, 128($a1)
sw $a3, 132($a1)
sw $a3, 136($a1)
sw $a3, 256($a1)
sw $a3, 264($a1)
sw $a3, 384($a1)
sw $a3, 512($a1)
jr $ra

drawS:
#$a0 is digit start
sw $a3, 0($a1)
sw $a3, 4($a1)
sw $a3, 8($a1)
sw $a3, 128($a1)
sw $a3, 256($a1)
sw $a3, 260($a1)
sw $a3, 264($a1)
sw $a3, 392($a1)
sw $a3, 512($a1)
sw $a3, 516($a1)
sw $a3, 520($a1)
jr $ra

drawT:
#$a0 is digit start
sw $a3, 0($a1)
sw $a3, 4($a1)
sw $a3, 8($a1)
sw $a3, 132($a1)
sw $a3, 260($a1)
sw $a3, 388($a1)
sw $a3, 516($a1)
jr $ra

drawU:
#$a0 is digit start
sw $a3, 0($a1)
sw $a3, 8($a1)
sw $a3, 128($a1)
sw $a3, 136($a1)
sw $a3, 256($a1)
sw $a3, 264($a1)
sw $a3, 384($a1)
sw $a3, 392($a1)
sw $a3, 512($a1)
sw $a3, 516($a1)
sw $a3, 520($a1)
jr $ra

drawV:
#$a0 is digit start
sw $a3, 0($a1)
sw $a3, 8($a1)
sw $a3, 128($a1)
sw $a3, 136($a1)
sw $a3, 256($a1)
sw $a3, 264($a1)
sw $a3, 384($a1)
sw $a3, 392($a1)
sw $a3, 516($a1)
jr $ra

drawW:
#$a0 is digit start
sw $a3, 0($a1)
sw $a3, 8($a1)
sw $a3, 128($a1)
sw $a3, 136($a1)
sw $a3, 256($a1)
sw $a3, 264($a1)
sw $a3, 384($a1)
sw $a3, 388($a1)
sw $a3, 392($a1)
sw $a3, 512($a1)
sw $a3, 520($a1)
jr $ra

drawX:
#$a0 is digit start
sw $a3, 0($a1)
sw $a3, 8($a1)
sw $a3, 132($a1)
sw $a3, 256($a1)
sw $a3, 264($a1)
jr $ra

drawY:
#$a0 is digit start
sw $a3, 0($a1)
sw $a3, 8($a1)
sw $a3, 132($a1)
sw $a3, 260($a1)
sw $a3, 388($a1)
sw $a3, 516($a1)
jr $ra

drawZ:
#$a0 is digit start
sw $a3, 0($a1)
sw $a3, 4($a1)
sw $a3, 8($a1)
sw $a3, 136($a1)
sw $a3, 260($a1)
sw $a3, 384($a1)
sw $a3, 512($a1)
sw $a3, 516($a1)
sw $a3, 520($a1)
jr $ra

drawExclamation:
#$a0 is digit start
sw $a3, 4($a1)
sw $a3, 132($a1)
sw $a3, 260($a1)
sw $a3, 516($a1)
jr $ra

#draws the exit screen once user loses
drawExitScreen:
#initializing name arrays
	li $t0, 0x10008c80
	li $t1, 0
	sw $t0, nameAddress($t1)
	li $t0, 0x10008c90
	addi $t1, $t1, 4
	sw $t0, nameAddress($t1)
	li $t0, 0x10008ca0
	addi $t1, $t1, 4
	sw $t0, nameAddress($t1)
	li $t0, 0x10008cb0
	addi $t1, $t1, 4
	sw $t0, nameAddress($t1)
	li $t0, 0x10008cc0
	addi $t1, $t1, 4
	sw $t0, nameAddress($t1)
	li $t0, 0x10008cd0
	addi $t1, $t1, 4
	sw $t0, nameAddress($t1)
	li $t0, 0x10008ce0
	addi $t1, $t1, 4
	sw $t0, nameAddress($t1)
	li $t0, 0x10008cf0
	addi $t1, $t1, 4
	sw $t0, nameAddress($t1)
addiu $sp, $sp, -4
sw $ra 0($sp)
	drawGameOver:
	li $a3, 0xffff00
	lw $a1, G
	jal drawG
	lw $a1, A
	jal drawA
	lw $a1, M
	jal drawM
	lw $a1, E1
	jal drawE
	lw $a1,O
	jal drawO
	lw $a1, V
	jal drawV
	lw $a1, E2
	jal drawE
	lw $a1, R
	jal drawR
	li $t0, 0
	li $a3, 0x89cff0
	drawName:
	lw $t1, name($t0)
	beq $t0, 32, drawFinalScore
	beq $t1, 0, drawFinalScore
	beq $t1, 0x61,callDrawA
	beq $t1, 0x62,callDrawB
	beq $t1, 0x63,callDrawC
	beq $t1, 0x64,callDrawD
	beq $t1, 0x65,callDrawE
	beq $t1, 0x66,callDrawF
	beq $t1, 0x67,callDrawG
	beq $t1, 0x68,callDrawH
	beq $t1, 0x69,callDrawI
	beq $t1, 0x6a,callDrawJ
	beq $t1, 0x6b,callDrawK
	beq $t1, 0x6c,callDrawL
	beq $t1, 0x6d,callDrawM
	beq $t1, 0x6e,callDrawN
	beq $t1, 0x6f,callDrawO
	beq $t1, 0x70,callDrawP
	beq $t1, 0x71,callDrawQ
	beq $t1, 0x72,callDrawR
	beq $t1, 0x73,callDrawS
	beq $t1, 0x74,callDrawT
	beq $t1, 0x75,callDrawU
	beq $t1, 0x76,callDrawV
	beq $t1, 0x77,callDrawW
	beq $t1, 0x78,callDrawX
	beq $t1, 0x79,callDrawY
	beq $t1, 0x7a,callDrawZ
		callDrawA:
		li $a3, 0x89cff0
		lw $a1, nameAddress($t0)
		jal drawA
		addi $t0, $t0, 4
		j drawName
		callDrawB:
		li $a3, 0x89cff0
		lw $a1, nameAddress($t0)
		jal drawB
		addi $t0, $t0, 4
		j drawName
		callDrawC:
		li $a3, 0x89cff0
		lw $a1, nameAddress($t0)
		jal drawC
		addi $t0, $t0, 4
		j drawName
		callDrawD:
		li $a3, 0x89cff0
		lw $a1, nameAddress($t0)
		jal drawD
		addi $t0, $t0, 4
		j drawName
		callDrawE:
		li $a3, 0x89cff0
		lw $a1, nameAddress($t0)
		jal drawE
		addi $t0, $t0, 4
		j drawName
		callDrawF:
		li $a3, 0x89cff0
		lw $a1, nameAddress($t0)
		jal drawF
		addi $t0, $t0, 4
		j drawName
		callDrawG:
		li $a3, 0x89cff0
		lw $a1, nameAddress($t0)
		jal drawG
		addi $t0, $t0, 4
		j drawName
		callDrawH:
		li $a3, 0x89cff0
		lw $a1, nameAddress($t0)
		jal drawH
		addi $t0, $t0, 4
		j drawName
		callDrawI:
		li $a3, 0x89cff0
		lw $a1, nameAddress($t0)
		jal drawI
		addi $t0, $t0, 4
		j drawName
		callDrawJ:
		li $a3, 0x89cff0
		lw $a1, nameAddress($t0)
		jal drawJ
		addi $t0, $t0, 4
		j drawName
		callDrawK:
		li $a3, 0x89cff0
		lw $a1, nameAddress($t0)
		jal drawK
		addi $t0, $t0, 4
		j drawName
		callDrawL:
		li $a3, 0x89cff0
		lw $a1, nameAddress($t0)
		jal drawL
		addi $t0, $t0, 4
		j drawName
		callDrawM:
		li $a3, 0x89cff0
		lw $a1, nameAddress($t0)
		jal drawM
		addi $t0, $t0, 4
		j drawName
		callDrawN:
		li $a3, 0x89cff0
		lw $a1, nameAddress($t0)
		jal drawN
		addi $t0, $t0, 4
		j drawName
		callDrawO:
		li $a3, 0x89cff0
		lw $a1, nameAddress($t0)
		jal drawO
		addi $t0, $t0, 4
		j drawName
		callDrawP:
		li $a3, 0x89cff0
		lw $a1, nameAddress($t0)
		jal drawP
		addi $t0, $t0, 4
		j drawName
		callDrawQ:
		li $a3, 0x89cff0
		lw $a1, nameAddress($t0)
		jal drawQ
		addi $t0, $t0, 4
		j drawName
		callDrawR:
		li $a3, 0x89cff0
		lw $a1, nameAddress($t0)
		jal drawR
		addi $t0, $t0, 4
		j drawName
		callDrawS:
		li $a3, 0x89cff0
		lw $a1, nameAddress($t0)
		jal drawS
		addi $t0, $t0, 4
		j drawName
		callDrawT:
		li $a3, 0x89cff0
		lw $a1, nameAddress($t0)
		jal drawT
		addi $t0, $t0, 4
		j drawName
		callDrawU:
		li $a3, 0x89cff0
		lw $a1, nameAddress($t0)
		jal drawU
		addi $t0, $t0, 4
		j drawName
		callDrawV:
		li $a3, 0x89cff0
		lw $a1, nameAddress($t0)
		jal drawV
		addi $t0, $t0, 4
		j drawName
		callDrawW:
		li $a3, 0x89cff0
		lw $a1, nameAddress($t0)
		jal drawW
		addi $t0, $t0, 4
		j drawName
		callDrawX:
		li $a3, 0x89cff0
		lw $a1, nameAddress($t0)
		jal drawX
		addi $t0, $t0, 4
		j drawName
		callDrawY:
		li $a3, 0x89cff0
		lw $a1, nameAddress($t0)
		jal drawY
		addi $t0, $t0, 4
		j drawName
		callDrawZ:
		li $a3, 0x89cff0
		lw $a1, nameAddress($t0)
		jal drawZ
		addi $t0, $t0, 4
		j drawName
	drawFinalScore:
	lw $t0, score
	#first digit
	li $a3, 0xff0000
	divu $a2, $t0, 10000
	mflo $a2
	lw $a1, F1
	jal drawNumber
	mfhi $a2
	sub $t0, $t0, $a2 
	#second digit
	li $a3, 0xffa500
	divu $a2, $a2, 1000
	mflo $a2
	lw $a1, F2
	jal drawNumber
	mfhi $a2
	sub $t0, $t0, $a2 
	#third digit
	li $a3, 0x008000
	divu $a2, $a2, 100
	mflo $a2
	lw $a1, F3
	jal drawNumber
	mfhi $a2
	sub $t0, $t0, $a2
	#fourth digit
	li $a3, 0x0000ff
	divu $a2, $a2, 10
	mflo $a2
	lw $a1, F4
	jal drawNumber
	mfhi $a2
	sub $t0, $t0, $a2
	#fifth digit
	li $a3, 0xee82ee
	lw $a1, F5
	jal drawNumber
	lw $ra 0($sp)
	addiu $sp, $sp, 4
	jr $ra 
	lw $ra 0($sp)	
	addiu $sp, $sp, 4
	jr $ra 
