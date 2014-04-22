#include "data.h";
#include "pad.h";
#include "event.h";
#include "debug.h";
#include "PPURegisters.h"
#include "sprite.h"

extern padStatus pad1;
extern OAMData spriteData;

char oncePerVBlank;

char fadeOut(word counter) {
	static byte fadeOutValue;

	if(!isEnabledEvent()) {
		return EVENT_CONTINUE;
	}

	if(counter == 0) {
		// init fade value
		fadeOutValue = 0x0f;
	} else {
		fadeOutValue--;
	}

	setINIDSP(PPU_NO_VALUE, fadeOutValue);

	if(fadeOutValue == 0x00) {
		return EVENT_STOP;
	} else {
		return EVENT_CONTINUE;
	}
}

char fadeIn(word counter) {
	static byte fadeInValue;

	if(!isEnabledEvent()) {
		return EVENT_CONTINUE;
	}

	if(counter == 0) {
		// init fade value
		fadeInValue = 0x00;
	} else {
		fadeInValue++;
	}

	setINIDSP(PPU_NO_VALUE, fadeInValue);

	if(fadeInValue >= 0x0f) {
		return EVENT_STOP;
	} else {
		return EVENT_CONTINUE;
	}
}

char mosaicOut(word counter) {
	static byte mosaicOutValue;

	if(!isEnabledEvent()) {
		return EVENT_CONTINUE;
	}

	if(counter == 0) {
		// init fade value
		mosaicOutValue = 0xf;
	} else {
		mosaicOutValue--;
	}

	setMOSAIC(mosaicOutValue, 0xf);

	if(mosaicOutValue == 0) {
		return EVENT_STOP;
	} else {
		return EVENT_CONTINUE;
	}
}

char mosaicIn(word counter) {
	static byte mosaicInValue;

	if(!isEnabledEvent()) {
		return EVENT_CONTINUE;
	}

	if(counter == 0) {
		// init fade value
		mosaicInValue = 0;
	} else {
		mosaicInValue++;
	}

	setMOSAIC(mosaicInValue, 0xf);

	if(mosaicInValue == 0xf) {
		return EVENT_STOP;
	} else {
		return EVENT_CONTINUE;
	}
}

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
