
-- **********************************************************************************
-- Setup pats first

package.cpath = "./lib/?.so;./?.so"
package.path = "./?.lua;./lib/?/init.lua;./ffi/?/init.lua;./lua/?/init.lua;"
package.path = package.path.."./lib/?.lua;./lua/?.lua;./ffi/?.lua"

local ffi = require("ffi")
require("pprint")

-- **********************************************************************************
-- A simple console parser. Will expand
local console = require "console"
local chalk = require "chalk"

-- **********************************************************************************

local tinsert = table.insert 
local tremove = table.remove
local tconcat = table.concat

-- **********************************************************************************
-- LJOS Configs!!
LJOS_VERSION    = "0.1a"
LJOS_WELCOME    = [[ Welcome to LJOS. Version: ]]..LJOS_VERSION
-- This will be per user - each instance ca run its VM with separate configs
-- Later this is how all processes will run.
LJOS_CONF       = {

}


-- **********************************************************************************
-- Luajit initial test

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

-- **********************************************************************************
-- Ok, getting serious now. Various examples of common commands.
--  These will be mapped into the console, NOT the vm. 
--  We want to change the complete operation of the file system - removal of its io 
--  direct control. LJOS will run form a key/value store like leveldb, or redis. 
--  Key benefits: 
--     per use filesystem - making polluting and corrupting other peoples filesystems difficult.
--     system files are NOT in user filesystem. 
--     snapshots and remote use is builtin.
--     high perf caching is available.
--     decouples whole file interface from the user (and devleoper). All io requests 
--        will be rediected.
--     should result in high perf for large file counts. tests show 1B files can be iterated in 
--        seconds. this is a key benefit.
--
--  All of the commands will be moved to modules. FBP modules will be setup. 
--  This is coming soon, dont get comfortable :)


-- **********************************************************************************
-- command for running processes
function cmd( command )
    local fh = io.popen( command, "r" )
    local data = nil

    if( fh ) then 
        data = tostring( fh:read("*a") )
        fh:close()
    else 
        data = "invalid command."
    end 
    if( data == nil ) then data = "" end
    return data 
end 

-- **********************************************************************************
-- Our implementation of ls
function ls(path, detail)

    if(path == nil) then path = "." end
    local fileline = ""

    for file in lfs.dir(path) do

        local line = '-'
        if(detail == nil) then line = "" end 

        local attr = lfs.attributes (path.."/"..file)
        if( (type(attr) == "table") ) then 

            local filecolor = chalk.white(file)
            if attr.mode == "directory" then
                filecolor = chalk.blue(file)
            else 
                if string.find(attr.permissions, "x") then 
                    filecolor = chalk.green(file)
                end
            end

            if(detail) then 
                if attr.mode == "directory" then
                    -- attrdir (f)
                    line = 'd'
                end
                line = line..attr.permissions.." "
                line = line..string.format("% 5d", attr.blocks).." "

                local userid = attr.uid
                if(userid == 0) then line = line.." root:" else 
                    line = line..string.format("% 5d", userid)..":" end 

                local groupid = attr.gid
                if(groupid == 0) then line = line.."root  " else 
                    line = line..string.format("% 5d", groupid).." " end 

                line = line..string.format("% 8d", attr.size).." "

                local changetime = os.date("%m/%d/%Y %I:%M %p", attr.change)
                line = line..changetime.." "
                line = line..filecolor
                print(line)
            else 
                if(#file > 16) then line = string.sub(file, 1, 16) else 
                    line = filecolor..(string.rep( " ", 16-#file )) end
                if(#fileline > 80) then print(fileline); fileline = "" end
                fileline = fileline..line.." "
            end
        end
    end
    if(detail == nil) then print(fileline) end 
end

-- **********************************************************************************
-- Simple change directory
function cd (path) 

    if(path == nil) then path = "." end
    p( cmd( "cd "..path ) )
end

-- **********************************************************************************
-- Simple change directory
function mkdir (path) 

    if(path == nil) then 
        print("mkdir: Path not specified")
        return
    end
    lfs.mkdir(path)
end

-- **********************************************************************************
-- Simple editor from here:
--     https://github.com/philanc/ple
function ple (filepath) 

    if(arg == nil) then arg = {} end 
    if(filepath) then arg[1] = filepath end 
    dofile("./ple/ple.lua")
end 

-- **********************************************************************************
-- while tm < 5 do
-- 	local thistm = math.floor(os.clock())
-- 	if( thistm ~= tm ) then
-- 		print("Hello...", tm)
-- 		tm = thistm
-- 	end
-- end

-- p("Testing Pretty Print.")
-- p(tbl)

-- **********************************************************************************
-- Setup output

-- Clear screen
print("\027c")

-- Logo.. put your own in here.
local logo1 = [[
                        
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

local logo2 = [[
  88           88  ,dBBB888a,  .d88888a.
  88           88  88'    `88  88'   `88
  88           88  88      88  Y8.      
  88           88  88      88  `Y88888a,
  88           88  88      88        `88
  88           88  88      88         88
  88          ,88  Y8.    .8P  Y8.   .88
  8888888  Y88P"   `Y8BBB8YP'  `Y88888P"
  ...............::..........::.........:
  :::::::::::::::::::::::::::::::::::::::
  :::::::::::::::::::::::::::::::::::::::
  ---------------------------------------
]]
local LOGO_LINE = [[  ---------------------------------------
]]

local logo = logo2
local fillcount = #(LOGO_LINE) - #(LJOS_WELCOME) - 5
logo = logo..[[  |]]..LJOS_WELCOME..(string.rep(" ",fillcount)).."|\n"
logo = logo..LOGO_LINE
-- output logo
print(logo)

-- start console.
console.runconsole( {} )

-- **********************************************************************************
-- TODO:
--   Key goals: 
--      - replace filesystem with leveldb or redis
--      - add FBP kernel controller. Launching modules should be simple.
--      - add simple bindings for ctrl+alt+Fx for switching terms. support standard
--      - each term is a module, and FBP controller manages them.
--      - add base networking (if possible with minimal drivers)
--      - add nuklear for UI. 
