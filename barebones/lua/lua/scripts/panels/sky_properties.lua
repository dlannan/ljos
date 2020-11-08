------------------------------------------------------------------------------------------------------------
-- State - Sky Properties panel
--
-- Decription: Displays the new Sky Property panel. 
--			   Creates a new sky object on completion.

------------------------------------------------------------------------------------------------------------

	
------------------------------------------------------------------------------------------------------------

local SSkyPanel	= NewState()
local gskySelect = ""
local gskyTypes = { SKY_SHADER = " Sky Shader", SKY_DOMETEX = " Sky Dome Texture", SKY_BOX = " Sky Box" }

------------------------------------------------------------------------------------------------------------

function ExitSkyProp()
	Gcairo.newObject = nil
end

------------------------------------------------------------------------------------------------------------

function ChangeSkyProp(callerobj)
	gskySelect = callerobj.name
end

------------------------------------------------------------------------------------------------------------

function CreateSkyObject()

	local level = gLevels["Default"].level

	local cam_far = byt3dRender.currentCamera.farPlane * 0.95  -- May need to tinker with this
	local newmodel = byt3dModel:New()
	
	if gskySelect == gskyTypes.SKY_SHADER then
		--callerobj.newObject = { name="Sky Object", type="Dome|Box", camera=defaultCam, params="" }
		local newshader = byt3dShader:NewProgram(sky_shader_vert, sky_shader_frag)
		local newtex = byt3dTexture:New()
		newtex:NewColorImage( {64, 64, 255, 255} )
		newmodel:GenerateSphere(cam_far, 10)
		newmodel:SetMeshProperty("priority", 1)
		newmodel:SetMeshProperty("shader", newshader)
		newmodel:SetSamplerTex(newtex, "s_tex0")
		
	end 
	
	if gskySelect == gskyTypes.SKY_DOMETEX then
		local newshader = byt3dShader:NewProgram(colour_shader_vert, colour_shader_frag)
		local newtex = byt3dTexture:New()
		newtex:FromCairoImage(Gcairo, "sky1", "byt3d/data/bg/skyboxsun25degtest.png")
		newmodel:GenerateSphere(cam_far, 10)
        newmodel:SetMeshProperty("priority", 1)
        newmodel:SetMeshProperty("shader", newshader)
		newmodel:SetSamplerTex(newtex, "s_tex0")
	end
	
	if gskySelect == gskyTypes.SKY_BOX then
		local newshader = byt3dShader:NewProgram(colour_shader_vert, colour_shader_frag)
		local newtex = byt3dTexture:New()
		newtex:FromCairoImage(Gcairo, "sky1", "byt3d/data/bg/skyboxsun25degtest.png")
		newmodel:GenerateCube(cam_far * 0.6, 10)
        newmodel:SetMeshProperty("priority", 1)
        newmodel:SetMeshProperty("shader", newshader)
		newmodel:SetSamplerTex(newtex, "s_tex0")
	end
	
	-- level.sky:AddChild(newmodel, "Sky_Main")
	--byt3dRender.currentCamera.node:AddChild(newmodel, name)
	newmodel.node.transform:Position(0.0, 0.0, 0.0)
	level.sky = newmodel
	Gcairo.newObject = nil
end

------------------------------------------------------------------------------------------------------------

function SSkyPanel:Begin()
	gskySelect = " Sky Shader"
	self.image1 = Gcairo:LoadImage("icon1", "byt3d/data/icons/generic_64.png")
end

------------------------------------------------------------------------------------------------------------

function SSkyPanel:Update(mxi, myi, buttons)

	local tcolor = { r=1.0, b=1.0, g=1.0, a=1.0 }
	local line1 = {
			{ name=" OK", ntype=CAIRO_TYPE.TEXT, size=14, callback=CreateSkyObject },
			{ name="space1", size=116 },
			{ name=" Cancel", ntype=CAIRO_TYPE.TEXT, size=14, callback=ExitSkyProp }
	}

	-- A Content window of 'stuff' to show
	local sky_property = Gcairo:List("", 0, 0, 220, 106)
	local snodes = {}
	local i = 1
	for k,v in pairs(gskyTypes) do
	
		local nline1 = { name="space1", size=8 }
		local nline2 = { 
			 { name="space1", size=6 },
			 { name="test2", ntype=CAIRO_TYPE.IMAGE, image=self.image1, size=14, color=tcolor },
			 { name="space1", size=6 },
			 { name=v, ntype=CAIRO_TYPE.TEXT, size=14, callback=ChangeSkyProp }
		}
		if gskySelect ~= v then nline2[2] = { name="space1", size=14 } end
		local nline2ref = { name="line2", ntype=CAIRO_TYPE.HLINE, size=18, nodes = nline2 }
		snodes[i] = nline1; i=i+1
		snodes[i] = nline2ref; i=i+1
	end
	
	snodes[i] =	{ name = "space1", size=22 }; i=i+1
	snodes[i] =	{ name = "line1", ntype=CAIRO_TYPE.HLINE, size=18 , nodes=line1 }; i=i+1
	sky_property.nodes = snodes

	local saved = Gcairo.style.button_color
	Gcairo.style.button_color = { r=0.0, g=0.0, b=0.0, a=1.0 }
	Gcairo:RenderBox(400, 100, 220, 124, 0)
	Gcairo.style.button_color = CAIRO_STYLE.METRO.ORANGE
	Gcairo.style.button_color.a = 0.4
	Gcairo:RenderBox(400, 122, 220, 80, 0)
	Gcairo.style.border_width = 0.0
	Gcairo.style.button_color = CAIRO_STYLE.METRO.ORANGE
	Gcairo.style.button_color.a = 0.5
	Gcairo:Panel(" Sky Properties", 400, 100, 18, 0, sky_property)

	Gcairo.style.button_color = saved
end

------------------------------------------------------------------------------------------------------------

function SSkyPanel:Render()

end

------------------------------------------------------------------------------------------------------------

function SSkyPanel:Finish()

end
	
------------------------------------------------------------------------------------------------------------

return SSkyPanel

------------------------------------------------------------------------------------------------------------