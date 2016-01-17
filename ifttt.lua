--ifttt.lua

function file_exists(name)
   fileresult=file.open(name,"r")
   print(fileresult)
   if fileresult~=nil then file.close(fileresult) return true else return false end
end


function sendmesg ()
    keyid = 0
    eventname = 0
    conn = nil
    conn=net.createConnection(net.TCP, 0) 
    if file_exists("keyid.txt") then
        file.open("keyid.txt", "r" )
        keyid = file.read()
        keyid = string.gsub(keyid, "%s+", "")
        file.close()
        print("IFTTT keyid: "..keyid)
    end    
    --print("IFTTT Maker Key: "..iftttKey)

    if file_exists("eventname.txt") then
        file.open( "eventname.txt", "r" )
        eventname = file.read()
        eventname = string.gsub(eventname, "%s+", "")
        file.close()
        print("IFTTT Event Name: "..eventname)
    end    

  --bbrY8InVQ4qwP0fdfgn7cK
    conn:on("connection", function(conn, payload) 
         conn:send("GET /trigger/"..eventname.."/with/key/"..keyid
         .." HTTP/1.1\r\n" 
         .."Host: maker.ifttt.com\r\n"
         .."Accept: */*\r\n" 
         .."User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n" 
         .."\r\n")     
     end) 

    conn:on("receive", function(conn, payload)
        print(payload)
        print('Posted to ifttt.com')           
        print("Going to deep sleep...")
        conn:close()       
        node.dsleep(0)
    end)
    conn:connect(80,'maker.ifttt.com')
end
    
sendmesg()
