;------------------------------------------------------------------------------
; Chip's Challenge
; by Johan Fjeldtvedt / Jaffe
; 
;------------------------------------------------------------------------------
;
; OBJECT ACTION, COLLISION AND INTERACTION HANDLING
;
;------------------------------------------------------------------------------

Action_DirtBlock:
	txa
	pha
	
	ldx #0
@loop:
	; kill anything in its way
	lda object_xpos, x
	cmp current_object_x
	bne @next
	lda object_ypos, x
	cmp current_object_y
	bne @next
	; ... except stationary items
	lda object_type, x
	cmp #$01
	bmi @next
	cmp #$0A
	bpl @next
	jsr FreeObject
@next:
	txa
	clc
	adc #8
	tax
	bne @loop
		
	ldx current_object_x
	ldy current_object_y
	jsr GetBlock
	cmp #BLOCK_WATER
	bne @not_water
	lda #BLOCK_DIRT
	ldx current_object_x
	ldy current_object_y
	jsr UpdateBlock
	jmp @free
@not_water:
	cmp #BLOCK_FLOOR			; speed up in most cases
	beq @store_block
	cmp #BLOCK_TELEPORT
	beq @return
	tay
	lda block_types, y
	cmp #BLOCK_TYPE_NORMAL
	bne @return
@store_block:
	pla
	pha
	tax	
	lda object_speed, x
	and #$0F
	bne @return
	ldx current_object_x
	ldy current_object_y
	lda #BLOCK_MOVABLE
	jsr UpdateBlock

@free:
	pla
	tax
	jsr FreeObject
	rts
@return:
	pla
	rts

Action_Item:
	lda object_finepos, x
	bne @return
	lda object_xpos, x
	cmp object_xpos
	bne @return
	lda object_ypos, x
	cmp object_ypos
	bne @return
	txa
	pha
	lda object_type, x
	sec
	sbc #2
	tax
	inc item_counts, x
	pla
	tax
	jsr FreeObject
@return:
	rts
	
;Action_Monster_Old:
Action_Monster:
	lda #0
	sta temp3

	lda object_xpos, x
	sec
	sbc object_xpos
	beq @move_vertical
	bpl @store_h
	eor #$FF
	clc
	adc #1
@store_h:
	sta temp2
	lda object_ypos, x
	sec
	sbc object_ypos
	beq @move_horizontal
	bpl @compare
	eor #$FF
	clc
	adc #1
@compare:
	cmp temp2
	bpl @move_vertical

@move_horizontal:
	inc temp3
	lda object_xpos, x
	cmp object_xpos
	bmi @move_right
	lda #$0F
	jmp @set_speed_h
@move_right:
	lda #$01
@set_speed_h:
	sta temp2
	ldy current_object_y
	ldx current_object_x
	lsr a
	lsr a
	lsr a
	jsr GetTargetblock
	tax
	lda block_types, x
	and #$02
	beq @set_speed	
	lda temp3
	cmp #2
	beq @ret

@move_vertical:
	inc temp3
	lda object_ypos, x
	cmp object_ypos
	beq @ret
	bmi @move_down
	lda #$1F
	jmp @set_speed_v
@move_down:
	lda #$11
@set_speed_v:
	sta temp2
	ldy current_object_y
	ldx current_object_x
	lsr a
	lsr a
	lsr a
	jsr GetTargetblock
	tax
	lda block_types, x
	and #$02
	beq @set_speed
	lda temp3
	cmp #2
	beq @ret
	jmp @move_horizontal

@set_speed:
	ldx current_object
	lda temp2
	sta object_last_speed, x
	sta object_speed, x
@ret:	
	jmp CheckForChip
	
Action_Tank:
	lda object_last_speed, x
	bne Action_Generic_Monster
	lda tank_flag
	beq @check_chip	
	lda object_state, x
	tay
	lda down_turns, y
	sta object_last_speed, x
	jmp Action_Generic_Monster
@return:	
	rts

@check_chip:
	jmp CheckForChip

Action_Generic_Monster:
	lda object_type, x
	sec
	sbc #OBJECT_BALL
	and #$07
	asl a
	asl a
	tay
	stx temp2
	lda object_last_speed, x
	bne @move
	jmp @set_speed
@move:
	lsr a
	lsr a
	lsr a
	sta temp3
	tya
	tax
@loop:
	tya
	pha
	txa
	pha
	lda priority_lists, x
	ora temp3
	tax
	lda turns, x
	ldx temp2
	sta object_speed, x
	jsr ObjectCollision
	lda object_speed, x
	bne @do_move
	pla 
	tax
	pla
	tay
	inx
	sta temp
	txa
	sec
	sbc temp
	cmp #4
	bne @loop
	ldx temp2
	lda object_last_speed, x
	sta object_speed, x
	jmp @ret
	
@do_move:
	pla 
	pla
	
@ret:
	jmp CheckForChip
	
@set_speed:
	lda object_state, x
	asl a
	asl a
	asl a
	sta object_speed, x
	jmp @move

