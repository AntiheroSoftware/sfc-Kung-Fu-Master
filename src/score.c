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

word score1;
word score2;
word top;

word time;
byte level;
byte live;
byte playerStatus;
byte ennemyStatus;

word far scoreMap[SCORE_MAP_SIZE];

void initScore(void) {

	word i;
	word counter;

	counter = 0;

	score1 = score2 = top = 0;

	time = 2000;
	level = 1;
	live = 1;

	playerStatus = 64;
	ennemyStatus = 64;

	// Init score map (copy from rom)
	for(i=0; i<SCORE_MAP_SIZE; i++) {
		scoreMap[i] = score_map[i];
	}

	// Screen map data @ VRAM location $1000
	setBG2SC(SCORE_MAP, (byte) 0x00);

	// Plane 0 Tile graphics @ $2000
	setBG12NBA(PPU_NO_VALUE, SCORE_TILE);

	// Title screen transfer to VRAM
	VRAMLoadFromValue(score_pic, HEX_A(SCORE_TILE), HEX_A(0c00));
	VRAMLoadFromValue(score_map, HEX_A(SCORE_MAP), HEX_A(c0));
	CGRAMLoad(score_pal, HEX_A(40), HEX_A(20));

	setBGMODE(0, 0, 3);
	// 4 pixel scroll down
	*(byte*) 0x2110 = 0xfb;
	*(byte*) 0x2110 = 0x00;
	*(byte*) 0x212c = 0x12; // Plane 0 (bit one) enable register and OBJ enable
	*(byte*) 0x212d = 0x00;	// All subPlane disable
	//setINIDSP(0, 0xf);
}

char scoreEvent(word counter) {
	scoreDisplay();
	return EVENT_CONTINUE;
}

void updateTime(word counter) {
	char buffer[5];

	// update time every 5th frame
	if(counter % 5 == 0 && time > 0) {
		time--;
		itoa2(time, buffer, 10);
		writeStringScore(buffer, (byte) 5, (byte) 27, (byte) 2, (byte) (-'0'+NUMBERS_WHITE));
	}
}

word getTime() {
	return time;
}

void updateScore(byte type, word scoreUpdate) {
	char buffer[7];

	switch(type) {
		case SCORE_TOP :
			top += scoreUpdate;
			itoa2(top, buffer, 10);
			writeStringScore(buffer, (byte) 7, (byte) 15, (byte) 0, (byte) (-'0'+NUMBERS_RED));
			break;
		case SCORE_PLAYER1 :
			score1 += scoreUpdate;
			itoa2(score1, buffer, 10);
			writeStringScore(buffer, (byte) 7, (byte) 4, (byte) 0, (byte) (-'0'+NUMBERS_CYAN));
			break;
		case SCORE_PLAYER2 :
			score2 += scoreUpdate;
			itoa2(score2, buffer, 10);
			writeStringScore(buffer, (byte) 7, (byte) 25, (byte) 0, (byte) (-'0'+NUMBERS_CYAN));
			break;
	}
}
