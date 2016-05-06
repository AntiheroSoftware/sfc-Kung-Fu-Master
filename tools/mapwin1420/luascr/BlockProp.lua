function main ()

 myobject = mappy.getValue (mappy.CUREDIT)
 myobjuser1 = mappy.getBlockValue (myobject, mappy.BLKUSER1)

-- Uncomment next line to see effect
-- mappy.setValue (mappy.BLOCKLABELS, "Block "..myobject.." data:;"..myobjuser1..";U2;U3;U4;U5;U6;U7;F1;F2;F3;F4;F5;F6;F7;F8;")
end

test, errormsg = pcall( main )
if not test then
    mappy.msgBox("Error ...", errormsg, mappy.MMB_OK, mappy.MMB_ICONEXCLAMATION)
end
