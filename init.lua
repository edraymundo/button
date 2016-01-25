 --init.lua

-- load helper module 
require ('helper')
 
cnt=0
-- LEDs
red = 2
green = 1

gpio.mode(green, gpio.OUTPUT)
gpio.mode(red, gpio.OUTPUT)

gpio.write(red,gpio.HIGH)

wifi.setmode(wifi.STATION)
ipcfg={}
ipcfg.ip="192.168.1.145"
ipcfg.netmask="255.255.255.0"
ipcfg.gateway="192.168.1.1"
wifi.ap.setip(ipcfg)    

ssid = helper.get_string("ssid") 
password = helper.get_string("password")

print("ssid:"..ssid)
print("password:"..password)
wifi.sta.config(ssid,password);
wifi.sta.connect()

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
        dofile("ifttt.lua")
    end  
 end)  
