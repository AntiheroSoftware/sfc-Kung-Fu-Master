-- Set Text Strings

-- See the main docs for information on text strings
-- For this example, keep the strings in a table, you could parse a textfile

-- String 0 is not shown in the map (blank)
textstrings = {
"None set",
"Text string 1",
"Text string 2",
"Text string 3",
"Text string 4",
"Text string 5",
"Text string 6",
"Text string 7, the last one"
}

function main()

 if mappy.msgBox("Set Text Strings", "An example of how to load text strings into a FMP map, see the 'Set Text Strings.lua' source for more info.\n\nContinue?", mappy.MMB_OKCANCEL, mappy.MMB_ICONQUESTION ) == mappy.MMB_OK then

-- load the strings in order
  for i = 1,table.getn(textstrings) do
   mappy.setTextString (i-1, textstrings[i])
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

