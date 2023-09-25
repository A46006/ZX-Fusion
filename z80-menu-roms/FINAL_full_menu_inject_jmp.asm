#target rom


#code EPROM, 0x386E, 0x492


	LD	HL, $FFFF ; 
	BIT	0, (HL)   ; getting bit 0 of byte at FFFF (menu flag)
	JR Z, MENU    ; if at 0, go to my menu code (0 is the initial value of RAM)
	
	XOR A
	LD DE,$1538
	CALL $0C0A
	SET 5,(IY+$02)
	
	JP $12A9 ; MAIN_1
	;JP $B00E ; NORMAL_BASIC_MISSING_CODE label in my code, to later continue booting normally
MENU:
	DI
	IN A, ($17)			; INIT command for NIOS to inject menu code to RAM
	HALT				; 
	JP $B000 ; beginning of my code (MAIN label in the menu code)
