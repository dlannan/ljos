------------------------------------------------------------------------------------------------------------
-- State - Icon Manager
--
-- Decription:  Loads and manages social icons
--				

------------------------------------------------------------------------------------------------------------

local SiconMgr	= NewState()

------------------------------------------------------------------------------------------------------------

local win		= nil
local icons		=	{}

------------------------------------------------------------------------------------------------------------
-- Simple little icon render func (probably should go in cairo)

local function RenderIcon( icon )
	if(icon.enabled==0) then 
		CairoRenderImage(icon.disableImage, icon.x, icon.y, 0.0)
	else 
		CairoRenderImage(icon.enableImage, icon.x, icon.y, 0.0)
	end
end

------------------------------------------------------------------------------------------------------------

function SiconMgr:Begin()

	-- Some icons on screen to enable/disable
	icons.facebook = { 
			x=400, y=60, enabled=0, 
			enableImage=CairoLoadImage("fbEnable", "icons/NORMAL/64/facebook_64.png"),
			disableImage=CairoLoadImage("fbDisable", "icons/DIS/64/facebook_64.png"),
	}	
	
	icons.twitter = { 
			x=470, y=60, enabled=0, 
			enableImage=CairoLoadImage("twEnable", "icons/NORMAL/64/twitter_64.png"),
			disableImage=CairoLoadImage("twDisable", "icons/DIS/64/twitter_64.png"),
	}	

	icons.google = { 
			x=540, y=60, enabled=0, 
			enableImage=CairoLoadImage("ggEnable", "icons/NORMAL/64/google_64.png"),
			disableImage=CairoLoadImage("ggDisable", "icons/DIS/64/google_64.png"),
	}	
end

------------------------------------------------------------------------------------------------------------

function SiconMgr:Update(mxi, myi, buttons)

	-- Render Icons
--	if(MouseButton[1] == true) then icons.facebook.enabled=1 else icons.facebook.enabled=0 end		
end

------------------------------------------------------------------------------------------------------------

function SiconMgr:Render()

	for k,v in pairs(icons) do RenderIcon(v) end
end

------------------------------------------------------------------------------------------------------------

function SiconMgr:Finish()

end
	
------------------------------------------------------------------------------------------------------------

return SiconMgr

------------------------------------------------------------------------------------------------------------
