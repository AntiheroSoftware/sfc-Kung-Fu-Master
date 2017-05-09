all: ressource rom

.PHONY: ressource rom

ressource:
	@$(MAKE) -C ressource

rom:
	@$(MAKE) -C src
	../Tools/SuperFamicheck/bin/superfamicheck -f -s kungfumaster.sfc
