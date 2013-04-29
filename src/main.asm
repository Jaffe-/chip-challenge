;------------------------------------------------------------------------------
; Chip's Challenge
; by Johan Fjeldtvedt / Jaffe
; 
;------------------------------------------------------------------------------
;
; MAIN TOP LEVEL CODE (STARTUP, NMI)
;
;------------------------------------------------------------------------------


;------------------------------------------------------------------------------
; MAIN
;------------------------------------------------------------------------------

Start:
	lda current_level
	lda map
	sei				; disable IRQs and don't use decimal mode
	cld

:	lda $2002
	bpl :-
:	lda $2002			; wait two VBLANKs
	bpl :-

	lda #0			
	sta PPUCTRL			; turn off PPU rendering 
	sta PPUMASK

	lda #>bg_tiles
	sta tempaddr+1
	lda #<bg_tiles
	sta tempaddr
	ldx #32
	ldy #0
	lda #0
	sta PPUADDR
	sta PPUADDR
@l:
	lda (tempaddr),y
	sta PPUDATA
	iny
	bne @l
	inc tempaddr+1
	dex
	bne @l

	lda #0
	ldx #0
@loop:
	sta 0,x
	sta $0100,x
	sta $0200,x
	sta $0300,x			; clear RAM
	sta $0400,x
	sta $0500,x
	sta $0600,x
	sta $0700, x
	inx
	bne @loop

	ldx #$FF
	txs				; set stack pointer to top of stack

LoadPalette:
	lda #$3F			; point PPU to $3F00
	sta PPUADDR
	lda #0
	sta PPUADDR
	tax
@loop:
	lda palette, x
	sta PPUDATA			; transfer 32 bytes
	inx
	cpx #32
	bne @loop
	
	lda #0
	sta <current_level
	lda #STATUS_INIT
	sta <status

:	lda $2002			; wait for VBLANK in case we are in the middle
	bpl :-				; of a frame

	lda #%10001000			; turn on NMI trigging, use second bank for sprites
	sta PPUCTRL			
	lda #%00011010		
	sta PPUMASK

;------------------------------------------------------------------------------
; Main loop
;------------------------------------------------------------------------------

main:
	lda status
	cmp #STATUS_INIT
	bne @game_mode
	jsr LoadLevel
	jmp main

@game_mode:
	lda object_speed
	and #$0F
	bne @ok2
	lda #$02
	sta object_state
@ok2:
	lda vblank_flag			 ; we only want this loop to run once each frame
	beq @game_mode
	lda #0
	sta vblank_flag
	sta scroll_flag			; this flag is used by UpdateNametables to detect
					; if a scroll has happened (in which case it might
					; have to update some graphics)

	jsr HandleInput			; get input
	jsr HandleScroll		; scroll according to Chip's position
	jsr UpdateNametables		; check if we need to update nametable at $2000
	jsr HandleObjects		; run the object handling routine
	jsr Test
	jsr HandlePlayer

	lda object_type
	beq @dead
	; Store visible screen area
	lda vscroll
	lsr a
	lsr a
	lsr a
	lsr a
	sta visible_y
	lda active_nt
	and #8
	beq @get_visible_x
	lda visible_y	
	clc
	adc #15
	;adc visible_y
	sta visible_y

@get_visible_x:
	lda hscroll
	lsr a
	lsr a
	lsr a
	lsr a
	sta visible_x
	lda active_nt
	and #4
	asl a
	asl a
	clc
	adc visible_x
	sta visible_x
@ok: 
	jmp main

@dead:
	lda #0
	sta current_level
	lda #STATUS_INIT
	sta status
	jmp main

;------------------------------------------------------------------------------
; HandleInput
; Read keypresses and store them 
;------------------------------------------------------------------------------

HandleInput:
	lda #1
	sta $4016
	lda #0
	sta $4016
	
	lda $4016		 	; A
	lda $4016			; B				
	lda $4016			; Select      (these are all ignored)
	lda $4016			; Start
	
	; Read, shift left and OR with previous keypresses to get a nibble of keys
	lda $4016			; Up
	asl a
	ora $4016			; down
	asl a
	ora $4016			; left
	asl a
	ora $4016			; right
	and #15
	sta direction
	rts
	
;------------------------------------------------------------------------------
; HandlePlayer
; Set player speed according to keypress
;------------------------------------------------------------------------------

HandlePlayer:
	lda object_finepos		; is the player currently moving?
	and #$0F
	bne @ret			; yes, don't set new speed yet

	ldx object_xpos
	ldy object_ypos
	jsr GetBlock
	tax
	cmp #BLOCK_TELEPORT
	beq @ret
	lda block_types, x
	cmp #BLOCK_TYPE_ICE
	bne @move
	lda ice_skates
	beq @ret

@move:
	lda direction
	cmp #1
	beq @right
	cmp #2
	beq @left
	cmp #4
	beq @down
	cmp #8
	beq @up
	jmp @ret
	
@left:
	lda #$0C				 
	jmp @store_speed
		
@right:
	lda #$04				 
	jmp @store_speed
		
@down:
	lda #$14
	jmp @store_speed
	
@up:
	lda #$1C

@store_speed:
	sta object_speed		; store new speed
	lda #0
	sta object_last_speed 		; last speed was 0 if the player was able to move
	
@ret:
	rts

;------------------------------------------------------------------------------
; HandleScroll
; Scroll screen based on player position in the map.
;------------------------------------------------------------------------------

HandleScroll:
	lda object_xpos
	cmp #7				; if Chip's x-position is less than 7 he'll
	bmi @scroll_y			; move on screen, instead of the background scrolling
	cmp #24				; if x-position is 24 or higher, he'll move right
	bpl @scroll_y			
	cmp #23					
	bne @nope
	lda object_finepos
	and #$0F
	bne @scroll_y
	lda object_xpos
@nope:
	sec
	sbc #7
	clc
	asl a
	asl a
	asl a
	asl a
	sta temp
	php
	lda object_finepos
	cmp #$10
	bpl @no_horizontal
	lda object_finepos
	and #$0F
	clc
	adc temp
	sta temp
@no_horizontal:
	lda temp
	sta hscroll
	lda active_nt
	and #$FB
	sta active_nt
	plp
	rol a
	rol a
	rol a
	and #4
	ora active_nt
	sta active_nt
	jmp @scroll_y
	
@return: 
	rts

@scroll_y:
	lda object_ypos
	cmp #7
	bmi @return
	cmp #25
	bpl @return
	cmp #24
	bne @nop
	lda object_finepos
	and #$0F
	bne @return
	lda object_ypos
@nop:
	sec
	sbc #7
	sta temp
	sec
	sbc #15
	php
	bmi @first_nt
	sta temp
@first_nt:
	lda temp
	clc
	asl a
	asl a
	asl a
	asl a
	sta temp
	lda object_finepos
	cmp #$10
	bmi @no_vertical
	and #$0F
	clc
	adc temp
	sta temp
@no_vertical:
	lda temp
	sta vscroll
	lda #1
	sta scroll_flag
	lda active_nt
	and #$F7
	sta active_nt
	pla
	clc
	rol a
	rol a
	rol a
	rol a
	rol a
	and #8
	eor #8
	ora active_nt
	sta active_nt	
	rts

;------------------------------------------------------------------------------
; LoadLevel
;------------------------------------------------------------------------------

LoadLevel:
	ldy current_level
	sta PPUCTRL
	sta PPUMASK
	ldx #0
	lda #0
@loop:
	sta 0,x
	sta $200,x
	sta $300,x
	inx
	bne @loop

	lda #$08
	sta PPUADDR
	lda #0
	sta PPUADDR
	ldx #0
@tile_loop:
	lda bg_tiles + $0800, x
	sta PPUDATA
	inx
	cpx #128
	bne @tile_loop

	tya
	sty current_level
	jsr LoadMap
	jsr FillNametables
	lda #%10001000			; turn on NMI trigging, use second bank for sprites
	sta PPUCTRL			
	lda #%00011110		
	sta PPUMASK
	lda #STATUS_GAME
	sta status
	rts


