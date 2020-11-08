------------------------------------------------------------------------------------------------------------
-- State - AssetManager
--
-- Decription: Display Asset list found in Project asset directory/ies
-- 				Ability to tag/untag assets (with own label / tag)
--				Ability to include/exclude assets from a project target (project targets can be user defined)
--				Packaging of assets
--				Exporting of assets to new folder (usually for collation & testing)
-- 			    Stream packaging (specific for streaming support)
--				Reference testing and validation (see if an asset is in use anywhere in the project)
------------------------------------------------------------------------------------------------------------

local SassetMgr	= NewState()

-- Need to now add a global interface to the manager for all asset pool handling.
-- Should be defined externally at the root level of the WSE. All apps, and editors will need access
-- to it. This AssetManager is only a viewer of filesystem <-> asset mapping

------------------------------------------------------------------------------------------------------------

SassetMgr.width		= 1024
SassetMgr.height	= 768

-- Scroll in out the screen.. using tween!! tween roxors!!
SassetMgr.top		= SassetMgr.height

-- Dont like this....
gExitApp			= 0

------------------------------------------------------------------------------------------------------------

function PanelSlideDone(obj, name)

	if name == "PanelUp" then
		obj.tween = nil
	end

	if name == "PanelDown" then
		obj.tween = nil
		sm:ExitState()
	end
end

------------------------------------------------------------------------------------------------------------

function SassetMgr:SetTextPreview( docname )

	-- Get doc.. and show first 10 lines.. no need for more (esp if its large doc).
	local mydoc = io.open( Gcairo.currdir.."/"..docname, "r" )
	local lines = {}
	
	if mydoc ~= nil then
		for i=1,50 do
			local txt = mydoc:read("*l")
			-- Convert string to stay in ASCII region
			newtxt = ""
			if txt ~= nil then
			for j=1,string.len(txt) do 
				local v = string.byte(txt, j)
				if v > 128 then v = string.byte("?", 1) end
				local outv = string.char(v)
				newtxt = newtxt..outv
			end
			lines[i] = { name=newtxt, ntype=CAIRO_TYPE.TEXT, size=12 }
			end 
		end
		mydoc:close()
	end
	
	self.preview_obj = lines
	local entry = Gcairo.dirlist[Gcairo.select_file]
	self.preview_props = { dtype="text file", filename=docname, filesize=entry["size"], modify=entry["mtime"] }
end

------------------------------------------------------------------------------------------------------------

function SassetMgr:SetImagePreview( imgname )
		
	print("Preview Image:", imgname, Gcairo.currdir.."/"..imgname)
	if(self.preview_obj ~= nil) then
		if( self.preview_obj.image ~= nil ) then		 
			Gcairo:DeleteImage(self.preview_obj.image)
		end 
	end
	
	local img_obj = Gcairo:LoadImage("icon_preview", Gcairo.currdir.."/"..imgname)	
	local lines = {}
	lines[1] = { name="space1", size=30 }
	lines[2] = { name="preview_line", ntype=CAIRO_TYPE.IMAGE, image=img_obj, size=230, color=tcolor }
	local pobj = {}
	pobj[1] = { name="preview", ntype=CAIRO_TYPE.HLINE, size=18, nodes = lines }
	self.preview_obj = pobj
	self.preview_props = img_obj
end

------------------------------------------------------------------------------------------------------------

function SassetMgr:Begin()
	
	self.image1 	= Gcairo:LoadImage("icon1", "byt3d/data/icons/generic_64.png")
	self.image2 	= Gcairo:LoadImage("icon2", "byt3d/data/icons/generic_obj_close_64.png")
	self.image2.scalex = 0.35
	self.image2.scaley = 0.35

	self.img_image 	= Gcairo:LoadImage("icon_image", "byt3d/data/icons/generic_obj_image_64.png", 1)
	self.img_doc 	= Gcairo:LoadImage("icon_doc", "byt3d/data/icons/generic_obj_doc_64.png", 1)
	self.img_ref 	= Gcairo:LoadImage("icon_ref", "byt3d/data/icons/generic_obj_ref_64.png", 1)
	self.img_movie 	= Gcairo:LoadImage("icon_movie", "byt3d/data/icons/generic_obj_movie_64.png", 1)
	self.img_mesh 	= Gcairo:LoadImage("icon_mesh", "byt3d/data/icons/generic_obj_mesh_64.png", 1)
	
	self.preview_obj 		= nil
	self.preview_props		= nil
	
	Gcairo.file_FileSelect 	= nil
	Gcairo.file_LastSelect	= nil
	Gcairo.currdir		= "byt3d"
	Gcairo.dirlist		= nil

	--print("Starting AssetManager....")

	self.ExtensionFunc	= {
	
		png 	= { func=self.SetImagePreview, obj=self },
		-- jpg = { func=self.SetImagePreview, obj=self },
		lua 	= { func=self.SetTextPreview, obj=self },
		vert 	= { func=self.SetTextPreview, obj=self },
		frag 	= { func=self.SetTextPreview, obj=self },
		txt 	= { func=self.SetTextPreview, obj=self }
	}
	
	self.panel_move = { pos = self.height }
	self.tween 	= tween(0.5, self.panel_move, { pos=0.0 }, 'inExpo', PanelSlideDone, self, "PanelUp")	
	
	Gcairo:SetExtensionCallbacks(self.ExtensionFunc)
end

------------------------------------------------------------------------------------------------------------

function ExitAssetManager(callerobj)

	gExitApp = 1
end

------------------------------------------------------------------------------------------------------------

function SassetMgr:RenderMainPanel()

	local panel_list = Gcairo:List("panel_list", 0, 0, self.width-10, self.height-34)

	Gcairo.style.border_width = 0.0
	Gcairo.style.button_color = CAIRO_STYLE.METRO.ORANGE
	Gcairo:Panel(" Asset Manager", 5, self.top + 5, 24, 0, panel_list ) 
end

------------------------------------------------------------------------------------------------------------

function SassetMgr:RenderFolderList()

	Gcairo:RenderDirectory( 10, self.top + 60, 500, self.height-70)
end

------------------------------------------------------------------------------------------------------------

function SassetMgr:RenderTypePanel()

	-- A Content window of 'stuff' to show
	local list_assets = Gcairo:List("typepanel", 0, 0, 200, self.height-90)
	local snodes = {}
	local i = 1
	local nline1 = { 
		 { name="space1", size=6 },
		 { name="image", ntype=CAIRO_TYPE.IMAGE, image=self.img_image, size=18, color=tcolor },
		 { name="space1", size=6 },
		 { name="Images", ntype=CAIRO_TYPE.TEXT, size=18 }
	}
	local nline2 = { 
		 { name="space1", size=6 },
		 { name="doc", ntype=CAIRO_TYPE.IMAGE, image=self.img_doc, size=18, color=tcolor },
		 { name="space1", size=6 },
		 { name="Scripts", ntype=CAIRO_TYPE.TEXT, size=18 }
	}
	local nline3 = { 
		 { name="space1", size=6 },
		 { name="ref", ntype=CAIRO_TYPE.IMAGE, image=self.img_ref, size=18, color=tcolor },
		 { name="space1", size=6 },
		 { name="Reference", ntype=CAIRO_TYPE.TEXT, size=18 }
	}
	local nline4 = { 
		 { name="space1", size=6 },
		 { name="movie", ntype=CAIRO_TYPE.IMAGE, image=self.img_movie, size=18, color=tcolor },
		 { name="space1", size=6 },
		 { name="Movie", ntype=CAIRO_TYPE.TEXT, size=18 }
	}
	local nline5 = { 
		 { name="space1", size=6 },
		 { name="mesh", ntype=CAIRO_TYPE.IMAGE, image=self.img_mesh, size=18, color=tcolor },
		 { name="space1", size=6 },
		 { name="Mesh", ntype=CAIRO_TYPE.TEXT, size=18 }
	}
	local nline6 = { 
		 { name="space1", size=6 },
		 { name="doc", ntype=CAIRO_TYPE.IMAGE, image=self.img_doc, size=18, color=tcolor },
		 { name="space1", size=6 },
		 { name="Shaders", ntype=CAIRO_TYPE.TEXT, size=18 }
	}
	
	snodes[i] = { name="space1", size=6 }; i=i+1
	snodes[i] = { name="line1", ntype=CAIRO_TYPE.HLINE, size=18, nodes = nline1 }; i=i+1
	snodes[i] = { name="space1", size=6 }; i=i+1
	snodes[i] = { name="line2", ntype=CAIRO_TYPE.HLINE, size=18, nodes = nline2 }; i=i+1
	snodes[i] = { name="space1", size=6 }; i=i+1
	snodes[i] = { name="line3", ntype=CAIRO_TYPE.HLINE, size=18, nodes = nline3 }; i=i+1
	snodes[i] = { name="space1", size=6 }; i=i+1
	snodes[i] = { name="line4", ntype=CAIRO_TYPE.HLINE, size=18, nodes = nline4 }; i=i+1
	snodes[i] = { name="space1", size=6 }; i=i+1
	snodes[i] = { name="line5", ntype=CAIRO_TYPE.HLINE, size=18, nodes = nline5 }; i=i+1
	snodes[i] = { name="space1", size=6 }; i=i+1
	snodes[i] = { name="line6", ntype=CAIRO_TYPE.HLINE, size=18, nodes = nline6 }; i=i+1
	
	list_assets.nodes = snodes
	Gcairo.style.button_color = { r=0.6, g=0.4, b=0.4, a=1.0 }
	Gcairo:Panel(" Asset Types", 515, self.top + 60, 20, 0, list_assets ) 
end


------------------------------------------------------------------------------------------------------------

function SassetMgr:RenderPreviewPanel()

	-- A Content window of 'stuff' to show
	Gcairo.style.button_color = { r=0.3, g=0.2, b=0.5, a=1.0 }
	Gcairo:RenderBox(720, self.top+60, 295, 270)
	local list_assets = Gcairo:List("previewlist", 10, 10, 275, 230)
	local snodes = {}
	local i = 1
--print("Preview:", self.preview_obj)
	if self.preview_obj ~= nil then
		for k,v in pairs(self.preview_obj) do
			snodes[i] = v; i=i+1
		end
	end
	list_assets.nodes = snodes

	Gcairo:Panel(" Preview", 720, self.top + 60, 20, 0, list_assets ) 
end

------------------------------------------------------------------------------------------------------------

function SassetMgr:RenderPropertiesPanel()
	-- A Content window of 'stuff' to show
	local list_assets = Gcairo:List("properties", 0, 0, 295, 210)
	local snodes = {}
	local i = 1
	
	snodes[i] = { name="space1", size=6 }; i=i+1	
	if self.preview_obj ~= nil then
		for k,v in pairs(self.preview_props) do
			snodes[i] = { name="  "..tostring(k)..": "..tostring(v), ntype=CAIRO_TYPE.TEXT, size=12 }; i=i+1
		end
	end
	list_assets.nodes = snodes
	
	Gcairo.style.button_color = { r=0.2, g=0.6, b=0.3, a=1.0 }
	Gcairo:Panel(" Properties", 720, self.top + 335, 20, 0, list_assets ) 
end

------------------------------------------------------------------------------------------------------------

function SassetMgr:Update(mxi, myi, buttons)

	local saved = Gcairo.style.button_color
	local tcolor = { r=1.0, b=1.0, g=1.0, a=1.0 }
	
	if gExitApp == 1 then 
		self.tween = tween(0.5, self.panel_move, { pos=self.height }, 'inExpo', PanelSlideDone, self, "PanelDown") 
		gExitApp = 0
	end
	
	self.top = self.panel_move.pos
	Gcairo:Begin()

	self:RenderMainPanel()
	self:RenderTypePanel()
	self:RenderFolderList()
	self:RenderPreviewPanel()
	self:RenderPropertiesPanel()
	
	Gcairo:ButtonImage("icon_close", self.image2, self.width - 32, 8, ExitAssetManager )

	Gcairo.style.button_color = saved
	Gcairo:Update(mxi, myi, buttons)
end

------------------------------------------------------------------------------------------------------------

function SassetMgr:Render()
		
	Gcairo:Render()	
end

------------------------------------------------------------------------------------------------------------

function SassetMgr:Finish()

end
	
------------------------------------------------------------------------------------------------------------

return SassetMgr

------------------------------------------------------------------------------------------------------------
