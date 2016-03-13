 --init.lua
collectgarbage();

-- load helper module 
require ('helper')
 
cnt=0
-- LEDs
red = 2
green = 1

--setup button
ap_button = 4

function debounce (func)
    local last = 0
    local delay = 300000

    return function (...)
        local now = tmr.now()
        if now - last < delay then return end

        last = now
        return func(...)
    end
end

function onChange ()
    tmr.stop(1) 
    gpio.mode(ap_button,gpio.OUTPUT)
    dofile("setwifi.lua") 
end

gpio.mode(ap_button,gpio.INT)
gpio.mode(green, gpio.OUTPUT)
gpio.mode(red, gpio.OUTPUT)

gpio.write(red,gpio.HIGH)
gpio.write(green,gpio.LOW)

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
if ssid~='' then
    wifi.sta.config(ssid,password);
    wifi.sta.connect()
end

gpio.trig(ap_button, "both", debounce(onChange))

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
        dofile("ifttt.lua")
    end  
 end) 

