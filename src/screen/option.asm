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

            .export 	optionScreen
            .import 	titleScreen

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
optionExitString:
    .byte $01,"EXIT",$00

.proc optionScreen

	jsr removeAllEvent

	setBG1SC OPTION_MAP_ADDR, $00
	setBG12NBA OPTION_TILE_ADDR, $0000

	;*** Font data loading ***
	;*************************

	wai 							; wait for interrupt (VBLANK)

	lda #$01
	ldx #OPTION_MAP_ADDR
	ldy #$008d
	jsr initFont

	ldx #.LOWORD(screenBuffer)
	jsr initFontBuffer

	ldx #$000c
	ldy #$000a
	jsr setFontCursorPosition

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

	; TODO clear hero sprite

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