; Based on 128k, dissasembly in http://www.fruitcake.plus.com/Sinclair/Spectrum128/ROMDisassembly/Spectrum128ROMDisassembly.htm

#target rom


#code EPROM, 0x386e, 0x492

MAIN:
	SET 5, (IY+$02)		; DO I NEED THIS?!?
	
	;;;;;;;;;;;    THIS CODE WILL BE ELSEWHERE LATER
	DI
	LD A, $0		; first page
	IN A, ($1B)
	HALT
	EI
	;;;;;;;;;;;;
	
	CALL	INIT_MENU	; Initialise mode and cursor settings. IX will point at editing settings information.
	JP	SHOW_FILE_MENU	; Jump to show the Main Menu.

; ------------------------
; Initialise Mode Settings
; ------------------------
; Called before Main menu displayed.
INIT_MENU: 	; WAS L2584
	CALL RST_CURSOR_POS ; Reset Cursor Position.

	LD   HL,$0000     ; No top line.
	LD   ($FC9A),HL   ; Line number at top of screen.

	LD   A,$82        ; Signal waiting for key press, and menu is displayed.
	LD   ($EC0D),A    ; Store the Editor flags.

	LD   HL,$0000     ; No current line number.
	LD   ($5C49),HL   ; E_PPC. Current line number.

	CALL SET_INDENT_SETTINGS ; Reset indentation settings.
	CALL RESET_L_MODE_TOP ; Reset to 'L' Mode
	RET               ; [Could have saved one byte by using JP $365E (ROM 0)]


; ------------------------
; Set Indentation Settings
; ------------------------

SET_INDENT_SETTINGS:  ; WAS L35BC
	LD   HL,INDENT_SETTINGS ; HL=Address of the indentation settings data table.
	LD   DE,$FD6A     ; Destination address.
	JP   COPY_DATA_BLOCK ; Copy two bytes from $35B9-$35BA (ROM 0) to $FD6A-$FD6B.

; ---------------------
; Reset Cursor Position
; ---------------------
RST_CURSOR_POS:  ; WAS L28BE
	CALL RESET_MAIN_SCREEN ; Reset to main screen.
	CALL SET_MAIN_CURSOR_DETAILS ; Set default main screen editing cursor details.
	JP   INIT_MAIN_SCREEN_SETTINGS ; Set default main screen editing settings.

; ---------------------------------------
; Initialise Main Screen Editing Settings
; ---------------------------------------
; Used when selecting main screen. Copies 6 bytes from $28D2 (ROM 0) to $F6EE.

INIT_MAIN_SCREEN_SETTINGS: 	; WAS L28E8 
	LD   HL,MAIN_SCREEN_ERROR_CURSOR     ; Default main screen editing information.
	LD   DE,$F6EE     ; Editing information stores.
	JP   COPY_DATA_BLOCK ; Copy bytes.

; --------------------------------------
; Set Main Screen Editing Cursor Details
; --------------------------------------
; Set initial cursor editing settings when using the main screen.
; Copies 8 bytes from $3A6E-$3A75 (ROM 0) to $FD6C-$FD73.

SET_MAIN_CURSOR_DETAILS:  ; WAS L3A7F
	LD   IX,$FD6C     ; Point IX at cursor settings in workspace.

	LD   HL,INIT_LOWER_SCREEN_CURSROR ; Initial values table for the lower screen cursor settings.
	JR   SET_EDIT_CURSOR_DETAILS_END  ; Jump ahead.


; ---------------------------------------
; Set Lower Screen Editing Cursor Details
; ---------------------------------------
; Set initial cursor editing settings when using the lower screen.
; Copies 8 bytes from $3A77-$3A7E (ROM 0) to $FD6C-$FD73.

SET_LOWER_SCREEN_CURRSOR:  LD   HL,INIT_MAIN_SCREEN_CURSOR ; Initial values table for the main screen cursor settings.

SET_EDIT_CURSOR_DETAILS_END:  	; WAS L3A8B
	LD   DE,$FD6C     ; DE=Cursor settings in workspace.
	JP   COPY_DATA_BLOCK ; Jump to copy the settings.
		

; --------------------
; Reset to Main Screen
; --------------------

RESET_MAIN_SCREEN:  ; WAS L2E1F
	LD   HL,$5C3C     ; TVFLAG.
	RES  0,(HL)       ; Signal using main screen.
	LD   HL,UPPER_SCREEN_ROWS ; Upper screen lines table.
	LD   DE,$EC15     ; Destination workspace variable. The number of editing rows on screen.
	JP   COPY_DATA_BLOCK ; Copy one byte from $2E1C (ROM 0) to $EC15


; ---------------
; Copy Data Block
; ---------------
; This routine is used on 8 occasions to copy a block of default data.
; Entry: DE=Destination address.
;        HL=Address of source data table, which starts with the number of bytes to copy
;           followed by the bytes themselves.

COPY_DATA_BLOCK:  ; WAS L3FBA
	LD   B,(HL)       ; Get number of bytes to copy.
	INC  HL           ; Point to the first byte to copy.

CPY_BLK_LOOP:  
	LD   A,(HL)       ; Fetch the byte from the source
	LD   (DE),A       ; and copy it to the destination.
	INC  DE           ; Increment destination address.
	INC  HL           ; Increment source address.
	DJNZ CPY_BLK_LOOP ; Repeat for all bytes.

	RET               ;


; -----------------------
; Upper Screen Rows Table
; -----------------------
; Copied to $EC15-$EC16.

UPPER_SCREEN_ROWS:  ; WAS L2E1B
	DEFB $01          ; Number of bytes to copy.
	DEFB $14          ; Number of editing rows (20 for upper screen).


; --------------
; Show Main Menu
; --------------
SHOW_FILE_MENU:	; WAS L259F																					;;; TO BE
	;LD HL, MENU_JMP_TBL	; Jump table for Main Menu
	;LD ($F6EA), HL	; Store current menu jump table address
	LD HL, $C000	; Main Menu text									; MUST CHANGE TO ACTUAL ADDRESS IN RAM
	LD ($F6EC), HL	; Store current menu text table address

	PUSH HL
	
	LD HL, $EC0D	; Editor flags
	SET 1, (HL)		; Indicate 'menu displayed'
	RES 4, (HL)		; Signal return to main menu
	DEC HL			; current menu index
	LD (HL), $00	; select top entry
	
	DEC HL
	LD (HL), $00	; select page 0
	;LD HL, $EC0B
	;LD (HL), $00	; select page 0
	
	pop HL
	
DISPLAY_FILE_MENU_CALL:
	CALL DISPLAY_FILE_MENU ; Display menu and highlight first item DISPLAY MENU ROUTINE ADDRESS
	
	JP FILE_MENU_WAITING_LOOP		; Jump ahead to enter the main key waiting and processing


; -----------------
; Main Waiting Loop
; -----------------
; Enter a loop to wait for a key press. Handles key presses for menus, the Calculator and the Editor.
FILE_MENU_WAITING_LOOP:	; WAS L2653
	LD   SP,$EBFF     ; TSTACK. Use temporary stack.													TSTACK = EBFF now

	CALL RESET_L_MODE ; Reset 'L' mode.

	CALL WAIT_KEY_PRESS ; Wait for a key. [Note that it is possible to change CAPS LOCK mode whilst on a menu]
	PUSH AF           ; Save key code.

	LD   A,($5C39)    ; PIP. Tone of keyboard click.
	CALL KEY_CLICK_SOUND ; Produce a key click noise.

	POP  AF           ; Retrieve key code.
	LD   HL, FILE_MENU_KEYS_ACTION_TBL
	CALL PROCESS_KEY_PRESS ; Process the key press.

	JR   FILE_MENU_WAITING_LOOP ; Wait for another key.



; -----------------
; Process Key Press
; -----------------
; Handle key presses for the menus and the Editor.
; Entry: A=Key code.
;        HL=address to menu keys lookup table
;        Zero flag set if a menu is being displayed.
PROCESS_KEY_PRESS:  																						; CHANGE FOR BOTH TO WORK (parameter)
	PUSH HL
	LD   HL,$EC0D     ; Editor flags.
	BIT  1,(HL)       ; Is a menu is displayed?
	POP  HL
	PUSH AF           ; Save key code and flags.

	JR   NZ,PRESS_MENU_DISPLAYED ; Jump if menu is being displayed.

	;LD   HL,L2537     ; Use editing keys lookup table.												NO 128K BASIC HERE, SO THIS IS UNNECESSARY?

PRESS_MENU_DISPLAYED:  
	CALL CALL_ACTION_HNDLR ; Find and call the action handler for this key press.
	JR   NZ,PRESS_MENU_NO  ; Jump ahead if no match found.

	CALL NC,ERR_BEEP     ; If required then produce error beep.

	POP  AF           ; Restore key code.
	RET               ;
;No action defined for key code

PRESS_MENU_NO:  
	;POP  AF           ; Restore key code and flags.
	;JR   Z,PRESS_MENU_NDISPLAYED ; Jump if menu is not being displayed.							NO EDITOR MENU EXISTS HERE

;A menu is being displayed, so just ignore key press

	XOR  A            ; Select 'L' mode.
	LD   ($5C41),A    ; MODE.
	RET               ;

;A menu is not being displayed

;PRESS_MENU_NDISPLAYED:  
;	LD   HL,$EC0D     ; Editor flags.
;	BIT  0,(HL)       ; Is the Screen Line Edit Buffer is full?
;	JR   Z,PRESS_MENU_BUF_NFULL ; Jump if not to process the key code.

;The buffer is full so ignore the key press

;	CALL ERR_BEEP        ; Produce error beep.
;	RET               ; [Could have save a byte by using JP $26E7 (ROM 0)]

;PRESS_MENU_BUF_NFULL: 
;	CP   $A3          ; Was it a supported function key code?
;	JR   NC,FILE_MENU_WAITING_LOOP ; Ignore by jumping back to wait for another key.
					  ; [*BUG* - This should be RET NC since it was called from the loop at $2653 (ROM 0). Repeatedly pressing an unsupported
					  ; key will result in a stack memory leak and eventual overflow. Credit: John Steven (+3), Paul Farrow (128)]
	

;	JP   KEY_CHAR_CODE_HNDLR ; Jump forward to handle the character key press.
	
	
ERR_BEEP:
	RET	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; TODO??
	

; ---------------------------
; Call Action Handler Routine
; ---------------------------
; If the code in A matches an entry in the table pointed to by HL
; then execute the action specified by the entry's routine address.
; Entry: A=Code.
;        HL=Address of action table.
; Exit : Zero flag reset if no match found.
;        Carry flag reset if an error beep is required, or to signal no suitable action handler found.
;        HL=Address of next table entry if a match was found.
CALL_ACTION_HNDLR:  ; WAS L3FCE																		; COMMON ROUTINE
	PUSH BC           ; Save registers.
	PUSH DE           ;

	LD   B,(HL)       ; Fetch number of table entries.
	INC  HL           ; Point to first entry.

CALL_ACTION_NEXT_ENTRY:  
	CP   (HL)         ; Possible match for A?
	INC  HL           ;
	LD   E,(HL)       ;
	INC  HL           ;
	LD   D,(HL)       ; DE=Address to call if a match.
	JR   Z,CALL_ACTION_MATCH ; Jump if a match.

	INC  HL           ; Next table entry.
	DJNZ CALL_ACTION_NEXT_ENTRY ; Repeat for next table entry.

;No match found

        SCF               ; Return with carry flag reset to signal an error beep is required
        CCF               ; and with the zero flag reset to signal a match was not found.

        POP  DE           ; Restore registers.
        POP  BC           ;
        RET               ;

;Found a match

CALL_ACTION_MATCH:  EX   DE,HL        ; HL=Action routine to call.

        POP  DE           ;
        POP  BC           ;

        CALL CALL_ACTION ; Indirectly call the action handler routine.
        JR   C,CALL_ACTION_NO_ERR ; Jump if no error beep is required.

        CP   A            ; Set zero flag to indicate a match was found.
        RET               ; Exit with carry flag reset to indicate error beep required.

CALL_ACTION_NO_ERR:  CP   A            ; Set zero flag to indicate a match was found.
        SCF               ; Signal no error beep required.
        RET               ;

CALL_ACTION:  JP   (HL)         ; Jump to the action handler routine.


; ---------------------------
; Key Click Sound
; ---------------------------

KEY_CLICK_SOUND:		; WAS 3B47															; COMMON ROUTINE
	PUSH IX           ;

	LD   D,$00        ; Pitch.
	LD   E,A          ;
	LD   HL,$0C80     ; Duration.

	CALL $03B5        ; BEEPER. Produce a tone.
	;RST  28H          ;																		OLD
	;DEFW $03B5       ; BEEPER. Produce a tone.

	POP  IX           ;
	RET               ;


; --------------------
; Wait for a Key Press
; --------------------
; Exit: A holds key code.
WAIT_KEY_PRESS:			; WAS 3B55																			; COMMON ROUTINE
	PUSH HL           ; Preserve contents of HL.

WAIT_KEY:  
	LD   HL,$5C3B     ; FLAGS.

KEY_WAIT_LOOP:  
	BIT  5,(HL)       ;
	JR   Z,KEY_WAIT_LOOP ; Wait for a key press.

	RES  5,(HL)       ; Clear the new key indicator flag.

	LD   A,($5C08)    ; Fetch the key pressed from LAST_K.
	LD   HL,$5C41     ; MODE.
	RES  0,(HL)       ; Remove extended mode.

	CP   $20          ; Is it a control code?
	JR   NC,NCTRL_KEY ; Jump if not to accept all characters and token codes (used for the keypad).

	CP   $10          ; Is it a cursor key?
	JR   NC,WAIT_KEY  ; Jump back if not to wait for another key.

	CP   $06          ; Is it a cursor key?
	JR   C,WAIT_KEY   ; Jump back if not to wait for another key.

;Control code or cursor key

	CALL CAPS_MODE_HNDLR  ; Handle CAPS LOCK code and 'mode' codes.
	JR   NC,WAIT_KEY     ; Jump back if mode might have changed.

NCTRL_KEY: 
	POP  HL           ; Restore contents of HL.
	RET               ;

CAPS_MODE_HNDLR:  
	CALL $10DB          ; KEY_M_CL. Handle CAPS LOCK code and 'mode' codes via ROM 1.
	; RST  28H          ; 																			OLD
	; DEFW $10DB        ; KEY_M_CL. Handle CAPS LOCK code and 'mode' codes via ROM 1.
	RET               ;
	
	

RESET_L_MODE_TOP:		;; WAS 3B7E (L365E)																; COMMON ROUTINE
	LD   A,$00        ; Select 'L' mode.
	LD   ($5C41),A    ; MODE.

	LD   A,$02        ; Reset repeat key duration.
	LD   ($5C0A),A    ; REPPER

RESET_L_MODE:    ;; WAS 3B88
	LD   HL,$5C3B     ; FLAGS.
	LD   A,(HL)       ;
	OR   $0C          ; Select L-Mode and Print in L-Mode.
	LD   (HL),A       ;

	LD   HL,$EC0D     ; Editor flags.
	BIT  4,(HL)       ; Return to the calculator?
	LD   HL,$7B66     ; FLAGS3.
	JR   NZ,CALC      ; Jump ahead if so.

	RES  0,(HL)       ; Select Editor/Menu mode.
	RET               ;

CALC:  
	SET  0,(HL)       ; Select BASIC/Calculator mode.
	RET               ;




; ------------
; Print Stripe (NEW)
; ------------
; A=0 if no speccy stripe
; HL=Address of text.
; BC=Coordinates of stripe
PRINT_BLACK_STRIPE:

	LD   D, A
	PUSH DE

	CALL PRINT_AT_B_C
	
	PUSH HL           ;
	LD   HL,FILE_MENU_TITLE_COLORS_TBL ; Set title colours.		
	CALL PRINT_STRING ; Print them.
	POP  HL           ;
	
	POP  DE
	LD   B, $1F ; num of columns
	XOR A             ; A = 0
	CP  D             ; A - D for flag setting (jump ahead)
	PUSH DE
	JR   Z, CHAR_STRIPE
	LD   B, $1A ; num of columns
CHAR_STRIPE:
	LD   A, (HL)
	INC HL
	CP   $FF ;; end char
	JR   Z, TRAILING_SPACES_STRIPE
	
	RST  10H
	DJNZ CHAR_STRIPE
TRAILING_SPACES_STRIPE:
	LD   A, $20
	RST  10H
	DJNZ TRAILING_SPACES_STRIPE
	
	POP DE
	XOR A
	CP  D
	JR  Z, PRINT_BLACK_STRIPE_END
	CALL PRINT_STRIPES
	
	LD   A, $20
	RST  10H
	
PRINT_BLACK_STRIPE_END:
	RET
	
; --------------------------------------
; Print the Sinclair stripes on the menu
; --------------------------------------

PRINT_STRIPES:			;																								COMMON ROUTINE 
	PUSH BC           ; Save registers.
	PUSH DE           ;
	PUSH HL           ;

	LD   HL,SINCLAIR_STRIPES ; Graphics bit-patterns
	LD   DE,$5B98     ; STRIP1.									; CHANGE THIS
	LD   BC,$0010     ; Copy two characters.
	LDIR              ;

	LD   HL,($5C36)   ; Save CHARS.
	PUSH HL           ;

	LD   HL,$5A98 	  ; $STRIP1-$0100.									; CHANGE THIS
	LD   ($5C36),HL   ; Set CHARS to point to new graphics.

	LD   HL,SINCLAIR_STRIP_TEXT ; Point to the strip string.
	CALL PRINT_STRING ; Print it.

	POP  HL           ; Restore CHARS.
	LD   ($5C36),HL   ;

	POP  HL           ; Restore registers.
	POP  DE           ;
	POP  BC           ;
	RET               ;

SINCLAIR_STRIPES:  ;                                                                                                        COMMON
	DEFB $01          ; 0 0 0 0 0 0 0 1           X
	DEFB $03          ; 0 0 0 0 0 0 1 1          XX
	DEFB $07          ; 0 0 0 0 0 1 1 1         XXX
	DEFB $0F          ; 0 0 0 0 1 1 1 1        XXXX
	DEFB $1F          ; 0 0 0 1 1 1 1 1       XXXXX
	DEFB $3F          ; 0 0 1 1 1 1 1 1      XXXXXX
	DEFB $7F          ; 0 1 1 1 1 1 1 1     XXXXXXX
	DEFB $FF          ; 1 1 1 1 1 1 1 1    XXXXXXXX

	DEFB $FE          ; 1 1 1 1 1 1 1 0    XXXXXXX
	DEFB $FC          ; 1 1 1 1 1 1 0 0    XXXXXX
	DEFB $F8          ; 1 1 1 1 1 0 0 0    XXXXX
	DEFB $F0          ; 1 1 1 1 0 0 0 0    XXXX
	DEFB $E0          ; 1 1 1 0 0 0 0 0    XXX
	DEFB $C0          ; 1 1 0 0 0 0 0 0    XX
	DEFB $80          ; 1 0 0 0 0 0 0 0    X
	DEFB $00          ; 0 0 0 0 0 0 0 0
	
SINCLAIR_STRIP_TEXT:		;;                                                                                             COMMON
	DEFB $10, $02, ' ' ; INK 2;
	DEFB $11, $06, '!' ; PAPER 6;
	DEFB $10, $04, ' ' ; INK 4;
	DEFB $11, $05, '!' ; PAPER 5;
	DEFB $10, $00, ' ' ; INK 0;
	DEFB $FF           ;

; ------------
; Display Menu
; ------------
; HL=Address of menu text.
DISPLAY_FILE_MENU:			; WAS L36A8															; TO BE

	LD   E,(HL)       ; Fetch number of table entries.
	INC  HL           ; Point to first entry.
	
	DEC  E
	LD   A, $10       ; Max number of entries
	SUB  E            ; A=number of empty entries
	LD   D, A       
	
	LD   BC, $0300
	LD   A, $1
	PUSH DE 
	CALL PRINT_BLACK_STRIPE ; Prints stripe with title 

;;;;;;;;;;;;;;;;;;;

	PUSH HL           ;
	LD   HL,FILE_MENU_TITLE_SPACE_TBL ; setting color for rest of text
	CALL PRINT_STRING ; Print it.
	POP  HL           ; HL=Address of first menu item text.

	LD   BC,$0400     ;
	CALL PRINT_AT_B_C ; Perform 'Print AT 4,0;' (this is the top left position of the menu).
	
ITEM2:
	PUSH BC           ; Save row print coordinates.

	LD   B,$1F        ; Number of columns in a row of the menu.
	
CHAR2:  
	LD   A,(HL)       ; Fetch menu item character.
	INC  HL           ;
	CP   $80          ; End marker found?
	JR   NC,CHAR_END2  ; Jump if end of text found.

	RST  10H          ; Print menu item character
	DJNZ CHAR2         ; Repeat for all characters in menu item text.
	
CHAR_END2:
	AND  $7F          ; Clear bit 7 to yield a final text character.
	RST  10H          ; Print it.
	
TRAILING_SPACES2:
	LD   A,$20        ;
	RST  10H          ; Print trailing spaces
	DJNZ TRAILING_SPACES2 ; Until all columns filled.
		
	POP  BC           ; Fetch row print coordinates.
	INC  B            ; Next row.
	CALL PRINT_AT_B_C ; Print AT.

	DEC  E            ;
	JR   NZ,ITEM2      ; Repeat for all menu items.
	
	POP  DE
	XOR  A
	CP   D
	JR   Z, EMPTY_ENTRIES_END
EMPTY_ENTRIES:
	PUSH BC           ; Save row print coordinates.
	LD   B, $1F
	
EMPTY_ENTRIES_TRAILING:
	LD   A,$20        ;
	RST  10H          ; Print trailing spaces
	DJNZ EMPTY_ENTRIES_TRAILING ; Until all columns filled.
	
	POP  BC           ; Fetch row print coordinates.
	INC  B            ; Next row.
	CALL PRINT_AT_B_C ; Print AT.
	
	DEC  D
	JR   NZ, EMPTY_ENTRIES

EMPTY_ENTRIES_END:	

	
	LD HL, FILE_MENU_TITLE_COLORS_TBL+10 ; address of a ' '
	LD BC, $1400	   ; coordinates
	XOR A
	CALL PRINT_BLACK_STRIPE  ; Prints stripe


	XOR  A            ; A=Index of menu option to highlight.
	CALL TOGGLE_FILE_MENU_HIGHLIGHT ; Toggle menu option selection so that it is highlight.
	RET               ; [Could have saved one byte by using JP $37CA (ROM 0)]



; --------------------------------------
; Toggle Menu Option Selection Highlight
; --------------------------------------
; Entry: A=Menu option index to highlight.
TOGGLE_FILE_MENU_HIGHLIGHT:	;; WAS 3C06 (L37CA)																	; TO BE
	PUSH AF           ; Save registers.
	PUSH HL           ;
	PUSH DE           ;

	LD   HL,$5880     ; First attribute byte at position (4,0).
	LD   DE,$0020     ; The increment for each row.
	AND  A            ;
	JR   Z,HIGHED2     ; Jump ahead if highlighting the first entry.

LOOP:  
	ADD  HL,DE        ; Otherwise increase HL
	DEC  A            ; for each row.
	JR   NZ,LOOP      ;

HIGHED2:  
	LD   A,$78        ; Flash 0, Bright 1, Paper 7, Ink 0 = bright white.
	CP   (HL)         ; Is the entry already highlighted?
	JR   NZ,HIGHLIGHT2 ; Jump ahead if not.

	;LD   A,$30        ; Flash 0, Bright 0, Paper 6, Ink 0 = dark yellow.
	LD   A,$68        ; Flash 0, Bright 1, Paper 5, Ink 0 = cyan.

HIGHLIGHT2:  
	LD   D,$20        ; There are 32 columns to set.						; CHANGED

NEXT_COL2: 
	LD   (HL),A       ; Set the attributes for all columns.
	INC  HL           ;
	DEC  D            ;
	JR   NZ,NEXT_COL2  ;

	POP  DE           ; Restore registers.
	POP  HL           ;
	POP  AF           ;
	RET               ;

; -------------------------------
; Menu Key Press Handler - SELECT
; -------------------------------

FILE_SEL_HNDLR:  																						; TO BE
	DI
	
	;LD   HL,$EC0D     ; HL points to Editor flags.
	;RES  1,(HL)       ; Clear 'displaying menu' flag.

	;DEC  HL           ; HL=$EC0C.
	LD   HL,$EC0C
	LD   B,(HL)       ; B=Current menu option index (game number in page)
	LD   C, $1B		  ; SD interface

	LD   A, ($EC0A)   ; page menu type
	AND  A            ; for checking if A is 0
	JR   Z, FILE_SEL_HNDLR_CONT
	LD   C, $1D		  ; Online interface
FILE_SEL_HNDLR_CONT:
	LD   A, B		  ; A=Current menu option index (game number in page)
	DEC  HL           ; HL=$EC0B.
	LD   B, (HL)	  ; B=Current menu page
	
	OUT (C), A        ; 
	HALT


	;LD   HL,($F6EA)   ; HL points to jump table for current menu.
	;PUSH HL           ;
	;PUSH AF           ;
	;CALL L373E        ; Restore menu screen area.														IS THIS NECESSARY?
	;POP  AF           ;
	;POP  HL           ;

	;CALL CALL_ACTION_HNDLR ; Call the item in the jump table corresponding to the
					  ; currently selected menu item.
					  
	JP   SHOW_CURSOR  ; Set attribute at editing position so as to show the cursor, and return.


; -----------
; Show Cursor
; -----------
; Set editing cursor colour at current position.
; Exit: C=row number.
;       B=Column number.
SHOW_CURSOR:	;WAS L29F2																				; COMMON ROUTINE
	CALL FETCH_CURSOR_POS ; Get current cursor position (C=row, B=column, A=preferred column).												IDK IF I NEED THIS
	JP   SET_CURSOR_COLOR ; Set editing position character square to cursor colour to show it.
					  ; [Could have saved 1 byte by using a JR instruction to join the end of the routine below]

; ---------------------																														OR THIS
; Fetch Cursor Position
; ---------------------
; Returns the three bytes of the cursor position.
; Exit : C=Row number.
;        B=Column number
;        A=Preferred column number.

FETCH_CURSOR_POS:  	; WAS L2A07																			; COMMON ROUTINE
	LD   HL,$F6EE     ; Editing info.
	LD   C,(HL)       ; Row number.
	INC  HL           ;
	LD   B,(HL)       ; Column number.
	INC  HL           ;
	LD   A,(HL)       ; Preferred column number.
	INC  HL           ;
	RET               ;


; ---------------------------																												OR THIS
; Set Cursor Attribute Colour
; ---------------------------
; Entry: C=Row number, B=Column number.

SET_CURSOR_COLOR:  ; WAS L3640																			; COMMON ROUTINE
	PUSH AF           ; Save registers.
	PUSH BC           ;
	PUSH DE           ;
	PUSH HL           ;

	LD   A,B          ; Swap B with C.
	LD   B,C          ;
	LD   C,A          ;
	CALL SET_CURSOR_POS ; Set cursor position attribute.

	POP  HL           ; Restore registers.
	POP  DE           ;
	POP  BC           ;
	POP  AF           ;
	RET               ;

; -----------------------------																												OR THIS
; Set Cursor Position Attribute
; -----------------------------
; Entry: B=Row number
;        C=Column number.
;        IX=Address of the cursor settings information.

SET_CURSOR_POS:  	; WAS L3A9D																					; COMMON ROUTINE
	LD   A,(IX+$01)   ; A=Rows above the editing area ($16 when using the lower screen, $00 when using the main screen).
	ADD  A,B          ; B=Row number within editing area.
	LD   B,A          ; B=Screen row number.
	CALL GET_ATT_ADDR ; Get address of attribute byte into HL.

	LD   A,(HL)       ; Fetch current attribute byte.
	LD   (IX+$07),A   ; Store the current attribute byte.
	CPL               ; Invert colours.
	AND  $C0          ; Mask off flash and bright bits.
	OR   (IX+$06)     ; Get cursor colour.
	LD   (HL),A       ; Store new attribute value to screen.

	SCF               ; [Redundant since calling routine preserves AF]
	RET               ;


; ---------------------																													OR THIS
; Get Attribute Address
; ---------------------
; Get the address of the attribute byte for the character position (B,C).
; Entry: B=Row number.
;        C=Column number.
; Exit : HL=Address of attribute byte.

GET_ATT_ADDR: 	;WAS L3BA0																						; COMMON ROUTINE
	PUSH BC           ; Save BC.

	XOR  A            ; A=0.
	LD   D,B          ;
	LD   E,A          ; DE=B*256.
	RR   D            ;
	RR   E            ;
	RR   D            ;
	RR   E            ;
	RR   D            ;
	RR   E            ; DE=B*32.
	LD   HL,$5800     ; Start of attributes file.																					DONT THINK 48K HAS THIS
	LD   B,A          ; B=0.
	ADD  HL,BC        ; Add column offset.
	ADD  HL,DE        ; Add row offset.

	POP  BC           ; Restore BC.
	RET               ;

PRINT_AT_B_C:		; WAS 3C3A
	LD   A,$16        ; 'AT'.
	RST  10H          ; Print.
	LD   A,B          ; B=Row number.
	RST  10H          ; Print.
	LD   A,C          ; C=Column number.
	RST  10H          ; Print.
	RET               ;

; ------------
; Print String
; ------------
; Print characters pointed to by HL until $FF found.
PRINT_STRING:		  ; WAS 3C90
	LD   A,(HL)       ; Fetch a character.
	INC  HL           ; Advance to next character.
	CP   $FF          ; Reach end of string?
	RET  Z            ; Return if so.

	RST  $10          ; Print the character.
	JR   PRINT_STRING ; Back for the next character.

; ----------------------------------
; Menu Key Press Handler - CURSOR UP
; ----------------------------------
FILE_UP_HNDLR:  																								; TO BE
	SCF               ; Signal move up.
	JR   FILE_UP_DN_HNDLR  ; Jump ahead to continue.

; ------------------------------------
; Menu Key Press Handler - CURSOR DOWN
; ------------------------------------
FILE_DN_HNDLR:  																								; TO BE
	AND  A            ; Signal moving down.

FILE_UP_DN_HNDLR:    																								; TO BE
	LD   HL,$EC0C     ;
	LD   A,(HL)       ; Fetch current menu index.
	PUSH HL           ; Save it.

	LD   HL,($F6EC)   ; Address of text for current menu.
	CALL C,FILE_MOVE_UP    ; Call if moving up.
	CALL NC,FILE_MOVE_DN   ; Call if moving down.

	POP  HL           ; HL=Address of current menu index store.
	LD   (HL),A       ; Store the new menu index.

; Comes here to complete handling of Menu cursor up and down. Also as the handler routines
; for Edit Menu return to 128 BASIC option and Calculator menu return to Calculator option,
; which simply make a return.

FINISH_KEY_HNDLR:    																								; COMMON
	SCF               ;
	RET               ;
		
		

; ------------
; Move Up Menu
; ------------

FILE_MOVE_UP:    																								; TO BE 
	CALL TOGGLE_FILE_MENU_HIGHLIGHT ; Toggle old menu item selection to de-highlight it.
	DEC  A            ; Decrement menu index.
	JP   P,FILE_MORE_UP    ; Jump if not exceeded top of menu.

	LD   A,(HL)       ; Fetch number of menu items.
	DEC  A            ; Ignore the title.
	DEC  A            ; Make it indexed from 0.

FILE_MORE_UP:    																								; TO BE
	CALL TOGGLE_FILE_MENU_HIGHLIGHT ; Toggle new menu item selection to highlight it.
	SCF               ; Ensure carry flag is set to prevent immediately
	RET               ; calling menu down routine upon return.

; --------------
; Move Down Menu
; --------------

FILE_MOVE_DN:    																								; TO BE
	PUSH DE           ; Save DE.

	CALL TOGGLE_FILE_MENU_HIGHLIGHT ; Toggle old menu item selection to de-highlight it.

	INC  A            ; Increment menu index.
	LD   D,A          ; Save menu index.

	LD   A,(HL)       ; fetch number of menu items.
	DEC  A            ; Ignore the title.
	DEC  A            ; Make it indexed from 0.
	CP   D            ; Has bottom of menu been exceeded?
	LD   A,D          ; Fetch menu index.
	JP   P,FILE_MORE_DN    ; Jump if bottom menu not exceeded.

	XOR  A            ; Select top menu item.

FILE_MORE_DN:    																								; TO BE
	CALL TOGGLE_FILE_MENU_HIGHLIGHT ; Toggle new menu item selection to highlight it.

	POP  DE           ; Restore DE.
	RET               ;
	
	
; ----------------------------------
; Menu Key Press Handler - CURSOR RIGHT
; ----------------------------------
RT_HNDLR:  																								; TO BE
	;SCF               ; Signal move up.
	LD HL, ($F6EC)        ; addr of page entries size
	LD A, (HL)
	SUB A, $11
	JR NZ, NO_RT
	
	LD   HL, $EC0B    ; 
	LD   A, (HL)      ; Fetch current page number
	INC  A            ;
	LD   (HL), A      ; increment page number and store it back 
	JR   RT_LT_HNDLR  ; Jump ahead to continue.
NO_RT:
	RET
	; MAKE PAGE NUM UPDATE INCREMENT
	; CHECK MENU TEXT AREA, CHECK NUM OF ENTRIES TO FIND OUT IF LAST PAGE
	; IF IT IS LAST PAGE, RET
	

; ------------------------------------
; Menu Key Press Handler - CURSOR LEFT
; ------------------------------------
LT_HNDLR:  																								; TO BE
	LD   HL, $EC0B    ; 
	LD   A, (HL)      ; Fetch current page number
	CP   $0
	JR   NZ, LT_HNDLR_DEC ; check if it is zero
	RET
	
LT_HNDLR_DEC:
	DEC  A            ;
	LD   (HL), A      ; decrement page number and store it back 
	
RT_LT_HNDLR:    																								; TO BE

	LD   (HL),A       ; Store the new page number.
	INC  HL			  ; addr to current menu index
	
	PUSH AF
	
	LD   A, (HL)      ; A=old menu index
	CALL TOGGLE_FILE_MENU_HIGHLIGHT ; Toggle old menu item selection to de-highlight it.
	LD   (HL), $0     ; reset menu index to 0
	XOR A
	CALL TOGGLE_FILE_MENU_HIGHLIGHT ; Toggle top menu item selection to highlight it.

	POP AF 

	LD   B, A
	LD   C, 0x1B
	LD   HL, $EC0A    ; menu type addr
	BIT  0, (HL)
	JR   Z, RT_LT_PAGE_CONTINUE
	LD   C, 0x1D
RT_LT_PAGE_CONTINUE:
	IN   A, (C)       ; the A doesn't matter
	HALT
	LD HL, ($F6EC)
	JP   DISPLAY_FILE_MENU_CALL

; Comes here to complete handling of Menu cursor up and down. Also as the handler routines
; for Edit Menu return to 128 BASIC option and Calculator menu return to Calculator option,
; which simply make a return.

;FINISH_LR_KEY_HNDLR:    																				; TO BE
;	SCF               ;
;	RET               ;
		
		
		

;;------------
;; DATA
;;------------
FILE_MENU_KEYS_ACTION_TBL:  																		; TO BE
	DEFB $06          ; Number of entries.
	DEFB $0B          ; Key code: Cursor up.
	DEFW FILE_UP_HNDLR     ; MENU-UP handler routine.
	DEFB $0A          ; Key code: Cursor down.
	DEFW FILE_DN_HNDLR     ; MENU-DOWN handler routine.
	
	DEFB $09          ; Key code: Cursor right.
	DEFW RT_HNDLR     ; left handler routine.
	DEFB $08          ; Key code: Cursor left.
	DEFW LT_HNDLR     ; right handler routine.

	
	DEFB $07          ; Key code: Edit.	
	DEFW FILE_SEL_HNDLR ; MENU-SELECT handler routine.
	DEFB $0D          ; Key code: Enter.
	DEFW FILE_SEL_HNDLR ; MENU-SELECT handler routine.

	
FILE_MENU_TITLE_SPACE_TBL:  ; WAS 3C42
	DEFB $13, $01      ; BRIGHT 1;
	DEFB $11, $07      ; PAPER 7;
	DEFB $10, $00      ; INK 0;
	DEFB $FF           ;
	
FILE_MENU_TITLE_COLORS_TBL:  ; WAS 3C98													; TO BE
	;DEFB $16, $04, $00 ; AT 4,0;  CHANGED
	;DEFB $16, $02, $00 ; AT 2,0;  CHANGED
	DEFB $15, $00      ; OVER 0;
	DEFB $14, $00      ; INVERSE 0;
	DEFB $10, $07      ; INK 7;
	DEFB $11, 00       ; PAPER 0;
	DEFB $13, $01      ; BRIGHT 1;
	DEFB ' '
	DEFB $FF           ;
	
; ------------------------------------
; Initial Lower Screen Cursor Settings
; ------------------------------------
; Copied to $FD6C-$FD73.

INIT_LOWER_SCREEN_CURSROR:  ; WAS L3A6D
	DEFB $08          ; Number of bytes in table.
	DEFB $00          ; $FD6C. [Setting never used]
	DEFB $00          ; $FD6D = Rows above the editing area.
	DEFB $14          ; $FD6E. [Setting never used]
	DEFB $00          ; $FD6F. [Setting never used]
	DEFB $00          ; $FD70. [Setting never used]
	DEFB $00          ; $FD71. [Setting never used]
	DEFB $0F          ; $FD72 = Cursor attribute colour (blue paper, white ink).
	DEFB $00          ; $FD73 = Stored cursor position screen attribute colour (None = black paper, black ink).

; -----------------------------------
; Initial Main Screen Cursor Settings
; -----------------------------------
; Copied to $FD6C-$FD73.

INIT_MAIN_SCREEN_CURSOR:  	; WAS L3A76
	DEFB $08          ; Number of bytes in table.
	DEFB $00          ; $FD6C. [Setting never used]
	DEFB $16          ; $FD6D = Rows above the editing area.
	DEFB $01          ; $FD6E. [Setting never used]
	DEFB $00          ; $FD6F. [Setting never used]
	DEFB $00          ; $FD70. [Setting never used]
	DEFB $00          ; $FD71. [Setting never used]
	DEFB $0F          ; $FD72 = Cursor attribute colour (blue paper, white ink).
	DEFB $00          ; $FD73 = Stored cursor position screen attribute colour (None = black paper, black ink).
	
; --------------------
; Indentation Settings
; --------------------
; Copied to $FD6A-$FD6B.

INDENT_SETTINGS:  ; WAS L35B9
	DEFB $02          ; Number of bytes in table.
	DEFB $01          ; Flag never subsequently used. Possibly intended to indicate the start of a new BASIC line and hence whether indentation required.
	DEFB $05          ; Number of characters to indent by.

; ---------------------------------
; Main Screen Error Cursor Settings
; ---------------------------------
; Main screen editing cursor settings.
; Gets copied to $F6EE.

MAIN_SCREEN_ERROR_CURSOR:  ; WAS L28D1
	DEFB $06          ; Number of bytes in table.
	DEFB $00          ; $F6EE = Cursor position - row 0.
	DEFB $00          ; $F6EF = Cursor position - column 0.
	DEFB $00          ; $F6F0 = Cursor position - column 0 preferred.
	DEFB $04          ; $F6F1 = Top row before scrolling up.
	DEFB $10          ; $F6F2 = Bottom row before scrolling down.
	DEFB $14          ; $F6F3 = Number of rows in the editing area.
