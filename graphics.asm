IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

;=============================================================================
; INCLUDES
;=============================================================================
include "globals.inc"
include "graphics.inc"

;=============================================================================
; CODE
;=============================================================================
CODESEG

; Set the video mode
PROC setVideoMode
	ARG @@Mode:byte
	mov ah, 0
	mov al, [@@Mode]
	int 10h
	
	ret
ENDP setVideoMode

; Fill the background (for mode 13h)
PROC fillBackground
    ARG @@fillColor:byte
	USES eax,ebx, edi

	mov edi,VMEMADR
	mov ecx, SCRWIDTH*SCRHEIGHT
	mov al,[@@fillColor]
	rep stosb
	
	ret
ENDP fillBackground

; Draw the main ship
PROC drawShip
	ARG @@fillColor:byte
	
	mov al,[@@fillColor]
	@@colcount:
	inc cx
	int 10h
	cmp cx, 30
	JNE @@colcount

	mov cx, 10  ; reset to start of col
	inc dx      ;next row
	cmp dx, 30
	JNE @@colcount
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