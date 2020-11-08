--
-- Created by David Lannan
-- User: grover
-- Date: 6/03/13
-- Time: 8:14 PM
-- Copyright 2013  Developed for use with the byt3d engine.
--

------------------------------------------------------------------------------------------------------------
-- State - Asset Manager Panel
--
-- Description: Displays the new AssetManager panel.
--			   Creates a slideout panel from the right that has
--              a simplified asset browser and filter.
--              Additionally, as you browse it converts data to byt3d formats
--              these conversions should go in a cache folder somewhere  -  .byt3d folder?

------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------

local PEditorAssets	= NewState()

------------------------------------------------------------------------------------------------------------

PEditorAssets.started   = 0

------------------------------------------------------------------------------------------------------------
local ASSETPANEL_WIDTH      = 300.0
------------------------------------------------------------------------------------------------------------

function EditorAssetPanelSlideDone(obj, name)

    if name == "PanelLeft" then
        obj.tween = nil
        obj.started = 2
    end

    if name == "PanelRight" then
        obj.tween = nil
        obj.started = 0
    end
end

------------------------------------------------------------------------------------------------------------

function PEditorAssets:SetTextPreview( docname )

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

function PEditorAssets:SetImagePreview( imgname )

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

function PEditorAssets:Begin()

    Gcairo.file_FileSelect 	= nil
    Gcairo.file_LastSelect	= nil
    Gcairo.currdir		= "byt3d/data"
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

    Gcairo:SetExtensionCallbacks(self.ExtensionFunc)

    self.panel_move = { pos = 0.0 }
    self.tween 	= tween(0.5, self.panel_move, { pos=ASSETPANEL_WIDTH }, 'outExpo', EditorAssetPanelSlideDone, self, "PanelLeft")
    self.started   = 1
end

------------------------------------------------------------------------------------------------------------

function PEditorAssets:Update(mxi, myi, buttons)

    local tcolor = { r=1.0, b=1.0, g=1.0, a=1.0 }
    local saved = Gcairo.style.button_color

    Gcairo.style.button_color.a = 0.7
    Gcairo:RenderDirectory( Gcairo.WIDTH - self.panel_move.pos, 0.0, ASSETPANEL_WIDTH, Gcairo.HEIGHT )

    Gcairo.style.button_color = saved
end

------------------------------------------------------------------------------------------------------------

function PEditorAssets:Render()

end

------------------------------------------------------------------------------------------------------------

function PEditorAssets:Finish()
    self.started = 3
    self.tween 	= tween(0.5, self.panel_move, { pos=0.0 }, 'outExpo', EditorAssetPanelSlideDone, self, "PanelRight")
end

------------------------------------------------------------------------------------------------------------

return PEditorAssets

------------------------------------------------------------------------------------------------------------