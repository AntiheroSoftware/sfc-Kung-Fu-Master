IN PROGRESS
===========

* implement first draft of upcoming grabbing enemies
* make hero lose a life and restart level or game over
* set scripted hero in title screen

BUGS
====

* reactEnemyGrab is really slow (10 vertical scanline per enemy on screen, start to slow down after 10 or 11) 
  
REFACTORING
===========

* remove some 'trick' to gain ram, and optimize execution code. I think that at the final there is plenty of ram size.
* optimize write font in game with precalc version and just copy them to VRAM (or just don't do it in VBlank)

TODO
====

* have a simple way to disable collision for testing (invincible mode)
* use superfamiconv for all conversion
* put snesgss code in sfclib
* check gfx for hero grabbed
* review sprite gfx for enemies to optimise and have full enemy gfx
* implement knife enemy
* implement midget enemy
* implement boss (use new method with setFrame, translateX, and so on ...) 
* rip gfx for bombs and dragons

DONE
====

* ~~some grab enemy have their hands up since the beginning~~ fixed 26/10/17
* ~~Sometimes there is a bug where enemy fall a second time from upper position (reproduced it on first punch hit directly going on left)
  -> this is due to the fact that the enemy start off screen and are considered like being near (or so)~~ fixed 26/10/17
* ~~high score screen (and put it in the demo loop)~~ fixed 24/10/17
* ~~Minor glitch on top of screen when setting pause due to force vblank on event that print pause (see REFACTORING)~~ fixed 24/10/17
* ~~add event in start of level (hero moving alone)~~ fixed 24/10/17
* ~~allow hero to stand at very right of level (or left in pair levels) with no scroll~~ fixed 23/10/17
* ~~Some issues with background level when scrolling, after a while or under special conditions the offset get screwed~~ fixed 23/10/17
* ~~implement "player 1" message at level start~~ fixed 17/10/17
* ~~option screen controls (a button and left/right)~~ fixed 16/10/17
* ~~option screen~~ fixed 16/10/17
* ~~snesgss is buggy with fastrom (spc_command seems faulty)~~ fixed since a while ;)
* ~~bug when quitting pause in game~~ fixzs 12/10/17
* ~~split main.asm and remove splash and intro code from it~~ fixed 11/05/17
* ~~select on main screen~~ fixed 11/05/17
* ~~use superfamicheck~~ fixed 09/05/17
* ~~add high score screen code~~ fixed 09/05/17
* ~~add code to clear an area in font.asm~~ fixed 09/05/17
* ~~add pause in game (with message)~~ fixed 09/05/17
* ~~implement font code~~ fixed 01/05/17
* ~~letter intro before first level~~ fixed 01/05/17
* ~~switch to fastrom~~ fixed 13/03/17
* ~~refactor enemy data struct for easy indexing~~ fixed 07/03/17
* ~~On level start there is somehow partly messed gfx and partly loaded frame~~ fixed 03/11/16
* ~~fix palette problems with spriteFull (more than 16 colors) Might need to have a custom tool for that~~ fixed 14/11/16
* ~~make enemy fall~~ fixed 21/11/16
* ~~scroll is not regular at all on real hardware (too much stuff during vblank ???)~~ fixed date ???
* ~~make hero fall when energy is 0~~ fixed 28/11/16
* ~~fix hero jump~~ fixed 03/12/16
* ~~make enemy scroll look ok when hero is moving~~ fixed 04/12/16
* ~~duplicate hit and and grab for enemies (24/11/16 done for grab-grab)~~ fixed 06/12/16
* ~~hit of grab enemy~~ fixed 06/12/16
* ~~set hit sprite when enemy is hit~~ 13/12/16
* ~~add heroHitType and change heroHitPosition to heroHitZone~~ 13/12/16

