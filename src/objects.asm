;------------------------------------------------------------------------------
; Chip's Challenge
; by Johan Fjeldtvedt / Jaffe
; 
;------------------------------------------------------------------------------
;
; OBJECT (METASPRITE) HANDLING
;
;------------------------------------------------------------------------------



;------------------------------------------------------------------------------
; HandleObjects
; Loops through the object list and checks object state, moves them, draws them, etc@
;------------------------------------------------------------------------------

HandleObjects:
	ldx #0
	txa
@clear_sprites:
	sta SPRRAM, x
	dex
	bne @clear_sprites
	lda #0
	sta sprite_pointer

	lda #<ObjectAction
	sta handler_address
	lda #>ObjectAction
	sta handler_address+1
	jsr ActionLoop

	lda #<ObjectInteraction
	sta handler_address
	lda #>ObjectInteraction
	sta handler_address+1
	jsr ActionLoop

	jsr Blue_Button_Handler
	jsr Red_Button_Handler
	jsr Green_Button_Handler

	lda #<ObjectCollision
	sta handler_address
	lda #>ObjectCollision
	sta handler_address+1
	jsr ActionLoop

	lda object_count
	sta objects_left
	ldx #0
move_draw_loop:
	stx temp2
	lda object_type, x
	beq @next_object
	lda object_last_speed, x
	bne @ok
	lda object_ypos, x
	tay
	lda object_xpos, x
	tax
	jsr GetBlock
	ldx temp2
	cmp #BLOCK_CLONE_MACHINE
	bne @ok
	lda #0
	sta object_speed, x
@ok:
	jsr MoveObject
	jsr DrawObject

	dec objects_left

@next_object:
	txa
	clc
	adc #8
	tax
	lda objects_left
	bne move_draw_loop
	
@return:	
	rts

Test:
	ldx #8
@l:
	lda object_type, x
	cmp #$0A
	bmi @next
	lda object_xpos, x
	cmp object_xpos
	bne @next
	lda object_ypos, x
	cmp object_ypos
	bne @next
	ldx #0
	jsr FreeObject
	jmp @ret
@next:
	txa
	clc
	adc #8
	tax
	bne @l

@ret:
	rts



;------------------------------------------------------------------------------
; ActionLoop
;
; Loops through the object list and runs a desired handler function on each 
; suitable object. The handler's address is stored in handler_address. 
;------------------------------------------------------------------------------

ActionLoop:
	lda object_count
	sta objects_left
	ldx #0
@loop:
	stx current_object
	lda object_type, x
	beq @next
	lda object_finepos, x
	and #$0F
	bne @moving
	lda #>@moving
	pha
	lda #<(@moving - 1)
	pha
	lda object_ypos, x
	sta current_object_y
	lda object_xpos, x
	sta current_object_x

	jmp (handler_address)

@moving:
	dec objects_left

@next:
	txa
	clc
	adc #8
	tax
	lda objects_left
	bne @loop
	rts

;------------------------------------------------------------------------------
; DrawObject
; Draw an objcet (store sprite data in SPRRAM) if it's within the visible area
;------------------------------------------------------------------------------

DrawObject:
	txa
	pha
	
	stx temp
		
	; is the object hidden under a movable block?
	lda object_ypos, x
	tay
	lda object_xpos, x
	tax
	jsr GetBlock
	cmp #$0A
	beq @return					; yes, don't bother drawing it

	ldx temp
	lda visible_x
	cmp object_xpos, x
	beq @check_right
	bcs @return
@check_right:
	clc
	adc #15
	cmp object_xpos, x
	bmi @return
	lda visible_y
	cmp object_ypos, x
	beq @check_lower
	bcs @return
@check_lower:
	clc
	adc #14
	cmp object_ypos, x
	bmi @return
	
	jsr StoreSprites
	
@return:
	pla
	tax
	rts

;------------------------------------------------------------------------------
; StoreSprites
; Stores object in SPRRAM and calculates position on screen
;------------------------------------------------------------------------------

StoreSprites:
	lda object_speed, x
	sta temp
	and #$07
	bne @moving
	lda object_state, x
	asl a
	asl a
	asl a
	sta temp
@moving:
	lda temp
	lsr a
	lsr a
	and #$6
	tay
	lda metasprite_directions,y
	sta tempaddr
	lda metasprite_directions+1,y
	sta tempaddr+1

	; DRAW	
	txa
	pha
	lda object_type, x
	and #$7F
	sta temp
	tax
	ldy sprite_pointer
	lda sprite_palettes, x
	sta SPRRAM_a, y
	sta SPRRAM_a+4, y
	sta SPRRAM_a+8, y
	sta SPRRAM_a+12, y
	
	tya
	tax
	lda temp
	asl a
	asl a
	tay
	lda (tempaddr), y
	sta SPRRAM_t, x
	iny
	lda (tempaddr), y
	sta SPRRAM_t+4, x
	iny
	lda (tempaddr), y
	sta SPRRAM_t+8, x
	iny
	lda (tempaddr), y
	sta SPRRAM_t+12, x

	pla
	tax
	lda object_xpos, x
	asl a
	asl a
	asl a
	asl a
	sec
	sbc hscroll
	sta temp
	lda object_type, x
	cmp #OBJECT_CHIP
	bne @normal_object
	jsr GetChipX
	sta temp
	cpy #1
	beq @store_x
@normal_object:
	lda object_finepos, x
	and #$10
	bne @store_x
	lda object_finepos, x
	and #$0F
	clc
	adc temp
	sta temp
@store_x:
	lda temp
	ldy sprite_pointer
	sta SPRRAM_x, y
	sta SPRRAM_x+8, y
	clc
	adc #8
	sta SPRRAM_x+4, y
	sta SPRRAM_x+12, y
	
	lda object_ypos, x
	asl a
	asl a
	asl a
	asl a
	sta temp
	sec
	sbc vscroll
	sta temp
	lda active_nt
	and #8
	beq @nosub
	lda temp
	sec
	sbc #240
	sta temp
@nosub:
	lda object_type, x
	cmp #OBJECT_CHIP
	bne @normal_object_y
	jsr GetChipY
	sta temp
	cpy #1
	beq @store_y
@normal_object_y:
	lda object_finepos, x
	and #$10
	beq @store_y
	lda object_finepos, x
	and #$0F
	clc
	adc temp
	sta temp
@store_y:
	dec temp
	lda temp
	ldy sprite_pointer
	sta SPRRAM_y, y
	sta SPRRAM_y+4, y	
	clc
	adc #8
	sta SPRRAM_y+8, y
	sta SPRRAM_y+12, y

	tya
	clc
	adc #16
	sta sprite_pointer
	rts

;------------------------------------------------------------------------------
; MoveObject
; Moves an object@
;------------------------------------------------------------------------------

MoveObject:
	txa
	pha
	
	lda object_speed, x
	pha
	and #$0F
	sta temp
	lda object_finepos, x
	and #$0F
	clc
	adc temp
	pha
	and #$0F
	sta temp
	pla
	rol a
	rol a
	rol a
	rol a
	pla
	php
	pha
	and #$10
	ora temp
	sta object_finepos, x
	and #$0F
	bne @no_clear
	lda object_speed, x
	sta object_last_speed, x
	beq @clear_speed
	lsr a
	lsr a
	lsr a
	sta object_state, x
	lda object_type, x
	cmp #OBJECT_CHIP
	bne @clear_speed
	;lda #$02
	;sta object_state, x
	lda #60
	sta chip_direction_counter

@clear_speed:
	lda #0
	sta object_speed, x

@no_clear:
	pla
	pha
	and #$10
	lsr a
	lsr a
	lsr a
	lsr a
	sta temp
	txa
	clc
	adc temp
	tay
	
	pla
	and #8
	eor #8
	lsr a
	lsr a
	lsr a
	sec
	sbc #1
	plp
	adc object_data, y
	and #$1F
	sta object_data, y	
	
@return:
	pla
	tax
	rts
	
;------------------------------------------------------------------------------
; GetTargetblock
; IN: (X,Y) holds position of object to fetch target block for
;     A holds direction (00 = right, 01 = left, 10 = down, 11 = up)
; OUT: A = block number of the block the object is moving towards
;------------------------------------------------------------------------------

GetTargetblock:
	pha
	pha
	eor #1
	and #1
	asl a
	sta temp
	pla
	cmp #2
	bmi @horizontal
	tya
	jmp @sub_pos

@horizontal:
	txa

@sub_pos:
	sec
	sbc #1
	clc
	adc temp
	sta temp
	pla
	cmp #2
	bmi @sub_x
	ldy temp
	jmp @get_block
@sub_x:
	ldx temp
@get_block:
	tya
	pha
	txa
	pha
	jsr GetBlock
	sta temp
	pla
	tax
	pla
	tay
	lda temp
	rts
	
;------------------------------------------------------------------------------
; GetChipX
; 
; Returns Chip's sprite location on screen.
;------------------------------------------------------------------------------

GetChipX:
	ldy #0
	lda object_xpos
	cmp #7
	bmi @return
	cmp #23
	bpl @return
	lda #7
	ldy #1
@return:
	clc
	asl a
	asl a
	asl a
	asl a
	rts

;------------------------------------------------------------------------------
; GetChipX
; 
; Returns Chip's sprite location on screen.
;------------------------------------------------------------------------------

GetChipY:
	ldy #0
	lda object_ypos
	cmp #7
	bmi @return
	cmp #24
	bpl @d1
	lda #7
	ldy #1
	jmp @return
@d1:
	sec
	sbc #1
@return:
	clc
	asl a
	asl a
	asl a
	asl a
	rts

;--------------------------------------------------------------------------------
; Allocate object
;--------------------------------------------------------------------------------

AllocateObject:
	ldx #0
@loop:
	lda object_type, x
	beq @return
	txa
	clc
	adc #8
	tax
	bne @loop
	
@return:
	inc object_count
	rts

;------------------------------------------------------------------------------
; Free object
;------------------------------------------------------------------------------

FreeObject:
	lda #0
	sta object_xpos, x
	sta object_ypos, x
	sta object_type, x
	sta object_finepos, x
	sta object_speed, x
	sta object_last_speed, x
	sta object_frame, x
	sta object_state, x
	dec object_count
	rts
