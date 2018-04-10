.equ ADDR_VGA, 0x08000000

IMAGE:
	.incbin "intruder.bmp"

.text

.global _start
_start:
    movia r16, ADDR_VGA
	movia r23, IMAGE
	addi r23, r23, 66
	
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
	ldh r21, 0(r23)
	sthio r21, 0(r22)		#image colour
	addi r23, r23, 0x02 	#each pixel is a half word therefore the address is incremented by 2
	addi r17, r17, 0x01
	bne r17, r19, X_LOOP_PIXEL
	movui r17, 0x0000
    addi r18, r18, 0x01
	bne r18, r20, Y_LOOP_PIXEL
	
Loop:
	br Loop