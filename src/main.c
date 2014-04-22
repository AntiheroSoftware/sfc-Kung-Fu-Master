#include <stdlib.h>
#include "data.h"
#include "pad.h"
#include "sprite.h"
#include "event.h"
#include "myEvents.h"
#include "ennemiesHandling.h"
#include "ressource.h"
#include "PPU.h"
#include "PPURegisters.h"
#include "debug.h"
#include "score.h"
#include "level.h"
#include "2a03/nsf_player.h"

// Prototype
void playLevel(byte level);
void gameOver();

padStatus pad1;

void initInternalRegisters(void) {
	initDebug();
	initRegisters();
	initOAM();
	initEvents();
	enablePad();
	clearPad(pad1);
}

void preInit(void) {
	// For testing purpose ...
	// Insert code here to be executed before register init
}

void main(void) {

	word counter;

	//spc_sound_init();
	//spc_nsf_init(0,0);
	//spc_nsf_init();
	//spc_nsf_play();

	initInternalRegisters();

	// Enable forced VBlank during DMA transfer
	setINIDSPDirectValue(0x80);

	// Screen map data @ VRAM location $1000
	setBG1SC(0x1000, (byte) 0x00);

	// Plane 0 Tile graphics @ $2000
	setBG12NBA(0x2000, PPU_NO_VALUE);

	// Title screen transfer to VRAM
	VRAMLoadFromValue(title_pic, HEX_A(2000), HEX_A(1BE0));
	VRAMLoadFromValue(title_map, HEX_A(1000), HEX_A(0800));
	CGRAMLoad(title_pal, HEX_A(00), HEX_A(20));

	// Sprite screen data transfer to VRAM
	setINIDSPDirectValue(0x80);		// make VBlank happens
	//load32x32SpriteToVRAM(sprite_pic+spriteOffset((byte) 0, (byte) 0), 0x6000);
	//setOBJSEL(0x05, 0x00, 0x6000);
	//CGRAMLoad(sprite_pal, (byte) 0x80, (word) 0x20);
	setINIDSPDirectValue(0x00);		// free VBlank

	// TODO switch to mode 0 for trying
	setBGMODE(0, 0, 1);
	*(byte*) 0x212c = 0x01; // Plane 0 (bit one) enable register and OBJ disable
	*(byte*) 0x212d = 0x00;	// All subPlane disable
	setINIDSP(0, 0xf);

	// set Plane 0 scroll to 0
	*(byte*) 0x210d = (byte) 0;
	*(byte*) 0x210d = (byte) 0;

	counter = 0;
	oncePerVBlank = 0;

	addEvent(&oncePerVBlankReset, 1);
	addEventWithPriority(&NMIReadPad, 1, (char) 0x00);

	// Enable screen and disable forced VBlank
	setINIDSPDirectValue(0x0F);

	// Loop forever
	while(1) {
		if(oncePerVBlank) {
			counter++;

			//if(pad1.start) {
			//	debug();
			//}

			if(pad1.start) {
				playLevel((byte) 1);
			}

			// reset oncePerVBlank
			oncePerVBlank = 0;
		}
	}
}

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

void IRQHandler(void) {
}

void NMIHandler(void) {
	processEvents();
}
