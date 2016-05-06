require 'bit'
require 'hex'

function writeIntForMap ( file, number )
 file:write ( num_to_char( number ))
 file:write ( num_to_char( math.floor(number / 256) ))
end

function num_to_char ( number )
 return ( string.char ( math.mod ( math.mod ( number, 256 ) + 256, 256 ) ) )
end

function string:split(sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

function paletteConversion(red, green, blue)

	data=0

	temp = 0
	rounded = 0

	-- get blue portion and round it off
	temp = bit.band(blue,1)		-- see if this needs rounding
	if (blue == 63) then		-- if value == 63, then we can't round up
		temp = 0
		rounded = 1
	end

	data = bit.brshift(blue, 1) + bit.band(temp,rounded)				-- round up if necessary
	rounded = bit.bxor(temp, rounded)		-- reset rounded down flag after rounding up

	-- get green portion and round it
	temp = bit.band(green, 1)	-- see if this needs rounding
	if green == 63 then		--if value == 63, then we can't round up
		temp = 0
		rounded = 1
	end
	data = bit.blshift(data, 5) + bit.brshift(green, 1) + bit.band(temp,rounded)			-- round up if necessary
	rounded = bit.bxor(temp, rounded)		--reset rounded down flag after rounding up

	-- get red portion and round it
	temp = bit.band(red, 1)	-- see if this needs rounding
	if red == 63 then			-- if value == 63, then we can't round up
		temp = 0
		rounded = 1
	end
	data = bit.blshift(data, 5) + bit.brshift(red, 1) + bit.band(temp,rounded)				-- round up if necessary
	rounded = bit.bxor(temp, rounded)		--reset rounded down flag after rounding up

	return data

end

function main ()

	mappy.msgBox ("ERROR", "Rearrange palette start ...", mappy.MMB_OKCANCEL, mappy.MMB_ICONQUESTION)

	mappy.msgBox ("ERROR", "num_tiles = "..mappy.getValue(mappy.NUMBLOCKGFX), mappy.MMB_OKCANCEL, mappy.MMB_ICONQUESTION)

	local num_tiles = mappy.getValue(mappy.NUMBLOCKGFX)
	local color = 16

	local combos = {}
	local num = {}
	local list = {}

	local final = {}

	local i,ii

	-- clear combos list 
	for i=0,(num_tiles-1)*16,1 do 
		combos[i] = 0
	end

	-- start each list having one color... color zero
	for i=0,num_tiles-1,1 do 
		num[i] = 1
	end

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
    	mappy.setValue(mappy.PALETTEARGB+key, 0, pixel[1], pixel[2], pixel[3])
    	index = index+1
    end

    -- clean rest of the palette
    mappy.msgBox ("SNES Block Info", "New palette size : "..index, mappy.MMB_OKCANCEL, mappy.MMB_ICONQUESTION)
    for i=index,255,1 do
		mappy.setValue(mappy.PALETTEARGB+i, 0, 0, 0, 0)
    end

	-- now, build up the 'color combo' list...
	for index=0,num_tiles-1,1 do
		for x=0,7,1 do
	    	for y=0,7,1 do
	    		data = mappy.getPixel(x, y, index)

	    		-- is this color already in the list?
	    		ii = 0
	    		while ii < num[index] do
	    			if combos[index*16+ii] == data then
	    				break
	    			end
	    			ii = ii + 1
	    		end

	    		-- if not add it to the list
	    		if ii == num[index] then
	    			-- is combo full
	    			if num[index] == color then
	    				mappy.msgBox ("ERROR", "Detected more colors in one 8x8 tile than is allowed.", mappy.MMB_OKCANCEL, mappy.MMB_ICONQUESTION)
	    				return
	    			end 

					combos[index*16+ii] = data
					num[index] = num[index] + 1
	    		end	
	    	end
	    end
	end

	-- // now sort combos in order of number of colors (greatest to least)
	-- 
	-- here's some more horrid code... I know this is all messy and
	-- slow, but hey... I just don't care right now.
	n = 0
	for ii=color,1,-1 do
		for i=0,num_tiles-1,1 do
			if num[i] == ii then
				list[n] = i
				n = n + 1
			end	
		end
	end	

	-- ok, now try to combine the combos
	last_index = -1
	num_final = 0
	while num_final <= 8 do

		-- start looking for next 'non-combined' combo in the list
		index=last_index+1
		while index < num_tiles do
			if num[list[index]] > 0 then
				break
			end
			index = index +1
		end

		-- if none... we're done
		if index == num_tiles then
			break
		end

		-- test = combo # of new 'final combo'
		test = list[index];
		last_index = index;

		-- check if we've failed
		if num_final == 8 then
			mappy.msgBox ("ERROR", "Not enough colors/palettes to represent the picture.", mappy.MMB_OKCANCEL, mappy.MMB_ICONQUESTION)
			return		
		end

		-- if one exists, then add to final and start combining
		final[num_final] = test
		n = index + 1
		while n < num_tiles do
			-- n = index into sorted list of combos

			-- test  = combo # of new 'final combo'
			-- test2 = combo we're going to try to combine with the 'final combo'
			test2 = list[n];

			-- if not combined to someone... continue
			num_miss = 0;
			if num[test2] >= 0 then
				-- can it be combined?
				
				for ii=test2*16,test2*16+num[test2]-1,1 do 
					-- ii = index into the 'attempting to combine' combo
					--  i = index into the 'final combo'

					-- check for non-matched colors
					i = test*16
					while i < test*16+num[test]+num_miss do 
						if combos[ii]==combos[i] then
							break
						end
						i = i + 1
					end

					-- is there a miss?
					if i == test*16+num[test]+num_miss then
						if num[test]+num_miss == color then
							--print("got miss "..num[test]+num_miss)
							-- we can't add anymore colors
							-- this combine has failed
							num_miss=-1
							break
						end
					
						-- temporarily add the missed color to the 'final combo'
						combos[test*16 + num[test] + num_miss] = combos[ii]
						num_miss = num_miss + 1
					end
				end -- loop - try to combine an individual combo 
		
				-- did we succeed?
				if num_miss >= 0 then
					-- permanently add in the new colors;
					num[test] = num[test] + num_miss
					-- save the final_num here, and make this negative to show it 
					-- has been combined
					num[test2] = num_final - 100	
				end
			end

			n = n + 1
		end

		num_final = num_final + 1
	end

	-- Yeah! ... if we made it here it worked! 
	-- (assuming my code is right)
	mappy.msgBox ("YEAHHHH", "Rearrangement possible!! Accomplished in "..(num_final-1).." palettes...", mappy.MMB_OKCANCEL, mappy.MMB_ICONQUESTION)
	
	new_palette = {}
	-- create the new palettes and write them to disk 
	-- make the palette conversion
	for i=0,num_final-1, 1 do
		new_palette[i] = {}
		for ii=0,num[final[i]]-1,1 do
			index = combos[ final[i]*16 + ii ]
			local a,r,g,b = mappy.getValue(mappy.PALETTEARGB+index)
			--new_palette[i][ii] = paletteConversion(r, g, b)
			pal_color = bit.brshift(b, 3) * 1024 + bit.brshift(g, 3) * 32 + bit.brshift(r, 3)
			new_palette[i][ii] = pal_color

		end
	end

	-- write palette to file
	for i=0,num_final-1, 1 do
	    outas = io.open("palette"..i..".pal", "wb")
	    if (mappy.getValue(mappy.BLOCKDEPTH) == 8) then 
	     	local x = 0
	    	while x < num[final[i]] do
 				outas:write ( num_to_char( new_palette[i][x] )) 				-- x>>0
 				outas:write ( num_to_char( bit.brshift(new_palette[i][x],8) )) 	-- x>>8
		       	x = x + 1
	      	end
	      	while x < 16 do
				outas:write ( num_to_char( 0 )) -- x>>8
 				outas:write ( num_to_char( 0 )) -- x>>0
 				x = x + 1
	      	end
	    end
	    outas:close()
	end

	-- convert the image in a buffer
	buffer = {}
	block_palette = {}

	for i=0,num_tiles-1, 1 do

		color_table = {}

		-- find which 'final combo' this block uses
		if num[i]>0 then
			-- this block's combo became a final

			-- find which final it is
			n = 0
			while n < num_final do
				if final[n]==i then 
					break
				end
				n = n + 1
			end
		else
			n = num[i] + 100
		end

		block_palette[i] = n
		print('Block : '..i.." Palette : "..n)

		-- make the conversion table
		for ii=0, num[final[n]]-1, 1 do
			index = combos[ final[n]*16 + ii ]
			color_table[index] = n*16 + ii
		end
				
		-- convert the block in buffer
		buffer[i] = {}
		for x=0,7,1 do
			buffer[i][x] = {}
	    	for y=0,7,1 do
	    		buffer[i][x][y] = color_table[mappy.getPixel(x, y, i)]
	    	end
	    end
	end

	for y=0,7,1 do
		for x=0,7,1 do
			print("buffer x : "..x.." y : "..y.." value : "..hex.to_hex(buffer[1][x][y]))
    	end
    end

	-- write map to file
	outas = io.open ("map.map", "wb")
	local w = mappy.getValue(mappy.MAPWIDTH)
	local h = mappy.getValue(mappy.MAPHEIGHT)
   	local screenNum = math.floor(w / 32)
   	local screen = 0
   	while screen < screenNum do
    	local y = 0
    	while y < h do
        	local x = screen*32
        	while x < (screen+1)*32 do
             --local mapval = mappy.getBlockValue (mappy.getBlock (x, y), mappy.BLKBG)
             -- Get the block number from 'Still blocks'

             -- TODO fix flip bits

             local paletteNumber = 0

			block_value = mappy.getBlockValue (mappy.getBlock (x, y), mappy.BLKBG)
			hflip = mappy.getBlockValue (mappy.getBlock (x, y), mappy.BLKFLAG7)
			vflip = mappy.getBlockValue (mappy.getBlock (x, y), mappy.BLKFLAG8)
             -- print(x.." "..y.." -> "..mappy.getBlock(x, y).." lpatte number : "..block_palette[block_value])

             local mapval = block_value + bit.blshift(block_palette[block_value],10) + bit.blshift(hflip,14) + bit.blshift(vflip,15)
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

   	-- write tiles to file
   	outas = io.open ("pic.pic", "wb")
   	
   	for i=0,num_tiles-1, 1 do
   		--i = 1
	   	bitplanes = 4
	   	data = 0
	   	for b=0,bitplanes-1, 2 do -- loop through bitplane pairs
			for y=0,7,1 do

				data = 0

				-- get bit-mask
				mask = bit.blshift(1,b)

				--print("MASK : "..hex.to_hex(mask))

				-- get row of bit-plane
				for x=0,7,1 do
					data = bit.blshift(data,1)
					--print("condition : "..bit.band(buffer[i][x][y],mask).." "..hex.to_hex(buffer[i][x][y]).." "..hex.to_hex(mask))
					if bit.band(buffer[i][x][y],mask) > 0 then
						data = data+1;
					end
				end

				--print("DATA : "..hex.to_hex(data))

				-- save row
				outas:write ( num_to_char( data ))

				data = 0

				-- adjust bit-mask
				mask = bit.blshift(mask,1);

				--print("MASK* : "..hex.to_hex(mask))

				-- get row of next bit-plane
				for x=0,7,1 do
					data = bit.blshift(data,1)
					--print("condition* : "..bit.band(buffer[i][x][y],mask).." "..hex.to_hex(buffer[i][x][y]).." "..hex.to_hex(mask))
					if bit.band(buffer[i][x][y],mask) > 0 then
						data = data+1;
					end
				end

				--print("DATA* : "..hex.to_hex(data))

				-- save row
				outas:write ( num_to_char( data ))
			end
		end

   	end
   	outas:close ()

end

test, errormsg = pcall( main )
if not test then
    mappy.msgBox("Error ...", errormsg, mappy.MMB_OK, mappy.MMB_ICONEXCLAMATION)
end
