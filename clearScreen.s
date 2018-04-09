.equ ADDR_VGA, 0x08000000
.equ ADDR_CHAR, 0x09000000

.global clearScreen

clearScreen:
	movia r16, ADDR_VGA
	movui r17, 0x0000		#0 (starting x address) i
	movui r18, 0x0000		#0 (starting y address) j
	movui r19, 0x0140		#320 (ending x address)
	movui r20, 0x00f0		#240 (ending y address)
	
Y_LOOP_PIXEL:
X_LOOP_PIXEL:
	muli r21, r17, 0x0002
	muli r22, r18, 0x0400
	add r22, r22, r21
	add r22, r22, r16
	sthio r0, 0(r22)	#black
	addi r17, r17, 0x01
	bne r17, r19, X_LOOP_PIXEL
	movui r17, 0x0000
    addi r18, r18, 0x01
	bne r18, r20, Y_LOOP_PIXEL

	movia r16, ADDR_CHAR
	movui r17, 0x0000		#0 (starting x address) i
	movui r18, 0x0000		#0 (starting y address) j
	movui r19, 0x0050		#80 (ending x address)
	movui r20, 0x003c		#60 (ending y address)
	
Y_LOOP_CHAR:
X_LOOP_CHAR:
	muli r22, r18, 0x0080
	add r22, r22, r17
	add r22, r22, r16
	stbio r0, 0(r22)	#NULL character
	addi r17, r17, 0x01
	bne r17, r19, X_LOOP_CHAR
    movui r17, 0x0000
	addi r18, r18, 0x01
	bne r18, r20, Y_LOOP_CHAR
	
	ret