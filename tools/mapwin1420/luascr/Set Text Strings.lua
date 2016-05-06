-- Set Text Strings

-- See the main docs for information on text strings

-- String 0 is not shown in the map (blank)

function main()

 if mappy.msgBox("Set Text Strings", "Load text strings into a FMP map. Select a text file, each line will be a string.\n\nContinue?", mappy.MMB_OKCANCEL, mappy.MMB_ICONQUESTION ) == mappy.MMB_OK then

  local isok,asname = mappy.fileRequester (".", "Textfile (*.txt)", "*.txt", mappy.MMB_OPEN)
  if isok == mappy.MMB_OK then

   local i = 0
   for line in io.lines (asname) do
    mappy.setTextString (i, line)
    i = i + 1
   end
  end


-- replace an existing string
-- mappy.setTextString (3, "Replaced string number 3")

-- delete string (only works on last string, send "-del")
-- mappy.setTextString (mappy.getValue(mappy.NUMTEXTSTR)-1, "-del")

  local isok,index = mappy.doDialogue ("Set Text Strings", "Which Block/Object user field?", "1", mappy.MMB_DIALOGUE1)
  index = tonumber (index)
  mappy.setValue(mappy.STRBLKUSER, index)
  mappy.setValue(mappy.STROBJUSER, index)
 end
end

test, errormsg = pcall( main )
if not test then
    mappy.msgBox("Error ...", errormsg, mappy.MMB_OK, mappy.MMB_ICONEXCLAMATION)
end

