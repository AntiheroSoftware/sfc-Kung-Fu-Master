1.4.20
Fixed crash when User info is shown with 3D walls (wnesmode)
Added 3D walls mode to MapTools menu (wnesmode)
Pro: OBJGXOFF and OBJGYOFF now read and set from lua
Pro: Custom mousebuttons now work in Graphics editor (block0=colour0, pick, fill, line)
Pro: Drag map now works in Object editor
Fixed user info display length can now be changed
Compiled with latest mingw, lua (5.1.2) and libpng (1.2.24)
Keys i, k and m can be customised in mapwin.ini (keyi, keyk and keym)
ctrl-x or Edit cut can now display a warning with 'warnctrlx=1' in mapwin.ini

1.4.19
32bit FMPS now have true alphablend (use onionskin or move graphics from BG to FG field 
with 'range edit blocks')
Fixed several lua dialogue functions
Overlap maps (where stagger is 0x0, but blockgap is different from blocksize) now 
work properly (use onionskin on a blank layer for transparent overlap), disable 
grid for less depth sort artifacts
'Grab Brush from block sequence' works better, size the Block Window so the area is
aligned, select the top left block, then select the bottom right block, then select
'Grab Brush from block sequence' in the Brushes menu and accept the defaults.

1.4.18
Fixed object drag bug
Fixed block properties from 1.4.17 (user 5,6,7 still signed)
Improved Dialogue example slightly
Fixed a mapwin.ini textexportopts comment

1.4.17 (beta 1 to 5 are now 1.4.12 to 1.4.16)
Any Dialogue through lua (see examples Dialogue Example and Dialogue Proc in luascr)
Undo for all buttons
Fix crash on make map from big picture
Set text export defaults in mapwin.ini
investigate atoi blank field in block properties
any action with mousebuttons (see mapwin.ini)


Beta 5:
Toggling the Flip V and Flip H flags in block properties redraws the dialogue
BlockProp.lua and ObjectProp.lua are called each time the properties dialogue is drawn, allowing labels to be changed (see examples in luascr folder)
Grid no longer drawn in software zoomout (0.5 and 0.25)
Lua: moveWindow (WINDOW, x, y, width, height) added (WINDOW = MPY_MAINWINDOW, MPY_MAPWINDOW or MPY_BLOCKWINDOW)
Setting text strings is now much easier (from textfile)

---------------------------------------------------------------------------------

Beta 4:
Zoom 0.25 should work with bigger window sizes
Pro: Added duplicate current object and place with ctrl+click
Lua: Can run a lua script by dragging an area (luascr/Area.lua)
Pro: Fixed brush window so anims are displayed
New Block properties dialogue with settable labels
Pro: New Object properties dialogue with settable labels

To set user labels, add lines like this to mapwin.ini (16labels, each end with ';')
blockdialoguelabels=User data:;U1;U2;U3;U4;U5;U6;U7;tl;tr;bl;br;bg transp;flag 1;flag 2;flag 3;
objectdialoguelabels=Object data:;U1;U2;U3;U4;U5;U6;U7;F1;F2;F3;F4;F5;F6;F7;F8;
Should also be able to set with lua:
mappy.setValue (mappy.BLOCKLABELS, "User data:;U1;U2;U3;U4;U5;U6;U7;tl;tr;bl;br;bg transp;flag 1;flag 2;flag 3;")
mappy.setValue (mappy.OBJECTLABELS, "Object data:;U1;U2;U3;U4;U5;U6;U7;F1;F2;F3;F4;F5;F6;F7;F8;")

---------------------------------------------------------------------------------

Beta 3:
Added lua function 'mappy.renameMenuItem (123, "Test rename")' number is a shortcut as in docs.
Lua: Added new get/setValue (MAPONION)
Lua: Added new get/setValue (MAPDARK)
Lua: Can now add 30 lua script in ini file (16 in menu, rest can be set to keys)
Export:Current Layer as big picture now exports 24bit if 8bit map has darken or objects displayed

Known bugs:
pro: graphic overlap with tall window (aspect) on 'graph'
'trail' left on zoom (press any arrow key to clear it)

Fixed from Beta 2:
+ zoom 0.25 crashes in 1280x1024 softscale
+ Resize map needs fixing (parts of map lost on some resizes. Topleft=0,0 is fine)
+ pro: add next/prev on 'graph'
+ pro: add requested select graphic of current block in 'graph' option
+ pro: Use DrawScreen for corner map view in 'graph' mode
+ wrong scroll amount with mousewheel
+ minor colour problems with output in 8bit 'Export:Current Layer as big picture' (lost background with darkened background, wrong colour dividers)

---------------------------------------------------------------------------------

Beta 2:
Done:
Fixed tbarinfo=5 option (TextStrings in titlebar)
Added support for loading unknown graphics files with MAPEXT.DLL
Pro: Added lua funcs getObjectFilename (index), setObjectFilename (index, string),
getObjectSort (index), setObjectSort (index, objnum).
Added new getValue (NUMFILESTR)
Fix export big BMP (background=crash)
Pro: Added Pick object under mouse with 'p'
Resize dialogue add new topleft coords
Soft scaling instead of StretchBlt (zmstyle=0 in mapwin.ini)
Export:Current Layer as big picture much improved, shows objects, onionskin, dividers etc if enabled, ie how it looks in the editor
Added extra mousebuttons in Custom:Mousebuttons

Todo:
More about 32bit alpha in the docs
More pro docs
Add new lua scripts and tidy Custom menu
Possibly add user defined labels to property dialogues


Resize map notes:
1) Choose new width and height.
2) Click a centering square, or enter new left and top manually
3) Click OK
