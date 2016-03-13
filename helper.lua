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
 
function escape(s) 
   s = string.gsub(s, " ", "%%20")
   return s
end

function get_string(name)
    str = ''
    if file_exists(name..".txt") then
        file.open(name..".txt", "r" )
        str = file.read()
        if str~=nil then
            str = string.gsub(str, "%s+", " ") 
            str = string.gsub(str, "%%", "%%")     
        end    
        file.close()
        print("Return String "..str)
    end 
    return str
end

function set_value(filename,getvalue)
       print("Set string:"..getvalue)
       file.remove(filename)
       tmr.delay(2000)
       file.open(filename, "w")
       file.write(getvalue)
       file.flush()
       file.close()
end

return M
