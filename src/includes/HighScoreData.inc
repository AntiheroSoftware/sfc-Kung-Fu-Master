;.segment "BANK4"           ; TODO update this and make writeSTring to get bank
.segment "CODE"

highScoreTitleString:
          ;01234567890123456789012345678901
    .byte "        BEST 20 PLAYERS        ",$00

highScoreNumbersString:
    .byte $01, "  1              11",$0a,$0a
    .byte      "  2              12",$0a,$0a
    .byte      "  3              13",$0a,$0a
    .byte      "  4              14",$0a,$0a
    .byte      "  5              15",$0a,$0a
    .byte      "  6              16",$0a,$0a
    .byte      "  7              17",$0a,$0a
    .byte      "  8              18",$0a,$0a
    .byte      "  9              19",$0a,$0a
    .byte      " 10              20",$00


highScoreInitValues:
    .byte $04, $85, $20, " N.A", $00
    .byte $04, $31, $50, " SUI", $00
    .byte $04, $01, $00, " T.K", $00
    .byte $03, $97, $50, " BAH", $00
    .byte $03, $91, $80, " TSI", $00
    .byte $03, $81, $00, " ANI", $00
    .byte $03, $55, $00, " IHM", $00
    .byte $03, $02, $10, " SAI", $00
    .byte $02, $81, $10, " YE.", $00
    .byte $02, $63, $50, " A.T", $00
    .byte $02, $57, $00, " HAT", $00
    .byte $02, $55, $10, " IIA", $00
    .byte $02, $10, $10, " M.K", $00
    .byte $02, $00, $70, " ANO", $00
    .byte $01, $98, $50, " AI.", $00
    .byte $01, $82, $10, " IKO", $00
    .byte $01, $65, $20, " AAA", $00
    .byte $01, $57, $20, " NNI", $00
    .byte $01, $53, $80, " AAA", $00
    .byte $01, $49, $50, " TA.", $00

.export highScoreInitValues