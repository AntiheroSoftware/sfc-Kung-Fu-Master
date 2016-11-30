;
; Kung Fu Master Level Select state
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .feature	c_comments

            .include    "snes.inc"

            .export 	levelSelectStateDef

.segment "RODATA"

levelSelectStateDef:
	.word .LOWORD(levelSelectInit)
	.word .LOWORD(levelSelectBefore)
	.word .LOWORD(levelSelectMain)
	.word .LOWORD(levelSelectAfter)
	.word .LOWORD(levelSelectDestroy)

.segment "CODE"

.proc levelSelectInit
.endproc

.proc levelSelectBefore
.endproc

.proc levelSelectMain
.endproc

.proc levelSelectAfter
.endproc

.proc levelSelectDestroy
.endproc