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

typedef struct _lfb{
	char id[18]; 
	int pixels_per_line;
	int bytes_per_line;
	int width;
	int height;
	int bpp;
	unsigned char *buff;
} lfb_object;

void lfb_memset(void *dst, unsigned int data, size_t n);
void lfb_fillscr(Color c);
void lfb_fillbox(int, int, int, int, Color);
void lfb_drawline(Point a, Point b, int width, Color c);
void lfb_drawpolygon(Point *, int, Color);
void lfb_drawtriangle(Point[3], int, Color);
void lfb_drawsquare(Point, int, int, int, Color);
void lfb_fillsquare(Point, int, int, Color);
Image* lfb_loadPNG(int);
int lfb_drawimage(Image *, Point);
void lfb_setpixel(int offset, Color);
void lfb_putpixel(int, int, Color);
void lfb_draw_char(char, Color);
void lfb_refresh();
lfb_object * lfb_getfb();
void lfb_init();
]]

-- FIXME: this path could/should be absolute
local libfb = ffi.load("lib/x86_64-linux-gnu/libfb.so")

libfb.lfb_init()
libfb.lfb_fillscr(0)

return libfb
