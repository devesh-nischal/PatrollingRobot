.equ ADDR_VGA, 0x08000000

.global drawTable

drawTable:
	
	movia r18, ADDR_VGA
	movui r17, 0xf800		#red
	movui r20, 0x0082		#130 (starting x address)
	movui r23, 0x00cd		#205 (ending x address)
	
TOP_LINE:
	movui r21, 0x0073		#115 (constant y address)
	muli r22, r20, 0x0002
	muli r21, r21, 0x0400
	add r22, r22, r21
	add r22, r22, r18
	sthio r17, 0(r22)
	addi r20, r20, 0x01
	bne r20, r23, TOP_LINE

	movui r17, 0xf800		#red
	movui r20, 0x0082		#130 (starting x address)
	movui r23, 0x00cd		#205 (ending x address)
	
BOTTOM_LINE:
	movui r21, 0x007d		#225 (constant y address)
	muli r22, r20, 0x0002
	muli r21, r21, 0x0400
	add r22, r22, r21
	add r22, r22, r18
	sthio r17, 0(r22)
	addi r20, r20, 0x01
	bne r20, r23, BOTTOM_LINE

	movui r17, 0xf800		#red
	movui r20, 0x0073		#115 (starting y address)
	movui r23, 0x007d		#225 (ending y address)
	
LEFT_LINE:
	movui r21, 0x0082		#130 (constant x address)
	muli r21, r21, 0x0002
	muli r22, r20, 0x0400
	add r22, r22, r21
	add r22, r22, r18
	sthio r17, 0(r22)
	addi r20, r20, 0x01
	bne r20, r23, LEFT_LINE

	movui r17, 0xf800		#red
	movui r20, 0x0073		#115 (starting y address)
	movui r23, 0x007d		#225 (ending y address)
	
MIDDLE_LINE:
	movui r21, 0x00a0		#160 (constant x address)
	muli r21, r21, 0x0002
	muli r22, r20, 0x0400
	add r22, r22, r21
	add r22, r22, r18
	sthio r17, 0(r22)
	addi r20, r20, 0x01
	bne r20, r23, MIDDLE_LINE

	movui r17, 0xf800		#red
	movui r20, 0x0073		#115 (starting y address)
	movui r23, 0x007d		#225 (ending y address)
	 
RIGHT_LINE:
	movui r21, 0x00cd		#205 (constant x address)
	muli r21, r21, 0x0002
	muli r22, r20, 0x0400
	add r22, r22, r21
	add r22, r22, r18
	sthio r17, 0(r22)
	addi r20, r20, 0x01
	bne r20, r23, RIGHT_LINE
	
	ret