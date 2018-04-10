.equ ADDR_JP2, 0xFF200070     		# address GPIO JP2
.equ ADDR_JP2_IRQ, 0x00001000     	# IRQ line for GPIO JP2 (IRQ12) 
.equ ADDR_JP2_Edge, 0xFF20007C      # address Edge Capture register GPIO JP2 
.equ KEYBOARD, 0xff200100
.equ RED_LEDS, 0xff200000
.equ ADDR_VGA, 0x08000000
.equ ADDR_CHAR, 0x09000000
.equ AUDIO_CORE, 0xff203040

IMAGE:
	.incbin "intruder.bmp"			#image

.align 2
ALARM:
	.incbin "BigAlarm.wav"			#sound file

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
	movui r17, 0x01			#enable keyboard read interrupt
	stwio r17, 4(r16)
	movia r17, RED_LEDS
	stwio r0, 0(r17)
	
	call drawTable
	
	call drawStopped
   
   movia r8, ADDR_JP2         		# load address GPIO JP2 into r8
   movia r9, 0x07f557ff       		# set motor,threshold and sensors bits to output, set state and sensor valid bits to inputs 
   stwio r9, 4(r8)

# load sensor3 threshold value A and enable sensor3
   movia r9, 0xfd3effff				#set motors FORWARD & enable threshold load sensor 3 with value 10
   stwio r9, 0(r8)            		#store value into threshold register

# disable threshold register and enable state mode
   movia  r9,  0xffdfffff        	#keep threshold value same in case update occurs before state mode is enabled
   stwio  r9,  0(r8)
 
# enable interrupts

    movia  r12, 0x40000000       	#enable interrupts on sensor 3
    stwio  r12, 8(r8)
	
    movui r17, 0x0080
    movia  r8, ADDR_JP2_IRQ    		#enable interrupt for GPIO JP2 (IRQ12) 
	add r8, r8, r17
    wrctl  ctl3, r8

    movi  r8, 1
    wrctl  ctl0, r8            		#enable global interrupts 
 	movia r8, ADDR_JP2
   
STOPLOOPD:
   movi r5, 1								#added - Devesh
   wrctl ctl0, r5
   movia r16, Mode
   ldw r5, 0(r16)
   bne r5, r0, LOOP
   movia  r9,  0xffffffff       	#keep threshold value same in case update occurs before state mode is enabled
   stwio  r9,  0(r8)
   br STOPLOOPD
   
   
LOOP:
	movi r5, 1								#Moved to before the mode stuff as i need interrupts enabled - Devesh
	wrctl ctl0, r5
	movia r16, Mode
    ldw r5, 0(r16)
	beq r5, r0, STOPLOOPD
    movia  r9,  0xfd5fffcf      	#turn motors forward
    stwio  r9,  0(r8)
	movia r4, 0x000ff000	
    call timerDelay	
	br TOUCH

TOUCH:
	wrctl ctl0, r0
	movia r4, 0x00af0800
	movia  r9,  0xffffffff        	#keep threshold value same in case update occurs before state mode is enabled
	stwio  r9,  0(r8)
	call timerDelay
	
   movia  r9, 0xfffbffff     # enable sensor 4, disable all motors
   stwio  r9, 0(r8)
   ldwio  r5,  0(r8)          # checking for valid data sensor 4

VALID:
   srli   r5, r5, 27          # shift to the right by 27 bits so that 4-bit sensor value is in lower 4 bits 
   andi   r5, r5, 0x0f
   movi   r2, 15
   beq    r2, r5, LOOP
   movia r4, 0x0fff0800			#put period in r4
   movia  r9,  0xffffffef      	#keep threshold value same in case update occurs before state mode is enabled
   stwio  r9,  0(r8)
   call timerDelay
   br LOOP
	
.section .exceptions, "ax"
IHANDLER:
	ldwio  r5,  0(r8)          # checking for valid data sensor 4
    srli   r5, r5, 27          # shift to the right by 27 bits so that 4-bit sensor value is in lower 4 bits 
    andi   r5, r5, 0x0f
	wrctl ctl0, r0					#disable global interrupts
	subi sp, sp, 52					#save registers
	stw	r2,	 0(sp)					#save return value
	stw	ra,  4(sp)					#save return adress
	stw ea,  8(sp)
	stw r4,  12(sp)					#save timer value
	stw r16, 16(sp)   				#save timer registers
    stw r17, 20(sp)
    stw r18, 24(sp)
    stw r19, 28(sp)
    stw r20, 32(sp)
    stw r21, 36(sp)
    stw r22, 40(sp)
    stw r23, 44(sp)
	stw r8,	 48(sp)

	#check if keyboard or sensors (branch if it is keyboard)
	rdctl et, ctl4
	movui r2, 0x0080
	and et, r2, et
	beq et, r2, KEYBOARD_INTERRUPT
	
	
	rdctl et, ctl4					#check the interrupt pending register (ctl4) 
	beq	et,	r0,	exit_handler
	movia r2, ADDR_JP2_IRQ    
	and	r2, r2, et                  #check if the pending interrupt is from GPIO JP2 
	beq r2, r0, exit_handler    

	movia r2, ADDR_JP2_Edge  		#check edge capture register from GPIO JP2 
	ldwio et, 0(r2)
	andhi r2, et, 0x4000         	#mask bit 30 (sensor 3)  
	beq   r2, r0, exit_handler  	#exit if sensor 3 did not interrupt 
  
    
  
	movia	r2,ADDR_JP2_Edge	    #clear all interrupts on GPIO-JP2. Must write to all ports 
	movia	r4,0xffffffff
	stwio	r4,0(r2)
  

	movi   r2, 7
	beq    r2, r5, TURN
	movi   r2, 15
	beq    r2, r5, TURN
	br TOUCHED

TURN:
	movia r2, ADDR_JP2
	movia r4, 0x00dfb080			#set timer value         
	movia r21,	0xfd5fffef 			#set motors to go back, to turn use 8
	stwio  r21,  0(r2)            	
	call timerDelay	         
	movia r4, 0x00afb080			#set timer value         
	movia r21,	0xfd5fffe8 			#set motors to go back, to turn use 8
	stwio  r21,  0(r2)            	
	call timerDelay	                
	movia r4, 0x00bfb080			#change timer value
	movia r21,	0xfd5fffc8  		#set motors to go forward and turn
	stwio  r21,  0(r2)           	 
	call timerDelay					
	movia r21,	0xfd5fffff  		#turn motors off,     previous values: #fd5effcf #fd5fffcf 
	stwio  r21,  0(r2)         
	br exit_handler

TOUCHED:
	
	call clearScreen
	
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
	
	movia r4, 0x00ff0800			#put period in r4
	movia  r9,  0xffffffef #fd5fffcf       	#keep threshold value same in case update occurs before state mode is enabled
	stwio  r9,  0(r8)
	call timerDelay
	
	movia  r9,  0xffffffff
	stwio  r9,  0(r8)
	
	movia r16, AUDIO_CORE
    movia r17, ALARM
    movia r18, 0x000f4240
    addi r17, r17, 0x7fff
   
WRITE_SPACE_WAIT:
	ldwio r20, 4(r16)
	andhi r21, r20, 0xff00
	beq r21, r0, WRITE_SPACE_WAIT
	andhi r21, r20, 0xff
	beq r21, r0, WRITE_SPACE_WAIT
    
AUDIO_WRITE:
	ldh r19, 0(r17)
	sthio r19, 8(r16)
	sthio r19, 12(r16)
	addi r17, r17, 2
	subi r18, r18, 2
	bne r0, r18, WRITE_SPACE_WAIT
	
	#reset the screen to original state
	call clearScreen
	call drawTable
	call drawPatrolling
	
	br exit_handler	 
   
KEYBOARD_INTERRUPT:
	movia r16, KEYBOARD
CHECK_VALIDITY:   
	ldwio et, 0(r16)
	srli r19, et, 15
	andi r19, r19, 0x0001
	movui r18, 0x01
	bne r19, r18, CHECK_VALIDITY
	
	andi et, et, 0x00ff
	movui r18, 0x29
	bne et, r18, exit_handler
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
    movia r17, Mode	
    stw r18, 0(r17)
	#override "Stopped" with "Patrolling" (no need to clear anything)

	call drawPatrolling

	br exit_handler
OFF:						#mode: stopped
	movui r18, 0x00
	stwio r18, 0(et)
    movia r17, Mode	
    stw r18, 0(r17)
	#override "Patrolling" with "Stopped" (need to clear the next 3 characters)

	call drawStopped

	stbio r0, 3888(r20)
	stbio r0, 3889(r20)
	stbio r0, 3890(r20)

	br exit_handler

SECOND_INTERRUPT:
	movui r18, 0x00
	movia et, Mode
	stw r18, 4(et)
	br exit_handler
   
exit_handler:
	ldw r2,  0(sp)	      			#reload value from regular routine
	ldw ra,  4(sp)         			#reload return address
	ldw ea,  8(sp)					#reload exception address
	ldw r4,  12(sp)					#reload timer value
	ldw r16, 16(sp)					#load all the timer registers
	ldw r17, 20(sp)
	ldw r18, 24(sp)
	ldw r19, 28(sp)
	ldw r20, 32(sp)
	ldw r21, 36(sp)
	ldw r22, 40(sp)
	ldw r23, 44(sp)
	ldw r8, 48(sp)
	addi sp, sp, 52
	subi ea, ea, 4
	eret			        		#return from interrupt routine 
