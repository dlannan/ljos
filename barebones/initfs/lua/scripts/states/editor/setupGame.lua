------------------------------------------------------------------------------------------------------------
-- State - Setup Screen
--
-- Decription: Displays the setup components for a game (simple at first)
--             As more advanced levels are unlocked more advanced gameplay is opened.
--
-- Details:
-- 			Basic setup allows:
--			------------------------------------------------------------------------------------------------
--			Random planet selection (each planet for each game will randomize). 
--          or
--          10, 20 or 50 planet game list (these are fixed planet challenges).
--			Number of planets to play in a row (this really only applies to random planets)
--			Max AI players (1-3 for basic mode).
--			Off-world market does not interact with gameplay.
--			AI Intelligence - Simple, Medium or Hard. Playing at different levels 
--				results in different bonues and unlocks.
--
-- 			Intermediate setup allows (must unlock by winning 10 planet challenge):
--			------------------------------------------------------------------------------------------------
--			Same as basic settings. 
--			Max AI players (1-5 the more players the higher rating you get - goes into online stats)
--			Off-world market only effects Rich Metals and Rich Minerals. Food and Energy not involved.
--			AI Intelligence - Simple, Medium, Hard and Very Hard.
--			Special "disasters" occur randomly during game - can have positive or negative effect on game.
--
-- 			Advanced setup allows (must unlock by winning 20 planet challenge):
--			------------------------------------------------------------------------------------------------
--			Same as intermediate settings.
--			Max AI players (1-7)
--			Off-world market effects all resources. Food shortages off world, will impact local prices etc.
--			AI Intelligence - Simple Medium, Hard, Very Hard and Im sure they cheat!!
--			Special disasters, and also local planet weather effects harvests and so forth. Enable
--			    weather display to see the effects.
--			Can collude with AI if they are on Hard or higher. 
--			
--  TODO: put into doc. 
--			Only implement Basic to start with. 
--
------------------------------------------------------------------------------------------------------------
-- Making this global gives all modules access to it
-- Gcairo = require("pioneer/scripts/cairo_ui")

local tween		= require("scripts/utils/tween")

------------------------------------------------------------------------------------------------------------

local SsetupGame	= NewState()

------------------------------------------------------------------------------------------------------------

SsetupGame.width 	= 512
SsetupGame.height 	= 512

-- Make a nice table of icons - use sensible non colliding names
SsetupGame.icons	= {}
-- Game options to start the game with
SsetupGame.options	= {}

local bgimage		= nil

------------------------------------------------------------------------------------------------------------

function SsetupGame:Init(wwidth, wheight)

	self.width = wwidth
	self.height = wheight

	--print("Begin")
	-- Gcairo:Init(self.width, self.height)	
end

------------------------------------------------------------------------------------------------------------

function SsetupGame:Begin()	

	bgimage = Gcairo:LoadImage("bg1", "byt3d/data/bg/background-red.png")
	bgimage.scalex = self.width /  bgimage.width
	bgimage.scaley = self.height / bgimage.height

	self.icons["no-tick"] 	= Gcairo:LoadImage("icon-no-tick", "byt3d/icons/menu/validation-tick-square-1.png")
	self.icons["tick"] 		= Gcairo:LoadImage("icon-no-tick", "byt3d/icons/menu/validation-tick-1.png")
	
	-- Random game by default
	self.options.gametype = "random"
	-- 1 game by default
	self.options.gamecount = 1
	-- Game mode is basic to start with (will add others)..
	self.options.gamemode = "basic"
	
	self.options.gamecounttext = { "1 Game", "2 Games", "5 Games", "10 Games", "20 Games", "50 Games" }
	self.options.gamemodetext  = { "Basic", "Intermediate", "Advanced" }
end

------------------------------------------------------------------------------------------------------------

function ToggleRandomGame(vobj, cobj)

	if cobj.options.gametype == "random" then
		cobj.options.gametype = "preset"
	else
		cobj.options.gametype = "random"
	end
end

------------------------------------------------------------------------------------------------------------

function ToggleGameCount(vobj, cobj)

	cobj.options.gamecount = cobj.options.gamecount + 1
	if cobj.options.gamecount > 6 then cobj.options.gamecount = 1 end
end

------------------------------------------------------------------------------------------------------------

function BackToMainMenu(vobj, cobj)

	sm:ChangeState("MainMenu")
end


------------------------------------------------------------------------------------------------------------

function StartGame(vobj, cobj)

	sm:ChangeState("TerrainGame")
end

------------------------------------------------------------------------------------------------------------

function SsetupGame:Update(mxi, myi, buttons)	

	Gcairo:Begin()
	
	Gcairo:RenderImage(bgimage, 0, 0, 0.0)

	Gcairo:RenderBox(30, 30, 240, 50, 0)
	Gcairo:RenderText("PIONEER", 45, 65, 30, tcolor )
		

	local saved = Gcairo.style.button_color
	Gcairo.style.border_width = 0.0
	Gcairo.style.button_color = metro_s.green
	Gcairo:RenderBox(250, 100, 400, 50, 0)
	Gcairo:RenderText("Setup Game", 270, 130, 20)

	Gcairo.style.button_color = metro_s.purple
	Gcairo:RenderBox(250, 155, 150, 160, 0)

	Gcairo.style.button_color = metro_s.seagreen
	Gcairo:RenderBox(405, 155, 245, 50, 0)

	Gcairo.style.button_color = metro_s.orange
	Gcairo:RenderBox(405, 210, 245, 50, 0)

	Gcairo.style.button_color = metro_s.lblue
	Gcairo:RenderBox(405, 265, 245, 50, 0)
	
	-- Start Game...
	Gcairo.style.button_color = metro_s.green
	Gcairo:RenderBox(660, 370, 130, 50, 0)
	-- Back to main menu
	Gcairo.style.button_color = metro_s.lblue
	Gcairo:RenderBox(660, 30, 130, 50, 0)

	Gcairo.style.button_color = saved

	-- Render the Game Type line - handling the gametype setting
	local line = {}
	local nodes = {}
	nodes[1] = { name="Game Type", ntype=CAIRO_TYPE.TEXT, size=18 }
	nodes[2] = { name="space1", size=40 }
	nodes[3] = { name="Random", ntype=CAIRO_TYPE.TEXT, size=18, callback=ToggleRandomGame, cobject=self }
	nodes[4] = { name="RandomI1", ntype=CAIRO_TYPE.IMAGE, image=self.icons["no-tick"], size=18, callback=ToggleRandomGame, cobject=self }
	nodes[10] = { name="space1", size=40 }
	nodes[11] = { name="Preset", ntype=CAIRO_TYPE.TEXT, size=18, callback=ToggleRandomGame, cobject=self }
	nodes[12] = { name="PresetI1", ntype=CAIRO_TYPE.IMAGE, image=self.icons["no-tick"], size=18, callback=ToggleRandomGame, cobject=self }
	line.nodes = nodes

	local xpos = 492
	if self.options.gametype == "preset" then xpos = 603 end
	Gcairo:RenderImage(self.icons["tick"], xpos, 170, 0.0)
	Gcairo:RenderLine(line, 270, 170)

	-- Render the Game Count - Preset game counts unlock special extras
	line = {}
	nodes = {}
	nodes[1] = { name="Game Count", ntype=CAIRO_TYPE.TEXT, size=18 }
	nodes[2] = { name="space1", size=40 }
	nodes[3] = { name=self.options.gamecounttext[self.options.gamecount], ntype=CAIRO_TYPE.TEXT, size=18, callback=ToggleGameCount, cobject=self }
	line.nodes = nodes
	Gcairo:RenderLine(line, 270, 225)	
	
	-- Render the Game Mode - Basic game mode is only being implemented initially (thats why Intermediate and Advanced are not selectable)
	line = {}
	nodes = {}
	nodes[1] = { name="Game Mode", ntype=CAIRO_TYPE.TEXT, size=18 }
	nodes[2] = { name="space1", size=40 }
	nodes[3] = { name=self.options.gamemodetext[1], ntype=CAIRO_TYPE.TEXT, size=18 }
	line.nodes = nodes
	Gcairo:RenderLine(line, 270, 280)	
	
	-- Go and Cancel buttons
	line = { nodes = {} }
	line.nodes[1] = { name="Start", ntype=CAIRO_TYPE.TEXT, size=30, callback=StartGame }	
	Gcairo:RenderLine(line, 700, 380)	
	
	line = { nodes = {} }
	line.nodes[1] = { name="Back", ntype=CAIRO_TYPE.TEXT, size=30, callback=BackToMainMenu }	
	Gcairo:RenderLine(line, 700, 40)	
	
	Gcairo:Update(mxi, myi, buttons)
end

------------------------------------------------------------------------------------------------------------


function SsetupGame:Render()	
	--print("Render")
	Gcairo:Render()
end

------------------------------------------------------------------------------------------------------------


function SsetupGame:Finish()	

	bgimage		= nil
	Gcairo:Finish()
end

------------------------------------------------------------------------------------------------------------

return SsetupGame

------------------------------------------------------------------------------------------------------------

