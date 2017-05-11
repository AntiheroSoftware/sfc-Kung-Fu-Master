;
; Kung Fu Master option screen
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .feature	c_comments

            .include    "snes.inc"
            .include    "snes-pad.inc"
			.include    "snes-event.inc"
			.include    "snes-sprite.inc"
			.include	"../includes/base.inc"
			.include	"../includes/events.inc"
            .include	"../includes/font.inc"
			.include	"../includes/cursor.inc"

            .export 	optionScreen
            .import 	titleScreen

            .import 	titleScreenTiles
            .import 	titleScreenMap
            .import 	titleScreenPal

OPTION_TILE_ADDR	= $0000
OPTION_MAP_ADDR     = $1000

.segment "BANK1"

/*
titleScreenTiles:
    .incbin "../ressource/titleScreen.pic"

titleScreenMap:
    .incbin "../ressource/titleScreen.map"

titleScreenPal:
    .incbin "../ressource/titleScreen.clr"
*/

.segment "RODATA"

;******************************************************************************
;*** structure of cursor data *************************************************
;******************************************************************************
;*** xpos			word													***
;*** ypos			byte													***
;*** dstBank		byte													***
;*** dstAddr		word													***
;*** previousOffset	byte													***
;*** nextOffset		byte													***
;******************************************************************************

optionCursorList:
	.word $004a
	.byte $4b
	.byte .BANKBYTE(titleScreen)
	.word .LOWORD(titleScreen)
	.byte $18
	.byte $08

	.word $004a
	.byte $5b
	.byte .BANKBYTE(titleScreen)
	.word .LOWORD(titleScreen)
	.byte $00
	.byte $10

	.word $004a
	.byte $6b
	.byte .BANKBYTE(titleScreen)
	.word .LOWORD(titleScreen)
	.byte $08
	.byte $18

	.word $004a
	.byte $7b
	.byte .BANKBYTE(titleScreen)
	.word .LOWORD(titleScreen)
	.byte $10
	.byte $00

.segment "CODE"

.A8
.I16

optionsString:
    .byte $01,"LIVES",$0a,$0a
    .byte $01,"CONTINUE",$0a,$0a
    .byte $01,"DIFFICULTY",$0a,$0a
    .byte $01,"EXIT",$00

.proc optionScreen

	setINIDSP $80   				; Enable forced VBlank during DMA transfer

	jsr removeAllEvent

	setBG1SC OPTION_MAP_ADDR, $00
	setBG12NBA OPTION_TILE_ADDR, $0000

	;VRAMLoad titleScreenTiles, OPTION_TILE_ADDR, $11A0
	VRAMLoad titleScreenMap, OPTION_MAP_ADDR, $800
	;CGRAMLoad titleScreenPal, $00, $20

	;*** Font data loading ***
	;*************************

	;VRAMLoad fontTiles, $08D0, $0800
	;CGRAMLoad titleScreenWhitePal, $10, $20
	;CGRAMLoad titleScreenYellowPal, $20, $20
	;CGRAMLoad titleScreenWhiteRedPal, $30, $20

	lda #$01
	ldx #OPTION_MAP_ADDR
	ldy #$008d
	jsr initFont

	ldx #$000c
	ldy #$000a
	jsr setFontCursorPosition

	ldx #.LOWORD(optionsString)
	jsr writeFontString

	;*** End of font stuff ***
	;*************************

	lda #$11         				; enable main screen 1 +sprite
	sta $212c

	ldx #.LOWORD(optionCursorList)
	jsr initCursor

	; set the event that copy OAM data
	lda #.BANKBYTE(copyOAMEvent)
	ldx #.LOWORD(copyOAMEvent)
	ldy #$0000
	jsr addEvent

	; set the event that transfer hero tile data
	lda #.BANKBYTE(cursorEvent)
	ldx #.LOWORD(cursorEvent)
	ldy #$0001
	jsr addEvent

	setINIDSP $0f   				; Enable screen full brightness

infiniteLoop:

	lda cursorTargetSet
	cmp #$01
	bne skipToWait

jump:
	jmp [cursorTarget]

skipToWait:
	wai
	bra infiniteLoop

.endproc