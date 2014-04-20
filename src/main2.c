#include "data.h"
#include "sprite.h"
#include "myEvents.h"
#include "ennemiesHandling.h"
#include "event.h"
#include "score.h"
#include "level.h"
#include "ressource.h"
#include "PPU.h"
#include "PPURegisters.h"
#include "pad.h"

extern void main(void);

void gameOver(void){
	main();
}

void playLevel(byte level) {

	word counter;

	// Enable forced VBlank during DMA transfer
	setINIDSPDirectValue(0x80);

	//initScore();
	initLevel();

	setOBJSEL(0x00, 0x00, 0x6000);
	CGRAMLoad(sprite_pal, HEX_A(80), HEX_A(20));
	CGRAMLoad(ennemies_pal, HEX_A(90), HEX_A(20));

	addEventWithPriority(&NMIReadPad, 1, (char) 0x01);
	//addEvent(&spriteTableUpdate, 1);
	addEventWithPriority(&scoreEvent, 1, (char) 0x02);

	oncePerVBlank = 0;
	addEventWithPriority(&oncePerVBlankReset, 1, (char) 0xff);

	//updateLevel((byte) 1);

	scrollLevelDMAInit();
	addEventWithPriority(&scrollLevelEvent, 1, (char) 0x80);

	//ennemyInit();
	counter = 0;

	// Disable forced VBlank
	setINIDSPDirectValue(0x00);

	// Loop forever
	while(1) {
		if(oncePerVBlank) {
			//updateTime(counter);
			//heroSpriteControl(counter);
			//ennemySpriteControl(counter);
			scrollLevel(counter);

			//if((counter % 300 == 0) && ennemyCount(ennemies) < 2) {
			//	if(isEnnemyComingFromLeftAllowed())
			//		ennemyAdd(ennemySpriteDataWalkSequence, (byte) 0, (sword) -16, (word) 0x70);
			//}

			//if(getPlayerStatus() == 0 || getTime() == 0) {
			//	gameOver();
			//}

			// update counter on each VBlank
			counter++;
			// reset oncePerVBlank
			oncePerVBlank = 0;
		}
	}
}
