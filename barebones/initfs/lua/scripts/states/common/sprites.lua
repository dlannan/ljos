------------------------------------------------------------------------------------------------------------
-- State - Sprite handler
--
-- Decription: Images are submitted to the state for animated or movement
--				playback. The state acts as a contained object controller
--			    that looks after "what a sprite can do"

-- Notes: Uses cairo_ui images and uses simple vector and angle for 2D
--        operations.

------------------------------------------------------------------------------------------------------------

if(Gcairo == nil) then Gcairo = require("scripts/cairo_ui") end

------------------------------------------------------------------------------------------------------------

local Ssprite	= NewState()

------------------------------------------------------------------------------------------------------------

Ssprite.image_count 	= 0
Ssprite.images			= {}
Ssprite.start_time		= 0.0
Ssprite.end_time		= 0.0
Ssprite.current_time 	= 0.0
Ssprite.current_action 	= nil
Ssprite.frame_speed 	= 30.0
Ssprite.frame_rate 		= 30.0
Ssprite.frame_count		= 0
Ssprite.actions 		= {}

Ssprite.visible 		= 0
Ssprite.animated		= 0
Ssprite.x 				= 0
Ssprite.y 				= 0
Ssprite.xoff 			= 0  -- Used to define a internal "pivot point" on the sprite.
Ssprite.yoff			= 0

Ssprite.angle 			= 0.0
Ssprite.dx 				= 0.0
Ssprite.dy 				= 0.0
Ssprite.length 			= 0.0

------------------------------------------------------------------------------------------------------------

function Ssprite:AddAction(action)

	local laction = self.actions[action]
	if(laction == nil) then
		-- Adding new action
		--print("adding new sprite action: "..action)
		self.actions[action] = { }
	end
end

------------------------------------------------------------------------------------------------------------
-- Add a cairo image to the image list for the sprite.
-- Assign the image to a specific action and index within the action

function Ssprite:AddImage( image, action, index )
	
	if(index == nil) then index = 1 end
	-- Add the image to the image list - hold the id of the index to it.
	self.image_count = self.image_count + 1
	self.images[self.image_count] = image
	
	-- Make sure action exists (creates it if not)
	self:AddAction(action)
	local action_table = self.actions[action]
	action_table[index] = self.image_count
	--print("Adding image: "..self.image_count.."  to index: "..index)
end

------------------------------------------------------------------------------------------------------------
-- Add a cairo image to the image list for the sprite.
-- Assign the imageList to a specific action and start index within the action

function Ssprite:AddImageList( imagelist, action, index )

	if(index == nil) then index = 1 end
	local icount = index
	for k,v in ipairs(imagelist) do
		self:AddImage(v, action, icount)
		icount = icount + 1
	end
end

------------------------------------------------------------------------------------------------------------
-- Set an animation playing
--  	set the action time length.

function Ssprite:PlayAnim( action, start_frame, frame_speed )

	-- default to 30 fps which is pretty standard for animation frames.
	if(frame_speed == nil) then frame_speed = 30.0 end
	if(start_frame == nil) then start_frame = 1 end
	self.frame_speed = 1.0 / frame_speed
	self.frame_rate = frame_speed
	
	if(self.actions[action] == nil) then print("Cannot find action: "..action); return end
	action_list = self.actions[action]
	self.frame_count = table.getn(action_list)
	-- print("Action Table: "..action.."  is size: "..self.frame_count)
		
	self.start_time 		= os.clock();
	self.current_time 		= 0.0;
	self.end_time 			= self.frame_count * self.frame_speed 
	self.current_action 	= action
end

------------------------------------------------------------------------------------------------------------
-- Set an animation to stop 
--  	set the action time length.

function Ssprite:StopAnim( action )
	self.frame_speed = 0.0
end

------------------------------------------------------------------------------------------------------------

function Ssprite:Begin()

	self.image_count 	= 0
	self.images			= {}
	self.start_time 	= 0.0
	self.end_time		= 0.0
	self.current_time 	= 0.0
	self.current_action = nil
	self.frame_speed 	= 30.0
	self.frame_rate 	= 30.0
	self.actions 		= {}

	self.visible 		= 0
	self.animated		= 0
	self.x 				= 0
	self.y 				= 0
	self.angle 			= 0.0
	self.dx 			= 0.0
	self.dy 			= 0.0
end

------------------------------------------------------------------------------------------------------------
-- Do movement and current anim frame update calculations

function Ssprite:Update(mxi, myi, buttons)

	-- If anim stopped then hold time for render (anim pause)
	if (self.animated == 1) and (self.frame_speed ~= 0.0) then
		self.current_time = os.clock() - self.start_time
		if(self.current_time >= self.end_time) then 
			self.start_time = os.clock() 
			self.current_time = self.current_time - self.end_time 
		end
	end
end

------------------------------------------------------------------------------------------------------------

function Ssprite:Render()

	if self.visible == 0 then return end
	-- If no action selected then no point continuing
	if self.current_action == nil then return end
	
	local aframe = math.floor( (self.current_time / self.end_time) * self.frame_count )
	-- print(aframe, self.current_time, self.end_time)
	if (aframe + 1) > self.frame_count then aframe = 0 end
	 
	-- print(self.current_action, self.current_time, self.frame_count)
	local laction = self.actions[self.current_action]
	-- All lists are index offset by one (like lua)
	local image_index = laction[aframe + 1]		
	local image = self.images[image_index]
	
	Gcairo:RenderImage(image, self.x + self.xoff, self.y + self.yoff, self.angle)
end

------------------------------------------------------------------------------------------------------------

function Ssprite:Finish()
end
	
------------------------------------------------------------------------------------------------------------

return Ssprite

------------------------------------------------------------------------------------------------------------
