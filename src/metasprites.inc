;------------------------------------------------------------------------------
; Chip's Challenge
; by Johan Fjeldtvedt / Jaffe
; 
;------------------------------------------------------------------------------
;
; METASPRITE / OBJECT DEFINITIONS
;
;------------------------------------------------------------------------------


metasprite_directions:
	.word metasprites_right
	.word metasprites_left
	.word metasprites_down
	.word metasprites_up

metasprites_right:
	.byte 0,0,0,0
	.byte 33,34,35,36				; Chip
	.byte 1,2,3,4					; key
	.byte 1,2,3,4					; key
	.byte 1,2,3,4					; key
	.byte 1,2,3,4					; key
	.byte 13,14,15,16				; fire shoes
	.byte 13,14,17,18				; ice shoes
	.byte 13,14,19,20				; suction shoes
	.byte 21,22,23,24				; swim feet
	.byte 5,6,7,8					; block
	.byte 121,122,123,124				; monster
	.byte 29,30,31,32				; ball
	.byte 89,90,91,92				; tank
	.byte 65,66,67,68				; bee
	.byte 45,46,47,48				; bug
	.byte 49,50,51,52				; glider
	.byte 125,126,127,128				; fireball
	.byte 129,130,131,132

metasprites_left:
	.byte 0,0,0,0
	.byte 37,38,39,40				; Chip 
	.byte 1,2,3,4					; key
	.byte 1,2,3,4					; key
	.byte 1,2,3,4					; key
	.byte 1,2,3,4					; key
	.byte 13,14,15,16				; fire shoes
	.byte 13,14,17,18				; ice shoes
	.byte 13,14,19,20				; suction shoes
	.byte 21,22,23,24				; swim feet
	.byte 5,6,7,8					; block
	.byte 113,114,115,116				; monster
	.byte 29,30,31,32				; ball
	.byte 93,94,95,96				; tank
	.byte 69,70,71,72				; bee
	.byte 45,46,47,48				; bug
	.byte 53,54,55,56				; glider
	.byte 125,126,127,128				; fireball
	.byte 129,130,131,132
	
metasprites_down:
	.byte 0,0,0,0
	.byte 9,10,11,12				; Chip
	.byte 1,2,3,4					; key
	.byte 1,2,3,4					; key
	.byte 1,2,3,4					; key
	.byte 1,2,3,4					; key
	.byte 13,14,15,16				; fire shoes
	.byte 13,14,17,18				; ice shoes
	.byte 13,14,19,20				; suction shoes
	.byte 21,22,23,24				; swim feet
	.byte 5,6,7,8					; block
	.byte 117,118,119,120				; monster
	.byte 29,30,31,32				; ball
	.byte 85,86,87,88				; tank
	.byte 77,78,79,80				; bee
	.byte 25,26,27,28				; bug
	.byte 57,58,59,60				; glider
	.byte 125,126,127,128				; fireball
	.byte 129,130,131,132

metasprites_up:
	.byte 0,0,0,0
	.byte 41,42,43,44				; Chip
	.byte 1,2,3,4					; key
	.byte 1,2,3,4					; key
	.byte 1,2,3,4					; key
	.byte 1,2,3,4					; key
	.byte 13,14,15,6				; fire shoes
	.byte 13,14,17,18				; ice shoes
	.byte 13,14,19,20				; suction shoes
	.byte 21,22,23,24				; swim feet
	.byte 5,6,7,8
	.byte 109,110,111,112				; monster
	.byte 29,30,31,32				; ball
	.byte 81,82,83,84				; tank
	.byte 73,74,75,76				; bee
	.byte 25,26,27,28				; bug
	.byte 61,62,63,64				; glider
	.byte 125,126,127,128				; fireball
	.byte 129,130,131,132

sprite_palettes:
	.byte 0
	.byte BLUE						
	.byte GREY
	.byte BLUE
	.byte RED
	.byte GREEN
	.byte RED
	.byte BLUE
	.byte GREEN
	.byte BLUE
	.byte RED
	.byte GREEN					; monster
	.byte RED					; ball
	.byte BLUE					; tank
	.byte RED					; bee
	.byte GREEN					; bug
	.byte BLUE					; glider
	.byte RED					; fireball
	.byte GREEN

action_routines:
	.word 0
	.word 0
	.word Action_Item
	.word Action_Item
	.word Action_Item
	.word Action_Item
	.word Action_Item
	.word Action_Item
	.word Action_Item
	.word Action_Item
	.word Action_DirtBlock
	.word Action_Monster
	.word Action_Generic_Monster
	.word Action_Tank
	.word Action_Generic_Monster
	.word Action_Generic_Monster
	.word Action_Generic_Monster
	.word Action_Generic_Monster
	.word Action_Monster
