.IFNDEF HERO_MAIN_CODE

    .import 	initHeroSprite
    .import     transferHeroSpriteDataEvent
    .import     reactHero
    .importzp   heroXOffset
    .importzp   heroFlag
    .importzp   heroHitOffset
    .importzp   heroHitZone
    .importzp   heroHitType

.ENDIF

HERO_STATUS_MIRROR_FLAG 				= %00000001
HERO_STATUS_SHAKING_FLAG 				= %00000010
HERO_STATUS_LAST_SHAKE_DIRECTION_FLAG 	= %00000100
HERO_STATUS_GRAB_FLAG 					= %00001000

HERO_FLAG_HIT_HIGH             = %00000000
HERO_FLAG_HIT_MID              = %10000000
HERO_FLAG_HIT_LOW              = %11000000

HERO_FLAG_HIT_NONE             = %00000000
HERO_FLAG_HIT_KICK             = %00000001
HERO_FLAG_HIT_PUNCH            = %00000010

SPRITE_DATA_BANK 	= $02

.macro _ResetHeroGrabFlag

    pha
    lda heroFlag
    and #<.BITNOT(HERO_STATUS_GRAB_FLAG)
    sta heroFlag								; reset grab flag
    pla

.endmacro

.macro _GetHeroGrabFlag

    lda heroFlag
    and #HERO_STATUS_GRAB_FLAG

.endmacro

.macro _SetHeroGrabFlag

    pha
    lda heroFlag
    ora #HERO_STATUS_GRAB_FLAG
    sta heroFlag
    pla

.endmacro

.macro _GetHeroShakingFlag

    lda heroFlag
    and #HERO_STATUS_SHAKING_FLAG

.endmacro

.macro _CheckHeroMirrorMode

    lda padFirstPushDataLow1
    bit #PAD_LOW_LEFT
    beq :+
    jsr setMirrorSpriteMode
    lda #$01
    sta forceRefresh
    bra :++

:	lda padFirstPushDataLow1
    bit #PAD_LOW_RIGHT
    beq :+
    jsr setNormalSpriteMode
    lda #$01
    sta forceRefresh
:

.endmacro