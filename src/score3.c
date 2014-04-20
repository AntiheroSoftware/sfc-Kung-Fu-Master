#include "data.h";
#include "score.h"
#include "sprite.h";
#include "event.h";
#include "myEvents.h";
#include "ressource.h"
#include "PPURegisters.h"
#include "PPU.h";
#include "string.h"

// TODO REMOVE THIS AND SET ALL IN MAIN
#include "level.h"

extern byte level;
extern word far scoreMap[SCORE_MAP_SIZE];

void updateLive(void) {
	// TODO
}

void updateLevel(byte updateLevel) {
	byte i;
	if(updateLevel > 0 && updateLevel <= 5) {
		level = updateLevel;
		for(i=1; i<updateLevel; i++)
			scoreMap[LEVEL+(i-1)*2] = MAP_LEVEL_ON + SCORE_PAL_ADJUST;
		for(; i<=5; i++)
			scoreMap[LEVEL+(i-1)*2] = MAP_LEVEL_OFF + SCORE_PAL_ADJUST;
		addEventWithPriority(&updateLevelEvent, 1, (char) 0x10);
	}
}

word writeStringScore(char out[], byte bufferSize, byte x, byte y, byte tileOffset) {
	int i, j;

	for(j=0; out[j] != '\0'; j++) {}

	for(i=bufferSize-1; j>=0; i--,j--) {
		out[i] = out[j];
	}

	for(; i>=0; i--) {
		out[i] = '0';
	}

	for(i=0; out[i] != '\0'; i++) {
		//VRAMByteWrite((byte) out[i]+tileOffset, (word) SCORE_MAP+x+(y*0x20));
		scoreMap[x+(y*0x20)] = out[i]+tileOffset + SCORE_PAL_ADJUST;
		x++;
	}

	return i;
}

void scoreDisplay(void) {
	VRAMLoadFromPtr(scoreMap, HEX_A(SCORE_MAP), HEX_A(SCORE_MAP_SIZE));
	//setINIDSPDirectValue(0x0f);
}
