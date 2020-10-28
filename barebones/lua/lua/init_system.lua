-----------------------------------------------------------------------------------------
local ffi = require("ffi")

local S     = require "syscall"
local nlbase= require "syscall.linux.nl"

local nl    = nlbase.init(S)
-- for k,v in pairs(nl) do print(k,v) end


local IO_OPEN = {
    O_RDONLY    = 0,
    O_WRONLY    = 1,
    O_RDWR      = 2,
}

local function fatal(s)
  print(s)
  os.exit()
end

function try(f, ...)
  local ok, err = f(...) -- could use pcall
  if ok then return ok end
  --print("init: ", err or "")
  -- p(debug.getinfo(2, "l"))
end

if not S then fatal("cannot find syscall library") end

-- **********************************************************************************
-- This is the preferred way to setup linux dev.

-- -- According to here: https://stackoverflow.com/questions/35245247/writing-my-own-init-executable
-- --   its important to setup stdin, stdout, stderr - I think this is BS tho.
-- local onefd = ffi.C.open("/dev/console", IO_OPEN.O_RDONLY, 0)
-- stdin = ffi.C.dup2(onefd, 0) -- stdin
-- local twofd = ffi.C.open("/dev/console", IO_OPEN.O_RDWR, 0)
-- stdout = ffi.C.dup2(twofd, 1) -- stdout
-- stderr = ffi.C.dup2(twofd, 2) -- stderr

-- os.execute("dir /dev 755 0 0")
-- os.execute("nod /dev/console 644 0 0 c 5 1")
-- os.execute("nod /dev/loop0 644 0 0 b 7 0")
-- os.execute("dir /bin 755 1000 1000")
-- os.execute("dir /proc 755 0 0")
-- os.execute("dir /sys 755 0 0")
-- os.execute("dir /mnt 755 0 0")

-- os.execute("mknod dev/fb0 c 29 0")
-- os.execute("mknod dev/ttyS0 c 4 64")
-- os.execute("mknod -m 600 dev/console c 5 1")
-- os.execute("mknod -m 666 dev/null c 1 3")
-- os.execute("mknod dev/tty c 5 0")
-- os.execute("mknod dev/random c 1 8")
-- os.execute("mknod dev/urandom c 1 9")
-- os.execute("chown root:tty dev/{console,tty}")

-- mounts
try(S.mount, "devtmpfs", "/dev", "devtmpfs", "rw,nosuid,nodev,noexec,relatime")
try(S.mount, "sysfs", "/sys", "sysfs", "rw,nosuid,nodev,noexec,relatime")
try(S.mount, "proc", "/proc", "proc", "rw,nosuid,nodev,noexec,relatime")
try(S.mount, "devpts", "/dev/pts", "devpts", "rw,nosuid,noexec,relatime")

-- interfaces

local i = nl.interfaces()
local lo, eth0 = i.lo, i.eth0

lo:up()
eth0:up()
--eth0:address("192.168.4.130/24")

-- hostname

S.sethostname("lua")

-- print something
local i = nl.interfaces()
print(i)

-- run processes


-- reap zombies

local w, err = S.waitpid(-1, "all")
-- if not w and err.ECHILD then break end -- no more children
pp(w)

-- childless

print("last child exited")

