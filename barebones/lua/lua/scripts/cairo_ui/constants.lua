------------------------------------------------------------------------------------------------------------
-- Cairo UI - Develop by David Lannan
--
-- Design Notes:
-- The aim of the UI is to provide pixel consistancy for scalable graphics. What this means is the art
-- and the scalable graphics use a common measurement system (currently 1024 x1024) and it auto pixel 
-- scales the output to match the target UI resolution. 
--
-- Why this is needed - Quite often when you scale Cairo you will get pixel blends and stretching that 
-- deform the output. Small fonts are a good example. If you rotate or place some cairo operation on a small 
-- font with a small base scale then you will lose pixels in the operation and the output will look poor.
-- By using a high internal level of scale but maintaining the output to match the target it means 
-- the blending will look good for the target resolution no matter the size.
--
-- When the resolution has a unique aspect (non square) then we adjust the underlying maximum sizes so that
-- it still matches. For example, 640x480 will have a underlying Cairo UI size of 1024x768 rather than 1024x1024
-- to ensure close pixel approximation. A mobile phone type resolution of 480x800 will map to 614x1024
--
-- Cairo UI cannot solve all layout UI problems, but it should make development much easier in the long run.
-- 
------------------------------------------------------------------------------------------------------------

CAIRO_RENDER = {}

-- These are valid resolution widths for textures that map closely to resolutions.
-- The concept is that the underlying texture map should closely match the required resolution.
-- Using this method the output graphics will be clear and 'tidy' only most devices.
CAIRO_RENDER_SIZES = { 512, 1024, 2048, 4096 }

-- The function here finds the best solution from an input width.
function CAIRO_RENDER:GetSize(width, aspect)
	local w = width
	for k,v in pairs(CAIRO_RENDER_SIZES) do
		if v > width then w=v; break; end
	end
	return w, math.ceil( w * aspect )
end

--Some sensible defaults...
CAIRO_RENDER.DEFAULT_WIDTH		= 512
CAIRO_RENDER.DEFAULT_HEIGHT		= 512
CAIRO_RENDER.MAX_PIXEL_SIZE 	= 2048

------------------------------------------------------------------------------------------------------------
CAIRO_UI	=	
{
	LEFT 		= 0,
	RIGHT 		= 1,
	TOP			= 2,
	BOTTOM		= 3,

    EXPLODER_TWEEN_TIME     = 0.1,
    SLIDER_TWEEN_TIME       = 0.1
}

------------------------------------------------------------------------------------------------------------
CAIRO_TYPE 	= 
{
	-- Base types
	TEXT		= 0,
	BUTTON		= 1,
	IMAGE		= 2,
	TEXTBOX		= 3,			-- Text entry box, same as text but has input handling and such.
	
	-- Complex types
	SLIDEOUT	= 10,
	EXPLODER	= 11,
	LISTBOX		= 12,			-- Technically the same as VLINE/LIST..  TODO: will need to sort out later
	PANEL		= 13,			-- Simple Dialog / Window like panel
	
	-- Layout types
	HLINE		= 20,
	VLINE		= 21,
	LIST		= 22
}

------------------------------------------------------------------------------------------------------------

CAIRO_STATE = {}
CAIRO_STATE.SO_STATES			= { INITIAL = 0, MOVING_OUT = 1, OUT = 2, MOVING_IN = 3, IN = 4}

------------------------------------------------------------------------------------------------------------

CAIRO_STYLE = {}

CAIRO_STYLE.WHITE				= { r=1.0, g=1.0, b=1.0, a=1.0 }

------------------------------------------------------------------------------------------------------------
-- Metro style colours!! Base metroc colors (ala Win8)

CAIRO_STYLE.METRO	= {}
CAIRO_STYLE.METRO.ORANGE		= { r=0.97,  g=0.576, b=0.117, a=1  }
CAIRO_STYLE.METRO.PURPLE		= { r=0.341, g=0.149, b=0.5,   a=1  }
CAIRO_STYLE.METRO.LBLUE			= { r=0.012, g=0.684, b=0.859, a=1 }
CAIRO_STYLE.METRO.SEAGREEN		= { r=0.258, g=0.570, b=0.598, a=1 }
CAIRO_STYLE.METRO.GREEN			= { r=0.469, g=0.730, b=0.265, a=1 }


------------------------------------------------------------------------------------------------------------

CAIRO_STYLE.ICONS 	= {}
CAIRO_STYLE.ICONS.tick_64 		= "data/icons/generic_obj_tick_64.png"
CAIRO_STYLE.ICONS.folder_64 	= "data/icons/generic_obj_folder_64.png"
CAIRO_STYLE.ICONS.arrowup_64 	= "data/icons/generic_arrowup_64.png"
CAIRO_STYLE.ICONS.arrowdn_64 	= "data/icons/generic_arrowdn_64.png"
------------------------------------------------------------------------------------------------------------
