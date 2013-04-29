;------------------------------------------------------------------------------
; Chip's Challenge
; by Johan Fjeldtvedt / Jaffe
; 
;------------------------------------------------------------------------------
;
; LEVELS
;
;------------------------------------------------------------------------------

LevelList: 
	.word level1
	.word level2
	.word level3
	.word level4
	.word level5
	.word level6
	.word level7
	.word level8

;--------------------------------------------------------------------------------

tests:
	.incbin "level20.bin"

level1:
	.incbin "level1.bin"
	.byte 0
level2:
	.incbin "level2.bin"
	.byte 0
level3:
	.incbin "level3.bin"
	.byte 0
level4:
	.incbin "level4.bin"
	.byte 0
level5:
	.incbin "level5.bin"
	; TRAP, BUTTON 
	.byte 18,07,16,07
	.byte 18,10,16,10
level6:
	.incbin "level6.bin"

level7:
	.incbin "level7.bin"
	;.byte 0, 0, 0, 0, 0, 0, 0, 0
	.byte 17, 16
	.byte 15, 16
	.byte 17, 14
	.byte 15, 14

level8:
	.incbin "level8.bin"

level9:
	.incbin "level9.bin"
	.byte 27,03,28,05
level11:
	.incbin "level11.bin"
level14:
	.incbin "level14.bin"

level15:	
	.incbin "level15.bin"
level21:
	.incbin "level21.bin"
level24:
	.incbin "level24.bin"
level34:
	.incbin "level34.bin"
level42:
	.incbin "level42.bin"
