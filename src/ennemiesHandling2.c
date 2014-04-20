#include <stdlib.h>;
#include <sys/types.h>;
#include "data.h";
#include "event.h";
#include "ressource.h";
#include "PPURegisters.h";
#include "sprite.h";
#include "myEvents.h";
#include "ennemiesHandling.h";
#include "level.h"

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
