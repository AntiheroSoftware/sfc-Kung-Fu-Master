.linecont

.IFNDEF ENEMY_MAIN_CODE

    .import 	initEnemySprite
    .import     reactEnemy

    .import     hdmaInitTitle
    .import     hdmaInitGame

.ENDIF

ENEMY_DATA_BANK = $01

; First 3 bits of Flag reserved for shaking counter if it's a grab enemy

ENEMY_STATUS_SHAKE_COUNT_INIT   = %00000101
ENEMY_STATUS_SHAKE_COUNT_MASK 	= %00000111

ENEMY_STATUS_ACTIVE_FLAG 		= %00001000
ENEMY_STATUS_MIRROR_FLAG 		= %00010000

ENEMY_STATUS_TYPE_GRAB			= %00100000
ENEMY_STATUS_TYPE_KNIFE			= %01000000
ENEMY_STATUS_TYPE_MIDGET		= %01100000

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

.macro _EnemyDataIndexSetFromXIndex
    pha
    rep #$20
    .A16

    txa
    and #$00ff
    sta EnemyCurrentArrayIndexByte
    asl								; index slot * 2
    sta EnemyCurrentArrayIndexWord
    lda EnemyCurrentArrayIndexByte	; restore value

    rep #$10
    sep #$20
    .A8
    .I16
    pla
.endmacro

.macro _EnemyDataLDA variableName
    phx
    .if    (.xmatch(EnemyArrayAnimFrameIndex, {variableName}) \
            .or .xmatch(EnemyArrayAnimFrameCounter, {variableName}) \
            .or .xmatch(EnemyArrayAnimJumpFramecounter, {variableName}) \
            .or .xmatch(EnemyArrayFlag, {variableName}))
    ldx EnemyCurrentArrayIndexByte
    lda variableName,X
    .else
        .error "_EnemyDataLDA: that variable don't exist"
    .endif
    plx
.endmacro

.macro _EnemyDataLDX variableName
    phy
    .if    (.xmatch(EnemyArrayAnimAddress, {variableName}) \
            .or .xmatch(EnemyArrayXOffset, {variableName}) \
            .or .xmatch(EnemyArrayOAMSlotOffset, {variableName}))
    ldy EnemyCurrentArrayIndexWord
    ldx variableName,Y
    .else
        .error "_EnemyDataLDX: that variable don't exist"
    .endif
    ply
.endmacro

.macro _ResetEnemyShakingCounter

    lda EnemyArrayFlag,X
    and #<.BITNOT(ENEMY_STATUS_SHAKE_COUNT_MASK)
    ora #ENEMY_STATUS_SHAKE_COUNT_INIT
    sta EnemyArrayFlag,X

.endmacro

.macro _GetEnemyShakingCounter

.endmacro

.macro _setEnemyShakingCounter

    pha
    lda EnemyArrayFlag,X
    and #<.BITNOT(ENEMY_STATUS_SHAKE_COUNT_MASK)
    sta EnemyArrayFlag,X
    pla
    and EnemyArrayFlag,X
    sta EnemyArrayFlag,X

.endmacro