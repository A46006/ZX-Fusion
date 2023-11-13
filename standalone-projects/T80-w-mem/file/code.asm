#target rom


#code EPROM, 0x0000, 0x10000

	LD SP, $C0A0
	LD HL, $AA55
	LD ($FFFE), HL
	;LD ($FFF0), HL
START:
	LD HL, ($FFFE)
	;LD HL, ($FFF0)
	LD ($FFFE), HL
	;LD ($FFF0), HL
	HALT
	JP START
	nop
	nop
	nop
;	nop
;	nop
;	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	RETN
	