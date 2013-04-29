;------------------------------------------------------------------------------
; Chip's Challenge
; by Johan Fjeldtvedt / Jaffe
; 
;------------------------------------------------------------------------------
;
; LEVELS
;
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; NMI routine
;------------------------------------------------------------------------------
	
NMI:
	pha
	txa
	pha				; store registers in case this is triggered
	tya				; in the middle of something
	pha
	
	lda $2002			; clear address part latch

	lda #3				; start DMA transfer of $0300 -> SPR-RAM
	sta $4014
	
	lda t
	bne @k
	inc t
	jmp @ret
@k:
	dec t

	lda buffer_flag			; check buffer_flag
	beq @set_regs			; if 0 there's nothing to write
	cmp #3
	beq @green_button_test_a
	cmp #4
	bne @write_buffer
	jmp @green_button_test_b
@write_buffer:
	jsr WriteBuffer			; if 1, write a row of tile data
	jmp @set_zero

@set_zero:
	lda #0				; the buffer is written now
	sta buffer_flag


@set_regs:	
	lda #1
	sta vblank_flag			; we are now in vblank
	
@ret:
	lda active_nt
	sta PPUADDR
	lda #0
	sta PPUADDR
	lda hscroll
	sta PPUSCROLL
	lda vscroll
	sta PPUSCROLL
	
	pla
	tay
	pla
	tax
	pla
	rti

@green_button_test_a:
	jmp @set_regs
	lda #$08
	sta PPUADDR
	lda #$00
	sta PPUADDR

	.repeat 64, i
	lda buffer+(64-i)
	sta PPUDATA
	.endrep
	inc buffer_flag
	jmp @set_regs

@green_button_test_b:
	jmp @set_regs
	lda #$08
	sta PPUADDR
	lda #$40
	sta PPUADDR

	.repeat 64, i
	lda buffer+64+(64-i)
	sta PPUDATA
	.endrep
	jmp @set_zero


