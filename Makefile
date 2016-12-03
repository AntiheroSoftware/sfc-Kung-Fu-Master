all: ressource rom

.PHONY: ressource rom

ressource:
	@$(MAKE) -C ressource

rom:
	@$(MAKE) -C src
