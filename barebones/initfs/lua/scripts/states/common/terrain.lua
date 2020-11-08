------------------------------------------------------------------------------------------------------------
-- State - Terrain rendering and setup
--
-- Decription: Generates procedurally generated terrain with icons on it.
--             Allplies scrolling and clipping for display in cairo

------------------------------------------------------------------------------------------------------------

local snoise 	= require("scripts/terrain/proc_gen")
local color_maps = require("scripts/terrain/color_maps")

local tween		= require("scripts/utils/tween")

------------------------------------------------------------------------------------------------------------

local Sterrain	= NewState()

------------------------------------------------------------------------------------------------------------

-- Some reasonable defaults.

Sterrain.WINwidth		= 512
Sterrain.WINheight		= 512

Sterrain.pos 			= { x = 0.0, y = 0.0, dx = 0.0, dy = 0.0 }
Sterrain.speed			= speed
Sterrain.zoom			= 1.0
Sterrain.zoom_tween		= nil
Sterrain.x			= 256
Sterrain.y				= 256

Sterrain.image			= nil		-- Terrain image

Sterrain.cmap			= nil		-- color map for the terrain
Sterrain.reversemap		= {}
Sterrain.terrain_tiles 	= {}
Sterrain.terrain_imgs	= {}

Sterrain.regen_terrain	= false
Sterrain.tweenspeed		= 0.6

------------------------------------------------------------------------------------------------------------

function Terrain_SettingsChanged(vobj, cobj)

	cobj.regen_terrain = true
end

------------------------------------------------------------------------------------------------------------

function Terrain_ZoomDone(cobj, name)

	cobj.zoom_tween = nil
end

------------------------------------------------------------------------------------------------------------

function Terrain_ZoomIn(vobj, cobj)

	-- If already tweening.. ignore extra calls!!  TODO: could queue them up?
	if cobj.zoom_tween ~= nil then return end
	local newzoom = cobj.zoom * 1.2 
	cobj.zoom_tween = tween(cobj.tweenspeed, cobj, { zoom=newzoom }, 'outCubic',  Terrain_ZoomDone, cobj, "ZoomIn")	
end

------------------------------------------------------------------------------------------------------------

function Terrain_ZoomOut(vobj, cobj)

	-- If already tweening.. ignore extra calls!!  TODO: could queue them up?
	if cobj.zoom_tween ~= nil then return end
	if cobj.zoom < 0 then cobj.zoom = cobj.zoom + 1 end
	local newzoom = cobj.zoom * 0.8
	cobj.zoom_tween = tween(cobj.tweenspeed, cobj, { zoom=newzoom }, 'outCubic',  Terrain_ZoomDone, cobj, "ZoomOut")
end

------------------------------------------------------------------------------------------------------------
-- Generate a simple terrain mesh
--        The terrain should eventually be a GLES shader with auto lod and soft vertex blending

local gTerrainCount = 1

function Sterrain:GenerateMesh( image )

    local model = byt3dModel:New()
    local mesh = byt3dMesh:New()

    local szInd = image.width * image.height * 6
    local indices		    = ffi.new("unsigned int["..szInd.."]" )
    local szVert = image.width * image.height * 3
    local verts		 	    = ffi.new( "float["..szVert.."]" )
    local szUVs = image.width *image.height * 2
    local uvs		 	    = ffi.new( "float["..szUVs.."]" )

    local ct = 1
    for y=1, image.width do
        for x = 1, image.height do
            indices[y * image.width * 6 + x * 6] = ct
            ct = ct + 1
        end
    end

    mesh.vertBuffer 		= verts
    mesh.indexBuffer 		= indices
    mesh.texCoordBuffer 	= uvs

    local name = string.format("Dynamic Mesh Terrain(%02d)", gTerrainCount)
    print("New Terrain: "..name)
    gTerrainCount = gTerrainCount + 1;

    model.node:AddBlock(mesh, name)
    model.boundMax = { image.width, image.height, 0.0, 0.0 }
    model.boundMin = { -image.width, -image.height, 0.0, 0.0 }
    model.boundCtr[1] = (model.boundMax[1] - model.boundMin[1]) * 0.5 + model.boundMin[1]
    model.boundCtr[2] = (model.boundMax[2] - model.boundMin[2]) * 0.5 + model.boundMin[2]
    model.boundCtr[3] = (model.boundMax[3] - model.boundMin[3]) * 0.5 + model.boundMin[3]
end

------------------------------------------------------------------------------------------------------------

function Sterrain:Init(wwidth, wheight)

	
	self.WINwidth		= wwidth
	self.WINheight		= wheight
	
	self.pos 			= { x = 0.0, y = 0.0, dx = 0.0, dy = 0.0 }
	self.speed			= speed
	self.zoom			= 1.0
	self.x				= 240 + 300
	self.y				= 240
	
	self.image			= nil		-- Terrain image
	
	self.cmap			= nil		-- color map for the terrain
	self.reversemap		= {}
	self.terrain_tiles 	= {}
	self.terrain_imgs	= {}
	
	self.regen_terrain	= false
end

------------------------------------------------------------------------------------------------------------

function Sterrain:RegenTerrain()

	snoise:GenerateImage( self.image2)
--	snoise:Quantize(self.image2, 64)
--	snoise:Colorize(self.image2, self.cmap)
	
	local data = Gcairo:GetImageData(self.image2)
	
	self.terrain_imgs = {}
	local count = 1
	
--	for y=32, 511, 64 do
--		for x=32, 511, 64 do
--			local col1 = data[y * self.image2.width * 4 + x * 4 + 0]
--			local col2 = data[y * self.image2.width * 4 + x * 4 + 1]
--			local col3 = data[y * self.image2.width * 4 + x * 4 + 2]
--
--			--print(col1, col2, col3)
--			local mapnumber = col3 * 65536 + col2 * 256 + col1
--			local index = self.reversemap[mapnumber]
--			if index ~= nil then
--				if index < 50 then
--					self.terrain_imgs[count] =  { tile=self.terrain_tiles[math.random(1,2)], x=x-16, y=y-16, angle=0.0 }
--					count = count + 1
--				end
--				if index > 80 and index < 150  and math.random() > 0.6 then
--					self.terrain_imgs[count] =  { tile=self.terrain_tiles[math.random(3,4)], x=x-16, y=y-16, angle=0.0 }
--					count = count + 1
--				end
--				if index > 160  then
--					self.terrain_imgs[count] =  { tile=self.terrain_tiles[math.random(5,6)], x=x-16, y=y-16, angle=0.0 }
--					count = count + 1
--				end
--			end
--		end
--	end
	self.regen_terrain = false
end

------------------------------------------------------------------------------------------------------------

function Sterrain:Begin()	
	
	self.terrain_tiles = {}
	self.terrain_tiles[1] = Gcairo:LoadImage("mtn1", "byt3d/data/tiles/mountain.png")
	self.terrain_tiles[2] = Gcairo:LoadImage("mtn2", "byt3d/data/tiles/mountain2.png")
	self.terrain_tiles[3] = Gcairo:LoadImage("tree1", "byt3d/data/tiles/trees.png")
	self.terrain_tiles[4] = Gcairo:LoadImage("tree2", "byt3d/data/tiles/trees2.png")
	self.terrain_tiles[5] = Gcairo:LoadImage("des1", "byt3d/data/tiles/desert.png")
	self.terrain_tiles[6] = Gcairo:LoadImage("des2", "byt3d/data/tiles/desert2.png")
	
	-- Make a terrain image
--	self.cmap = color_maps:LoadPng(Gcairo, "ground", "pioneer/data/ground_only.png" )
--	color_maps:DumpCmap(Gcairo, "ground", "pioneer/data/ground_only.lua", self.cmap)
	self.cmap = color_maps.ground
	self.image2 = snoise:CreateNoiseImage(Gcairo, self.cmap)
	self.zoom = self.WINheight / self.image2.height 
	
--	for i=1, 256 do
--		local col = self.cmap[i]
--		local mapnumber = col[3] * 65536 + col[2] * 256 + col[1]
--		self.reversemap[mapnumber] = i
--	end

    Gcairo:SaveImage( "byt3d/terrain_height.png", self.image2 )
	--self:RegenTerrain()
end

------------------------------------------------------------------------------------------------------------

function Sterrain:Update(mxi, myi, buttons)

	if self.regen_terrain == true then self:RegenTerrain() end	

	--Gcairo:Translate( 300, 0 )
    Gcairo:RenderImage(self.image2, -256, -256, 0.0)
    
--    for k,v in ipairs(self.terrain_imgs) do
--    	Gcairo:RenderImage(v.tile, v.x - 256, v.y - 256, 0.0)
--    end
    
end

------------------------------------------------------------------------------------------------------------

function Sterrain:Render()	
end

------------------------------------------------------------------------------------------------------------

function Sterrain:Finish()	
	
end

------------------------------------------------------------------------------------------------------------

return Sterrain	
	
------------------------------------------------------------------------------------------------------------
	