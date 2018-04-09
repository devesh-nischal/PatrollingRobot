.equ KEYBOARD, 0xff200100
.equ RED_LEDS, 0xff200000
.equ ADDR_VGA, 0x08000000
.equ ADDR_CHAR, 0x09000000

.data
Mode:
    .skip 8         #base stores the mode of the robot, (base+4) stores the number of time that the space interrupt has been read

.text

.global _start
_start:
    movia sp, 0x03fffffc
    
    call clearScreen
    
	movia r16, Mode
	movui r17, 0x00
	stw r17, 0(r16)			#since initial mode is stopped
	stw r17, 4(r16)			#since the interrupt has not happened yet
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
	
	movia r19, ADDR_CHAR
	movui r17, 0x4d			#ascii for 'M'
	stbio r17, 3874(r19)

	movui r17, 0x6f			#ascii for 'o'
	stbio r17, 3875(r19)

	movui r17, 0x64			#ascii for 'd'
	stbio r17, 3876(r19)

	movui r17, 0x65			#ascii for 'e'
	stbio r17, 3877(r19)

	movui r17, 0x3a			#ascii for ':'
	stbio r17, 3878(r19)


	movui r17, 0x53			#ascii for 'S'
	stbio r17, 3881(r19)

	movui r17, 0x74			#ascii for 't'
	stbio r17, 3882(r19)

	movui r17, 0x6f			#ascii for 'o'
	stbio r17, 3883(r19)

	movui r17, 0x70			#ascii for 'p'
	stbio r17, 3884(r19)

	movui r17, 0x70			#ascii for 'p'
	stbio r17, 3885(r19)

	movui r17, 0x65			#ascii for 'e'
	stbio r17, 3886(r19)

	movui r17, 0x64			#ascii for 'd'
	stbio r17, 3887(r19)

LOOP:
    br LOOP
	
	
.section .exceptions, "ax"
IHandler:
	subi sp, sp, 16
    stw r17, 0(sp)
    stw r18, 4(sp)
    stw r19, 8(sp)
    stw r20, 12(sp)
    
    movia r16, KEYBOARD
CHECK_VALIDITY:   
	ldwio et, 0(r16)
	srli r19, et, 15
	andi r19, r19, 0x0001
	movui r18, 0x01
	bne r19, r18, CHECK_VALIDITY
	
	andi et, et, 0x00ff
	movui r18, 0x29
	bne et, r18, EXIT
	movia r17, Mode
    ldw r20, 4(r17)
	addi r20, r20, 0x01
	movui r18, 0x02
	beq r20, r18, SECOND_INTERRUPT
	stw r20, 4(r17)
	ldw r19, 0(r17)
	movia et, RED_LEDS
	movia r20, ADDR_CHAR
	bne r0, r19, OFF
	br ON
	
ON:							#mode: patrolling
	movui r18, 0x01
	stwio r18, 0(et)
	stw r18, (r17)
	#override "Stopped" with "Patrolling" (no need to clear anything)

	movui r18, 0x50			#ascii for 'P'
	stbio r18, 3881(r20)

	movui r18, 0x61			#ascii for 'a'
	stbio r18, 3882(r20)

	movui r18, 0x74			#ascii for 't'
	stbio r18, 3883(r20)

	movui r18, 0x72			#ascii for 'r'
	stbio r18, 3884(r20)

	movui r18, 0x6f			#ascii for 'o'
	stbio r18, 3885(r20)

	movui r18, 0x6c			#ascii for 'l'
	stbio r18, 3886(r20)

	movui r18, 0x6c			#ascii for 'l'
	stbio r18, 3887(r20)

	movui r18, 0x69			#ascii for 'i'
	stbio r18, 3888(r20)

	movui r18, 0x6e			#ascii for 'n'
	stbio r18, 3889(r20)

	movui r18, 0x67			#ascii for 'g'
	stbio r18, 3890(r20)

	br EXIT
OFF:						#mode: stopped
	movui r18, 0x00
	stwio r18, 0(et)
	stw r18, 0(r17)
	#override "Patrolling" with "Stopped" (need to clear the next 3 characters)

	movui r18, 0x53			#ascii for 'S'
	stbio r18, 3881(r20)

	movui r18, 0x74			#ascii for 't'
	stbio r18, 3882(r20)

	movui r18, 0x6f			#ascii for 'o'
	stbio r18, 3883(r20)

	movui r18, 0x70			#ascii for 'p'
	stbio r18, 3884(r20)

	movui r18, 0x70			#ascii for 'p'
	stbio r18, 3885(r20)

	movui r18, 0x65			#ascii for 'e'
	stbio r18, 3886(r20)

	movui r18, 0x64			#ascii for 'd'
	stbio r18, 3887(r20)

	stbio r0, 3888(r20)
	stbio r0, 3889(r20)
	stbio r0, 3890(r20)

	br EXIT

SECOND_INTERRUPT:
	movui r18, 0x00
	movia et, Mode
	stw r18, 4(et)
	br EXIT

EXIT:
	stw r17, 0(sp)
    stw r18, 4(sp)
    stw r19, 8(sp)
    stw r20, 12(sp)
	addi sp, sp, 16
    
	subi ea, ea, 4
    eret
