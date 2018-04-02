.equ KEYBOARD, 0xff200100
.equ RED_LEDS, 0xff200000
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