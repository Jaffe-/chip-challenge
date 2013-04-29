;------------------------------------------------------------------------------
; Chip's Challenge
; by Johan Fjeldtvedt / Jaffe
; 
;------------------------------------------------------------------------------
;
; MAP ROUTINES
;
;------------------------------------------------------------------------------


;------------------------------------------------------------------------------
; LoadMap
;------------------------------------------------------------------------------

LoadMap:
	clc
	asl a
	tax
	lda LevelList, x
	sta map_ptr
	lda LevelList+1, x
	sta map_ptr+1
	lda #<map
	sta ram_ptr
	lda #>map
	sta ram_ptr+1
	
	ldy #0
	lda (map_ptr), y
	sta chip_count
	iny
	lda (map_ptr), y
	sta trap_count
	iny
	lda (map_ptr), y
	sta teleport_count
	lda map_ptr
	clc
	adc #3
	sta map_ptr
	lda map_ptr+1
	adc #0
	sta map_ptr+1
	
@loop:
	ldy #0
	lda (map_ptr), y
	cmp #$FF
	bne @store_normal
	iny
	iny
	lda (map_ptr), y
	tax
	dey
	lda (map_ptr), y
	jsr ExpandRLE
	lda map_ptr
	clc
	adc #3
	sta map_ptr
	lda map_ptr+1
	adc #0
	sta map_ptr+1
	jmp @check_end

@store_normal:
	jsr StoreRAM
	lda map_ptr
	clc
	adc #1
	sta map_ptr
	lda map_ptr+1
	adc #0
	sta map_ptr+1
	
@check_end:
	lda ram_ptr
	bne @loop
	lda ram_ptr+1
	sec
	sbc #>map
	cmp #4
	bmi @loop

	; load object data
	ldy #0
	lda (map_ptr),y
	sta object_count
	inc map_ptr
	clc
	asl a
	asl a
	asl a
	sta temp
	
	ldx #0
@object_loop:
	lda (map_ptr),y
	sta object_xpos, x
	iny
	lda (map_ptr),y
	sta object_ypos, x
	iny
	lda (map_ptr),y
	pha
	and #$1F
	sta object_type, x
	pla
	and #$C0
	clc
	rol a
	rol a
	rol a
	sta object_state, x
	iny
	txa
	clc
	adc #8
	tax
	cpx temp
	bne @object_loop
	tya
	clc
	adc map_ptr
	sta map_ptr
	lda map_ptr+1
	adc #0
	sta map_ptr+1

	lda teleport_count
	beq @return
	lda trap_count
	asl a
	asl a
	clc
	adc map_ptr
	sta teleport_ptr
	lda map_ptr+1
	adc #0
	sta teleport_ptr+1	

@return:
	rts

;------------------------------------------------------------------------------
; ExpandRLE
;------------------------------------------------------------------------------

ExpandRLE:
@loop:
	jsr StoreRAM
	dex
	bne @loop
	rts

;------------------------------------------------------------------------------
; StoreRAM
;------------------------------------------------------------------------------

StoreRAM:
	pha
	ldy #0
	sta (ram_ptr),y
	lda ram_ptr
	clc
	adc #1
	sta ram_ptr
	lda ram_ptr+1
	adc #0
	sta ram_ptr+1
	pla
	rts
	
;------------------------------------------------------------------------------
; GetBlock
; Get blok in map coordinate X,Y
; IN: X = x coordinate, Y = y coordinate
; OUT: X = raw map byte, A = processed map byte, with actual block returned
;------------------------------------------------------------------------------

GetBlock:
	tya
	and #$E0						
	bne @solid
	txa
	and #$E0						
	bne @solid			; check if X or Y refer to blocks outside map
	tya
	jsr CalculateRowAddress
	txa
	tay
	jmp ReadBlock
@solid:
	lda #BLOCK_WALL			; return solid block if X, Y > 31
	rts

;------------------------------------------------------------------------------
	
ReadBlock:
	lda (ram_ptr),y
	bpl @return			; is the 7th bit set?
	tax		
	lda #$0A			; yes -- return graphic for movable block
@return:
	rts

;------------------------------------------------------------------------------
; SetBlock
;------------------------------------------------------------------------------

SetBlock:
	pha
	tya
	jsr CalculateRowAddress
	txa
	ora ram_ptr
	sta ram_ptr
	ldy #0
	pla
	cmp #$0A
	bne @store_block
	lda (ram_ptr),y
	ora #$80
@store_block:
	sta (ram_ptr),y
	rts

;------------------------------------------------------------------------------
; GetMetatile
; Expects ram_ptr + Y to point to block address
;------------------------------------------------------------------------------

GetMetatile:
	txa
	pha
	jsr ReadBlock
	tax
	lda metatile_offsets, x
	sta temp

	pla
	tax
	lda temp
	rts

;------------------------------------------------------------------------------
; GetAttribute
;------------------------------------------------------------------------------

GetAttribute:
	txa
	pha
	jsr ReadBlock
	tax
	lda block_palettes, x
	ror a
	ror a
	ror a
	sta temp2
	
	pla
	tax
	lda temp2
	rts
	
;------------------------------------------------------------------------------

UpdateBlock:
	sta temp
	txa
	pha
	tya
	pha
	
	lda temp
	jsr SetBlock
	txa
	tay
	ldx #0
	ldy #0
	stx tile_offset
	jsr ExpandMetatile
	inx
	stx tile_offset
	jsr ExpandMetatile
	ldx #0
	stx tile_offset
	pla
	tay
	pla
	tax
	jsr WriteMetatile	
	
	rts
