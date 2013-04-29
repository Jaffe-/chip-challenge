;------------------------------------------------------------------------------
; Chip's Challenge
; by Johan Fjeldtvedt / Jaffe
; 
;------------------------------------------------------------------------------
;
; OBJECT ACTION, COLLISION AND INTERACTION HANDLING
;
;------------------------------------------------------------------------------

ObjectAction:
	txa
	pha
	
	; first, run object specific stuff
	lda object_speed, x
	and #$0F
	bne @return
	lda object_type, x
	asl a
	tax
	lda action_routines+1, x
	beq @return
	sta action_address+1
	lda action_routines, x
	sta action_address
	
	lda #>@return
	pha
	lda #<(@return - 1)
	pha
	ldx current_object
	jmp (action_address)

@return:
	pla
	tax
	rts
	
ObjectInteraction:
	txa
	pha
	
	ldx current_object_x
	ldy current_object_y
	jsr GetBlock
	sta current_block
	tax

	lda current_object
	bne @run_routine
	lda block_types, x
	rol a
	bcc @run_routine
	rol a
	rol a
	rol a
	and #$03
	tay
	lda shoe_counts, y
	bne @return

@run_routine:
	txa
	asl a
	tay
	lda interaction_routines+1, y
	beq @return
	sta action_address+1
	lda interaction_routines, y
	sta action_address
	lda #>@return
	pha
	lda #<(@return - 1)
	pha
	tya
	lsr a
	tay
	ldx current_object
	jmp (action_address)

@return:
	pla
	tax
	rts

ObjectCollision:
	txa
	pha

	lda object_speed, x
	beq @return
	lsr a
	lsr a
	lsr a
	ldx current_object_x
	ldy current_object_y
	jsr GetTargetblock
	sty target_y
	stx target_x
	sta target_block
	tax
	lda block_types, x
	and #$03
	beq @no_collision
	cmp #BLOCK_TYPE_SOLID
	beq @solid
	cmp #BLOCK_TYPE_ROUTINE
	beq @run_routine
	lda current_object
	bne @solid

@run_routine:
	lda target_block
	asl a
	tax
	lda collision_routines+1,x
	beq @return
	sta action_address+1
	lda collision_routines, x
	sta action_address
	lda #>@return
	pha
	lda #<(@return - 1)
	pha
	ldx current_object
	jmp (action_address)

@solid:
	ldx current_object
	jsr Collision_Solid
	jmp @return

@no_collision:
	
@return:
	pla
	tax
	rts

Blue_Button_Handler:
	lda blue_button_count
	pha
	ror a
	ror a
	ror a
	ror a
	and #$0F
	sta temp
	pla
	and #$0F
	cmp temp
	beq @set_zero
	lda blue_button_count
	and #1
	beq @set_zero
	lda #1
	sta tank_flag
	jmp @shift_count
@set_zero:
	lda #0
	sta tank_flag

@shift_count:
	asl blue_button_count
	asl blue_button_count
	asl blue_button_count
	asl blue_button_count
	rts

Red_Button_Handler:
	lda red_button_count
	pha
	ror a
	ror a
	ror a
	ror a
	and #$0F
	sta temp
	pla
	and #$0F
	cmp temp
	beq @set_zero
	lda red_button_count
	and #1
	beq @set_zero
	lda #1
	sta cloner_active
	jmp @shift_count
@set_zero:
	lda #0
	sta cloner_active

@shift_count:
	asl red_button_count
	asl red_button_count
	asl red_button_count
	asl red_button_count
	rts

Green_Button_Handler:
	lda green_button_count
	pha
	ror a
	ror a
	ror a
	ror a
	and #$0F
	sta temp
	pla
	and #$0F
	cmp temp
	beq @shift_count
	lda green_button_count
	and #1
	beq @shift_count
	lda #(>bg_tiles + 8)
	sta tempaddr+1
	lda #<bg_tiles
	ora toggle_status
	sta tempaddr
	ldy #64
	ldx #0
@l1:	
	lda (tempaddr), y
	sta buffer+64, x
	inx
	dey
	bne @l1

	lda toggle_status
	eor #$40
	sta toggle_status
	ora #<bg_tiles
	sta tempaddr
	ldy #64
	ldx #0
@l2:
	lda (tempaddr), y
	sta buffer, x
	inx
	dey
	bne @l2

	lda #3
	sta buffer_flag	

	lda #>map
	sta tempaddr+1
	lda #<map
	sta tempaddr
	ldx #4
	ldy #0
@l3:
	lda (tempaddr),y
	cmp #BLOCK_TOGGLE_OPEN
	bne @store_open
	lda #BLOCK_TOGGLE_CLOSED
	jmp @store
@store_open:
	cmp #BLOCK_TOGGLE_CLOSED
	bne @next
	lda #BLOCK_TOGGLE_OPEN
@store:
	sta (tempaddr),y
@next:
	iny
	bne @l3
	inc tempaddr+1
	dex
	bne @l3 

@shift_count:
	asl green_button_count
	asl green_button_count
	asl green_button_count
	asl green_button_count
	rts
