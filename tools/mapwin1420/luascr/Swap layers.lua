-- Swap layers

function main ()
 local w = mappy.getValue(mappy.MAPWIDTH)
 local h = mappy.getValue(mappy.MAPHEIGHT)

 if (w == 0) then
  mappy.msgBox ("Swap layers", "You need to load or create a map first", mappy.MMB_OK, mappy.MMB_ICONINFO)
 else

  local isok,index1,index2 = mappy.doDialogue ("Swap layers", "Enter layer numbers:", "0,1", mappy.MMB_DIALOGUE2)
  if isok == mappy.MMB_OK then
   mappy.copyLayer(index1, mappy.MPY_UNDO)
   mappy.copyLayer(index2, index1)
   mappy.copyLayer(mappy.MPY_UNDO, index2)
  end
 end
end

test, errormsg = pcall( main )
if not test then
    mappy.msgBox("Error ...", errormsg, mappy.MMB_OK, mappy.MMB_ICONEXCLAMATION)
end
