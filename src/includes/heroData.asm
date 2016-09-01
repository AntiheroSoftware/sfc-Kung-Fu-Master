.segment "BANK2"

KFM_Player_final_Tiles:
	.incbin "../ressource/KFM_Player_final_sprite.pic"

KFM_Player_final_Pal:
	.incbin "../ressource/KFM_Player_final_sprite.clr"

;******************************************************************************
;*** Hero Sprite definition ***************************************************
;******************************************************************************

;******************************************************************************
;*** Metasprites **************************************************************
;******************************************************************************
;*** Adress in bank for tiles                                               ***
;*** Number of horizontal tiles                                             ***
;*** Y offset of the line                                                   ***
;*** X offset                                                               ***
;*** X offset Mirror                                                        ***
;*** Tile Number                                                            ***
;******************************************************************************

heroStand1:							; 7 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles)
	.byte   $01, $00, $0c, $1b, $00
	.byte   $02, $10, $0c, $1b, $02, $1b, $0c, $04
	.byte   $02, $20, $0c, $1b, $06, $1b, $0c, $08
	.byte   $02, $30, $0c, $1b, $0a, $1b, $0c, $0c
	.byte	$00

heroWalk1: 							; 7 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*1))
	.byte   $01, $00, $11, $05, $00
	.byte   $02, $10, $01, $15, $02, $10, $05, $04
	.byte   $02, $20, $03, $13, $06, $13, $03, $08
	.byte   $02, $30, $03, $13, $0a, $13, $03, $0c
	.byte	$00

heroWalk2:							; 4 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*2))
	.byte   $01, $00, $0a, $0c, $00
	.byte   $01, $10, $09, $0d, $02
	.byte   $01, $20, $09, $0d, $04
	.byte   $01, $30, $09, $0d, $06
	.byte	$00

heroWalk3:							; 7 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*3))
	.byte   $01, $00, $10, $06, $00
	.byte   $02, $10, $00, $16, $02, $0f, $06, $04
	.byte   $02, $20, $00, $16, $06, $0f, $06, $08
	.byte   $02, $30, $00, $16, $0a, $0f, $06, $0c
	.byte	$00

heroWalk4:							; 4 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*4))
	.byte   $01, $00, $0b, $0c, $00
	.byte   $01, $10, $0b, $0c, $02
	.byte   $01, $20, $0b, $0c, $04
	.byte   $01, $30, $0b, $0c, $06
	.byte	$00

heroDownStand1:						; 4 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*5))
	.byte   $01, $10, $00, $00, $00
	.byte   $01, $20, $00, $00, $02
	.byte   $02, $30, $00, $0f, $04, $0f, $00, $06
	.byte	$00

heroDownKick1:						; 5 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*6))
	.byte   $01, $10, $00, $00, $00
	.byte   $02, $20, $00, $0f, $02, $0f, $00, $04
	.byte   $02, $30, $00, $0f, $06, $0f, $00, $08
	.byte	$00

heroDownKick2:						; 7 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*7))
	.byte   $01, $10, $00, $00, $00
	.byte   $02, $20, $00, $0f, $02, $0f, $00, $04
	.byte   $04, $30, $00, $0f, $06, $0f, $00, $08, $1e, $0f, $0a, $2d, $00, $0c
	.byte	$00

heroDownPunch1:						; 6 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*8))
	.byte   $02, $10, $00, $0f, $00, $0f, $00, $02
	.byte   $02, $20, $00, $0f, $04, $0f, $00, $06
	.byte   $02, $30, $00, $0f, $08, $0f, $00, $0a
	.byte	$00

heroDownPunch2:						; 5 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*9))
	.byte   $01, $10, $00, $0f, $00
	.byte   $02, $20, $00, $0f, $04, $0f, $00, $06
	.byte   $02, $30, $00, $0f, $08, $0f, $00, $0a
	.byte	$00

heroDownPunch3:						; 6 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*10))
	.byte   $02, $10, $00, $0f, $00, $0f, $00, $02
	.byte   $02, $20, $00, $0f, $04, $0f, $00, $06
	.byte   $02, $30, $00, $0f, $08, $0f, $00, $0a
	.byte	$00

heroStandKick1:						; 7 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*11))
	.byte   $02, $00, $00, $0f, $00, $0f, $00, $02
	.byte   $02, $10, $00, $0f, $04, $0f, $00, $06
	.byte   $02, $20, $00, $0f, $08, $0f, $00, $0a
	.byte   $01, $30, $00, $0f, $0c
	.byte	$00

heroStandKick2:						; 7 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*12))
	.byte   $02, $00, $00, $0f, $00, $1e, $00, $02
	.byte   $03, $10, $00, $1e, $04, $0f, $0f, $06, $1e, $00, $08
	.byte   $01, $20, $00, $0f, $0a
	.byte   $01, $30, $00, $0f, $0c
	.byte	$00

heroStandPunch1:					; 7 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*13))
	.byte   $02, $00, $00, $0f, $00, $0f, $00, $02
	.byte   $02, $10, $00, $0f, $04, $0f, $00, $06
	.byte   $01, $20, $00, $0f, $08
	.byte   $02, $30, $00, $0f, $0a, $0f, $00, $0c
	.byte	$00

heroStandPunch2:					; 7 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*14))
	.byte   $01, $00, $00, $0f, $00
	.byte   $01, $10, $00, $0f, $04
	.byte   $01, $20, $00, $0f, $08
	.byte   $02, $30, $00, $0f, $0a, $0f, $00, $0c
	.byte	$00

heroStandPunch3:					; 7 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*15))
	.byte   $02, $00, $00, $0f, $00, $0f, $00, $02
	.byte   $02, $10, $00, $0f, $04, $0f, $00, $06
	.byte   $01, $20, $00, $0f, $08
	.byte   $02, $30, $00, $0f, $0a, $0f, $00, $0c
	.byte	$00

heroJump1:							; 4 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*16))
	.byte   $01, $00, $0a, $0c, $00
	.byte   $01, $10, $09, $0d, $02
	.byte   $01, $20, $09, $0d, $04
	.byte   $01, $30, $09, $0d, $06
	.byte	$00

heroJump2:							; 5 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*17))
	.byte   $01, $00, $0a, $0c, $00
	.byte   $01, $10, $09, $0d, $02
	.byte   $01, $20, $09, $0d, $04
	.byte   $01, $30, $09, $0d, $06
	.byte   $01, $40, $09, $0d, $08
	.byte	$00

heroJumpKick1:						; 8 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*18))
	.byte   $02, $00, $00, $0f, $00, $0f, $00, $02
	.byte   $02, $10, $00, $0f, $04, $0f, $00, $06
	.byte   $02, $20, $00, $0f, $08, $0f, $00, $0a
	.byte   $01, $30, $00, $0f, $0c
	.byte   $01, $40, $00, $0f, $0e
	.byte	$00

heroJump3:							; 5 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*19))
	.byte   $01, $00, $0a, $0c, $00
	.byte   $01, $10, $09, $0d, $02
	.byte   $01, $20, $09, $0d, $04
	.byte   $01, $30, $09, $0d, $06
	.byte   $01, $40, $09, $0d, $08
	.byte	$00

heroJumpRun1:						; 6 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*20))
	.byte   $01, $00, $00, $00, $00
	.byte   $02, $10, $00, $0f, $02, $0f, $00, $04
	.byte   $02, $20, $00, $0f, $06, $0f, $00, $08
	.byte   $01, $40, $00, $00, $0c
	.byte	$00

heroJumpRun2:						; 4 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*21))
	.byte   $01, $00, $0a, $0c, $00
	.byte   $01, $10, $09, $0d, $02
	.byte   $01, $20, $09, $0d, $04
	.byte   $01, $30, $09, $0d, $06
	.byte	$00

heroHitLow1:						; 4 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*22))
	.byte   $01, $00, $0a, $0c, $00
	.byte   $01, $10, $09, $0d, $02
	.byte   $01, $20, $09, $0d, $04
	.byte   $01, $30, $09, $0d, $06
	.byte	$00

heroHitHigh1:						; 4 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*23))
	.byte   $01, $00, $0a, $0c, $00
	.byte   $01, $10, $09, $0d, $02
	.byte   $01, $20, $09, $0d, $04
	.byte   $01, $30, $09, $0d, $06
	.byte	$00

heroGrabbed1:						; 4 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*24))
	.byte   $01, $00, $0a, $0c, $00
	.byte   $01, $10, $09, $0d, $02
	.byte   $01, $20, $09, $0d, $04
	.byte   $01, $30, $09, $0d, $06
	.byte	$00

heroFall1:							; 8 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*25))
	.byte   $02, $00, $00, $0f, $00, $0f, $00, $02
	.byte   $02, $10, $00, $0f, $04, $0f, $00, $06
	.byte   $02, $20, $00, $0f, $08, $0f, $00, $0a
	.byte   $02, $30, $00, $0f, $0c, $0f, $00, $0e

heroFall2:							; 8 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*26))
	.byte   $02, $00, $00, $0f, $00, $1e, $00, $02
	.byte   $03, $10, $00, $1e, $04, $0f, $0f, $06, $1e, $00, $0a
	.byte   $03, $20, $00, $1e, $0c, $0f, $0f, $0e, $1e, $00, $10
	.byte	$00

animationList:
	.word	.LOWORD(heroStand1)
	.word	.LOWORD(heroWalk1)
	.word	.LOWORD(heroWalk2)
	.word	.LOWORD(heroWalk3)
	.word	.LOWORD(heroWalk4)
	.word	.LOWORD(heroDownStand1)
	.word	.LOWORD(heroDownKick1)
	.word	.LOWORD(heroDownKick2)
	.word	.LOWORD(heroDownPunch1)
	.word	.LOWORD(heroDownPunch2)
	.word	.LOWORD(heroDownPunch3)
	.word	.LOWORD(heroStandKick1)
	.word	.LOWORD(heroStandKick2)
	.word	.LOWORD(heroStandPunch1)
	.word	.LOWORD(heroStandPunch2)
	.word	.LOWORD(heroStandPunch3)
	.word	.LOWORD(heroJump1)
	.word	.LOWORD(heroJump2)
	.word	.LOWORD(heroJump3)
	.word	.LOWORD(heroJumpRun1)
	.word	.LOWORD(heroJumpRun2)
	.word	.LOWORD(heroHitLow1)
	.word	.LOWORD(heroHitHigh1)
	.word	.LOWORD(heroGrabbed1)
	.word	.LOWORD(heroFall1)
	.word	.LOWORD(heroFall2)

;******************************************************************************
;*** Animation frames *********************************************************
;******************************************************************************
;*** number of frames                                                       ***
;*** metasprite definition address                                          ***
;******************************************************************************
;*** end of animation value :												***
;*** $00 -> loop															***
;*** $ff -> no loop  													    ***
;*** $fe -> loop with other animation if event							    ***
;******************************************************************************

heroStand:
	.byte $01
	.word .LOWORD(heroStand1)
	.byte $ff

heroWalk:
	.byte $08
	.word .LOWORD(heroWalk1)
	.byte $08
	.word .LOWORD(heroWalk2)
	.byte $08
	.word .LOWORD(heroWalk3)
	.byte $08
	.word .LOWORD(heroWalk4)
	.byte $00

heroDownStand:
	.byte $01
	.word .LOWORD(heroDownStand1)
	.byte $ff

heroDownKick:
	.byte $04
	.word .LOWORD(heroDownKick1)
	.byte $04
	.word .LOWORD(heroDownKick2)
	.byte $04
	.word .LOWORD(heroDownKick1)
	.byte $04
	.word .LOWORD(heroDownStand1)
	.byte $ff

heroDownPunch:
	.byte $08
	.word .LOWORD(heroDownPunch1)
	.byte $08
	.word .LOWORD(heroDownPunch2)
	.byte $08
	.word .LOWORD(heroDownPunch3)
	.byte $08
	.word .LOWORD(heroDownPunch2)
	.byte $ff

heroDownPunchAgain:
	.byte $08
	.word .LOWORD(heroDownPunch1)
	.byte $08
	.word .LOWORD(heroDownPunch2)
	.byte $08
	.word .LOWORD(heroDownPunch3)
	.byte $08
	.word .LOWORD(heroDownPunch2)
	.byte $ff

heroStandKick:
	.byte $04
	.word .LOWORD(heroStandKick1)
	.byte $04
	.word .LOWORD(heroStandKick2)
	.byte $04
	.word .LOWORD(heroStandKick1)
	.byte $01
	.word .LOWORD(heroStand1)
	.byte $ff

heroStandPunch:
	.byte $08
	.word .LOWORD(heroStandPunch1)
	.byte $08
	.word .LOWORD(heroStandPunch2)
	.byte $08
	.word .LOWORD(heroStandPunch3)
	.byte $08
	.word .LOWORD(heroStandPunch2)
	.byte $ff

heroStandPunchAgain:
	.byte $08
	.word .LOWORD(heroStandPunch1)
	.byte $08
	.word .LOWORD(heroStandPunch2)
	.byte $08
	.word .LOWORD(heroStandPunch3)
	.byte $08
	.word .LOWORD(heroStandPunch2)
	.byte $ff

heroJump:
	.byte $07
	.word .LOWORD(heroJump1)
	.byte $07
	.word .LOWORD(heroJump2)
	.byte $07
	.word .LOWORD(heroJump3)
	.byte $07
	.word .LOWORD(heroJump1)
	.byte $01
	.word .LOWORD(heroStand1)
	.byte $ff

heroJumpRun:
	.byte $06
	.word .LOWORD(heroJumpRun1)
	.byte $06
	.word .LOWORD(heroJump2)
	.byte $06
	.word .LOWORD(heroJumpRun2)
	.byte $06
	.word .LOWORD(heroJump3)
	.byte $06
	.word .LOWORD(heroJump1)
	.byte $03
	.word .LOWORD(heroStand1)
	.byte $ff

heroJumpOffsetTable:
	; old values
	;.byte  0,  0,  5, 12, 14, 16, 18, 20, 22, 31, 32, 34, 35, 36	; 14 values
	;.byte 35, 34, 32, 31, 29, 27, 18, 14, 12,  6,  0,  0,  0,  0	; 14 values -> 28 values

	.byte $00, $00, $05, $07, $02, $02, $02, $02, $02, $09, $01, $02, $01, $01	; 14 values
	.byte $ff, $ff, $fe, $ff, $fe, $fe, $f7, $fb, $fe, $fa, $fa, $00, $00, $00	; 14 values -> 28 values
	.byte $00
