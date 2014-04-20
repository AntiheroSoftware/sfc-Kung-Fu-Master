#include "data.h"
#include "pad.h"
#include "PPU.h"
#include "PPURegisters.h"
#include "ressource.h"
#include "string.h"
#include "debug.h"
#include "event.h"

#include <stdlib.h>
#include <sys/types.h>;

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