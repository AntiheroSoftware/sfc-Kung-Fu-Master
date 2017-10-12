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
			.include	"../includes/screen.inc"
			.include	"../includes/hero.inc"

            .export 	optionScreen
            .import 	titleScreenReload

            .import 	titleScreenTiles
            .import 	titleScreenMap
            .import 	titleScreenPal

            .export optionsString
            .export optionExitString

OPTION_TILE_ADDR	= $0000
OPTION_MAP_ADDR     = $1000

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
	.word $0020
	.byte $53
	.byte .BANKBYTE(titleScreenReload)
	.word .LOWORD(titleScreenReload)
	.byte $20
	.byte $08

	.word $0020
	.byte $63
	.byte .BANKBYTE(titleScreenReload)
	.word .LOWORD(titleScreenReload)
	.byte $00
	.byte $10

	.word $0020
	.byte $73
	.byte .BANKBYTE(titleScreenReload)
	.word .LOWORD(titleScreenReload)
	.byte $08
	.byte $18

	.word $0020
	.byte $83
	.byte .BANKBYTE(titleScreenReload)
	.word .LOWORD(titleScreenReload)
	.byte $10
	.byte $20

	.word $0020
	.byte $93
	.byte .BANKBYTE(titleScreenReload)
	.word .LOWORD(titleScreenReload)
	.byte $18
	.byte $00

.segment "CODE"

.A8
.I16

optionsString:
    .byte $01,"DIFFICULTY ",$02,"< NORMAL >",$01,$0a,$0a
    .byte $01,"LIVES      ",$02,"< 3 >",$01,$0a,$0a
    .byte $01,"CONTINUE   ",$02,"< 3 >",$01,$0a,$0a
    .byte $01,"SOUND      ",$02,"< STEREO >",$01,$0a,$0a
optionExitString:
    .byte $01,"EXIT",$00

.proc optionScreen

	jsr removeAllEvent

	setBG1SC OPTION_MAP_ADDR, $00
	setBG12NBA OPTION_TILE_ADDR, $0000

	;*** Font data loading ***
	;*************************

	lda #$01
	ldx #OPTION_MAP_ADDR
	ldy #$008d
	jsr initFont

	ldx #.LOWORD(screenBuffer)
	jsr initFontBuffer

	ldx #$000c
	ldy #$000a
	jsr setFontCursorPosition

	lda #$01
	ldx #$0009
	ldy #$0005
	jsr clearFontZone

	ldx #$0007
	ldy #$000b
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

	; set the event that handle knife cursor
	lda #.BANKBYTE(cursorEvent)
	ldx #.LOWORD(cursorEvent)
	ldy #$0001
	jsr addEvent

	; set the event that copy the buffer to VRAM only once
	lda #.BANKBYTE(copyFontBufferToVRAMOnceEvent)
	ldx #.LOWORD(copyFontBufferToVRAMOnceEvent)
	ldy #$0002
	jsr addEvent

	; clear hero sprite
	jsr clearHeroSprite
	jsr OAMDataUpdated

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