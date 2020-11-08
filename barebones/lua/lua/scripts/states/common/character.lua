------------------------------------------------------------------------------------------------------------
-- State - Main Background Render Test
--
-- Decription: Display BG Shader

------------------------------------------------------------------------------------------------------------

sprite = require("scripts/states/sprites")
local tween		= require("scripts/utils/tween")

------------------------------------------------------------------------------------------------------------

local Scharacter	= NewState()

------------------------------------------------------------------------------------------------------------

-- Some reasonable defaults.
Scharacter.pos 			= { x = 0.0, y = 0.0, dx = 0.0, dy = 0.0 }
Scharacter.sprite		= sprite
Scharacter.speed		= 20.0		-- 1m / sec?

------------------------------------------------------------------------------------------------------------

function Scharacter:Begin()

	-- Dont forget this, it sets up all the variables.
	self.sprite:Begin()

	local walkListR = {}
	walkListR[1] = Gcairo:LoadImage("walk1", "byt3d/sprites/obj_Walk000.png")
	walkListR[2] = Gcairo:LoadImage("walk2", "byt3d/sprites/obj_Walk001.png")
	walkListR[3] = Gcairo:LoadImage("walk3", "byt3d/sprites/obj_Walk002.png")
	walkListR[4] = Gcairo:LoadImage("walk4", "byt3d/sprites/obj_Walk003.png")
	walkListR[5] = Gcairo:LoadImage("walk5", "byt3d/sprites/obj_Walk004.png")
	walkListR[6] = Gcairo:LoadImage("walk6", "byt3d/sprites/obj_Walk005.png")
	walkListR[7] = Gcairo:LoadImage("walk7", "byt3d/sprites/obj_Walk006.png")
	walkListR[8] = Gcairo:LoadImage("walk7", "byt3d/sprites/obj_Walk007.png")
		
	local walkListL = {}
	walkListL[1] = Gcairo:LoadImage("walk1", "byt3d/sprites/obj_Walk100.png")
	walkListL[2] = Gcairo:LoadImage("walk2", "byt3d/sprites/obj_Walk101.png")
	walkListL[3] = Gcairo:LoadImage("walk3", "byt3d/sprites/obj_Walk102.png")
	walkListL[4] = Gcairo:LoadImage("walk4", "byt3d/sprites/obj_Walk103.png")
	walkListL[5] = Gcairo:LoadImage("walk5", "byt3d/sprites/obj_Walk104.png")
	walkListL[6] = Gcairo:LoadImage("walk6", "byt3d/sprites/obj_Walk105.png")
	walkListL[7] = Gcairo:LoadImage("walk7", "byt3d/sprites/obj_Walk106.png")
	walkListL[8] = Gcairo:LoadImage("walk7", "byt3d/sprites/obj_Walk107.png")

	local idleList1 = {}
	idleList1[1] = Gcairo:LoadImage("idle11", "byt3d/sprites/obj_Idle000.png")
	idleList1[2] = Gcairo:LoadImage("idle12", "byt3d/sprites/obj_Idle001.png")
	idleList1[3] = Gcairo:LoadImage("idle13", "byt3d/sprites/obj_Idle002.png")
	idleList1[4] = Gcairo:LoadImage("idle14", "byt3d/sprites/obj_Idle003.png")

	local idleList2 = {}
	idleList2[1] = Gcairo:LoadImage("idle21", "byt3d/sprites/obj_Idle100.png")
	idleList2[2] = Gcairo:LoadImage("idle22", "byt3d/sprites/obj_Idle101.png")
	idleList2[3] = Gcairo:LoadImage("idle23", "byt3d/sprites/obj_Idle102.png")
	idleList2[4] = Gcairo:LoadImage("idle24", "byt3d/sprites/obj_Idle103.png")

	local jumpjoyList = {}
	jumpjoyList[1] = Gcairo:LoadImage("jumpjoy1", "byt3d/sprites/obj_JumpJoy000.png")

	local jumpjoyList2 = {}
	jumpjoyList2[1] = Gcairo:LoadImage("jumpjoy1", "byt3d/sprites/obj_JumpJoy100.png")
	
	self.sprite:AddImageList(walkListR, "walkR", 1)
	self.sprite:AddImageList(walkListL, "walkL", 1)
	self.sprite:AddImageList(idleList1, "idleR", 1)
	self.sprite:AddImageList(idleList2, "idleL", 1)
	self.sprite:AddImageList(jumpjoyList, "jumpjoy1", 1)
	self.sprite:AddImageList(jumpjoyList2, "jumpjoy2", 1)
	
	self.sprite.visible = 1
	self.sprite.animated = 1

	-- Setup some offsets so the pivot is somewhere near the feet of the character
	self.sprite.xoff = -20
	self.sprite.yoff = -65

	self.sprite:PlayAnim("idleR", 1, 8)
end

------------------------------------------------------------------------------------------------------------

function Sprite_Done(char, action)
	
	tween.stop(char.tweenx)
	tween.stop(char.tweeny)

	-- print("Finished movement: ", char.sprite.current_action)
	if char.sprite.current_action == "walkR" or char.sprite.current_action == "idleR" then
		char.sprite:PlayAnim("idleR", 1, 8)
	else
		char.sprite:PlayAnim("idleL", 1, 8)
	end
end

------------------------------------------------------------------------------------------------------------

function Scharacter:WalkTo(nx, ny, factor, obj)
	--print("walking to: ", nx, ny)
	-- distance to walk
	local target = self.sprite
	if obj ~= nil then target = obj end
	
	local xdiff = nx - target.x
	local ydiff = ny - target.y
	local distance = math.sqrt( xdiff * xdiff + ydiff * ydiff )
	local move_time = distance * factor / self.speed
	
	-- Dont do anything if there is no distance to travel
	if(distance == 0.0) then return end

	if xdiff < 0.0 then 
		self.sprite:PlayAnim("walkL", 1, 8)
	else
		self.sprite:PlayAnim("walkR", 1, 8)
	end
	
	-- clear any previous tweens
	tween.stop(self.tweenx)
	tween.stop(self.tweeny)
	
	self.tweenx = tween(move_time, target, { x=nx }, 'linear',  Sprite_Done, self, "WalkToX")
	self.tweeny = tween(move_time, target, { y=ny }, 'linear',  Sprite_Done, self, "WalkToY")
end

------------------------------------------------------------------------------------------------------------

function Scharacter:Update(mxi, myi, buttons)
	self.sprite:Update(mxi, myi, buttons)
end

------------------------------------------------------------------------------------------------------------

function Scharacter:Render()
	self.sprite:Render()
end

------------------------------------------------------------------------------------------------------------

function Scharacter:Finish()
	self.sprite:Finish()
end
	
------------------------------------------------------------------------------------------------------------

return Scharacter

------------------------------------------------------------------------------------------------------------
