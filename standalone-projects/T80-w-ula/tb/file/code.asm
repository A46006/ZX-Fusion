#target rom


#code EPROM, 0x0000, 0x38

	IM 1
	EI
	
	; initializing system variables
	
	CALL INIT
	
	LD SP, $C0A0	; Setting SP so it isn't in FFFF
	LD HL, $AA55	; Writting values to FFFE
	LD ($FFFE), HL	;
	;LD ($FFF0), HL
START:
	LD HL, ($FFFE)
	HALT
	JR START



;; Interrupt and keyboard routines follow (code taken from Richard Dymond's ZX Specturm 48k ROM disassembly https://skoolkid.github.io/rom/index.html)
#code interrupt, 0x38, 0x2E
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

#code nmi, 0x66, 0x1cd
	RETN

KEYBOARD:
	CALL KEY_SCAN
	RET NZ

	LD HL,$5C00		; Start with KSTATE0.
K_ST_LOOP:
	BIT 7,(HL)		; Jump forward if a 'set is free', i.e. KSTATE0/4 holds +FF.
	JR NZ,K_CH_SET	;
	INC HL 			; However if the set is not free decrease its '5 call counter' and 
	DEC (HL)		; 	when it reaches zero signal the set as free.
	DEC HL			;
	JR NZ,K_CH_SET	;
	LD (HL),$FF		;
K_CH_SET:
	LD A,L			; Fetch the low byte of the address and 
	LD HL,$5C04		; jump back if the second set (KSTATE4) has still to be considered.
	CP L			;
	JR NZ,K_ST_LOOP	;
	
	CALL K_TEST		; Make the necessary tests and return if needed. 
	RET NC			; Also change the key value to a 'main code'.
	
	LD HL,$5C00		; Look first at KSTATE0.
	CP (HL) 		; Jump forward if the codes match - indicating a repeat.
	JR Z,K_REPEAT	;
	EX DE,HL		; Save the address of KSTATE0.
	LD HL,$5C04 	; Now look at KSTATE4.
	CP (HL)			; Jump forward if the codes match - indicating a repeat.
	JR Z,K_REPEAT	; 
	
	BIT 7,(HL)		; Consider the second set.
	JR NZ,K_NEW		; Jump forward if 'free'.
	EX DE,HL		; Now consider the first set.
	BIT 7,(HL)		; Continue if the set is 'free' but exit if not.
	RET Z			;
	
K_NEW:
 	LD E,A			; The code is passed to the E register and to KSTATE0/4.
	LD (HL),A		;
	INC HL			; The '5 call counter' for this set is reset to '5'.
	LD (HL),$05		; 
	INC HL			; The third system variable of the set holds 
	LD A,($5C09)	; the REPDEL value (normally 0.7 secs.).
	LD (HL),A		;
	INC HL			; Point to KSTATE3/7.
	LD C,(IY+$07) 	; Fetch MODE.
	LD D,(IY+$01) 	; Fetch FLAGS.
	PUSH HL 		; Save the pointer whilst the 'main code' is decoded.
	CALL K_DECODE	;
	POP HL			;
	LD (HL),A		; The final code value is saved in KSTATE3/7, 
					; from where it is collected in case of a repeat.
K_END:
	LD ($5C08),A 	; Enter the final code value into LAST-K and signal 'a new key' 
	SET 5,(IY+$01)	; by setting bit 5 of FLAGS.
	RET 			; Finally return.
K_REPEAT:
	INC HL 			; Point to the '5 call counter' of the set being used and reset it to 5.
	LD (HL),$05		;
	INC HL 			; Point to the third system variable - the REPDEL/REPPER value 
	DEC (HL)		; 	- and decrement it.
	RET NZ			; Exit from the KEYBOARD subroutine if the delay period has not passed.
	LD A,($5C0A)	; However once it has passed the delay period for the 
	LD (HL),A		;	next repeat is to be REPPER.
	INC HL			; The repeat has been accepted so the final code value 
	LD A,(HL)		; 	is fetched from KSTATE3/7 and passed to K_END.
	JR K_END		;
	
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
			
			
; Used by KEYBOARD and S_INKEY.	
K_TEST:
	LD B,D			; Copy the shift byte.
	LD D,$00		; Clear the D register for later.
	LD A,E			; Move the key number.
	CP $27			; Return now if the key was 'CAPS SHIFT' only or 'no-key'.
	RET NC			;
	CP $18			; Jump forward unless the E key was SYMBOL SHIFT.
	JR NZ,K_MAIN	;
	BIT 7,B			; However accept SYMBOL SHIFT and another key; 
	RET NZ			; return with SYMBOL SHIFT only.
K_MAIN:
	LD HL,KEYTABLE_A ; The base address of the main key table. 
	ADD HL,DE		; Index into the table and fetch the 'main code'.
	LD A,(HL)		;
	SCF				; Signal 'valid keystroke' before returning.
	RET				;
	

#code main_key_table, 0x205, 0x3DCD;0xFDFB;0x28E
KEYTABLE_A:
	DEFB $42 	; B
	DEFB $48 	; H
	DEFB $59 	; Y
	DEFB $36 	; 6
	DEFB $35 	; 5
	DEFB $54 	; T
	DEFB $47 	; G
	DEFB $56 	; V
	DEFB $4E 	; N
	DEFB $4A 	; J
	DEFB $55 	; U
	DEFB $37 	; 7
	DEFB $34 	; 4
	DEFB $52 	; R
	DEFB $46 	; F
	DEFB $43 	; C
	DEFB $4D 	; M
	DEFB $4B 	; K
	DEFB $49 	; I
	DEFB $38 	; 8
	DEFB $33 	; 3
	DEFB $45 	; E
	DEFB $44 	; D
	DEFB $58 	; X
	DEFB $0E 	; SYMBOL SHIFT
	DEFB $4C 	; L
	DEFB $4F 	; O
	DEFB $39 	; 9
	DEFB $32 	; 2
	DEFB $57 	; W
	DEFB $53 	; S
	DEFB $5A 	; Z
	DEFB $20 	; SPACE
	DEFB $0D 	; ENTER
	DEFB $50 	; P
	DEFB $30 	; 0
	DEFB $31 	; 1
	DEFB $51 	; Q
	DEFB $41 	; A
	
KEYTABLE_B:
	DEFB $E3 	; READ
	DEFB $C4 	; BIN
	DEFB $E0 	; LPRINT
	DEFB $E4 	; DATA
	DEFB $B4 	; TAN
	DEFB $BC 	; SGN
	DEFB $BD 	; ABS
	DEFB $BB 	; SQR
	DEFB $AF 	; CODE
	DEFB $B0 	; VAL
	DEFB $B1 	; LEN
	DEFB $C0 	; USR
	DEFB $A7 	; PI
	DEFB $A6 	; INKEY$
	DEFB $BE 	; PEEK
	DEFB $AD 	; TAB
	DEFB $B2 	; SIN
	DEFB $BA 	; INT
	DEFB $E5 	; RESTORE
	DEFB $A5 	; RND
	DEFB $C2 	; CHR$
	DEFB $E1 	; LLIST
	DEFB $B3 	; COS
	DEFB $B9 	; EXP
	DEFB $C1 	; STR$
	DEFB $B8 	; LN
	
KEYTABLE_C:
	DEFB $7E 	; ~
	DEFB $DC 	; BRIGHT
	DEFB $DA 	; PAPER
	DEFB $5C 	; \
	DEFB $B7 	; ATN
	DEFB $7B 	; {
	DEFB $7D 	; }
	DEFB $D8 	; CIRCLE
	DEFB $BF 	; IN
	DEFB $AE 	; VAL$
	DEFB $AA 	; SCREEN$
	DEFB $AB 	; ATTR
	DEFB $DD 	; INVERSE
	DEFB $DE 	; OVER
	DEFB $DF 	; OUT
	DEFB $7F 	; ©
	DEFB $B5 	; ASN
	DEFB $D6 	; VERIFY
	DEFB $7C 	; |
	DEFB $D5 	; MERGE
	DEFB $5D 	; ]
	DEFB $DB 	; FLASH
	DEFB $B6 	; ACS
	DEFB $D9 	; INK
	DEFB $5B 	; [
	DEFB $D7 	; BEEP
	
KEYTABLE_D:
	DEFB $0C 	; DELETE
	DEFB $07 	; EDIT
	DEFB $06 	; CAPS LOCK
	DEFB $04 	; TRUE VIDEO
	DEFB $05 	; INV. VIDEO
	DEFB $08 	; Cursor left
	DEFB $0A 	; Cursor down
	DEFB $0B 	; Cursor up
	DEFB $09 	; Cursor right
	DEFB $0F 	; GRAPHICS
	
KEYTABLE_E:
 	DEFB $E2 	; STOP
	DEFB $2A 	; *
	DEFB $3F 	; ?
	DEFB $CD 	; STEP
	DEFB $C8 	; >=
	DEFB $CC 	; TO
	DEFB $CB 	; THEN
	DEFB $5E 	; ↑
	DEFB $AC 	; AT
	DEFB $2D 	; -
	DEFB $2B 	; +
	DEFB $3D 	; =
	DEFB $2E 	; .
	DEFB $2C 	; ,
	DEFB $3B 	; ;
	DEFB $22 	; "
	DEFB $C7 	; <=
	DEFB $3C 	; <
	DEFB $C3 	; NOT
	DEFB $3E 	; >
	DEFB $C5 	; OR
	DEFB $2F 	; /
	DEFB $C9 	; <>
	DEFB $60 	; £
	DEFB $C6 	; AND
	DEFB $3A 	; :
	
KEYTABLE_F:
 	DEFB $D0 	; FORMAT
	DEFB $CE 	; DEF FN
	DEFB $A8 	; FN
	DEFB $CA 	; LINE
	DEFB $D3 	; OPEN
	DEFB $D4 	; CLOSE
	DEFB $D1 	; MOVE
	DEFB $D2 	; ERASE
	DEFB $A9 	; POINT
	DEFB $CF 	; CAT
	
	
; Code taken from Geoff Wearmouth's ZX Spectrum 128k ROM 1 disassembly
; http://www.fruitcake.plus.com/Sinclair/Spectrum128/ROMDisassembly/Spectrum128ROMDisassembly.htm
K_DECODE:
		LD      A,E             ; pick up the stored main key
        CP      $3A             ; an arbitrary point between digits and letters
        JR      C,L0367         ; forward to K-DIGIT with digits, space, enter.

        DEC     C               ; decrease MODE ( 0='KLC', 1='E', 2='G')

        JP      M,L034F         ; to K-KLC-LET if was zero

        JR      Z,L0341         ; to K-E-LET if was 1 for extended letters.

; proceed with graphic codes.
; Note. should selectively drop return address if code > 'U' ($55).
; i.e. abort the KEYBOARD call.
; e.g. cp 'V'; jr c addit; pop af; ;;addit etc. (5 bytes of instruction).
; (s-inkey$ never gets into graphics mode.)

;; addit
        ADD     A,$4F           ; add offset to augment 'A' to graphics A say.
        RET                     ; return.
                                ; Note. ( but [GRAPH] V gives RND, etc ).

; ---

; the jump was to here with extended mode with uppercase A-Z.

;; K-E-LET
L0341:  
		LD      HL,KEYTABLE_B    ; base address of E-UNSHIFT L022c
                                ; ( $01EB in standard ROM ) 
        INC     B               ; test B is it empty i.e. not a shift
        JR      Z,L034A         ; forward to K-LOOK-UP if neither shift

        LD      HL,KEYTABLE_C   ; Address: $0205 L0246-$41 EXT-SHIFT base

;; K-LOOK-UP
L034A:  
		LD      D,$00           ; prepare to index
        ADD     HL,DE           ; add the main key value
        LD      A,(HL)          ; pick up other mode value
        RET                     ; return

; ---

; the jump was here with mode = 0

;; K-KLC-LET
L034F:  
		LD      HL,KEYTABLE_E    ; prepare base of sym-codes
        BIT     0,B             ; shift=$27 sym-shift=$18
        JR      Z,L034A         ; back to K-LOOK-UP with symbol-shift

        BIT     3,D             ; test FLAGS is it 'K' mode (from OUT-CURS)
        JR      Z,L0364         ; skip to K-TOKENS if so

        BIT     3,(IY+$30)      ; test FLAGS2 - consider CAPS LOCK ?
        RET     NZ              ; return if so with main code.

        INC     B               ; is shift being pressed ?
                                ; result zero if not
        RET     NZ              ; return if shift pressed.

        ADD     A,$20           ; else convert the code to lower case.
        RET                     ; return.

; ---

; the jump was here for tokens

;; K-TOKENS
L0364:  
		ADD     A,$A5           ; add offset to main code so that 'A'
                                ; becomes 'NEW' etc.
        RET                     ; return

; ---

; the jump was here with digits, space, enter and symbol shift (< $xx)

;; K-DIGIT
L0367:  
		CP      $30             ; is it '0' or higher ?
        RET     C               ; return with space, enter and symbol-shift

        DEC     C               ; test MODE (was 0='KLC', 1='E', 2='G')
        JP      M,L039D         ; jump to K-KLC-DGT if was 0.

        JR      NZ,L0389        ; forward to K-GRA-DGT if mode was 2.

; continue with extended digits 0-9.

        LD      HL,KEYTABLE_F    ; $0254 - base of E-DIGITS
        BIT     5,B             ; test - shift=$27 sym-shift=$18
        JR      Z,L034A         ; to K-LOOK-UP if sym-shift

        CP      $38             ; is character '8' ?
        JR      NC,L0382        ; to K-8-&-9 if greater than '7'

        SUB     $20             ; reduce to ink range $10-$17
        INC     B               ; shift ?
        RET     Z               ; return if not.

        ADD     A,$08           ; add 8 to give paper range $18 - $1F
        RET                     ; return

; ---

; 89

;; K-8-&-9
L0382:  
		SUB     $36             ; reduce to 02 and 03  bright codes
        INC     B               ; test if shift pressed.
        RET     Z               ; return if not.

        ADD     A,$FE           ; subtract 2 setting carry
        RET                     ; to give 0 and 1    flash codes.

; ---

;  graphics mode with digits

;; K-GRA-DGT
L0389:  
		LD      HL,KEYTABLE_D    ; $0230 base address of CTL-CODES

        CP      $39             ; is key '9' ?
        JR      Z,L034A         ; back to K-LOOK-UP - changed to $0F, GRAPHICS.

        CP      $30             ; is key '0' ?
        JR      Z,L034A         ; back to K-LOOK-UP - changed to $0C, delete.

; for keys '0' - '7' we assign a mosaic character depending on shift.

        AND     $07             ; convert character to number. 0 - 7.
        ADD     A,$80           ; add offset - they start at $80

        INC     B               ; destructively test for shift
        RET     Z               ; and return if not pressed.

        XOR     $0F             ; toggle bits becomes range $88-$8F
        RET                     ; return.

; ---

; now digits in 'KLC' mode

;; K-KLC-DGT
L039D:  
		INC     B               ; return with digit codes if neither
        RET     Z               ; shift key pressed.

        BIT     5,B             ; test for caps shift.

        LD      HL,KEYTABLE_D    ; prepare base of table CTL-CODES.
        JR      NZ,L034A        ; back to K-LOOK-UP if shift pressed.

; must have been symbol shift

        SUB     $10             ; for ASCII most will now be correct
                                ; on a standard typewriter.
        CP      $22             ; but '@' is not - see below.
        JR      Z,L03B2         ; forward to to K-@-CHAR if so

        CP      $20             ; '_' is the other one that fails
        RET     NZ              ; return if not.

        LD      A,$5F           ; substitute ASCII '_'
        RET                     ; return.

; ---

;; K-@-CHAR
L03B2:  
		LD      A,$40           ; substitute ASCII '@'
        RET                     ; return.
	

; Simple code to initialize necessary system variables
INIT:
	; KSTATE
	LD A, $FF
	LD HL, $5C00
	
	LD (HL), A	; FF -> 5C00
	INC HL
	XOR A		; A = 0
	LD (HL), A	; 00 -> 5C01
	INC HL
	LD (HL), A	; 00 -> 5C02
	INC HL
	LD (HL), A	; 00 -> 5C03
	
	LD A, $FF
	INC HL
	LD (HL), A	; FF -> 5C04
	XOR A		; A = 0
	INC HL
	LD (HL), A	; 00 -> 5C05
	INC HL
	LD (HL), A	; 00 -> 5C06
	INC HL
	LD (HL), A	; 00 -> 5C07

	; LAST_K
	INC HL
	LD (HL), A	; 00 -> 5C08
	
	; REPDEL (time that key must be held down before it repeats)
	INC HL
	LD A, $23
	LD (HL), A	; 0x23 -> 5C09
	
	; REPPER
	INC HL
	LD A, $05
	LD (HL), A	; 5 -> 5C0A
	
	LD IY, $5C3A ; IY INIT
	
	; FLAGS
	XOR A		; A = 0
	LD (IY+$01), A
	
	; MODE
	LD (IY+$07), A
	
	; FLAGS2
	LD (IY+$30), A
	RET