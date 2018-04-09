.equ ADDR_JP2, 0xFF200070     # address GPIO JP2
.equ ADDR_JP2_IRQ, 0x00001000      # IRQ line for GPIO JP2 (IRQ12) 
.equ ADDR_JP2_Edge, 0xFF20007C      # address Edge Capture register GPIO JP2 
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
   
   movia r8, ADDR_JP2         		# load address GPIO JP2 into r8
   movia r9, 0x07f557ff       		# set motor,threshold and sensors bits to output, set state and sensor valid bits to inputs 
   stwio r9, 4(r8)

# load sensor3 threshold value A and enable sensor3
   movia r9, 0xfd3effff				#set motors FORWARD & enable threshold load sensor 3 with value 10
   stwio r9, 0(r8)            		#store value into threshold register

# disable threshold register and enable state mode
   movia  r9,  0xffdfffff #fd5fffcf       	#keep threshold value same in case update occurs before state mode is enabled
   stwio  r9,  0(r8)
 
# enable interrupts

    movia  r12, 0x40000000#f8000000 #40000000       	#enable interrupts on sensor 3
    stwio  r12, 8(r8)
	
    movia  r8, ADDR_JP2_IRQ    		#enable interrupt for GPIO JP2 (IRQ12) 
    wrctl  ctl3, r8

    movia  r8, 1
    wrctl  ctl0, r8            		#enable global interrupts 
 	movia r8, ADDR_JP2
   
STOPLOOPD:
   movia r16, Mode
   ldw r5, 0(r16)
   bne r5, r0, LOOP
   movia  r9,  0xffffffff #fd5fffcf       	#keep threshold value same in case update occurs before state mode is enabled
   stwio  r9,  0(r8)
   br STOPLOOPD
   
   
 LOOP:
	movi r5, 1								#Moved to before the mode stuff as i need interrupts enabled - Devesh
	wrctl ctl0, r5
	movia r16, Mode
    ldw r5, 0(r16)
	beq r5, r0, STOPLOOPD
	#movi r5, 1
	#wrctl ctl0, r5
#	movia  r9,  0xfd5fffff        	#turn motors off
#    stwio  r9,  0(r8)
#	movia r4, 0x00af0800			#put period in r4
#    call timerDelay	
#	br TOUCH
    movia  r9,  0xfd5fffcf      	#turn motors forward
    stwio  r9,  0(r8)
	movia r4, 0x000ff000	
    call timerDelay	
	br TOUCH

	                               #ENABLE SENSOR INTERRUPRS HERE (DEBOUNCING} <- TA COMMENT
	
	
TOUCH:
	wrctl ctl0, r0
	movia r4, 0x00af0800			#ADDED BEFORE
	movia  r9,  0xffffffff #fd5fffcf       	#keep threshold value same in case update occurs before state mode is enabled
	stwio  r9,  0(r8)
	call timerDelay
	
#CHECK:
   movia  r9, 0xfffbffff     # enable sensor 4, disable all motors
   stwio  r9, 0(r8)
   ldwio  r5,  0(r8)          # checking for valid data sensor 4
#   srli   r6,  r5,19          # bit 17 is valid bit for sensor 4           
#   andi   r6,  r6,0x1
#   bne    r0,  r6,LOOP        # wait for valid bit to be low: sensor 3 needs to be valid
VALID:
   srli   r5, r5, 27          # shift to the right by 27 bits so that 4-bit sensor value is in lower 4 bits 
   andi   r5, r5, 0x0f
   movi   r2, 15
   beq    r2, r5, LOOP
   movia r4, 0x0fff0800			#put period in r4
   movia  r9,  0xffffffef #fd5fffcf       	#keep threshold value same in case update occurs before state mode is enabled
   stwio  r9,  0(r8)
   call timerDelay
   br LOOP


	
.section .exceptions, "ax"
IHANDLER:
	ldwio  r5,  0(r8)          # checking for valid data sensor 4
    srli   r5, r5, 27          # shift to the right by 27 bits so that 4-bit sensor value is in lower 4 bits 
    andi   r5, r5, 0x0f
	wrctl ctl0, r0					#disable global interrupts
	subi sp, sp, 48					#save registers
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
    stw r23, 44(sp)																									#NEED TO SAVE R8 ALSOOOOOOOOOOO!!!!!!!!!!!!!!! - Devesh
#	stw r5,  48(sp)

    #movia r2,  ADDR_JP2 			#disable sensor interrupts
    #movia r21, 0xfd5effff
    #movia r12, 0x00000000       
    #stwio r12, 8(r2)
	
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
	beq   r2, r0, exit_handler #PLOW 	#exit if sensor 3 did not interrupt 
  
    
  
	movia	r2,ADDR_JP2_Edge	    #clear all interrupts on GPIO-JP2. Must write to all ports 
	movia	r4,0xffffffff
	stwio	r4,0(r2)
  

	movi   r2, 7
	beq    r2, r5, TURN
	movi   r2, 15
	beq    r2, r5, TURN
	br TOUCHED
#	movia r4, 0x0fff0800			#put period in r4
#	movia  r9,  0xffffffef #fd5fffcf       	#keep threshold value same in case update occurs before state mode is enabled
#	stwio  r9,  0(r8)
#	call timerDelay
#	br exit_handler
#if light sensor interrupted 
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
	movia r4, 0x00bfb080	#d		#change timer value
	movia r21,	0xfd5fffc8  		#set motors to go forward and turn
	stwio  r21,  0(r2)           	 
	call timerDelay					
	movia r21,	0xfd5fffff  		#turn motors off,     previous values: #fd5effcf #fd5fffcf 
	stwio  r21,  0(r2)         
	br exit_handler

TOUCHED:
	movia r4, 0x00ff0800			#put period in r4
	movia  r9,  0xffffffef #fd5fffcf       	#keep threshold value same in case update occurs before state mode is enabled
	stwio  r9,  0(r8)
	call timerDelay
	br exit_handler	
#if touch sensor interrupted
#PLOW:
#	movia r2, ADDR_JP2
#	movia r4, 0x0fffb080			#set timer value         
#	movia r21,	0xfd5fffcf 			#set motors to go back, to turn use 8
#	stwio  r21,  0(r2)    
   
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

	br exit_handler
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
#	ldw r5,  48(sp)
	addi sp, sp, 48
	subi ea, ea, 4
	movi r24, 1						#enable global interrups
	wrctl ctl0, r24
	eret			        		#return from interrupt routine 
