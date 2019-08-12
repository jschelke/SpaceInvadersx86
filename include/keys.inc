GLOBAL	isKeypressed:PROC, \
        __keyb_installKeyboardHandler:PROC, \
        __keyb_uninstallKeyboardHandler:PROC

GLOBAL __keyb_keyboardState:BYTE:128
GLOBAL __keyb_rawScanCode:BYTE
GLOBAL __keyb_keysActive:BYTE



;-------------------------------------------------------------------
; Scancodes
;   see: http://www.ee.bgu.ac.il/~microlab/MicroLab/Labs/ScanCodes.htm
;        https://www.win.tue.nl/~aeb/linux/kbd/scancodes-1.html
;-------------------------------------------------------------------