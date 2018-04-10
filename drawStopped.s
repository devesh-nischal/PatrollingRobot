.equ ADDR_CHAR, 0x09000000

.global drawStopped

drawStopped:
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
	
	ret