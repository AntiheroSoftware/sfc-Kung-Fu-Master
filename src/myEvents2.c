#include "data.h";
#include "pad.h";
#include "event.h";
#include "debug.h";
#include "PPURegisters.h"
#include "sprite.h"

extern padStatus pad1;

char oncePerVBlank;

char NMIReadPad(word counter) {
	static byte buttonB;
	static byte buttonX;

	if(counter == 0) {
		buttonB = 0;
		buttonX = 0;
	}

	pad1 = readPad((byte) 0);

	// the buttons need to be unpressed before trigger
	if(buttonB && pad1.B) pad1.B = 0;
	else {
		if(pad1.B) buttonB = 1;
		else buttonB = 0;
	}

	if(buttonX && pad1.X) pad1.X = 0;
	else {
		if(pad1.X) buttonX = 1;
		else buttonX = 0;
	}

	return EVENT_CONTINUE;
}

char oncePerVBlankReset(word counter) {
	oncePerVBlank = 1;
	return EVENT_CONTINUE;
}
