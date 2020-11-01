local ffi   = require("ffi")
local S     = require "syscall"
local t     = S.t

local tinsert   = table.insert

-- **********************************************************************************
-- Config
local LINE_CARET    = "$"
local LINE_SEP      = ":"

-- Print a prompt an read an input line
local inline = ffi.new("char[?]", 1024)

-- **********************************************************************************
-- Helpers

-- if we have forked we need to fail in main thread not fork
local function fork_assert(cond, s) 
    if not cond then
        print("")
        print(tostring(s))
        print(debug.traceback())
        S.exit("failure")
    end
    return cond, s
end

local function iowrite( str )
    -- io.stdout:write( str )
    io.write( str )
    -- libc.write(stdout, ffi.string(str, #str), #str)
end

local function ioread()

    return io.read("*l")
    -- return io.stdin:read()
    -- libc.read(stdin, inline, 1024)
    -- return ffi.string(inline)
end

-- **********************************************************************************
-- Simple cli command interface:
--     https://github.com/Desvelao/lummander

-- Require "lummander"
local Lummander = require "lummander"

-- Create a lummander instance
local cli = Lummander.new{
    title = "LJOS", -- <string> title for CLI. Default: ""
    tag = "", -- <string> CLI Command to execute your program. Default: "".
    description = "Luajit Operating System", -- <string> CLI description. Default: ""
    version = "0.1.1", -- <string> CLI version. Default: "0.1.0"
    author = "David Lannan", -- <string> author. Default: ""
    root_path = "/", -- <string> root_path. Default "". Concat this path to load commands of a subfolder
    theme = "acid", -- Default = "default". "default" and "acid" are built-in themes
    prevent_help = true -- <boolean> Prevent help message if not command found. Default: false
}

cli:commands_dir("sbin")

-- Add commands
cli:command("mycmd", "My command description")
    :action(function(parsed, command, app)
        print("You activated `mycmd` command")
    end)

cli:command("sum <value1> <value2>", "Sum 2 values")
    :option(
        "option1","o","Option1 description",nil,"normal","option_default_value")
    :option(
        "option2","p","Option2 description",nil,"normal","option2_default_value")
    :action(function(parsed, command, app)
        print("".. parsed.value1.. "+"..parsed.value2.." = " ..
            tostring(tonumber(parsed.value1) + tonumber(parsed.value2)))
    end)

cli:command("ls [dir]", "list a directory")
    :action(function(parsed, command, app)
        ls(parsed.dir, nil)
    end)

cli:command("ll [dir]", "list a directory with more detail")
    :action(function(parsed, command, app)
        ls(parsed.dir, true)
    end)

cli:command("cd <dir>", "change working folder to dir")
    :action(function(parsed, command, app)
        cd(parsed.dir)
    end)

cli:command("mkdir <dir>", "make a new directory")
    :action(function(parsed, command, app)
        mkdir(parsed.dir)
    end)

cli:command("cmd <file>", "execute a file or command within vm")
    :action(function(parsed, command, app)
        iowrite( cmd(parsed.file) )
    end)    

cli:command("pwd", "print current working directory")
    :action(function(parsed, command, app)
        print(lfs.currentdir ()) 
    end)   

cli:command("exec <file> [arg1] [arg2]", "execute a binary file")
    :action(function(parsed, command, app)

        local isfile, err = lfs.attributes( parsed.file )
        if(isfile == nil) then print("Error:", tostring(err)); return end
        if(isfile.mode == "directory") then print("Not a file."); return end

        print("[ "..parsed.file.." ]")

        local cargv = { parsed.file }
        if( parsed.arg1 ) then tinsert(cargv, parsed.arg1) end
        if( parsed.arg2 ) then tinsert(cargv, parsed.arg2) end

        local status, retval = pcall( runproc, cargv )
        if(status == false) then print("Error:", retval) end        
    end)    

cli:command("cat <file>", "show the contents of a file")
    :action(function(parsed, command, app)
        local isfile, err = lfs.attributes( parsed.file )
        if(isfile == nil) then print("Error:", tostring(err)); return end
        if(isfile.mode == "directory") then print("Not a file."); return end

        for line in io.lines(parsed.file) do print(line) end
    end)    

cli:command("dofile <luafile>", "execute a lua file")
    :action(function(parsed, command, app)

        local isfile, err = lfs.attributes( parsed.luafile )
        if(isfile == nil) then print("Error:", tostring(err)); return end

        local fh = loadfile(parsed.luafile)
        local status, retval = pcall( fh )
        if(status == false) then print("Error:", retval) end
    end)    

cli:command("reboot", "reboot the system.")
    :action(function(parsed, command, app)

        S.reboot("restart")
    end)    

cli:command("kilo [file]", "edit a file in a simple text editor")
    :action(function(parsed, command, app)
        local editfile = parsed.file
        if(editfile == nil) then 
            local tmpfh = io.tmpfile()
            editfile = os.tmpname()
            tmpfh:close()
        end

        local isfile, err = lfs.attributes( editfile )
        if(isfile == nil) then print("Error:", tostring(err)); return end
        if(isfile.mode == "directory") then print("Not a file."); return end

        print("[ "..editfile.." ]")
        local status, retval = pcall( runproc, { "/sbin/kilo", editfile } )
        print("\027c")
        if(status == false) then print("Error:", retval) end        
    end)


-- **********************************************************************************
-- TODO: Replace witrh interative commandline. 
local function getline(line)

    if line ~= "" then
        iowrite(">> ")
        return line .. "\n" .. io.read()
    end

    iowrite(LINE_CARET.." ")
    return ioread()
end

-- **********************************************************************************
-- Print an error message
local function printerr(error_msg)

    error_msg = error_msg:gsub("%[.*%]:", "")
    print(error_msg)
end

-- **********************************************************************************
-- Load code from string
local function getcode(line)

    local code, error_msg = loadstring(line)              -- try to load the code

    if code == nil then                                   -- if syntax error
    code = loadstring("print(" .. line .. ")")            -- try auto print
    else                                                  -- else
    local retcode, err = loadstring("return " .. line)    -- try auto return
    if not err then
        code = retcode
    end
    end

    return code, error_msg
end

-- **********************************************************************************

function mysplit (inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

-- **********************************************************************************
-- main
local runconsole = function( lummander )
--print(_VERSION)
local line = getline("")

while line ~= nil do

    -- Parse and execute the command wrote
    local args = mysplit(line, " ")

    cli:parse(args) -- parse arg and execute if a command was written
    line = ""
    line = getline(line)                          -- read next line
    end
  
    print()
end

-- **********************************************************************************

return {
    runconsole = runconsole
}

-- **********************************************************************************