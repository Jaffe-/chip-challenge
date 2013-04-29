;------------------------------------------------------------------------------
; Chip's Challenge
; by Johan Fjeldtvedt / Jaffe
; 
;------------------------------------------------------------------------------
;
; BLOCK COLLISION ROUTINES  
;
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; Collision with solid blocks
;------------------------------------------------------------------------------

Collision_Solid:
	txa
	pha

	; Handle some special cases. If the object in motion is moving on ICE or
	; FORCE floor, the object's speed should NOT be cleared.
	ldx current_object_x
	ldy current_object_y
	jsr GetBlock			; get out block number
	tax
	lda block_types, x		; look up the block's type
	cmp #BLOCK_TYPE_FORCE
	beq @set_zero			
	cmp #BLOCK_TYPE_ICE	
	bne @set_zero			; it's not ice, so the object's speed should be
					; zeroed.

	; In case it's ice, flip the object's speed in its current direction
@flip_speed:
	pla
	tax
	lda object_last_speed, x
	eor #$0F
	clc
	adc #1
	sta object_speed, x
	sta object_last_speed, x
	rts

	; In other cases, the object should stop:
@set_zero:
	pla
	tax
	lda #0
	sta object_speed, x
	rts


;------------------------------------------------------------------------------
; Collision with movable dirt blocks
;------------------------------------------------------------------------------

Collision_Movable:
	txa
	pha
	lda object_speed, x		; bits 45 of object_speed holds the 
	lsr a				; direction which the object is moving 
	lsr a				; in. 
	lsr a
	ldx target_x			; target_x and target_y holds the coordinates
	ldy target_y			; of the movable block.
	jsr GetTargetblock		; get the movable block's target block
	tax
	lda block_types, x		; get its block type
	and #$03			; mask out the solidity bits
	beq @move_block			; if it's zero, it's a empty floor block
	pla
	tax
	jmp Collision_Solid		; if not, it's a solid block and the effect
					; should be as if Chip is colliding with a wall.

@move_block:
	pla
	jsr AllocateObject		; allocate a new object for the moving block metasprite.
	lda target_x			; set the object's position to the same position as the
	sta object_xpos, x		; metatile.
	lda target_y
	sta object_ypos, x
	lda #OBJECT_DIRT_BLOCK		; set object type.
	sta object_type, x
	lda object_speed		; the speed should be the same as Chip's.
	sta object_speed, x
	jsr MoveObject			; MoveObject will set the block in motion. Otherwise it will
					; be deleted and replaced by a metatile during the next 
					; frame by Action_DirtBlock.

	ldx target_x			
	ldy target_y
	jsr GetBlock			; get the block number at the block's position
	txa
	and #$7F			; remove the movable block flag
	ldx target_x
	ldy target_y
	jsr UpdateBlock			; store updated block (and write new metatiles to PPU buffer)
	rts	


;------------------------------------------------------------------------------
; Collision with doors
;------------------------------------------------------------------------------

Collision_Grey_Door:
	lda grey_key_count
	beq No_Key
	dec grey_key_count
	jmp ReplaceFloor

Collision_Red_Door:
	lda red_key_count
	beq No_Key
	dec red_key_count
	jmp ReplaceFloor

Collision_Blue_Door:
	lda blue_key_count
	beq No_Key
	dec blue_key_count
	jmp ReplaceFloor

Collision_Green_Door:
	lda green_key_count
	beq No_Key
	jmp ReplaceFloor

No_Key:
	jmp Collision_Solid

;------------------------------------------------------------------------------
; Collision with a chip socket
;------------------------------------------------------------------------------

Collision_Socket:
	lda chip_count			; get the number of chips _left_ in the level.
	beq @remove_socket		; if it's zero, the socket can be removed.
	jmp Collision_Solid		; otherwise, this is like a solid wall.
@remove_socket:
	jmp ReplaceFloor

;------------------------------------------------------------------------------
; Collision with (solid) blue walls. If a blue wall is touched, it becomes a solid wall.
;------------------------------------------------------------------------------
	
Collision_Blue_Wall:
	cpx #0				; only chip should be able to "reveal" the wall.
	beq @make_solid		
	jmp Collision_Solid		; for other objects, this is a normal solid block.
@make_solid:
	txa				; preserve object type
	pha
	ldx target_x
	ldy target_y
	lda #BLOCK_WALL			; replace the block with a solid wall block.
	jsr UpdateBlock			
	pla
	tax
	jmp Collision_Solid		; run standard solid block collision code.

Collision_Blocked_South:
	lda object_speed, x
	and #$18
	cmp #$18
	bne @ret
	jmp Collision_Solid
@ret:
	rts

Collision_Blocked_East:
	lda object_speed, x
	and #$18
	cmp #$08
	bne @ret
	jmp Collision_Solid
@ret:
	rts

Collision_Blocked_West:
	lda object_speed, x
	and #$18
	cmp #$00
	bne @ret
	jmp Collision_Solid
@ret:
	rts

Collision_Blocked_North:
	lda object_speed, x
	and #$18
	cmp #$10
	bne @ret
	jmp Collision_Solid
@ret:
	rts

;----------------------------------------------------------------------------------------------------
; Time to kill Chip?
; Intended to be run from monster action handlers.
;----------------------------------------------------------------------------------------------------

CheckForChip:
	lda current_object_x
	cmp object_xpos
	bne @return
	lda current_object_y
	cmp object_ypos
	bne @return
	ldx #0
	jsr FreeObject
@return:
	rts

ReplaceFloor:
	ldx target_x
	ldy target_y	
	lda #BLOCK_FLOOR		; replace the block with a floor block.
	jsr UpdateBlock
	rts

