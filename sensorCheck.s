.equ ADDR_JP2, 0xFF200070     # address GPIO JP2
.equ ADDR_JP2_IRQ, 0x00001000      # IRQ line for GPIO JP2 (IRQ12) 
.equ ADDR_JP2_Edge, 0xFF20007C      # address Edge Capture register GPIO JP2 


.text

.global _start
_start:
   movia  r8, ADDR_JP2         # load address GPIO JP2 into r8
   movia  r9, 0x07f557ff       # set motor,threshold and sensors bits to output, set state and sensor valid bits to inputs 
   stwio  r9, 4(r8)

# load sensor3 threshold value 5 and enable sensor3
 
   movia  r9,  0xfd3effcf		#f9beffff #f9beffff       # set motors off enable threshold load sensor 3
   stwio  r9,  0(r8)            # store value into threshold register

# disable threshold register and enable state mode
  
   movia  r9,  0xfd5fffff       #fadfffff	#fadfffff #fadfffff #f9dfffff      # keep threshold value same in case update occurs before state mode is enabled
   stwio  r9,  0(r8)
 
# enable interrupts

    movia  r12, 0x40000000       # enable interrupts on sensor 3
    stwio  r12, 8(r8)

    movia  r8, ADDR_JP2_IRQ    # enable interrupt for GPIO JP2 (IRQ12) 
    wrctl  ctl3, r8

    movia  r8, 1
    wrctl  ctl0, r8            # enable global interrupts 
 
    LOOP:
    movia  r9,  0xfd5fffef       #fadfffff	#fadfffff #fadfffff #f9dfffff      # keep threshold value same in case update occurs before state mode is enabled
    stwio  r9,  0(r8)
	movia r4, 0x00989680				# put period in r4, 100 000 000
    call timerDelay	
    movia  r9,  0xfd5fffcf      # FD5FFFEF#fadfffff	#fadfffff #fadfffff #f9dfffff      # keep threshold value same in case update occurs before state mode is enabled
    stwio  r9,  0(r8)
	#movia r4, 0x000f4240	
   # call timerDelay	
    br LOOP
	
	
	
.section .exceptions, "ax"
IHANDLER:

  subi	sp, sp, 4					# save registers
  stw	r2, 0(sp)

  rdctl et, ctl4                    # check the interrupt pending register (ctl4) 
  beq   et, r0, exit_handler
  movia r2, ADDR_JP2_IRQ    
  and	r2, r2, et                  # check if the pending interrupt is from GPIO JP2 
  beq   r2, r0, exit_handler    

  movia r2, ADDR_JP2_Edge           # check edge capture register from GPIO JP2 
  ldwio et, 0(r2)
  andhi r2, et, 0x4000              # mask bit 30 (sensor 3)  
  beq   r2, r0, exit_handler        # exit if sensor 3 did not interrupt 
  
  movia	r2,ADDR_JP2_Edge	        /* clear all interrupts on GPIO-JP2. Must write to all ports */
  movia	r5,0xffffffff
  stwio	r5,0(r2)
  
 TURN:
   movia r2, ADDR_JP2
   movia  r21,  0xfd5fffef #FADFFFE2 FD5FFFEF #fadfffc8      # set motors off enable threshold load sensor 3
   stwio  r21,  0(r2)            # store value into threshold register
   movia r4, 0x00895440				# put period in r4, 100 000 000
   call timerDelay
   movia r21,	0xfd5fffff
   stwio  r21,  0(r2)            # store value into threshold register
   call timerDelay						#FD5FFFE2
   movia r21,	0xfd5fffe8
   stwio  r21,  0(r2)            # store value into threshold register
   movia r4, 0x00989680    #2faf080				# put period in r4, 100 000 000
   call timerDelay	
   movia r21,	0xfd5fffc2  #FD5FFFC2
   stwio  r21,  0(r2)            # store value into threshold register
   call timerDelay	
   movia r21,	0xfd5fffcf
   stwio  r21,  0(r2)            # store value into threshold register

   

exit_handler:

  ldw	r2,0(sp)	       	     /* reload value from regular routine*/
  addi  sp, sp, 4
 
  subi	ea,ea,4
  eret			            /* return from interrupt routine */
