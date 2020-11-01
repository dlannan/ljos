
-- **********************************************************************************
-- A simple console parser. Will expand

local ffi   = require("ffi")
local S     = require "syscall"
local t     = S.t

local chalk = require "chalk"

-- **********************************************************************************

local tinsert = table.insert 
local tremove = table.remove
local tconcat = table.concat

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

    print("Command: ", command)
    local fh = io.popen( command, "r" )
    local data = nil

    if( fh ~= nil ) then 
        data = tostring( fh:read("*a") )
        fh:close()
        print(data)
    else 
        data = "invalid command."
    end 
    if( data == nil ) then data = "" end
    return data 
end 

-- **********************************************************************************

function runproc( pargs ) 

    local pid0 = S.getpid()
    pid = S.fork()
    if(pid == 0) then 
        S.execve( pargs[1], pargs, { } )
    else 
        S.wait()
    end
end


-- **********************************************************************************
-- Our implementation of ls

local function lsentry(path, detail, file, fileline)

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
    return fileline
end

function ls(path, detail)

    if(path == nil) then path = lfs.currentdir() end
    local fileline = ""

    local isfile, err = lfs.attributes( path )
    if(isfile == nil) then print("Error:", tostring(err)); return end

    if(isfile.mode == "directory") then
        for file in lfs.dir(path) do

            fileline = lsentry( path, detail, file, fileline)
        end
    else 
        fileline = lsentry( "", detail, path, fileline)
    end 

    if(detail == nil) then print(fileline) end 
end

-- **********************************************************************************
-- Simple change directory
function cd (path) 

    if(path == nil) then path = lfs.currentdir() end
    local fileline = ""

    local isfile = lfs.attributes( path )
    if(isfile == nil) then return end 

    local ok, err = lfs.chdir(path)
    if(ok == nil) then print(tostring(err)) end
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
