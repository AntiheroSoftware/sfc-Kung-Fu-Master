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

function string:split(sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

function main ()
	local w = mappy.getValue(mappy.MAPWIDTH)
  	local h = mappy.getValue(mappy.MAPHEIGHT)

  	-- mappy.msgBox ("SNES Block Info", "Block (1,1) : "..mappy.getBlock(1,1), mappy.MMB_OKCANCEL, mappy.MMB_ICONQUESTION)
  	-- mappy.msgBox ("SNES Block Info", "Block (6,1) : "..mappy.getBlock(6,1), mappy.MMB_OKCANCEL, mappy.MMB_ICONQUESTION)

  	-- mappy.msgBox ("SNES Block Info", "NUMBLOCKSTR : "..mappy.getValue(mappy.NUMBLOCKSTR), mappy.MMB_OKCANCEL, mappy.MMB_ICONQUESTION)
  	mappy.msgBox ("SNES Block Info", "NUMBLOCKGFX : "..mappy.getValue(mappy.NUMBLOCKGFX), mappy.MMB_OKCANCEL, mappy.MMB_ICONQUESTION)

	-- mappy.msgBox ("SNES Block Info", "Block Value 4 : "..mappy.getBlockValue(4,mappy.BLKBG), mappy.MMB_OKCANCEL, mappy.MMB_ICONQUESTION)
  	-- mappy.msgBox ("SNES Block Info", "Block Value 6 : "..mappy.getBlockValue(6,mappy.BLKBG), mappy.MMB_OKCANCEL, mappy.MMB_ICONQUESTION)

  	-- set palette color
	--mappy.setValue(mappy.PALETTEARGB+11, 0, 0, 0, 0)

  	-- get all colors from images
  	local colors = {}
  	if (mappy.getValue(mappy.BLOCKDEPTH) == 8) then 
    	local x = 0
    	while x < 256 do
	       local a,r,g,b = mappy.getValue(mappy.PALETTEARGB+x)
	       colors[r..':'..g..':'..b] = x
	       x = x + 1
      	end
    end

    -- optimize palette to remove duplicates
    local palette = {}
    local index = 1
    for key, value in pairs(colors) do 
    	palette[index] = key
    	colors[key] = index
    	index = index + 1
    end

    -- change palette index of pixels
    for block=0,mappy.getValue(mappy.NUMBLOCKGFX)-1,1 do
    	for x=0,7,1 do
	    	for y=0,7,1 do
	    		value = mappy.getPixel(x, y, block)
	    		local a,r,g,b = mappy.getValue(mappy.PALETTEARGB+value)
	    		--mappy.msgBox ("SNES Block Info", "Palette value : "..x..":"..y.." "..value.." -> "..colors[r..':'..g..':'..b], mappy.MMB_OKCANCEL, mappy.MMB_ICONQUESTION)
	    		mappy.setPixel(x, y, block, colors[r..':'..g..':'..b])
	    	end
	    end
	end
    
    -- set new palette
    index = 1
    for key, value in pairs(palette) do 
    	pixel = string.split(value, ":")
    	--mappy.msgBox ("SNES Block Info", "Palette value : "..key.." : "..value, mappy.MMB_OKCANCEL, mappy.MMB_ICONQUESTION)
    	mappy.setValue(mappy.PALETTEARGB+key, 0, pixel[1], pixel[2], pixel[3])
    	index = index+1
    end

    -- clean rest of the palette
    mappy.msgBox ("SNES Block Info", "New palette size : "..index, mappy.MMB_OKCANCEL, mappy.MMB_ICONQUESTION)
    for i=index,255,1 do
		mappy.setValue(mappy.PALETTEARGB+i, 0, 0, 0, 0)
    end

    -- write palette to file
    outas = io.open("test.pal", "wb")
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
    outas:close()

end

test, errormsg = pcall( main )
if not test then
    mappy.msgBox("Error ...", errormsg, mappy.MMB_OK, mappy.MMB_ICONEXCLAMATION)
end