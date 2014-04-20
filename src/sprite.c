#include "data.h"
#include "sprite.h"
#include "PPURegisters.h"
#include "C:\65xx_FreeSDK\include\string.h"

OAMData spriteData;

void initOAM(void) {
	byte i;
	memset(&spriteData, 0x00, sizeof(OAMData));
	for(i=0; i<0x80; i++) {
		spriteData.data[i].VPos = 224;
	}
	// copy data the first time
	OAMLoad();
}

// This function need to be called during VBlank 
void OAMLoad(void) {
	//OAMPartialLoad((byte) 0x80);
	OAMFullLoad();
}

// This method is quite slow ...
void OAMPartialLoad(byte objectNum) {
	// first part of OAM data
	setOAMADDR(0x0000, 0x00);
	*(word*)0x4300 = 0x0400;				// set DMA control register (1 byte inc) and destination ($21xx xx -> 0x04)
	*(word*)0x4302 = (word) &spriteData;	// DMA channel x source address offset (low $4302 and high $4303 optimisation)
	*(byte*)0x4304 = 0x00; 					// DMA channel x source address bank
	*(word*)0x4305 = (word) objectNum*4;	// DMA channel x transfer size (low $4305 and high $4306 optimisation)
	*(byte*)0x420b = 0x01;					// Turn on DMA transfer for this channel

	// second part of OAM data
	setOAMADDR(0x0100, 0x00);
	*(word*)0x4300 = 0x0400;				// set DMA control register (1 byte inc) and destination ($21xx xx -> 0x04)
	*(word*)0x4302 = (word) &spriteData+(0x80*4);	// DMA channel x source address offset (low $4302 and high $4303 optimisation)
	*(byte*)0x4304 = 0x00; 					// DMA channel x source address bank
	*(word*)0x4305 = (word) (objectNum/4)+1;// DMA channel x transfer size (low $4305 and high $4306 optimisation)
	*(byte*)0x420b = 0x01;					// Turn on DMA transfer for this channel
}

void OAMFullLoad() {
	setOAMADDR(0x0000, 0x00);
	*(word*)0x4300 = 0x0400;				// set DMA control register (1 byte inc) and destination ($21xx xx -> 0x04)
	*(word*)0x4302 = (word) &spriteData;	// DMA channel x source address offset (low $4302 and high $4303 optimisation)
	*(byte*)0x4304 = 0x00; 					// DMA channel x source address bank
	*(word*)0x4305 = sizeof(OAMData);		// DMA channel x transfer size (low $4305 and high $4306 optimisation)
	*(byte*)0x420b = 0x01;					// Turn on DMA transfer for this channel
}

void loadSpriteToVRAM(word far *src, word vramDst, word horBlocks, word verBlocks) {

	word i;
	
	// DMA Init
	*(byte*)0x2115 = 0x80;
	*(word*)0x4300 = 0x1801;	// set DMA control register (1 word inc) and destination ($21xx xx -> 0x18)

	for(i=0; i<verBlocks; i++) {
		*(word*)0x2116 = vramDst;	// set address in VRam for read or write ($2116) + block size transfer ($2115)
#asm
		lda %%src;					// DMA channel x source address offset 
		sta $4302;					// (low $4302 and high $4303 optimisation)
#endasm
#asm
		lda %%src+2;				// DMA channel x source address bank
		sta $4304;
#endasm
		*(word*)0x4305 = 0x20*horBlocks;		// DMA channel x transfer size (low $4305 and high $4306 optimisation)
		*(byte*)0x420b = 0x01;

		vramDst += 0x100;
		src += 0x100;
	}
}

void load8x8SpriteToVRAM(word far *src, word vramDst) {
	loadSpriteToVRAM(src, vramDst, 1, 1);
}

void load16x16SpriteToVRAM(word far *src, word vramDst) {
	loadSpriteToVRAM(src, vramDst, 2, 2);
}

void load32x32SpriteToVRAM(word far *src, word vramDst) {
	loadSpriteToVRAM(src, vramDst, 4, 4);
}

void load32x64SpriteToVRAM(word far *src, word vramDst) {
	loadSpriteToVRAM(src, vramDst, 4, 8);
}

word spriteOffset(byte x, byte y) {
	return (y*0x10)+x;
}

word spriteOffsetVRAM(byte x, byte y) {
	return (y*0x100)+(x*0x10);
}