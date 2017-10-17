;
; Kung Fu Master high score screen
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .feature	c_comments

            .include    "snes.inc"
			.include	"../includes/common.inc"
			.include	"../includes/highScoreData.inc"
            .include	"../includes/font.inc"

			.export 	initHighScore
			.export 	insertNewHighScore
			.export 	displayHighScore
			.export 	highScoreMainLoop

			.export highScoreTitleString

HIGH_SCORE_TILE_ADDR	= $0000
HIGH_SCORE_MAP_ADDR     = $1000

.segment "BSS"

highScores:
	.res (3+5)*20

.segment "CODE"

.A8
.I16

;******************************************************************************
;*** initHighScore ************************************************************
;******************************************************************************

.proc initHighScore

.endproc

;******************************************************************************
;*** insertNewHighScore *******************************************************
;******************************************************************************

.proc insertNewHighScore

.endproc

;******************************************************************************
;*** displayHighScore *********************************************************
;******************************************************************************

.proc displayHighScore

	jsr enableSkipLeadingZero

	ldx #$0004
	ldy #$0006
	jsr setFontCursorPosition

	ldy #$000a
	ldx #.LOWORD(highScoreInitValues)

loopFirstColumn:
	lda #$02
	jsr setFontPalette

	lda #$06
	jsr writeFontNumber

	inx
	inx
	inx

	lda #$03
	jsr setFontPalette

	jsr writeFontString

	jsr setFontCursorPositionNewLine
	jsr setFontCursorPositionNewLine

	inx
	inx
	inx
	inx
	inx
	dey
	cpy #$0000
	bne loopFirstColumn

	ldx #$0014
	ldy #$0006
	jsr setFontCursorPosition

	ldy #$000a
	ldx #.LOWORD(highScoreInitValues)+80

loopSecondColumn:
	lda #$02
	jsr setFontPalette

	lda #$06
	jsr writeFontNumber

	inx
	inx
	inx

	lda #$03
	jsr setFontPalette

	jsr writeFontString

	jsr setFontCursorPositionNewLine
	jsr setFontCursorPositionNewLine

	inx
	inx
	inx
	inx
	inx
	dey
	cpy #$0000
	bne loopSecondColumn

	rts

.endproc

;******************************************************************************
;*** highScoreMainLoop ********************************************************
;******************************************************************************

.proc highScoreMainLoop
	pha
	phx
	phy
	php

	ldx #$0000
	stx blankData

	setINIDSP $80   				; Enable forced VBlank during DMA transfer

	setBG1SC HIGH_SCORE_MAP_ADDR, $00
	setBG12NBA HIGH_SCORE_TILE_ADDR, $0000

	VRAMLoad fontTiles, HIGH_SCORE_TILE_ADDR, $0800
	VRAMClear blankData, HIGH_SCORE_MAP_ADDR, $0800
	CGRAMLoad gameMessagePal, $00, $20
	CGRAMLoad fontWhiteRedBlackPal, $10, $20
	CGRAMLoad fontCyanBlackBlackPal, $20, $20
	CGRAMLoad fontRedBlackBlackPal, $30, $20

	lda #$01        ; setBGMODE(0, 0, 1);
	sta $2105

	lda #$01         ; enable main screen 1
	sta $212c

	lda #$00         ; disable all sub screen
	sta $212d

	lda #$00
	ldx #HIGH_SCORE_MAP_ADDR
	ldy #$0000
	jsr initFont

	ldx #$0000
	ldy #$0003
	jsr setFontCursorPosition

	ldx #.LOWORD(highScoreTitleString)
	jsr writeFontString

	ldx #$0000
	ldy #$0006
	jsr setFontCursorPosition

	ldx #.LOWORD(highScoreNumbersString)
	jsr writeFontString

	jsr displayHighScore

	setINIDSP $0f   				; Enable screen full brightness

loop:
	bra loop

	plp
	ply
	plx
	pla
	rts
.endproc