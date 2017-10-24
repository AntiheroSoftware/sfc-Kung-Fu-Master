;
; Kung Fu Master title screen
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
			.include	"../includes/hero.inc"
			.include	"../includes/enemy.inc"
            .include	"../includes/font.inc"
			.include	"../includes/cursor.inc"
			.include	"../includes/screen.inc"
			.include	"../includes/highScore.inc"

            .export 	titleScreen
            .import 	letterSplash
            .import 	optionScreen

            .export 	titleScreenTiles
			.export 	titleScreenMap
			.export 	titleScreenPal

TITLE_TILE_ADDR	= $0000
TITLE_MAP_ADDR	= $1000

.segment "BANK1"

titleScreenTiles:
    .incbin "../ressource/titleScreen.pic"

titleScreenMap:
    .incbin "../ressource/titleScreen.map"

titleScreenPal:
    .incbin "../ressource/titleScreen.clr"

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
;*** padMask		word													***
;******************************************************************************

titleCursorList:
	.word $004a
	.byte $4b
	.byte .BANKBYTE(letterSplash)
	.word .LOWORD(letterSplash)
	.byte $14
	.byte $0a
	.word PAD_START | PAD_A

	.word $004a
	.byte $5b
	.byte .BANKBYTE(letterSplash)
	.word .LOWORD(letterSplash)
	.byte $00
	.byte $14
	.word PAD_START | PAD_A

	.word $004a
	.byte $6b
	.byte .BANKBYTE(optionScreen)
	.word .LOWORD(optionScreen)
	.byte $0a
	.byte $00
	.word PAD_START | PAD_A

.segment "CODE"

.A8
.I16

.proc titleScreen

	setINIDSP $80   				; Enable forced VBlank during DMA transfer

	WRAMLoad titleScreenMap, screenBuffer, $800 	; copy title screen map to WRAM

	setBG1SC TITLE_MAP_ADDR, $00
	setBG12NBA TITLE_TILE_ADDR, $0000

	VRAMLoad titleScreenTiles, TITLE_TILE_ADDR, $11A0
	VRAMLoad titleScreenMap, TITLE_MAP_ADDR, $800
	CGRAMLoad titleScreenPal, $00, $20

	;*** Font data loading ***
	;*************************

	VRAMLoad fontTiles, $08D0, $0800
	CGRAMLoad titleScreenWhitePal, $10, $20
	CGRAMLoad titleScreenYellowPal, $20, $20
	CGRAMLoad titleScreenWhiteRedPal, $30, $20

titleScreenReload:

	lda #$01
	ldx #TITLE_MAP_ADDR
	ldy #$008d
	jsr initFont

	ldx #.LOWORD(screenBuffer)
	jsr initFontBuffer

	ldx #$0007
	ldy #$000b
	jsr setFontCursorPosition

	lda #$01
	ldx #$0015
	ldy #$0009
	jsr clearFontZone

	ldx #$000c
	ldy #$000a
	jsr setFontCursorPosition

	ldx #.LOWORD(titleScreenSelectString)
	jsr writeFontString

	ldx #$0006
	ldy #$0018
	jsr setFontCursorPosition

	ldx #.LOWORD(titleScreenCopyrightString)
	jsr writeFontString

	;*** End of font stuff ***
	;*************************

	lda #HERO_TITLE_SCREEN_Y_OFFSET
	jsr initHeroSprite
	jsr initEnemySprite

	lda #$11         				; enable main screen 1 +sprite
	sta $212c

	; reset BG1 scroll register
	stz $210d
	stz $210e

	jsr removeAllEvent

	; set the event that copy OAM data
	lda #.BANKBYTE(copyOAMEvent)
	ldx #.LOWORD(copyOAMEvent)
	ldy #$0000
	jsr addEvent

	; set the event that trasnfer hero tile data
	lda #.BANKBYTE(transferHeroSpriteDataEvent)
	ldx #.LOWORD(transferHeroSpriteDataEvent)
	ldy #$0001
	jsr addEvent

	ldx #.LOWORD(titleCursorList)
	jsr initCursor

	; set the event that trasnfer hero tile data
	lda #.BANKBYTE(cursorEvent)
	ldx #.LOWORD(cursorEvent)
	ldy #$0002
	jsr addEvent

	; set the event that copy the buffer to VRAM only once
	lda #.BANKBYTE(copyFontBufferToVRAMOnceEvent)
	ldx #.LOWORD(copyFontBufferToVRAMOnceEvent)
	ldy #$0003
	jsr addEvent

	setINIDSP $0f   				; Enable screen full brightness

setupTimer:

	ldx #(60 * 30)						; frame per second * 30 seconds

infiniteLoop:

	phx

	; TODO set automated reactHero
	; ldx padPushData1
	; jsr reactHero

	lda cursorTargetSet
	cmp #$01
	bne skipToWait

jump:
	jmp [cursorTarget]

skipToWait:
	jsr waitForVBlank

	plx

	dex
	cpx #$0000
	bne infiniteLoop

	jsr highScoreMainLoop

	jmp titleScreen

.endproc

.export 	titleScreenReload = titleScreen::titleScreenReload