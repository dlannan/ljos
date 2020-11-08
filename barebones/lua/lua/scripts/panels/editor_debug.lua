--
-- Created by David Lannan
-- User: grover
-- Date: 25/03/13
-- Time: 8:09 PM
-- Copyright 2013  Developed for use with the byt3d engine.
--

------------------------------------------------------------------------------------------------------------
-- State - Editor Debug Panel
--
-- Decription: Displays a Debug panel that can be used to issue debug commmands and examine
--			   variables and logs
------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------

local SEditorDebug	= NewState()
local gCommand 			= ""
local gPrevCommand		= ""

local gcommandHistory 	= { }
local gcommandLog		= { }

local gcommandtext 		= nil

------------------------------------------------------------------------------------------------------------

function cprint( ... )
    local printResult = ""
    local n = select("#",...)
    for i = 1,n do
        local v = tostring(select(i,...))
        printResult = printResult.."  "..v
    end
    table.insert(gcommandLog, printResult)
end

------------------------------------------------------------------------------------------------------------

function ExitCommandPanel()
    Gcairo.newObject = nil
end

------------------------------------------------------------------------------------------------------------

function SetCurrentCommand(callerobj)
    gCommand = callerobj.name
end

------------------------------------------------------------------------------------------------------------

function DebuggerCommand(callerobj)
    gCommand = callerobj.meta
end

-----------------------------------------------------------------------------------------------------------

function SEditorDebug:Begin()

    -- Screenshot with gui and with save file
    self.bg = Gcairo:ScreenShot(1)
    self.bg.scalex = Gcairo.WIDTH / self.bg.width
    self.bg.scaley = Gcairo.HEIGHT / self.bg.height

    self.img_step = Gcairo:LoadImage("icon_step", "byt3d/data/icons/generic_64.png")
    self.img_step.scalex = 0.3; self.img_step.scaley = 0.3
    self.img_trace = Gcairo:LoadImage("img_trace", "byt3d/data/icons/generic_obj_search_64.png")
    self.img_trace.scalex = 0.3; self.img_trace.scaley = 0.3
    self.img_out = Gcairo:LoadImage("img_out", "byt3d/data/icons/generic_arrowup_64.png")
    self.img_out.scalex = 0.3; self.img_out.scaley = 0.3
    self.img_vars = Gcairo:LoadImage("img_vars", "byt3d/data/icons/generic_obj_ask_64.png")
    self.img_vars.scalex = 0.3; self.img_vars.scaley = 0.3

    self.oldprint = print
    print = cprint
    self.oldwrite = io.write
    io.write = cprint

    gCommand = ""
    self.enabled = true
end

------------------------------------------------------------------------------------------------------------

function SEditorDebug:Update()

    local buttons 	= gSdisp:GetMouseButtons()
    local move 		= gSdisp:GetMouseMove()

    local tcolor = { r=1.0, b=1.0, g=1.0, a=1.0 }
    local saved = Gcairo.style.button_color

    -- Command reset every frame.. dont want repeats!!!
    gCommand = ""
    if(gSdisp:GetRunApp() == false) then gCommand = "debug_quit" end
    gSdisp:PreRender()

    Gcairo:Begin()

    if self.bg then Gcairo:RenderImage(self.bg, 0, 0, 0) end

    -- Draw a debug panel with some debug features.
    -- Initial pass: Step, Run, Trace, Output to list.

    local ASSETPANEL_WIDTH  = 400
    local LEFT              = 0

    Gcairo.style.button_color = { r=0.3, g=0, b=0, a=0.8 }
    Gcairo:RenderBox(LEFT, 0, ASSETPANEL_WIDTH, Gcairo.HEIGHT, 0)

    Gcairo:RenderText("Debug", 10, 20, 14 )
    Gcairo.style.button_color = { r=1.0, g=1, b=1, a=1 }
    Gcairo:RenderBox(LEFT, 28, ASSETPANEL_WIDTH, 1, 0)

    Gcairo.style.button_color = { r=0.4, g=0, b=0, a=0.5 }
    Gcairo:PanelListText(" >", LEFT + 2, 30, 12, 11, ASSETPANEL_WIDTH - 4,  Gcairo.HEIGHT -40, gcommandLog)

    -- Step the next
    Gcairo:ButtonImage("button_step", self.img_step, LEFT+200, 4, DebuggerCommand, "step 1" )
    -- Step out to the next level function
    Gcairo:ButtonImage("button_out", self.img_out, LEFT+220, 4, DebuggerCommand, "out 1" )
    -- Trace the current position
    Gcairo:ButtonImage("button_trace", self.img_trace, LEFT+240, 4, DebuggerCommand, "trace" )
    -- Display local variables
    Gcairo:ButtonImage("button_vars", self.img_vars, LEFT+260, 4, DebuggerCommand, "vars 1" )

    Gcairo.style.button_color = saved
    Gcairo:Update(move.x, move.y, buttons)
    return gCommand
end

------------------------------------------------------------------------------------------------------------

function SEditorDebug:Render()

    if gcommandtext then
        gCommand = gcommandtext.data
    end

    -- This does a buffer flip.
    sm:Render()
    gSdisp:Flip()
end

------------------------------------------------------------------------------------------------------------

function SEditorDebug:Finish()
    print       = self.oldprint
    io.write    = self.oldwrite
    self.enabled = false
end

------------------------------------------------------------------------------------------------------------

return SEditorDebug

------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------

