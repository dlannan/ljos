local ffi = require("ffi")
ffi.cdef[[
typedef struct{
    int x;
    int y;
} Point;

typedef int Color;

typedef struct{
    int width;
    int height;
    int bpp;
    char *data;
} Image;

struct{
	char id[18]; //!< Framebuffer driver identification string
	int pixels_per_line;
	int width;
	int height;
	int bpp;
	void (*memset)(void *dst, unsigned int data, size_t n);
	void (*fillscr)(Color c);
	void (*fillbox)(int, int, int, int, Color);
	void (*drawline)(Point a, Point b, int width, Color c);
	void (*drawpolygon)(Point *, int, Color);
	void (*drawtriangle)(Point[3], int, Color);
	void (*drawsquare)(Point, int, int, int, Color);
	void (*fillsquare)(Point, int, int, Color);
	Image* (*loadPNG)(int);
	int (*drawimage)(Image *, Point);
	void (*setpixel)(int offset, Color);
	void (*putpixel)(int, int, Color);
	void (*draw_char)(char, Color);
	void (*refresh)();
	unsigned char * (*getframebuffer)();
} lfb;

void lfb_init();
]]

-- FIXME: this path could/should be absolute
local libfb = ffi.load("lib/x86_64-linux-gnu/libfb.so")

libfb.lfb_init()

return libfb.lfb
