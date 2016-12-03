.segment "BANK2"

KFM_Player_final_Tiles:
	.incbin "../ressource/KFM_Player_final_sprite.pic"

KFM_Player_final_Pal:
	.incbin "../ressource/KFM_Player_final_sprite.clr"

heroFallYOffset:
	.byte 0, 0, 1, 1, 2
	.byte 4, 5, 6, 7, 8, 9, 10, 12
	.byte 15, 17, 19, 22, 24, 27, 29, 32, 35, 39, 42, 46, 50, 54, 58, 63, 67

heroFallXOffset:
	.byte 1, 2, 3, 4, 5
	.byte 6, 7, 8, 9, 10, 11, 12, 13
	.byte 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30

;******************************************************************************
;*** Hero Sprite definition ***************************************************
;******************************************************************************

;******************************************************************************
;*** Metasprites **************************************************************
;******************************************************************************
;*** Adress in bank for tiles                                               ***
;*** Normal mode hit offset                                                 ***
;*** Mirror mode hit offset                                                 ***
;*** Number of horizontal tiles                                             ***
;*** Y offset of the line                                                   ***
;*** X offset                                                               ***
;*** X offset Mirror                                                        ***
;*** Tile Number                                                            ***
;******************************************************************************

; TODO add information about the frame if it's a HIT frame or not (+ offsets)

heroStand1:							; 7 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles)
	.byte	$00, $00
	.byte   $01, $00, $0c, $2a, $00
	.byte   $02, $10, $0c, $2a, $02
	.byte             $1b, $1b, $04
	.byte   $02, $20, $0c, $2a, $06
	.byte             $1b, $1b, $08
	.byte   $02, $30, $0c, $2a, $0a
	.byte             $1b, $1b, $0c
	.byte	$00

heroWalk1: 							; 7 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*1))
	.byte	$00, $00
	.byte   $01, $00, $11, $23, $00
	.byte   $02, $10, $01, $33, $02
	.byte             $10, $23, $04
	.byte   $02, $20, $03, $31, $06
	.byte             $13, $21, $08
	.byte   $02, $30, $03, $31, $0a
	.byte             $13, $21, $0c
	.byte	$00

heroWalk2:							; 4 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*2))
	.byte	$00, $00
	.byte   $01, $00, $0a, $2a, $00
	.byte   $01, $10, $09, $2b, $02
	.byte   $01, $20, $09, $2b, $04
	.byte   $01, $30, $09, $2b, $06
	.byte	$00

heroWalk3:							; 7 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*3))
	.byte	$00, $00
	.byte   $01, $00, $10, $24, $00
	.byte   $02, $10, $00, $34, $02
	.byte             $0f, $24, $04
	.byte   $02, $20, $00, $34, $06
	.byte             $0f, $24, $08
	.byte   $02, $30, $00, $34, $0a
	.byte             $0f, $24, $0c
	.byte	$00

heroWalk4:							; 4 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*4))
	.byte	$00, $00
	.byte   $01, $00, $0b, $2a, $00
	.byte   $01, $10, $0b, $2a, $02
	.byte   $01, $20, $0b, $2a, $04
	.byte   $01, $30, $0b, $2a, $06
	.byte	$00

heroDownStand1:						; 4 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*5))
	.byte	$00, $00
	.byte   $01, $10, $09, $24, $00
	.byte   $01, $20, $06, $27, $02
	.byte   $02, $30, $00, $2d, $04
	.byte             $0f, $1e, $06
	.byte	$00

heroDownKick1:						; 5 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*6))
	.byte	$00, $00
	.byte   $01, $10, $08, $25, $00
	.byte   $02, $20, $00, $2d, $02
	.byte             $0f, $1e, $04
	.byte   $02, $30, $00, $2d, $06
	.byte             $0f, $1e, $08
	.byte	$00

heroDownKick2:						; 7 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*7))
	.byte	$00, $00
	.byte   $01, $10, $08, $25, $00
	.byte   $02, $20, $02, $2b, $02
	.byte             $11, $1c, $04
	.byte   $04, $30, $00, $2d, $06
	.byte             $0f, $1e, $08
	.byte             $1e, $0f, $0a
	.byte             $2d, $00, $0c
	.byte	$00

heroDownPunch1:						; 6 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*8))
	.byte	$00, $00
	.byte   $02, $10, $00, $2d, $00
	.byte             $0f, $1e, $02
	.byte   $02, $20, $00, $2d, $04
	.byte             $0f, $1e, $06
	.byte   $02, $30, $00, $2d, $08
	.byte             $0f, $1e, $0a
	.byte	$00

heroDownPunch2:						; 5 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*9))
	.byte	$00, $00
	.byte   $01, $10, $00, $2d, $00
	.byte   $02, $20, $00, $2d, $04
	.byte             $0f, $1e, $06
	.byte   $02, $30, $00, $2d, $08
	.byte             $0f, $1e, $0a
	.byte	$00

heroDownPunch3:						; 6 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*10))
	.byte	$00, $00
	.byte   $02, $10, $00, $2d, $00
	.byte             $0f, $1e, $02
	.byte   $02, $20, $00, $2d, $04
	.byte             $0f, $1e, $06
	.byte   $02, $30, $00, $2d, $08
	.byte             $0f, $1e, $0a
	.byte	$00

heroStandKick1:						; 7 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*11))
	.byte	$00, $00
	.byte   $02, $00, $00, $2d, $00
	.byte             $0f, $1e, $02
	.byte   $02, $10, $00, $2d, $04
	.byte             $0f, $1e, $06
	.byte   $02, $20, $00, $2d, $08
	.byte             $0f, $1e, $0a
	.byte   $01, $30, $00, $2d, $0c
	.byte	$00

heroStandKick2:						; 7 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*12))
	.byte	$00, $00
	.byte   $02, $00, $00, $2d, $00
	.byte             $1b, $12, $02
	.byte   $03, $10, $00, $2d, $04
	.byte             $0f, $1e, $06
	.byte             $1e, $0f, $08
	.byte   $01, $20, $06, $27, $0a
	.byte   $01, $30, $00, $2d, $0c
	.byte	$00

heroStandPunch1:					; 7 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*13))
	.byte	$00, $00
	.byte   $02, $00, $00, $2d, $00
	.byte             $0f, $1e, $02
	.byte   $02, $10, $00, $2d, $04
	.byte             $0f, $1e, $06
	.byte   $01, $20, $05, $28, $08
	.byte   $02, $30, $01, $2d, $0a
	.byte             $10, $1e, $0c
	.byte	$00

heroStandPunch2:					; 7 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*14))
	.byte	$00, $00
	.byte   $01, $00, $02, $2b, $00
	.byte   $01, $10, $02, $2b, $04
	.byte   $01, $20, $05, $28, $08
	.byte   $02, $30, $01, $2d, $0a
	.byte             $10, $1e, $0c
	.byte	$00

heroStandPunch3:					; 7 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*15))
	.byte	$00, $00
	.byte   $02, $00, $00, $2d, $00
	.byte             $0f, $1e, $02
	.byte   $02, $10, $00, $2d, $04
	.byte             $0f, $1e, $06
	.byte   $01, $20, $05, $28, $08
	.byte   $02, $30, $01, $2d, $0a
	.byte             $10, $1e, $0c
	.byte	$00

heroJump1:							; 4 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*16))
	.byte	$00, $00
	.byte   $01, $00, $0a, $2a, $00
	.byte   $01, $10, $09, $2b, $02
	.byte   $01, $20, $09, $2b, $04
	.byte   $01, $30, $09, $2b, $06
	.byte	$00

heroJump2:							; 5 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*17))
	.byte	$00, $00
	.byte   $01, $00, $0a, $2a, $00
	.byte   $01, $10, $09, $2b, $02
	.byte   $01, $20, $09, $2b, $04
	.byte   $01, $30, $09, $2b, $06
	.byte   $01, $40, $09, $2b, $08
	.byte	$00

heroJumpKick1:						; 8 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*18))
	.byte	$00, $00
	.byte   $02, $00, $00, $2d, $00
	.byte             $0f, $1e, $02
	.byte   $02, $10, $00, $2d, $04
	.byte             $0f, $1e, $06
	.byte   $02, $20, $00, $2d, $08
	.byte             $0f, $1e, $0a
	.byte   $01, $30, $00, $2d, $0c
	.byte   $01, $40, $00, $2d, $0e
	.byte	$00

heroJumpRun1:						; 6 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*19))
	.byte	$00, $00
	.byte   $01, $00, $0f, $1e, $00
	.byte   $02, $10, $00, $2d, $02
	.byte             $0f, $1e, $04
	.byte   $02, $20, $00, $2d, $06
	.byte             $0f, $1e, $08
	.byte   $01, $30, $00, $2d, $0a
	.byte	$00

heroJumpRun2:						; 4 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*20))
	.byte	$00, $00
	.byte   $01, $00, $0d, $27, $00
	.byte   $01, $10, $09, $2b, $02
	.byte   $01, $20, $09, $2b, $04
	.byte   $01, $30, $09, $2b, $06
	.byte	$00

heroJump3:							; 5 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*21))
	.byte	$00, $00
	.byte   $01, $00, $0e, $26, $00
	.byte   $01, $10, $09, $2b, $02
	.byte   $01, $20, $09, $2b, $04
	.byte   $01, $30, $09, $2b, $06
	.byte   $01, $40, $09, $2b, $08
	.byte	$00

heroHitLow1:						; 4 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*22))
	.byte	$00, $00
	.byte   $01, $00, $0f, $25, $00
	.byte   $01, $10, $09, $2b, $02
	.byte   $01, $20, $09, $2b, $04
	.byte   $01, $30, $09, $2b, $06
	.byte	$00

heroHitHigh1:						; 4 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*23))
	.byte	$00, $00
	.byte   $01, $00, $0a, $2a, $00
	.byte   $01, $10, $09, $2b, $02
	.byte   $01, $20, $09, $2b, $04
	.byte   $01, $30, $09, $2b, $06
	.byte	$00

heroGrabbed1:						; 4 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*24))
	.byte	$00, $00
	.byte   $01, $00, $0a, $2a, $00
	.byte   $01, $10, $09, $2b, $02
	.byte   $01, $20, $09, $2b, $04
	.byte   $01, $30, $09, $2b, $06
	.byte	$00

heroFall1:							; 8 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*25))
	.byte	$00, $00
	.byte   $02, $00, $00, $2d, $00
	.byte             $0f, $1e, $02
	.byte   $02, $10, $00, $2d, $04
	.byte             $0f, $1e, $06
	.byte   $02, $20, $00, $2d, $08
	.byte             $0f, $1e, $0a
	.byte   $02, $30, $00, $2d, $0c
	.byte             $0f, $1e, $0e

heroFall2:							; 8 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*26))
	.byte	$00, $00
	.byte   $02, $10, $00, $2d, $00
	.byte             $0f, $1e, $02
	.byte   $03, $20, $00, $2d, $04
	.byte             $0f, $1e, $06
	.byte             $1e, $0f, $08
	.byte   $03, $30, $00, $2d, $0a
	.byte             $0f, $1e, $0c
	.byte             $1e, $0f, $0e
	.byte	$00

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
	.byte $01
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
	.byte $01
	.word .LOWORD(heroDownStand1)
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
	.byte $01
	.word .LOWORD(heroDownStand1)
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
	.byte $01
	.word .LOWORD(heroStand1)
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
	.byte $01
	.word .LOWORD(heroStand1)
	.byte $ff

heroJump:
	.byte $04
	.word .LOWORD(heroJump1)
	.byte $05
	.word .LOWORD(heroJump2)
	.byte $11
	.word .LOWORD(heroJump3)
	.byte $05
	.word .LOWORD(heroJump2)
	.byte $04
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

heroGrabbed:
	.byte $01
	.word .LOWORD(heroGrabbed1)		; TODO does heroGrabbed1 have a function ?
	.byte $ff

heroFall:
	.byte $05
	.word .LOWORD(heroGrabbed1)
	.byte $08
	.word .LOWORD(heroFall1)
	.byte $11
	.word .LOWORD(heroFall2)
	.byte $00

heroJumpOffsetTable:
	.byte 0, 0, 0, 0, 5								; 5 values
	.byte 28, 30, 32, 34, 36, 38					; 6 values
	.byte 20, 21, 23, 23, 24, 25, 25, 25, 25		; 9 values
	.byte 25, 25, 24, 23, 21, 20, 20, 18, 16		; 9 values
	.byte 34, 32, 30, 28, 22, 16					; 6 values
	.byte 0, 0, 0, 0, 0								; 5 values -> 40 values