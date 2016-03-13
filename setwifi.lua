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

local httpRequest={}
httpRequest["/"]="index.html";
httpRequest["/index.html"]="index.html";
httpRequest["/about.html"]="about.html";
httpRequest["/submitted.html"]="submitted.html";
httpRequest["/style.css"]="style.css";

local getContentType={};
getContentType["/"]="text/html";
getContentType["/index.html"]="text/html";
getContentType["/about.html"]="text/html";
getContentType["/submitted.html"]="text/html";
getContentType["/style.css"]="text/css";

local filePos=0;

function unescape(str)
  str = string.gsub (str, "+", " ")
  str = string.gsub (str, "%%(%x%x)", function(h)
      return string.char(tonumber(h, 16)) end)
  str = string.gsub (str, "\r\n", "\n")
  return str
end

--create server instance
srv=net.createServer(net.TCP,30)
tmr.alarm(0, 200000, 0, function() 
       print("Going to deep sleep1...")
       node.dsleep(0)
end) 
srv:listen(80,function(conn)
    conn:on("receive", function(client,request)
        print(request)       
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
            --buf = "<html><body><h2>All done! Button is now restarting. You may close this window.</h2></body></html>" 
        if (_GET.ssid) then       
                --save values to text file
            helper.set_value("phone.txt",_GET.phone)
            helper.set_value("mesg.txt",_GET.mesg)
            helper.set_value("ssid.txt",_GET.ssid)
            helper.set_value("password.txt",_GET.password)
            helper.set_value("provider.txt",_GET.provider)

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
            
         if getContentType[path] then
                requestFile=httpRequest[path];
                print("[Sending file "..requestFile.."]");            
                filePos=0;
                conn:send("HTTP/1.1 200 OK\r\nContent-Type: "..getContentType[path].."\r\n\r\n");  
         else
                print("[File "..path.." not found]");
                conn:send("HTTP/1.1 404 Not Found\r\n\r\n")
                conn:close();
                collectgarbage();
         end            
    end)
        conn:on("sent",function(conn)        
            if requestFile then
                if file.open(requestFile,r) then
                    file.seek("set",filePos);
                    local temp="";
                    local partial_data=file.read(512);
                    temp = partial_data;
                                        
                    file.close();
                    if partial_data then
                        filePos=filePos+#partial_data;
                        print("["..filePos.." bytes sent]"); 
                       if (filePos > 4000) then
                                temp = string.gsub(temp,"ssid:''","ssid:'"..helper.get_string('ssid').."'",1)         
                                temp = string.gsub(temp,"password:''","password:'"..helper.get_string('password').."'",1)     
                                temp = string.gsub(temp,"phone:''","phone:'"..helper.get_string('phone').."'",1)
                                temp = string.gsub(temp,"provider:''","provider:'"..helper.get_string('provider').."'",1)
                                temp = string.gsub(temp,"mesg:''","mesg:'"..helper.get_string('mesg').."'",1)
                        end                           
                        conn:send(temp);
                        if (string.len(partial_data)==512) then
                            return;
                        end
                        --partial_date ="";
                    end
                else
                    print("[Error opening file"..requestFile.."]");
                end
            end        
            conn:close();
            collectgarbage(); 
            tmr.alarm(0, 100000, 0, function() 
                  print("Going to deep sleep2...")
                  node.dsleep(0)   
            end)               
       end)
end)   
