#target rom


#code EPROM, 0x0000, 0x10000

	IM 1
	EI
	
	LD SP, $C0A0
	LD HL, $AA55
	LD ($FFFE), HL
	;LD ($FFF0), HL
START:
	LD HL, ($FFFE)
	HALT
	JP START
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

;; Interrupt and keyboard routines follow
MASK_INT:
	push AF
	push HL
	LD	HL, ($5C78)
	INC HL
	LD	($5C78), HL
	LD A,H
	OR L
	JR NZ,KEY_INT
	INC (IY+$40)
KEY_INT
	push BC
	push DE
	call KEYBOARD
	pop de
	pop bc
	pop hl
	pop af
	EI
	RET
	
KEYBOARD:
	CALL KEY_SCAN
	RET NZ
	; TODO rest of the code here, as well as initializing KSTATE variables
	RET
	
; Keyobard scanning subroutine
KEY_SCAN: 
	LD L,$2F
	LD DE,$FFFF
	LD BC,$FEFE
KEY_LINE:
	IN A,(C)
	CPL
	AND $1F
	JR Z,KEY_DONE
	LD H,A
	LD A,L
KEY_3KEYS:
	INC D
	RET NZ
KEY_BITS:
	SUB $08
	SRL H
	JR NC, KEY_BITS
	LD D,E
	LD E,A
	JR NZ,KEY_3KEYS	
KEY_DONE:
	DEC L
	RLC B
	JR C,KEY_LINE
	
	LD A,D	; Accept any key value which still has the D register holding +FF,
	INC A	;  i.e. a single key pressed or 'no-key'.
	RET Z	;
	CP $28 	; Accept the key value for a pair of keys if the D key is CAPS SHIFT.
	RET Z	;
	CP $19 	; Accept the key value for a pair of keys if the D key is SYMBOL SHIFT.
	RET Z	;
	LD A,E	; It is however possible for the E key of a pair to be
	LD E,D	;  SYMBOL SHIFT - so this has to be considered.
	LD D,A	;
	CP $18	;
	RET		; Return with the zero flag set if it was SYMBOL SHIFT and 'another key'; 
			; otherwise reset.