.equ ADDR_JP2, 0xFF200070     # address GPIO JP2
.equ ADDR_JP2_IRQ, 0x00001000      # IRQ line for GPIO JP2 (IRQ12) 
.equ ADDR_JP2_Edge, 0xFF20007C      # address Edge Capture register GPIO JP2 


.text

.global _start
_start:
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
   
 LOOP:
	movi r5, 1
	wrctl ctl0, r5
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
    stw r23, 44(sp)
#	stw r5,  48(sp)

    #movia r2,  ADDR_JP2 			#disable sensor interrupts
    #movia r21, 0xfd5effff
    #movia r12, 0x00000000       
    #stwio r12, 8(r2)

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
