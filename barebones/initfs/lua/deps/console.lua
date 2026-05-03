local ffi   = require("ffi")
local S     = require "syscall"
local h     = require "syscall.helpers"
local t     = S.t

local tinsert   = table.insert
local getch     = require("lua-getch")
local get_mbs   = require("lua-getch/get_mbs")

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
    io.stdout:write( str )
    -- io.write( str )
    --libc.write(stdout, ffi.string(str, #str), #str)
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
    root_path = "", -- <string> root_path. Default "". Concat this path to load commands of a subfolder
    theme = "acid", -- Default = "default". "default" and "acid" are built-in themes
    prevent_help = true -- <boolean> Prevent help message if not command found. Default: false
}

cli:commands_dir("lua/deps/commands")

-- Add commands
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

cli:command("strace [arg1] [arg2] [arg3]", "strace a binary file")
    :action(function(parsed, command, app)

        print("[ strace "..(arg1 or "")..", "..(arg2 or "")..", "..(arg3 or "").." ]")

        local cargv = { "/sbin/strace" }
        if( parsed.arg1 ) then tinsert(cargv, parsed.arg1) end
        if( parsed.arg2 ) then tinsert(cargv, parsed.arg2) end
        if( parsed.arg3 ) then tinsert(cargv, parsed.arg3) end

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

cli:command("dofile <luafile> [arg1] [arg2]", "execute a lua file")
    :action(function(parsed, command, app)

        local isfile, err = lfs.attributes( parsed.luafile )
        if(isfile == nil) then print("Error:", tostring(err)); return end
        if(isfile.mode == "directory") then print("Not a file."); return end

        print("[ "..parsed.luafile.." ]")

        local cargv = { "sbin/luajit", parsed.luafile }
        if( parsed.arg1 ) then tinsert(cargv, parsed.arg1) end
        if( parsed.arg2 ) then tinsert(cargv, parsed.arg2) end

        local status, retval = pcall( runproc, cargv )
        if(status == false) then print("Error:", retval) end    
    end)    

cli:command("reboot", "reboot the system.")
    :action(function(parsed, command, app)

        S.reboot("restart")
    end)    

cli:command("ctest", "run the cairo test001.lua - for quick testing")
    :action(function(parsed, command, app)

        local cargv = { "sbin/luajit", "lua/examples/mitree-test.lua" }
        local status, retval = pcall( runproc, cargv )
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
local function w(...)
	-- "graphical" terminal output to stderr
	io.stdout:write(...)
end

-- simple drawing routine using ANSI escape sequences
local function draw()
	-- reset sgr, clear screen, set cursor to 1,1
	w("\027[0m\027[2J\027[;H")
	w("\027[1m", prompt, "\027[0m\n\n")

	-- print menu items
	for k,v in ipairs(menu) do
		if k==menu_i then
			w("\027[31m [ ", tostring(v), " ]\027[0m\n")
		else
			w("   ",tostring(v),"  \n")
		end
	end
end

-- **********************************************************************************
-- Event structure for mouse or keyboard input
-- struct input_event {
--     struct timeval time;
--     unsigned short type;
--     unsigned short code;
--     unsigned int value;
-- };

kybdfd    = S.open("/dev/input/event1", "rdwr,nonblock", "0666")
local input_event = ffi.new("struct input_event[1]")

local key_ascii = {}
for name, code in pairs( S.c.KEY ) do key_ascii[code] = name end

local function read_event()

    local last_read = S.read(kybdfd, input_event, ffi.sizeof("struct input_event"))

    return last_read
end

-- **********************************************************************************

local function delete_char(line)
    if( #line > 0 ) then 
        line = string.sub(line, 1, -2) 
        w("\027[2K\r")
        w(line)
    end
    return line
end

local function clear_line()
    w("\027[2K\r")
end

-- **********************************************************************************
-- main
local runconsole = function( lummander )
    -- print(_VERSION)
    --w("\027[?1049h") -- Enable alternative screen buffer
    w("\027[?25h")

    local line = ""
    iowrite("$ ")
    io.stdout:flush()

    local chout = ffi.new("int[1]")

    local history = {}
    local history_select = 0

    -- /* Select on fds */
    local rfds = ffi.new("fd_set[1]")
    getch.fdzero(rfds)
    getch.fdset(h.getfd(kybdfd), rfds)

    local mod_shift   = false

    -- infinite loop for command line..
    while true do

        if(processes.active == nil) then 
  
--        local ch =  getch.getch_blocking()
            -- getch.getch_non_blocking(chout)
            -- local ch = tonumber(chout[0])
            local ch = ""

            local valid = read_event()
            if(valid) then 

                local key_pressed = true
                local key_released = false

                if(input_event[0].type == 01) then 
                    ch = key_ascii[input_event[0].code]
                end

                if(input_event[0].value == 0) then 
                    key_pressed = false
                    key_released = true
                end

                -- if(ch > 0) then print(ch, tonumber(ch)) end

                -- TODO: convert this into an index meta table. Will make handling special
                --       keys like delete, tab and others more simple.
                if( ch == "LEFTSHIFT" or ch == "RIGHTSHIFT") then 
                    if(key_pressed == true) then 
                        mod_shift = true 
                    else 
                        mod_shift = false 
                    end
                end 

                if( key_released == true ) then 
                    if( ch == "ENTER" ) then 
                        -- Parse and execute the command wrote
                        if(#line > 0) then 
                            local args = mysplit(line, " ")
                            cli:parse(args) -- parse arg and execute if a command was written
                            -- Store history
                            tinsert(history, 1, line)
                        end
                        line = ""
                        iowrite("$ ")
                        io.stdout:flush()

                    -- Arrow key pressed
                    elseif( ch == "UP" ) then
                        if(history_select < #history) then 
                            history_select = history_select + 1
                            line = history[history_select]
                            clear_line()
                            iowrite(line)
                        end
                    elseif( ch == "DOWN" ) then 

                    -- Backspace
                    elseif (ch == "BACKSPACE" ) then 
                        line = delete_char(line)

                    -- Delete
                    elseif( ch == "DELETE" ) then 
                        line = delete_char(line)

                    -- Printable chars
                    elseif( #ch == 1 ) then
                        if(mod_shift == false) then ch = string.lower(ch) end
                        line = line..ch
                        -- iowrite(string.char(ch))
                    end
                end
            end
        end 

        libc.usleep(30000)
    end

    --w("\027[?1049l") -- Disable alternative screen buffer
end 

-- **********************************************************************************

return {
    runconsole = runconsole
}

-- **********************************************************************************