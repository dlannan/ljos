------------------------------------------------------------------------------------------------------------
-- This allows button rendering to be deferred if needed

------------------------------------------------------------------------------------------------------------

local dir 		= require("scripts/utils/directory")
local widgets = {}

widgets.img_arrowup	= nil
widgets.img_arrowdn = nil

widgets.cursorFlash	= 0.4

------------------------------------------------------------------------------------------------------------

local function TweenDone(objList, name)
	local sostate = objList[name]
	sostate.tween = nil
end

------------------------------------------------------------------------------------------------------------

function widgets:ButtonImage(name, image, x, y, cb, meta)

    local button = self:Button(name, x, y, image.width * image.scalex, image.height * image.scaley, 0, 6, cb, meta )
    self:RenderImage(image, x, y, 0.0, 1)
end

------------------------------------------------------------------------------------------------------------

function widgets:ButtonText(name, text, x, y, fsize, tcolor, cb, meta)

    local w,h = self:GetTextSize(text, fsize)
    local button = self:Button(name, x, y-h, w, h, 0, 6, cb, meta )
    self:RenderText(text, x, y, fsize, tcolor)
end


------------------------------------------------------------------------------------------------------------

function widgets:RenderCursor(name, x, y, width, height, tfade, cb)
	
	if self.cursorStates[name] == nil then 

		local mistate = { name=name, alpha=0.0, state=CAIRO_STATE.SO_STATES.INITIAL, pos=0, posw=0 }
		local newtween = tween( tfade, mistate, { alpha=1.0 }, 'inQuad', TweenDone, self.cursorStates, name )
		mistate.tween = newtween
		
		self.cursorStates[name] = mistate
	end
	
	local saved = self.style.button_color
	local mistate = self.cursorStates[name]
	-- Cursor Flashing
	if mistate.state == CAIRO_STATE.SO_STATES.INITIAL then
		self.style.button_color = { r=1, g=1, b=1, a=mistate.alpha }
		self:RenderBox( x, y, width, height, 0 )
		if mistate.tween == nil then 
			mistate.tween = tween( tfade, mistate, { alpha=0.0 }, 'inQuad', TweenDone, self.cursorStates, name )
			self.style.image_color = {r=1, g=1, b=1, a=1}
			mistate.state=CAIRO_STATE.SO_STATES.MOVING_OUT
		end

	-- Cursor Flashing
	elseif mistate.state == CAIRO_STATE.SO_STATES.MOVING_OUT then
		self.style.button_color = { r=1, g=1, b=1, a=mistate.alpha }
		self:RenderBox( x, y, width, height, 0 )
		if mistate.tween == nil then 
			mistate.tween = tween( tfade, mistate, { alpha=1.0 }, 'inQuad', TweenDone, self.cursorStates, name )
			self.style.image_color = {r=1, g=1, b=1, a=1}
			mistate.state=CAIRO_STATE.SO_STATES.INITIAL
		end
	end
	self.style.button_color = saved 
end

------------------------------------------------------------------------------------------------------------

function widgets:RenderMultiImage(name, image_list, x, y, tdelay, tfade, cb)
	
	local saved = self.style.image_color
	local icount = table.getn(image_list)
	if icount == 0 then return end
	if self.multiImageStates[name] == nil then 
	
		local mistate = { name=name, alpha=0.0, state=CAIRO_STATE.SO_STATES.INITIAL, current=1 }
		local newtween = tween( tfade, mistate, { alpha=1.0 }, 'inQuad', TweenDone, self.multiImageStates, name )
		mistate.tween = newtween
		
		self.multiImageStates[name] = mistate
	end
	local mistate = self.multiImageStates[name]
	-- print("State:", mistate.state, "Alpha:", mistate.alpha, "Tween:",mistate.tween)
	
	-- Fading in..
	if mistate.state == CAIRO_STATE.SO_STATES.INITIAL then
		self.style.image_color = {r=1, g=1, b=1, a=mistate.alpha}
		self:ButtonImage(name..string.format("_%03d", mistate.current), image_list[mistate.current], x, y, cb)
		if mistate.tween == nil then 
			mistate.tween = tween( tdelay, mistate, { alpha=1.0 }, 'inQuad', TweenDone, self.multiImageStates, name )
			self.style.image_color = {r=1, g=1, b=1, a=1}
			mistate.state=CAIRO_STATE.SO_STATES.MOVING_OUT
		end

	-- Waiting for next fade out..
	elseif mistate.state == CAIRO_STATE.SO_STATES.MOVING_OUT then
		self:ButtonImage(name..string.format("_%03d", mistate.current), image_list[mistate.current], x, y, cb)
		if mistate.tween == nil then 
			mistate.tween = tween( tfade, mistate, { alpha=0.0 }, 'inQuad', TweenDone, self.multiImageStates, name )
			self.style.image_color = {r=1, g=1, b=1, a=1}
			mistate.state=CAIRO_STATE.SO_STATES.OUT
		end

	-- Fading out..
	elseif mistate.state == CAIRO_STATE.SO_STATES.OUT then
		self.style.image_color = {r=1, g=1, b=1, a=mistate.alpha}
		self:ButtonImage(name..string.format("_%03d", mistate.current), image_list[mistate.current], x, y, cb)
		if mistate.tween == nil then 
			mistate.tween = tween( tfade, mistate, { alpha=1.0 }, 'inQuad', TweenDone, self.multiImageStates, name )
			mistate.state=CAIRO_STATE.SO_STATES.INITIAL
			mistate.current = mistate.current + 1
			if mistate.current > icount then mistate.current = 1 end
		end
	end
	-- Flip pic.. start again..
	self.style.image_color = saved
end

------------------------------------------------------------------------------------------------------------

function widgets:RenderMultiSlideImage(name, image_list, x, y, swidth, tdelay, sspeed, cb)
	
	local icount = table.getn(image_list)
	if icount == 0 then return end
	
	if self.multiImageStates[name] == nil then 
	
		local timage = image_list[1]
        local imagex = timage.width * timage.scalex
        local targetx = (x + swidth * 0.5) - imagex * 0.5
		local mistate = { name=name, xpos=x-imagex, state=CAIRO_STATE.SO_STATES.INITIAL, current=1 }
		local newtween = tween( sspeed, mistate, { xpos=targetx }, 'inCubic', TweenDone, self.multiImageStates, name )
		mistate.tween = newtween
		self.multiImageStates[name] = mistate
	end
	
	local mistate = self.multiImageStates[name]
	-- print("State:", mistate.state, "Alpha:", mistate.alpha, "Tween:",mistate.tween)

	local timage = image_list[mistate.current]

	self:ClipRegion( x, y, swidth, timage.height * timage.scaley )
		
	local nameid = name..string.format("_%03d", mistate.current)
	
	-- Fading in..
	if mistate.state == CAIRO_STATE.SO_STATES.INITIAL then
		self:ButtonImage(nameid, image_list[mistate.current], mistate.xpos, y, cb)
		if mistate.tween == nil then
            local imagex = timage.width * timage.scalex
            local targetx = (x + swidth * 0.5) - imagex * 0.5
			mistate.tween = tween( tdelay, mistate, { xpos=targetx }, 'inCubic', TweenDone, self.multiImageStates, name )
			mistate.state=CAIRO_STATE.SO_STATES.MOVING_OUT
        end

	-- Fading in..
	elseif mistate.state == CAIRO_STATE.SO_STATES.MOVING_OUT then
		self:ButtonImage(nameid, image_list[mistate.current], mistate.xpos, y, cb)
		if mistate.tween == nil then 
			mistate.tween = tween( sspeed, mistate, { xpos=x+swidth }, 'inCubic', TweenDone, self.multiImageStates, name )
			mistate.state=CAIRO_STATE.SO_STATES.OUT
		end

	-- Fading out..
	elseif mistate.state == CAIRO_STATE.SO_STATES.OUT then
		self:ButtonImage(nameid, image_list[mistate.current], mistate.xpos, y, cb)
		if mistate.tween == nil then
            mistate.current = mistate.current + 1
            if mistate.current > icount then mistate.current = 1 end
            local timage = image_list[mistate.current]

            local imagex = timage.width * timage.scalex
            local targetx = (x + swidth * 0.5) - imagex * 0.5
			mistate.xpos = x-timage.width * timage.scalex
			mistate.tween = tween( sspeed, mistate, { xpos=targetx }, 'inCubic', TweenDone, self.multiImageStates, name )
			mistate.state=CAIRO_STATE.SO_STATES.INITIAL
		end
	end
	self:ClipReset()
end

------------------------------------------------------------------------------------------------------------

function widgets:RenderButton(button, angle)

	local style = self.style
	self:RenderBox( button.left-style.border_width, button.top-style.border_width, button.width+style.border_width, button.height+style.border_width, button.corner )
	self:ClipRegion(button.left-style.border_width, button.top-style.border_width, button.width+style.border_width, button.height+style.border_width)
	local bs = button.height
	if(bs > button.width) then bs = button.width end

	cr.cairo_save(self.ctx)
	cr.cairo_translate(self.ctx, button.left, button.top)
	if(math.abs(angle) > 0.0) then
		cr.cairo_rotate(self.ctx, angle)
		cr.cairo_translate(self.ctx, 0.0, -bs)
	end
	self:RenderText( button.name, 0, bs * 0.85, bs, button.color )	
	cr.cairo_restore(self.ctx)
	self:ClipReset()
end

------------------------------------------------------------------------------------------------------------

function widgets:Button(name, left, top, width, height, corner, border, cb, meta)
	
	--if(oldButton) then return oldButton end
	local newButton = { name=name, top=top, left=left, width=width, height=height, corner=corner, border=border }
	
	-- Must add to a managed list to detect clip regions for mouse over etc.
	-- Check it doesnt already exist!
	self:AddObject(newButton, CAIRO_TYPE.BUTTON, cb, meta)
	
	return newButton
end

------------------------------------------------------------------------------------------------------------

function widgets:List(name, left, top, width, height)
	
	-- Work out "where" the panel is currently (list slider).
	local state = {}
	if(self.listStates[name] == nil) then 
		state = { state=CAIRO_STATE.SO_STATES.INITIAL, move=0, scroll=0, target=1.0 }
	else
		state = self.listStates[name]
	end
	
	local newListBox = { 
		otype = CAIRO_TYPE.LISTBOX, name=name, top=top, left=left, width=width, height=height, nodes = {}
	}
		
	self:AddObject(newListBox, CAIRO_TYPE.LISTBOX)
	
	return newListBox
end

------------------------------------------------------------------------------------------------------------

function TextBoxHandler( object, cairo )
	
	return function ( textbox, cstate, cairo )

		local dlen 	= string.len(textbox.data)
		local tbl 	= gSdisp.wm.KeyUp
		local shifted = 0
        local modified = 0

		local tdata = textbox.data
        object.changed = nil
        if #tbl > 0 then object.changed = true end
        -- TODO: This needs some work - would prefer this in a table of callbacks
		for k,v in pairs(tbl) do

            if v.scancode == sdl.SDL_SCANCODE_RETURN or v.scancode == sdl.SDL_SCANCODE_GRAVE then
                modified = 1

			elseif v.scancode == sdl.SDL_SCANCODE_RIGHT then
				if cstate.pos < dlen-1 then cstate.pos = cstate.pos+1 end
                modified = 1

			elseif v.scancode == sdl.SDL_SCANCODE_LEFT then
				if cstate.pos > 0 then cstate.pos = cstate.pos-1 end
                modified = 1

			elseif v.scancode == sdl.SDL_SCANCODE_DELETE then
				if cstate.pos < dlen then
					local left 	= string.sub(tdata, 1, cstate.pos)
					local right = string.sub(tdata, cstate.pos+2, dlen)
					if cstate.pos == dlen then cstate.pos = cstate.pos - 1 end
					tdata = left..right
                end
                modified = 1

			elseif v.scancode == sdl.SDL_SCANCODE_BACKSPACE then
				if cstate.pos > 0 and cstate.pos <= dlen then
					local left = string.sub(tdata, 1, cstate.pos-1)
					local right = string.sub(tdata, cstate.pos+1)
					cstate.pos = cstate.pos - 1
					tdata = left..right
                end
                modified = 1

            elseif v.mod == sdl.KMOD_RSHIFT or v.mod == sdl.KMOD_LSHIFT then
                shifted = 1

			elseif v.scancode > 0 and v.scancode < sdl.SDL_SCANCODE_CAPSLOCK and modified == 0 then

				local char1 = string.char(v.sym)
				if shifted == 1 then
					char1 = string.upper(char1)
                    if char1 == '9' then char1 = '(' end
                    if char1 == '0' then char1 = ')' end
                    if char1 == '[' then char1 = '{' end
                    if char1 == ']' then char1 = '}' end
                    if char1 == "'" then char1 = '"' end
                    if char1 == ';' then char1 = ':' end
				end
			
				if dlen == 0 then 
					tdata = char1
					cstate.pos = 0
				else
					if dlen == 1 then
						tdata = tdata..char1
						cstate.pos = 1
					else
						local left = string.sub(tdata, 1, cstate.pos)
						local right = string.sub(tdata, cstate.pos+1)
						tdata = left..char1..right
					end
				end
				cstate.pos = cstate.pos + 1
			end
		end
		
		local subtext =  string.sub( tdata, 1, cstate.pos )
		cstate.posw = cairo:GetTextSize( subtext, textbox.height )
		return tdata
	end
end

------------------------------------------------------------------------------------------------------------

function widgets:TextBox(name, left, top, width, height, target_table, col )
	
	local cw, ch = self:GetTextSize(" ", height)
	local ca, cd = self:GetFontExtents()
		
	local newTextBox = { 
		otype = CAIRO_TYPE.TEXTBOX, name=name, top=top, left=left, width=width, height=height, 
					data=target_table, color=col, cursorw = cw, cursora = cd, changed = nil
	}
	
	-- Add to a managed list?
	self:AddObject( newTextBox, CAIRO_TYPE.TEXTBOX, TextBoxHandler( newTextBox, self ) )
	
	return newTextBox
end

------------------------------------------------------------------------------------------------------------

function widgets:GetLineSize(line)

	-- When elements are added or changed, remember to set contentsize to nil
	if line.contentsize then return line.contentsize end
	local listNodes = line.nodes
	local linesize = 0
	for k,v in pairs(listNodes) do
		-- Done include "space" in the calc - space should only effect horizontal.
		if(v.size ~= nil) then 
			if((v.size > linesize) and (v.ntype ~= nil)) then linesize = v.size end 
		end
	end
	line.contentsize = linesize
	return linesize
end

------------------------------------------------------------------------------------------------------------

function widgets:RenderLine(line, left, top)
	local listNodes = line.nodes
	local tleft = left
	local linesize = 0

	for k,v in pairs(listNodes) do

		if v.ntype == CAIRO_TYPE.LIST then
			local state = self:GetListState(v.list)
			self:RenderList(state, v.cobject, tleft, top )
			tleft = tleft + v.list.width

		elseif v.ntype == CAIRO_TYPE.TEXT then
			tcolor = {r=1, g=1, b=1, a=1}
			local textsz = self:GetTextSize(v.name, v.size)
			if(v.callback) then 
				local button = self:Button(v.name, tleft, top, textsz, v.size, v.corner, v.border, v.callback, v.meta)
                if v.meta then button.meta = v.meta end
			end
			self:RenderText(v.name, tleft, top + v.size * 0.85, v.size, tcolor )
			tleft = tleft + textsz

        elseif v.ntype == CAIRO_TYPE.BUTTON then
			if v.width == nil then v.width = self:GetTextSize(v.name, v.size) end
			local button = self:Button(v.name, tleft, top, v.width, v.size, v.corner, v.border, v.callback, v.meta)
			self:RenderButton(button, 0.0)
			tleft = tleft + v.width

        elseif v.ntype == CAIRO_TYPE.IMAGE then
			v.image.scalex = v.size / v.image.width
			v.image.scaley = v.size / v.image.height
			if(v.callback) then 
				local button = self:Button(v.name, tleft, top, v.image.width * v.image.scalex, v.size, v.corner, v.border, v.callback, v.meta)
                if v.meta then button.meta = v.meta end
			end
			self:RenderImage(v.image, tleft, top, 0.0, v.callback)
			tleft = tleft + v.image.width * v.image.scalex

        elseif v.ntype == CAIRO_TYPE.EXPLODER then

			v.image.scalex = v.size / v.image.width
			v.image.scaley = v.size / v.image.height
			self:Exploder(v.name, v.image, tleft, top, v.image.width * v.image.scalex, v.size, v.corner, v.list)
			tleft = tleft + v.image.width * v.image.scalex
		end
		
		if (v.ntype == nil) and (v.size ~= nil) then
			tleft = tleft + v.size
		end
		
		-- Done include "space" in the calc - space should only effect horizontal.
		if(v.size ~= nil) then 
			if((v.size > linesize) and (v.ntype ~= nil)) then linesize = v.size end 
		end
		
	end
	return linesize
end

------------------------------------------------------------------------------------------------------------

function widgets:GetListSize(list)
	
	-- When elements are added or changed, remember to set contentsize to nil
	if list.contentsize then return list.contentsize end
	local listNodes = list.nodes
	local listsize = 0
	for k,v in pairs(listNodes) do
		local lsize = v.size
		if v.ntype == CAIRO_TYPE.HLINE then
			lsize = self:GetLineSize(v)
		end
		listsize = listsize + lsize
	end
	list.contentsize = listsize
	return listsize
end

------------------------------------------------------------------------------------------------------------
-- List Utility functions

function widgets:ListAddSpace( tbl, textsize )
    local linedata = { name = "space", size = textsize }
    table.insert( tbl, linedata )
end

------------------------------------------------------------------------------------------------------------

function widgets:ListAddText( tbl, text, textsize, callback, meta )
    local linedata = { ntype = CAIRO_TYPE.TEXT, name = text, size = textsize, callback = callback, meta = meta }
    table.insert( tbl, linedata )
end

------------------------------------------------------------------------------------------------------------

function widgets:ListAddImage( tbl, name, image, textsize, colour, callback, meta )
    local linedata = { ntype = CAIRO_TYPE.IMAGE, name = name, image = image, size = textsize, color = colour, callback = callback, meta = meta }
    table.insert( tbl, linedata )
end

------------------------------------------------------------------------------------------------------------

function widgets:ListAddButton( tbl, name, image, textsize, colour, callback, meta )
    local linedata = { ntype = CAIRO_TYPE.BUTTON, name = name, image = image, size = textsize, color = colour, callback = callback, meta = meta }
    table.insert( tbl, linedata )
end

------------------------------------------------------------------------------------------------------------

function widgets:ListAddExploder( tbl, name, image, width, height, list )
    local linedata = { ntype = CAIRO_TYPE.EXPLODER, name = name, width = width, height = height, list = list }
    table.insert( tbl, linedata )
end

------------------------------------------------------------------------------------------------------------

function widgets:ListAddLine( tbl, hline, name, size  )
    local linedata = { ntype = CAIRO_TYPE.HLINE, name = name, size = size, nodes = hline }
    table.insert( tbl, linedata )
end

------------------------------------------------------------------------------------------------------------

function widgets:GetListState(list)

	local state = {}
	if(self.listStates[list.name] == nil) then 
		state = { state=CAIRO_STATE.SO_STATES.INITIAL, move=0, scroll=0, target=1.0, selected=0 }
		self.listStates[list.name] = state
	else
		state = self.listStates[list.name]
	end
	
	return state
end

------------------------------------------------------------------------------------------------------------

function widgets:RenderList(state, list, left, top, select)

	-- If no state has been defined, then make one to match the list name (this will generate a ListName state)
	if state == nil then 
		state = self:GetListState(list)
	end

	local ttop = top
	local style = self.style
	
	list.region = { left=left-style.border_width, top=top-style.border_width, 
					width=list.width+style.border_width, height=list.height+style.border_width }

	self:ClipRegion( list.region.left, list.region.top, list.region.width, list.region.height )
	self:RenderBox( list.region.left, list.region.top, list.region.width, list.region.height, style.corner_size )
	
	-- Get list size of content - if it is too big then need to make a scroll indicator
	local listSize = self:GetListSize(list)		
	-- if need scroll control / indicators then work it out..
	if listSize > list.height then 
		if( state.scroll > 0 ) then state.scroll = 0 end
		if( state.scroll < -(listSize - list.height) ) then state.scroll = -(listSize - list.height) end
		ttop = ttop + state.scroll 
	end
		
	local listNodes = list.nodes
	for k,v in pairs(listNodes) do
		local lsize = v.size
	
		if v.ntype == CAIRO_TYPE.TEXT then
			tcolor = {r=1, g=1, b=1, a=1}
			if(v.callback) then
				local textsz = self:GetTextSize(v.name, v.size)
				local button = self:Button(v.name, left, ttop, textsz, v.size, v.corner, v.border, v.callback)
			end
			self:RenderText(v.name, left, ttop + v.size * 0.85, v.size, tcolor )

		elseif v.ntype == CAIRO_TYPE.BUTTON then
			local button = self:Button(v.name, left, ttop, list.width, v.size, v.corner, v.border, v.callback)
			self:RenderButton(button, 0.0)

		elseif v.ntype == CAIRO_TYPE.IMAGE then
			v.image.scalex = v.size / v.image.width
			local halfx = 0.5 * v.image.width * v.image.scalex  
			v.image.scaley = v.size / v.image.height
			local halfy = 0.5 * v.image.height * v.image.scaley
			if(v.callback) then 
				local button = self:Button(v.name, left, ttop, v.image.width * v.image.scalex, v.size, v.corner, v.border, v.callback)
			end
			self:RenderImage(v.image, left + halfx, ttop + halfy, 0.0, v.callback)

		elseif v.ntype == CAIRO_TYPE.EXPLODER then
		
			widgets:Exploder(v.name, v.image, left, ttop, v.width, v.height, v.corner, v.list)

		elseif v.ntype == CAIRO_TYPE.HLINE then
			lsize = self:RenderLine(v, left, ttop)
		end

        if select == k then
            self.img_select.scalex = 0.4
            self.img_select.scaley = 0.4
            self:RenderImage(self.img_select, left+list.width * 0.6, ttop, 0.0)
        end
		ttop = ttop + (lsize)
	end
	
	-- Render overlayed indicators.. for scrolling
	if listSize > list.height then 
		local scrollheight = listSize - list.height
		local left1 = left-style.border_width+list.width-self.img_arrowup.width * self.img_arrowup.scalex
		local left2 = left-style.border_width+list.width-self.img_arrowdn.width * self.img_arrowup.scalex
		local top2 = top-style.border_width+list.height-self.img_arrowdn.height * self.img_arrowup.scaley
		if( state.scroll > -scrollheight ) then self:RenderImage( self.img_arrowup, left1, top-style.border_width, 0) end
		if( state.scroll < 0 ) then self:RenderImage( self.img_arrowdn, left2, top2, 0) end  
	end
		
	self:ClipReset()
end

------------------------------------------------------------------------------------------------------------
-- SlideOut Callback just moves to next state

local function SlideOutHandler( name, cairo_obj)

	local sostate = cairo_obj.slideOutStates[name]
	
	-- Dont bother if nothing exists!
	if(sostate == nil) then return end
	
	-- Change to moving on this callback (callback is a mouse up)
	if(sostate.state == CAIRO_STATE.SO_STATES.OUT) then
		sostate.state = CAIRO_STATE.SO_STATES.MOVING_OUT	
		sostate.tween = tween(CAIRO_UI.SLIDER_TWEEN_TIME, sostate, { move=sostate.target }, 'outBounce', TweenDone, cairo_obj.slideOutStates, name)
		return		
	end
	
	if(sostate.state == CAIRO_STATE.SO_STATES.IN) then
		sostate.state = CAIRO_STATE.SO_STATES.MOVING_IN
		sostate.tween = tween(CAIRO_UI.SLIDER_TWEEN_TIME, sostate, { move=0 }, 'outBounce',  TweenDone, cairo_obj.slideOutStates, name)
		return		
	end	
end

------------------------------------------------------------------------------------------------------------
-- Return current position

function widgets:SlideOut(name, image, align, pos, size, corner, list)
	-- Work out "where" the slideout is currently.
	if(self.slideOutStates[name] == nil) then 
		state = { state=CAIRO_STATE.SO_STATES.INITIAL, move=0, scroll=0, target=list.width }
	else
		state = self.slideOutStates[name]
	end

	local style 	= self.style
	local left 		= state.move;
	local top 		= pos;
	local width 	= size
	local height 	= list.height;
	
	local lleft		= left - list.width
	local ltop		= top

	if(align == CAIRO_UI.RIGHT) 	then left = self.WIDTH - state.move - size; top = pos; lleft = self.WIDTH - state.move; end
	if(align == CAIRO_UI.TOP) 		then left = pos; top = state.move; width = list.width; height = size; state.target = list.height; lleft = left; ltop = top - list.height; end
	if(align == CAIRO_UI.BOTTOM)	then left = pos; top = self.HEIGHT - state.move - size; width = list.width; height = size;  state.target = list.height; lleft = left; ltop = top + size; end
	
	-- Draw the list
	if(state.move > 0) then	
		-- Clip within the list box
		self:RenderList(state, list, lleft, ltop)
	end	

	local tcolor = { r=1, g=1, b=1, a=1 }
	local button = self:Button(name, left, top, width, height, corner, 6 )
    if(image) then
        button = image
        button.left = left; button.top = top
        button.scalex = size / image.width; button.scaley = size / image.height
        self:RenderImage(image, button.left, button.top, 0, 1)
    else
        local angle = 0
        -- Draw the button
        if(align == CAIRO_UI.LEFT) or (align == CAIRO_UI.RIGHT) then angle = math.pi * 0.5 end
        self:RenderButton(button, angle)
    end

	local newSlideOut = { name=name, button=button, list=list }

	self.slideOutStates[name] = state
	self:AddObject( newSlideOut, CAIRO_TYPE.SLIDEOUT, coroutine.create(SlideOutHandler) )

end

------------------------------------------------------------------------------------------------------------
-- Exploder Callback just moves to next state

local function ExploderHandler(name, cairo_obj)

	-- Dont bother if nothing exists!
	--if(self.exploderStates[name] == nil) then return end
	-- Handle the object - this is a ref remember!!!
	local sostate = cairo_obj.exploderStates[name]
	
	-- Change to moving on this callback (callback is a mouse up)
	if(sostate.state == CAIRO_STATE.SO_STATES.OUT) then
		sostate.state = CAIRO_STATE.SO_STATES.MOVING_OUT	
		sostate.tween = tween(CAIRO_UI.EXPLODER_TWEEN_TIME, sostate, { move=1.0 }, 'outBounce', TweenDone, cairo_obj.exploderStates, name)
		return		
	end

	if(sostate.state == CAIRO_STATE.SO_STATES.IN) then
		sostate.state = CAIRO_STATE.SO_STATES.MOVING_IN
		sostate.tween = tween(CAIRO_UI.EXPLODER_TWEEN_TIME, sostate, { move=0 }, 'outBounce',  TweenDone, cairo_obj.exploderStates, name)
		return		
	end
end

------------------------------------------------------------------------------------------------------------
-- Return current position

function widgets:Exploder(name, image, align, x, y, hsize, vsize, corner, list)
	-- Work out "where" the exploder is currently.
	if(self.exploderStates[name] == nil) then 
		state = { state=CAIRO_STATE.SO_STATES.INITIAL, move=0, scroll=0, target=1.0 }
	else
		state = self.exploderStates[name]
	end

	local left 		= x;
	local top 		= y;
	local button 	= nil

    local aleft     = 0
    local atop      = 10
    local adir      = 0
    local aoff      = 10
    if(list.arrows == nil) then aoff = 0 end

    local tpos      = { 10, -10 }
    if(align == CAIRO_UI.RIGHT) then aleft = hsize + aoff; atop = 0.0; adir = 90; tpos = { -10, 10 } end
    if(align == CAIRO_UI.BOTTOM) then aleft = 0.0; atop = vsize + aoff; end
    if(list.arrows == nil) then tpos = nil end

	-- Draw the list
	if(state.move > 0.1) then

		cr.cairo_save(self.ctx)
		cr.cairo_translate(self.ctx, left + aleft, top + atop)
        if tpos then self:DrawTriangle( tpos, adir, 8, 16 ) end
		cr.cairo_scale(self.ctx, state.move, state.move)
		cr.cairo_translate(self.ctx, -left-aleft, -top - atop)

		self:RenderList(state, list, left+aleft, top + atop)
		cr.cairo_restore(self.ctx)
	end


    if(image) then
		button = image
		button.left = x; button.top = y
		button.scalex = hsize / image.width; button.scaley = vsize / image.height
		self:RenderImage(image, button.left, button.top, 0, 1)
	else
		button = self:Button(name, left, top, hsize, vsize, corner, 6 )
		self:RenderButton(button, 0.0)
	end

	local newExploder = { name=name, button=button, list=list }
	self.exploderStates[name] = state
	self:AddObject( newExploder, CAIRO_TYPE.EXPLODER, coroutine.create(ExploderHandler) )
	
end

------------------------------------------------------------------------------------------------------------
-- Return current position

function widgets:Panel(name, posx, posy, size, corner, list, select )
	
	local style 	= self.style
	local left 		= posx;
	local top 		= posy;
	local width 	= list.width + list.left
	local height 	= list.height + list.top;
	
	local lleft		= left + list.left
	local ltop		= top + list.top + size
	
	local state = self:GetListState(list)
	
	-- Draw the list
	-- Clip within the list box
	self:RenderList(state, list, lleft, ltop, select)

	local tcolor = { r=1, g=1, b=1, a=1 }
	local button = self:Button(name, left, top, width, size, corner, 6 )
	local newPanel = { name=name, button=button, list=list }
	
	if size > 0 then self:RenderButton(button, 0.0) end
	self:AddObject( newPanel, CAIRO_TYPE.PANEL )
end

------------------------------------------------------------------------------------------------------------
-- Really... this is what Panel should have been. Panel is a little more flexible,
--   PanelList is used for displaying a list of panel text, nothing else.

function widgets:PanelListText(name, posx, posy, headsize, textsize, width, height, textlist )

    local listid = "PanelListText"..tostring(textlist)
    local tlist = self:List(listid, 0, 0, width, height)
    local snodes = {}
    local i = 1
    for k,v in pairs(textlist) do

        local nline1 = { name="space1", size=8 }
        local nline2 = {
            { name="space1", size=2 },
            { name=v, ntype=CAIRO_TYPE.TEXT, size=textsize, color=tcolor }
        }
        local nline2ref = { name="line2", ntype=CAIRO_TYPE.HLINE, size=textsize, nodes = nline2 }
        snodes[i] = nline1; i=i+1
        snodes[i] = nline2ref; i=i+1
    end

    snodes[i] =	{ name = "space1", size=12 }; i=i+1
    tlist.nodes = snodes
    self:Panel(name, posx, posy, headsize, 0, tlist)
end

------------------------------------------------------------------------------------------------------------

local function CairoChangeFolder(callerobj, wcairo)

--print("*************", callerobj.name, wcairo.file_FileSelect)
	wcairo.file_NewFolder = callerobj.name
end

------------------------------------------------------------------------------------------------------------

local function CairoSelectFile(callerobj, wcairo)
--print("------------", callerobj.name, wcairo.file_FileSelect)
	if callerobj.name ~= "." and callerobj.name ~= ".." then
		wcairo.file_LastSelect = wcairo.file_FileSelect
		wcairo.file_FileSelect = callerobj.name
		wcairo.file_preview_obj = nil
	end
end

------------------------------------------------------------------------------------------------------------

function widgets:RenderDirectory(left, top, width, height)

	if self.currdir == nil then return end
	if self.dirlist == nil then self.dirlist = dir:listfolder(self.currdir) end
	
	-- A Content window of 'stuff' to show
	local list_assets = Gcairo:List("dirlist", 0, 0, width, height-20)
	local snodes = {}
	local i = 1
	
	local line1 = {
			{ name="space1", size=116 }
	}
	
	for k,v in pairs(self.dirlist) do
	
		local nline1 = { name="space1", size=8 }
		local nline2 = { 
			 { name="space1", size=6 },
			 { name="space1", size=18 },
			 { name="space1", size=6 },
			 { name=v.name, ftype=v.ftype, ntype=CAIRO_TYPE.TEXT, size=18 }
		}
		
		if self.file_FileSelect == v.name then 
			nline2[2] = { name=v.name, ntype=CAIRO_TYPE.IMAGE, image=self.img_select, size=18, color=tcolor } 
			self.select_file = k
		end

		if v.ftype == 2 then 
			nline2[2] = { name=v.name, ntype=CAIRO_TYPE.IMAGE, image=self.img_folder, size=18, color=tcolor, callback=CairoChangeFolder } 
			nline2[4].callback = CairoChangeFolder
		else
			nline2[4].callback = CairoSelectFile
			nline2[2].callback = CairoSelectFile
		end
		
		local nline2ref = { name="line2", ntype=CAIRO_TYPE.HLINE, size=18, nodes = nline2 }
		if v.name ~= "." then
			snodes[i] = nline1; i=i+1
			snodes[i] = nline2ref; i=i+1
		end
	end
	
	snodes[i] =	{ name = "space1", size=22 }; i=i+1
	snodes[i] =	{ name = "line1", ntype=CAIRO_TYPE.HLINE, size=18 , nodes=line1 }; i=i+1
	snodes[i] =	{ name = "space1", size=6 }; i=i+1
	list_assets.nodes = snodes
	
	--Gcairo.style.button_color = { r=0.6, g=0.3, b=0.3, a=1.0 }
	Gcairo:Panel(" "..self.currdir, left, top, 20, 0, list_assets )
	
	-- If folder has changed, then update
	if self.file_NewFolder ~= nil then 
		
		-- Handle "up one directory differently 
		if self.file_NewFolder == ".." then
			local s, e, m = string.find(self.currdir, ".*/([^/]+)")
			-- print("Found:",self.currdir,s,e,m)
			if s ~= nil and e ~= nil and m ~= nil then
				self.currdir = string.sub(self.currdir, 1, e-string.len(m)-1)
			end
			self.preview_image = nil
		else
			self.currdir = self.currdir.."/"..self.file_NewFolder
		end
		
		self.dirlist	= 	dir:listfolder(self.currdir)
		self.file_NewFolder = nil
	end
	
	if (self.file_FileSelect ~= self.file_LastSelect) and (self.file_FileSelect ~= nil) then

		local exttype = dir:getextension(self.file_FileSelect)
		--print("Extension:", exttype, self.file_FileSelect)
		local extobj = self.ExtensionFunc[exttype]
		if extobj ~= nil then
		
		--print("File:", self.currdir, self.file_FileSelect)
			extobj.func(extobj.obj, self.file_FileSelect)
			self.file_LastSelect = self.file_FileSelect
		end
	end
end

------------------------------------------------------------------------------------------------------------

function widgets:SetExtensionCallbacks(funcext)
	
	self.ExtensionFunc = funcext
end

------------------------------------------------------------------------------------------------------------

return widgets

------------------------------------------------------------------------------------------------------------
