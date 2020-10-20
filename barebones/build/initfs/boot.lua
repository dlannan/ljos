local ffi = require("ffi")
require("pprint")

package.path = package.path..";./lummander/?.lua"

-- Require "lummander"
local console = require "console"

local tm = math.floor(os.clock())

local tbl = {
    stuff   = "Stuff",
    num     = 1.0,
    sub     = {
        d1  = 0xffff,
        d2  = "More stuff.",
        d3  = ffi.new("char[?]", 10),
    },
}

function attrdir (path)
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local f = path..'/'..file
            print ("\t "..f)
            local attr = lfs.attributes (f)
            assert (type(attr) == "table")
            if attr.mode == "directory" then
                attrdir (f)
            else
                for name, value in pairs(attr) do
                    print (name, value)
                end
            end
        end
    end
end

-- while tm < 5 do
-- 	local thistm = math.floor(os.clock())
-- 	if( thistm ~= tm ) then
-- 		print("Hello...", tm)
-- 		tm = thistm
-- 	end
-- end

-- p("Testing Pretty Print.")
-- p(tbl)

--for i=0, 80 do print "" end
print("\027c")

local logo1 = [[
    8         8  8"""88 8""""8 
    8         8  8    8 8      
    8e        8e 8    8 8eeeee 
    88        88 8    8     88 
    88    e   88 8    8 e   88 
    88eee 8eee88 8eeee8 8eee88 
]]

local logo2 = [[
                        
        o       o .oPYo. .oPYo. 
        8       8 8    8 8      
        8       8 8    8 `Yooo. 
        8       8 8    8     `8 
        8       8 8    8      8 
        8oooo oP' `YooP' `YooP' 
        .........::.....::.....:
        ::::::::::::::::::::::::
        ::::::::::::::::::::::::    
]]

local logo3 = [[
        .____         ____.   _____    _________
        |    |       |    |  /     \  /   _____/
        |    |       |    | /   |   \ \_____  \ 
        |    |___/\__|    |/    |    \/        \
        |________\________|\_________/_________/
]]

print(logo2)

print ""
print "         -= LUAJIT OS  V0.1a =-   "

console.runconsole()