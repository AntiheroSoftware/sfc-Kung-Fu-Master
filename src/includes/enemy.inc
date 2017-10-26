.linecont

.IFNDEF ENEMY_MAIN_CODE

    .import 	initEnemySprite
    .import     reactEnemy
    .import 	addEnemy
    .import 	findEmptySlotEnemy
    .import 	EnemyArrayXOffset
    .import 	EnemyArrayYOffset

.ENDIF

ENEMY_DATA_BANK = $81

; First 3 bits of Flag reserved for shaking counter if it's a grab enemy

ENEMY_STATUS_SHAKE_COUNT_INIT   = %00000110     ; need 4  left/right to get out of grab
ENEMY_STATUS_SHAKE_COUNT_MASK 	= %00000111

ENEMY_STATUS_HIT_MASK           = %00001000
ENEMY_STATUS_HIT_HIGH           = %00001000
ENEMY_STATUS_HIT_MID            = %00001010
ENEMY_STATUS_HIT_LOW            = %00001011

ENEMY_STATUS_ACTIVE_FLAG 		= %00010000
ENEMY_STATUS_MIRROR_FLAG 		= %00100000

ENEMY_STATUS_TYPE_MASK			= %11000000
ENEMY_STATUS_TYPE_GRAB			= %01000000
ENEMY_STATUS_TYPE_KNIFE			= %10000000
ENEMY_STATUS_TYPE_MIDGET		= %11000000

ENEMY_MS_UZONE     = %10000000  ; sprite char is in up zone (bit 5)
ENEMY_MS_VFLIP     = %01000000  ; vertical flip (bit 8)
ENEMY_MS_SMALL_PAL = %00000000  ; palette 1 for enemy small guys (bit 6-7)
ENEMY_MS_KNIFE_PAL = %00000000  ; palette 1 for enemy knife guys (bit 6-7)
ENEMY_MS_GRAB_PAL  = %00010000  ; palette 2 for enemy grab guys (bit 6-7)
ENEMY_MS_BLOCK_NUMBER_MASK = %00001111

ENEMY_NORMAL_GRAB_DISTANCE_ARMS_UP 	= $30
ENEMY_NORMAL_GRAB_DISTANCE_GRAB 	= $04

ENEMY_MIRROR_GRAB_DISTANCE_ARMS_UP	= $30
ENEMY_MIRROR_GRAB_DISTANCE_GRAB 	= $04

.macro _EnemyDataIndexSetFromAccumulator
    rep #$20
    .A16

    and #$00ff
    sta EnemyCurrentArrayIndexByte
    asl								; index slot * 2
    sta EnemyCurrentArrayIndexWord
    lda EnemyCurrentArrayIndexByte	; restore value

    rep #$10
    sep #$20
    .A8
    .I16
.endmacro

.macro _ResetEnemyShakingCounter

    lda EnemyArrayFlag,X
    and #<.BITNOT(ENEMY_STATUS_SHAKE_COUNT_MASK)
    ora #ENEMY_STATUS_SHAKE_COUNT_INIT
    sta EnemyArrayFlag,X

.endmacro

.macro _setEnemyShakingCounter

    pha
    lda EnemyArrayFlag,X
    and #<.BITNOT(ENEMY_STATUS_SHAKE_COUNT_MASK)
    sta EnemyArrayFlag,X
    pla
    ora EnemyArrayFlag,X
    sta EnemyArrayFlag,X

.endmacro