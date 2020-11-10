------------------------------------------------------------------------------------------------------------

ffi = require( "ffi" )

ENV_PATH = "./"

package.cpath = ENV_PATH.."lib/?.so;"..ENV_PATH.."lib64/?.so;/?.so;"..ENV_PATH.."lua/uv/lib/?.so"
package.path = ENV_PATH.."lua/?.lua;"..ENV_PATH.."lib/?.so"
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
cr 		= require( "ffi/cairo" )

------------------------------------------------------------------------------------------------------------

tween 	= require( "scripts/utils/tween" )
FB0 	= require( "libs/fb0" )


local min, max, abs, sqrt, log, floor = math.min, math.max, math.abs, math.sqrt, math.log, math.floor

local function cairo_test()
   local surface = ffi.gc( 
      cr.cairo_image_surface_create( 
	 cr.CAIRO_FORMAT_ARGB32, 
	 240, 
	 80 
      ),
      cr.cairo_surface_destroy 
   )

   local c = ffi.gc( 
      cr.cairo_create( surface ), 
      cr.cairo_destroy 
   )

   cr.cairo_select_font_face(
      c, "bizarre", 
      cr.CAIRO_FONT_SLANT_OBLIQUE, 
      cr.CAIRO_FONT_WEIGHT_BOLD 
   )

   local font_face = cr.cairo_font_face_reference( cr.cairo_get_font_face( c ))
   print( 'font_face', font_face )
   assert( ffi.string( cr.cairo_toy_font_face_get_family( font_face )) == "bizarre"      )
   assert( cr.cairo_font_face_get_type(       font_face ) == cr.CAIRO_FONT_TYPE_TOY      )
   assert( cr.cairo_toy_font_face_get_slant(  font_face ) == cr.CAIRO_FONT_SLANT_OBLIQUE )
   assert( cr.cairo_toy_font_face_get_weight( font_face ) == cr.CAIRO_FONT_WEIGHT_BOLD   )
   assert( cr.cairo_font_face_status(         font_face ) == cr.CAIRO_STATUS_SUCCESS     )
   cr.cairo_font_face_destroy (font_face);
   
   print( 'font_face 1', font_face )

   font_face = cr.cairo_toy_font_face_create(
      "bozarre",
      cr.CAIRO_FONT_SLANT_OBLIQUE,
      cr.CAIRO_FONT_WEIGHT_BOLD
   )
   assert( ffi.string( cr.cairo_toy_font_face_get_family( font_face )) == "bozarre"      )
   assert( cr.cairo_font_face_get_type(       font_face ) == cr.CAIRO_FONT_TYPE_TOY      )
   assert( cr.cairo_toy_font_face_get_slant(  font_face ) == cr.CAIRO_FONT_SLANT_OBLIQUE )
   assert( cr.cairo_toy_font_face_get_weight( font_face ) == cr.CAIRO_FONT_WEIGHT_BOLD   )
   assert( cr.cairo_font_face_status(         font_face ) == cr.CAIRO_STATUS_SUCCESS     )
   cr.cairo_font_face_destroy( font_face )

   print( 'font_face 2', font_face )

   print( surface, c )

   local temp = [[

   cr.cairo_move_to( c, 10, 50 )
   cr.cairo_show_text( c, "Hello, world" )

   print( surface, c )


   cr.cairo_set_font_size(  c, 32 )
   cr.cairo_set_source_rgb( c,  0,  0, 1 )

--   cr.cairo_surface_write_to_png( surface, "hello.png" )
]]

end

local function kernel_1d_new( radius, deviation )
   assert( radius > 0 )

   local size = 2 * radius + 1

   local radius2 = radius + 1
   if deviation == 0 then
      deviation = sqrt( - radius2*radius2 / ( 2 * log(1/255)))
   end

   kernel = ffi.new( "double[?]", size + 1 )
   kernel[0] = size
   local value, sum = -radius, 0
   local oodeviation = 1 / deviation
   local oodeviationbyconst = oodeviation / 2.506628275
   local oodeviationsqhalf = oodeviation * oodeviation / 2
   for i=0, size do
      kernel[ i+1 ] = oodeviationbyconst * exp ( - value * value * oodeviationsqhalf )
      sum = sum + kernel[ i+1 ]
      value = value + 1
   end

   local oosum = 1 / sum
   for i=0, size do
      kernel[ i+1 ] = kernel[ i+1 ] * oosum
   end

   return kernel
end

local function cairo_image_surface_blur( surface, horzRadius, vertRadius )
   assert( surface )
   assert( horzSurface > 0 )
   assert( vertRadius > 0 )
   assert( cr. ( surface ) == cr.CAIRO_SURFACE_TYPE_IMAGE )
   cr.cairo_surface_flush( surface )
   local src = cr.cairo_image_surface_get_data( surface )
   local width = cr.cairo_image_surface_get_width( surface )
   local height = cr.cairo_image_surface_get_height( surface )
   local format = cr.cairo_image_surface_get_format( surface )
   local chanmap = { 
      [cr.CAIRO_FORMAT_ARGB32] = 4, 
      [cr.CAIRO_FORMAT_RGB24]  = 3 
   }
   local channels = chanmap[ format ]
   assert( channels )
   local stride = width * channels
   local horzBlur = ffi.new( "double[?]", height * stride )
   local vertBlur = ffi.new( "double[?]", height * stride )
   local horzKernel = kernel_1d_new( horzRadius, 0 )
   local vertKernel = kernel_1d_new( vertRadius, 0 )
   local process = { 
      { src,      horzKernel, horzBlur }, 
      { horzBlur, vertKernel, verbBlur },
   }
   for p = 1, #process do
      local process = process[p]
      local src, kernel, blur = process[1], process[2], process[3]
      for iy = 0, height - 1 do
	 for ix = 0, width - 1 do
	    local R, G, B, A = 0, 0, 0, 0
	    local size = horzKernel[0]
	    local offset = floor(-size * 0.5)
	    local s, e = max(ix + offset, 0), min(ix + offset + size - 1, width)
	    for x = s, e do
	       local i = ix + offset - s + 1
	       local o = iy * stride + x * channels
	       if channels == 4 then
		  A = A + kernel[i] * src[o+3]
	       end
	       R = R + kernel[i] * src[o+2]
	       G = G + kernel[i] * src[o+1]
	       B = B + kernel[i] * src[o+0]
	    end
	    local o = iy * stride + ix * channels
	    if channels == 4 then
	       blur[ o+3 ] = A
	    end
	    blur[ o+2 ] = R
	    blur[ o+1 ] = G
	    blur[ o+0 ] = B
	 end
      end
   end
   for iy = 0, height - 1 do
      for ix = 0, width - 1 do
	 local o = iy * stride + ix * channels
	 if channels == 4 then
	    src[ o+3 ] = verBlur[ o+3 ]
	 end
	 src[ o+2 ] = vertBlur[ o+3 ]
	 src[ o+1 ] = vertBlur[ o+3 ]
	 src[ o+0 ] = vertBlur[ o+3 ]
      end
   end
   cr.cairo_surface_mark_dirty( surface )
end
