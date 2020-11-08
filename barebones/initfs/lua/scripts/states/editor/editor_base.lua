--
-- Created by David Lannan
-- Date: 5/03/13
-- Time: 7:25 PM
-- Developed for the byt3d engine
--

------------------------------------------------------------------------------------------------------------
-- State - Editor Base
--
-- Decription: Display GUI Elements
-- 				Interaction with Slideouts
--				Interaction with Exploder
--              Main System for rendering the Editor elements and panels.

------------------------------------------------------------------------------------------------------------

require("scripts/utils/xml-reader")
require("scripts/utils/assimp")

bullet  = require( "byt3d/ffi/bulletcapi" )

------------------------------------------------------------------------------------------------------------
-- Some states call other states!!
-- This is our BG state, and belongs with the MainMenu state

--local Slogin 	= require("scripts/states/login")

byt3dRender = require("framework/byt3dRender")
Gpool		= require("framework/byt3dPool")

local utils = require("scripts/states/editor/editor_utils")

------------------------------------------------------------------------------------------------------------
-- byt3d Framework includes

require("framework/byt3dModel")
require("framework/byt3dLevel")
require("framework/byt3dShader")
require("framework/byt3dTexture")

------------------------------------------------------------------------------------------------------------
-- Shaders

require("shaders/base_models")
require("shaders/base_terrain")
require("shaders/liquid_blue")
require("shaders/sky")
require("shaders/grid")

------------------------------------------------------------------------------------------------------------
---- Panels
local cmdPanel 	        = require("scripts/panels/command_console")
local Pedit_main 	    = require("scripts/panels/editor_main")
local Pedit_assetMgr    = require("scripts/panels/editor_assetlist")

local edit_camera       = require("scripts/states/editor/editor_cameras")
------------------------------------------------------------------------------------------------------------

local SEditor	= NewState()

gPhysicsSdk     = nil
gDynamicsWorld  = nil

------------------------------------------------------------------------------------------------------------

gLevels				= { }
gLevels["Default"]	= {

    level 	= nil
}

------------------------------------------------------------------------------------------------------------

SEditor.newObject	= nil
SEditor.editLevel	= "Default"

------------------------------------------------------------------------------------------------------------

function SEditor:Init(wwidth, wheight)

    self.width 		= wwidth
    self.height 	= wheight
    Gcairo.newObject	= nil
    initComplete    = true

    -- print(gPhysicsSdk, gDynamicsWorld)
end

------------------------------------------------------------------------------------------------------------

function SEditor:CheckFlags(mxi, myi, buttons)

    if Pedit_main.flags == nil then return end
    local tryrequest = 0

    if Pedit_main.flags["assets"] == "RequestOpen" then
        Pedit_main.flags["assets"] = nil
        tryrequest = 1
    end
    if Pedit_main.flags["assets"] == "RequestClose" then
        Pedit_main.flags["assets"] = nil
        tryrequest = 2
    end

    if Pedit_assetMgr.started == ASSET_LIST_INACTIVE then
        Pedit_main.flags["assets_last"] = "RequestClose"
    end

    if Pedit_assetMgr.started == ASSET_LIST_ACTIVE then
        Pedit_main.flags["assets_last"] = "RequestOpen"
    end

    if Pedit_assetMgr.started == ASSET_LIST_SLIDEOUT then
        tryrequest = 1
    end

    if Pedit_assetMgr.started == ASSET_LIST_SLIDEIN then
        tryrequest = 2
    end

    if tryrequest == 1 then Pedit_assetMgr:Begin() end
    if tryrequest == 2 then Pedit_assetMgr:Close() end
    if Pedit_assetMgr.started > ASSET_LIST_INACTIVE then
        Pedit_assetMgr:Update(mxi, myi, buttons)
    end

    if Pedit_main.flags["close"] == true then
        print("Quitting...")
        sm:ExitState()
    end
end

------------------------------------------------------------------------------------------------------------

function SEditor:BuildTower(level, ttype)

    local newtex = byt3dTexture:New()
    newtex:FromCairoImage(Gcairo, "concrete", "byt3d/data/images/surfaces/grey-concrete.png")

    self.tower = {}
    local col = { 200, 200, 200, 255 }

    for levels = 0, 1 do
    for x=0, 8 do
        for i=0, 3 do
        local pos = { x, 0.25 + 1 * levels, i * 2 }
        local plank = utils:AddBlock(level, 0.8, pos, col, 0.1, 0.25, 1)
        table.insert(self.tower, plank)
        plank:SetSamplerTex(newtex, "s_tex0")
        end
    end

    for y=0, 8 do
        for i=0, 3 do
        local pos = { i * 2 , 0.75 + 1 * levels, y }
        local plank = utils:AddBlock(level, 0.8, pos, col, 1, 0.25, 0.1)
        table.insert(self.tower, plank)
        plank:SetSamplerTex(newtex, "s_tex0")
        end
    end
    end

    local newmodel = byt3dModel:New()
    local newshader = byt3dShader:NewProgram(colour_shader_vert, colour_shader_frag)
    local newtex = byt3dTexture:New()
    newtex:FromCairoImage(Gcairo, "sky1", "byt3d/data/bg/skyboxsun25degtest.png")
    -- Need a sphere you see from the inside
    local inverted = -1
    newmodel:GenerateSphere(900, 10, inverted)
    newmodel:SetMeshProperty("priority", byt3dRender.ENV)
    newmodel:SetMeshProperty("shader", newshader)
    newmodel:SetMeshProperty("shadows_cast", nil)
    newmodel:SetMeshProperty("shadows_recv", nil)

    newmodel:SetSamplerTex(newtex, "s_tex0")
    newmodel.node.transform:Position(0.0, 0.0, 0.0)
    level.nodes["root"]:AddChild(newmodel, "sky")
end

------------------------------------------------------------------------------------------------------------

function SEditor:UpdateTower(level)

    for k, v in ipairs(self.tower) do
        local m = ffi.new("float[16]")
        bullet.plGetOpenGLMatrix(v.physics, m);
        v.node.transform.m = {  m[0], m[1], m[2], m[3], m[4], m[5], m[6], m[7], m[8], m[9], m[10], m[11], m[12], m[13], m[14], m[15] }
    end
end


------------------------------------------------------------------------------------------------------------

function SEditor:UpdateBalls(level)

    for k, v in ipairs(self.balls) do
        local m = ffi.new("float[16]")
        bullet.plGetOpenGLMatrix(v.physics, m);
        v.node.transform.m = {  m[0], m[1], m[2], m[3], m[4], m[5], m[6], m[7], m[8], m[9], m[10], m[11], m[12], m[13], m[14], m[15] }
    end
end

------------------------------------------------------------------------------------------------------------

function SEditor:SetupEditor( level )

    local newmodel = byt3dModel:New()
    local newshader = byt3dShader:NewProgram(grid_shader_vert, colour_shader_frag)
    local newtex = byt3dTexture:New()

    newtex:FromCairoImage(Gcairo, "grid1", "byt3d/data/images/editor/grid_001.png")
    newmodel:GeneratePlane(160, 160, 10, hasPHYSICS)
    newmodel:SetMeshProperty("alpha", 1.0)
    newmodel:SetMeshProperty("priority", byt3dRender.EDITOR)
    newmodel:SetMeshProperty("shader", newshader)
    newmodel:SetMeshProperty("shadows_cast", nil)

    newmodel:SetSamplerTex(newtex, "s_tex0")
    newmodel.node.transform:RotationHPR(0.0, 90.0, 0.0)
    newmodel.node.transform:Position(0.0, 0.0, 0.0)
    -- Adds a physics rigid body collision plane
    newmodel.physics = utils:CreatePhysicsPlane(160, {0.0, 0.0, 0.0}, 0.0)

    level.nodes["root"]:AddChild(newmodel, "editor_grid")

    local cursor_model  = byt3dModel:New()
    local cursor_shader = byt3dShader:NewProgram(colour_shader_vert, colour_shader_frag)
    local cursor_tex    = byt3dTexture:New()

    cursor_tex:FromCairoImage(Gcairo, "cursor", "byt3d/data/images/editor/cursor_target.png")
    cursor_model:GeneratePlane(1, 1, 1)
    cursor_model:SetMeshProperty("alpha", 0.5)
    cursor_model:SetMeshProperty("priority", byt3dRender.EDITOR_ALPHA)
    cursor_model:SetMeshProperty("shader", cursor_shader)
    cursor_model:SetMeshProperty("shadows_cast", nil)
    cursor_model:SetMeshProperty("shadows_recv", nil)

    cursor_shader.PreRender = function( ) gl.glEnable(gl.GL_BLEND); gl.glDisable(gl.GL_DEPTH_TEST) end

    cursor_model:SetSamplerTex(cursor_tex, "s_tex0")
    cursor_model.node.transform:RotationHPR(0.0, 90.0, 0.0)
    cursor_model.node.transform:Position(0.0, 0.0, 0.0)
    level.nodes["root"]:AddChild(cursor_model, "cursor_shader")
end

------------------------------------------------------------------------------------------------------------

function SEditor:Begin()

    -- Assert that we have valid width and heights (simple protection)
    assert(initComplete == true, "Init function not called.")

    gPhysicsSdk     = bullet.plNewBulletSdk()
    gDynamicsWorld  = bullet.plCreateDynamicsWorld(gPhysicsSdk)

    self.time_start = os.time()
    self.time_last = os.clock()

    local level = byt3dLevel:New("Default", "data/levels/default.lvl" )
    gLevels[self.editLevel].level = level
    edit_camera:Begin(level, self.width, self.height)

    level.icons = {}
    level.icons.oculus = Gcairo:LoadImage("oculus", "byt3d/data/icons/oculus_64.png", 1)
    level.icons.oculus.scalex = 0.35; level.icons.oculus.scaley = 0.35
    level.icons.select = Gcairo:LoadImage("icon_generic", "byt3d/data/icons/generic_64.png", 1)
    level.icons.camera = Gcairo:LoadImage("icon2", "byt3d/data/icons/generic_obj_camera_64.png")

    edit_camera.selected = level.cameras[level.currentCamera]

    self.filterMask     = 0x0000000
    self.oldFilterMask  = 0xFFFFFFF
    self.OCULUS_ICON    = 0x0000001
    level.RenderCamera  = level.Render

    self:SetupEditor( level )
    local pos = {0, 20, 0}; col = { 255, 0, 0, 255 }
    --self.cube = utils:AddCube( level, 2, pos, col )

    -- Build a little wall
    self:BuildTower(level, "brick_wall")

    self.balls = {}
    pos = {2, 50, 0}; col = { 0, 255, 0, 255 }
    --self.sphere = utils:AddSphere( level, 2, pos, col )

    Pedit_main:Begin()
end



------------------------------------------------------------------------------------------------------------

function SEditor:SetOculus( )

    if bit.band(self.filterMask, self.OCULUS_ICON) > 0 then
        Gcairo.style.image_color.a=1.0
    else
        Gcairo.style.image_color.a=0.2
    end

    if self.filterMask == self.oldFilterMask then return end
    local level = gLevels[self.editLevel].level
    if bit.band(self.filterMask, self.OCULUS_ICON) > 0 then
        level.RenderCamera = level.RenderOculus
    else
        level.RenderCamera = level.Render
    end

    self.oldFilterMask = self.filterMask
end

------------------------------------------------------------------------------------------------------------

function SEditor:Update(mxi, myi, buttons)

    -- Do physics updates first
    local pos = ffi.new("float[3]")
    local m = ffi.new("float[16]")
    --bullet.plGetOpenGLMatrix(self.cube.physics, m);
    --self.cube.node.transform.m = {  m[0], m[1], m[2], m[3], m[4], m[5], m[6], m[7], m[8], m[9], m[10], m[11], m[12], m[13], m[14], m[15] }
    --bullet.plGetOpenGLMatrix(self.sphere.physics, m);
    --self.sphere.node.transform.m = {  m[0], m[1], m[2], m[3], m[4], m[5], m[6], m[7], m[8], m[9], m[10], m[11], m[12], m[13], m[14], m[15] }

    local level = gLevels[self.editLevel].level

    self:UpdateTower(level)
    self:UpdateBalls(level)

    if(buttons[3] == true) then
        local col = { 150, 70, 180, 255 }
        local p = level.cameras[level.currentCamera].eye

        local fwd = level.cameras[level.currentCamera].node.transform:view()
        local vel = ffi.new("float[3]", fwd[1] * 50.0, fwd[2] * 50.0, fwd[3] * -50.0 )
        local model = utils:AddSphere( level, 0.5, p, col, 1 )
        bullet.plSetLinearVelocity(model.physics, vel )
        table.insert(self.balls, model)
    end

    local tcolor = { r=1.0, b=1.0, g=1.0, a=1.0 }
    Gcairo:Begin()

    local saved = Gcairo.style.button_color
    Gcairo.style.button_color = { r=0.2, g=0.0, b=0.7, a=1.0 }

    Gcairo:RenderBox(5, 0, 240, 27, 0)
    Gcairo:RenderText("byt3d", 20, 20, 20, tcolor )

    local image_saved = Gcairo.style.image_color.a
    self:SetOculus()
    Gcairo:ButtonImage("button_oculus", level.icons.oculus, 195, 4, AssetListToggle, { this=self, mask=self.OCULUS_ICON } )
    Gcairo.style.image_color.a=image_saved

    Gcairo.style.button_color = saved
    Pedit_main:Update(mxi, myi, buttons)

    -- Cameras with handlers need eye, heading and pitch updates
    local ccam = level.cameras[level.currentCamera]
    if ccam.handler then
        ccam.handler(edit_camera, mxi, myi, buttons)
        edit_camera:CameraUpdate()
    end

    edit_camera:CameraList(level)
    -- Check flags
    self:CheckFlags(mxi, myi, buttons)
    -- Check state
    if Pedit_assetMgr.model then

        level.nodes["root"]:AddChild(Pedit_assetMgr.model, "Model_"..Pedit_assetMgr.model.name)
        Pedit_assetMgr.model = nil
    end

    Gcairo:Update(mxi, myi, buttons)

    -- Physics updates - this will go in a coroutine.. to make it nice to run
    local time_current = os.clock()
    local dtime = time_current - self.time_last
    self.time_last = time_current
    -- Update the physics
    bullet.plStepSimulation(gDynamicsWorld, dtime, 6)

    saved = Gcairo.style.button_color
end

------------------------------------------------------------------------------------------------------------

function SEditor:Render()

    local level = gLevels[self.editLevel].level
    level:RenderCamera()
    Gcairo:Render()
end

------------------------------------------------------------------------------------------------------------

function SEditor:Finish()

    -- Before leaving capture a thumbnail for the project if set
    if gCurrProjectInfo.byt3dProject.projectInfo.genThumbnail == 1 then
        local thumbnail = "byt3d/data/projects/thumbnails/"..projectName..".png"
        Gcairo:ScreenShot(1, 1, thumbnail )
        gCurrProjectInfo.byt3dProject.projectInfo.thumbnail = thumbnail
        SaveXml(gProjectFile..".xml", gCurrProjectInfo.byt3dProject, "byt3dProject")
    end

    Pedit_main:Finish()

    local tpool = byt3dPool:GetPool(byt3dPool.TEXTURES_NAME)
    tpool:DestroyAllFromTime(self.time_start)

    bullet.plDeleteDynamicsWorld(gDynamicsWorld);
    bullet.plDeletePhysicsSdk(gPhysicsSdk);
end

------------------------------------------------------------------------------------------------------------

return SEditor

------------------------------------------------------------------------------------------------------------
