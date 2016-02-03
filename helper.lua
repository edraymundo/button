local modname = ...
local M = {}
_G[modname] = M

local table = table
local string = string
local file = file
local print = print
local tmr = tmr

setfenv(1,M)

function file_exists(name)
   fileresult=file.open(name,"r")
   if fileresult~=nil then file.close(fileresult) return true else return false end
end

function unescape (s)
   s = string.gsub(s, "+", " ")
   s = string.gsub(s, "%%(%x%x)", function (h)
         return string.char(tonumber(h, 16))
       end)
   return s
end

function get_string(name)
    str = 'test123456'
    if file_exists(name..".txt") then
        file.open(name..".txt", "r" )
        str = file.read()
        str = string.gsub(str, "%s+", "")
        file.close()
        print("Return String "..str)
    end 
    return str
end

function set_value(filename,getvalue)
       file.remove(filename)
       tmr.delay(2000)
       file.open(filename, "w")
       file.write(getvalue)
       file.flush()
       file.close()
end

return M
