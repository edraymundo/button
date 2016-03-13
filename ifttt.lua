--ifttt.lua
-- load helper module 
require ('helper')

gpio.write(red,gpio.LOW)
gpio.write(green,gpio.HIGH)

function encode(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w %-%_%.%~])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end
  return str    
end


function sendmesg ()
    phone = 0
    mesg = 0
    provider = 0
    conn = nil
    conn=net.createConnection(net.TCP, 0) 

    phone = helper.get_string("phone") 
    mesg = encode(helper.get_string("mesg"))
    provider = helper.get_string("provider")

    if provider == 'verizon' then
        phone = phone.."@vtext.com"
    elseif provider == 'tmobile' then
        phone = phone.."@tmomail.net" 
    elseif provider == 'att' then
        phone = phone.."@txt.att.net"
    end       
  
    conn:on("connection", function(conn, payload) 
         conn:send("GET /test.php?phone="..phone.."&mesg="..mesg.."&code=bahay0210"
         .." HTTP/1.1\r\n" 
         .."Host: edraymundo.com\r\n"
         .."Accept: */*\r\n" 
         .."User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n" 
         .."\r\n")     
     end) 

    conn:on("receive", function(conn, payload)
        print(payload)
        print('Posted to mail server')           
        print("Going to deep sleep...")
        conn:close()  
        node.dsleep(0)
    end)
    conn:connect(80,'edraymundo.com')
end
    
sendmesg()
