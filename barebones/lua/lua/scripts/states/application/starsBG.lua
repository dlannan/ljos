------------------------------------------------------------------------------------------------------------
-- State - Render the Star field (clips for client)
--
-- Decription: 	Render the star field
--				Clips the starfield to the viewport
--				Renders info about the stars (exploder for stars)

------------------------------------------------------------------------------------------------------------

require("scripts/utils/csv")
	
------------------------------------------------------------------------------------------------------------

local SstarsBG	= NewState()

------------------------------------------------------------------------------------------------------------

SstarsBG.WINwidth		= 512
SstarsBG.WINheight		= 512

SstarsBG.UIwidth		= 1024
SstarsBG.UIheight		= 1024

SstarsBG.RA				= 0.0		-- Right Ascension (Yaw.. is another way to describe it :) )
SstarsBG.Dec			= 0.0		-- Declination (Pitch is similar..)

SstarsBG.HFOV			= 20.0		-- These can be dynamically set - clipping and scaling is done using these fovs
SstarsBG.VFOV			= 40.0

SstarsBG.minRA			= SstarsBG.RA
SstarsBG.maxRA			= SstarsBG.RA + SstarsBG.HFOV 
SstarsBG.minDec			= SstarsBG.Dec
SstarsBG.maxDec			= SstarsBG.Dec + SstarsBG.VFOV 


local star_image		= nil
local star_catalog 		= {}

------------------------------------------------------------------------------------------------------------

local function ConvertData( ra1, ra2, dec1, dec2)
	local decsec = (dec2 - math.floor(dec2)) 
	dec_deg = dec1 + (math.floor(dec2) / 60) + decsec
	local rasec = (ra2 - math.floor(ra2)) 
	ra_deg = 360 * (ra1 + (math.floor(ra2) / 60) + rasec) / 24
	
	return ra_deg, dec_deg  
end

------------------------------------------------------------------------------------------------------------

local function RecalcMinMax()

	SstarsBG.minRA			= SstarsBG.RA
	SstarsBG.maxRA			= SstarsBG.RA + SstarsBG.HFOV 
	SstarsBG.minDec			= SstarsBG.Dec
	SstarsBG.maxDec			= SstarsBG.Dec + SstarsBG.VFOV 
end

------------------------------------------------------------------------------------------------------------

local function DrawStar(name, ra, dec)

	-- Work out the X/Y (this is real simple.. no space curvature.. will do that later..)
	star_image.x = SstarsBG.UIwidth * (ra - SstarsBG.minRA) / (SstarsBG.maxRA - SstarsBG.minRA)
	star_image.y = SstarsBG.UIheight * (dec - SstarsBG.minDec) / (SstarsBG.maxDec - SstarsBG.minDec)
	Gcairo:RenderImage(star_image.enableImage, star_image.x, star_image.y, 0.0)
	local tw, th = Gcairo:GetTextSize(name, 20.0)
	-- Need valid vertical and horizontal values
	if (tw ~= 0) and (th ~= 0) then 
		Gcairo:TextDraw(name, star_image.x - tw * 0.5 + 32.0, star_image.y - th, 20.0)
	end
end

------------------------------------------------------------------------------------------------------------

function SstarsBG:Begin()

	star_image = { 
			x=0, y=0, enabled=1, angle = 0.0, scalex = 1.0, scaley = 1.0,
			enableImage=Gcairo:LoadImage("starImage", "byt3d/icons/temp_game/star_system_64.png")
	}	
	
	star_catalog = LoadCSV("byt3d/data/stars-50lyr.csv")
	
	-- TODO: This is a little slow.. meh! Will fix later.
	for k,v in ipairs(star_catalog) do
		v[1] = utf2lat(v[1])
	end
end

------------------------------------------------------------------------------------------------------------

function SstarsBG:Update(mxi, myi, buttons)

	local decHeight = SstarsBG.WINheight * 0.5
	SstarsBG.RA = (mxi / SstarsBG.WINwidth) * 360.0
	SstarsBG.Dec = (myi - decHeight) / SstarsBG.WINheight * 90.0 
	if(SstarsBG.RA > 360.0) then SstarsBG.RA = 0.0 end
	if(SstarsBG.RA < 0.0) then SstarsBG.RA = 360.0 end
	RecalcMinMax()
end

------------------------------------------------------------------------------------------------------------

function SstarsBG:Render()
	-- If it falls within the min/max then render it!
	for k,v in ipairs(star_catalog) do
		if(v[1] ~= "Sun") then
			-- Star data is in column format: 1-Name  2+3-RA  4+5-Dec
			local ra, dec = ConvertData( tonumber(v[2]), tonumber(v[3]), tonumber(v[4]), tonumber(v[5]) )
			if ra > SstarsBG.minRA and ra < SstarsBG.maxRA and dec > SstarsBG.minDec and dec < SstarsBG.maxDec then
				-- Draw Icon 
				DrawStar( v[1], ra, dec)
			end
		end
	end
end

------------------------------------------------------------------------------------------------------------

function SstarsBG:Finish()
end
	
------------------------------------------------------------------------------------------------------------

return SstarsBG

------------------------------------------------------------------------------------------------------------
	