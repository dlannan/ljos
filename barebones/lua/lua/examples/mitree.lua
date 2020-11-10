
local FractalTree = {

    DEPTH       = 9,
    LEAN        = 1.5,
    SPREAD 	    = 20.0,
    BRANCH      = 20.0,
    MAXSIZE	    = 10.0,
    dev         = 0.0,

    NewSeed	    = 15,
    frontCnt	= 0,
    imgBranch	= nil,
    mgFrond     = {},
        
    lastLX	= 0.0,
    lastLY	= 0.0,
    lastRX	= 0.0,
    lastRY	= 0.0,

    New     = function()
        imgBranch = Gcairo:LoadImage( "data/line001.png" )	
        imgFrond[0] = Gcairo:LoadImage( "data/frond001.png" )
    end,

    Render  = function(self) 
        dev = Sin(Millisecs()/40.0) * LEAN
        print( dev)
        -- SetBlend(0)
        -- SetAlpha(0.7)
        Seed = NewSeed
        lastLX = 370 - DEPTH * 0.5
        lastLY = 460
        lastRX = 370 + DEPTH * 0.5
        lastRY = 460
        frontCnt = math.floor(math.random(0, 3))
        self.DrawTree(370, 460, -90, DEPTH)
    end,

    DrawTree = function(x1, y1, angle, depth)

        If (depth > 0) then
            local x2 = x1 + math.floor(math.cos(angle) * depth * MAXSIZE)
            local y2 = y1 + math.floor(math.sin(angle) * depth * MAXSIZE)

            local depthMod = math.random(-0.03, 0.03)
            local tdepth = depth + depthMod
            -- local col = 0.25 - tdepth * 0.125 / DEPTH
            -- SetColor(col * 255.0, col * 255.0, col * 255.0)
            SetColor(255, 255, 255)

            -- g.setStroke(New BasicStroke(depth))
            -- g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON)
            
            --DrawLine(x1, y1, x2, y2)
            --local length = Sqrt((x2-x1) * (x2-x1) + (y2-y1) * (y2-y1)) / 256.0
            local scaleY = Float(depth) / DEPTH
            local scaleX = Float(depth) * MAXSIZE / 255.0
            
            -- Nomalized direction
            local dirX = math.sin(-angle) * depth * 0.5
            local dirY = math.cos(-angle) * depth * 0.5
            
            local newLX = x2-dirX
            local newLY = y2-dirY
            local newRX = x2+dirX
            local newRY = y2+dirY
            
            local vertices = { lastLX, lastLY, newLX, newLY,
                                        newRX, newRY, lastRX, lastRY }
            DrawPoly(vertices)
            -- DrawImage(img, x1, y1, -angle, scaleX, scaleY, 0) 
            local saved  = {lastLX, lastLY, lastRX, lastRY}
            lastLX = newLX
            lastLY = newLY
            lastRX = newRX
            lastRY = newRY
            
            local ldev = math.random(-SPREAD, SPREAD)
            local rdev = math.random(-SPREAD, SPREAD)
            local leftDev = angle - BRANCH + dev + ldev
            local rightDev = angle + BRANCH + dev + rdev
            DrawTree(x2, y2, leftDev, depth - 1)
            DrawTree(x2, y2, rightDev, depth - 1)

            lastLX = saved[0]
            lastLY = saved[1]
            lastRX = saved[2]
            lastRY = saved[3]
        else
            if (depth = 0) then
                DrawImage(imgFrond[0], x1-16, y1-16) 
            end
        end
    end
}

return FractalTree