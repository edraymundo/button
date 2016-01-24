--ifttt.lua
gpio.write(green,gpio.HIGH)

function file_exists(name)
   fileresult=file.open(name,"r")
   if fileresult~=nil then file.close(fileresult) return true else return false end
end

function get_string(name)
    str = 'test'
    if file_exists(name..".txt") then
        file.open(name..".txt", "r" )
        str = file.read()
        str = string.gsub(str, "%s+", "")
        file.close()
    end 
    return str
end

function sendmesg ()
    keyid = 0
    eventname = 0
    conn = nil
    conn=net.createConnection(net.TCP, 0) 

    keyid = get_string("keyid") 
    eventname = get_string("eventname")
  
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
