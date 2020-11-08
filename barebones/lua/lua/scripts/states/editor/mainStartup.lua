------------------------------------------------------------------------------------------------------------
-- State - Main Startup Screen 
--
-- Decription: Shows a main startup screen much like the 'Start' area on Win8
--				Project load / modify / play
--				Documentation and Help
--				Customisation etc
------------------------------------------------------------------------------------------------------------

require("scripts/utils/xml-reader")
	
------------------------------------------------------------------------------------------------------------

local Smainstartup	= NewState()
	
------------------------------------------------------------------------------------------------------------
-- Making this global gives all modules access to it

Gcairo      = require("scripts/cairo_ui/base")

------------------------------------------------------------------------------------------------------------

local initComplete 	= false
local image1		= nil		-- Test image
local image2		= nil		-- Test image
local bgimage		= nil

local lsurf			= nil		-- Test SVG Surface
local changetosetup = false

------------------------------------------------------------------------------------------------------------

function Smainstartup:Init(wwidth, wheight)
	
--	Sbg.WINwidth 	= wwidth
--	Sbg.WINheight 	= wheight
	
	self.width 		= wwidth
	self.height 	= wheight
	Gcairo.newObject	= nil

	Gcairo:Init(self.width, self.height)
	initComplete = true
	
	--SassMgr.width 	= wwidth
	--SassMgr.height 	= wheight
	--sm:CreateState("AssetManager",	SassMgr)
end

------------------------------------------------------------------------------------------------------------

function StartEditor(callerobj)

	--sm:JumpToState("MainMenu")
	sm:JumpToState("ProjectSetup")
end

------------------------------------------------------------------------------------------------------------

function AssetManager(callerobj)

	--sm:JumpToState("MainMenu")
	sm:JumpToState("AssetManager")
end

------------------------------------------------------------------------------------------------------------

function ShowAbout(callerobj)

    --sm:JumpToState("MainMenu")
    sm:JumpToState("AboutPage")
end

------------------------------------------------------------------------------------------------------------

function LaunchLink(callerobj)

	os.execute("start iexplore.exe \"http://www.gagagames.com\"")
end

------------------------------------------------------------------------------------------------------------

function Smainstartup:Begin()

	-- Assert that we have valid width and heights (simple protection)
	assert(initComplete == true, "Init function not called.")
	
	self.icon1 	= Gcairo:LoadImage("icon_image", 	"byt3d/data/icons/generic_obj_image_64.png")
	self.icon2 	= Gcairo:LoadImage("icon_doc", 		"byt3d/data/icons/generic_obj_doc_64.png")
	self.icon3 	= Gcairo:LoadImage("icon_ref", 		"byt3d/data/icons/generic_obj_ref_64.png")
	
	self.icon4 	= Gcairo:LoadImage("icon_ask", 		"byt3d/data/icons/generic_obj_ask_64.png")
	self.icon5 	= Gcairo:LoadImage("icon_tag", 		"byt3d/data/icons/generic_obj_tag_64.png")
	
	self.scenario1 	= Gcairo:LoadImage("icon_scenario1", 	"byt3d/data/images/scenario_1.png")
	self.scenario2 	= Gcairo:LoadImage("icon_scenario2", 	"byt3d/data/images/scenario_2.png")
	self.scenario3 	= Gcairo:LoadImage("icon_scenario3", 	"byt3d/data/images/scenario_3.png")
	self.scenario4 	= Gcairo:LoadImage("icon_scenario4", 	"byt3d/data/images/scenario_4.png")
	self.scenario5 	= Gcairo:LoadImage("icon_scenario5", 	"byt3d/data/images/scenario_5.png")
	self.scenario6 	= Gcairo:LoadImage("icon_scenario6", 	"byt3d/data/images/scenario_6.png")
	self.scenario7 	= Gcairo:LoadImage("icon_scenario7", 	"byt3d/data/images/scenario_7.png")
	
	self.config1 	= Gcairo:LoadImage("icon_config1", "byt3d/data/images/config_1.png")
	self.config2 	= Gcairo:LoadImage("icon_config2", "byt3d/data/images/config_2.png")
	self.config3 	= Gcairo:LoadImage("icon_config3", "byt3d/data/images/config_3.png")
	self.config4 	= Gcairo:LoadImage("icon_config4", "byt3d/data/images/config_4.png")
		
	self.icon10 	= Gcairo:LoadImage("icon_list", "byt3d/data/icons/generic_obj_list_64.png")
	self.icon11 	= Gcairo:LoadImage("icon_box", "byt3d/data/icons/generic_obj_box_64.png")
	self.icon12 	= Gcairo:LoadImage("icon_window", "byt3d/data/icons/generic_obj_windows_64.png")
end

------------------------------------------------------------------------------------------------------------

function Smainstartup:Update(mxi, myi, buttons)

	local tcolor = { r=1.0, b=1.0, g=1.0, a=1.0 }
	Gcairo.style.button_border_color  = { r=1.0, b=1.0, g=1.0, a=1.0 }
	Gcairo.style.border_width = 0.0
	Gcairo:Begin()
	
	-- Gcairo:RenderImage(bgimage, 0, 0, 0.0)

	local saved = Gcairo.style.button_color
	Gcairo.style.button_color = { r=0.0, b=0.1, g=0.0, a=1 }
	Gcairo:RenderBox(0, 0, self.width, self.height, 0)
	Gcairo.style.button_color = saved
	
	-- Create Modify Save
	Gcairo.style.button_color = { r=0.3, b=0.9, g=0.3, a=1 }
	Gcairo:RenderBox(120, 120, 250, 150, 0)
	Gcairo:RenderText("Create", 140, 170, 20, tcolor )
	Gcairo:RenderText("Modify", 140, 200, 20, tcolor )
	Gcairo:RenderText("Save", 140, 230, 20, tcolor )
	-- Animated images?
	Gcairo:RenderMultiImage("MS_start", { self.icon1, self.icon2, self.icon3 }, 260, 170, 4.0, 1.0, nil)
	local start_button = Gcairo:Button( "  ", 120, 120, 250, 150, 0, 0, StartEditor)
	
	-- Play
	Gcairo.style.button_color = { r=0.9, b=0.1, g=0.3, a=1 }
	Gcairo:RenderBox(380, 120, 250, 150, 0)
	Gcairo:RenderMultiSlideImage("MS_play", { self.scenario1, self.scenario2, self.scenario3, self.scenario4, self.scenario5, self.scenario6, self.scenario7 }, 380, 130, 250, 6.0, 0.7, nil)
	Gcairo:RenderText("Play", 400, 255, 20, tcolor )
	
	-- Configure
	Gcairo.style.button_color = { r=0.3, b=0.3, g=0.3, a=1 }
	Gcairo:RenderBox(640, 120, 250, 150, 0)
	Gcairo:RenderMultiSlideImage("MS_configure", { self.config1, self.config2, self.config3, self.config4 }, 640, 165, 250, 8.0, 1.2, nil)
	Gcairo:RenderText("Configure", 770, 150, 20, tcolor )
	
	-- About
	Gcairo.style.button_color = { r=0.35, b=0.0, g=0.6, a=1 }
	Gcairo:RenderBox(120, 280, 120, 150, 0)
	Gcairo:RenderText("About", 140, 415, 20, tcolor )
	-- Animated images?
	Gcairo:RenderMultiImage("MS_about", { self.icon4, self.icon5 }, 150, 310, 4.3, 1.0, ShowAbout)
	
	-- Help
	Gcairo.style.button_color = { r=0.85, g=0.65, b=0.0, a=1 }
	Gcairo:RenderBox(250, 280, 120, 150, 0)
	Gcairo:RenderText("Help", 270, 415, 20, tcolor )
	
	-- Example Scene
	Gcairo.style.button_color = { r=0.55, g=0.08, b=0.26, a=1 }
	Gcairo:RenderBox(380, 280, 250, 150, 0)
	Gcairo:RenderText("Asset Manager", 400, 315, 20, tcolor )
	local asset_button = Gcairo:Button( " ", 380, 280, 250, 150, 0, 0, AssetManager)
	
	-- Tutorials
	Gcairo.style.button_color = { r=0.15, g=0.1, b=0.5, a=1 }
	Gcairo:RenderBox(640, 280, 250, 150, 0)
	-- Animated images?
	Gcairo:RenderMultiImage("MS_tutorial", { self.icon10, self.icon11, self.icon12 }, 750, 325, 2.3, 0.67, nil)
	Gcairo:RenderText("Tutorials", 660, 315, 20, tcolor )
	
	Gcairo:RenderText("byt3d", 120, 70, 30, tcolor )
	Gcairo:RenderText(BYT3D_VERSION, 120, 100, 11, tcolor)
	Gcairo:RenderText("www.gagagames.com", self.width - 250, self.height - 30, 20, tcolor )
	
	--Dont have to render a button to have an active element attached to it!
	local button = Gcairo:Button( "httplink", self.width-250, self.height-50, 200, 20, 0, 0, LaunchLink)
	--Gcairo:RenderButton(button, 0.0)
	
	Gcairo:Update(mxi, myi, buttons)
end

------------------------------------------------------------------------------------------------------------

function Smainstartup:Render()

	Gcairo:Render()
end

------------------------------------------------------------------------------------------------------------

function Smainstartup:Finish()

	Gcairo:Finish()
end
	
------------------------------------------------------------------------------------------------------------

return Smainstartup

------------------------------------------------------------------------------------------------------------
