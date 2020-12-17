package.path = package.path..";./ljsys/?.lua;./ljsys/syscall/?.lua"

local ffi   = require("ffi")
local lpng  = require("libpng")
local S     = require("syscall")
local h     = require "syscall.helpers"

local getch = require("lua-getch")

-- Need to put this in common.
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

local EV_REL    = 0x02
local REL_X     = 0x00
local REL_Y     = 0x01
local REL_Z     = 0x02
local REL_RX    = 0x03
local REL_RY    = 0x04
local REL_RZ    = 0x05
local REL_HWHEEL = 0x06
local REL_DIAL  = 0x07
local REL_WHEEL = 0x08
local REL_MISC  = 0x09
local REL_MAX   = 0x0f


local screenwidth = 1440
local screenheight = 900

mouse_x = screenwidth / 2
mouse_y = screenheight / 2

framebuffer = nil
wallpaper   = nil

local function copy_png_to_screen( png_buffer, width, offx, offy )

    local wpptr = wallpaper
    local pptr = png_buffer + offx * 4 + offy * width * 4
    for y = 0, screenheight-1 do 
        ffi.copy(wpptr, pptr, screenwidth * 4)
        wpptr = wpptr + screenwidth * 4 
        pptr = pptr + width * 4
    end
end

-- // return the image
local function load() 

    local png = lpng.png_create_read_struct("1.6.36", nil, nil, nil)
    -- //if(!png) abort();
    local info = lpng.png_create_info_struct(png)
    -- //if(!info) abort();

    -- //if(setjmp(png_jmpbuf(png))) abort();

    local filename = "/usr/local/images/wallpapers/wallpaper0001.png"
    local fp = io.open(filename, "rb")
    lpng.png_init_io(png, fp)
    lpng.png_read_info(png, info)

    local width      = lpng.png_get_image_width(png, info)
    local height     = lpng.png_get_image_height(png, info)
    local color_type = lpng.png_get_color_type(png, info)
    local bit_depth  = lpng.png_get_bit_depth(png, info)

    local outdata = string.format("bit_depth = %d\ncolor: %d\nwidth %d\nheight %d\n", bit_depth, color_type, width, height)
    print(outdata)
    local png_buffer = ffi.new("char[?]", width * height * 4)

    -- // Read any color_type into 8bit depth, RGBA format.
    -- // See http://www.libpng.org/pub/png/libpng-manual.txt

    if(bit_depth == 16) then lpng.png_set_strip_16(png) end
    if(color_type == lpng.PNG_COLOR_TYPE_PALETTE) then lpng.png_set_palette_to_rgb(png) end 

    -- // PNG_COLOR_TYPE_GRAY_ALPHA is always 8 or 16bit depth.
    if(color_type == lpng.PNG_COLOR_TYPE_GRAY and bit_depth < 8) then lpng.png_set_expand_gray_1_2_4_to_8(png) end

    if(lpng.png_get_valid(png, info, lpng.PNG_INFO_tRNS)) then lpng.png_set_tRNS_to_alpha(png) end 

    -- // These color_type don't have an alpha channel then fill it with 0xff.
    if(color_type == lpng.PNG_COLOR_TYPE_RGB or
        color_type == lpng.PNG_COLOR_TYPE_GRAY or
        color_type == lpng.PNG_COLOR_TYPE_PALETTE) then
        lpng.png_set_filler(png, 0xFF, lpng.PNG_FILLER_AFTER)
    end

    if(color_type == lpng.PNG_COLOR_TYPE_GRAY or
        color_type == lpng.PNG_COLOR_TYPE_GRAY_ALPHA) then 
        lpng.png_set_gray_to_rgb(png)
    end

    lpng.png_read_update_info(png, info)

    row_pointers = ffi.new("png_bytep[?]", height) 
    for y = 0, height-1 do
        row_pointers[y] = png_buffer + width * y * 4
    end

    lpng.png_read_image(png, row_pointers);
    io.close(fp)

    local pptr = ffi.new("png_structp[1]")
    pptr[0] = png 
    local iptr = ffi.new("png_infop[1]")
    iptr[0] = info
    lpng.png_destroy_read_struct(pptr, iptr, nil)
    -- // invert rbga to agbr

    for i = 0, width * height - 1 do
        local r = png_buffer[4 * i]
        local g = png_buffer[4 * i + 1]
        local b = png_buffer[4 * i + 2]
        local a = png_buffer[4 * i + 3]

        png_buffer[4 * i] = b
        png_buffer[4 * i + 1] = g
        png_buffer[4 * i + 2] = r
        png_buffer[4 * i + 3] = 255
    end

    copy_png_to_screen( png_buffer, width, 240, 90 )
end

-- /* Render full frame with mouse cursor */
local function render(fbfd) 

	-- /* 4 bytes per pixel */
	local blue = ffi.new("char[4]", {255, 0, 0, 255})
	local black = ffi.new("char[4]", {0, 255, 255, 255})

    S.lseek(fbfd, 0, "set")

	ffi.copy(framebuffer, wallpaper, screenwidth * screenheight * 4)

    local fbptr = nil
    for x = 0, screenwidth-1 do
        fbptr = framebuffer + (mouse_y * screenwidth + x) * 4
		ffi.copy(fbptr, blue, 4)
    end

    for y = 0, screenheight-1 do
        fbptr = framebuffer + (y * screenwidth + mouse_x) * 4
		ffi.copy(fbptr, blue, 4)
    end

	-- // 32 bits per pixel, uppifrån vänster rad för rad ner
	-- //memcpy(&framebuffer[0], blue, 4);

	S.write(fbfd, framebuffer, screenwidth * screenheight * 4)
end

local function main() 

    local mouse_event = ffi.new("struct input_event[1]")
    --local data = ffi.new("char[3]")

    -- /* Allocate framebuffer */
    framebuffer = ffi.new("char[?]", screenwidth * screenheight * 4)
    wallpaper = ffi.new("char[?]", screenwidth * screenheight * 4)

    load()
    --return 0

    -- /* Open framebuffer, mouse, terminal */
    fbfd = S.open("/dev/fb0", "rdwr", 0)
    msfd = S.open("/dev/input/event2", "rdwr,nonblock", "0666")
    ttyfd = S.open("/dev/tty0", "rdwr", 0)

    -- /* Render once */
    render(fbfd)

    -- /* Wait for mouse input */
    while (true) do

        -- /* Select on fds */
        local rfds = ffi.new("fd_set[1]")
        getch.fdzero(rfds)
        getch.fdset(h.getfd(msfd), rfds)

        tv = ffi.new("struct timeval[1]")
        tv[0].tv_sec = 5
        tv[0].tv_usec = 0

        while (true) do

 			local last_read = S.read(msfd, mouse_event, ffi.sizeof("struct input_event"))

            -- local last_read = libc.read(msfd, data, 3)
            if (last_read == nil) then break end

			if (EV_REL == mouse_event[0].type) then
				if (REL_X == mouse_event[0].code) then
					mouse_x = mouse_x + mouse_event[0].value
				elseif (REL_Y == mouse_event[0].code) then
					mouse_y = mouse_y + mouse_event[0].value
                end
            end
 
            -- /* Cap mouse x */
            if (mouse_x < 0) then
                mouse_x = 0
            elseif (mouse_x >= screenwidth) then
                mouse_x = screenwidth - 1
            end

            -- /* Cap mouse y */
            if (mouse_y < 0) then
                mouse_y = 0
            elseif (mouse_y >= screenheight) then
                mouse_y = screenheight - 1
            end

            -- print(last_read, mouse_x, mouse_y)
        end 
        
        render(fbfd) 
    end
end 

main()