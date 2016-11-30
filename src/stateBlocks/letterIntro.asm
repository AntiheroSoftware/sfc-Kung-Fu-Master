;
; Kung Fu Master Letter Intro state
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .feature	c_comments

            .include    "snes.inc"

            .export 	letterIntroStateDef

.segment "RODATA"

letterIntroStateDef:
	.word .LOWORD(letterIntroInit)
	.word .LOWORD(letterIntroBefore)
	.word .LOWORD(letterIntroMain)
	.word .LOWORD(letterIntroAfter)
	.word .LOWORD(letterIntroDestroy)

.segment "CODE"

.proc letterIntroInit
.endproc

.proc letterIntroBefore
.endproc

.proc letterIntroMain
.endproc

.proc letterIntroAfter
.endproc

.proc letterIntroDestroy
.endproc