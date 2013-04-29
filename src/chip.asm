;------------------------------------------------------------------------------
; Chip's Challenge
; by Johan Fjeldtvedt / Jaffe
; 
;------------------------------------------------------------------------------
;
; TOP LEVEL VARIABLE AND DATA DEFINITIONS
;
;------------------------------------------------------------------------------


.include "constants.inc"

.segment "INES"
	.byte "NES",$1A,2,0,9

.segment "VECTORS"
	.word NMI,Start,0

;------------------------------------------------------------------------------
; Variables
;------------------------------------------------------------------------------

.segment "ZEROPAGE"

; PPU buffer (at most 64 bytes bytes)
buffer: .res $80

current_level: .byte 0

; PPU addresses used in buffer writes
ppu_low: .byte 0
ppu_high: .byte 0

; Two pointers for indirect addressing
map_ptr: .word 0
ram_ptr: .word 0
teleport_ptr: .word 0

; Flips between upper (0) and lower (2) row of tiles in a block / metatile
tile_offset: .byte 0

; The currently active nametable (PPU base address)
active_nt: .byte 0

; Scrolling
hscroll: .byte 0
vscroll: .byte 0
scroll_flag: .byte 0

; VBLank flag
vblank_flag: .byte 0
col: .byte 0
colr: .byte 0

toggle_status: .byte 0

; Buffer variables
buffer_flag: .byte 0
buffer_pointer: .byte 0
buffer_mask: .byte 0

; Temporary variables used by various routines
temp: .byte 0
temp2: .byte 0
temp3: .byte 0
tempaddr: .word 0

t: .byte 0

chip_direction_counter: .byte 0

force_flag: .byte 0

; Input
direction: .byte 0

; Points to next free sprite in SPR-RAM
sprite_pointer: .byte 0

; Holds the coordinate of the upper left visible block
visible_x: .byte 0
visible_y: .byte 0

; Object handler variables
object_count: .byte 0
current_object_x: .byte 0
current_object_y: .byte 0
current_block: .byte 0
current_object: .byte 0
object_clear_flag: .byte 0

; Action handler variables
action_address: .word 0
handler_address: .word 0

target_x: .byte 0
target_y: .byte 0
target_block: .byte 0

status: .byte 0

cloner_active: .byte 0

tank_flag: .byte 0

objects_left: .byte 0

skipped_force_flag: .byte 0


; - LEVEL SPECIFIC VARIABLES
; --------------------------

level_variables:

; Number of chips left
chip_count: .byte 0

trap_count: .byte 0
teleport_count: .byte 0


; Items
item_counts:
key_counts:
grey_key_count: .byte 0
blue_key_count: .byte 0
red_key_count: .byte 0
green_key_count: .byte 0

shoe_counts:
fire_shoes: .byte 0
ice_skates: .byte 0
suction_shoes: .byte 0
flippers: .byte 0

blue_button_count: .byte 0
green_button_count: .byte 0
red_button_count: .byte 0


.segment "OBJECTS"
	; Object data structure
object_data:
object_xpos: .byte 0			; rough block position
object_ypos: .byte 0			
object_type: .byte 0			; IIITTTTT
object_finepos: .byte 0			; pixel-position between blocks
object_speed: .byte 0			; 000DSSSS (D = 0 = horiz.)
object_frame: .byte 0			; animation frame
object_last_speed: .byte 0
object_state: .byte 0			; used by object handlers

.segment "OAM"
	; RAM mirror of SPRRAM
SPRRAM:
SPRRAM_y: .byte 0
SPRRAM_t: .byte 0
SPRRAM_a: .byte 0
SPRRAM_x: .byte 0

.segment "MAP"
	; Decoded map in memory 32x32
map: .byte 0


.segment "CODE"

;------------------------------------------------------------------------------

	.include "main.asm"
	.include "map.asm"
	.include "nametables.asm"
	.include "objects.asm"
	.include "levels.asm"
	.include "handlers.asm"
	.include "action.asm"
	.include "collision.asm"
	.include "interaction.asm"
	.include "nmi.asm"

;------------------------------------------------------------------------------

.segment "DATA"

palette:
	.byte 0,$00,$10,$20			; blocks
	.byte 0,$11,$21,$31			; ice,water ($31)
	.byte 0,$06,$16,$26			; fire
	.byte 0,$1A,$2A,$20			; ... slide things

	.byte $0E,$3D,$2D,$20			; grey
	.byte $00,$11,$2C,$20			; blue
	.byte $00,$06,$16,$38			; red
	.byte $00,$0A,$1A,$3D			; green

	.include "metatiles.inc"
	.include "metasprites.inc"

priority_lists:

ball_priority:
	.byte up_turns - turns
	.byte down_turns - turns
	.byte down_turns - turns
	.byte down_turns - turns

tank_priority:
	.byte up_turns - turns
	.byte up_turns - turns
	.byte up_turns - turns
	.byte up_turns - turns

bee_priority:
	.byte left_turns - turns
	.byte up_turns - turns
	.byte right_turns - turns
	.byte down_turns - turns
	
bug_priority:
	.byte right_turns - turns
	.byte up_turns - turns
	.byte left_turns - turns
	.byte down_turns - turns

glider_priority:
	.byte up_turns - turns
	.byte left_turns - turns
	.byte right_turns - turns
	.byte down_turns - turns

fireball_priority:
	.byte up_turns - turns
	.byte right_turns - turns
	.byte left_turns - turns
	.byte down_turns - turns
	
turns:
left_turns:
	.byte SPEED_MONSTER_UP			; RIGHT -> UP
	.byte SPEED_MONSTER_DOWN		; LEFT -> DOWN 
	.byte SPEED_MONSTER_RIGHT		; DOWN -> RIGHT
	.byte SPEED_MONSTER_LEFT		; UP -> LEFT
	
up_turns:
	.byte SPEED_MONSTER_RIGHT
	.byte SPEED_MONSTER_LEFT
	.byte SPEED_MONSTER_DOWN
	.byte SPEED_MONSTER_UP
	
right_turns:
	.byte SPEED_MONSTER_DOWN		; RIGHT -> DOWN
	.byte SPEED_MONSTER_UP			; LEFT -> UP
	.byte SPEED_MONSTER_LEFT		; DOWN -> LEFT
	.byte SPEED_MONSTER_RIGHT		; UP -> RIGHT

down_turns:
	.byte SPEED_MONSTER_LEFT
	.byte SPEED_MONSTER_RIGHT
	.byte SPEED_MONSTER_UP
	.byte SPEED_MONSTER_DOWN

	; GRAPHICS
	.segment "GFX"
bg_tiles:
	.incbin "chip.chr"
spr_tiles:
	.incbin "chip.spr"

