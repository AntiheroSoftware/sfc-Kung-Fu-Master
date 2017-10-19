;
; Kung Fu Master scripted pad
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .feature	c_comments

            .include    "snes.inc"
            .include    "snes-pad.inc"

            .export 	scriptedPadInit
            .export 	scriptedPadReadData
            .export 	scriptedPadOverride

.segment "RODATA"

;******************************************************************************
;*** Data Structure ***********************************************************
;******************************************************************************
;*** number of frame (byte)													***
;*** pad data (word)														***
;******************************************************************************

;scriptedDataTest:
;	.byte $30						; 30 frames
;	.word PAD_LEFT					; left pressed
;	.byte $10						; 10 frames
;	.word PAD_LEFT | PAD_A			; left and a button pressed
;	.byte $00						; end

.segment "BSS"

scriptedPadPushData:
scriptedPadPushDataLow:
    .res    1
scriptedPadPushDataHigh:
	.res    1

scriptedPadFirstPushData:
scriptedPadFirstPushDataLow:
    .res    1
scriptedPadFirstPushDataHigh:
	.res    1

scriptedPadReleaseData:
scriptedPadReleaseDataLow:
    .res    1
scriptedPadReleaseDataHigh:
    .res    1

scriptedPadIndex:
	.res 	2

scriptedPadCounter:
	.res 	1

.segment "ZEROPAGE"

scriptedPadPtr:
	.res 	2

.segment "CODE"

.A8
.I16

;******************************************************************************
;*** scriptedPadInit **********************************************************
;******************************************************************************
;*** A contains list bank													***
;*** X contains list address												***
;******************************************************************************

.proc scriptedPadInit
	pha
	phx

	; TODO implement bank usage
	stx scriptedPadPtr
	ldx #$0000
	stx scriptedPadIndex
	lda #$00
	sta scriptedPadCounter

	plx
	pla
	rts
.endproc

;******************************************************************************
;*** scriptedPadReadData ******************************************************
;******************************************************************************
;*** No parameters															***
;*** Return 0/1 in A register												***
;******************************************************************************

.proc scriptedPadReadData
	pha
	phx
	phy
	php

	ldy scriptedPadIndex
	lda (scriptedPadPtr),Y
	cmp #$00						; are we at the end
	beq noMoreData
	cmp scriptedPadCounter			; have we reached the count
	bne readData

	iny
	iny
	iny								; get next index
	sty scriptedPadIndex
	lda (scriptedPadPtr),Y
	cmp #$00						; are we at the end
	beq noMoreData

readData:
	inc scriptedPadCounter
	iny

	rep #$20
	.A16

	lda (scriptedPadPtr),Y
	tax

	sep #$20
	.A8

	stx scriptedPadPushData
	jsr _transformPadData

	lda #$01						; return value to continue

	plp
	ply
	plx
	pla
	rts

noMoreData:

	stz scriptedPadPushData
	stz scriptedPadPushData+1		; clear data
	lda #$00						; return value to stop

	plp
	ply
	plx
	pla
	rts
.endproc

;******************************************************************************
;*** scriptedPadOverride ******************************************************
;******************************************************************************
;*** No parameters															***
;******************************************************************************

.proc scriptedPadOverride
	phx

	ldx scriptedPadPushData
	stx padPushData1
	ldx scriptedPadFirstPushData
	stx padFirstPushData1
	ldx scriptedPadReleaseData
	stx padReleaseData1

	plx
	rts
.endproc

;******************************************************************************
;*** _transformPadData ********************************************************
;******************************************************************************
;*** X contains pad data													***
;******************************************************************************

.proc _transformPadData
	pha
	phx
	phy
	php

	rep #$20
	.A16

	stx scriptedPadReleaseData         ; and put it in place of released data

	txa

	; Calculate first push data
	lda scriptedPadPushData
	eor scriptedPadReleaseData
	and scriptedPadPushData
	sta scriptedPadFirstPushData

	; Calculate release data
	lda scriptedPadPushData
	eor #$FFFF
	and scriptedPadReleaseData
	sta scriptedPadReleaseData

	plp
	ply
	plx
	pla
	rts
.endproc