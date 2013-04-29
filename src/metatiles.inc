;------------------------------------------------------------------------------
; Chip's Challenge
; by Johan Fjeldtvedt / Jaffe
; 
;------------------------------------------------------------------------------
;
; METATILE / BLOCK DEFINITIONS
;
;------------------------------------------------------------------------------


metatile_offsets:
	.byte 4							; empty tile
	.byte 0							; wall
	.byte 8							; chip
	.byte 12						; water
	.byte 72						; fire
	.byte 4							; invisible wall
	.byte 80						; blocked north
	.byte 84						; blocked west
	.byte 92						; blocked south
	.byte 76						; blocked east
	.byte 0							; movable dirt block
	.byte 68						; dirt in water
	.byte 20						; ice
	.byte 32						; force south
	.byte 0							; cloning block north
	.byte 0							; cloning block west
	.byte 0							; cloning block south
	.byte 0							; cloning block east
	.byte 16						; force north
	.byte 36						; force east
	.byte 40						; force west
	.byte 64						; exit
	.byte 24						; blue door
	.byte 24						; red door
	.byte 24						; green door
	.byte 24						; yellow door
	.byte 44						; ice - south / east
	.byte 52						; ice - south / west
	.byte 56						; ice - north / west
	.byte 48						; ice - north / east
	.byte 0							; blue block becomes tile
	.byte 0							; blue block becomes wall
	.byte 4							; -- background for items --
	.byte 156						; thief
	.byte 28						; chip socket
	.byte 104						; green button
	.byte 104						; red button
	.byte 132						; switch block, closed				37 (100101)
	.byte 128						; switch block, open				38 (100110)
	.byte 104						; brown button
	.byte 104						; blue button
	.byte 100						; teleport
	.byte 144						; bomb ( TNT)
	.byte 140						; trap
	.byte 4							; invisible wall (appears)
	.byte 96						; gravel
	.byte 136						; pass once
	.byte 60						; hint
	.byte 0							; blocked south
	.byte 108						; cloning machine
	.byte 0							; force all directions

block_palettes:
	.byte GREY
	.byte GREY
	.byte GREY
	.byte BLUE
	.byte RED
	.byte GREY
	.byte GREY
	.byte GREY
	.byte GREY
	.byte GREY
	.byte RED
	.byte RED
	.byte BLUE
	.byte GREEN
	.byte GREY
	.byte GREY
	.byte GREY
	.byte GREY
	.byte GREEN
	.byte GREEN
	.byte GREEN
	.byte BLUE
	.byte BLUE
	.byte RED
	.byte GREEN
	.byte GREY
	.byte BLUE
	.byte BLUE
	.byte BLUE
	.byte BLUE
	.byte BLUE
	.byte BLUE
	.byte GREY
	.byte BLUE
	.byte GREY
	.byte GREEN
	.byte RED
	.byte GREEN
	.byte GREEN
	.byte GREY						; button brown
	.byte BLUE						; button blue
	.byte BLUE						; teleport
	.byte RED						; bomb
	.byte GREY						; trap
	.byte GREY
	.byte GREY
	.byte GREY
	.byte GREY
	.byte GREY
	.byte GREY
	.byte GREEN

block_types:
	.byte BLOCK_TYPE_NORMAL
	.byte BLOCK_TYPE_SOLID
	.byte BLOCK_TYPE_SOLID_EXCEPT_CHIP
	.byte BLOCK_TYPE_WATER
	.byte BLOCK_TYPE_FIRE
	.byte BLOCK_TYPE_SOLID
	.byte BLOCK_TYPE_ROUTINE
	.byte BLOCK_TYPE_ROUTINE
	.byte BLOCK_TYPE_ROUTINE
	.byte BLOCK_TYPE_ROUTINE
	.byte BLOCK_TYPE_SOLID_EXCEPT_CHIP
	.byte BLOCK_TYPE_SOLID_EXCEPT_CHIP
	.byte BLOCK_TYPE_ICE
	.byte BLOCK_TYPE_FORCE
	.byte BLOCK_TYPE_NORMAL
	.byte BLOCK_TYPE_NORMAL
	.byte BLOCK_TYPE_NORMAL
	.byte BLOCK_TYPE_NORMAL
	.byte BLOCK_TYPE_FORCE
	.byte BLOCK_TYPE_FORCE
	.byte BLOCK_TYPE_FORCE
	.byte BLOCK_TYPE_NORMAL
	.byte BLOCK_TYPE_SOLID_EXCEPT_CHIP
	.byte BLOCK_TYPE_SOLID_EXCEPT_CHIP
	.byte BLOCK_TYPE_SOLID_EXCEPT_CHIP
	.byte BLOCK_TYPE_SOLID_EXCEPT_CHIP
	.byte BLOCK_TYPE_ICE
	.byte BLOCK_TYPE_ICE
	.byte BLOCK_TYPE_ICE
	.byte BLOCK_TYPE_ICE
	.byte BLOCK_TYPE_NORMAL
	.byte BLOCK_TYPE_SOLID_EXCEPT_CHIP
	.byte BLOCK_TYPE_SOLID_EXCEPT_CHIP
	.byte BLOCK_TYPE_SOLID_EXCEPT_CHIP
	.byte BLOCK_TYPE_SOLID_EXCEPT_CHIP
	.byte BLOCK_TYPE_NORMAL
	.byte BLOCK_TYPE_NORMAL
	.byte BLOCK_TYPE_SOLID
	.byte BLOCK_TYPE_NORMAL
	.byte BLOCK_TYPE_NORMAL
	.byte BLOCK_TYPE_NORMAL
	.byte BLOCK_TYPE_NORMAL
	.byte BLOCK_TYPE_NORMAL
	.byte BLOCK_TYPE_NORMAL
	.byte BLOCK_TYPE_SOLID_EXCEPT_CHIP
	.byte BLOCK_TYPE_SOLID_EXCEPT_CHIP
	.byte BLOCK_TYPE_NORMAL
	.byte BLOCK_TYPE_NORMAL
	.byte BLOCK_TYPE_NORMAL
	.byte BLOCK_TYPE_SOLID
	.byte BLOCK_TYPE_FORCE

interaction_routines:
	.word 0
	.word 0
	.word Interaction_Chip
	.word Interaction_Water
	.word Interaction_Fire
	.word 0
	.word Interaction_Blocked_North
	.word Interaction_Blocked_West
	.word Interaction_Blocked_South
	.word Interaction_Blocked_East
	.word 0
	.word Interaction_MakeTile
	.word Interaction_Ice
	.word Interaction_ForceDown
	.word 0
	.word 0
	.word 0
	.word 0
	.word Interaction_ForceUp
	.word Interaction_ForceRight
	.word Interaction_ForceLeft
	.word Interaction_Exit
	.word 0
	.word 0
	.word 0
	.word 0
	.word Interaction_IceUpRight
	.word Interaction_IceUpLeft
	.word Interaction_IceDownLeft
	.word Interaction_IceDownRight
	.word Interaction_MakeTile
	.word 0
	.word Interaction_MakeTile
	.word Interaction_Thief
	.word 0
	.word Interaction_Green_Button
	.word Interaction_Red_Button
	.word 0
	.word 0
	.word 0 
	.word Interaction_Blue_Button
	.word Interaction_Teleport
	.word Interaction_Bomb
	.word Interaction_Trap
	.word 0
	.word 0
	.word Interaction_Pass_Once
	.word 0
	.word 0
	.word Interaction_Clone_Machine
	.word 0	

collision_routines:
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word Collision_Blocked_North
	.word Collision_Blocked_West
	.word Collision_Blocked_South
	.word Collision_Blocked_East
	.word Collision_Movable
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word Collision_Blue_Door
	.word Collision_Red_Door
	.word Collision_Green_Door
	.word Collision_Grey_Door
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word Collision_Blue_Wall
	.word 0
	.word 0
	.word Collision_Socket
	.word 0
	.word 0
	.word 0 
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word Collision_Blue_Wall
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0	
