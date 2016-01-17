
--init.lua
wifi.setmode(wifi.STATION)
cnt=0

--ipcfg={}
  --  ipcfg.ip="192.168.1.145"
    --ipcfg.netmask="255.255.255.0"
    --ipcfg.gateway="192.168.1.1"
--wifi.ap.setip(ipcfg)

--Go to deep sleep if you can't connect to Wifi
 tmr.alarm(1, 1000, 1, function()
    if wifi.sta.getip()== nil then
       cnt = cnt + 1
       print("(" .. cnt .. ") Waiting for IP...")
       if cnt == 10 then
          tmr.stop(1) 
          dofile("setwifi.lua")  
       end
    end  
 end)  

dofile("ifttt.lua")

