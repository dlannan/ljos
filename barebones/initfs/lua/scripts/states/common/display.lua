------------------------------------------------------------------------------------------------------------
-- State - Display
--
-- Decription: Setup the display for the device
-- 				Includes SDL initialisation
--				Includes EGL initialisation
--				Inlcudes Shader initialisation	

------------------------------------------------------------------------------------------------------------

require("scripts/platform/wm")
require("shaders/base")
	
------------------------------------------------------------------------------------------------------------

local SDisplay	= NewState()

------------------------------------------------------------------------------------------------------------

SDisplay.wm 				= nil
SDisplay.eglinfo			= nil

-- Some reasonable defaults.
SDisplay.WINwidth			= 640
SDisplay.WINheight			= 480
SDisplay.WINFullscreen		= 0

SDisplay.initComplete 		= false
SDisplay.runApp				= true

------------------------------------------------------------------------------------------------------------

function SDisplay:Init(wwidth, wheight, fs)
	
	SDisplay.WINwidth = wwidth
	SDisplay.WINheight = wheight
	SDisplay.WINFullscreen = fs
	self.initComplete = true
end

------------------------------------------------------------------------------------------------------------

function SDisplay:Begin()

	-- Assert that we have valid width and heights (simple protection)
	assert(self.initComplete == true, "Init function not called.")
	
	self.wm = InitSDL(SDisplay.WINwidth, SDisplay.WINheight, SDisplay.WINFullscreen)
	self.eglInfo = InitEGL(self.wm)	
	
	self.runApp = self.wm:update()
	gl.glClearColor ( 0.0, 0.0, 0.0, 0.0 )
end

------------------------------------------------------------------------------------------------------------

function SDisplay:Update(mx, my, buttons)

    -- This actually generates/gets mouse position and buttons.
	-- Push them into SDisplay
	self.runApp = self.wm:update()
end

------------------------------------------------------------------------------------------------------------

function SDisplay:PreRender()

	-- No need for clear when BG is being written
    -- TODO: Make this an optional call (no real need for it)
	gl.glClear( bit.bor(gl.GL_COLOR_BUFFER_BIT, gl.GL_DEPTH_BUFFER_BIT ) )
end

------------------------------------------------------------------------------------------------------------

function SDisplay:Flip()

	egl.eglSwapBuffers( self.eglInfo.dpy, self.eglInfo.surf )
end

------------------------------------------------------------------------------------------------------------

function SDisplay:Finish()
	egl.eglDestroyContext( self.eglInfo.dpy, self.eglInfo.ctx )
	egl.eglDestroySurface( self.eglInfo.dpy, self.eglInfo.surf )
	egl.eglTerminate( self.eglInfo.dpy )
	
	self.wm:exit()
end
	
------------------------------------------------------------------------------------------------------------

function SDisplay:GetMouseButtons()
	return self.wm.MouseButton
end

------------------------------------------------------------------------------------------------------------

function SDisplay:GetMouseMove()
	return self.wm.MouseMove
end
	
------------------------------------------------------------------------------------------------------------

function SDisplay:GetKeyDown()
	return self.wm.KeyDown
end
	
------------------------------------------------------------------------------------------------------------
	
function SDisplay:GetRunApp()
	
	self.runApp = self.wm:update()
	return self.runApp
end

------------------------------------------------------------------------------------------------------------

return SDisplay

------------------------------------------------------------------------------------------------------------

	