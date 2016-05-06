-- Example Area script
-- called when the mouse moves and a button pressed that is set to Area.lua

function main ()
 local x1 = mappy.getValue (mappy.MOUSEBLOCKX)
 local y1 = mappy.getValue (mappy.MOUSEBLOCKY)
 local x2 = mappy.getValue (mappy.MOUSEBLOCKX2)
 local y2 = mappy.getValue (mappy.MOUSEBLOCKY2)


 mappy.msgBox("Area script", "Mouse area is "..x1..","..y1.." to "..x2..","..y2, mappy.MMB_OK, mappy.MMB_ICONINFO)
end

test, errormsg = pcall( main )
if not test then
    mappy.msgBox("Error ...", errormsg, mappy.MMB_OK, mappy.MMB_ICONEXCLAMATION)
end

