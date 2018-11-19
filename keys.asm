IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

;=============================================================================
; INCLUDES
;=============================================================================
include "globals.inc"
include "graphics.inc"
include "main.inc"
include "keys.inc"
include "player.inc"
include "debug.inc"

;=============================================================================
; CODE
;=============================================================================
CODESEG

PROC isKeypressed
	USES eax
	; Scancodes: http://www.ee.bgu.ac.il/~microlab/MicroLab/Labs/ScanCodes.htm

	cmp [__keyb_keyboardState + 01h], 1 ; ESC
	jne @@notPressedESC ; skip if not pressed
		call terminateProcess
	@@notPressedESC:

	mov [playerSpeed], 0 ; reset x speed incase no key is pressed
	cmp [__keyb_keyboardState + 4bh], 1 ; Left arrow
	jne @@notPressedLeft 
		mov eax, [playerMaxSpeed + 4]
		mov [playerSpeed], eax
		; call printString, offset left
	@@notPressedLeft:

	cmp [__keyb_keyboardState + 4dh], 1 ; Right arrow
	jne @@notPressedRight 
		mov eax, [playerMaxSpeed]
		mov [playerSpeed], eax
		; call printString, offset right
	@@notPressedRight:

	mov [playerSpeed + 4], 0 ; reset y speed incase no key is pressed
	cmp [__keyb_keyboardState + 48h], 1 ; Up arrow
	jne @@notPressedUP
		mov eax, [playerMaxSpeed + 4]
		mov [playerSpeed + 4], eax
		; call printString, offset up
	@@notPressedUP:

	cmp [__keyb_keyboardState + 50h], 1 ; Down arrow
	jne @@notPressedDown
		mov eax, [playerMaxSpeed]
		mov [playerSpeed + 4], eax
		; call printString, offset down
	@@notPressedDown:

	ret
ENDP isKeypressed

;-----------------------------------------------------------------------------

; Installs the custom keyboard handler
PROC __keyb_installKeyboardHandler
    push	ebp
    mov		ebp, esp

	push	eax
	push	ebx
	push	ecx
	push	edx
	push	edi
	push	ds
	push	es
		
	; clear state buffer and the two state bytes
	cld
	mov		ecx, (128 / 2) + 1
	mov		edi, offset __keyb_keyboardState
	xor		eax, eax
	rep		stosw
	
	; store current handler
	push	es			
	mov		eax, 3509h			; get current interrupt handler 09h
	int		21h					; in ES:EBX
	mov		[originalKeyboardHandlerS], es	; store SELECTOR
	mov		[originalKeyboardHandlerO], ebx	; store OFFSET
	pop		es
		
	; set new handler
	push	ds
	mov		ax, cs
	mov		ds, ax
	mov		edx, offset keyboardHandler			; new OFFSET
	mov		eax, 2509h							; set custom interrupt handler 09h
	int		21h									; uses DS:EDX
	pop		ds
	
	pop		es
	pop		ds
	pop		edi
	pop		edx
	pop		ecx
	pop		ebx
	pop		eax	
    
    mov		esp, ebp
    pop		ebp
    ret
ENDP __keyb_installKeyboardHandler

; Restores the original keyboard handler
PROC __keyb_uninstallKeyboardHandler
    push	ebp
    mov		ebp, esp

	push	eax
	push	edx
	push	ds
		
	mov		edx, [originalKeyboardHandlerO]		; retrieve OFFSET
	mov		ds, [originalKeyboardHandlerS]		; retrieve SELECTOR
	mov		eax, 2509h							; set original interrupt handler 09h
	int		21h									; uses DS:EDX
	
	pop		ds
	pop		edx
	pop		eax
	
    mov		esp, ebp
    pop		ebp
    ret
ENDP __keyb_uninstallKeyboardHandler

; Keyboard handler (Interrupt function, DO NOT CALL MANUALLY!)
PROC keyboardHandler
	KEY_BUFFER	EQU 60h			; the port of the keyboard buffer
	KEY_CONTROL	EQU 61h			; the port of the keyboard controller
	PIC_PORT	EQU 20h			; the port of the peripheral

	push	eax
	push	ebx
	push	esi
	push	ds
	
	; setup DS for access to data variables
	mov		ax, _DATA
	mov		ds, ax
	
	; handle the keyboard input
	sti							; re-enable CPU interrupts
	in		al, KEY_BUFFER		; get the key that was pressed from the keyboard
	mov		bl, al				; store scan code for later use
	mov		[__keyb_rawScanCode], al	; store the key in global variable
	in		al, KEY_CONTROL		; set the control register to reflect key was read
	or		al, 82h				; set the proper bits to reset the keyboard flip flop
	out		KEY_CONTROL, al		; send the new data back to the control register
	and		al, 7fh				; mask off high bit
	out		KEY_CONTROL, al		; complete the reset
	mov		al, 20h				; reset command
	out		PIC_PORT, al		; tell PIC to re-enable interrupts

	; process the retrieved scan code and update __keyboardState and __keysActive
	; scan codes of 128 or larger are key release codes
	mov		al, bl				; put scan code in al
	shl		ax, 1				; bit 7 is now bit 0 in ah
	not		ah
	and		ah, 1				; ah now contains 0 if key released, and 1 if key pressed
	shr		al, 1				; al now contains the actual scan code ([0;127])
	xor		ebx, ebx	
	mov		bl, al				; bl now contains the actual scan code ([0;127])
	lea		esi, [__keyb_keyboardState + ebx]	; load address of key relative to __keyboardState in ebx
	mov		al, [esi]			; load the keyboard state of the scan code in al
	; al = tracked state (0 or 1) of pressed key (the value in memory)
	; ah = physical state (0 or 1) of pressed key
	neg		al
	add		al, ah				; al contains -1, 0 or +1 (-1 on key release, 0 on no change and +1 on key press)
	add		[__keyb_keysActive], al	; update __keysActive counter
	mov		al, ah
	mov		[esi], al			; update tracked state
	
	pop		ds
	pop		esi
	pop		ebx
	pop		eax
	
	iretd
ENDP keyboardHandler

;=============================================================================
; Uninitialized DATA
;=============================================================================
UDATASEG

;=============================================================================
; DATA
;=============================================================================
DATASEG
	originalKeyboardHandlerS	dw ?			; SELECTOR of original keyboard handler
	originalKeyboardHandlerO	dd ?			; OFFSET of original keyboard handler

	__keyb_keyboardState		db 128 dup(?)	; state for all 128 keys
	__keyb_rawScanCode			db ?			; scan code of last pressed key
	__keyb_keysActive			db ?			; number of actively pressed keys



	sepp db "--------", 10, 13, '$'
	up db "up", 10, 13, '$'
	down db "down", 10, 13, '$'
	left db "left", 10, 13, '$'
	right db "right", 10, 13, '$'

END 