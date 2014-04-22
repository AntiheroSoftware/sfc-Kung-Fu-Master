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

char updateLevelEvent(word counter) {
	static byte flash;

	if(counter == 0) {
		flash = 0;
	}

	if(counter % 10 == 0) {
		if(flash == 0) {
			scoreMap[LEVEL+(level-1)*2] = MAP_LEVEL_ON + SCORE_PAL_ADJUST;
			flash = 1;
		} else {
			scoreMap[LEVEL+(level-1)*2] = MAP_LEVEL_OFF + SCORE_PAL_ADJUST;
			flash = 0;
		}
	}

	if(counter > 70) {
		scoreMap[LEVEL+(level-1)*2] = MAP_LEVEL_ON + SCORE_PAL_ADJUST;
		return EVENT_STOP;
	} else
		return EVENT_CONTINUE;
}

char getPlayerStatus() {
	return (char) playerStatus;
}

void updatePlayerStatus(byte status) {
	byte i;

	// we save the status
	playerStatus = status;

	if(status > 64) status = 64;
	if(status < 0) status = 0;

	for(i=0; i < status/8; i++) {
		scoreMap[PLAYER_ENERGY+i] = PLAYER_ENERGY_MAP + SCORE_PAL_ADJUST;
	}
	if(i < 8) {
		scoreMap[PLAYER_ENERGY+i] = PLAYER_ENERGY_MAP+(7-(status%8)) + SCORE_PAL_ADJUST;
		i++;
	}
	for(; i < 8; i++) {
		scoreMap[PLAYER_ENERGY+i] = ENNEMY_ENERGY_MAP+8 + SCORE_PAL_ADJUST;
	}
}

byte getEnnemyStatus() {
	return ennemyStatus;
}

void updateEnnemyStatus(byte status) {
	byte i;

	if(status > 64) status = 64;
	if(status < 0) status = 0;

	for(i=0; i < status/8; i++) {
		scoreMap[ENNEMY_ENERGY+i] = ENNEMY_ENERGY_MAP + SCORE_PAL_ADJUST;
	}
	if(i < 8) {
		scoreMap[ENNEMY_ENERGY+i] = ENNEMY_ENERGY_MAP+(7-(status%8)) + SCORE_PAL_ADJUST;
		i++;
	}
	for(; i < 8; i++) {
		scoreMap[ENNEMY_ENERGY+i] = ENNEMY_ENERGY_MAP+8 + SCORE_PAL_ADJUST;
	}
}

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
