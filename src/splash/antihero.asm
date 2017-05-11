;
; Kung Fu Master antihero splash
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .feature	c_comments

            .include    "snes.inc"
            .include    "snes-pad.inc"
            .include    "snes-event.inc"
            .include    "../includes/commonSplash.inc"

			.export 	antiheroSplash
            .import 	iremSplash

.segment "BANK1"

antiheroSplashTiles:
    .incbin "../ressource/splash.pic"

antiheroSplashMap:
    .incbin "../ressource/splash.map"

antiheroSplashPal:
    .incbin "../ressource/splash.clr"

.segment "CODE"

.A8
.I16

.proc antiheroSplash

	setINIDSP $80   				; Enable forced VBlank during DMA transfer

	jsr removeAllEvent

	setBG1SC SPLASH_MAP_ADDR, $00
	setBG12NBA SPLASH_TILE_ADDR, $0000

	VRAMLoad antiheroSplashTiles, SPLASH_TILE_ADDR, $0980
	VRAMLoad antiheroSplashMap, SPLASH_MAP_ADDR, $800
	CGRAMLoad antiheroSplashPal, $00, $20

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

	jmp iremSplash

wait:
	wai
	jmp infiniteSplashLoop

.endproc
