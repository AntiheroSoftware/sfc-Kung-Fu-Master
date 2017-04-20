.segment "RODATA"

hitPointsKick:
	.word $0000
    .word $0100                     ; point for grab guy
    .word $0100                     ; point for knife
    .word $0100                     ; point for midget

hitPointsPunch:
	.word $0000
    .word $0200                     ; point for grab guy
    .word $0200                     ; point for knife
    .word $0200                     ; point for midget

hitTileKick:
	.byte $00
	.byte $40
	.byte $40
	.byte $40

hitTilePunch:
	.byte $00
	.byte $42
	.byte $42
	.byte $42