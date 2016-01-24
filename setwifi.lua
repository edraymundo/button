
tmr.alarm(3, 200, 1, function()
    if value == gpio.LOW then
        value = gpio.HIGH
    else
        value = gpio.LOW
    end

    gpio.write(2, value)
end)


-- URL decode function
function unescape (s)
   s = string.gsub(s, "+", " ")
   s = string.gsub(s, "%%(%x%x)", function (h)
         return string.char(tonumber(h, 16))
       end)
   return s
end

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
        print("Return String "..str)
    end 
    return str
end

--setwifi.lua
print("Entering wifi setup..")
wifi.setmode(wifi.SOFTAP)

nodessid = "CallMeButton"
cfg={}
    cfg.ssid=nodessid
  --cfg.password="12345678" --comment to leave open
wifi.ap.config(cfg)

ipcfg={}
    ipcfg.ip="192.168.1.1"
    ipcfg.netmask="255.255.255.0"
    ipcfg.gateway="192.168.1.1"
wifi.ap.setip(ipcfg)

--create server instance
srv=net.createServer(net.TCP,30)
tmr.alarm(0, 200000, 0, function() 
       print("Going to deep sleep1...")
       node.dsleep(0)
end) 
srv:listen(80,function(conn)
 
    conn:on("receive", function(client,request)
        local buf = "";
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        --get variables from the URL decode them and them place them in _GET array
        local _GET = {}
        if (vars ~= nil) then
            for name, value in string.gfind(vars, "([^&=]+)=([^&=]+)") do
              name = unescape(name)
              value = unescape(value)
              _GET[name] = value
              print(name)
              print(value)
            end

        end
        
        if path == "/favicon.ico" then
            conn:send("HTTP/1.1 404 file not found")
            return
        end
        if (path == "/" and  vars == nil) then
            buf = buf.."<html><head></head><body>";
            buf = buf.."<h1>CallMeButton Wifi Configuration</h1>"
            buf = buf.."<form action='' method='get'>"
            buf = buf.."<table cellpadding=5 cellspacing=5><tr><td align=left>SSID:</td> "
            buf = buf.."<td><input type='text' id='ssid' name='ssid' value='"..get_string('ssid').."' maxlength='300' size='30px' placeholder='required' required /></td>"
            buf = buf.."</tr><tr><td align=left>Password:</td> "
            buf = buf.."<td><input type='text' id='password' name='password' value='"..get_string('password').."' maxlength='300' size='30px' placeholder='required' required/></td>"
            buf = buf.."</tr><tr><td align=left>Key Id (ifftt.com):</td> "
            buf = buf.."<td><input type='text' id='keyid' name='keyid' value='"..get_string('keyid').."' maxlength='300' size='30px' placeholder='required' required/></td>"
            buf = buf.."</tr><tr><td align=left>Event Name (ifttt.com): </td>"
            buf = buf.."<td><input type='text' id='eventname' name='eventname' value='"..get_string('eventname').."' maxlength='300' size='30px' placeholder='required' required/></td>"
            buf = buf.."</tr><tr><td>&nbsp;</td><td><input type='submit' value='Submit' style='height: 25px; width: 130px;'/></td>"
            buf = buf.."</table></body></html>"    
        elseif (vars ~= nil) then
            restarting = "<html><body><h2>Button is now restarting. You may close this window.</h2></body></html>"
            client:send(restarting);
            client:close(); 
            if (_GET.ssid) then       
                --save key id in text file
                file.remove("keyid.txt")
                tmr.delay(2000)
                file.open("keyid.txt", "w")
                file.write(_GET.keyid)
                file.flush()
                file.close()
                
                --save event in text file
                file.remove("eventname.txt")
                tmr.delay(2000)
                file.open("eventname.txt", "w")
                file.write(_GET.eventname)
                file.flush()
                file.close()

                --save ssid in text file
                file.remove("ssid.txt")
                tmr.delay(2000)
                file.open("ssid.txt", "w")
                file.write(_GET.ssid)
                file.flush()
                file.close()
                
                --save password in text file
                file.remove("password.txt")
                tmr.delay(1000)
                file.open("password.txt", "w")
                file.write(_GET.password)
                file.flush()
                file.close()                
                                
                print("Setting SSID: ".. _GET.ssid)
                print("password: ".. _GET.password)
                tmr.alarm(4, 5000, 0, function()
                    print("setting wifi")
                    ipcfg={}
                    ipcfg.ip="192.168.1.145"
                    ipcfg.netmask="255.255.255.0"
                    ipcfg.gateway="192.168.1.1"
                    wifi.ap.setip(ipcfg)    
                    wifi.setmode(wifi.STATION);
                    wifi.sta.config(_GET.ssid,_GET.password);
                    print("restarting..")
                    node.restart()
                end)
            end
        end
        client:send(buf);
        client:close();
        collectgarbage(); 
        tmr.alarm(0, 100000, 0, function() 
              print("Going to deep sleep2...")
              node.dsleep(0)   
        end)               
    end)
    
end)
