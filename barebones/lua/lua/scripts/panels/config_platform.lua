------------------------------------------------------------------------------------------------------------
-- Config Windows - Configuration setup for the windows platform
--
-- Decription:  Configuration setup for the windows platform
--				The config is saved into the profile data. 
--            

------------------------------------------------------------------------------------------------------------
--if ffi.os == "Windows" then require("scripts/platform/windows") end

local tween		= require("scripts/utils/tween")
local folder    = require("scripts/panels/editor_folderselect")

------------------------------------------------------------------------------------------------------------

local SconfigPlatform	= NewState()

------------------------------------------------------------------------------------------------------------

CONFIG = 
{
	WINDOWS		= "Windows 7",
	ANDROID		= "Android",
	BLACKBERRY 	= "Blackberry",
	UBUNTU		= "Ubuntu"
}

------------------------------------------------------------------------------------------------------------

function SconfigPlatform:Init(wwidth, wheight)
	self.width = wwidth
	self.height = wheight
	
	self.current = CONFIG.WINDOWS
end

------------------------------------------------------------------------------------------------------------

function SconfigPlatform:Begin()	

	self.image1 		= Gcairo:LoadImage("icon1_next", "byt3d/data/icons/generic_64.png", 1)
    self.image1.scalex = 0.6; self.image1.scaley = 0.6;
	self.image2 		= Gcairo:LoadImage("icon2", "byt3d/data/icons/generic_obj_close_64.png")
    self.image3 		= Gcairo:LoadImage("icon3", "byt3d/data/icons/generic_obj_add_64.png")
    self.image4 		= Gcairo:LoadImage("icon4", "byt3d/data/icons/generic_obj_tick_64.png")

	self.icon_windows 	= Gcairo:LoadImage("icon_windows", "byt3d/data/icons/small/config_windows.png", 1)
    self.icon_windows.scalex = 0.6; self.icon_windows.scaley = 0.6;
	self.icon_android 	= Gcairo:LoadImage("icon_android", "byt3d/data/icons/small/config_android.png", 1)
    self.icon_android.scalex = 0.6; self.icon_android.scaley = 0.6;
	self.icon_blackberry= Gcairo:LoadImage("icon_bb", "byt3d/data/icons/small/config_blackberry.png", 1)
    self.icon_blackberry.scalex = 0.6; self.icon_blackberry.scaley = 0.6;
	self.icon_ubuntu 	= Gcairo:LoadImage("icon_bb", "byt3d/data/icons/small/config_ubuntu.png", 1)
    self.icon_ubuntu.scalex = 0.6; self.icon_ubuntu.scaley = 0.6;

    assetPath = ""
    sm:CreateState("FolderSelect",		folder)
    self.last_buttons = {}
end

------------------------------------------------------------------------------------------------------------

function ExitConfigManager(callerobj)

	sm:ExitState()
end

------------------------------------------------------------------------------------------------------------

function EditWorld(callerobj)

    -- Save project xml
    SaveXml(gProjectFile..".xml", gCurrProjectInfo.byt3dProject, "byt3dProject")
	sm:JumpToState("MainMenu")
end

------------------------------------------------------------------------------------------------------------

function AddPathToProject(callerobj)

    sm:JumpToState("FolderSelect")
end

------------------------------------------------------------------------------------------------------------

function SconfigPlatform:Update(mxi, myi, buttons)	

	local tcolor = { r=1.0, b=1.0, g=1.0, a=1.0 }
	Gcairo.style.button_border_color  = { r=1.0, b=1.0, g=1.0, a=1.0 }
	Gcairo.style.border_width = 0.0
	Gcairo:Begin()
	
	local saved = Gcairo.style.button_color
	Gcairo.style.button_color = { r=0.0, b=0.1, g=0.0, a=1 }
	Gcairo:RenderBox(0, 0, self.width, self.height, 0)
	Gcairo.style.button_color = { r=0.1, b=0.1, g=0.4, a=1 }
	Gcairo:RenderBox(120, 120, 770, 310, 0)

    Gcairo.style.button_color = { r=1, g=1, b=1, a=1 }
    Gcairo:RenderBox(120, 185, 770, 1, 0)

    Gcairo.style.button_color = saved
	
	local left = 600
	local top  = 130
	
	Gcairo:ButtonImage("icon_win", self.icon_windows, left + 70, top, WinConfig )
	Gcairo:ButtonImage("icon_android", self.icon_android, left + 70 + 50 * 1, top, WinConfig )
	Gcairo:ButtonImage("icon_blackberry", self.icon_blackberry, left + 70 + 50 * 2, top, WinConfig )
	Gcairo:ButtonImage("icon_ubuntu", self.icon_ubuntu, left + 70 + 50 * 3, top, WinConfig )
	
	Gcairo:RenderText(self.current, left + 160, top - 20, 22, tcolor )

    Gcairo:RenderText(projectName, left - 440, top + 40, 30, tcolor )
    Gcairo:RenderText("3D Renderer", left - 400, 240, 20, tcolor )
    Gcairo:RenderText("Generate Thumbnail", left - 400, 270, 20, tcolor )
    Gcairo:RenderText("Auto Asset Convert", left - 400, 300, 20, tcolor )
    Gcairo:RenderText("Occulus Rift Support", left - 400, 380, 20, tcolor )

    Gcairo.style.button_color = { r=0.0, g=0.0, b=0.0, a=1 }
    local tbox = Gcairo:TextBox("assetPath", left - 140, 225, 320, 20, assetPath, tcolor)
    Gcairo:RenderBox(left - 140, 225, 320, 20, 0)
    self.image3.scalex = 0.4; self.image3.scaley = 0.4
    Gcairo:ButtonImage("icon3", self.image3, left + 180, 222, AddPathToProject )

    -- TODO: Make a generic toggle widget for this stuff - this is messy
    ----------------------------------------------------------------------
    self.image4.scalex = 0.4; self.image4.scaley = 0.4
    self.image2.scalex = 0.4; self.image2.scaley = 0.4
    local drawicon1, drawicon2, drawicon3, drawicon4 = self.image2, self.image2, self.image2, self.image2
    -- Update project status for the toggles
    local renderer = gCurrProjectInfo.byt3dProject.projectInfo.renderer3d
    if renderer == nil then renderer = 0 end
    if renderer == 1 then drawicon1 = self.image4 end
    local hit1 = Gcairo:RenderImage(drawicon1, left-440, 220, 0.0, 1)
    if self.last_buttons[1] == true and buttons[1] == false and hit1 == true then
        gCurrProjectInfo.byt3dProject.projectInfo.renderer3d = 1-renderer
    end

    local gen_thumbnail = gCurrProjectInfo.byt3dProject.projectInfo.genThumbnail
    if gen_thumbnail == nil then gen_thumbnail = 0 end
    if gen_thumbnail == 1 then drawicon2 = self.image4 end
    local hit2 = Gcairo:RenderImage(drawicon2, left-440, 250, 0.0, 1)
    if self.last_buttons[1] == true and buttons[1] == false and hit2 == true then
        gCurrProjectInfo.byt3dProject.projectInfo.genThumbnail = 1-gen_thumbnail
    end

    local auto_convert = gCurrProjectInfo.byt3dProject.projectInfo.autoAssetConv
    if auto_convert == nil then auto_convert = 0 end
    if auto_convert == 1 then drawicon3 = self.image4 end
    local hit3 = Gcairo:RenderImage(drawicon3, left-440, 280, 0.0, 1)
    if self.last_buttons[1] == true and buttons[1] == false and hit3 == true then
        gCurrProjectInfo.byt3dProject.projectInfo.autoAssetConv = 1-auto_convert
    end

    local occulus_support = gCurrProjectInfo.byt3dProject.projectInfo.occulusRift
    if occulus_support == nil then occulus_support = 0 end
    if occulus_support == 1 then drawicon4 = self.image4 end
    local hit4 = Gcairo:RenderImage(drawicon4, left-440, 360, 0.0, 1)
    if self.last_buttons[1] == true and buttons[1] == false and hit4 == true then
        gCurrProjectInfo.byt3dProject.projectInfo.occulusRift = 1-occulus_support
    end

    ----------------------------------------------------------------------

    Gcairo.style.button_color =  { r=0.0, g=0.3, b=0.1, a=1 }
    -- Add a project list of folders that the project looks for assets in
    -- A Content window of 'stuff' to show
    local datapaths = gCurrProjectInfo.byt3dProject.projectInfo.datafolders
    -- This is nice.. should have done this ages ago!!
    Gcairo:PanelListText("Project Asset Paths", left-140, 250, 20, 18, 320, 120, datapaths)

    Gcairo:RenderText("byt3d", 120, 70, 30, tcolor )
	Gcairo:RenderText(BYT3D_VERSION, 120, 100, 11, tcolor)
	Gcairo:RenderText("www.gagagames.com", self.width - 250, self.height - 30, 20, tcolor )
	
	--Dont have to render a button to have an active element attached to it!
	local button = Gcairo:Button( "httplink", self.width-250, self.height-50, 200, 20, 0, 0, LaunchLink)
	--Gcairo:RenderButton(button, 0.0)
	
	Gcairo:ButtonImage("icon_close", self.image2, self.width - 32, 8, ExitConfigManager )
	Gcairo:ButtonImage("icon1_next", self.image1, self.width - 200, self.height-220, EditWorld )

	Gcairo:Update(mxi, myi, buttons)
    assetPath = tbox.data
    self.last_buttons = { buttons[1], buttons[2], buttons[3] }
end

------------------------------------------------------------------------------------------------------------


function SconfigPlatform:Render()
	
	Gcairo:Render()	
end

------------------------------------------------------------------------------------------------------------


function SconfigPlatform:Finish()	

	
end

------------------------------------------------------------------------------------------------------------



return SconfigPlatform

------------------------------------------------------------------------------------------------------------
