------------------------------------------------------------------------------------------------------------
-- This allows button rendering to be deferred if needed

------------------------------------------------------------------------------------------------------------

local widget_handlers = {}

------------------------------------------------------------------------------------------------------------

widget_handlers.widget_handlers = {}
		
------------------------------------------------------------------------------------------------------------

function widget_handlers:PanelHandler(v, mx, my, buttons)

	local obj = v.cobject
	local list = obj.list
	-- Check the button area
	if(InRegion(list.region, mx, my) == true) then
	
	-- print("PanelScroll:",mx,my,obj.name)
		-- self:CheckListScroll(buttons, mx, my, obj, panels)
		--if v.callback then coroutine.resume(v.callback, obj.name, self) end
	end
end

------------------------------------------------------------------------------------------------------------

widget_handlers.widget_handlers[CAIRO_TYPE.PANEL] = widget_handlers.PanelHandler

------------------------------------------------------------------------------------------------------------

function widget_handlers:ListBoxHandler(v, mx, my, buttons)

	local obj = v.cobject
	-- Check panel clicks (this should be genericised)
	local liststate = self.listStates[v.name]
	-- Check the list area

	if liststate then self:CheckListScroll(buttons, mx, my, obj.region, liststate) end
	if v.callback then
		local handler = v.callback
		handler( self, obj, self)
	end
end

------------------------------------------------------------------------------------------------------------

widget_handlers.widget_handlers[CAIRO_TYPE.LISTBOX] = widget_handlers.ListBoxHandler

------------------------------------------------------------------------------------------------------------
		
function widget_handlers:TextBoxHandler(v, mx, my, buttons)

	local obj = v.cobject
	-- Check data entry for input box

	-- Set all cursors off.. every update. Then the only active one can be used.
	if(InRegion(obj, mx, my) == true) then
		-- To activate a textbox click in it.
		if buttons[1] == false and self.lastMouseButton[1] == true then
			self.currentCursor = obj.name
		end				
	end

    self:ClipRegion( obj.left, obj.top, obj.width, obj.height )
    self:RenderText( obj.data, obj.left, obj.top+obj.height-obj.cursora, obj.height, obj.color )

	if obj.name == self.currentCursor then
		-- Call the TextBox handler.. this looks after character control etc.
		local cstate 	= self.cursorStates[v.name]
		local posw 		= 0
		if cstate ~= nil then
			if v.callback then 
				local handler = v.callback
				obj.data = handler( obj, cstate, self ) 
			end
			posw = cstate.posw
		end

        self:RenderCursor(obj.name, obj.left+posw, obj.top, obj.cursorw, obj.height, self.cursorFlash)
    end

    self:ClipReset()
end

------------------------------------------------------------------------------------------------------------

widget_handlers.widget_handlers[CAIRO_TYPE.TEXTBOX] = widget_handlers.TextBoxHandler

------------------------------------------------------------------------------------------------------------
		
function widget_handlers:ButtonHandler(v, mx, my, buttons)

	local obj = v.cobject

	-- Other types have been handled, we only really care if this object has a callback! if it is a TEXT object or
	-- a Button object or and Image object. We should be able to callback them all.		
	if(InRegion(obj, mx, my) == true) then
		if buttons[1] == false and self.lastMouseButton[1] == true then

			if v.callback ~= nil then 
				v.data = v.callback( v, self )
				-- print("Button: "..obj.left..","..obj.top..","..obj.width..","..obj.height.."     MouseMove:"..mx..","..my)
			end
		end
	end
end 

------------------------------------------------------------------------------------------------------------

widget_handlers.widget_handlers[CAIRO_TYPE.BUTTON] = widget_handlers.ButtonHandler

------------------------------------------------------------------------------------------------------------
			
function widget_handlers:ExploderHandler(v, mx, my, buttons)

	local obj = v.cobject

	-- Check exploder clicks (this should be genericised)
	local exploder = self.exploderStates[obj.name]
	if(InRegion(obj.button, mx, my) == true) then

		if buttons[1] == false and self.lastMouseButton[1] == true then
	
			-- Deal with the slideouts
			if exploder.state == CAIRO_STATE.SO_STATES.MOVING_OUT then
				exploder.state = CAIRO_STATE.SO_STATES.IN
			end
			if (exploder.state == CAIRO_STATE.SO_STATES.MOVING_IN) or (exploder.state == CAIRO_STATE.SO_STATES.INITIAL) then
				exploder.state = CAIRO_STATE.SO_STATES.OUT
			end
		end
	end
	
	self:CheckListScroll(buttons, mx, my, obj.list.region, exploder)
	self.exploderStates[obj.name] = exploder
	if v.callback then coroutine.resume(v.callback, obj.name, self) end
end

------------------------------------------------------------------------------------------------------------

widget_handlers.widget_handlers[CAIRO_TYPE.EXPLODER] = widget_handlers.ExploderHandler

------------------------------------------------------------------------------------------------------------
			
function widget_handlers:SlideoutHandler(v, mx, my, buttons)

	local obj = v.cobject
		
	-- Check the button area
	local bo = obj.button
	local slideout = self.slideOutStates[obj.name]
	if(InRegion(bo, mx, my) == true) then
		if buttons[1] == false and self.lastMouseButton[1] == true then
		
			-- Deal with the slideouts
			if slideout.state == CAIRO_STATE.SO_STATES.MOVING_OUT then
				slideout.state = CAIRO_STATE.SO_STATES.IN
			end
			if (slideout.state == CAIRO_STATE.SO_STATES.MOVING_IN) or (slideout.state == CAIRO_STATE.SO_STATES.INITIAL) then
				slideout.state = CAIRO_STATE.SO_STATES.OUT
			end
			self.slideOutStates[obj.name] = slideout
		end
	end

	self:CheckListScroll(buttons, mx, my, obj.list.region, slideout)
	self.slideOutStates[obj.name] = slideout
	if v.callback then coroutine.resume(v.callback, obj.name, self) end
end

------------------------------------------------------------------------------------------------------------

widget_handlers.widget_handlers[CAIRO_TYPE.SLIDEOUT] = widget_handlers.SlideoutHandler

------------------------------------------------------------------------------------------------------------
	
return widget_handlers

------------------------------------------------------------------------------------------------------------

	