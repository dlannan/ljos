--
-- Created by David Lannan - copyright 2013
-- Developed for the Byt3D project. byt3d.codeplex.com
-- User: dlannan
-- Date: 7/03/13
-- Time: 11:15 PM
--


------------------------------------------------------------------------------------------------------------
-- State - Folder Select Panel
--
-- Description: Displays a simple Folder selection panel
--			   Creates a slideout panel from the right that has
--              a simplified asset browser and filter.
--              Only allows selection of a folder, and set the panel name to match

------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------

local PEditorFolder = NewState()

------------------------------------------------------------------------------------------------------------

PEditorFolder.started   = 0

------------------------------------------------------------------------------------------------------------
local ASSETPANEL_WIDTH      = 300.0
------------------------------------------------------------------------------------------------------------

function FolderSelected(callerobj)

    gFolderSelected = Gcairo.currdir
    callerobj.meta:Close()
end

------------------------------------------------------------------------------------------------------------

function FolderCancel(callerobj)

    gFolderSelected = nil
    callerobj.meta:Close()
end

------------------------------------------------------------------------------------------------------------

function EditorFolderPanelSlideDone(obj, name)

    if name == "PanelLeft" then
        obj.tween = nil
        obj.started = 2
    end

    if name == "PanelRight" then
        obj.tween = nil
        obj.started = 0
        sm:ExitState()
    end
end

------------------------------------------------------------------------------------------------------------

function PEditorFolder:Close()
    self.started = 3
    self.tween 	= tween(0.5, self.panel_move, { pos=0.0 }, 'outExpo', EditorFolderPanelSlideDone, self, "PanelRight")
end

------------------------------------------------------------------------------------------------------------

function PEditorFolder:Begin()

    -- Screenshot with gui and with save file
    self.bgimage = Gcairo:ScreenShot(1)
    self.bgtex = byt3dTexture:New()
    self.bgtex:FromCairoImage(Gcairo, "bgimage", self.bgimage)

    Gcairo.file_FileSelect 	= nil
    Gcairo.file_LastSelect	= nil
    Gcairo.currdir		= "byt3d"
    Gcairo.dirlist		= nil

    --print("Starting AssetManager....")
    self.bgmesh = byt3dMesh:New()
    self.bgmesh:SetShader(Gcairo.uiShader)

    self.panel_move = { pos = 0.0 }
    self.tween 	= tween(0.5, self.panel_move, { pos=ASSETPANEL_WIDTH }, 'outExpo', EditorAssetPanelSlideDone, self, "PanelLeft")
    self.started   = 1
end

------------------------------------------------------------------------------------------------------------

function PEditorFolder:Update(mxi, myi, buttons)

    local tcolor = { r=1.0, b=1.0, g=1.0, a=1.0 }
    local saved = Gcairo.style.button_color

    Gcairo:Begin()

    Gcairo.style.button_color = { r=0, g=0, b=0, a=0.7 }
    Gcairo:RenderBox(0, 0, Gcairo.WIDTH, Gcairo.HEIGHT, 0)
    Gcairo.style.button_color = saved

    local left = Gcairo.WIDTH - self.panel_move.pos
    Gcairo:RenderText( " Select a folder:", left, 18.0, 18, tcolor)
    Gcairo:RenderDirectory( left, 20.0, ASSETPANEL_WIDTH, Gcairo.HEIGHT-80.0 )

    Gcairo:ButtonText( "Bok", " OK ", left, Gcairo.HEIGHT - 40.0, 18, tcolor, FolderSelected, self)
    Gcairo:ButtonText( "Bcancel", " Cancel ", left + 200, Gcairo.HEIGHT - 40.0, 18, tcolor, FolderCancel, self)
    Gcairo.style.button_color = saved

    Gcairo:Update(mxi, myi, buttons)
end

------------------------------------------------------------------------------------------------------------

function PEditorFolder:Render()

    Gcairo.uiShader:Use()
    self.bgmesh:SetTexture(self.bgtex)
    self.bgmesh:RenderTextureRect(-1, 1, 2, -2)

    Gcairo:Render()
end

------------------------------------------------------------------------------------------------------------

function PEditorFolder:Finish()
end

------------------------------------------------------------------------------------------------------------

return PEditorFolder

------------------------------------------------------------------------------------------------------------