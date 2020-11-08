------------------------------------------------------------------------------------------------------------
-- State - Terrain rendering and setup
--
-- Decription: Generates procedurally generated terrain with icons on it.
--             Allplies scrolling and clipping for display in cairo

------------------------------------------------------------------------------------------------------------

local snoise 	= require("scripts/terrain/proc_gen")
local color_maps = require("scripts/terrain/color_maps")

local tween		= require("scripts/utils/tween")

local alien1	= require("scripts/states/character")
local terrain	= require("scripts/states/terrain")

------------------------------------------------------------------------------------------------------------

local SterrainGame	= NewState()

------------------------------------------------------------------------------------------------------------

local bgimage		= nil
------------------------------------------------------------------------------------------------------------

function SterrainGame:Init(wwidth, wheight)

	terrain.WINwidth	= wwidth
	terrain.WINheight	= wheight
	
	terrain:Init(wwidth, wheight)
end

------------------------------------------------------------------------------------------------------------

function SterrainGame:Begin()	
	
	bgimage = Gcairo:LoadImage("bg1", "data/bg/background-red.png")

	terrain:Begin()
	alien1:Begin()
	alien1.sprite.x = 190
	alien1.sprite.y = 160	
end

------------------------------------------------------------------------------------------------------------

function SterrainGame:Update(mxi, myi, buttons)	

	Gcairo:Begin()
	Gcairo:RenderImage(bgimage, 0, 0, 0.0)
	
	if (buttons[1] == true) and (mxi > 300) then 
		alien1:WalkTo( (terrain.WINheight-(mxi-300)) + 300, terrain.WINheight-myi, 1.0, terrain ) 
	end
	
	-- Clip to a fixed space in the scene
	Gcairo:ClipRegion(300, 0, 480, 480)

	Gcairo:PushState()
	Gcairo:Translate( terrain.x, terrain.y )	
	Gcairo:Scale( terrain.zoom, terrain.zoom )
	

	terrain:Update(mxi, myi, buttons)
	alien1:Update(mxi, myi, buttons)
		
	-- This closes the popped zoom state
	Gcairo:PopState()
	
	Gcairo:ClipReset()	
	Gcairo:DirtyImage(terrain.image2)	

	local terrain_menu = Gcairo:List("", 0, 0, 180, 100)
	local tnodes = {}

	local line1 = {}
	line1[2] = { name="Zoom:", ntype=CAIRO_TYPE.TEXT, size=14 }
	line1[3] = { name="In ", ntype=CAIRO_TYPE.BUTTON, size=14, callback=Terrain_ZoomIn, cobject=terrain }
	line1[4] = { name="Out", ntype=CAIRO_TYPE.BUTTON, size=14, callback=Terrain_ZoomOut, cobject=terrain }

	tnodes[1] = { name="Regen Terrain", ntype=CAIRO_TYPE.BUTTON, size=14, border=0, corner=0, callback=Terrain_SettingsChanged, cobject=terrain }
	tnodes[2] = { name="line1", ntype=CAIRO_TYPE.HLINE, size=16, nodes = line1 }
	terrain_menu.nodes = tnodes	

	Gcairo:PushState()
	Gcairo:Scale( 0.5, 0.5 )	
	alien1:Render()
	Gcairo:PopState()
	
	Gcairo:SlideOut(" Terrain", CAIRO_UI.BOTTOM, 10, 22, 0, terrain_menu)
	Gcairo:Update(mxi, myi, buttons)
end

------------------------------------------------------------------------------------------------------------


function SterrainGame:Render()	
	

	Gcairo:Render()
end

------------------------------------------------------------------------------------------------------------


function SterrainGame:Finish()	

	Gcairo:Finish()
	terrain:Finish()
	alien1:Finish()	
	
end

------------------------------------------------------------------------------------------------------------

return SterrainGame

------------------------------------------------------------------------------------------------------------