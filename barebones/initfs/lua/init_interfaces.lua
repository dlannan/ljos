
-----------------------------------------------------------------------------------------
local ffi = require("ffi")

local S     = require "syscall"
local nlbase= require "syscall.linux.nl"

local nl    = nlbase.init(S)

-- **** UNDER TEST ****
-- interfaces
local ifaces    = {}
local i         = nl.interfaces()
pp(i)

for k,v in pairs(i) do

    if(type(k) == "string") then 
        ifaces[k] = v
    end 
end 
pp("Interfaces:")
pp(ifaces)

-- Bring up the interfaces 
for k,v in pairs(ifaces) do 
    v:up()
end 

ifaces.eth0:address("192.168.4.130/24")

-- -- hostname
-- S.sethostname("lua")

-- -- print something
-- local i = nl.interfaces()
-- print(i)

-- -- run processes

-- -- reap zombies
-- local w, err = S.waitpid(-1, "all")
-- -- if not w and err.ECHILD then break end -- no more children
-- pp(w)

-- -- childless
-- print("last child exited")
