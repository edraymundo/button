--ifttt.lua
-- load helper module 
require ('helper')

gpio.write(red,gpio.LOW)
gpio.write(green,gpio.HIGH)

function sendmesg ()
    keyid = 0
    eventname = 0
    conn = nil
    conn=net.createConnection(net.TCP, 0) 

    keyid = helper.get_string("keyid") 
    eventname = helper.get_string("eventname")
  
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
