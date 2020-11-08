------------------------------------------------------------------------------------------------------------

ffi = require( "ffi" )
gl  = require( "ffi/OpenGLES2" )

------------------------------------------------------------------------------------------------------------
-- Version format: <release number>.<hg revision>.<special id>  -- TODO: Automate this id.. soon..
BYT3D_VERSION		= "0.71.001"

------------------------------------------------------------------------------------------------------------
-- Setup the root file path to use.

package.path 		= package.path..";byt3d\\?.lua;;lua/?.lua;"

--package.cpath = package.cpath..";bin\\Windows\\x86\\socket\\?.dll"
--package.cpath = package.cpath..";bin\\Windows\\x86\\mime\\?.dll"

print(package.path)
print(package.cpath)

------------------------------------------------------------------------------------------------------------
-- Window width
--local WINwidth, WINheight = 1024, 576
--local WINwidth, WINheight, WINFullscreen = 1280, 720, 0
local WINwidth, WINheight, WINFullscreen = 480, 800, 0
local GUIwidth, GUIheight = 480, 800

------------------------------------------------------------------------------------------------------------
-- Global because states need to use it themselves

sm = require("scripts/platform/statemanager")

------------------------------------------------------------------------------------------------------------

require("scripts/cairo_ui/base")
require("scripts/utils/xml-reader")
local Sstartup 	= require("scripts/states/editor/mainStartup")

byt3dRender = require("framework/byt3dRender")
Gpool		= require("framework/byt3dPool")
require("framework/byt3dShader")
require("framework/byt3dTexture")

require("scripts/platform/wm")

require("shaders/base")
require("shaders/PlasmaShader")
--require("gary/shaders/PlasmaStarsShader")

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

	local wm = InitSDL(WINwidth, WINheight)
	local eglInfo = InitEGL(wm)
	
	wm:update()

    print("OpenGL version string: "..ffi.string(gl.glGetString(gl.GL_VERSION))) 
    print("OpenGL renderer string: "..ffi.string(gl.glGetString(gl.GL_RENDERER)))
    print("OpenGL vendor string: "..ffi.string(gl.glGetString(gl.GL_VENDOR)))

    Gcairo:Init(GUIwidth, GUIheight)

    local bgShader = byt3dShader:NewProgram(colour_shader, plasma_stars_shader)
    bgShader.name = "Shader_bg"

	local loc_bgposition = gl.glGetAttribLocation( bgShader.info.prog, "vPosition" )
	local loc_time		= gl.glGetUniformLocation( bgShader.info.prog, "time" )
	local loc_res		= gl.glGetUniformLocation( bgShader.info.prog, "resolution" )

	
	-- Some icons on screen to enable/disable
	icons	=	{}
	icons.facebook = { 
			x=400, y=60, enabled=0, 
			enableImage=Gcairo:LoadImage("fbEnable", "gary/icons/NORMAL/64/facebook_64.png"),
			disableImage=Gcairo:LoadImage("fbDisable", "gary/icons/DIS/64/facebook_64.png"),
	}	
	
	icons.twitter = { 
			x=470, y=60, enabled=0, 
			enableImage=Gcairo:LoadImage("twEnable", "gary/icons/NORMAL/64/twitter_64.png"),
			disableImage=Gcairo:LoadImage("twDisable", "gary/icons/DIS/64/twitter_64.png"),
	}	

	icons.google = { 
			x=540, y=60, enabled=0, 
			enableImage=Gcairo:LoadImage("ggEnable", "gary/icons/NORMAL/64/google_64.png"),
			disableImage=Gcairo:LoadImage("ggDisable", "gary/icons/DIS/64/google_64.png"),
	}	
	
	local image1 = Gcairo:LoadImage("icon1", "gary/icons/NORMAL/64/facebook_64.png")
	
	-- Test the xml Loader
	local lsurf = Gcairo:LoadSvg("byt3d/data/svg/test01.svg")
	-- DumpXml(lsurf)
	
	-- TODO: This will change substantially. Will move to a state system when testing/prototyping is done
	--		 Do not rely on this loop! It will be gone soon!
	while wm:update() do

        local tcolor = { r=1.0, b=1.0, g=1.0, a=1.0 }
        Gcairo:Begin()
		gl.glViewport( 0, 0, WINwidth, WINheight )
		
		-- No need for clear when BG is being written
--		gl.glClearColor (1.0, 0.0, 0.0, 1.0)
--		gl.glClear (  bit.bor(gl.GL_DEPTH_BUFFER_BIT, gl.GL_COLOR_BUFFER_BIT) )
		gl.glUseProgram( bgShader.info.prog )
		
        gl.glUniform1f(loc_time, os.clock() )
        gl.glUniform2f(loc_res, WINwidth, WINheight)
           
        gl.glVertexAttribPointer( loc_bgposition, 3, gl.GL_FLOAT, gl.GL_FALSE, 0, Gcairo.vertexArray )
        gl.glEnableVertexAttribArray( loc_bgposition )

        gl.glDrawElements( gl.GL_TRIANGLES, 6, gl.GL_UNSIGNED_SHORT, Gcairo.ibuffer )
        gl.glDisableVertexAttribArray( loc_bgposition )
		
        Gcairo:RenderBox(30, 30, 200, 50, 5)
        Gcairo:RenderText("GARY", 45, 65, 30, tcolor )
		
		-- A Content window of 'stuff' to show
		local content = Gcairo:List("", 5, 5, 400, 300)
		local nodes = {}
		nodes[1] = { name="Information", ntype=CAIRO_TYPE.TEXT, size=20 }
		nodes[2] = { name="   some 1234", ntype=CAIRO_TYPE.TEXT, size=20 }
		nodes[3] = { name="   more 1234", ntype=CAIRO_TYPE.TEXT, size=20 }
		nodes[4] = { name="Do Stuff", ntype=CAIRO_TYPE.BUTTON, size=30, border=2, corner=5, colorA=tcolor, colorB=tcolor }
		
		local line1 = {}
		line1[1] = { name="test1", ntype=CAIRO_TYPE.IMAGE, image=image1, size=30, color=tcolor }
		line1[2] = { name="space1", size=50 }
		line1[3] = { name="test2", ntype=CAIRO_TYPE.IMAGE, image=image1, size=40, color=tcolor }
		
		nodes[5] = { name="space2", size=40 }
		nodes[6] = { name="line1", ntype=CAIRO_TYPE.HLINE, size=30, nodes = line1 }
		nodes[7] = { name="Another Line", ntype=CAIRO_TYPE.TEXT, size=30 }
		content.nodes = nodes
		
		-- Render a slideOut object on left side of screen
        Gcairo:SlideOut("Main Menu", CAIRO_UI.LEFT, 100, 40, 5, content)
        Gcairo:Exploder("Test1", nil, 200, 500, 100, 20, 5, content)
        Gcairo:Exploder("Test2", image1, 400, 600, 120, 100, 5, content)

        Gcairo:RenderSvg(lsurf)
		
		-- Render Icons
		if(wm.MouseButton[1] == true) then icons.facebook.enabled=1 else icons.facebook.enabled=0 end
		if(wm.MouseButton[2] == true) then icons.twitter.enabled=1 else icons.twitter.enabled=0 end
		if(wm.MouseButton[3] == true) then icons.google.enabled=1 else icons.google.enabled=0 end
		for k,v in pairs(icons) do RenderIcon(v) end

        local buttons 	= wm.MouseButton
        local move 		= wm.MouseMove

        Gcairo:Update(move.x, move.y, buttons)
        Gcairo:Render()
		
--	    draw_string( 0, 0, "Some Text" )
--	  
--		gl.glVertexAttribPointer( loc_position, 3, gl.GL_FLOAT, gl.GL_FALSE, 0, vbo )
--		gl.glEnableVertexAttribArray( loc_position )
--		gl.glDrawArrays( gl.GL_POINTS, 0, vbo_index/3)
--		prev_vbo_index, vbo_index = vbo_index, 0

        gl.glFinish()
	    egl.eglSwapBuffers( eglInfo.dpy, eglInfo.surf )
	end

    Gcairo:Finish()
	
	egl.eglDestroyContext( eglInfo.dpy, eglInfo.ctx )
	egl.eglDestroySurface( eglInfo.dpy, eglInfo.surf )
	egl.eglTerminate( eglInfo.dpy )
	
	wm:exit()
end

------------------------------------------------------------------------------------------------------------

main()

------------------------------------------------------------------------------------------------------------
