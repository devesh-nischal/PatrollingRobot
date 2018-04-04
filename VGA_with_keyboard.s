.equ KEYBOARD, 0xff200100
.equ RED_LEDS, 0xff200000
.equ ADDR_VGA, 0x08000000
.equ ADDR_CHAR, 0x09000000
.text

.global _start
_start:
    movia r16, KEYBOARD
	movui r17, 0x01
	stwio r17, 4(r16)
	movui r17, 0x80
    wrctl ctl3, r17
	movui r17, 0x01
	wrctl ctl0, r17
	movia r17, RED_LEDS
	stwio r0, 0(r17)
	
	movia r18, ADDR_VGA
	movia r19, ADDR_CHAR
	movui r17, 0xf800		#red
	movui r20, 0x0082		#130 (starting x address)
	movui r23, 0x00be		#160 (ending x address)
	
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
	movui r23, 0x00be		#160 (ending x address)
	
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
	movui r21, 0x00be		#190 (constant x address)
	muli r21, r21, 0x0002
	muli r22, r20, 0x0400
	add r22, r22, r21
	add r22, r22, r18
	sthio r17, 0(r22)
	addi r20, r20, 0x01
	bne r20, r23, RIGHT_LINE

	movui r17, 0x004d		#ascii for 'M'
	sthio r17, 11(r19)	#3874
/*
	movui r17, 0x006f		#ascii for 'o'
	sthio r17, 21(r19)	#3875

	movui r17, 0x0064		#ascii for 'd'
	sthio r17, 23(r19)	#3876

	movui r17, 0x0065		#ascii for 'e'
	sthio r17, 25(r19)	#3877

	movui r17, 0x003a		#ascii for ':'
	sthio r17, 27(r19)	#3878
*/
LOOP:
    br LOOP
	

.section .exceptions, "ax"
IHandler:
CHECK_VALIDITY:
    ldwio et, 0(r16)
	srli r19, et, 15
	andi r19, r19, 0x0001
	movui r18, 0x01
	bne r19, r18, CHECK_VALIDITY
	
	andi et, et, 0x00ff
	movui r18, 0x29
	bne et, r18, EXIT
	ldwio r19, 0(r17)
	bne r0, r19, OFF
	br ON
	
ON:
	movui r18, 0x01
	stwio r18, 0(r17)
	br EXIT
OFF:
	movui r18, 0x00
	stwio r18, 0(r17)
	br EXIT
	
EXIT:
	subi ea, ea, 4
    eret
