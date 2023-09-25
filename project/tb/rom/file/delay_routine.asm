; https://worldofspectrum.org/files/large/cb0c60215da625f

		DI				; 4 cycles
START:
		LD D, $FF		; 7 cycles
		LD E, $FF		; 7 cycles
		CALL OLOOP		; 17 cycles
		
		LD D, $FF		; 7 cycles
		LD E, $FF		; 7 cycles
		CALL OLOOP		; 17 cycles
		
		LD D, $FF		; 7 cycles
		LD E, $85		; 7 cycles
		CALL OLOOP		; 17 cycles
		
		NEG 			; 4 cycles
		LD ($FF00), A	; 13 cycles
		JP START		; 10 cycles

OLOOP:	
		DEC E			; 4 cycles
		RET Z			; 11 or 5 if true
ILOOP:
		DEC D			; 4 cycles
		JP Z, OLOOP		; 10 cycles
		JP ILOOP		; 10 cycles 
		
		
; C = 31 + 15*E + E*(D*24) - 6

; E = 255
; D = 255

; then C = 1 564 440

; OLOOP with 255 255 twice gives C = 3128880

; missing 371 120

; 371 120 = 25 + 15*E + E*(24*D)

; D = 255

; 371 120 = 25 + 15*E + 6120*E

; 371 120 = 25 + 6135*E

; E = 60,488 (0x96)