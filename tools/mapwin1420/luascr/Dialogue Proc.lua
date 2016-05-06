WM_INITDIALOG = 272
WM_COMMAND = 273

IDC_BUTTON1 = 100

function DlgProc ()
 hwnd, msg, wParam, lParam = mappy.getDialogueParam ()

-- mappy.msgBox("Dialogue Example", "Vals = "..msg..", "..wParam..", "..lParam, mappy.MMB_OK, mappy.MMB_ICONINFO)

 if msg == WM_COMMAND then
  idc = mappy.andVal (wParam, 65535)
  if idc == IDC_BUTTON1 then
    mappy.msgBox("Dialogue Example", "Clicked button 1", mappy.MMB_OK, mappy.MMB_ICONINFO)
  end
 end
end


test, errormsg = pcall( DlgProc )
if not test then
    mappy.msgBox("Error ...", errormsg, mappy.MMB_OK, mappy.MMB_ICONEXCLAMATION)
end

