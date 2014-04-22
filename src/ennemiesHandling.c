#include <stdlib.h>;
#include <sys/types.h>;
#include "data.h";
#include "event.h";
#include "ressource.h";
#include "PPURegisters.h";
#include "sprite.h";
#include "pad.h"
#include "myEvents.h";
#include "ennemiesHandling.h";
#include "level.h"
#include "score.h"

ennemyData *ennemies;
char ennemyScrollUpdate;

void enableEnnemy(ennemyData myEnnemy) {
	myEnnemy.enabled = 1;
}

void disableEnnemy(ennemyData myEnnemy) {
	myEnnemy.enabled = 0;
}

void ennemySpriteControl(word counter) {
	byte heroTempStatus;
	word ennemyIndex;
	word ennemyBackwardIndex;
	ennemyData *myEnnemy, *nextEnnemy;

	ennemyIndex = 0;
	myEnnemy = ennemies;

	ennemyBackwardIndex = ennemyCount(ennemies);

	while(myEnnemy != NULL) {
		if(myEnnemy->enabled) {

			if(myEnnemy->spriteHScroll > 260) {
				// Remove this ennemy because out of screen
				nextEnnemy = myEnnemy->nextEnnemy;
				ennemyRemove(myEnnemy);
				myEnnemy = nextEnnemy;

				clearAOMTable((byte) (ennemyBackwardIndex*8), (byte) 8);
				ennemyBackwardIndex--;

				continue;
			}

			if(hero.heroSpriteHScroll - myEnnemy->spriteHScroll <= 1) {
				// Don't move anywhere
				hero.status = HERO_STATUS_CATCHED;
				// catchInit
				if(myEnnemy->catchFrameCounter == 0) {
					myEnnemy->catchedPower = 5;
					myEnnemy->catchFrameCounter = 10;
				}
				// catch energy loss
				if(myEnnemy->catchFrameCounter == 1) {
					heroTempStatus = getPlayerStatus();
					updatePlayerStatus((byte) (heroTempStatus - HERO_ENERGY_LOSS_CATCHED));
					myEnnemy->catchFrameCounter = 30;
				}
				// Check if enemy loss catchPower
				if(hero.getOutCatch) {
					myEnnemy->catchedPower--;
					hero.getOutCatch = 0;
					if(myEnnemy->catchedPower == 0) {
						// Hero is not catched anymore
						hero.status = HERO_STATUS_NORMAL;
						// Remove this ennemy because dead
						nextEnnemy = myEnnemy->nextEnnemy;
						ennemyRemove(myEnnemy);
						myEnnemy = nextEnnemy;

						clearAOMTable((byte) (ennemyBackwardIndex*8), (byte) 8);
						ennemyBackwardIndex--;

						continue;
					}
				}
				myEnnemy->catchFrameCounter--;
			} else {
				if(	myEnnemy->spriteSequence != ennemySpriteDataArmsUpSequence
					&& hero.heroSpriteHScroll - myEnnemy->spriteHScroll <= 50) {
					// ARMS UP
					myEnnemy->spriteSequence = ennemySpriteDataArmsUpSequence;
				}

				if(ennemyScrollUpdate == LEVEL_SCROLL_LEFT) {
					myEnnemy->spriteHScroll += 2;
				} else if(ennemyScrollUpdate == LEVEL_SCROLL_RIGHT) {
					// do nothing
				} else {
					myEnnemy->spriteHScroll++;
				}

				// WALK
				myEnnemy->spriteFrameCounter++;
				if((myEnnemy->spriteFrameCounter % 0x08) == 0) {
					myEnnemy->spriteFrame++;
					if(myEnnemy->spriteFrame >= 4) {
						myEnnemy->spriteFrame = 0;
					}
				}
				copyPreparedSpriteDataToAOMTable(	myEnnemy->spriteSequence, (byte) myEnnemy->spriteFrame,
													(byte) 0, (byte) ((ennemyIndex+1)*8), myEnnemy->spriteHScroll, myEnnemy->spriteVScroll);
			}
		}
		ennemyIndex++;
		myEnnemy = myEnnemy->nextEnnemy;
	}
	// Reset scroll update
	ennemyScrollUpdate = 0;
}

void ennemyInit() {
	ennemies = NULL;
}

ennemyData *ennemyCreate(heroPreparedSpriteData *spriteSequence, byte spriteFrameStart, sword HPos, word VPos) {

	ennemyData *myEnnemy;
	myEnnemy = (ennemyData*) malloc(sizeof(ennemyData));

	myEnnemy->enabled = 1;
	myEnnemy->spriteSequence = spriteSequence;
	myEnnemy->spriteFrame = spriteFrameStart;
	myEnnemy->spriteFrameCounter = 0;
	myEnnemy->catchFrameCounter = 0;
	myEnnemy->spriteHScroll = HPos;
	myEnnemy->spriteVScroll = VPos;
	myEnnemy->previousEnnemy = NULL;
	myEnnemy->nextEnnemy = NULL;

	return myEnnemy;
}

ennemyData *ennemyAdd(heroPreparedSpriteData *spriteSequence, byte spriteFrameStart, sword HPos, word VPos) {
	ennemyData *lastEnnemy;
	ennemyData *myEnnemy;

	if(ennemies == NULL) {
		ennemies = ennemyCreate(spriteSequence, spriteFrameStart, HPos, VPos);
		return ennemies;
	} else {
		lastEnnemy = ennemies;
		// TODO optimise this with noduplicate
		while(lastEnnemy->nextEnnemy != NULL) {
			lastEnnemy = lastEnnemy->nextEnnemy;
		}

		myEnnemy = ennemyCreate(spriteSequence, spriteFrameStart, HPos, VPos);

		if(lastEnnemy->previousEnnemy == NULL) {
			myEnnemy->nextEnnemy = lastEnnemy;
			lastEnnemy->previousEnnemy = myEnnemy;
			ennemies = myEnnemy;
		} else {
			if(lastEnnemy->nextEnnemy != NULL) {
				myEnnemy->nextEnnemy = lastEnnemy->nextEnnemy;
				myEnnemy->nextEnnemy->previousEnnemy = myEnnemy;
			}
			myEnnemy->previousEnnemy = lastEnnemy;
			lastEnnemy->nextEnnemy = myEnnemy;
		}

		return myEnnemy;
	}
}

word ennemyCount(ennemyData *ennemyElement) {
	word	count;
	ennemyData	*myEnnemy;

	myEnnemy = ennemyElement;

	count = 0;
	while(myEnnemy != NULL) {
		count++;
		myEnnemy = myEnnemy->nextEnnemy;
	}

	return count;
}

void ennemyRemove(ennemyData *ennemyElement) {

	ennemyData *next, *previous;

	next = ennemyElement->nextEnnemy;
	previous = ennemyElement->previousEnnemy;

	if(next != NULL && previous != NULL) {
		next->previousEnnemy = previous;
		previous->nextEnnemy = next;

	} else if(next != NULL) {
		next->previousEnnemy = NULL;
		ennemies = next;
	} else if(previous != NULL) {
		previous->nextEnnemy = NULL;
	} else {
		ennemies = NULL;
	}

	free(ennemyElement);
}
