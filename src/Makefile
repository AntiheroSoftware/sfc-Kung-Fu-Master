ERASE=del

CC=wdc816cc.exe
AS=wdc816as.exe
LN=wdcln.exe

SRC_C= $(wildcard *.c)
SRC_ASM= $(wildcard *.asm)

OBJ= $(SRC_C:.c=.o)
OBJ+= $(SRC_ASM:.asm=.o)

all: clean rom.smc

rom.smc : $(OBJ) 
	$(CC) -I "../Snes Lib/include" -AT -QV -wl -wp -sop -MS main.c -o main.a
	$(CC) -I "../Snes Lib/include" -AT -QV -wl -wp -sop -MS main2.c -o main2.a
	$(CC) -I "../Snes Lib/include" -AT -QV -wl -wp -sop -MS level.c -o level.a
	$(CC) -I "../Snes Lib/include" -AT -QV -wl -wp -sop -MS level2.c -o level2.a
	$(LN) -HB -M21 -V -T -PFF \
		-C008000,0000 -D003000,050000 \
		-U0200,0000 \
		-Avectors=FFE4,7FE4 \
		-Aregistration_data=FFB0,7FB0 \
		-Aressource=18000,8000 \
		-AlevelRessource=28000,10000 \
		-AlevelMapRessource=38000,18000 \
		-AscoreRessource=48000,20000 \
		-AspriteRessource=58000,28000 \
		-AspriteRessource2=68000,30000 \
		-Anes_code=78000,40000 \
		-Aspc_code=10000,10000 \
		-N \
		$(OBJ) \
		-L"../Snes Lib/lib/snes" \
		-LC:\65xx_FreeSDK\lib\cs -O rom.smc
	tools\padbin.exe 0x40000 rom.smc

%.o: %.c
	$(CC) -I "../Snes Lib/include" -AT -QV -wl -wp -sop -MS $< -o $(@:.o=.a)
	$(CC) -I "../Snes Lib/include" -QV -wl -wp -sop -MS $< -o $@

%.o: %.asm
	$(AS) -V $< -o $@

spc.bin: 
	cd 2a03/SPC && tasm.exe -t07 -b spc.asm && cd ../..

ressource: ressource/*
	tools\Pcx2Snes.exe ressource/kungfu -n -c16 -screen
	tools\Pcx2Snes.exe ressource/level-block -n -s8 -c128 -o32 
	tools\Pcx2Snes.exe ressource/level1.map -n -s8 -c128
	tools\Pcx2Snes.exe ressource/score.map -n -s8 -c16 -o16 
	tools\Pcx2Snes.exe ressource/test.map -n -s8 -c16 -o16
	tools\Pcx2Snes.exe ressource/sprite -n -c16 -s32 -o16
	tools\Pcx2Snes.exe ressource/ennemies -n -c16 -s32 -o16
	tools\Pcx2Snes.exe ressource/debugFont -n -c16 -s8 -o16

clean:
	-$(ERASE) *.obj
	-$(ERASE) *.o
	-$(ERASE) 2a03/*.obj
	-$(ERASE) 2a03/*.o
	-$(ERASE) *.lst
	-$(ERASE) *.usage
	-$(ERASE) *.map
	-$(ERASE) *.smc
	-$(ERASE) Valid.Ext