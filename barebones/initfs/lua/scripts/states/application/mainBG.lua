------------------------------------------------------------------------------------------------------------
-- State - Main Background Render Test
--
-- Decription: Display BG Shader

------------------------------------------------------------------------------------------------------------

require("shaders/base")
--require("shaders/PlasmaShader")
require("shaders/PlasmaStarsShader")
	
------------------------------------------------------------------------------------------------------------

local SMainBG	= NewState()

------------------------------------------------------------------------------------------------------------

-- Some reasonable defaults.
local loc_bgposition 	= nil
local loc_res			= nil
local loc_time			= nil

local bgShader			= nil		-- BG Shader

SMainBG.WINwidth		= 512
SMainBG.WINheight		= 512

------------------------------------------------------------------------------------------------------------

function SMainBG:Begin()

	bgShader = MakeShader( colour_shader, plasma_stars_shader )
	
	loc_bgposition 	= gl.glGetAttribLocation( bgShader.prog, "aPosition" )
	loc_time		= gl.glGetUniformLocation( bgShader.prog, "time" )
	loc_res			= gl.glGetUniformLocation( bgShader.prog, "resolution" )
end

------------------------------------------------------------------------------------------------------------

function SMainBG:Update(mxi, myi, buttons)

end

------------------------------------------------------------------------------------------------------------

function SMainBG:Render()

	gl.glUseProgram( bgShader.prog )
	
	gl.glUniform1f(loc_time, os.clock() )
	gl.glUniform2f(loc_res, SMainBG.WINwidth, SMainBG.WINheight)
	   
	gl.glEnableVertexAttribArray( loc_bgposition ) 
	gl.glVertexAttribPointer( loc_bgposition, 3, gl.GL_FLOAT, gl.GL_FALSE, 0, vertexArray )
	
	gl.glDrawArrays( gl.GL_TRIANGLES, 0, 6 )
	gl.glDisableVertexAttribArray( loc_bgposition )

end

------------------------------------------------------------------------------------------------------------

function SMainBG:Finish()
end
	
------------------------------------------------------------------------------------------------------------

return SMainBG

------------------------------------------------------------------------------------------------------------
