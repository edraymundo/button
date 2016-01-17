-- URL decode function
function unescape (s)
   s = string.gsub(s, "+", " ")
   s = string.gsub(s, "%%(%x%x)", function (h)
         return string.char(tonumber(h, 16))
       end)
   return s
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
tmr.alarm(0, 100000, 0, function() 
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

        --if path == "/validate.js" then
         ---   file.open("validate.js", "r" )
          --  local content = file:read "*a"  
           -- conn:send("HTTP/1.1 200 OK\r\nContent-Type: text/javascript \r\n\r\n "..content); 
           -- client:close();  
           -- return
        --end
        
        if path == "/favicon.ico" then
            conn:send("HTTP/1.1 404 file not found")
            return
        end
        if (path == "/" and  vars == nil) then
            buf = buf.."<html><head></head><body style='width:90%;margin-left:auto;margin-right:auto;background-color:LightGray;'>";
            buf = buf.."<h1>CallMeButton Wifi Configuration</h1>"
            buf = buf.."<form action='' method='get'>"
            buf = buf.."<table cellpadding=5 cellspacing=5><tr><td align=left>SSID:</td> "
            buf = buf.."<td><input type='text' id='ssid' name='ssid' value='' maxlength='300' size='30px' placeholder='required' required /></td>"
            buf = buf.."</tr><tr><td align=left>Password:</td> "
            buf = buf.."<td><input type='text' id='password' name='password' value='' maxlength='300' size='30px' placeholder='required' required/></td>"
            buf = buf.."</tr><tr><td align=left>Key Id (ifftt.com):</td> "
            buf = buf.."<td><input type='text' id='keyid' name='keyid' value='' maxlength='300' size='30px' placeholder='required' required/></td>"
            buf = buf.."</tr><tr><td align=left>Event Name (ifttt.com): </td>"
            buf = buf.."<td><input type='text' id='eventname' name='eventname' value='' maxlength='300' size='30px' placeholder='required' required/></td>"
            buf = buf.."</tr><tr><td>&nbsp;</td><td><input type='submit' value='Submit' style='height: 25px; width: 130px;'/></td>"
            buf = buf.."</table></body></html>"    
        elseif (vars ~= nil) then
            restarting = "<html><body style='width:90%;margin-left:auto;margin-right:auto;background-color:LightGray;'><h1>Restarting...You may close this window.</h1></body></html>"
            client:send(restarting);
            client:close();
            if (_GET.ssid) then
            
                --save key id in text file
                file.remove("keyid.txt")
                tmr.delay(1000)
                file.open("keyid.txt", "w")
                file.write(_GET.keyid)
                file.flush()
                file.close()
                
                --save event in text file
                file.remove("eventname.txt")
                tmr.delay(1000)
                file.open("eventname.txt", "w")
                file.write(_GET.eventname)
                file.flush()
                file.close()
                                
                print("Setting to: ".. _GET.ssid)
                tmr.alarm(0, 5000, 1, function()
                wifi.setmode(wifi.STATION);
                wifi.sta.config(_GET.ssid,_GET.password);
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
