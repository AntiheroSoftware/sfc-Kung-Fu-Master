function main ()

 myobject = mappy.getValue (mappy.CUREDIT)
-- myobjuser1 = mappy.getObjectValue (myobject, mappy.OBJUSER1)
-- myobjflag1 = "Blank"
-- The next line, flag 1 is 1 (as below), flag 2 is 2, flag 3 is 4, flag 4 is 8, then 16,32,64,128
-- if mappy.andVal (mappy.getObjectValue (myobject, mappy.OBJFLAGS), 1) == 0 then
--  myobjflag1 = "Not set"
-- else
--  myobjflag1 = "Set"
-- end

-- Uncomment next line to see effect
-- mappy.setValue (mappy.OBJECTLABELS, "Object "..myobject.." data:;"..myobjuser1..";U2;U3;U4;U5;U6;U7;"..myobjflag1..";F2;F3;F4;F5;F6;F7;F8;")
end

test, errormsg = pcall( main )
if not test then
    mappy.msgBox("Error ...", errormsg, mappy.MMB_OK, mappy.MMB_ICONEXCLAMATION)
end
