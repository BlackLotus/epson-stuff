enpc_proto = Proto("enpc","EpsonNet Protocol")

function enpc_proto.dissector(buffer,pinfo,tree)
    pinfo.cols.protocol = "ENPC"
    local subtree = tree:add(enpc_proto,buffer(),"EpsonNet Protocol Data")
    subtree:add(buffer(0,5),"EPSON Header")
    
--    subtree = subtree:add(buffer(5,1),"Query or Command")
    if string.lower(buffer(5,1):string())==buffer(5,1):string() then
        ctype="Reply"
    else
--  it's a request and doesn't have to be defined
        ctype=""
    end
    if string.lower(buffer(5,1):string())=="q" then
        subtree:add(buffer(5,1),"Type: Query " .. ctype)
    elseif string.lower(buffer(5,1):string())=="c" then
        subtree:add(buffer(5,1),"Type: Command " .. ctype)
    elseif string.lower(buffer(5,1):string())=="s" then
        subtree:add(buffer(5,1),"Type: _S_omething else " .. ctype)
    else
        subtree:add(buffer(5,1),"Type: " .. buffer(5,1):string() .. ctype)
    end
    subtree:add(buffer(6,1),"Device Type: " .. buffer(6,1):uint())
    subtree:add(buffer(7,1),"Device Number: " .. buffer(7,1):uint())
-- get function (maybe use a case instead)
    freturn=buffer(8,2):uint()
    if freturn==0 then
        func="Basic Information"
    elseif freturn==0x10 then
        func="Status"
    elseif freturn==0x11 then
-- needs flow control and stuff
        func="Forced Transmission"
    elseif freturn==0x12 then
        func="Reset"
    elseif freturn==0x13 then
        func="Buffer Flash"
    elseif freturn==0x16 then
        func="Clearing Connection Timeout Timer"
    else
        func="Unknown Function"
    end

    subtree:add(buffer(8,2),"Function Number: " .. buffer(8,2):uint() .. " " .. func)

    if ctype=="" then
        subtree:add(buffer(10,2),"(Fixed Value 0x0000) " .. buffer(10,2):uint())
    else
        if buffer(10,2):uint()==0 then
            subtree:add(buffer(10,2),"Result Code: " .. buffer(10,2):uint() .. " (Normal end)")
        elseif buffer(10,2):uint()==65534 then
            subtree:add(buffer(10,2),"Result Code: " .. buffer(10,2):uint() .. " (No device requested)")
        elseif buffer(10,2):uint()==65535 then
            subtree:add(buffer(10,2),"Result Code: " .. buffer(10,2):uint() .. " (Function not supported)")
        else
-- TODO: add functions
            subtree:add(buffer(10,2),"Result Code: " .. buffer(10,2):uint() .. " (Unknown result code)")
        end
    end
    subtree:add(buffer(12,2),"Command Length: " .. buffer(12,2):uint())
    length=buffer(12,2):int()
    if length > 0 then
        if ctype=="" then
            subtree = subtree:add(buffer(14,length), "Command")
            subtree:add(buffer(14,length),"Foo: " .. buffer(14,length):string())
         else
            subtree = subtree:add(buffer(14,length), "Reply Data")
            subtree:add(buffer(14,length),"Foo: " .. buffer(14,length):string())
         end
    end
end
-- load the udp.port table
udp_table = DissectorTable.get("udp.port")
udp_table:add(3289, enpc_proto)
