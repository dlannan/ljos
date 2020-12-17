
-- **********************************************************************************
-- Setup paths first - needs to go in a common/env file.

_G.COMMAND_LINE = nil

local ENV_PATH  = "/"
if( _G.COMMAND_LINE ) then 
    ENV_PATH = "./"
end 

package.cpath = ENV_PATH.."lib/?.so;"..ENV_PATH.."lib64/?.so;/?.so;"
package.cpath = package.cpath..ENV_PATH.."lua/libs/shared/?.so"

package.path = ENV_PATH.."?.lua;"..ENV_PATH.."lua/?.lua;"..ENV_PATH.."lib/?.so"
package.path = package.path..";"..ENV_PATH.."lua/ffi/?.lua"
package.path = package.path..";"..ENV_PATH.."lua/libs/?.lua"
package.path = package.path..";"..ENV_PATH.."lua/deps/?.lua"
package.path = package.path..";"..ENV_PATH.."lua/libs/?/init.lua"
package.path = package.path..";"..ENV_PATH.."lua/ffi/?/init.lua;"
package.path = package.path..";"..ENV_PATH.."lua/?/init.lua"

-- print("PATH: ", package.path)

local ffi = require("ffi")
pp = require("pprint").prettyPrint

-- **********************************************************************************

ffi.cdef[[

void sleep( unsigned int sec );
int usleep(unsigned int usec);

int dup2(int oldfd, int newfd);
int open(const char *pathname, int flags, int mode);

int read(int fd, void *buf, unsigned int count);
int write(int fd, const void *buf, unsigned int count);
int lseek(int filein, long int offset, int whence);

int execvp(const char *file, char *const argv[]);

int epoll_create(int size);
int epoll_ctl(int epfd, int op, int fd, struct epoll_event *event);
int epoll_wait(int epfd, struct epoll_event *events, int maxevents, int timeout);

/*
long syscall(long number, ...);
dev_t makedev(int major, int minor);
int mknod(const char *path, mode_t mode, dev_t dev);
*/
]]

-- If running on real machine, becareful!!!
if(_G.COMMAND_LINE ) then 
libld   = ffi.load("/usr/lib64/ld-linux-x86-64.so.2", true)
libc    = ffi.load("/lib/x86_64-linux-gnu/libc.so.6", true)
else
libld   = ffi.load("/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2", true)
libc    = ffi.load("/lib/x86_64-linux-gnu/libc.so.6", true)
end

-- **********************************************************************************
-- This is necessary to setup main lua state properly.
dofile("lua/deps/init_system.lua")
dofile("lua/deps/init_commands.lua")
dofile("lua/deps/init_interfaces.lua")

-- **********************************************************************************
-- LJOS Configs!!
-- This will be per user - each instance ca run its VM with separate configs
-- Later this is how all processes will run.
LJOS_CONF       = {
    display_logo    = true,
    version_major   = 0,
    version_minor   = 1,
    version_id      = 1,
}

LJOS_VERSION    = LJOS_CONF.version_major.."."..LJOS_CONF.version_minor.."."..LJOS_CONF.version_id
LJOS_WELCOME    = [[ Welcome to LJOS. Version: ]]..LJOS_VERSION

local console = require "console"

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

-- local cargv = { "sbin/luajit", "lua/logo.lua" }
-- local status, retval = pcall( runproc, cargv )
-- if(status == false) then print("Error:", retval) end   

-- libc.sleep(10)

-- start the logger
-- os.execute("/sbin/syslogd -T -f /etc/syslog.conf")

if( LJOS_CONF.display_logo ) then
-- Clear screen
--print("\027c")

-- Logo.. put your own in here.
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
  ---------------------------------------
]]
local LOGO_LINE = [[  ---------------------------------------
]]

local logo = logo2
local fillcount = #(LOGO_LINE) - #(LJOS_WELCOME) - 5
logo = logo..[[  |]]..LJOS_WELCOME..(string.rep(" ",fillcount)).."|\n"
logo = logo..LOGO_LINE
-- output logo
-- print(logo)
if( _G.COMMAND_LINE ) then print( "WARNING: Running on local machine." ) end

end 

-- local cargv = { "sbin/shell" }
-- local status, retval = pcall( runproc, cargv )

-- os.execute( "sbin/ifconfig" )
-- dofile("lua/examples/httpserver.lua")
dofile("lua/examples/demo_mouse.lua")

console.runconsole()