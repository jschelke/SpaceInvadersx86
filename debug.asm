IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

;=============================================================================
; INCLUDES
;=============================================================================
include "globals.inc"
include "debug.inc"

;=============================================================================
; CODE
;=============================================================================
CODESEG

PROC printInteger
	ARG @@num:dword
	USES eax, ebx, ecx, edx

	mov eax, [@@num]	; eax holds input integer
	mov ebx, 10		; divider
	xor ecx, ecx	; counter for digit to be printed

	cmp eax, 0
	jge @@positiveNumber ; print a '-' if negative, skip otherwise
		mov edx, -1
		mul edx
		push eax
		mov ah, 2h
		mov dl, '-'
		int 21h
		pop eax
	@@positiveNumber:

	;store digit on stack
	@@getNextDigit:
		inc ecx			; increase digit counter
		xor edx, edx
		div ebx			; divide by 10
		push dx			; store remainder on stack
		test eax, eax	; check wheter zero?
		jnz @@getNextDigit

		; Write all digits to the standard output
		mov ah, 2h		; function for printing single characters

	@@printDigit:
		pop dx
		add dl, '0'		; add 30h => code for a digit in the ascii table
		int 21h			; print the digit to the screen
		loop @@printDigit	; until diit counter = 0

		mov dl, 0Dh		; carriage return
		int 21h
		mov dl, 0Ah		; new line
		int 21h

	ret
ENDP printInteger

PROC printIntList
	ARG @@arrpointer:dword, @@arrlen:dword
	USES eax, ebx, ecx, edx

	mov eax, [@@arrlen]
	mov ecx, [eax]
	xor edx, edx
    mov eax, [@@arrpointer]

	@@arrloop: 
		call printInteger, [dword ptr eax + 4*edx]
		inc edx
	loop @@arrloop

	ret
ENDP printIntList

; Print string. String must be terminated with '$'
PROC printString
	ARG @@stringPointer:dword
	USES eax, edx

	mov ah, 09h
	mov edx, [@@stringPointer]
	int 21h

	ret
ENDP

;=============================================================================
; Uninitialized DATA
;=============================================================================
UDATASEG

;=============================================================================
; DATA
;=============================================================================
DATASEG

END 