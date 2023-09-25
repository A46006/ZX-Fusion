#target rom


#code EPROM, 0x1295, 0xD

	LD	HL, $FFFF ; 
	BIT	0, (HL)   ; getting bit 0 of byte at FFFF (menu flag)
	JR Z, MENU    ; if at 0, go to my menu code (0 is the initial value of RAM)
	JP $3878 ; NORMAL_BASIC_MISSING_CODE label in my code, to later continue booting normally
MENU:
	JP $386e ; beginning of my code (MAIN label in the menu code)
