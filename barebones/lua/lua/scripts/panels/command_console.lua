------------------------------------------------------------------------------------------------------------
-- State - Command Console panel
--
-- Decription: Displays a command console panel - initiated by the ~ key (traditional games key)
--			   Panel can be configured to be placed anywhere. Simple single line execution,
--			   with multi-line output.

------------------------------------------------------------------------------------------------------------

	
------------------------------------------------------------------------------------------------------------

local SCmdPanel	= NewState()
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

function SCmdPanel:Begin()

    self.oldprint = print
    print = cprint
	gCommand = ""
	self.image1 = Gcairo:LoadImage("icon1", "byt3d/data/icons/generic_64.png")
end

------------------------------------------------------------------------------------------------------------

function SCmdPanel:Update(mxi, myi, buttons)

	local tcolor = { r=1.0, b=1.0, g=1.0, a=1.0 }

	-- A Content window of 'stuff' to show
	local cmd_output = Gcairo:List("", 0, 0,  Gcairo.WIDTH, 140)
	local snodes = {}
	local i = 1

	for k,v in pairs(gcommandLog) do
		snodes[i] =	{ name = v, ntype=CAIRO_TYPE.TEXT, size=14 }; i=i+1
	end
	cmd_output.nodes = snodes

	local saved = Gcairo.style.button_color

	Gcairo.style.border_width = 0.0
	Gcairo.style.button_color = CAIRO_STYLE.METRO.ORANGE
	Gcairo.style.button_color.a = 0.5
	Gcairo:Panel(" Command Console", 0, Gcairo.HEIGHT - 160, 14, 0, cmd_output)

	Gcairo.style.button_color = { r=0.0, g=0.0, b=0.0, a=1 }
	gcommandtext = Gcairo:TextBox("command", 300, Gcairo.HEIGHT - 155, Gcairo.WIDTH - 320, 14, gCommand, tcolor) 
	Gcairo:RenderBox(300, Gcairo.HEIGHT - 157, Gcairo.WIDTH - 320, 18, 0)
	Gcairo.style.button_color = saved
	
	for k,v in pairs(gSdisp.wm.KeyUp) do
		if v.scancode == sdl.SDL_SCANCODE_RETURN then
            if gCommand ~= nil then
                local cmd = tostring(gCommand)
                table.insert(gcommandHistory, cmd)
                table.insert(gcommandLog, "> "..cmd)

			    local err, output = load(cmd)
                if err == nil then
                    print("Error Executing: "..cmd)
                else
                    err()
                end
            end
			
			gCommand = ""
			gcommandtext.data = ""
		end
	end
end

------------------------------------------------------------------------------------------------------------

function SCmdPanel:Render()

	if gcommandtext then 
		gCommand = gcommandtext.data 
	end
end

------------------------------------------------------------------------------------------------------------

function SCmdPanel:Finish()
    print = self.oldprint
end
	
------------------------------------------------------------------------------------------------------------

return SCmdPanel

------------------------------------------------------------------------------------------------------------