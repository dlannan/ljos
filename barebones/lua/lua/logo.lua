------------------------------------------------------------------------------------------------------------

ffi = require( "ffi" )

ENV_PATH = "./"

-- package.cpath = ENV_PATH.."lib/?.so;"..ENV_PATH.."lib64/?.so;/?.so;"..ENV_PATH.."lua/uv/lib/?.so"
package.path = package.path..";"..ENV_PATH.."lua/?.lua;"..ENV_PATH.."lib/?.so"
-- package.path = package.path..";"..ENV_PATH.."lua/ffi/?.lua"
package.path = package.path..";"..ENV_PATH.."lua/libs/?.lua"
-- package.path = package.path..";"..ENV_PATH.."lua/deps/?.lua"
-- package.path = package.path..";"..ENV_PATH.."lua/libs/?/init.lua"
-- package.path = package.path..";"..ENV_PATH.."lua/ffi/?/init.lua;"..ENV_PATH.."lua/?/init.lua"

--package.cpath = package.cpath..";bin\\Windows\\x86\\socket\\?.dll"
--package.cpath = package.cpath..";bin\\Windows\\x86\\mime\\?.dll"

print(package.path)

pp = require("pprint").prettyPrint

-- If running on real machine, becareful!!!
libld   = ffi.load(ENV_PATH.."lib/x86_64-linux-gnu/ld-linux-x86-64.so.2", true)
libc    = ffi.load(ENV_PATH.."lib/x86_64-linux-gnu/libc.so.6", true)

------------------------------------------------------------------------------------------------------------
-- Window width
--local WINwidth, WINheight = 1024, 576
--local WINwidth, WINheight, WINFullscreen = 1280, 720, 0
local WINwidth, WINheight, WINFullscreen = 480, 800, 0
local GUIwidth, GUIheight = 1024, 768

------------------------------------------------------------------------------------------------------------

Gcairo      = require("lua/scripts/cairo_ui/base")
require("lua/scripts/utils/xml-reader")

------------------------------------------------------------------------------------------------------------
-- Http testing

-- Help here: http://w3.impa.br/~diego/software/luasocket/http.html
-- Info: There are two methods of request. Simple and complex
-- Simple:
--http.request(url [, body])
--
-- Complex: (this allows method and all sorts as needed)
--http.request{
--  url = string,
--  [sink = LTN12 sink,]
--  [method = string,]
--  [headers = header-table,]
--  [source = LTN12 source],
--  [step = LTN12 pump step,]
--  [proxy = string,]
--  [redirect = boolean,]
--  [create = function]
--}

-- load the http module
--local http = require "socket.http"
--
--local result = http.request("http://www.youtube.com/watch?v=_eT40eV7OiI")
--local title = result:match("<[Tt][Ii][Tt][Ll][Ee]>([^<]*)<")
--print(title)

------------------------------------------------------------------------------------------------------------
-- Simple little icon render func (probably should go in cairo)

function RenderIcon( icon )
	if(icon.enabled==0) then 
		Gcairo:RenderImage(icon.disableImage, icon.x, icon.y, 0.0)
	else 
		Gcairo:RenderImage(icon.enableImage, icon.x, icon.y, 0.0)
	end
end

------------------------------------------------------------------------------------------------------------

function main()

    Gcairo:Init(GUIwidth, GUIheight)

    -- Test the xml Loader
    local lsurf = Gcairo:LoadSvg("lua/data/svg/tetris_diagram.svg")
    local logo = Gcairo:LoadImage("ljos", "lua/data/images/LJOS.png")
	-- DumpXml(lsurf)
	
	local dotest = true
	local start = os.clock()

	-- TODO: This will change substantially. Will move to a state system when testing/prototyping is done
	--		 Do not rely on this loop! It will be gone soon!
	while dotest do

        local tcolor = { r=1.0, b=1.0, g=1.0, a=1.0 }
		Gcairo:Begin()
		
		-- Gcairo:TestFonts() 

		-- Gcairo:RenderBox(30, 30, 200, 50, 5)
        -- Gcairo:RenderText("GARY", 45, 65, 30, tcolor )
		
        -- Gcairo:RenderSvg(lsurf)
        Gcairo:RenderImage(logo, 100, 100, 0)
		
		-- Render Icons
		-- if(wm.MouseButton[1] == true) then icons.facebook.enabled=1 else icons.facebook.enabled=0 end
		-- if(wm.MouseButton[2] == true) then icons.twitter.enabled=1 else icons.twitter.enabled=0 end
		-- if(wm.MouseButton[3] == true) then icons.google.enabled=1 else icons.google.enabled=0 end
		-- for k,v in pairs(icons) do RenderIcon(v) end

        -- local buttons 	= wm.MouseButton
        -- local move 		= wm.MouseMove

		-- Gcairo:Update(move.x, move.y, buttons)
		Gcairo:Update(0, 0, {0,0,0})
        Gcairo:Render()
		
--	    draw_string( 0, 0, "Some Text" )
		if( os.clock() - start > 10 ) then dotest = nil end
	end

    Gcairo:Finish()
end

------------------------------------------------------------------------------------------------------------

main()

------------------------------------------------------------------------------------------------------------
