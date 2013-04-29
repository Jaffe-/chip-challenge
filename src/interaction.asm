;------------------------------------------------------------------------------
; Chip's Challenge
; by Johan Fjeldtvedt / Jaffe
; 
;------------------------------------------------------------------------------
;
; BLOCK INTERACTION ROUTINES
;
;------------------------------------------------------------------------------


;------------------------------------------------------------------------------
; Chip (the chip block) interraction.
; Because of the block type, this will only be run when Chip steps on it.
;------------------------------------------------------------------------------
	
Interaction_Chip:
	lda chip_count
	beq @replace_block
	dec chip_count			; decrease the number of chips left
@replace_block:
	ldx current_object_x
	ldy current_object_y		; replace with a floor block.
	lda #BLOCK_FLOOR
	jsr UpdateBlock
	rts


;------------------------------------------------------------------------------
; Fire interaction.
;------------------------------------------------------------------------------

Interaction_Fire:
	lda object_type, x
	cmp #OBJECT_FIREBALL		; everything but fireballs should be destroyed.
	beq @return
	jsr FreeObject
@return:
	rts


;------------------------------------------------------------------------------
; Water interaction 
;------------------------------------------------------------------------------

Interaction_Water:
	lda object_type, x
	cmp #OBJECT_DIRT_BLOCK		; dirt blocks and gliders should survive water
	beq @return
	cmp #OBJECT_GLIDER
	beq @return
@kill_object:
	jsr FreeObject			; free all other objects
@return:
	rts


;------------------------------------------------------------------------------
; Ice interaction 
;------------------------------------------------------------------------------

Interaction_Ice:
	lda object_last_speed, x	; an object on ice should retain its last speed.
	sta object_speed, x		
	rts

Interaction_IceDownRight:		
	lda object_last_speed, x
	and #$18
	beq Interaction_Ice
	cmp #$18
	beq Interaction_Ice
	jmp FlipDirection

Interaction_IceUpLeft:
	lda object_last_speed, x
	and #$18
	beq FlipDirection
	cmp #$18
	beq FlipDirection
	jmp Interaction_Ice

Interaction_IceDownLeft:
	lda object_last_speed, x
	and #$08
	beq ChangeDirection
	jmp Interaction_Ice

Interaction_IceUpRight:
	lda object_last_speed, x
	and #$08
	bne ChangeDirection
	jmp Interaction_Ice

FlipDirection:
	lda object_last_speed, x
	eor #$10
	sta object_speed, x
	rts

ChangeDirection:
	lda object_last_speed, x
	eor #$10
	pha
	and #$10
	sta temp
	pla
	and #$0F
	eor #$0F
	clc
	adc #1
	ora temp
	sta object_speed, x
	rts

Interaction_ForceDown:
	lda #$14
	sta object_speed, x
	rts

Interaction_ForceUp:
	lda #$1C
	sta object_speed, x
	rts

Interaction_ForceLeft:
	lda #$0C
	sta object_speed, x
	rts

Interaction_ForceRight:
	lda #$04
	sta object_speed, x
	rts

Interaction_Red_Button:
	inc red_button_count
	rts

Interaction_Green_Button:
	inc green_button_count
	rts

Interaction_Blue_Button:
	inc blue_button_count
	rts

Interaction_Trap:
	ldx #0
	ldy #0
@trap_loop:
	lda (map_ptr), y
	iny
	cmp current_object_x
	beq @check_y
	iny
	jmp @next
@check_y:
	lda (map_ptr), y
	iny
	cmp current_object_y
	bne @next
	jmp @check_button
@next:
	inx
	iny
	iny
	cpx trap_count
	bne @trap_loop
@return:
	rts

@check_button:
	lda (map_ptr), y
	sta temp2
	iny
	lda (map_ptr), y
	sta temp3

	; first check if the button is covered by a movable block
	ldx temp2
	ldy temp3
	jsr GetBlock
	cmp #BLOCK_MOVABLE
	beq @return				; if it is, objects are to be freed	
	ldx #0
@object_loop:
	lda object_xpos, x
	cmp temp2
	bne @next_object
	lda object_ypos, x
	cmp temp3
	beq @return
@next_object:
	txa
	clc
	adc #8
	tax
	lsr a
	lsr a
	lsr a
	cmp object_count
	bne @object_loop
	ldx current_object
	lda #0
	sta object_speed, x
	sta object_last_speed, x
	rts

Interaction_Hint:
	rts					; no hints yet...

Interaction_Exit:
	inc current_level			; go to next level
	lda #STATUS_INIT			; not in game mode any more
	sta status				; set new status
	rts

Interaction_MakeTile:
	cpx #INDEX_CHIP			
	bne @ret				; only Chip can replace stuff with floor tiles
	lda #BLOCK_FLOOR			; replace with a floor block
	ldx current_object_x
	ldy current_object_y
	jsr UpdateBlock				; replace block
@ret:
	rts

Interaction_Bomb:
	jsr FreeObject				; any object should be destroyed by the bomb
	ldx current_object_x
	ldy current_object_y			
	lda #BLOCK_FLOOR
	jsr UpdateBlock				; replace bomb with floor block
	rts


Interaction_Clone_Machine:
	lda cloner_active			; is the cloner active?
	beq @ret				; if not, keep the object to be cloned still.
	txa
	tay					; put object's idnex in Y
	jsr AllocateObject			; X will contain new object's index
	lda current_object_x			
	sta object_xpos, x
	lda current_object_y
	sta object_ypos, x			; copy data to the new object
	lda object_type, y
	sta object_type, x
	lda object_state, y
	sta object_state, x
	tay				
	lda up_turns, y				; get speed
	sta object_last_speed, x		; and set the object in motion
	sta object_speed, x
@ret:
	lda #0
	sta cloner_active			; the cloner is no longer active
	rts


Interaction_Thief:
	lda #0
	sta shoe_counts
	sta shoe_counts+1			; set all shoe counters to 0
	sta shoe_counts+2
	sta shoe_counts+3
	rts


Interaction_Blocked_North:
	lda object_speed, x
	and #$18
	cmp #$18
	bne @ret
	lda #0
	sta object_speed, x
@ret:
	rts

Interaction_Blocked_East:
	lda object_speed, x
	and #$18
	cmp #$00
	bne @ret
	lda #0
	sta object_speed, x
@ret:
	rts

Interaction_Blocked_South:
	lda object_speed, x
	and #$18
	cmp #$10
	bne @ret
	lda #0
	sta object_speed, x
@ret:
	rts

Interaction_Blocked_West:
	lda object_speed, x
	and #$18
	cmp #$08
	bne @ret
	lda #0
	sta object_speed, x
@ret:
	rts


Interaction_Teleport:
	ldy #0
	ldx #0
@find_loop:
	lda (teleport_ptr), y
	iny
	cmp current_object_x
	beq @check_y
	iny
	jmp @next_teleport
@check_y:
	lda (teleport_ptr), y
	iny
	cmp current_object_y
	beq @find_exit_teleport
@next_teleport:
	inx
	cpx teleport_count
	bne @find_loop
	rts

@find_exit_teleport:
	inx
	cpx teleport_count
	bne @find_exit
	ldx #0
	ldy #0
@find_exit:
	lda (teleport_ptr), y
	sta target_x
	iny
	lda (teleport_ptr), y
	iny
	sta target_y
	txa
	pha
	tya
	pha
	ldx current_object
	lda target_x
	sta current_object_x
	sta object_xpos, x
	lda target_y
	sta current_object_y
	sta object_ypos, x
	lda object_last_speed, x
	sta object_speed, x
	jsr ObjectCollision
	lda object_speed, x
	bne @go
	pla
	tay
	pla
	tax
	jmp @find_exit_teleport
@go:
	pla
	pla
	rts

Interaction_Pass_Once:
	ldx current_object_x
	ldy current_object_y
	lda #BLOCK_WALL
	jsr UpdateBlock
	rts
