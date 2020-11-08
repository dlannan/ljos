--
-- Created by David Lannan - copyright 2013
-- Developed for the Byt3D project. byt3d.codeplex.com
-- User: dlannan
-- Date: 7/03/13
-- Time: 11:15 PM
--


------------------------------------------------------------------------------------------------------------
-- State - Folder Asset List selection (this is generated and stored in cache)
--
-- Description: Displays a simple Asset selection panel
--			   Creates a slideout panel from the right that has
--              a simplified asset browser and filter.
--              Only allows selection of a folder, and set the panel name to match

------------------------------------------------------------------------------------------------------------

local dir       = require("byt3d/scripts/utils/directory")
local fileio    = require("byt3d/scripts/utils/fileio")
require("byt3d/scripts/states/editor/asset_filters")

------------------------------------------------------------------------------------------------------------

local PEditorAssetList = NewState()

------------------------------------------------------------------------------------------------------------

ASSET_LIST_INACTIVE     = 0
ASSET_LIST_SLIDEOUT     = 1
ASSET_LIST_ACTIVE       = 2
ASSET_LIST_SLIDEIN      = 3

------------------------------------------------------------------------------------------------------------

PEditorAssetList.LUA_FILTER     = 0x00000001
PEditorAssetList.MESH_FILTER    = 0x00000002
PEditorAssetList.TEX_FILTER     = 0x00000004
PEditorAssetList.SVG_FILTER     = 0x00000008

------------------------------------------------------------------------------------------------------------

PEditorAssetList.FilterMap = {
    lua =       PEditorAssetList.LUA_FILTER,
    gsl =       PEditorAssetList.LUA_FILTER,

    dae =       PEditorAssetList.MESH_FILTER,
    obj =       PEditorAssetList.MESH_FILTER,

    png =       PEditorAssetList.TEX_FILTER,
    jpg =       PEditorAssetList.TEX_FILTER,

    svg =       PEditorAssetList.SVG_FILTER
}

------------------------------------------------------------------------------------------------------------

PEditorAssetList.started   = ASSET_LIST_INACTIVE

------------------------------------------------------------------------------------------------------------
local ASSETPANEL_WIDTH      = 300.0

local collectfiles          = nil
------------------------------------------------------------------------------------------------------------

function AssetListToggle(callerobj)
    local toggle_info = callerobj.meta
    local filter_mask = toggle_info.this.filterMask

    -- get the bit from the filter mask, toggle it.
    local bitstate = bit.band( filter_mask, toggle_info.mask)
    local toggle = toggle_info.mask-bitstate
    local clearmask = bit.bnot( toggle_info.mask )
    filter_mask = bit.band(filter_mask, clearmask) + toggle

    callerobj.meta.this.filterMask = filter_mask
    -- print("AssetMask: ", bit.tohex(filter_mask), bit.tohex(toggle))
end

------------------------------------------------------------------------------------------------------------

function AssetListFolderSelected(callerobj)

    gFolderSelected = Gcairo.currdir
--    callerobj.meta:Close()
    callerobj.meta.started = ASSET_LIST_SLIDEIN
end

------------------------------------------------------------------------------------------------------------

function AssetListFolderCancel(callerobj)

    gFolderSelected = nil
--    callerobj.meta:Close()
    callerobj.meta.started = ASSET_LIST_SLIDEIN
end

------------------------------------------------------------------------------------------------------------

function AssetListSlideDone(obj, name)

    if name == "PanelLeft" then
        obj.tween = nil
        obj.started = ASSET_LIST_ACTIVE
    end

    if name == "PanelRight" then
        obj:Finish()
    end
end

------------------------------------------------------------------------------------------------------------

function PEditorAssetList:Close()
    self.started = ASSET_LIST_SLIDEIN
    self.tween 	= tween(0.5, self.panel_move, { pos=0.0 }, 'outExpo', AssetListSlideDone, self, "PanelRight")
end

------------------------------------------------------------------------------------------------------------

function PEditorAssetList:Begin()

    Gcairo.file_FileSelect 	= nil
    Gcairo.file_LastSelect	= nil
    Gcairo.currdir		= "byt3d"
    Gcairo.dirlist		= nil

    -- Both the cache update button _and_ the cache 'updating' indicator. If its not spinning, it can
    -- be pressed and restart the cache.
    self.img_refresh = Gcairo:LoadImage("icon_refresh", "byt3d/data/icons/generic_obj_refresh_64.png")
    self.img_refresh.scalex = 0.3; self.img_refresh.scaley = 0.3

    self.img_close = Gcairo:LoadImage("icon_close", "byt3d/data/icons/generic_64.png")
    self.img_close.scalex = 0.3; self.img_close.scaley = 0.3

    self.img_f_lua = Gcairo:LoadImage("icon_f_lua", "byt3d/data/icons/generic_obj_doc_64.png")
    self.img_f_lua.scalex = 0.3; self.img_f_lua.scaley = 0.3
    self.img_f_mesh = Gcairo:LoadImage("icon_f_lua", "byt3d/data/icons/generic_obj_mesh_64.png")
    self.img_f_mesh.scalex = 0.3; self.img_f_mesh.scaley = 0.3
    self.img_f_tex = Gcairo:LoadImage("icon_f_lua", "byt3d/data/icons/generic_obj_image_64.png")
    self.img_f_tex.scalex = 0.3; self.img_f_tex.scaley = 0.3
    self.img_f_svg = Gcairo:LoadImage("icon_f_lua", "byt3d/data/icons/generic_obj_home_64.png")
    self.img_f_svg.scalex = 0.3; self.img_f_svg.scaley = 0.3
    --print("Starting AssetManager....")

    self.panel_move = { pos = 0.0 }
    self.tween 	= tween(0.5, self.panel_move, { pos=ASSETPANEL_WIDTH }, 'outExpo', AssetListSlideDone, self, "PanelLeft")
    self.started    = ASSET_LIST_SLIDEOUT
    self.refresh    = 0.0

    -- Cache state is whether the cache needs updating or not.
    --   The cache is a little simplistic, in that it looks at the timestamps of cache files, and
    --   timestamps of source files, and if they differ by more than 2 minutes, they will update.
    --   A cache update button will force a cache flush on all files.
    self.cache_state = 0

    -- File filters
    -- TODO: Make this more accessible and dynamic for the users to choose
    self.filters = {
        lua     = AssetFilterLua,
        gls     = AssetFilterLua,       -- GLSL OpenGLES shaders in Lua script.

        dae     = AssetFilterMesh,
        obj     = AssetFilterMesh,
        lwo     = AssetFilterMesh,      -- Lightwave Object
        lws     = AssetFilterMesh,      -- Lightwave Scene
        cob     = AssetFilterMesh,      -- TrueSpace Object
        scn     = AssetFilterMesh,      -- TrueSpace Scene

        ter     = AssetFilterTerrain,   -- Terragen Terrain - this needs to be treated differently.

        png     = AssetFilterTexture,
        jpg     = AssetFilterTexture,   -- JPEG Images supported via Cairo (TODO: need testing)

        wav     = AssetFilterAudio,
        mp3     = AssetFilterAudio,     -- Apparently SDL supports MP3 as well (TODO: need testing)

        svg     = AssetFilterSVG
    }

    collectfiles = coroutine.create( self.CollectAllFiles )
    self.assetlist = {}

    -- Get the filter mask for the project
    self.filterMask = gCurrProjectInfo.byt3dProject.projectInfo.filterMask
    -- 16 filter types should be enough for anyone!!! (famous last words)
    if self.filterMask == nil then self.filterMask = 0xFFFF end
    self.oldFilterMask = self.filterMask

    self.select = 1
    self.selected_asset = nil
    self.selected_type  = nil
    self.selected_image = nil

    self.oldbutton = 0
end

------------------------------------------------------------------------------------------------------------
-- Using the project folders collect all the know source files that can be built/used
--  in a project and build a cache for them.
-- Some file types dont need caching (like scripts, shaders and similar) these are instantaneous files
--  and are compiled into the project's output as is.
-- Others like meshes, terrain, svgs and some textures can be cached and are saved in binary format in the
--  cache folder.

function RefreshFiles(callerobj)

    collectfiles = coroutine.create( callerobj.meta.CollectAllFiles )
    callerobj.meta.cache_state  = 0
    callerobj.meta.assetlist    = {}
end

------------------------------------------------------------------------------------------------------------
-- Callerobj has meta data that points to the asset list object
function SelectedAsset( callerobj )

    local assetlist = callerobj.meta.alist
    local sfile = callerobj.meta.sfile
    local sext  = dir:getextension(sfile)
    local exttype = assetlist.FilterMap[sext]

    -- print(sfile, sext, exttype, assetlist.SVG_FILTER, assetlist.MESH_FILTER)

    if exttype == assetlist.MESH_FILTER or exttype == assetlist.SVG_FILTER then
        assetlist.selected_asset = sfile
        assetlist.selected_type  = exttype
        assetlist.selected_image = callerobj.meta.image
    end
end

------------------------------------------------------------------------------------------------------------

function PEditorAssetList_CB()
    coroutine.yield()
end

------------------------------------------------------------------------------------------------------------

function PEditorAssetList:PanelAssetIcons(left)

    -- The new list object for displaying all the icons.
    local asseticons = Gcairo:List("asset_icons", 0, 0, ASSETPANEL_WIDTH, Gcairo.HEIGHT - 80)
    local tbl = {}

    -- Go through the asst list - if it has an icon, then show it or show name.
    for k,v in pairs(self.assetlist) do

        local lineobjs = {}

        local origname = gCache:GetFile(v)
        local localname = origname
        local fext = dir:getextension(localname)
        if( fext ~= "png" ) then
            localname = string.gsub(origname, "%.", "_").."_icon.png"
        end

        Gcairo:ListAddSpace(lineobjs, 10)
        if fileio:exists(localname) == true then
            local img = Gcairo:LoadImage("icon_"..tostring(k), localname)
            local alist = self
            local meta = { alist=alist, sfile=origname, image=img }
            local linedata = Gcairo:ListAddImage(lineobjs, "image_"..tostring(k), img, 32, CAIRO_STYLE.WHITE, SelectedAsset, meta)
        end

        Gcairo:ListAddSpace(lineobjs, 10)
        Gcairo:ListAddText(lineobjs, dir:getfilename(origname), 12)
        Gcairo:ListAddLine(tbl, lineobjs, "line_"..tostring(k), 48)

        local lineobjs2 = {}
        Gcairo:ListAddText(lineobjs2, " ", 10)
        Gcairo:ListAddLine(tbl, lineobjs2, "line_"..tostring(k*100), 40)
    end

    asseticons.nodes = tbl
    Gcairo:Panel(" Assets", left + 2, 40, 12, 0, asseticons)
end

------------------------------------------------------------------------------------------------------------

function PEditorAssetList:CollectAllFiles()

    local datafolders = gCurrProjectInfo.byt3dProject.projectInfo.datafolders
    -- Collect all the appropriate files (as specified in the filter)
    self.allfiles = {}
    local templist = {}
    for k,v in pairs(datafolders) do
        -- templist = dir:listfolder(v, templist, 1, PEditorAssetList_CB)
        templist = gCache:CheckCacheFolder(v, templist, PEditorAssetList_CB)
    end

    -- Filter the list - this should be quick but we can use coroutines to keep the refresh icon
    --   spinning.
    for k,v in pairs(templist) do
        local ext = dir:getextension(v.name)
        if( self.filters[ext] ~= nil ) then
            local mask = self.FilterMap[ext]
            if bit.band(self.filterMask, mask) > 0 then
                --print(k,v.name, v.path)
                table.insert(self.assetlist, v.source)
            end
            table.insert(self.allfiles, v.source)
        end
        coroutine.yield()
    end

    self.cache_state = 1
end

------------------------------------------------------------------------------------------------------------

function PEditorAssetList:FilterAssetList( )

    -- No changes then dont bother trying to update the list!!
    if self.oldFilterMask == self.filterMask then return end
    if self.cache_state == 0 then return end

    local newlist = {}
    for k,v in pairs(self.allfiles) do
        local ext = dir:getextension(v)
        if( self.filters[ext] ~= nil ) then
            local mask = self.FilterMap[ext]
            if bit.band(self.filterMask, mask) > 0 then
                table.insert(newlist, v)
            end
        end
    end
    self.assetlist = newlist
end

------------------------------------------------------------------------------------------------------------

function PEditorAssetList:SetImageStyle( source )

    if bit.band(self.filterMask, source) > 0 then
        Gcairo.style.image_color.a=1.0
    else
        Gcairo.style.image_color.a=0.2
    end
end

------------------------------------------------------------------------------------------------------------

function PEditorAssetList:AddModel( filename, pos )
    -- The mesh should convert the model to binary - to be used afterwards
    local tmodel = LoadModel(filename)
    tmodel:SetMeshProperty("priority", byt3dRender.OPAQUE)
    tmodel.node.transform:Position(pos[1], pos[2], pos[3])

    local newtex = byt3dTexture:New()
    newtex:NewColorImage( {255.0, 0.0, 255.0, 255.0} )

    local newshader = byt3dShader:NewProgram(colour_shader_vert, colour_shader_frag)
    newshader.name = "Shader_Default"

    tmodel:SetMeshProperty("shader", newshader)
    tmodel:SetSamplerTex(newtex, "s_tex0")
    return tmodel
end

------------------------------------------------------------------------------------------------------------

function PEditorAssetList:Update(mxi, myi, buttons)

    if self.cache_state == 0 then
        coroutine.resume(collectfiles, self)
    end

    local tcolor = { r=1.0, b=1.0, g=1.0, a=1.0 }
    local saved = Gcairo.style.button_color

    local left = Gcairo.WIDTH - self.panel_move.pos
    Gcairo.style.button_color = { r=0.2, g=0.6, b=0.2, a=0.9 }
    Gcairo:RenderBox(left, 1, ASSETPANEL_WIDTH, Gcairo.HEIGHT-2, 0)

    Gcairo.style.button_color = { r=1, g=1, b=1, a=1 }
    Gcairo:RenderBox(left, 28, ASSETPANEL_WIDTH, 1, 0)

    -- Cache updater - this needs to check the cache state externally
    -- TODO: Make the cache statemanager that looks after these files
    if self.cache_state == 0 then
        Gcairo:RenderImage(self.img_refresh, left + 47, 15, self.refresh)
        self.refresh = self.refresh + 0.2
    else
        Gcairo:ButtonImage("button_refresh", self.img_refresh, left+37, 5, RefreshFiles, self )
    end

    -- Close the panel manually
    Gcairo:ButtonImage("button_close", self.img_close, left+7, 5, AssetListFolderCancel, self )

    -- Render the toggle buttons based on their toggle state. Each button has its own bitmask
    local image_saved = Gcairo.style.image_color.a
    self:SetImageStyle(self.LUA_FILTER)
    Gcairo:ButtonImage("button_filter_lua", self.img_f_lua, left+67, 5, AssetListToggle, { this=self, mask=self.LUA_FILTER } )
    self:SetImageStyle(self.MESH_FILTER)
    Gcairo:ButtonImage("button_filter_mesh", self.img_f_mesh, left+97, 5, AssetListToggle, { this=self, mask=self.MESH_FILTER } )
    self:SetImageStyle(self.TEX_FILTER)
    Gcairo:ButtonImage("button_filter_tex", self.img_f_tex, left+127, 5, AssetListToggle, { this=self, mask=self.TEX_FILTER } )
    self:SetImageStyle(self.SVG_FILTER)
    Gcairo:ButtonImage("button_filter_svg", self.img_f_svg, left+157, 5, AssetListToggle, { this=self, mask=self.SVG_FILTER } )
    Gcairo.style.image_color.a=image_saved

    self:FilterAssetList()
    Gcairo.style.button_color = { r=0.2, g=0.6, b=0.2, a=0.4 }

    -- Generate the panel
    -- Gcairo:PanelListText(" Assets", left + 2, 40, 12, 11, ASSETPANEL_WIDTH,  Gcairo.HEIGHT-80, self.assetlist)

    -- Make a panel that displays icons if available - auto size.. and so on.
    self:PanelAssetIcons(left)

    Gcairo.style.button_color = saved

    -- Save the last filter mask so we can check for changes (only update on change)
    if self.cache_state > 0 then
        self.oldFilterMask = self.filterMask
    end

    -- Button released event
    if buttons[1] == true and self.oldbutton == false and self.selected_image then

        -- Put the object in the world!!!
        -- If SVG then add to the Interface Render in the Level
        if( self.selected_type == self.SVG_FILTER ) then

            local svgdata = Gcairo:LoadSvg(self.selected_asset)
            svgdata.pos = { x=mxi, y=myi }
            Gcairo:AddSvg(svgdata)
            self:Close()

        -- If Mesh then add to the world with position as a ray trace
        elseif( self.selected_type == self.MESH_FILTER ) then

            local pos = { 0.0, 0.0, 0.0 }
            self.model = self:AddModel(self.selected_asset, pos)
            self:Close()
        end

        self.selected_asset = nil
        self.selected_type  = nil
        self.selected_image = nil
    end

    if self.selected_image then

        Gcairo:RenderImage(self.selected_image, mxi  * Gcairo.mouseScaleX - 16, myi * Gcairo.mouseScaleY - 16, 0)
    end

    self.oldbutton = buttons[1]
end

------------------------------------------------------------------------------------------------------------

function PEditorAssetList:Render()

end

------------------------------------------------------------------------------------------------------------

function PEditorAssetList:Finish()
    self.tween = nil
    self.started = ASSET_LIST_INACTIVE

    -- write out the filtermask
    gCurrProjectInfo.byt3dProject.projectInfo.filterMask = self.filterMask
end

------------------------------------------------------------------------------------------------------------

return PEditorAssetList

------------------------------------------------------------------------------------------------------------