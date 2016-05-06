-- SNES 16x16 sprite export
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

	local isok,asname = mappy.fileRequester (".", "Sprite tiles file (*.pic)", "*.pic", mappy.MMB_SAVE)

end

test, errormsg = pcall( main )
if not test then
    mappy.msgBox("Error ...", errormsg, mappy.MMB_OK, mappy.MMB_ICONEXCLAMATION)
end