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

; Wait for esc keystroke.
PROC isESCpressed
	mov	ah, 00h
	int	16h
	cmp al, 27
	jne @@notPressedESC ; if not pressed skip terminate function
	call terminateProcess
	@@notPressedESC:
	ret
ENDP isESCpressed

;Check if key is pressed.
PROC isKeypressed
	mov	ah, 00h
	int	16h
	cmp al, 27 ; check if ESC is pressed
	jne @@notPressedESC ; if not pressed skip terminate function
	call terminateProcess
	@@notPressedESC:
    cmp al, 27 ; check if Left is pressed
	jne @@notPressedLeft ; if not pressed skip terminate function
	call leftPressed
	@@notPressedLeft:
    cmp al, 27 ; check if Left is pressed
	jne @@notPressedRight ; if not pressed skip terminate function
	call rightPressed
	@@notPressedRight:
	ret
ENDP isKeypressed

; Wait for Left arrow keystroke.
PROC isLeftpressed
	mov	ah, 00h
	int	16h
	cmp al, 27
	jne @@notPressedLeft ; if not pressed skip terminate function
	call terminateProcess
	@@notPressedESC:
	ret
ENDP isLeftpressed

; Wait for esc keystroke.
PROC isRightpressed
	mov	ah, 00h
	int	16h
	cmp al, 27
	jne @@notPressedESC ; if not pressed skip terminate function
	call terminateProcess
	@@notPressedESC:
	ret
ENDP isRightpressed


;=============================================================================
; Uninitialized DATA
;=============================================================================
UDATASEG

;=============================================================================
; DATA
;=============================================================================
DATASEG

END 