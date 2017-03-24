enpc_proto = Proto("enpc","EpsonNet Protocol")

function enpc_proto.dissector(buffer,pinfo,tree)
    pinfo.cols.protocol = "ENPC"
    local subtree = tree:add(enpc_proto,buffer(),"EpsonNet Protocol Data")
    subtree:add(buffer(0,5),"EPSON Header")
    
--    subtree = subtree:add(buffer(5,1),"Query or Command")
    if string.lower(buffer(5,1):string())==buffer(5,1):string() then
        ctype="Answer"
    else
        ctype="Request"
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
    subtree:add(buffer(8,2),"Function Number: " .. buffer(8,2):uint())
    subtree:add(buffer(10,2),"Result Code: " .. buffer(10,2):uint())
    subtree:add(buffer(12,2),"Length: " .. buffer(12,2):uint())
    length=buffer(12,2):int()
    if length > 0 then
        subtree:add(buffer(14,length),"Command: " .. buffer(14,length):string())
    end
end
-- load the udp.port table
udp_table = DissectorTable.get("udp.port")
-- register our protocol to handle udp port 7777
udp_table:add(3289, enpc_proto)
