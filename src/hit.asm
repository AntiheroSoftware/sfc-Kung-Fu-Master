;
; Kung Fu Master hit point display
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .feature	c_comments

			.include    "snes-sprite.inc"
			.include    "includes/score.inc"
			.include    "includes/hero.inc"
			.include    "includes/enemy.inc"

			.include 	"includes/hitData.asm"

            .export 	hitInit
            .export 	hitAdd
            .export 	hitProcess

            .export hitRemove

HIT_NUMBER 	= 15
HIT_TIMER 	= 10

HIT_ACTIVE_MASK = %10000000
HIT_TIMER_MASK 	= %01111111

.segment "BSS"

hitFlag:
	.res 1 * HIT_NUMBER

hitValue:
	.res 1 * HIT_NUMBER

hitOAMVOffset:
	.res 1 * HIT_NUMBER

hitOAMOffsetHigh:
	.res 1 * HIT_NUMBER

hitOAMOffsetLow:
	.res 1 * HIT_NUMBER

.segment "CODE"

.A8
.I16

;******************************************************************************
;*** hitInit ******************************************************************
;******************************************************************************

.proc hitInit
	php
	pha
	phx

	ldx #(HIT_NUMBER-1)
	lda #$00

:	sta hitFlag,X
	dex
	cpx #$00
	bne :-

	plx
	pla
	plp
	rts
.endproc

;******************************************************************************
;*** hitAdd *******************************************************************
;******************************************************************************
;*** Use EnemyCurrentXOffset and EnemyCurrentYOffset to determine pos of    ***
;*** the hit.																***
;*** Also use heroAnimAddr to determine wich kind of hit it is.				***
;*** A register contains enemyFlag 											***
;*** X register contains enemy number/offset								***
;******************************************************************************

.proc hitAdd
	php
	phy
	phx
	pha

	pha 							; save enemy flag

	lda #HIT_ACTIVE_MASK
	sta hitFlag,X

	;*** Calculate OAMOffset ***
	;***************************

	rep #$20
	.A16

	txa
	inc
	asl
	asl
	asl
	dec
	asl
	asl

	tay

	rep #$10
	sep #$20
	.A8
	.I16

	sta hitOAMOffsetLow,X
	lda #$00
	xba
	sta hitOAMOffsetHigh,X

	pla								; restore enemy Flag
	phx
	phy

	and #ENEMY_STATUS_TYPE_MASK
	clc
	rol
	rol
	rol
	tax
	phx

	rol
	tay

	;*** add Score ***
	;*****************

	lda heroHitType
	cmp #HERO_FLAG_HIT_KICK
	beq kick
punch:
	ldx hitPointsPunch,Y
	jsr updateScorePlayer1
	plx
	lda hitTilePunch,X
	bra :+
kick:
	ldx hitPointsKick,Y
	jsr updateScorePlayer1
	plx
	lda hitTileKick,X

:

	;*** set data in OAM (sprite 8 of enemy) ***
	;*******************************************

	ply
	plx

	sta oamData+2,Y					; A value was calculated right before

	lda EnemyArrayYOffset,X
	sec
	sbc #09
	sta oamData+1,Y
	sta hitOAMVOffset,X

	rep #$20
	.A16

	txa
	asl
	tax

	rep #$10
	sep #$20
	.A8
	.I16

	lda EnemyArrayXOffset,X
	clc
	adc #13
	sta oamData,Y

	lda #%00110101					; priority 3 / palette 2 / second sprite zone
	sta oamData+3,Y

	jsr OAMDataUpdated

	rep #$20
	.A16

	lda #$0000						; fix a register high byte TODO fix this

	rep #$10
	sep #$20
	.A8
	.I16

end:

	pla
	plx
	ply
	plp
	rts
.endproc

;******************************************************************************
;*** hitRemove ****************************************************************
;******************************************************************************
;*** X register contains the index of the hit to remove 					***
;******************************************************************************

.proc hitRemove
	php
	pha
	phy

	lda #$00
	sta hitFlag,X

	;*** clear data in OAM (sprite 8 of enemy) ***
	;*********************************************

	lda hitOAMOffsetHigh,X
	xba
	lda hitOAMOffsetLow,X
	tay

	lda #$e0
	sta oamData+1,Y

	ply
	pla
	plp
	rts
.endproc

;******************************************************************************
;*** hitProcess ***************************************************************
;******************************************************************************

.proc hitProcess
	php
	pha
	phx

	ldx #$0000

:	lda hitFlag,X
	bit #HIT_ACTIVE_MASK
	beq skip

	inc
	sta hitFlag,X
	cmp #HIT_ACTIVE_MASK+HIT_TIMER
	bne noRemove

	jsr hitRemove
	bra skip

noRemove:

	lda hitOAMOffsetHigh,X
	xba
	lda hitOAMOffsetLow,X
	tay

	lda hitOAMVOffset,X
	sta oamData+1,Y

skip:
	inx
	cpx #(HIT_NUMBER-1)
	bne :-

	plx
	pla
	plp
	rts
.endproc