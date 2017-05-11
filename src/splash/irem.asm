;
; Kung Fu Master irem splash
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .feature	c_comments

            .include    "snes.inc"
            .include    "snes-pad.inc"
            .include    "snes-event.inc"
			.include    "../includes/commonSplash.inc"


            .export 	iremSplash
            .import 	titleScreen

.segment "BANK1"

iremSplashTiles:
    .incbin "../ressource/irem.pic"

iremSplashMap:
    .incbin "../ressource/irem.map"

iremSplashPal:
    .incbin "../ressource/irem.clr"

.segment "CODE"

.A8
.I16

.proc iremSplash

	setINIDSP $80   				; Enable forced VBlank during DMA transfer

	jsr removeAllEvent

	setBG1SC SPLASH_MAP_ADDR, $00
	setBG12NBA SPLASH_TILE_ADDR, $0000

	VRAMLoad iremSplashTiles, SPLASH_TILE_ADDR, $0980
	VRAMLoad iremSplashMap, SPLASH_MAP_ADDR, $800
	CGRAMLoad iremSplashPal, $00, $20

	lda #$01        ; setBGMODE(0, 0, 1);
	sta $2105

	lda #$01         ; enable main screen 1
	sta $212c

	lda #$00         ; disable all sub screen
	sta $212d

	ldx #$0100
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

	jmp titleScreen

wait:
	wai
	jmp infiniteSplashLoop

.endproc