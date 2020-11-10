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

local random = math.random

-- This is somewhat dangerous and could cause name clashes!! should rethink this.
ffi 	= require( "ffi" )
ft 		= require( "lua/ffi/freetype")
cr 		= require( "lua/ffi/cairo" )

tween 	= require( "scripts/utils/tween" )
FB0 	= require( "libs/fb0" )

require("scripts/cairo_ui/constants")
require("scripts/utils/geometry")
require("scripts/utils/text")

------------------------------------------------------------------------------------------------------------
-- Some manager lists -- bit crap.. for the moment

local cairo_ui = {}

------------------------------------------------------------------------------------------------------------

local function AddLibrary( lib, fname ) 
	local tlib = require(fname)
	for k,v in pairs(tlib) do
		lib[k] = v
	end
end
		
------------------------------------------------------------------------------------------------------------

function CAIRO_CHK(ctx)
	local error = cr.cairo_status(ctx)
	if error ~= 0 then
		print( 'cairo error: ', error )
	end
end

------------------------------------------------------------------------------------------------------------
-- The files below are able to use the local namespace to work correctly with cairo_ui

AddLibrary(cairo_ui, "scripts/cairo_ui/operations")
AddLibrary(cairo_ui, "scripts/cairo_ui/text")
AddLibrary(cairo_ui, "scripts/cairo_ui/images")
AddLibrary(cairo_ui, "scripts/cairo_ui/import_svg")
AddLibrary(cairo_ui, "scripts/cairo_ui/widgets")
AddLibrary(cairo_ui, "scripts/cairo_ui/widget_handlers")

------------------------------------------------------------------------------------------------------------

cairo_ui.ibuffer 		= ffi.new( "unsigned short[6]", 1, 0, 2, 3, 2, 0 )
cairo_ui.vertexArray 	= ffi.new( "float[12]", -1.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0,-1.0, 0.0, -1.0,-1.0, 0.0 )
cairo_ui.texCoordArray 	= ffi.new( "float[8]", 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0 )
cairo_ui.FB0			= FB0

------------------------------------------------------------------------------------------------------------
-- Style settings.. change these to change the style of buttons etc
cairo_ui.style = {}
cairo_ui.style.corner_size	= 0.0
cairo_ui.style.border_width = 1.0
cairo_ui.style.button_color			= CAIRO_STYLE.METRO.LBLUE		-- { r=0.8, g=0.5, b=0.5, a=1 }
cairo_ui.style.button_border_color	= CAIRO_STYLE.METRO.LBLUE		-- { r=0.3, g=0, b=0, a=1 }
cairo_ui.style.image_color			= CAIRO_STYLE.WHITE
cairo_ui.style.font_name			= "normal" -- "Century Gothic"

------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------
-- This list is checked for mouseover, mousedown, mouseup and mousemove type events
-- List is ordered based on declaration order. If you need a button to the front, then delete it and add it again.
cairo_ui.objectList		= {}

------------------------------------------------------------------------------------------------------------
-- Simple cache for images - recommend preloading!!
cairo_ui.imageList		= {}

------------------------------------------------------------------------------------------------------------
cairo_ui.WIDTH			= CAIRO_RENDER.DEFAULT_WIDTH
cairo_ui.HEIGHT 		= CAIRO_RENDER.DEFAULT_HEIGHT
cairo_ui.V_WIDTH		= CAIRO_RENDER.MAX_PIXEL_SIZE
cairo_ui.V_HEIGHT 		= CAIRO_RENDER.MAX_PIXEL_SIZE
cairo_ui.data 			= nil
cairo_ui.tests 			= { "pdf", "svg", "png" }

------------------------------------------------------------------------------------------------------------

cairo_ui.image_counter	= 1
------------------------------------------------------------------------------------------------------------

cairo_ui.lastMouseButton = {}
cairo_ui.oldmx			 = 0	-- old mouse x
cairo_ui.oldmy			 = 0	-- old mouse y
cairo_ui.currentCursor	 = nil

------------------------------------------------------------------------------------------------------------
cairo_ui.timeLast 		= os.clock()
cairo_ui.written 		= 0

------------------------------------------------------------------------------------------------------------
-- Object Control methods

-- Add a new object to the object list - this is created per frame
-- TODO: Add cahcing mechanisms and so on.

function cairo_ui:AddObject( obj, otype, cb, meta )

	-- new object which wraps the notmal widget
	local nobj = { id=self.objectCount, name=obj.name, otype=otype, callback=cb, cobject=obj, meta=meta  }
	
	-- Some objects have default callback setups (buttons mainly - where we can set objects as buttons)
--	if callback ~= nil then
--		nobj.callback = self:ButtonSetHandler(nobj)
--	end
	self.objectList[tonumber(nobj.id)] = nobj
	self.objectCount = self.objectCount + 1
end

------------------------------------------------------------------------------------------------------------

function cairo_ui:Reset()

	local test = false
	if self.data ~= nil then test = true end
	
	self.slideOutStates	= {}
	self.exploderStates	= {}
	self.listStates		= {}
	self.multiImageStates = {}
	self.cursorStates	= {}
		
	------------------------------------------------------------------------------------------------------------
	-- This list is checked for mouseover, mousedown, mouseup and mousemove type events
	-- List is ordered based on declaration order. If you need a button to the front, then delete it and add it again.
	self.objectList		    = {}
	
	------------------------------------------------------------------------------------------------------------
	-- Simple cache for images - recommend preloading!!
	self.imageList			= {}
	
	------------------------------------------------------------------------------------------------------------
	self.WIDTH			    = CAIRO_RENDER.DEFAULT_WIDTH
	self.HEIGHT 		    = CAIRO_RENDER.DEFAULT_HEIGHT
	self.V_WIDTH		    = CAIRO_RENDER.MAX_PIXEL_SIZE
	self.V_HEIGHT 		    = CAIRO_RENDER.MAX_PIXEL_SIZE
	self.data 			    = nil
	self.tests 			    = { "pdf", "svg", "png" }
	
	------------------------------------------------------------------------------------------------------------
	
	self.image_counter	    = 1
	------------------------------------------------------------------------------------------------------------
	
	self.lastMouseButton    = {}
	self.oldmx			    = 0	-- old mouse x
	self.oldmy			    = 0	-- old mouse y
	
	------------------------------------------------------------------------------------------------------------
	self.timeLast 		    = os.clock()
	self.written 		    = 0
	
	self.file_FileSelect 	= ""
	self.file_LastSelect	= ""
	self.file_NewFolder 	= nil

	-- This can be modified per project - defines root level project directory.
	self.currdir 			= nil
	self.dirlist			= nil
	self.select_file		= -1

    self.svgs               = {}
	
end 

------------------------------------------------------------------------------------------------------------

function cairo_ui:TestFonts() 

	-- -- draw the entire context white
	cr.cairo_set_source_rgba(self.ctx, 1, 1, 1, 1)
	cr.cairo_paint(self.ctx)
	
	-- text color black, size 20
	cr.cairo_set_source_rgb(self.ctx, 0.0, 0.0, 0.0)
	cr.cairo_set_font_size (self.ctx, 20.0)
	
	cr.cairo_select_font_face (self.ctx, "sans", cr.CAIRO_FONT_SLANT_NORMAL, cr.CAIRO_FONT_WEIGHT_NORMAL)
	cr.cairo_move_to (self.ctx, 50, 50)
	-- cr.cairo_show_text (self.ctx, "Sans normal")
	
	-- cr.cairo_select_font_face (self.ctx, "sans", cr.CAIRO_FONT_SLANT_ITALIC, cr.CAIRO_FONT_WEIGHT_NORMAL)
	-- cr.cairo_move_to (self.ctx, 50, 70)
	-- cr.cairo_show_text (self.ctx, "Sans italic")
	
	-- cr.cairo_select_font_face (self.ctx, "sans", cr.CAIRO_FONT_SLANT_NORMAL, cr.CAIRO_FONT_WEIGHT_BOLD)
	-- cr.cairo_move_to (self.ctx, 50, 90)
	-- cr.cairo_show_text (self.ctx, "Sans bold")
	
	
	-- cr.cairo_select_font_face (self.ctx, "courier", cr.CAIRO_FONT_SLANT_NORMAL, cr.CAIRO_FONT_WEIGHT_NORMAL)
	-- cr.cairo_move_to (self.ctx,50, 150)
	-- cr.cairo_show_text (self.ctx, "Courier normal")
	
	-- cr.cairo_select_font_face (self.ctx, "courier", cr.CAIRO_FONT_SLANT_ITALIC, cr.CAIRO_FONT_WEIGHT_NORMAL)
	-- cr.cairo_move_to (cself.ctxr, 50, 170)
	-- cr.cairo_show_text (self.ctx, "Courier italic")
	
	-- cr.cairo_select_font_face (self.ctx, "courier", cr.CAIRO_FONT_SLANT_NORMAL, cr.CAIRO_FONT_WEIGHT_BOLD)
	-- cr.cairo_move_to (self.ctx, 50, 190)
	-- cr.cairo_show_text (self.ctx, "Courier bold")
	
	
	-- cr.cairo_select_font_face (self.ctx, "calibri", cr.CAIRO_FONT_SLANT_NORMAL, cr.CAIRO_FONT_WEIGHT_NORMAL)
	-- cr.cairo_move_to (self.ctx, 50, 250)
	-- cr.cairo_show_text (self.ctx, "Calibri normal")
	
	-- cr.cairo_select_font_face (self.ctx, "calibri", cr.CAIRO_FONT_SLANT_ITALiC, cr.CAIRO_FONT_WEIGHT_NORMAL)
	-- cr.cairo_move_to (self.ctx, 50, 270)
	-- cr.cairo_show_text (self.ctx, "Calibri italic")
	
	-- cr.cairo_select_font_face (self.ctx, "calibri", cr.CAIRO_FONT_SLANT_NORMAL, cr.CAIRO_FONT_WEIGHT_BOLD)
	-- cr.cairo_move_to (self.ctx, 50, 290)
	-- cr.cairo_show_text (self.ctx, "Calibri bold")
	
	
	-- cr.cairo_select_font_face (self.ctx, "times", cr.CAIRO_FONT_SLANT_NORMAL, cr.CAIRO_FONT_WEIGHT_NORMAL)
	-- cr.cairo_move_to (self.ctx, 50, 350)
	-- cr.cairo_show_text (self.ctx, "Times normal")
	
	-- cr.cairo_select_font_face (self.ctx, "times", cr.CAIRO_FONT_SLANT_ITALIC, cr.CAIRO_FONT_WEIGHT_NORMAL)
	-- cr.cairo_move_to (self.ctx,50, 370)
	-- cr.cairo_show_text (self.ctx, "Times italic")
	
	-- cr.cairo_select_font_face (self.ctx, "times", cr.CAIRO_FONT_SLANT_NORMAL, cr.CAIRO_FONT_WEIGHT_BOLD)
	-- cr.cairo_move_to (self.ctx, 50, 390)
	-- cr.cairo_show_text (self.ctx, "Times bold")
	
	
	-- cr.cairo_select_font_face (self.ctx, "georgia", cr.CAIRO_FONT_SLANT_NORMAL, cr.CAIRO_FONT_WEIGHT_NORMAL)
	-- cr.cairo_move_to (self.ctx, 50, 450)
	-- cr.cairo_show_text (self.ctx, "Georgia normal")
	
	-- cr.cairo_select_font_face (self.ctx, "georgia", cr.CAIRO_FONT_SLANT_ITALIC, cr.CAIRO_FONT_WEIGHT_NORMAL)
	-- cr.cairo_move_to (self.ctx, 50, 470)
	-- cr.cairo_show_text (self.ctx, "Georgia italic")
	
	-- cr.cairo_select_font_face (self.ctx, "georgia", cr.CAIRO_FONT_SLANT_NORMAL, cr.CAIRO_FONT_WEIGHT_BOLD)
	-- cr.cairo_move_to (self.ctx, 50, 490)
	-- cr.cairo_show_text (self.ctx, "Georgia bold")
	
end

------------------------------------------------------------------------------------------------------------

function cairo_ui:SetupFont()

	local faces = {
		['Gothic'] = 'lua/data/fonts/gothic.ttf',
		['Origami Mommy']  = 'lua/data/fonts/origami mommy.ttf',
	}	

	local lib = ft:new()
	local face = lib:face(faces['Gothic'])
	ct = cr.cairo_ft_font_face_create_for_ft_face (face, 0)
	cr.cairo_set_font_face (self.ctx, ct)
end	

------------------------------------------------------------------------------------------------------------
-- Initialise some Cairo informaiton
function cairo_ui:Init(width, height)
	
	self:Reset()
	self.WIDTH 		= width
	self.HEIGHT 	= height
	
	local aspect = height / width
	local calcWidth, calcHeight = CAIRO_RENDER:GetSize(width, aspect)
	self.V_WIDTH 	= FB0.w -- calcWidth
	self.V_HEIGHT 	= FB0.h -- calcHeight
	
	print("Virtual Screen Size: ", self.V_WIDTH, self.V_HEIGHT)	
	-- self.data = ffi.new( "uint8_t[?]", self.V_WIDTH * self.V_HEIGHT * 4 )
print(FB0.fb_data)

	-- Make a default surface we will render to
	local stride = cr.cairo_format_stride_for_width (cr.CAIRO_FORMAT_ARGB32, self.V_WIDTH)
	self.sf = cr.cairo_image_surface_create_for_data( FB0.fb_data, cr.CAIRO_FORMAT_ARGB32, self.V_WIDTH, self.V_HEIGHT, stride )
	self.device = cr.cairo_surface_get_device(self.sf)
	self.ctx = cr.cairo_create( self.sf ); CAIRO_CHK(self.ctx)
	
	self:SetupFont()
	-- Use an available font - need to work out how to use local file based fonts or convert to scaled fonts.
	-- cr.cairo_select_font_face( self.ctx, self.style.font_name, cr.CAIRO_FONT_SLANT_NORMAL, 0 ); CAIRO_CHK(self.ctx)
	
	self.scaleX = self.V_WIDTH / self.WIDTH 
	self.scaleY = self.V_HEIGHT / self.HEIGHT
	cr.cairo_scale(self.ctx, self.scaleX, self.scaleY)
	-- cr.cairo_set_source_surface (self.ctx, self.sf, 0, 0)

	-- Builtin images for use with widgets
	self.img_select = self:LoadImage("icon_tick", CAIRO_STYLE.ICONS.tick_64)
	self.img_folder	= self:LoadImage("icon_folder", CAIRO_STYLE.ICONS.folder_64)

	self.img_folder.scalex = 0.35
	self.img_folder.scaley = 0.35
	
	if(self.img_arrowup == nil) then 
		self.img_arrowup = self:LoadImage("arrowup", CAIRO_STYLE.ICONS.arrowup_64) 
		self.img_arrowup.scalex = 16 / self.img_arrowup.width
		self.img_arrowup.scaley = 16 / self.img_arrowup.height
	end
	if(self.img_arrowdn == nil) then 
		self.img_arrowdn = self:LoadImage("arrowdn", CAIRO_STYLE.ICONS.arrowdn_64) 
		self.img_arrowdn.scalex = 16 / self.img_arrowdn.width
		self.img_arrowdn.scaley = 16 / self.img_arrowdn.height
	end

	self.mouseScaleX = (self.WIDTH / FB0.w )
	self.mouseScaleY = (self.HEIGHT / FB0.h)
	print("Cairo MouseScale W/H:", self.mouseScaleX, self.mouseScaleY)

    self.RenderFPS = self.InternalRenderFPS
end

------------------------------------------------------------------------------------------------------------
-- Closedown Cairo
function cairo_ui:Finish()

	for k,v in pairs(cairo_ui.imageList) do
		if(v.image) then
			if(v.data) then v.data = nil end 
			cr.cairo_surface_destroy ( v.image ) 
		end
	end

-- *************************************************************************
--- TODO: Figure just what the hell to do about startup/shutdown of cairo.
--		  Probably should run only one instance - will look into this.         
--        This will minimise mem foot print which is too big atm.
--	      Probably make cairo_ui singleton - self aware too (cant create more
--			than one of itself). And always returns that instance.
-- *************************************************************************
	cr.cairo_destroy( self.ctx );
	cr.cairo_surface_destroy( self.sf );
 
	self.ctx 	= nil
	self.sf 		= nil
end

------------------------------------------------------------------------------------------------------------

function cairo_ui:RenderSurface(svgdata)

	-- Root level should have svg label and xargs containing surface information
	local label = svgdata["label"]
	if(label == "svg") then
		cr.cairo_stroke (self.ctx)	
		
		-- Get the surface sizes, and so forth
		local xargs = svgdata["xarg"]
		local width = tonumber(xargs["width"])
		local height = tonumber(xargs["height"])
		local xmlns = xargs["xmlns"]

		for k,v in pairs(svgdata) do
			cairo_ui:RenderSvg(v)
		end
	end
end

------------------------------------------------------------------------------------------------------------
-- Start the Rendering of UI to the Cairo surface/context

function cairo_ui:Begin()

	-- Update the tweening 
	local timeNow = os.clock()
	local timeDiff = timeNow - self.timeLast
	self.timeLast = timeNow
	tween.update(timeDiff)

	cr.cairo_save (self.ctx)
	cr.cairo_set_source_rgba (self.ctx, 0, 0, 0, 0)
	cr.cairo_set_operator (self.ctx, cr.CAIRO_OPERATOR_SOURCE)
	cr.cairo_paint (self.ctx)
	cr.cairo_restore (self.ctx)

	-- Object list every frame
	self.objectList 	= {}
	self.objectCount 	= 1
	self.image_counter = 1

    -- Render any svgs
    for k,v in pairs(self.svgs) do
        cr.cairo_save (self.ctx)
        if v.pos then cr.cairo_translate(self.ctx, v.pos.x, v.pos.y) end
        self:RenderSvg(v)
        cr.cairo_restore (self.ctx)
    end
end

------------------------------------------------------------------------------------------------------------

function cairo_ui:CheckListScroll(buttons, mx, my, obj, state)
			
	if obj == nil then return end
				
	-- Check the list scroll area and if in the region
	if(InRegion( obj, mx, my) == true) then	

		-- Holding mouse down on the slider.. move the slider.
        local sdiff = 0
		if buttons[1] == true then
			sdiff = my - self.oldmy
        end

        if buttons[10] ~= 0.0 then sdiff = buttons[10] * 0.25 end

        if sdiff ~= 0 then
            state.scroll = state.scroll + sdiff
        end
		
		-- Mouse released on list slider.. then stop sliding
		if buttons[1] == false and self.lastMouseButton[1] == true then
		
		end
	end
end

------------------------------------------------------------------------------------------------------------
-- Upon completion of rendering he Cairo surface pass it to the OpenGL texture

function cairo_ui:Update(mxi, myi, buttons)

	-- Scale the mouse position because of the Interface/Window scaling
	local mx = mxi * self.mouseScaleX
	local my = myi * self.mouseScaleY

	-- TODO:
	-------------------------------------------------------------------------------------------------------
	-- #######   CLEAN THIS SHIT UP DAVE!!!    ########
	
	-- TODO:     This Update function will soo be changed.. lots to do .. lots to cleanup.
	-------------------------------------------------------------------------------------------------------
	-- Iterate Objects and detect button hits and similar
	for k,v in ipairs(self.objectList) do
		
		if v ~= nil then
			local handler = self.widget_handlers[v.otype]
			if handler ~= nil then handler(self, v, mx, my, buttons) end
		end
	end
	
	self.oldmx = mx
	self.oldmy = my
	
	--  ***   TODO:  Need a Mouse Handler  *** --
	-- Bit of a hack.. 	
	self.lastMouseButton[1] = buttons[1]
	self.lastMouseButton[2] = buttons[2]
	self.lastMouseButton[3] = buttons[3]	
end

------------------------------------------------------------------------------------------------------------
-- Render FPS system

function cairo_ui:InternalRenderFPS()

    -- Enable frameMs rendering for profiling.
    ttime = math.floor(os.clock())
    if self.lastclock ~= ttime then
        self.ms = string.format("FPS: %02.2f", 0.0)
        self.lastclock = ttime
    end
    self:RenderText(self.ms, 90, 18, 12)
end

------------------------------------------------------------------------------------------------------------
-- Upon completion of rendering he Cairo surface pass it to the OpenGL texture

function cairo_ui:Render()

    --if self.RenderFPS then self:RenderFPS() end

	-- send self.data to the FB0!!!
	-- Need to scale to the FB0 size!!!!
	--ffi.copy(FB0.fb_data, self.data, FB0.fb_screensize)
end

------------------------------------------------------------------------------------------------------------
-- Render a user interface 'box'

function cairo_ui:RenderBox(x, y, width, height, corner)
	-- a custom shape that could be wrapped in a function --
	local aspect        = 1.0     			-- aspect ratio --
	
	if corner == nil then corner = self.style.corner_size end
	local corner_radius = corner  	-- and corner curvature radius --
	
	local radius = corner_radius / aspect;
	local degrees = 3.14129 / 180.0;
	
	local colorA = self.style.button_color	
	local colorB = self.style.button_border_color	
	local border = self.style.border_width

    cr.cairo_save (self.ctx)

	cr.cairo_set_source_rgba( self.ctx, colorA.r, colorA.g, colorA.b, colorA.a)
	cr.cairo_new_path( self.ctx )
	cr.cairo_arc( self.ctx,x + width - radius, y + radius, radius, -90 * degrees, 0 * degrees)
	cr.cairo_arc( self.ctx, x + width - radius, y + height - radius, radius, 0 * degrees, 90 * degrees)
	cr.cairo_arc( self.ctx,x + radius, y + height - radius, radius, 90 * degrees, 180 * degrees)
	cr.cairo_arc( self.ctx,x + radius, y + radius, radius, 180 * degrees, 270 * degrees)
	cr.cairo_close_path( self.ctx )

	cr.cairo_fill_preserve( self.ctx )

	cr.cairo_set_source_rgba( self.ctx,  colorB.r, colorB.g, colorB.b, colorB.a )
	cr.cairo_set_line_width( self.ctx, border)
	cr.cairo_stroke( self.ctx )

    cr.cairo_restore (self.ctx)
end

------------------------------------------------------------------------------------------------------------

return cairo_ui

------------------------------------------------------------------------------------------------------------
