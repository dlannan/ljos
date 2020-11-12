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

print(package.path)
print(package.cpath)

pp = require("pprint").prettyPrint

-- If running on real machine, becareful!!!
libld   = ffi.load(ENV_PATH.."lib/ld-linux-x86-64.so.2", true)
libc    = ffi.load(ENV_PATH.."lib/libc.so.6", true)

-- This is somewhat dangerous and could cause name clashes!! should rethink this.
ft 		= require( "ffi/freetype")
cairo	= require( "ffi/cairo" )

------------------------------------------------------------------------------------------------------------

tween 	= require( "scripts/utils/tween" )
FB0 	   = require( "libs/fb0" )
FB0:init()

local stride = cairo.cairo_format_stride_for_width(cairo.CAIRO_FORMAT_ARGB32, FB0.w)
print(FB0.w, FB0.h, stride)

surface = cairo.cairo_image_surface_create_for_data(FB0.fb_data, cairo.CAIRO_FORMAT_ARGB32, FB0.w, FB0.h, stride)
cr = cairo.cairo_create(surface)

cairo.cairo_select_font_face(cr, "serif", cairo.CAIRO_FONT_SLANT_NORMAL, cairo.CAIRO_FONT_WEIGHT_BOLD)
cairo.cairo_set_font_size(cr, 32.0)
cairo.cairo_set_source_rgb(cr, 0.0, 0.0, 1.0)
cairo.cairo_move_to(cr, 100.0, 100.0)
cairo.cairo_show_text(cr, ffi.string("Hello, CairoGraphics!"))

cairo.cairo_arc (cr, 128.0, 128.0, 76.8, 0, 2 * 3.141)
cairo.cairo_clip (cr)

cairo.cairo_new_path (cr) 
cairo.cairo_rectangle (cr, 0, 0, 256, 256)
cairo.cairo_fill (cr)
cairo.cairo_set_source_rgb (cr, 0, 1, 0)
cairo.cairo_move_to (cr, 0, 0)
cairo.cairo_line_to (cr, 256, 256)
cairo.cairo_move_to (cr, 256, 0)
cairo.cairo_line_to (cr, 0, 256)
cairo.cairo_set_line_width (cr, 10.0)
cairo.cairo_stroke (cr)

cairo.cairo_destroy(cr);
cairo.cairo_surface_destroy(surface);
print("Finished")
FB0:close()