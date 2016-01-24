 --init.lua
wifi.setmode(wifi.STATION)
cnt=0

-- LED
red = 2
green = 1

gpio.mode(green, gpio.OUTPUT)
gpio.mode(red, gpio.OUTPUT)

gpio.write(green,gpio.LOW)
gpio.write(red,gpio.HIGH)

ipcfg={}
ipcfg.ip="192.168.1.145"
ipcfg.netmask="255.255.255.0"
ipcfg.gateway="192.168.1.1"
wifi.ap.setip(ipcfg)    
wifi.setmode(wifi.STATION);

--Go to deep sleep if you can't connect to Wifi
 tmr.alarm(1, 1000, 1, function()
    if wifi.sta.getip()== nil then
       cnt = cnt + 1
       print("(" .. cnt .. ") Waiting for IP...")
       if cnt == 10 then
          tmr.stop(1) 
          dofile("setwifi.lua")  
       end
    else
        print("Got IP:"..wifi.sta.getip())
        gpio.write(red,gpio.LOW)
        tmr.stop(1)
        tmr.stop(2)
    end  
 end)  

dofile("ifttt.lua")
