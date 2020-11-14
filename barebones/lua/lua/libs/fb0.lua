local ffi 	= require("ffi")
local S 	= require "syscall"

ffi.cdef[[
						
	typedef struct _fb_bitfield {
		unsigned int offset;			
		unsigned int length;
		unsigned int msb_right;
	  } fb_bitfield;

	  typedef struct _fb_fix_screeninfo {
		char id[16];	
		unsigned long smem_start;
		unsigned int smem_len;
		unsigned int type;	
		unsigned int type_aux;
		unsigned int visual;
		unsigned short xpanstep;
		unsigned short ypanstep;
		unsigned short ywrapstep;
		unsigned int line_length;
		unsigned long mmio_start;
		unsigned int mmio_len;
		unsigned int accel;	
		unsigned short capabilities;
		unsigned short reserved[2];	
	  } fb_fix_screeninfo;

	  typedef struct _fb_var_screeninfo {
		unsigned int xres;
		unsigned int yres;
		unsigned int xres_virtual;
		unsigned int yres_virtual;
		unsigned int xoffset;
		unsigned int yoffset;
	
		unsigned int bits_per_pixel;
		unsigned int grayscale;
		fb_bitfield red;
		fb_bitfield green;
		fb_bitfield blue;
		fb_bitfield transp;
	
		unsigned int nonstd;
	
		unsigned int activate;
	
		unsigned int height;
		unsigned int width;	
	
		unsigned int accel_flags;	
	
		unsigned int pixclock;
		unsigned int left_margin;
		unsigned int right_margin;
		unsigned int upper_margin;
		unsigned int lower_margin;
		unsigned int hsync_len;
		unsigned int vsync_len;
		unsigned int sync;
		unsigned int vmode;
		unsigned int rotate;
		unsigned int colorspace;
		unsigned int reserved[4];
	} fb_var_screeninfo;

	typedef enum _fbioctl {
		FBIOGET_VSCREENINFO	= 0x4600,
		FBIOPUT_VSCREENINFO	= 0x4601,
		FBIOGET_FSCREENINFO	= 0x4602,
		FBIOGETCMAP			= 0x4604,
		FBIOPUTCMAP			= 0x4605,
		FBIOPAN_DISPLAY		= 0x4606
	} fbioctl;	
]]

-- **********************************************************************************
-- Default FB0 dimensions (not realistic)
local PROT_READ       	= 0x1         -- Page can be read.  
local PROT_WRITE        = 0x2         -- Page can be written.  
local PROT_EXEC        	= 0x4         -- Page can be executed. 
local PROT_NONE 		= 0x0         -- Page can not be accessed. 
local PROT_GROWSDOWN 	= 0x01000000  -- Extend change to start of growsdown vma (mprotect only). 
local PROT_GROWSUP  	= 0x02000000  -- Extend change to start of growsup vma (mprotect only).

-- Sharing types (must choose one and only one of these).  
local MAP_SHARED        = 0x01               -- Share changes. 
local MAP_PRIVATE       = 0x02               -- Changes are private.  

local FB0 = { w = 1024, h = 1024, fb_name = "/dev/fb0", fb_data = nil, fb_screensize = 0 }

local pp 	= require("lua/libs/pprint").prettyPrint

FB0.init = function(self)
	self.device  = { }
	self.device.fb_fd 		= nil
	self.device.fb_vinfo 	= ffi.new("fb_var_screeninfo[1]")
	self.device.fb_finfo 	= ffi.new("fb_fix_screeninfo[1]")

	-- Open the file for reading and writing
	self.device.fb_fd = S.open(self.fb_name, "RDWR")
	if (self.device.fb_fd == -1) then 
		pp("Error: cannot open framebuffer device")
		os.exit(1)
	end

	-- Get variable screen information
	if (S.ioctl(self.device.fb_fd, ffi.C.FBIOGET_VSCREENINFO, self.device.fb_vinfo) == -1) then
		pp("Error: reading variable information")
		os.exit(3)
	end

	self.w 		= self.device.fb_vinfo[0].xres
	self.h 		= self.device.fb_vinfo[0].yres
	self.bits 	= self.device.fb_vinfo[0].bits_per_pixel
	self.fb_screensize = self.w * self.h * (self.bits / 8)
	pp("Framebuffer Info: ", self.w, self.h, self.bits)

	-- Map the device to memory
	local mapaddr = S.mmap(nil, self.fb_screensize, "READ, WRITE", "SHARED", self.device.fb_fd, 0)
	self.fb_data = ffi.cast("char *", mapaddr)

	-- local ch = ffi.new("char")
	-- for i = 0, self.w * 100 do 
	-- 	ch = math.floor(math.random() * 255.0)
	-- 	self.fb_data[i] = ch 
	-- end

	if (self.fb_data == -1) then 
		pp("Error: failed to map framebuffer device to memory")
		exit(4)
	end

	-- Get fixed screen information
	if (S.ioctl(self.device.fb_fd, ffi.C.FBIOGET_FSCREENINFO, self.fb_finfo) == -1) then
		pp("Error: reading fixed information")
		exit(2)
	end
end

FB0.close = function(self)
	S.munmap (self.fb_data , self.fb_screensize)
	S.close (self.device.fb_fd )
end

return FB0 