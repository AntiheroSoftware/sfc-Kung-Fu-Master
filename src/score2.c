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
extern byte ennemyStatus;
extern byte playerStatus;
extern word far scoreMap[SCORE_MAP_SIZE];

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
