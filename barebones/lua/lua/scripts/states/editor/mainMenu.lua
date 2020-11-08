------------------------------------------------------------------------------------------------------------
-- State - Main Menu Test
--
-- Decription: Display GUI Elements
-- 				Interaction with Slideouts
--				Interaction with Exploder

------------------------------------------------------------------------------------------------------------

require("scripts/utils/xml-reader")
require("scripts/utils/assimp")
	
------------------------------------------------------------------------------------------------------------
-- Some states call other states!!
-- This is our BG state, and belongs with the MainMenu state
 
--local Sbg   	= require("scripts/states/mainBG")
--local Slogin 	= require("scripts/states/login")

--local Srender3d	= require("scripts/states/render3dbase")
--local Srender2d	= require("scripts/states/render2dbase")

byt3dRender = require("framework/byt3dRender")
Gpool		= require("framework/byt3dPool")

require("framework/byt3dModel")
require("framework/byt3dLevel")
require("framework/byt3dShader")
require("framework/byt3dTexture")

------------------------------------------------------------------------------------------------------------
-- Shaders

require("shaders/base_models")
require("shaders/base_terrain")
require("shaders/sky")
require("shaders/grid")

------------------------------------------------------------------------------------------------------------
---- Panels
local skyProp 	= require("scripts/panels/sky_properties")
local cmdPanel 	= require("scripts/panels/command_console")

local terr = require("scripts/states/common/terrain")
------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------

local SMainMenu	= NewState()

------------------------------------------------------------------------------------------------------------

gLevels				= { }
gLevels["Default"]	= { 
	
	level 	= nil
}

------------------------------------------------------------------------------------------------------------

SMainMenu.newObject	= nil
SMainMenu.editLevel	= "Default"

------------------------------------------------------------------------------------------------------------

local initComplete 	= false
local image1		= nil		-- Test image
local image2		= nil		-- Test image
local bgimage		= nil

local lsurf			= nil		-- Test SVG Surface
local changetosetup = false

------------------------------------------------------------------------------------------------------------

SMainMenu.camH		= 0.0		-- Camera heading
SMainMenu.camP		= 0.0		-- Camera pitch

SMainMenu.omx		= 0
SMainMenu.omy		= 0

SMainMenu.freePos	= { 0.0, 0.0, 0.0 }

------------------------------------------------------------------------------------------------------------

function SMainMenu:Init(wwidth, wheight)
	
--	Sbg.WINwidth 	= wwidth
--	Sbg.WINheight 	= wheight
	
	self.width 		= wwidth
	self.height 	= wheight
	Gcairo.newObject	= nil

    terr:Init(wwidth, wheight)
	initComplete = true
end

------------------------------------------------------------------------------------------------------------

function SMainMenu:Begin()

	-- Assert that we have valid width and heights (simple protection)
	assert(initComplete == true, "Init function not called.")
	self.time_start = os.time()

--	bgimage = Gcairo:LoadImage("bg1", "byt3d/data/bg/background-ufo.png")
--	bgimage.scalex = self.width /  bgimage.width
--	bgimage.scaley = self.height / bgimage.height
	
	image1 = Gcairo:LoadImage("icon1", "byt3d/data/icons/generic_64.png", 1)
	self.img_camera = Gcairo:LoadImage("icon1", "byt3d/data/icons/generic_obj_camera_64.png")
	
--	image2 = Gcairo:LoadImage("icon2", "byt3d/data/icons/generic_64.png")
	-- Test the xml Loader
	--lsurf = CairoLoadSvg("gary/svg/test01.svg")
	local lvl = byt3dLevel:New("Default", "data/levels/default.lvl" )
	gLevels[self.editLevel].level = lvl

	local level = gLevels[self.editLevel].level
	level.cameras["Default"]:SetupView(0.0, 0.0, self.width, self.height)
	level.cameras["Default"]:LookAt( { 13, 12, 13 }, { 0.0, 0.0, 0.0 } )
	
	level.cameras["FreeCamera"]:SetupView(0.0, 0.0, self.width, self.height)
	-- byt3dRender.currentCamera.node.transform:Position(0.0, 0.0, 0.0)
	--	Sbg:Begin()
	
	local newtex = byt3dTexture:New()
	newtex:FromCairoImage(Gcairo, "cannon_image", "byt3d/data/models/Brendan/Cannon.png")

    local tertex = byt3dTexture:New()
    tertex:FromCairoImage(Gcairo, "terrain_image", "byt3d/data/terrain/byt3d_Test01.png")

	local newshader = byt3dShader:NewProgram(colour_shader_vert, colour_shader_frag)
	newshader.name = "Shader_Canon"
    local tershader = byt3dShader:NewProgram(terrain_shader_vert, terrain_shader_frag)
    tershader.name = "Shader_Terrain"

    --- Loading in some models
	self.canon = LoadModel("byt3d\\data\\models\\Brendan\\Canon.dae")
	self.canon:SetMeshProperty("shader", newshader)
	self.canon:SetSamplerTex(newtex, "s_tex0")
	self.canon.node.transform:Position(0.0, 0.0, 0.0)

    self.terrain1 = LoadModel("byt3d\\data\\terrain\\byt3d_Test01.obj")
    self.terrain1:SetMeshProperty("shader", tershader)
    self.terrain1:SetSamplerTex(tertex, "s_tex0")
    self.terrain1.node.transform:Position(0.0, 0.0, 0.0)

	level.nodes["root"]:AddChild(self.canon, "Model_Canon")
    level.nodes["root"]:AddChild(self.terrain1, "Model_Terrain")
	
	-- Dont like this here.. 
	skyProp:Begin()
	Gcairo.newObject = nil
	
	self.speed 	= 1.0
	self.crot	= 0.0
	
	self:SetupEditor()
    terr:Begin()
end

------------------------------------------------------------------------------------------------------------

function SMainMenu:SetupEditor()

	local level = gLevels[self.editLevel].level
	local newmodel = byt3dModel:New()
	local newshader = byt3dShader:NewProgram(grid_shader_vert, grid_shader_frag)
	local newtex = byt3dTexture:New()
	
	newtex:FromCairoImage(Gcairo, "grid1", "byt3d/data/images/editor/grid_001.png")
	newmodel:GeneratePlane(160, 160, 10)
	newmodel:SetMeshProperty("alpha", 1)
	newmodel:SetMeshProperty("priority", byt3dRender.EDITOR_ALPHA)
	newmodel:SetMeshProperty("shader", newshader)

	newmodel:SetSamplerTex(newtex, "s_tex0")
	newmodel.node.transform:Position(0.0, 0.0, 0.0)
	newmodel.node.transform:RotationHPR(0.0, 90.0, 0.0)
	level.nodes["root"]:AddChild(newmodel, "editor_grid")
end

------------------------------------------------------------------------------------------------------------

function QuitApplication()

	print("Quitting...")
	sm:ExitState()
end

------------------------------------------------------------------------------------------------------------

function ChangeCamera(callerobj)

	local level = gLevels["Default"].level
	level:ChangeCamera(callerobj.name)
	Gcairo.exploderStates[" Cameras"].state = 4
end

------------------------------------------------------------------------------------------------------------

function NewSkyObject(callerobj)

	-- If a newobject is being created, dont make another!!!!
	if Gcairo.newObject ~= nil then return end
	Gcairo.newObject = skyProp
end

------------------------------------------------------------------------------------------------------------

function NewAssetManager(callerobj)

	Gcairo.slideOutStates[" Assets"].state = 4
	sm:JumpToState("AssetManager")
end

------------------------------------------------------------------------------------------------------------

function SMainMenu:RenderNewItem(mxi, myi, buttons)

	-- New object created?
	if Gcairo.newObject ~= nil then 
		-- Make a newobject panel. If the Ok is hit, then make the object or exit
		Gcairo.newObject:Update(mxi, myi, buttons)
	end
end

------------------------------------------------------------------------------------------------------------
-- Test function for making a mesh onscreen
function NewCubeMesh(callerobj)

	local level = gLevels["Default"].level
	local newtex = byt3dTexture:New()
	newtex:NewColorImage( {255, 255, 255, 128} )
	print("NewColorTexture:", newtex.textureId)
	
	local h = math.random() * 20.0	
	local newshader = byt3dShader:NewProgram(colour_shader_vert, colour_shader_frag)
	newshader.name = "Shader_Cube"
	level.spheres = {}
	for i= 1, 20 do
	
		local d = 100.0
		local x = math.cos(math.pi / 10 * i) * d
		local z = math.sin(math.pi / 10 * i) * d
		
		local newmodel = byt3dModel:New()
		newmodel:GenerateCube(20.0, 2)
		--newmodel:GeneratePlane(20.0, 20.0)
		--newmodel:GenerateSphere(20.0, 5.0)
		newmodel:SetMeshProperty("shader", newshader)
		newmodel:SetSamplerTex(newtex, "s_tex0")
		
		newmodel.node.transform:Position(x, 0.0, z)
		local name = "Model_"..tostring(newmodel)
		level.nodes["root"]:AddChild(newmodel, name)
		-- level.spheres[name] = newmodel
	end
	
	-- Update renderer so it knows whats going on....
	--byt3dRender.currentCamera.node.transform:LookAt( 0.0, 0.0, 0.0 )
	Gcairo.slideOutStates[" Objects"].state = CAIRO_STATE.SO_STATES.IN
end

------------------------------------------------------------------------------------------------------------

function SMainMenu:RenderProjects(column_wide, fontsize)

	-- A Content window of 'stuff' to show
	local content = Gcairo:List("render_projects", 0, 10, column_wide, 110)
	local tcolor = { r=1.0, b=1.0, g=1.0, a=1.0 }

	local line2 = {
		{ name=" New Project", ntype=CAIRO_TYPE.TEXT, size=fontsize },
		{ name="space1", size=50 },
		{ name="test2", ntype=CAIRO_TYPE.IMAGE, image=image1, size=fontsize, color=tcolor }
	}

	local nodes = {
		{ name="space1", size=6 },
		{ name="line2", ntype=CAIRO_TYPE.HLINE, size=fontsize, nodes = line2 },
		{ name="space1", size=6 },
		{ name=" Load Project", ntype=CAIRO_TYPE.TEXT, size=fontsize },
		{ name="space1", size=6 },
		{ name=" Save Project", ntype=CAIRO_TYPE.TEXT, size=fontsize },
		{ name="space1", size=6 },
		{ name=" Quit", ntype=CAIRO_TYPE.TEXT, size=fontsize, callback=QuitApplication },
		{ name="space1", size=6 }
	}
	
--	nodes[11] = { name="space2", size=10 }
--	nodes[12] = { name="Another Line", ntype=CAIRO_TYPE.TEXT, size=10 }
	content.nodes = nodes

    Gcairo.style.button_color = CAIRO_STYLE.METRO.SEAGREEN

	-- Render a slideOut object on left side of screen
	Gcairo:SlideOut(" Project",  CAIRO_UI.TOP, 245, fontsize+4, 0, content)
end

------------------------------------------------------------------------------------------------------------

function SMainMenu:CameraList()

	-- A Window for selection of the camera to use (should break into seperate state)
	local content = Gcairo:List("camera_list", 0, 10, 180, 140)
	local tcolor = { r=1.0, b=1.0, g=1.0, a=1.0 }
	local nodes = {
	}
	
	local level = gLevels[self.editLevel].level
	for k,v in pairs(level.cameras) do
	
		local nline1 = { name="space1", size=6 }
		local nline2 = { 
			 { name="space1", size=4 },
			 { name="test2", ntype=CAIRO_TYPE.IMAGE, image=image1, size=14, color=tcolor },
			 { name="space1", size=4 },
			 { name=k, ntype=CAIRO_TYPE.TEXT, size=14, callback=ChangeCamera }
		}
		if byt3dRender.currentCamera ~= v then nline2[2] = { name="space1", size=14 } end
		local nline2ref = { name="line2", ntype=CAIRO_TYPE.HLINE, size=14, nodes = nline2 }
		table.insert(nodes, nline1)
		table.insert(nodes, nline2ref )
	end
	
--	nodes[11] = { name="space2", size=10 }
--	nodes[12] = { name="Another Line", ntype=CAIRO_TYPE.TEXT, size=10 }
	content.nodes = nodes

	-- Render a slideOut object on left side of screen
	-- Gcairo:SlideOut(" Cameras",  CAIRO_UI.LEFT, 140, 20, 0, content)
	Gcairo:Exploder(" Cameras", self.img_camera, 210, 2, 20, 20, 0, content)
end

------------------------------------------------------------------------------------------------------------

function SMainMenu:RenderAssets(column_wide, fontsize)

	-- A Content window of 'stuff' to show
	local gamelist = Gcairo:List("render_assets", 0, 0, column_wide, 110)
	local gnodes = {
		{ name="space1", size=6 },
		{ name=" Asset Manager", ntype=CAIRO_TYPE.TEXT, size=fontsize, callback=NewAssetManager },
		{ name="space1", size=6 },
		{ name=" Export Assets", ntype=CAIRO_TYPE.TEXT, size=fontsize },
		{ name="space1", size=6 },
		{ name=" Validate Assets", ntype=CAIRO_TYPE.TEXT, size=fontsize },
		{ name="space1", size=6 }
	}
	gamelist.nodes = gnodes

	local saved = Gcairo.style.button_color
	Gcairo.style.border_width = 0.0
	Gcairo.style.button_color = CAIRO_STYLE.METRO.ORANGE
	Gcairo.style.button_color.a = 1
	Gcairo:SlideOut(" Assets", CAIRO_UI.TOP, 245+column_wide, fontsize+4, 0, gamelist)
	Gcairo.style.button_color = saved
end

------------------------------------------------------------------------------------------------------------

function SMainMenu:RenderCollections(column_wide, fontsize)

	-- A Content window of 'stuff' to show
	local gamelist = Gcairo:List("render_collections", 0, 0, column_wide, 150)
	local gnodes = {
		{ name="space1", size=6 },
		{ name=" Levels ", ntype=CAIRO_TYPE.TEXT, size=fontsize },
		{ name="space1", size=6 },
		{ name=" Layers ", ntype=CAIRO_TYPE.TEXT, size=fontsize },
		{ name="space1", size=6 },
		{ name=" Pools ", ntype=CAIRO_TYPE.TEXT, size=fontsize },
		{ name="space1", size=6 },	
		{ name=" Causes ", ntype=CAIRO_TYPE.TEXT, size=fontsize },
		{ name="space1", size=6 },	
		{ name=" Effects ", ntype=CAIRO_TYPE.TEXT, size=fontsize },
		{ name="space1", size=6 }	
	}
	gamelist.nodes = gnodes

	local saved = Gcairo.style.button_color
	Gcairo.style.border_width = 0.0
	Gcairo.style.button_color = CAIRO_STYLE.METRO.GREEN
	Gcairo.style.button_color.a = 1
	Gcairo:SlideOut(" Collections", CAIRO_UI.TOP, 245+column_wide * 2, fontsize+4, 0, gamelist)
	Gcairo.style.button_color = saved
end

------------------------------------------------------------------------------------------------------------

function SMainMenu:RenderObjects(column_wide, fontsize)

	-- A Content window of 'stuff' to show
	local gamelist = Gcairo:List("render_objects", 0, 0, column_wide, 150)
	local gnodes = {
		{ name="space1", size=6 },
		{ name=" Empty", ntype=CAIRO_TYPE.TEXT, size=fontsize },
		{ name="space1", size=6 },
		{ name=" GUI", ntype=CAIRO_TYPE.TEXT, size=fontsize },
		{ name="space1", size=6 },
		{ name=" Static Mesh", ntype=CAIRO_TYPE.TEXT, size=fontsize },
		{ name="space1", size=6 },
		{ name=" Dynamic Mesh", ntype=CAIRO_TYPE.TEXT, size=fontsize, callback=NewCubeMesh },
		{ name="space1", size=6 },
		{ name=" Sky ", ntype=CAIRO_TYPE.TEXT, size=fontsize, callback=NewSkyObject  },
		{ name="space1", size=6 },
		{ name=" Light ", ntype=CAIRO_TYPE.TEXT, size=fontsize },
		{ name="space1", size=6 },
		{ name=" Volume", ntype=CAIRO_TYPE.TEXT, size=fontsize },
		{ name="space1", size=6 },
		{ name=" Particle ", ntype=CAIRO_TYPE.TEXT, size=fontsize },
		{ name="space1", size=6 },
		{ name=" Camera", ntype=CAIRO_TYPE.TEXT, size=fontsize },
		{ name="space1", size=6 }
	}
	gamelist.nodes = gnodes

	local saved = Gcairo.style.button_color
	Gcairo.style.border_width = 0.0
	Gcairo.style.button_color = CAIRO_STYLE.METRO.PURPLE
	Gcairo.style.button_color.a = 1
	Gcairo:SlideOut(" Objects", CAIRO_UI.TOP, 245+column_wide * 3, fontsize+4, 0, gamelist)
	Gcairo.style.button_color = saved
end

------------------------------------------------------------------------------------------------------------

function SMainMenu:RenderParts(column_wide, fontsize)

	-- A Content window of 'stuff' to show
	local gamelist = Gcairo:List("render_parts", 0, 0, column_wide, 150)
	local gnodes = {
		{ name="space1", size=6 },
		{ name=" Script", ntype=CAIRO_TYPE.TEXT, size=fontsize },
		{ name="space1", size=6 },
		{ name=" Physics", ntype=CAIRO_TYPE.TEXT, size=fontsize },
		{ name="space1", size=6 },
		{ name=" Controller", ntype=CAIRO_TYPE.TEXT, size=fontsize },
		{ name="space1", size=6 },
		{ name=" Input", ntype=CAIRO_TYPE.TEXT, size=fontsize },
		{ name="space1", size=6 },
		{ name=" Output", ntype=CAIRO_TYPE.TEXT, size=fontsize },
		{ name="space1", size=6 }
	}
	gamelist.nodes = gnodes

	local saved = Gcairo.style.button_color
	Gcairo.style.border_width = 0.0
	Gcairo.style.button_color = CAIRO_STYLE.METRO.LBLUE
	Gcairo.style.button_color.a = 1
	Gcairo:SlideOut(" Parts", CAIRO_UI.TOP, 245+column_wide * 4, fontsize+4, 0, gamelist)
	Gcairo.style.button_color = saved
end

------------------------------------------------------------------------------------------------------------

function SMainMenu:Update(mxi, myi, buttons)
	
	local tcolor = { r=1.0, b=1.0, g=1.0, a=1.0 }
	Gcairo:Begin()

    terr:Update(mxi, mxi, buttons)
	
	-- Gcairo:RenderImage(bgimage, 0, 0, 0.0)

	local saved = Gcairo.style.button_color
	Gcairo.style.button_color = { r=0.2, g=0.0, b=0.7, a=1.0 }
	Gcairo:RenderBox(0, 0, self.width, 20.0, 0)

	Gcairo:RenderBox(5, 5, 240, 22, 0)
	Gcairo:RenderText("byt3d", 20, 20, 20, tcolor )
	Gcairo.style.button_color = saved
		
	local column_wide = (Gcairo.WIDTH - 250) / 5
	local fontsize = 14 
	
	self:RenderProjects(column_wide, fontsize)
	self:RenderAssets(column_wide, fontsize)
	self:RenderCollections(column_wide, fontsize)
	self:RenderObjects(column_wide, fontsize)
	self:RenderParts(column_wide, fontsize)
	
	self:RenderNewItem(mxi, myi, buttons)
	self:CameraList()
	
--	Gcairo:SlideOut(" Main Menu", CAIRO_UI.LEFT, 100, 22, 0, content)
--	Gcairo:Exploder("Test1", nil, 200, 500, 100, 20, 0, content)

    Gcairo:Update(mxi, myi, buttons)

	self.crot = 0.1
	self.canon.node.transform:RotateHPR( self.crot, 0.0, 0.0 )
    canon = self.canon
	
	-- Update the Editable level after the cairo UI - can respond to events more easily
	local level = gLevels[self.editLevel].level
	cmat = byt3dRender.currentCamera.node.transform

    local tm = byt3dRender.currentCamera.node.transform.m
    -- level.spheres["Model1"].node.transform:Position( tm[13], tm[14], tm[15] )

    local vec = { tm[3], tm[7], tm[11], 0.0 }
    local dir = VecNormalize( vec )

    -- Apply Speed
    self.freePos[1] = self.freePos[1] + dir[1] * self.speed
    self.freePos[2] = self.freePos[2] + dir[2] * self.speed
    self.freePos[3] = self.freePos[3] + dir[3] * self.speed

    byt3dRender.currentCamera.node.transform:Identity()
    byt3dRender.currentCamera.node.transform:Translate( self.freePos[1], self.freePos[2], self.freePos[3] )
    byt3dRender.currentCamera.node.transform:RotateHPR( self.camH, self.camP, 0.0 )

	-- Free Camera rotate
	if byt3dRender.currentCamera == level.cameras["FreeCamera"] and buttons[3] == true then

		self.camH = self.camH + (mxi - self.omx) * 0.5
		self.camP = self.camP + (myi - self.omy) * 0.5

        local tbl = gSdisp.wm.KeyDown
		for k, v in pairs(tbl) do
			if v.scancode == sdl.SDL_SCANCODE_S then
				self.speed = -2.0
			end
			if v.scancode == sdl.SDL_SCANCODE_W then
				self.speed = 2.0
			end
		end
		
		if #tbl == 0 then
            self.speed = self.speed * 0.9
        end
	else
        self.speed = self.speed * 0.9
	end

    local tbl = gSdisp.wm.KeyUp
	for k,v in pairs(tbl) do

		if v.scancode == sdl.SDL_SCANCODE_GRAVE then
			-- If a newobject is being created, dont make another!!!!
			if Gcairo.newObject == nil then 
				Gcairo.newObject = cmdPanel 
				Gcairo.newObject:Begin()
			else
				Gcairo.newObject:Finish()
				Gcairo.newObject = nil
			end
		end
	end

	self.omx = mxi
	self.omy = myi
end

------------------------------------------------------------------------------------------------------------

function SMainMenu:Render()

	-- Render level before UI so it overlays the 3D.
	local level = gLevels[self.editLevel].level
	level:Render(false)
	if Gcairo.newObject ~= nil then	Gcairo.newObject:Render() end
	Gcairo:Render()		
end

------------------------------------------------------------------------------------------------------------

function SMainMenu:Finish()

	local tpool = byt3dPool:GetPool(byt3dPool.TEXTURES_NAME)
	tpool:DestroyAllFromTime(self.time_start)

	image1	= nil
	image2	= nil

	bgimage = nil
	-- Gcairo:Finish()
end
	
------------------ ------------------------------------------------------------------------------------------

return SMainMenu

------------------------------------------------------------------------------------------------------------
