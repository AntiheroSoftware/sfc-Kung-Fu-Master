-- Export Tiles as BMPs

function num_to_char ( number )
 return ( string.char ( math.mod ( math.mod ( number, 256 ) + 256, 256 ) ) )
end

function writeIntLSB ( file, number )
 file:write ( num_to_char( number )) -- x>>0
 file:write ( num_to_char( number / 256 )) -- x>>8
 file:write ( num_to_char( number / 65536 )) -- x>>16
 file:write ( num_to_char( number / 16777216 )) -- x>>24
end

function main ()
 if mappy.msgBox ("Export Tiles as BMPs", "This saves the graphics tiles as individual BMP files. Enter the filename WITHOUT the .BMP extension (T???.BMP is added).\n\nRun the script (you will be prompted for a filename to save as)?", mappy.MMB_OKCANCEL, mappy.MMB_ICONQUESTION) == mappy.MMB_OK then

  local w = mappy.getValue(mappy.BLOCKWIDTH)
  local h = mappy.getValue(mappy.BLOCKHEIGHT)
  local wp = mappy.andVal(w,-4)

  if (mappy.getValue(mappy.MAPWIDTH) == 0) then
   mappy.msgBox ("Export Tiles as BMPs", "You need to load or create a map first", mappy.MMB_OK, mappy.MMB_ICONINFO)
  else

   local isok,asname = mappy.fileRequester (".", "BMP files (*.bmp)", "*.bmp", mappy.MMB_SAVE)
   if isok == mappy.MMB_OK then

    local isok,tstrt,tend = mappy.doDialogue ("Export Tiles as BMPs", "Range:", "0,"..(mappy.getValue(mappy.NUMBLOCKGFX)-1), mappy.MMB_DIALOGUE2)
    if isok == mappy.MMB_OK then

    tstrt = tonumber (tstrt)
    tend = tonumber (tend)
    local tnum = tstrt
    while (tnum <= tend) do
-- open file as binary
     outas = io.open (asname..string.format("T%03d",tnum)..".BMP", "wb")

-- BITMAPFILEHEADER
     outas:write ('B')
     outas:write ('M')
     writeIntLSB (outas, 0)
     writeIntLSB (outas, 0)
     if (mappy.getValue(mappy.BLOCKDEPTH) == 8) then 
      writeIntLSB (outas, 54+1024)
     else
      writeIntLSB (outas, 54)
     end

-- BITMAPINFOHEADER
     writeIntLSB (outas, 40)
     writeIntLSB (outas, mappy.getValue(mappy.BLOCKWIDTH))
     writeIntLSB (outas, mappy.getValue(mappy.BLOCKHEIGHT))
     if (mappy.getValue(mappy.BLOCKDEPTH) == 8) then 
      writeIntLSB (outas, 8*65536+1)
     else
      writeIntLSB (outas, 24*65536+1)
     end
     writeIntLSB (outas, 0)
     writeIntLSB (outas, 0)
     writeIntLSB (outas, 1000)
     writeIntLSB (outas, 1000)
     writeIntLSB (outas, 0)
     writeIntLSB (outas, 0)

-- Palette for 8bit
     if (mappy.getValue(mappy.BLOCKDEPTH) == 8) then 
      local x = 0
      while x < 256 do
       local a,r,g,b = mappy.getValue(mappy.PALETTEARGB+x)
       outas:write (num_to_char(b))
       outas:write (num_to_char(g))
       outas:write (num_to_char(r))
       outas:write (num_to_char(0))
       x = x + 1
      end
     end

     local y = 0
     while y < h do
      local x = 0
      while x < w do
-- getPixel returns an index for 8bit, or a,r,g,b for other depths
       local i,r,g,b = mappy.getPixel (x, mappy.getValue(mappy.BLOCKHEIGHT)-(y+1), tnum)
       if (mappy.getValue(mappy.BLOCKDEPTH) == 8) then 
        outas:write (num_to_char(i))
       else
        outas:write (num_to_char(b))
        outas:write (num_to_char(g))
        outas:write (num_to_char(r))
       end
       x = x + 1
      end
-- end of row BMP padding
      if (mappy.getValue(mappy.BLOCKDEPTH) > 8) then 
       x = x * 3
      end
      if (mappy.andVal (x, 3) > 0) then
       outas:write (0)
       x = x + 1
      end
      if (mappy.andVal (x, 3) > 0) then
       outas:write (0)
       x = x + 1
      end
      if (mappy.andVal (x, 3) > 0) then
       outas:write (0)
      end
      y = y + 1
     end
     outas:close ()
     tnum = tnum + 1

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
