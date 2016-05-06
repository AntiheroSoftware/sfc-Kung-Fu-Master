IDOK = 1
IDCANCEL = 2
IDC_BUTTON1 = 100
IDC_TEXT1 = 101

BUTTON = 128
EDIT = 129
STATIC = 130
LISTBOX = 131
SCROLLBOX = 132
COMBOBOX = 133

WS_DefButton = 1342177281
WS_Button = 1342177280
WS_Static = 1342177280
WS_Text = 1342308352
WS_Edit = 1350631424

function main ()
 dlgproc = mappy.getValue (mappy.MAPWINPATH).."luascr\\Dialogue Proc.lua"
--    mappy.msgBox(dlgproc, "Test", mappy.MMB_OK, mappy.MMB_ICONEXCLAMATION)

 NUMCONTROLS = 5 -- Important, must be number of calls to 'addDialogueItem'

 mappy.createDialogue  ("Test Dialogue", 0, 10, 10, 300, 200, NUMCONTROLS)

 mappy.addDialogueItem ("Edit field", WS_Text, 80, 17, 50, 14, 102, STATIC)
 mappy.addDialogueItem ("Change this text", WS_Edit, 132, 14, 100, 14, IDC_TEXT1, EDIT)
 mappy.addDialogueItem ("Button 1", WS_Button, 10, 10, 50, 20, IDC_BUTTON1, BUTTON)
 mappy.addDialogueItem ("Cancel", WS_Button, 236, 170, 50, 20, IDCANCEL, BUTTON)
 mappy.addDialogueItem ("OK", WS_DefButton, 200, 170, 30, 20, IDOK, BUTTON)

 mappy.doDialogue (dlgproc)
end

test, errormsg = pcall( main )
if not test then
    mappy.msgBox("Error ...", errormsg, mappy.MMB_OK, mappy.MMB_ICONEXCLAMATION)
end

