.segment "BANK1"

enemySpritePal:
    .incbin "../ressource/spriteFull.clr"

spriteBaseTiles:
	.incbin "../ressource/spriteFull.pic", $0000, $2000

.segment "BANK3"

enemySpriteFullTiles:
	.incbin "../ressource/spriteFull.pic", $2000

enemySpriteBank1Tiles := enemySpriteFullTiles
enemySpriteBank2Tiles := enemySpriteFullTiles + $2000
enemySpriteBank3Tiles := enemySpriteFullTiles + $4000
enemySpriteBank4Tiles := enemySpriteFullTiles + $6000

.segment "RODATA"

hdmaMemTitle:
	.byte $68,%00000001,$20,%00000001,$10,%00001001,$10,%00010001,$10,%00011001,$00

hdmaMemGame:
	.byte $70,%00000001,$20,%00000001,$10,%00001001,$10,%00010001,$10,%00011001,$00

verticalOffsetTable:
	.byte $80, $90, $a0, $b0

.segment "BANK1"

highByte:
	.byte %10101010
	.byte %10101011
	.byte %10101110
	.byte %10101111
	.byte %10111010
	.byte %10111011
	.byte %10111110
	.byte %10111111
	.byte %11101010
	.byte %11101011
	.byte %11101110
	.byte %11101111
	.byte %11111010
	.byte %11111011
	.byte %11111110
	.byte %11111111

metaspriteStatusNormal:
	.byte %00110101
	.byte %00110111
	.byte %00111001
	.byte %00111011
	.byte %10110101
	.byte %10110111
	.byte %10111001
	.byte %10111011
	.byte %00110100
	.byte %00110110
	.byte %00111000
	.byte %00111010
	.byte %10110100
	.byte %10110110
	.byte %10111000
	.byte %10111010

metaspriteStatusMirror:
	.byte %01110101
	.byte %01110111
	.byte %01111001
	.byte %01111011
	.byte %11110101
	.byte %11110111
	.byte %11111001
	.byte %11111011
	.byte %01110100
	.byte %01110110
	.byte %01111000
	.byte %01111010
	.byte %11110100
	.byte %11110110
	.byte %11111000
	.byte %11111010

;******************************************************************************
;*** Sprite definition ********************************************************
;******************************************************************************

;******************************************************************************
;*** Metasprites **************************************************************
;******************************************************************************
;*** Number of horizontal tiles + STATUS bits                               ***
;*** Y offset of the line                                                   ***
;*** X offset                                                               ***
;*** X offset Mirror                                                        ***
;*** Tile Number                                                            ***
;******************************************************************************

grabbingWalk1:						; 4 sprite blocks
	.byte   ENEMY_MS_GRAB_PAL + $01, $00, $09, $09, $00
	.byte   ENEMY_MS_GRAB_PAL + $01, $10, $09, $08, $00
	.byte   ENEMY_MS_GRAB_PAL + $01, $20, $09, $09, $00
	.byte   ENEMY_MS_GRAB_PAL + $01, $30, $09, $09, $00
	.byte	$00

grabbingWalk2:						; 6 sprite blocks
	.byte   ENEMY_MS_GRAB_PAL + $01, $00, $09, $09, $00
	.byte   ENEMY_MS_GRAB_PAL + $01, $10, $08, $09, $02
	.byte   ENEMY_MS_GRAB_PAL + $02, $20, $02, $11, $02
	.byte 			  			$11, $02, $04
	.byte   ENEMY_MS_GRAB_PAL + $02, $30, $02, $11, $02
	.byte 			  			$11, $02, $04
	.byte	$00

grabbingWalk3:						; 6 sprite blocks
	.byte   ENEMY_MS_GRAB_PAL + $01, $00, $09, $09, $00
	.byte   ENEMY_MS_GRAB_PAL + $01, $10, $09, $08, $04
	.byte   ENEMY_MS_GRAB_PAL + $02, $20, $01, $10, $06
	.byte  			  			$10, $01, $08
	.byte   ENEMY_MS_GRAB_PAL + $02, $30, $01, $10, $06
	.byte 			  			$10, $01, $08
	.byte	ENEMY_MS_GRAB_PAL + $00

grabbingArmUpWalk1:					; 4 sprite blocks
	.byte   ENEMY_MS_GRAB_PAL + $01, $00, $09, $09, $02
	.byte   ENEMY_MS_GRAB_PAL + $01, $10, $09, $08, $08
	.byte   ENEMY_MS_GRAB_PAL + $01, $20, $09, $09, $0c
	.byte   ENEMY_MS_GRAB_PAL + $01, $30, $09, $09, $0e
	.byte	$00

grabbingArmUpWalk2:					; 5 sprite blocks
	.byte   ENEMY_MS_GRAB_PAL + $01, $00, $09, $09, $02
	.byte   ENEMY_MS_GRAB_PAL + $01, $10, $08, $09, $06
	.byte   ENEMY_MS_GRAB_PAL + $01, $20, $08, $09, $0a
	.byte   ENEMY_MS_GRAB_PAL + $02, $30, $02, $11, $0a
	.byte 			  			$11, $02, $0c
	.byte	$00

grabbingArmUpWalk3:					; 5 sprite blocks
	.byte   ENEMY_MS_GRAB_PAL + $01, $00, $09, $09, $02	; right foot in front (normal mode)
	.byte   ENEMY_MS_GRAB_PAL + $01, $10, $09, $09, $0a ; left foot in front (mirror mode)
	.byte   ENEMY_MS_GRAB_PAL + $01, $20, $0c, $06, $20
	.byte   ENEMY_MS_GRAB_PAL + $02, $30, $03, $11, $20
	.byte 			  			$12, $02, $22
	.byte	$00

grabbingGrab1:
	.byte   ENEMY_MS_GRAB_PAL + $01, $00, $09, $09, $04
	.byte   ENEMY_MS_GRAB_PAL + $02, $10, $09, $08, $0c
	.byte 			  			$18, $f8, $0e
	.byte   ENEMY_MS_GRAB_PAL + $01, $20, $09, $09, $0e
	.byte   ENEMY_MS_GRAB_PAL + $01, $30, $09, $09, $24
	.byte	$00

;******************************************************************************
;*** Animation frames *********************************************************
;******************************************************************************
;*** number of frames                                                       ***
;*** metasprite definition address                                          ***
;******************************************************************************

grabbingWalk:
	.byte $08
	.word .LOWORD(grabbingWalk1)
	.byte $08
	.word .LOWORD(grabbingWalk2)
	.byte $08
	.word .LOWORD(grabbingWalk1)
	.byte $08
	.word .LOWORD(grabbingWalk3)
	.byte $00

grabbingArmUpWalk:
	.byte $08
	.word .LOWORD(grabbingArmUpWalk1)
	.byte $08
	.word .LOWORD(grabbingArmUpWalk2)
	.byte $08
	.word .LOWORD(grabbingArmUpWalk1)
	.byte $08
	.word .LOWORD(grabbingArmUpWalk3)
	.byte $00

grabbingGrab:
	.byte $08								; value is 8 cause we use frame counter to lose energy counter
	.word .LOWORD(grabbingGrab1)
	.byte $00