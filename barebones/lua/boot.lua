
-- **********************************************************************************
-- Setup pats first

package.cpath = "./lib/?.so;./lib64/?.so;./?.so"
package.path = "./lua/?.lua;./lib/?/init.lua;./lib64/?/init.lua;./ffi/?/init.lua;./lua/?/init.lua"
package.path = package.path..";./lib/?.lua;./lib64/?.lua;./lua/?.lua;./ffi/?.lua"

local ffi = require("ffi")

pp = require("pprint").prettyPrint

-- **********************************************************************************

ffi.cdef[[

void sleep( unsigned int sec );

int dup2(int oldfd, int newfd);
int open(const char *pathname, int flags, int mode);

unsigned int read(int fd, void *buf, unsigned int count);
unsigned int write(int fd, const void *buf, unsigned int count);

int execvp(const char *file, char *const argv[]);

/*
long syscall(long number, ...);
dev_t makedev(int major, int minor);
int mknod(const char *path, mode_t mode, dev_t dev);
*/
]]

-- If running on real machine, becareful!!!
local attr = lfs.attributes ("/home")
if(attr) then _G.REAL_MACHINE = true end 

if(_G.REAL_MACHINE ) then 
libld   = ffi.load("/usr/lib64/ld-linux-x86-64.so.2", true)
libc    = ffi.load("/lib/x86_64-linux-gnu/libc.so.6", true)
else
libld   = ffi.load("/lib/ld-linux-x86-64.so.2", true)
libc    = ffi.load("/lib/libc.so.6", true)
end

require("init_system")
require("init_commands")

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

-- start the logger
os.execute("./sbin/syslogd -T -f /etc/syslog.conf")

if( LJOS_CONF.display_logo ) then
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
if( _G.REAL_MACHINE ) then print( "WARNING: Running on local machine." ) end

end 

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
