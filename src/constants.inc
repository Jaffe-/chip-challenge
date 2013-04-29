;------------------------------------------------------------------------------
; Chip's Challenge
; by Johan Fjeldtvedt / Jaffe
;
;------------------------------------------------------------------------------
;
; CONSTANT DEFINITIONS
;
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; CHARACTERS
;------------------------------------------------------------------------------

			 

;------------------------------------------------------------------------------
; SYSTEM ADDRESSES
;------------------------------------------------------------------------------

PPUCTRL				= $2000
PPUMASK				= $2001
PPUSTATUS			= $2002
PPUSCROLL			= $2005
PPUADDR				= $2006
PPUDATA				= $2007

;------------------------------------------------------------------------------
; CONSTANTS
;------------------------------------------------------------------------------

RIGHT				= $00
LEFT 				= $40
DOWN				= $80
UP				= $C0

STATIONARY			= $80

SPEED_MONSTER_RIGHT 		= $04
SPEED_MONSTER_LEFT		= $0C
SPEED_MONSTER_DOWN		= $14
SPEED_MONSTER_UP		= $1C

GREY 				= $00
BLUE				= $01
RED				= $02
GREEN				= $03

BLOCK_FLOOR			= $00
BLOCK_WALL			= $01
BLOCK_CHIP			= $02
BLOCK_WATER			= $03
BLOCK_FIRE			= $04
BLOCK_MOVABLE			= $0A
BLOCK_DIRT			= $0B
BLOCK_FORCE_UP 			= $12
BLOCK_FORCE_DOWN		= $0D
BLOCK_TOGGLE_CLOSED		= $25
BLOCK_TOGGLE_OPEN		= $26
BLOCK_CLONE_MACHINE		= $31
BLOCK_TELEPORT			= 41
BLOCK_BOMB			= 42


; block type format: TTTDDDSS
; T = special surface flag
; 100 = fire
; 101 = ice
; 110 = force
; 111 = water
; D = door flag
; 100 = grey
; 101 = blue
; 110 = red
; 111 = green
; S = solidity: N values:
; 00 = non solid
; 10 = solid for all
; 11 = solid for objects except chip

BLOCK_TYPE_NORMAL		= $00
BLOCK_TYPE_SOLID		= $01
BLOCK_TYPE_ROUTINE		= $02
BLOCK_TYPE_SOLID_EXCEPT_CHIP	= $03
BLOCK_TYPE_FIRE			= $80
BLOCK_TYPE_ICE			= $A0
BLOCK_TYPE_FORCE		= $C0
BLOCK_TYPE_WATER		= $E0
BLOCK_TYPE_GREY_DOOR		= $13
BLOCK_TYPE_BLUE_DOOR		= $17
BLOCK_TYPE_RED_DOOR		= $1B
BLOCK_TYPE_GREEN_DOOR		= $1F

OBJECT_CHIP 			= $01
OBJECT_GREY_KEY 		= $02
OBJECT_BLUE_KEY 		= $03
OBJECT_RED_KEY 			= $04
OBJECT_GREEN_KEY 		= $05
OBJECT_FIRE_SHOE 		= $06
OBJECT_ICE_SKATE 		= $07
OBJECT_SUCTION_SHOE 		= $08
OBJECT_FLIPPER			= $09
OBJECT_DIRT_BLOCK		= $0A
OBJECT_MONSTER			= $0B
OBJECT_BALL			= $0C
OBJECT_TANK			= $0D
OBJECT_BEE			= $0E
OBJECT_BUG			= $0F
OBJECT_GLIDER			= $10
OBJECT_FIREBALL			= $11

STATUS_INIT			= $00
STATUS_GAME			= $01

INDEX_CHIP 			= $00

BUFFER_STATE_BG_UPDATE_1	= 0
BUFFER_STATE_BG_UPDATE_2	= 1

