#The timerDelay subroutine will take one argument (the number of cycles to delay)
#and will delay that amount of time before returning

.global	timerDelay
timerDelay:
	wrctl  ctl0, r0
    #Prologue
    subi sp, sp, 40
    stw ra, 0(sp)     # save return address
    stw r16, 4(sp)    # save all the callee save registers
    stw r17, 8(sp)
    stw r18, 12(sp)
    stw r19, 16(sp)
    stw r20, 20(sp)
    stw r21, 24(sp)
    stw r22, 28(sp)
    stw r23, 32(sp)
	stw ea, 36(sp)
	
    #Body
    movia r16, 0xFF202000         # r16 contains the base address for the timer
    mov r17, r4
    srli r17, r17, 16             # gets the 16 most significant bits of the argument
	andi r4, r4, 0xFFFF
    stwio r4, 8(r16)              # transfer the 16 least significant bits to the lower period register
    stwio r17, 12(r16)            # transfer the 16 most significant bits to the higher period register
    movui r18, 4
    stwio r18, 4(r16)             # Start the timer without continuing or interrupts

CHECK:    
	ldwio r19, 0(r16)
    andi r19, r19, 0x01           # Check timeout bit
    beq r19, r0, checkIfDone      # Delay if not done
    stwio r0, 0(r16)              # Reset timer flag
    br END

checkIfDone:
    br CHECK

END:
    #Epilogue
    ldw ra, 0(sp)     # restore ra
    ldw r16, 4(sp)    # restore all the callee save registers
    ldw r17, 8(sp)
    ldw r18, 12(sp)
    ldw r19, 16(sp)
    ldw r20, 20(sp)
    ldw r21, 24(sp)
    ldw r22, 28(sp)
    ldw r23, 32(sp)
	ldw ea, 36(sp)
    addi sp, sp, 40   # flush stack
	movi r24, 1
    wrctl  ctl0, r24
    ret
