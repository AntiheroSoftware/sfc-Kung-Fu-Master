;
; Kung Fu Master sound code
;
; Adapted from SNES GSS wladx code
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .feature	c_comments

            .export 	gss_init
            .export 	gss_playSfx
            .export 	gss_playTrack
            .export 	gss_stopTrack
            .export 	gss_pauseTrack
            .export 	gss_resumeTrack
            .export 	gss_stopAll
            .export 	gss_setStereo
            .export 	gss_setMono
            .export 	gss_setGlobalVolume
            .export 	gss_setChannelsVolume

            .exportzp	gss_trackNumber
            .exportzp	gss_volume
            .exportzp	gss_volumeSpeed
            .exportzp	gss_channels
            .exportzp	gss_channelsVolume
            .exportzp	gss_sfxChannel
            .exportzp	gss_sfxNumber
            .exportzp	gss_sfxVolume
            .exportzp	gss_sfxPan

			;*** For debugging purpose ***

            .export SPC700_Driver
            .export SPC700_Driver_Size
            .export Song_Dst_Pointer
			.export Song_Bank_Table
			.export Song_Offset_Table
			.export Song_Size_Table
			.export spc_command
			.export spc_load_data

;.define DISABLE_SOUND

.define APU0					$2140
.define APU1					$2141
.define APU2					$2142
.define APU3					$2143
.define APU01					$2140					; for 16-bit writes to $2140/$2141
.define APU23					$2142					; for 16-bit writes to $2142/$2143

.define SCMD_NONE				$00
.define SCMD_INITIALIZE			$01
.define SCMD_LOAD				$02
.define SCMD_STEREO				$03
.define SCMD_GLOBAL_VOLUME		$04
.define SCMD_CHANNEL_VOLUME		$05
.define SCMD_MUSIC_PLAY 		$06
.define SCMD_MUSIC_STOP 		$07
.define SCMD_MUSIC_PAUSE 		$08
.define SCMD_SFX_PLAY			$09
.define SCMD_STOP_ALL_SOUNDS	$0a
.define SCMD_STREAM_START		$0b
.define SCMD_STREAM_STOP		$0c
.define SCMD_STREAM_SEND		$0d

.macro _A8
	.A8
	sep #$20
.endmacro

.macro _A16
	.A16
	rep #$20
.endmacro

.macro _AXY8
	.A8
	.I8
	sep #$30
.endmacro

.macro _AXY16
	.A16
	.I16
	rep #$30
.endmacro

.macro _XY8
	.I8
	sep #$10
.endmacro

.macro _XY16
	.I16
	rep #$10
.endmacro

.segment "ZEROPAGE"

sneslib_ptr:
	.res 4

gss_param:			.res 2
gss_command:		.res 2

gss_loadBank:		.res 2
gss_loadOffset:		.res 2
gss_loadSize:		.res 2
gss_loadDst:		.res 2

gss_trackNumber:	.res 1

gss_volume: 		.res 1
gss_volumeSpeed:	.res 1

gss_channels:		.res 1
gss_channelsVolume: .res 1

gss_sfxChannel:		.res 1
gss_sfxNumber:		.res 1
gss_sfxVolume:		.res 1
gss_sfxPan:			.res 1

.macro _GSSDataGenerator path, numberOfSongs, segmentName

.segment segmentName

	SPC700_Driver:
    	.incbin .sprintf("%s/spc700.bin", path), 2

	.repeat numberOfSongs, index
    .ident(.sprintf("Song_%02d", index+1)):
    	.incbin .sprintf("%s/music_%d.bin", path, index+1), 2
	.endrepeat

.segment "RODATA"

	SPC700_Driver_Size:
    	.incbin .sprintf("%s/spc700.bin", path), 0, 1
    	.incbin .sprintf("%s/spc700.bin", path), 1, 1

    Song_Dst_Pointer:
    	.incbin .sprintf("%s/spc700.bin", path), 14, 1
    	.incbin .sprintf("%s/spc700.bin", path), 15, 1

    Song_Bank_Table:
		.repeat numberOfSongs, index
			.byte .BANKBYTE(.ident(.sprintf("Song_%02d", index+1)))
			.byte $00
		.endrepeat

    Song_Offset_Table:
    	.repeat numberOfSongs, index
			.word .LOWORD(.ident(.sprintf("Song_%02d", index+1)))
		.endrepeat

    Song_Size_Table:
    	.repeat numberOfSongs, index
			.incbin .sprintf("%s/music_%d.bin", path, index+1), 0, 1
        	.incbin .sprintf("%s/music_%d.bin", path, index+1), 1, 1
		.endrepeat

.segment "CODE"

.endmacro

_GSSDataGenerator "../ressource/music", 1, "BANK7"

.segment "CODE"

.A8
.I16

;***************************************************************************************
;*** gss_init **************************************************************************
;***************************************************************************************

.proc gss_init

	php								; preserve processor status

	sei								; disable interrupts

	_A16

	lda #.BANKBYTE(SPC700_Driver)
	sta gss_loadBank
	lda	#.LOWORD(SPC700_Driver)
	sta gss_loadOffset
	lda	SPC700_Driver_Size
	sta gss_loadSize
	lda	#$0200
	sta gss_loadDst
	jsl	spc_load_data

	_A16

	lda #SCMD_INITIALIZE
	sta	gss_command
	stz	gss_param
	jsl	spc_command

	cli								; reenable interrupts

	plp								; restore processor status
	rtl

.endproc

;*****************************************************************************************
;*** gss_playTrack ***********************************************************************
;*****************************************************************************************
;*** A register contains number of song to play                                        ***
;*****************************************************************************************

.proc gss_playTrack

	phx
	pha
	php								; preserve processor status

	sei								; disable interrupts

	_A16

	pha

	lda #SCMD_LOAD
	sta	gss_command
	stz	gss_param
	jsl	spc_command

	_A16

	pla
	and #$00ff
	asl
	tax

	lda Song_Bank_Table,X
	sta gss_loadBank
	lda	Song_Offset_Table,X
	sta gss_loadOffset
	lda	Song_Size_Table,X
	sta gss_loadSize
	lda	Song_Dst_Pointer
	sta gss_loadDst
	jsl	spc_load_data

	_A16

	lda #SCMD_INITIALIZE
	sta	gss_command
	stz	gss_param
	jsl	spc_command

	_A16

	lda #SCMD_MUSIC_PLAY
	sta	gss_command
	stz	gss_param
	jsl	spc_command

	cli								; reenable interrupts

	plp
	pla
	plx
	rtl

.endproc

;*****************************************************************************************
;*** gss_playSfx *************************************************************************
;*****************************************************************************************

.proc gss_playSfx

	php
	_AXY16

	lda gss_sfxPan					; Pan Value
	bpl :+
	lda #0
:
	cmp #255
	bcc :+
	lda #255
:
	xba
	and #$ff00
	sta gss_param

	lda gss_sfxNumber				; Sfx Number
	and #$00ff
	ora gss_param
	sta gss_param

	lda gss_sfxVolume				; Volume
	xba
	and #$ff00
	sta gss_command

	lda gss_sfxChannel				; Channel
	asl a
	asl a
	asl a
	asl a
	and #$00f0
	ora #SCMD_SFX_PLAY
	ora gss_command
	sta gss_command

	jsl spc_command

	plp
	rtl

.endproc

;******************************************************************************
;*** gss_stopTrack ************************************************************
;******************************************************************************

.proc gss_stopTrack

	php
	_AXY16

	lda #SCMD_MUSIC_STOP
	sta gss_command
	stz gss_param

	jsl spc_command

	plp
	rtl

.endproc

;******************************************************************************
;*** gss_pauseTrack ***********************************************************
;******************************************************************************

.proc gss_pauseTrack

	php
	_AXY16

	lda #$01						; Pause
	sta gss_param

	lda #SCMD_MUSIC_PAUSE
	sta gss_command

	jsl spc_command

	plp
	rtl

.endproc

;******************************************************************************
;*** gss_resumeTrack ***********************************************************
;******************************************************************************

.proc gss_resumeTrack

	php
	_AXY16

	lda #$00						; resume
	sta gss_param

	lda #SCMD_MUSIC_PAUSE
	sta gss_command

	jsl spc_command

	plp
	rtl

.endproc

;******************************************************************************
;*** gss_stopAll **************************************************************
;******************************************************************************

.proc gss_stopAll

	php
	_AXY16

	lda #SCMD_STOP_ALL_SOUNDS
	sta gss_command
	stz gss_param

	jsl spc_command

	plp
	rtl

.endproc

;******************************************************************************
;*** gss_setStereo ***********************************************************
;******************************************************************************

.proc gss_setStereo

	php

	_AXY16
	
	lda #$0001						; Stereo
	sta gss_param
	
	lda #SCMD_STEREO
	sta gss_command
	
	jsl spc_command

	plp
	rtl
	
.endproc

;******************************************************************************
;*** gss_setMono **************************************************************
;******************************************************************************

.proc gss_setMono

	php
	_AXY16

	lda #$00						; Mono
	sta gss_param

	lda #SCMD_STEREO
	sta gss_command

	jsl spc_command

	plp
	rtl

.endproc

;******************************************************************************
;*** gss_setGlobalVolume ******************************************************
;******************************************************************************

.proc gss_setGlobalVolume

	php
	_AXY16
	
	lda gss_volumeSpeed				; Speed
	xba
	and #$ff00
	sta gss_param

	lda gss_volume					; Volume
	and #$00ff
	ora gss_param
	sta gss_param
	
	lda #SCMD_GLOBAL_VOLUME
	sta gss_command
	
	jsl spc_command

	plp
	rtl
	
.endproc

;******************************************************************************
;*** gss_setChannelsVolume ****************************************************
;******************************************************************************

.proc gss_setChannelsVolume

	php
	_AXY16
	
	lda gss_channels				; Channels
	xba
	and #$ff00
	sta gss_param
	
	lda gss_channelsVolume			; Volume
	and #$00ff
	ora gss_param
	sta gss_param
	
	lda #SCMD_CHANNEL_VOLUME
	sta gss_command
	
	jsl spc_command

	plp
	rtl
	
.endproc

;******************************************************************************
;*** Internal functions *******************************************************
;******************************************************************************

;***************************************************************************************
;*** spc_load_data *********************************************************************
;***************************************************************************************
;*** void spc_load_data(unsigned int adr,unsigned int size,const unsigned char *src) ***
;***************************************************************************************

.proc spc_load_data

	php

	_AXY16

.ifndef DISABLE_SOUND

	lda	#0
	tay

	lda gss_loadBank				; srch
	sta sneslib_ptr+2
	lda gss_loadOffset				; srcl
	sta sneslib_ptr+0
	lda gss_loadSize				; size
	tax

	lda	#$bbaa						; IPL ready signature

_wait1:

	cmp	APU01
	bne	_wait1

	lda gss_loadDst					; adr
	sta APU23

	lda	#$01cc						; IPL load and ready signature
	sta	APU01

	_A8

_wait2:

	cmp	APU0
	bne	_wait2

	phb
	lda	#0

	pha
	plb

_load1:

	lda	[sneslib_ptr],y
	sta	APU1
	tya
	sta	APU0
	iny

_load2:

	cmp	APU0
	bne	_load2
	dex
	bne	_load1

	iny
	bne	_load3
	iny

_load3:

	plb

	_A16

	lda	#$0200						; loaded code starting address
	sta	APU23

	_A8

	lda	#$00						; execute code
	sta	APU1
	tya								; stop transfer
	sta	APU0

	_A16

_load5:

	lda	APU01						; wait until SPC700 clears all communication ports,
	ora	APU23						; confirming that code has started
	bne	_load5

.endif

	plp
	rtl

.endproc

;******************************************************************************
;*** spc_command **************************************************************
;******************************************************************************

.proc spc_command

.ifndef DISABLE_SOUND

	php

	_A8

:
	lda APU0
	bne :-

	_A16

	lda gss_param
	sta APU23
	lda gss_command
	_A8
	xba
	sta APU1
	xba
	sta APU0

	cmp #SCMD_LOAD					; don't wait acknowledge
	beq :++

:
	lda APU0
	beq :-

:
	.endif

	plp
	rtl

.endproc