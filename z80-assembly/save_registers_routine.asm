#target ram


#code EPROM, 0x4000, 0x200

	LD    ($4100), SP		; load stack pointer to 0x4100
	PUSH  AF				; push AF data to stack
	EX    AF, AF'			; exchange AF with AF'
	PUSH  AF				; push AF' data to stack
	
	LD    ($4000), HL		; load HL contents into 0x4000
	LD    ($4002), BC		; load BC contents into 0x4002
	LD    ($4004), DE		; load DE contents into 0x4004
	
	EXX
	
	LD    ($4006), HL		; load HL' contents into 0x4006
	LD    ($4008), BC		; load BC' contents into 0x4008
	LD    ($400A), DE		; load DE' contents into 0x400A
	
	LD    ($400C), IX		; load IX contents into 0x400C
	LD    ($400E), IY		; load IY contents into 0x400E
	
	LD    A, I				; load I contents to 0x4010
	LD    ($4010), A		; 
	
	LD    A, R				; load R contents to 0x4011
	LD    ($4011), A		; 

	HALT