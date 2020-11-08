------------------------------------------------------------------------------------------------------------
-- State - Icon Manager
--
-- Decription:  Loads and manages social icons
--				

------------------------------------------------------------------------------------------------------------

local Sgameicons	= NewState()

------------------------------------------------------------------------------------------------------------

local win		= nil
local icons		=	{}

------------------------------------------------------------------------------------------------------------
-- Simple little icon render func (probably should go in cairo)

local function RenderIcon( icon )
	if(icon.enabled==0) then 
		Gcairo:RenderImage(icon.disableImage, icon.x, icon.y, icon.angle)
	else 
		Gcairo:RenderImage(icon.enableImage, icon.x, icon.y, icon.angle)
	end
end

------------------------------------------------------------------------------------------------------------

function Sgameicons:Begin()

	-- Some icons on screen to enable/disable
	icons.scanner = { 
			x=900, y=60, enabled=1, angle = 0.0,
			enableImage=Gcairo:LoadImage("scannerEnable", "byt3d/icons/temp_game/scanner_64.png")
	}	
	
	icons.defense = { 
			x=900, y=140, enabled=1, angle = 0.0, 
			enableImage=Gcairo:LoadImage("scannerEnable", "byt3d/icons/temp_game/defense_64.png")
	}	

	icons.tech = { 
			x=900, y=220, enabled=1,  angle = 0.0,
			enableImage=Gcairo:LoadImage("scannerEnable", "byt3d/icons/temp_game/technology_64.png")
	}	

	icons.astro = { 
			x=900, y=300, enabled=1,  angle = 0.0,
			enableImage=Gcairo:LoadImage("scannerEnable", "byt3d/icons/temp_game/astro_vr_64.png")
	}	

	icons.star_system = { 
			x=900, y=380, enabled=1,  angle = 0.0,
			enableImage=Gcairo:LoadImage("scannerEnable", "byt3d/icons/temp_game/star_system_64.png")
	}
	
	icons.ship_scout = { 
			x=500, y=400, enabled=1,  angle = 0.0,
			enableImage=Gcairo:LoadImage("scannerEnable", "byt3d/icons/temp_game/ship_scout_64.png")
	}
	
		
end

------------------------------------------------------------------------------------------------------------

local deg = 0.0

function Sgameicons:Update(mxi, myi, buttons)

	-- Render Icons
--	if(MouseButton[1] == true) then icons.facebook.enabled=1 else icons.facebook.enabled=0 end		

	local range = 200.0
	-- Move the ship around so we can test trails and such
	icons.ship_scout.x = 500 + math.sin(deg) * range
	icons.ship_scout.y = 400 + math.cos(deg) * range
	deg = deg + frameMs
	if deg > math.pi * 2.0 then deg = deg - (math.pi * 2.0) end
	icons.ship_scout.angle = math.pi * 0.5 -deg
end

------------------------------------------------------------------------------------------------------------

function Sgameicons:Render()

	for k,v in pairs(icons) do RenderIcon(v) end
end

------------------------------------------------------------------------------------------------------------

function Sgameicons:Finish()

end
	
------------------------------------------------------------------------------------------------------------

return Sgameicons

------------------------------------------------------------------------------------------------------------
