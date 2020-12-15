-----------------------------------------------------------------------------------------
local ffi = require("ffi")

local S     = require "syscall"
local nlbase= require "syscall.linux.nl"

local nl    = nlbase.init(S)
-- for k,v in pairs(nl) do print(k,v) end

local IO_OPEN = {
    O_RDONLY    = 0x0000,    -- open for reading only
    O_WRONLY    = 0x0001,    -- open for writing only
    O_RDWR      = 0x0002,    -- open for reading and writing
    O_NONBLOCK  = 0x0004,    -- no delay
    O_APPEND    = 0x0008,    -- set append mode
    O_SHLOCK    = 0x0010,    -- open with shared file lock
    O_EXLOCK    = 0x0020,    -- open with exclusive file lock
    O_ASYNC     = 0x0040,    -- signal pgrp when data ready
    O_NOFOLLOW  = 0x0100,    -- don't follow symlinks
    O_CREAT     = 0x0200,    -- create if nonexistant
    O_TRUNC     = 0x0400,    -- truncate to zero length
    O_EXCL      = 0x0800,    -- error if already exists
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

if(_G.COMMAND_LINE == nil ) then 

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
local t = S.t

try(S.mkdir, "/dev")
try(S.mkdir, "/bin")
try(S.mkdir, "/proc")
try(S.mkdir, "/sys")
try(S.mkdir, "/run")
try(S.mkdir, "/mnt")
try(S.mkdir, "/usr")

try(S.mkdir, "/lib/x86_64-linux-gnu")
try(S.mkdir, "/usr/local")

-- mkdir -p $(INITFS_PATH)/bin $(INITFS_PATH)/dev $(INITFS_PATH)/dev/pts 
-- mkdir -p $(INITFS_PATH)/etc $(INITFS_PATH)/lib
-- mkdir -p $(INITFS_PATH)/mnt $(INITFS_PATH)/proc $(INITFS_PATH)/root 
-- mkdir -p $(INITFS_PATH)/sbin $(INITFS_PATH)/sys $(INITFS_PATH)/usr

-- mounts
try(S.mount, "devtmpfs", "/dev", "devtmpfs", "rw,nosuid")
try(S.mount, "proc", "/proc", "proc", "rw,nosuid,nodev,noexec,relatime")
try(S.mount, "sysfs", "/sys", "sysfs", "rw,nosuid,nodev,noexec,relatime")
try(S.mount, "tmpfs", "/run", "tmpfs", "rw,nosuid,nodev,noexec,relatime")

-- try(S.mount, "devpts", "/dev/pts", "devpts", "rw,nosuid,noexec,relatime")

--- Since kernel 2.6 devtmpfs creates these below.
-- try(S.mknod, "/dev/fb0", "fchr,rwxu", t.device(29, 0))
-- try(S.mknod, "/dev/ttyS0", "fchr,rwxu", t.device(4, 64))
-- try(S.mknod, "/dev/console", "fchr,rwxu", t.device(5, 1))
-- try(S.mknod, "/dev/null", "fchr,rwxu", t.device(1, 3))

-- try(S.mknod, "/dev/random", "fchr,rwxu", t.device(1, 8))
-- try(S.mknod, "/dev/urandom", "fchr,rwxu", t.device(1, 9))

-- Add some uiseful links - this will grow. We are replicating udev here.
lfs.link("/lib", "/lib64", true)
lfs.link("/lib/x86_64-linux-gnu", "/usr/local/lib", true)

lfs.link("/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2", "/lib/ld-linux-x86-64.so.2")

lfs.link("/lib/x86_64-linux-gnu/libc.so.6", "/lib/libc.so.6")
lfs.link("/lib/x86_64-linux-gnu/libm.so.6", "/lib/libm.so.6")
lfs.link("/lib/x86_64-linux-gnu/libpthread.so.0", "/lib/libpthread.so.0")
lfs.link("/lib/x86_64-linux-gnu/libdl.so.2", "/lib/libdl.so.2")
lfs.link("/lib/x86_64-linux-gnu/libgcc_s.so.1", "/lib/libgcc_s.so.1")

--lfs.link("/lib/libuv.so.1.0.0", "/lib/libuv.so")

end -- _G.COMMAND_LINE == nil

-- lfs.chdir("/tmp")
-- local bootgfx = "flags"
-- local ok, err = S.execve( bootgfx, { bootgfx }, { HOME="/opt", PATH="/opt:/bin:/sbin" } )

-- local ok, err = os.execute(bootgfx)
-- if( ok == nil ) then print("Error:", err) end
-- lfs.chdir("..")

-- /* Open framebuffer, mouse, terminal */
fbfd = ffi.C.open("/dev/fb0", IO_OPEN.O_RDWR, 0)
msfd = ffi.C.open("/dev/input/event5", bit.bor(IO_OPEN.O_RDWR , IO_OPEN.O_NONBLOCK), 0)
ttyfd = ffi.C.open("/dev/tty0", IO_OPEN.O_RDWR, 0)



os.execute( "echo $HOME" )
os.execute( "set HOME=/tmp" )
os.execute( "echo $HOME" )

-- **********************************************************************************
