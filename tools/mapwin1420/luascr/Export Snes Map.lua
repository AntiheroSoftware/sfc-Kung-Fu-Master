-- Export binary file
-- Thanks to Jerzy Kut for the num_to_char function

function num_to_char ( number )
 return ( string.char ( math.mod ( math.mod ( number, 256 ) + 256, 256 ) ) )
end

function writeIntForMap ( file, number )
 file:write ( num_to_char( number ))
 file:write ( num_to_char( math.floor(number / 256) ))
end

function writeIntLSB ( file, number )
 file:write ( num_to_char( number )) -- x>>0
 file:write ( num_to_char( number / 256 )) -- x>>8
 file:write ( num_to_char( number / 65536 )) -- x>>16
 file:write ( num_to_char( number / 16777216 )) -- x>>24
end

function main ()
 if mappy.msgBox ("Export SNES MAP", "This example script will export the current layer as a binary file (CDXMap format) (anims are replaced with block 0)\nThis is the same as the default .map format when you save a .map file\n\nRun the script (you will be prompted for a filename to save as)?", mappy.MMB_OKCANCEL, mappy.MMB_ICONQUESTION) == mappy.MMB_OK then

  local w = mappy.getValue(mappy.MAPWIDTH)
  local h = mappy.getValue(mappy.MAPHEIGHT)

  if (w == 0) then
   mappy.msgBox ("Export SNES MAP", "You need to load or create a map first", mappy.MMB_OK, mappy.MMB_ICONINFO)
  else

   local isok,asname = mappy.fileRequester (".", "SNESMap files (*.map)", "*.map", mappy.MMB_SAVE)
   if isok == mappy.MMB_OK then

    if (not (string.sub (string.lower (asname), -4) == ".map")) then
     mapname = asname .. ".map"
    else
     mapname = asname
    end

   local isok,adjust = mappy.doDialogue ("Export SNES MAP", "Set pallette offset :", "0", mappy.MMB_DIALOGUE1)
   if isok == mappy.MMB_OK then
       -- open file as binary
       outas = io.open (mapname, "wb")
       local screenNum = math.floor(w / 32)
       local screen = 0
       while screen < screenNum do
         local y = 0
         while y < h do
            local x = screen*32
            --while x < w do 
            while x < (screen+1)*32 do
             --local mapval = mappy.getBlockValue (mappy.getBlock (x, y), mappy.BLKBG)
             -- Get the block number from 'Still blocks'
             local mapval = mappy.getBlock (x, y) + (adjust * 1024)
             if mapval < 0 then
                mapval = 0
             end
             writeIntForMap (outas, mapval)
             x = x + 1
            end
            y = y + 1
         end
         screen = screen + 1 
       end
       outas:close ()

       -- open file as binary
       outas = io.open (asname..".bmp", "wb")

       blockNumber = mappy.getValue(mappy.NUMBLOCKSTR)
       blockWidth = mappy.getValue(mappy.BLOCKWIDTH)
       blockHeight = mappy.getValue(mappy.BLOCKHEIGHT)
       bmpWidth = 32*blockWidth
       bmpHeight = math.floor(blockNumber/(32)+1)*blockHeight


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
     writeIntLSB (outas, bmpWidth)
     writeIntLSB (outas, bmpHeight)
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

     local currentBlock = 0
     local y = 0
     while y < bmpHeight do
      local x = 0
      while x < bmpWidth do
-- getPixel returns an index for 8bit, or a,r,g,b for other depths
       local newY = bmpHeight - y - 1
       currentBlock = math.floor(x/blockWidth) + (math.floor(newY/blockHeight)*32) 
       -- local i,r,g,b = mappy.getPixel (x, mappy.getValue(mappy.BLOCKHEIGHT)-(y+1), 0)
       -- mappy.msgBox ("SNES Block Info", "x : "..x.." , y : "..y.." blocknum : "..currentBlock, mappy.MMB_OKCANCEL, mappy.MMB_ICONQUESTION)
       if (currentBlock < blockNumber) then
        local currentBlockGFX = mappy.getBlockValue(currentBlock, mappy.BLKBG)
        local i,r,g,b = mappy.getPixel(x%8, newY%8, currentBlockGFX)
        if (mappy.getValue(mappy.BLOCKDEPTH) == 8) then 
         outas:write (num_to_char(i))
        else
         outas:write (num_to_char(b))
         outas:write (num_to_char(g))
         outas:write (num_to_char(r))
        end
       else
        outas:write (num_to_char(0))
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
     outas:close ();
    end
   end
  end
 end
end

test, errormsg = pcall( main )
if not test then
    mappy.msgBox("Error ...", errormsg, mappy.MMB_OK, mappy.MMB_ICONEXCLAMATION)
end
