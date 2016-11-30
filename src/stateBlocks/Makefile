all: states

states:
	../../../Tools/cc65-master/bin/ca65 -t none -I ../../../Tools/cc65-sfclib/include levelSelect.asm
	../../../Tools/cc65-master/bin/ca65 -t none -I ../../../Tools/cc65-sfclib/include letterIntro.asm
	../../../Tools/cc65-master/bin/ar65 a allStates.lib levelSelect.o letterIntro.o