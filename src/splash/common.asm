;
; Kung Fu Master common splash code
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .feature	c_comments

            .include    "snes.inc"
            .include    "snes-pad.inc"
            .include    "snes-event.inc"

            .export 	splashScreenInit
            .export 	splashScreenEvent

.segment "BSS"

fadeOutValue:						; only used in splashScreen so can be reused
	.res 	1

splashCounter:						; only used in splashScreen so can be reused
	.res 	2

splashTimeTable:
	.res 	3*4

.segment "CODE"

;******************************************************************************
;*** splashScreenInit *********************************************************
;******************************************************************************
;*** X register contains wait time											***
;******************************************************************************

.proc splashScreenInit
	php
	phx
	pha

	rep #$20
	.A16

	txa
	sta splashTimeTable

	clc
	adc #$20
	sta splashTimeTable+2

	clc
	adc #$20
	sta splashTimeTable+4

	rep #$10
	sep #$20
	.A8
	.I16

	ldx #$0000
	stx splashCounter

	lda #$0f
	sta fadeOutValue

	pla
	plx
	plp
	rts

.endproc

;******************************************************************************
;*** splashScreenEvent ********************************************************
;******************************************************************************

.proc splashScreenEvent
	php
	phx

	;tax 							; put A reg containing counter in X reg

	ldx splashCounter

	rep #$10
	sep #$20
	.A8
	.I16

	cpx splashTimeTable+4
	bpl exit

	cpx splashTimeTable+2
	bpl waitMore

	cpx splashTimeTable
	bpl doFadeOut

	cpx #$0010
	bpl waitToFadeOut

	txa
	sta PPU_INIDSP
	bra continue

waitToFadeOut:

	lda padPushData1
	bit #PAD_START
	bne fadeOut						; check if START is pressed to fade out

	jmp continue

fadeOut:

	ldx splashTimeTable
	stx splashCounter

doFadeOut:

	lda fadeOutValue
	sta PPU_INIDSP
	dec
	sta fadeOutValue
	cmp #$ff
	bne continue

waitMore:
	jmp continue

exit:
	lda #$00                        ; exit event value
	bra return

continue:
	lda #$01                        ; continue event value

	ldx splashCounter
	inx
	stx splashCounter

return:
	plx
	plp
	rtl
.endproc