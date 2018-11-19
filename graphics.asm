IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

;=============================================================================
; INCLUDES
;=============================================================================
include "globals.inc"
include "graphics.inc"
include "player.inc"

;=============================================================================
; CODE
;=============================================================================
CODESEG

; Set the video mode
PROC setVideoMode
	ARG @@Mode:byte
	USES eax

	mov ah, 0
	mov al, [@@Mode]
	int 10h
	
	ret
ENDP setVideoMode

; Fill the background (for mode 13h)
PROC fillBackground
    ARG @@fillColor:byte
	USES eax, ecx, edi

	mov edi, VMEMADR
	mov ecx, SCRWIDTH*SCRHEIGHT
	mov al, [@@fillColor]
	rep stosb
	
	ret
ENDP fillBackground

; Draw the main ship
PROC drawShip
	ARG @@fillColor:byte, @@xpos:dword, @@ypos:dword
	USES eax, edx, ecx, edi
	
	mov ecx, [characterHeight]
	@@heighloop:
		mov eax, [@@ypos]	;/** Calculate the start position of the current line to draw
		add eax, ecx		; *
		mov edx, SCRWIDTH	; *
		mul edx				; *
		add eax, [@@xpos]	; *
		add eax, VMEMADR	; *
		mov edi, eax		; */
		push ecx			; Save outer loop
		mov ecx, [characterWidth]
		mov al, [@@fillColor]
		rep stosb
		pop ecx				; Restore outer loop
	loop @@heighloop

	ret
ENDP drawShip

;=============================================================================
; Uninitialized DATA
;=============================================================================
UDATASEG

;=============================================================================
; DATA
;=============================================================================
DATASEG

END 