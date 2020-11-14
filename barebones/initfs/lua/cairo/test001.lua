------------------------------------------------------------------------------------------------------------

ffi = require( "ffi" )

ENV_PATH = "/"

package.cpath = ENV_PATH.."lib/?.so;"..ENV_PATH.."lib64/?.so;/?.so;"..ENV_PATH.."lua/uv/lib/?.so"
package.path = ENV_PATH.."?.lua;"..ENV_PATH.."lua/?.lua;"..ENV_PATH.."lib/?.so"
package.path = package.path..";"..ENV_PATH.."lua/ffi/?.lua"
package.path = package.path..";"..ENV_PATH.."lua/libs/?.lua"
package.path = package.path..";"..ENV_PATH.."lua/deps/?.lua"
package.path = package.path..";"..ENV_PATH.."lua/libs/?/init.lua"
package.path = package.path..";"..ENV_PATH.."lua/ffi/?/init.lua;"..ENV_PATH.."lua/?/init.lua"

--package.cpath = package.cpath..";bin\\Windows\\x86\\socket\\?.dll"
--package.cpath = package.cpath..";bin\\Windows\\x86\\mime\\?.dll"

-- If running on real machine, becareful!!!
libld   = ffi.load(ENV_PATH.."lib/x86_64-linux-gnu/ld-linux-x86-64.so.2", true)
libc    = ffi.load(ENV_PATH.."lib/x86_64-linux-gnu/libc.so.6", true)

-- This is somewhat dangerous and could cause name clashes!! should rethink this.
ft 		    = require( "lua/ffi/freetype")
local cr    = require( "lua/ffi/cairo" )

------------------------------------------------------------------------------------------------------------

tween   = require( "lua/scripts/utils/tween" )
local lfb = require("lua/ffi/libfb")

lfb.fillscr(0x00FF00)

local stride = cr.cairo_format_stride_for_width(cr.CAIRO_FORMAT_ARGB32, lfb.width)
print(lfb.width, lfb.height, stride)

surface = cr.cairo_image_surface_create_for_data(lfb.getframebuffer(), cr.CAIRO_FORMAT_ARGB32, lfb.width, lfb.height, stride)
-- local data = ffi.new( "uint8_t[?]", FB0.w * FB0.h * 4 )
-- surface = cr.cairo_image_surface_create_for_data(data, cr.CAIRO_FORMAT_ARGB32, FB0.w, FB0.h, FB0.w*4)
local ctx = cr.cairo_create(surface)

-- cr.cairo_set_source_rgba(ctx, 1, 1, 1, 0.5)
-- cr.cairo_paint(ctx)

cr.cairo_select_font_face(ctx, "serif", cr.CAIRO_FONT_SLANT_NORMAL, cr.CAIRO_FONT_WEIGHT_BOLD)
cr.cairo_set_font_size(ctx, 32.0)
cr.cairo_set_source_rgb(ctx, 0.0, 0.0, 1.0)
cr.cairo_move_to(ctx, 100.0, 100.0)
cr.cairo_show_text(ctx, "Hello, CairoGraphics!")

cr.cairo_arc (ctx, 128.0, 128.0, 76.8, 0, 2 * 3.141)
cr.cairo_clip (ctx)

cr.cairo_new_path (ctx) 
cr.cairo_rectangle (ctx, 0, 0, 256, 256)
cr.cairo_fill (ctx)
cr.cairo_set_source_rgba (ctx, 0, 1, 0, 0.75)
cr.cairo_move_to (ctx, 0, 0)
cr.cairo_line_to (ctx, 256, 256)
cr.cairo_move_to (ctx, 256, 0)
cr.cairo_line_to (ctx, 0, 256)
cr.cairo_set_line_width (ctx, 10.0)
cr.cairo_stroke (ctx)

cr.cairo_surface_write_to_png( surface, "test.png" )

cr.cairo_destroy(ctx);
cr.cairo_surface_destroy(surface);
print("Finished")
