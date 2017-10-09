;
; Kung Fu Master base screen code
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .feature	c_comments

			.export 	screenBuffer

.segment "BSS"

screenBuffer:
	;.res	$800
	.res	0