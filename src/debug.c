#include "data.h"
#include "pad.h"
#include "PPU.h"
#include "PPURegisters.h"
#include "ressource.h"
#include "string.h"
#include "event.h"
#include "debug.h"

#include <stdlib.h>
#include <sys/types.h>;

byte cursorX, cursorY;
word debugMap[0x400];

extern padStatus pad1;

word* stack;
word registerA, registerX, registerY;

void initDebug(void) {
	word i;

	for(i=0; i<0x400; i++) {
		debugMap[i] = 0x00;
	}
}

void setCursorDebug(int x, int y) {
	cursorX = (byte) x;
	cursorY = (byte) y;
}

void writeStringDebug(char out[]) {
	word i;
	char buffer;

	for(i=0; out[i] != '\0'; i++) {
		buffer = out[i];
		if((cursorX > 0x1f) || (buffer == '\n')) {
			cursorY++;
			cursorX = 0;
			if(buffer == '\n') continue;
		}
		if(buffer>='a' && buffer<='z') {
			buffer -= 0x20;
		}
		debugMap[cursorX+(cursorY*0x20)] = buffer - 0x20;
		cursorX++;
	}
}

void displayDebug(void) {
	VRAMLoadFromPtr(debugMap, HEX_A(2000), HEX_A(0800));
	setINIDSPDirectValue(0x0f);
}

word* getStackPointer(void) {
	word stackValue;
	#asm
		tsx
		stx %%stackValue;
	#endasm
	return (word*) stackValue;
}

void DEBUGHandler(void) {
	word i,j;

	char buffer[32];

	byte tileMapLocationBackup;
	word characterLocationBackup;

	ppuRegisterStatus PPUBackup;

	stack = getStackPointer();

	// save context
	savePPUContext(&PPUStatus, &PPUBackup);

	// Disable events
	setEnabledEvent(false);

	*(byte*) 0x212c = 0x01; // Plane 0 (bit one) enable register
							// and OBJ disable

	// Display pink debug test screen
	VRAMLoadFromValue(debugFont_pic, HEX_A(DEBUG_TILE_ADDR), HEX_A(0800));
	CGRAMLoad(debugFont_pal, HEX_A(00), HEX_A(10));

	setBG1SC(DEBUG_MAP_ADDR, (byte) 0x00);
	setBG12NBA(DEBUG_TILE_ADDR, PPU_NO_VALUE);
	initDebug();

	setCursorDebug(0,0);
	writeStringDebug("PINK DEBUGGER OUTPUT V0.2\n\0");

	setCursorDebug(0,2);
	writeStringDebug("REGISTERS :\n\0");
	writeStringDebug("STACK: ");
	itoa2((word) stack, buffer, 16);
	writeStringDebug(buffer);
	writeStringDebug("\n\0");
	writeStringDebug("A: ");
	itoa2((word) registerA, buffer, 16);
	writeStringDebug(buffer);
	writeStringDebug(" X: ");
	itoa2((word) registerX, buffer, 16);
	writeStringDebug(buffer);
	writeStringDebug(" Y: ");
	itoa2((word) registerY, buffer, 16);
	writeStringDebug(buffer);
	writeStringDebug("\n\0");

	setCursorDebug(0,6);
	writeStringDebug("PPU-REGISTERS :\n\0");
	writeStringDebug("INIDSP: ");
	itoa2((word) PPUStatus.INIDSP, buffer, 16);
	writeStringDebug(buffer);
	writeStringDebug(" BGMODE: ");
	itoa2((word) PPUStatus.BGMODE, buffer, 16);
	writeStringDebug(buffer);
	writeStringDebug(" MOSAIC: ");
	itoa2((word) PPUStatus.MOSAIC, buffer, 16);
	writeStringDebug(buffer);
	writeStringDebug("\n\0");

	debugEvents(0, 9);

	setINIDSPDirectValue(0x0f);
	setMOSAICDirectValue(0x0f);

	*(byte*) 0x210d = 0;
	*(byte*) 0x210d = 0;

	displayDebug();

	while(!pad1.select) {
	}

	// reload palette
	// TODO save palette before
	CGRAMLoad(title_pal, HEX_A(00), HEX_A(ff));
	setINIDSPDirectValue(0x0f); // enable background

	*(byte*) 0x212c = 0x11; // Plane 0 (bit one) enable register
							// and OBJ enable

	// restore context
	restorePPUContext(PPUBackup);

	// Re-enable events
	setEnabledEvent(true);
}

void debugEvents(int cursorX, int cursorY) {
	char buffer[32];
	event *myEvent;

	setCursorDebug(cursorX, cursorY);
	writeStringDebug("EVENT DISPLAY :\n\n\0");
	myEvent = events;
	while(myEvent != NULL) {
		writeStringDebug("POINTER: ");
		itoa2((word) myEvent, buffer, 16);
		writeStringDebug(buffer);
		writeStringDebug(" VBLANK: ");
		itoa2((word) myEvent->VBlankCount, buffer, 16);
		writeStringDebug(buffer);
		writeStringDebug("\n\0");

		writeStringDebug("PRIORITY: ");
		itoa2((word) myEvent->priority, buffer, 16);
		writeStringDebug(buffer);
		writeStringDebug(" CALLBACK: ");
		itoa2((word) myEvent->callback, buffer, 16);
		writeStringDebug(buffer);
		writeStringDebug("\n\0");

		writeStringDebug("PREV: ");
		itoa2((word) myEvent->previousEvent, buffer, 16);
		writeStringDebug(buffer);
		writeStringDebug(" NEXT: ");
		itoa2((word) myEvent->nextEvent, buffer, 16);
		writeStringDebug(buffer);
		writeStringDebug("\n\0");

		myEvent = myEvent->nextEvent;

		if(myEvent != NULL) {
			writeStringDebug("-------------------------\n\0");
		}
	}
}
