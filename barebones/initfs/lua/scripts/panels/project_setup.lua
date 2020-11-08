------------------------------------------------------------------------------------------------------------
-- State - Project Setup state panel
--
-- Description: Displays the project setup panel
--			   

------------------------------------------------------------------------------------------------------------

local dir = require("scripts/utils/directory")
local xml = require("scripts/utils/xml-reader")

local profiledata = require("scripts/states/editor/profile")

------------------------------------------------------------------------------------------------------------

local SProjectSetup	= NewState()

------------------------------------------------------------------------------------------------------------
-- Global temps.. TODO: will remove these 

gCurrProjectInfo    = nil
gProjectFile		= nil
gErrorLine			= nil

------------------------------------------------------------------------------------------------------------

function SelectProject( obj )

    gProjectFile = obj.name
    local ext = dir:getextension(obj.name)
    projectName = string.gsub(obj.name, "."..ext, "")
end

------------------------------------------------------------------------------------------------------------

function CreateProject()

	-- TODO: Put a trace/exception here.. force people to name their projects
	if gProjectFile == nil then 
		gErrorLine = "Create Error: No Project Name."
		return 
    end
    gCurrProjectInfo = profiledata

	-- Cannot create projects without proper name - notify user
	SaveXml( gProjectFile..".xml", profiledata, "byt3dProject" )
	sm:JumpToState("CfgPlatform")
end

------------------------------------------------------------------------------------------------------------
-- Attempt to load in the project ready for modification
--
--    Note: The project file is parsed but not all objects are loaded until the "modify" button is pressed

function ModifyProject()

	if gProjectFile == nil then 
		gErrorLine = "Modify Error: No Project Selected."
		return 
    end
    gCurrProjectInfo = LoadXml(gProjectFile..".xml")
	sm:JumpToState("CfgPlatform")
end

------------------------------------------------------------------------------------------------------------

function ExitProjectConfig()

	sm:ExitState()
end

------------------------------------------------------------------------------------------------------------

function ConfigPlatform()

	if gProjectFile == nil then 
		gErrorLine = "Configure Error: No Project Selected."
		return 
	end
    gCurrProjectInfo = LoadXml(gProjectFile..".xml")
	sm:JumpToState("CfgPlatform")
end

------------------------------------------------------------------------------------------------------------

function	errorTimeDone(obj)

	obj.tween 	= nil
	gErrorLine 	= nil
end

------------------------------------------------------------------------------------------------------------

function SProjectSetup:Begin()

	Gcairo.file_FileSelect 	= nil
	Gcairo.file_LastSelect	= nil
	Gcairo.currdir			= "byt3d/data/projects"

	Gcairo.file_NewFolder 	= nil

	-- This can be modified per project - defines root level project directory.
	Gcairo.dirlist			= nil
	Gcairo.select_file		= -1
	
	self.ExtensionFunc	= {
	
		byt3d 	= { func=self.LoadProject, obj=self }
	}
	
	Gcairo:SetExtensionCallbacks(self.ExtensionFunc)
	
	self.img_missing    	= Gcairo:LoadImage("icon_image", "byt3d/data/icons/generic_obj_image_thumb_64.png", 1)

	self.image2 			= Gcairo:LoadImage("icon_close", "byt3d/data/icons/generic_obj_close_64.png")
	self.image2.scalex 		= 0.35
	self.image2.scaley 		= 0.35
    self.image3 			= Gcairo:LoadImage("icon2", "byt3d/data/icons/generic_obj_tick_64.png")
    self.image3.scalex 		= 0.6
    self.image3.scaley 		= 0.6

	self.icon_windows 		= Gcairo:LoadImage("icon_windows", "byt3d/data/icons/small/config_windows.png", 1)
	self.icon_android 		= Gcairo:LoadImage("icon_android", "byt3d/data/icons/small/config_android.png", 1)
	self.icon_blackberry 	= Gcairo:LoadImage("icon_bb", "byt3d/data/icons/small/config_blackberry.png", 1)
	self.icon_ubuntu 		= Gcairo:LoadImage("icon_bb", "byt3d/data/icons/small/config_ubuntu.png", 1)
	
	projectName = ""
	print("ProjectName:",projectName)
	
	self.errorTime 	= 8.0
	gErrorLine 		= nil
    self.thumbnailCache = {}
end

------------------------------------------------------------------------------------------------------------
-- The project list is a list of names of projects (in the project files) and thumbnails.
--    	Thumbnails can be generated or simply added to the project folder.
--		Requirements: thumbnail must be png, and must be set in the configuration page.
--					  the config panel can generate or "look for" a picture to set as the thumbnail for the project.
 
function SProjectSetup:RenderProjectList(left, top, width, height, tcolor)

	local dirlist = nil
	if Gcairo.currdir == nil then return end
	if dirlist == nil then dirlist = dir:listfolder(Gcairo.currdir) end
	
	-- A Content window of 'stuff' to show
	local list_assets = Gcairo:List("", 0, 0, width-10, height-20)
	Gcairo:RenderBox(left, top, width, height, 0)
	local snodes = {}
	local i = 1
	snodes[i] = { name="space1", size=12 }; i=i+1
	
	local line1 = {
			{ name="space1", size=18 }
	}

    local selected = nil
	-- grab the xml files - thats all we care about.
	for k,v in pairs(dirlist) do

		local nline1 = {
			 { name="space1", size=12 },
			 { name=v.name, ftype=v.ftype, ntype=CAIRO_TYPE.TEXT, size=20 }
		}
		
		local nline2 = { 
			 { name="space1", size=80 },
			 { name="space1", size=18 }
        }

        local extname = dir:getextension(v.name)

        -- Try loading in the project
        -- Thumbnails are cached - otherwise the iface slows down horribly
        -- TODO: Make the rendering for a list better - only update the viewable elements
        if self.thumbnailCache[v.name] == nil then

            self.thumbnailCache[v.name] = self.img_missing

            if extname == "xml" then
                local proj_info = LoadXml("byt3d/data/projects/"..v.name)
                if proj_info ~= nil then

                    local prj = proj_info.byt3dProject.projectInfo
                    if prj.thumbnail ~= "nil" and prj.thumbnail ~= nil then

                        local iimage = Gcairo:LoadImage(prj.name.."_icon", prj.thumbnail, 1)
                        if iimage ~= nil then
                            iimage.height = iimage.height * 1.3
                            self.thumbnailCache[v.name] = iimage
                        end
                    end
                end
            end
        end

        local cacheimg = self.thumbnailCache[v.name]
        local newline = { name=v.name, ntype=CAIRO_TYPE.IMAGE, image=cacheimg, size=80,
                                        color=tcolor, callback=SelectProject, meta=self }
	    nline2[2] = newline
		
		local nline1ref = { name="line2", ntype=CAIRO_TYPE.HLINE, size=18, nodes = nline1 }
		local nline2ref = { name="line2", ntype=CAIRO_TYPE.HLINE, size=18, nodes = nline2 }

		if v.name ~= "." and v.name ~= ".." then

			-- Found an xml project file? Check it, get project name and thumbnail name
			if extname == "xml" then

				--local xmldata = LoadXml(Gcairo.currdir.."/"..v.name)
				snodes[i] = nline1ref; i=i+1
				snodes[i] = nline2ref; i=i+1
			end
        end

        if projectName..".xml" == v.name then selected = i-1 end
	end
	
	snodes[i] =	{ name = "space1", size=22 }; i=i+1
	snodes[i] =	{ name = "line1", ntype=CAIRO_TYPE.HLINE, size=18 , nodes=line1 }; i=i+1
	list_assets.nodes = snodes

	Gcairo:Panel("prj_list", left, top+10, 0, 0, list_assets, selected )
end

------------------------------------------------------------------------------------------------------------

function SProjectSetup:RenderConfigure(left, top, width, height)

	local tcolor = { r=1.0, b=1.0, g=1.0, a=1.0 }
	
	-- A Content window of 'stuff' to show
	local list_assets = Gcairo:List("cfg_list1", left, top, 120, height - 20)
	local snodes = {}
	local i = 1
	
	Gcairo.style.button_color = { r=0.3, b=0.3, g=0.3, a=1 }
	Gcairo:RenderBox(left, top, width, height, 0)
	local icons = { self.icon_windows, self.icon_android, self.icon_blackberry, self.icon_ubuntu }
	Gcairo:RenderMultiSlideImage("prj_configure", icons, left, 180, width, 3.0, 1.5, nil)
	local cfgbutton = Gcairo:Button( "cfg", left, top, width, height, 0, 0, ConfigPlatform)
	
	Gcairo:RenderText("Configure", 770, height, 20, tcolor )
end

------------------------------------------------------------------------------------------------------------

function SProjectSetup:Update(mxi, myi, buttons)

	if(string.len(projectName) > 0) then
		profiledata.projectInfo.name = projectName
		gProjectFile = Gcairo.currdir.."/"..projectName
	else
		gProjectFile = nil
	end
	
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
	Gcairo.style.button_color = { r=0.75, b=0.1, g=0.75, a=1 }
	Gcairo:RenderBox(120, 120, 250, 310, 0)
	Gcairo:RenderText("Create", 140, 170, 20, tcolor )
	local createbutton = Gcairo:Button( "create", 140, 150, 200, 20, 0, 0, CreateProject)
	Gcairo:RenderText("Modify", 140, 260, 20, tcolor )
	local modifybutton = Gcairo:Button( "modify", 140, 240, 200, 20, 0, 0, ModifyProject)
	Gcairo:RenderText("Play", 140, 390, 20, tcolor )
	
	-- Animated images?
	--Gcairo:RenderMultiImage("MS_start", { self.icon1, self.icon2, self.icon3 }, 260, 170, 4.0, 1.0, StartEditor)
	Gcairo.style.button_color = { r=0.9, b=0.1, g=0.3, a=1 }
	-- Get a list of projects and display them in a "image + name" list.
	local lcolor = { r=0.6, g=0.4, b=0.4, a=1.0 }
	self:RenderProjectList(380, 120, 250, 310, lcolor)

	-- Configure
	self:RenderConfigure(640, 120, 250, 150)
	
	-- Tutorials
	Gcairo.style.button_color = { r=0.15, g=0.1, b=0.5, a=1 }
	Gcairo:RenderBox(640, 280, 250, 150, 0)
	
	-- Animated images?
	Gcairo:RenderMultiImage("MS_tutorial", { self.icon10, self.icon11, self.icon12 }, 750, 325, 2.3, 0.67, nil)
	Gcairo:RenderText("Project Name", 660, 315, 20, tcolor )
	
	Gcairo.style.button_color = { r=0.0, g=0.0, b=0.0, a=1 }
	local tbox = Gcairo:TextBox("projectName", 660, 330, 210, 20, projectName, tcolor)
	Gcairo:RenderBox(660, 330, 210, 20, 0)
	
	if gErrorLine then
		if self.tween == nil then
			self.error_display 	= { timelen = 0.0 }
			self.errorTime		= 8.0
			self.tween = tween(self.errorTime, self.error_display, { timelen = 0.0 }, 'inExpo', errorTimeDone, self) 
		end 
		Gcairo.style.button_color = { r=0.4, g=0.0, b=0.0, a=1 }
		Gcairo:RenderBox(120, self.height - 120-15, 770, 20, 0)
		Gcairo:RenderText(gErrorLine, 130,  self.height - 120, 14, tcolor )
	end
	
	Gcairo:RenderText("byt3d", 120, 70, 30, tcolor )
	Gcairo:RenderText(BYT3D_VERSION, 120, 100, 11, tcolor)
	Gcairo:RenderText("www.gagagames.com", self.width - 250, self.height - 30, 20, tcolor )
	
	--Dont have to render a button to have an active element attached to it!
	local button = Gcairo:Button( "httplink", self.width-250, self.height-50, 200, 20, 0, 0, LaunchLink)	
	Gcairo:ButtonImage("icon_close", self.image2, self.width - 32, 8, ExitProjectConfig )
	
	Gcairo:Update(mxi, myi, buttons)
	
	if tbox.changed then projectName = tbox.data end
end

------------------------------------------------------------------------------------------------------------

function SProjectSetup:Render()
	
	Gcairo:Render()		
end

------------------------------------------------------------------------------------------------------------

function SProjectSetup:Finish()

end
	
------------------------------------------------------------------------------------------------------------

return SProjectSetup

------------------------------------------------------------------------------------------------------------