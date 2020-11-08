--
-- Created by David Lannan
-- User: grover
-- Date: 5/03/13
-- Time: 7:55 PM
-- Copyright 2013  Developed for use with the byt3d engine.
--
------------------------------------------------------------------------------------------------------------

local CamEditor =
{
    omx     = 0.0,
    omy     = 0.0,
    selected = nil
}

------------------------------------------------------------------------------------------------------------

-- Indicate if the current camera settings should be copied to the next (useful for FreeCamera)
local COPY_CAMERA       = 1
local LEAVE_CAMERA      = nil

------------------------------------------------------------------------------------------------------------

function ChangeCamera(callerobj)

    local level = gLevels["Default"].level
    local camera_update = LEAVE_CAMERA
    if callerobj.name == "FreeCamera" then camera_update = COPY_CAMERA end

    level:ChangeCamera(callerobj.name, camera_update)
    callerobj.meta.this.selected = level.cameras[level.currentCamera]
    Gcairo.exploderStates[" Cameras"].state = 4
end

------------------------------------------------------------------------------------------------------------

function CamEditor:Begin(level, w, h)

    level.cameras["Default"]:SetupView(0.0, 0.0, w, h)
    level.cameras["Default"]:LookAt( { 13, 2, 13 }, { 0.0, 0.0, 0.0 } )

    level.cameras["FreeCamera"]:SetupView(0.0, 0.0, w, h)

    -- Add handlers here
    level.cameras["FreeCamera"].handler = self.CameraFreeController

    -- Keystate is instantaneous - more useful for free camera
    self.keystate = nil

    level.cameras["sun"] = byt3dRender.lights["sun"]
    level.cameras["sun"].handler = self.CameraFreeController
end

------------------------------------------------------------------------------------------------------------

function CamEditor:CameraList(level)

    -- A Window for selection of the camera to use (should break into seperate state)
    local content = Gcairo:List("camera_list", 0, 10, 180, 140)
    local tcolor = { r=1.0, b=1.0, g=1.0, a=1.0 }
    local nodes = {
    }

    for k,v in pairs(level.cameras) do

        local nline1 = { name="space1", size=6 }
        local nline2 = {
            { name="space1", size=4 },
            { name="test2", ntype=CAIRO_TYPE.IMAGE, image=level.icons.select, size=14, color=tcolor },
            { name="space1", size=4 },
            { name=k, ntype=CAIRO_TYPE.TEXT, size=14, callback=ChangeCamera, meta = { this=self } }
        }
        if level.currentCamera ~= k then nline2[2] = { name="space1", size=14 } end
        local nline2ref = { name="line2", ntype=CAIRO_TYPE.HLINE, size=14, nodes = nline2 }
        table.insert(nodes, nline1)
        table.insert(nodes, nline2ref )
    end

    --	nodes[11] = { name="space2", size=10 }
    --	nodes[12] = { name="Another Line", ntype=CAIRO_TYPE.TEXT, size=10 }
    content.nodes = nodes
    content.arrows = 1
    Gcairo.style.button_color = CAIRO_STYLE.METRO.SEAGREEN

    -- Render a slideOut object on left side of screen
    -- Gcairo:SlideOut(" Cameras",  CAIRO_UI.LEFT, 140, 20, 0, content)
    Gcairo:Exploder(" Cameras", level.icons.camera, CAIRO_UI.BOTTOM, 220, 3, 20, 20, 0, content)
end

------------------------------------------------------------------------------------------------------------

function CamEditor:CameraFreeController(mxi, myi, buttons)

    local cam = self.selected
    local dospeed = 0

    if buttons[1] == true then

        self.keystate = sdl.SDL_GetKeyboardState(nil)
        -- Free Camera rotate
        cam.heading = cam.heading + (mxi - self.omx) * 0.5
        cam.pitch = cam.pitch + (myi - self.omy) * 0.5

        if self.keystate[sdl.SDL_SCANCODE_S] == 1 then
            cam.speed = 20.0
            dospeed = 1
        end
        if self.keystate[sdl.SDL_SCANCODE_W] == 1 then
            cam.speed = -20.0
            dospeed = 1
        end
    end

    if dospeed == 0 then
        cam.speed = cam.speed * 0.75
    end

    self.omx = mxi
    self.omy = myi
end

------------------------------------------------------------------------------------------------------------

function CamEditor:CameraUpdate()

    local cam = self.selected

    -- No need to move, if there is no speed!
    if math.abs(byt3dRender.currentCamera.speed) > 0.5 then

        local tm = byt3dRender.currentCamera.node.transform.m
        -- level.spheres["Model1"].node.transform:Position( tm[13], tm[14], tm[15] )
        local vec = { tm[3], tm[7], tm[11], 0.0 }
        local dir = VecNormalize( vec )

        -- Apply Speed
        cam.eye[1] = cam.eye[1] + dir[1] * cam.speed * WM_frameMs
        cam.eye[2] = cam.eye[2] + dir[2] * cam.speed * WM_frameMs
        cam.eye[3] = cam.eye[3] + dir[3] * cam.speed * WM_frameMs
    end

    cam:UpdateFromEye()
    -- print(cam.eye[1], cam.eye[2], cam.eye[3])
end

------------------------------------------------------------------------------------------------------------

return CamEditor

------------------------------------------------------------------------------------------------------------
