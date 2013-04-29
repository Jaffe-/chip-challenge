;------------------------------------------------------------------------------
; Chip's Challenge
; by Johan Fjeldtvedt / Jaffe
; 
;------------------------------------------------------------------------------
;
; BACKGROUND (NAMETABLE) ROUTINES
;
;------------------------------------------------------------------------------


;------------------------------------------------------------------------------
; UpdateNametables
; Updates nametables during vblank@
;------------------------------------------------------------------------------

UpdateNametables:
	lda buffer_pointer
	cmp #32
	beq @set_flag
	cmp #8
	beq @set_flag
	lda tile_offset
	bne @load_from_map
	lda scroll_flag
	beq @return
	lda active_nt
	and #8
	bne @return
	lda vscroll
	and #7
	bne @return
	
	lda #$20
	sta ppu_high
	
	lda object_ypos
	cmp #10
	beq @set_attributes
	cmp #8
	bmi @return
	cmp #10
	bpl @return
	sta temp
	lda object_speed
	and #$10
	beq @return
	lda object_speed
	and #8
	beq @down

	lda temp
	sec
	sbc #8
	sta col
	jmp @load_from_map

@down:
	lda temp
	clc
	adc #22
	sta col

@load_from_map:
	lda col
	jsr MapToBuffer
	and #1
	clc
	asl a
	asl a
	adc tile_offset
	asl a
	asl a
	asl a
	asl a
	sta ppu_low

	lda tile_offset
	eor #2
	sta tile_offset

@set_flag:
	lda #1
	sta buffer_flag	
	
@return:
	rts

@set_attributes:
	lda #$23
	sta ppu_high
	lda #$C0
	sta ppu_low
	lda object_speed
	and #$10
	beq @return
	lda object_speed
	and #8
	beq @bottom
@top:
	ldx #0
	jmp @write
@bottom:
	ldx #30
@write:
	jsr WriteAttributeLine
	jmp @set_flag

;------------------------------------------------------------------------------
; MapRowToBuffer
; Takes a row in the map and expands it to tiles
; IN: A = row in map (0 - $1F)
; OUT: buffer holds 64 tiles for two horizontal nametables
;------------------------------------------------------------------------------

MapToBuffer:
	jsr CalculateRowAddress

	pha	
	txa
	pha
	tya
	pha

	ldx #0
	ldy #0
@loop:
	jsr ExpandMetatile

	inc ram_ptr	

	inx 						; point to next buffer byte
	cpx #64
	bne @loop
	
	pla
	tay
	pla
	tax
	pla
	rts	

;------------------------------------------------------------------------------
; ExpandMetatile
;------------------------------------------------------------------------------

ExpandMetatile:
	jsr GetMetatile
	ora tile_offset
	sta buffer, x
	inx
	clc
	adc #1
	sta buffer, x
	rts

;------------------------------------------------------------------------------
; BuildAttribute
; Builds an attribute byte from a given 2x2 metatile block in map
; IN: ram_ptr = address to upper left metatile
; OUT: A = an attribute byte for the given block
;------------------------------------------------------------------------------

BuildAttribute:
	txa
	pha
	tya
	pha
	
	ldy #0
	ldx #0
	sty temp
@loop:
	jsr GetAttribute
	iny
	inx
	and #$C0
	clc
	lsr temp
	lsr temp
	ora temp
	sta temp
	cpx #4
	beq @finished
	tya
	and #1
	bne @loop
	tya
	clc
	adc #30
	tay
	jmp @loop

@finished:
	pla
	tay
	pla
	tax

	lda temp
	rts

;------------------------------------------------------------------------------
; WriteAttributeLine
; Takes a row number in X and outputs attributes to buffer@
; IN: X = row in map
; OUT: buffer ($0200) holds 16 bytes of attribute data for two horiz@ tables  
;------------------------------------------------------------------------------

WriteAttributeLine:
	pha
	txa
	pha
	
	jsr CalculateRowAddress
	
	ldx #0
@loop:
	jsr BuildAttribute
	sta buffer, x
	inc ram_ptr
	inc ram_ptr
	inx
	cpx #16
	bne @loop
	
	pla
	tax
	pla
	rts
	
;------------------------------------------------------------------------------
; RowAddress
; Calculate row address from row number@
; IN: A = row number
; OUT: ram_ptr points to first column in the given row
;------------------------------------------------------------------------------

CalculateRowAddress:
	pha
	
	; calculate address
	clc
	rol a
	rol a				; row * 32
	rol a
	rol a
	rol a
	pha
	and #$E0			; clear out first page bit rolled in
	sta ram_ptr			; store low bits
	pla				; get back A before ANDing
	rol a				; roll one more time to get page bits in D0-D1
	and #3				; clear out higher bits
	clc
	adc #>map
	sta ram_ptr+1
	
	pla
	rts	

;------------------------------------------------------------------------------
; WriteBuffer
; Writes buffer to VRAM.
; IN: Target VRAM address in ppu_high and ppu_low
; OUT: None
;
; As all writes will happen across two horizontal nametables, this function
; auto-flips ppu_high and increments and zeros out buffer pointers accordingly@
; A 16-byte write mode for attribute tables is toggled when address points to
; attribute memory.
;------------------------------------------------------------------------------

WriteBuffer:
	pha
	txa
	pha
	
	lda ppu_high
	sta PPUADDR
	lda ppu_low
	sta PPUADDR

@onetile:
	lda buffer_flag
	cmp #2
	bne @row_write
	; TODO: fix this ugly code!

	lda #%10001100
	sta PPUCTRL
	lda buffer
	sta PPUDATA
	lda buffer+2
	sta PPUDATA

	lda ppu_high
	sta PPUADDR
	ldx ppu_low
	inx
	stx PPUADDR
	
	lda buffer+1
	sta PPUDATA
	lda buffer+3
	sta PPUDATA

	lda #%10001000
	sta PPUCTRL
	
	lda buffer+4
	sta PPUADDR
	lda buffer+5
	sta PPUADDR
	lda buffer+6
	sta PPUDATA
	jmp @return
	
@row_write:
	; check for attribute write (in which case we want to write 8, not 32 bytes)
	lda ppu_high
	and #3
	cmp #3
	bne @normal_write
	lda ppu_low
	and #$C0
	cmp #$C0
	bne @normal_write
	
	lda #7
	sta buffer_mask
	ldx buffer_pointer
	jmp @loop

@normal_write:
	lda #$1F
	sta buffer_mask
	ldx buffer_pointer
	
@loop:
	lda buffer, x
	sta PPUDATA
	inx
	txa
	and buffer_mask
	bne @loop
	stx buffer_pointer
	lda ppu_high
	eor #4
	sta ppu_high				; flip nametable
	and #4
	bne @return
	lda #0					; clear out buffer pointer if we've flipped back to old left NT
	sta buffer_pointer
	
@return:	
	pla
	tax
	pla
	rts
	
;------------------------------------------------------------------------------
; FillNametables
; Copy map data to nametables
;------------------------------------------------------------------------------

FillNametables:

	ldx #0
	lda #$20
	sta ppu_high
	lda #0
	sta ppu_low

@loop:
	txa
	jsr MapToBuffer
	jsr WriteBuffer
	jsr WriteBuffer
	lda ppu_low
	clc
	adc #$20
	sta ppu_low
	lda ppu_high
	adc #0
	sta ppu_high
	lda tile_offset
	eor #2
	sta tile_offset
	beq @next_block
	jmp @loop
@next_block:
	inx
	cpx #15
	beq @next_vnt
	cpx #30
	beq fill_attributes
	jmp @loop
@next_vnt:
	lda #$28
	sta ppu_high
	lda #0
	sta ppu_low
	jmp @loop

fill_attributes:
	lda #0
	sta buffer_pointer
	
	lda #$23
	sta ppu_high
	lda #$C0
	sta ppu_low
	ldx #0
@loop:
	jsr WriteAttributeLine
	jsr WriteBuffer
	jsr WriteBuffer
	inx
	inx
	lda ppu_low
	clc
	adc #8
	sta ppu_low
	cpx #16
	beq @next_vnt
	cpx #31
	beq @return
	jmp @loop
@next_vnt:
	ldx #15
	lda #$2B
	sta ppu_high
	lda #$C0
	sta ppu_low
	jmp @loop

@return:
	rts
		
;------------------------------------------------------------------------------

WriteMetatile:
	tya
	sta temp2
	sta temp
	sec
	sbc #15
	bmi @nt1
	sta temp
	sec
	sbc #15
	bmi @nt2
	sta temp
@nt1:
	lda #$20
	sta ppu_high
	jmp @find_hnt
@nt2:
	lda #$28
	sta ppu_high

@find_hnt:
	txa
	lsr a
	lsr a
	and #4
	ora ppu_high
	sta ppu_high
	
	lda temp
	lsr a
	lsr a
	and #3
	ora ppu_high	
	sta ppu_high
	
	lda temp
	ror a
	ror a
	ror a
	and #$D0
	sta ppu_low
	txa
	and #$0F
	asl a
	ora ppu_low
	sta ppu_low
	
	lda ppu_high
	and #$03
	asl a
	asl a
	asl a
	asl a
	sta temp
	lda ppu_high
	ora #$03
	sta buffer+4

	lda ppu_low
	asl a
	lda #0
	ror a
	lsr a
	lsr a
	lsr a
	lsr a
	ora temp
	sta temp
	lda ppu_low
	lsr a
	lsr a
	and #$07
	ora #$C0
	ora temp
	sta buffer+5

	lda ram_ptr
	and #$DE
	sta ram_ptr

	lda temp2
	cmp #15
	bmi @get
	cmp #30
	bpl @get

	lda temp2
	and #1
	beq @sub
	lda ram_ptr
	clc
	adc #32
	sta ram_ptr
	lda ram_ptr+1
	adc #0
	sta ram_ptr+1
	jmp @get
	
@sub:
	lda ram_ptr
	sec
	sbc #32
	sta ram_ptr
	lda ram_ptr+1
	sbc #0
	sta ram_ptr+1
	
@get:
	jsr BuildAttribute
	sta buffer+6 
	
	lda #2
	sta buffer_flag
	rts
