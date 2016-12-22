;
; Kung Fu Master ennemies strategy to appear on screen
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .feature	c_comments
            .linecont

			.include    "includes/enemy.inc"


            ENEMY_STRATEGY_MAIN_CODE = 1
			.include    "includes/enemyStrategy.inc"

            .export 	enemyStrategyInit
            .export 	enemyStrategyGrab

ENEMY_GRAB_INTERVAL = 100

.segment "ZEROPAGE"

.segment "BSS"

enemyStrategyGrabCounter:
	.res 2

.segment "CODE"

.A8
.I16

;******************************************************************************
;*** enemyStrategyInit ********************************************************
;******************************************************************************
;***                     				    					     		***
;******************************************************************************

.proc enemyStrategyInit
	php
	phx

	ldx #ENEMY_GRAB_INTERVAL
	stx enemyStrategyGrabCounter

	plx
	plp
	rts
.endproc

;******************************************************************************
;*** enemyStrategyGrab ********************************************************
;******************************************************************************
;***                     				    					     		***
;******************************************************************************

.proc enemyStrategyGrab
	php
	pha
	phx

	ldx enemyStrategyGrabCounter
	cpx #$0000
	bne decrement

	lda #$00						; set enemy type
	ora #ENEMY_STATUS_TYPE_GRAB		; grab
	;ora #ENEMY_STATUS_MIRROR_FLAG	; in mirror mode
	jsr findEmptySlotEnemy			; Load X with a free enemy slot ( 0 - 13 )

	cpx #$ffff
	beq decrement

	jsr addEnemy

	ldx #ENEMY_GRAB_INTERVAL
	stx enemyStrategyGrabCounter
	bra end

decrement:
	ldx enemyStrategyGrabCounter
	dex
	stx enemyStrategyGrabCounter

end:

	plx
	pla
	plp
	rts
.endproc