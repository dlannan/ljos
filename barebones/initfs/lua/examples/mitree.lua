
require("scripts/utils/copy")

local function getRandom(minr, maxr)
    local scale  = maxr - minr
    return math.random() * scale + minr
end

local function milliSec(self)
    local ms = (os.clock() - self.start) * 1000.0
    -- self.start = os.clock()
    return ms 
end

Gcairo.style.image_color = {r=0.3, g=0.3, b=0.7, a=0.6}
local FractalTree = {

    DEPTH       = 9,
    LEAN        = 1.5,
    SPREAD 	    = 20.0,
    BRANCH      = 20.0,
    MAXSIZE	    = 10.0,

    xscale 	= 0.8,
    yscale 	= 1.1,
    orig        = { x=500, y=550 },
    color       = {r=0.3, g=0.3, b=0.7, a=0.6},
    dev         = 0.0,
    start       = os.clock(),

    NewSeed	    = 15,
    frontCnt	= 0,
    imgBranch	= nil,
    imgFrond    = {},
        
    lastLX	= 0.0,
    lastLY	= 0.0,
    lastRX	= 0.0,
    lastRY	= 0.0,

    Render  = function(self) 
        self.dev = math.sin(math.rad(milliSec(self)/40.0)) * self.LEAN
        -- SetBlend(0)
        -- SetAlpha(0.7)
        math.randomseed(self.NewSeed)
        self.lastLX = self.orig.x - self.DEPTH * 0.5
        self.lastLY = self.orig.y
        self.lastRX = self.orig.x + self.DEPTH * 0.5
        self.lastRY = self.orig.y
        self.frontCnt = math.random(0, 3)
        self:DrawTree(self.orig.x, self.orig.y, -90, self.DEPTH)
    end,

    DrawTree = function(self, x1, y1, angle, depth)

        if(depth > 0) then
            local x2 = x1 + math.floor(math.cos(math.rad(angle)) * depth * self.MAXSIZE) * self.xscale
            local y2 = y1 + math.floor(math.sin(math.rad(angle)) * depth * self.MAXSIZE) * self.yscale

            local depthMod = getRandom(-0.03, 0.03)
            local tdepth = depth + depthMod
            -- local col = 0.25 - tdepth * 0.125 / DEPTH
            -- SetColor(col * 255.0, col * 255.0, col * 255.0)

            -- g.setStroke(New BasicStroke(depth))
            -- g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON)
            
            --DrawLine(x1, y1, x2, y2)
            --local length = Sqrt((x2-x1) * (x2-x1) + (y2-y1) * (y2-y1)) / 256.0
            local scaleY = depth / self.DEPTH
            local scaleX = depth * self.MAXSIZE / 255.0
            
            -- Nomalized direction
            local dirX = math.sin(-math.rad(angle)) * depth * 0.5
            local dirY = math.cos(-math.rad(angle)) * depth * 0.5
            
            local newLX = x2-dirX
            local newLY = y2-dirY
            local newRX = x2+dirX
            local newRY = y2+dirY
            
            local vertices = { self.lastLX, self.lastLY, newLX, newLY,
                                        newRX, newRY, self.lastRX, self.lastRY }
            Gcairo:DrawPolyline(vertices, self.color, 0.3 )
            -- DrawImage(img, x1, y1, -angle, scaleX, scaleY, 0) 
            local saved  = { llx=self.lastLX, lly=self.lastLY, lrx=self.lastRX, lry=self.lastRY }
            self.lastLX = newLX
            self.lastLY = newLY
            self.lastRX = newRX
            self.lastRY = newRY
            
            local ldev = getRandom(-self.SPREAD, self.SPREAD)
            local rdev = getRandom(-self.SPREAD, self.SPREAD)
            local leftDev = angle - self.BRANCH + self.dev + ldev
            local rightDev = angle + self.BRANCH + self.dev + rdev
            self:DrawTree(x2, y2, leftDev, depth - 1)
            self:DrawTree(x2, y2, rightDev, depth - 1)

            self.lastLX = saved.llx
            self.lastLY = saved.lly
            self.lastRX = saved.lrx
            self.lastRY = saved.lry
        else
            if (depth == 0) then
                Gcairo:RenderImage(self.imgFrond[1], x1-16, y1-16, 0.0) 
            end
        end
    end,
}

local FTree = {
    New     = function()

        local newtree = deepcopy(FractalTree)
        newtree.imgBranch = Gcairo:LoadImage( "line001", "lua/examples/data/line001.png" )	
        newtree.imgFrond[1] = Gcairo:LoadImage( "frond001", "lua/examples/data/frond001.png" )
        return newtree
    end,
}
return FTree
