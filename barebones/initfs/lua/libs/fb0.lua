local S = require "syscall"

-- **********************************************************************************
-- Default FB0 dimensions (not realistic)
local PROT_READ       	= 0x1         -- Page can be read.  
local PROT_WRITE        = 0x2         -- Page can be written.  
local PROT_EXEC        	= 0x4         -- Page can be executed. 
local PROT_NONE 		= 0x0         -- Page can not be accessed. 
local PROT_GROWSDOWN 	= 0x01000000  --Extend change to start of growsdown vma (mprotect only). 
local PROT_GROWSUP  	= 0x02000000  -- Extend change to start of growsup vma (mprotect only).

-- Sharing types (must choose one and only one of these).  
local MAP_SHARED        = 0x01               -- Share changes. 
local MAP_PRIVATE       = 0x02               -- Changes are private.  

local FB0 = { w = 1024, h = 1024, fb_name = "/dev/fb0" }

FB0.device  = { fb_fd = nil, fb_data = "", fb_screensize = 0 }
FB0.device.fb_vinfo = ffi.new("fb_var_screeninfo[1]")
FB0.device.fb_finfo = ffi.new("fb_fix_screeninfo[1]")

-- Open the file for reading and writing
FB0.device.fb_fd = S.open(FB0.fb_name, S.O_RDWR)
if (FB0.device.fb_fd == -1) then 
	pp("Error: cannot open framebuffer device")
	os.exit(1)
end

-- Get variable screen information
if (S.ioctl(FB0.device.fb_fd, cr.FBIOGET_VSCREENINFO, FB0.device.fb_vinfo) == -1) then
	pp("Error reading variable information")
	os.exit(3)
end

FB0.w 		= FB0.device.fb_vinfo[0].xres
FB0.h 		= FB0.device.fb_vinfo[0].yres
FB0.bits 	= FB0.device.fb_vinfo[0].bits_per_pixel
FB0.fb_screensize = FB0.w * FB0.h * (FB0.bits / 8)
pp(FB0.w, FB0.h, FB0.bits)

-- Map the device to memory
FB0.fb_data = S.mmap(0, FB0.fb_screensize,
		bit.bor(PROT_READ, PROT_WRITE), MAP_SHARED, FB0.device.fb_fd, 0)

if (FB0.fb_data == -1) then 
	print("Error: failed to map framebuffer device to memory")
	exit(4)
end

-- Get fixed screen information
if (S.ioctl(FB0.device.fb_fd, cr.FBIOGET_FSCREENINFO, FB0.fb_finfo) == -1) then
	print("Error reading fixed information")
	exit(2)
end

return FB0 