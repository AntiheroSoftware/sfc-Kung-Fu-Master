-- FMP info
-- Thanks to Jerzy Kut for the num_to_char function
-- Thanks to Robbob for the ReadChunkSize function

function num_to_char ( number )
 return ( string.char ( math.mod ( math.mod ( number, 256 ) + 256, 256 ) ) )
end

function ReadChunkID( file )
 acc = ""
 acc = acc..file:read(1)
 acc = acc..file:read(1)
 acc = acc..file:read(1)
 acc = acc..file:read(1)
 return acc
end

function ReadChunkSize( file )
 acc = 0
 acc = acc + string.byte( file:read(1) )
 acc = acc * 256
 acc = acc + string.byte( file:read(1) )
 acc = acc * 256
 acc = acc + string.byte( file:read(1) )
 acc = acc * 256
 acc = acc + string.byte( file:read(1) )   
 return acc
end

function main ()
 if mappy.msgBox ("FMP info", "This will show the chunks and their length in a selected FMP file. Run the script (you will be prompted for a FMP to open)?", mappy.MMB_OKCANCEL, mappy.MMB_ICONQUESTION) == mappy.MMB_OK then

  local isok,asname = mappy.fileRequester (".", "FMP files (*.fmp)", "*.fmp", mappy.MMB_OPEN)
   if isok == mappy.MMB_OK then

    infpt = io.open (asname, "rb")
    chkid = ReadChunkID (infpt)

    if chkid ~= "FORM" then
     mappy.msgBox ("FMP info", "Not a FMP file "..chkid, mappy.MMB_OK, mappy.MMB_ICONINFO)
     return
    end

    fmplen = ReadChunkSize (infpt)

    fmpid = ReadChunkID (infpt) -- FMAP id
    fmpinfo = "FMP file info:\n\n"..asname.."\nFMP file length "..(fmplen+8).."\n"..chkid.." Type: "..fmpid.." Length: "..fmplen.."\n"
    fmplen = fmplen - 4

    while chkid ~= 0 do
     chkid = ReadChunkID (infpt)
     chklen = ReadChunkSize (infpt)
     fmpinfo = fmpinfo.."Chunk id: "..chkid.."  Length: "..chklen.."\n"
     infpt:read (chklen)
     fmplen = fmplen - (chklen+8)
     if fmplen <= 0 then
      break
     end
    end

    infpt:close ()

    mappy.msgBox ("FMP info", fmpinfo, mappy.MMB_OK, mappy.MMB_ICONINFO)

  end
 end
end

test, errormsg = pcall( main )
if not test then
    mappy.msgBox("Error ...", errormsg, mappy.MMB_OK, mappy.MMB_ICONEXCLAMATION)
end
