require ('helper')

tmr.alarm(3, 200, 1, function()
    if value == gpio.LOW then
        value = gpio.HIGH
    else
        value = gpio.LOW
    end
    gpio.write(2, value)
end)

--setwifi.lua
print("Entering wifi setup..")
wifi.setmode(wifi.SOFTAP)

nodessid = "CallMeButton"
cfg={}
    cfg.ssid=nodessid
  --cfg.password="12345678" --comment to leave open
wifi.ap.config(cfg)

ipcfg={}
    ipcfg.ip="192.168.1.2"
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
        print(request)
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        --get variables from the URL decode them and them place them in _GET array
        local _GET = {}
        if (vars ~= nil) then
            for name, value in string.gfind(vars, "([^&=]+)=([^&=]+)") do
                name = helper.unescape(name)
                value = helper.unescape(value)
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
            buf = buf.."<td><input type='text' id='ssid' name='ssid' value='"..helper.get_string('ssid').."' maxlength='300' size='30px' placeholder='required' required /></td>"
            buf = buf.."</tr><tr><td align=left>Password:</td> "
            buf = buf.."<td><input type='text' id='password' name='password' value='"..helper.get_string('password').."' maxlength='300' size='30px' placeholder='required' required/></td>"
            buf = buf.."</tr><tr><td align=left>Phone:</td>"
            buf = buf.."<td><input type='text' id='phone' name='phone' value='"..helper.get_string('phone').."' maxlength='300' size='30px' placeholder='required' required/></td>"
            buf = buf.."</tr><tr><td align=left>Provider:</td>"
            buf = buf.."<td><input type='text' id='provider' name='provider' value='"..helper.get_string('provider').."' maxlength='300' size='30px' placeholder='required' required/></td>"
            buf = buf.."</tr><tr><td align=left>Mesg: </td>"
            buf = buf.."<td><input type='text' id='mesg' name='mesg' value='"..helper.get_string('mesg').."' maxlength='300' size='30px' placeholder='required' required/></td>"
            buf = buf.."</tr><tr><td>&nbsp;</td><td><input type='submit' value='Submit' style='height: 25px; width: 130px;'/></td>"
            buf = buf.."</table></body></html>"    
        elseif (vars ~= nil) then
            buf = "<html><body><h2>All done! Button is now restarting. You may close this window.</h2></body></html>"           
            --conn:send("HTTP/1.1 200 OK\r\nContent-Type: text/html \r\n\r\n");
            --conn:send(restarting);
            --client:close();  
            if (_GET.ssid) then       
                --save values to text file
                helper.set_value("phone.txt",_GET.phone)
                helper.set_value("mesg.txt",_GET.mesg)
                helper.set_value("ssid.txt",_GET.ssid)
                helper.set_value("password.txt",_GET.password)
                helper.set_value("provider.txt",_GET.provider)
                                                             
                print("Setting SSID: ".. _GET.ssid)
                print("password: ".. _GET.password)
                print("provider: ".. _GET.provider)
                tmr.alarm(4, 7000, 0, function() 
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
