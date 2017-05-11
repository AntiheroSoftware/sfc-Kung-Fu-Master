;
; Kung Fu Master letter splash
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .feature	c_comments

            .include    "snes.inc"
            .include    "snes-pad.inc"
            .include    "snes-event.inc"
            .include    "../includes/commonSplash.inc"
			.include	"../includes/font.inc"

            .export 	letterSplash
            .import 	playGame

.segment "BANK1"

letterHandTiles:
	.incbin "../ressource/letterHandBlank.pic"

letterHandMap:
	.incbin "../ressource/letterHandBlank.map"

letterHandPal:
	.incbin "../ressource/letterHandBlank.clr"

.segment "CODE"

.A8
.I16

.proc letterSplash

	setINIDSP $80   				; Enable forced VBlank during DMA transfer

	jsr removeAllEvent

	setBG1SC SPLASH_MAP_ADDR, $00
	setBG12NBA SPLASH_TILE_ADDR, $0000

	VRAMLoad letterHandTiles, SPLASH_TILE_ADDR, $0A20
	VRAMLoad letterHandMap, SPLASH_MAP_ADDR, $800
	CGRAMLoad letterHandPal, $00, $20

	;*** Font data loading ***
	;*************************

	VRAMLoad fontTiles, $0510, $0800
	CGRAMLoad letterGreyPal, $10, $20
	CGRAMLoad letterRedPal, $20, $20

	lda #$01
	ldx #SPLASH_MAP_ADDR
	ldy #$0051
	jsr initFont

	ldx #$0006
	ldy #$0005
	jsr setFontCursorPosition

	ldx #.LOWORD(letterIntroString)
	jsr writeFontString

	;*** End of font stuff ***
	;*************************

	lda #$01         ; enable main screen 1 + disable sprite (because title screen was using sprites)
	sta $212c

	ldx #$0500
	jsr splashScreenInit

	lda #.BANKBYTE(splashScreenEvent)
	ldx #.LOWORD(splashScreenEvent)
	ldy #$0000
	jsr addEvent					; add splash event

	setINIDSP $00   				; Enable screen full darkness

infiniteSplashLoop:

	lda #$00
	jsr isEventActive
	cmp #$01
	beq wait

	jmp playGame

wait:
	wai
	jmp infiniteSplashLoop

.endproc