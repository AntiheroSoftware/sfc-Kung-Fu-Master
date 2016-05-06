-- Export MAR files
-- Thanks to Jerzy Kut for the num_to_char function

function num_to_char ( number )
 return ( string.char ( math.mod ( math.mod ( number, 256 ) + 256, 256 ) ) )
end

function writeShortLSB ( file, number )
 file:write ( num_to_char( number )) -- x>>0
 file:write ( num_to_char( number / 256 )) -- x>>8
end

function main ()
 if mappy.msgBox ("Export MAR files", "This will export all layers as consecutive .MAR files.\nEnter the base filename WITHOUT the number or .MAR extension (??.MAR is added)\n\nRun the script (you will be prompted for a filename to save as)?", mappy.MMB_OKCANCEL, mappy.MMB_ICONQUESTION) == mappy.MMB_OK then

  local w = mappy.getValue(mappy.MAPWIDTH)
  local h = mappy.getValue(mappy.MAPHEIGHT)

  if (w == 0) then
   mappy.msgBox ("Export MAR files", "You need to load or create a map first", mappy.MMB_OK, mappy.MMB_ICONINFO)
  else

   local isok,asname = mappy.fileRequester (".", "MAR layer files (*.mar)", "*.MAR", mappy.MMB_SAVE)
   if isok == mappy.MMB_OK then

    local isok,adjust = mappy.doDialogue ("Export MAR files", "Start file number:", "0", mappy.MMB_DIALOGUE1)
    if isok == mappy.MMB_OK then

     adjust = tonumber (adjust)
-- open file as binary
     local l = 0
     while l < mappy.getValue(mappy.NUMLAYERS) do
     outas = io.open (asname..string.format("%02d.MAR", l+adjust), "wb")
     local y = 0
     while y < h do
      local x = 0
      while x < w do
       writeShortLSB (outas, mappy.getBlock (x, y, l))
       x = x + 1
      end
      y = y + 1
     end
     outas:close ()
     l = l + 1
     end

    end
   end
  end
 end
end

test, errormsg = pcall( main )
if not test then
    mappy.msgBox("Error ...", errormsg, mappy.MMB_OK, mappy.MMB_ICONEXCLAMATION)
end
