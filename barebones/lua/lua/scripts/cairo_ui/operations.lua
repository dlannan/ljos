-----------------------------------------------------------------------------------------------------------

local operations = {}

-----------------------------------------------------------------------------------------------------------
-- Set the clipping region

function operations:ClipRegion(x1, y1, x2, y2)

	cr.cairo_rectangle(self.ctx, x1, y1, x2, y2)
	cr.cairo_clip(self.ctx)
end

------------------------------------------------------------------------------------------------------------
-- Reset the clipping region

function operations:ClipReset()

	cr.cairo_reset_clip(self.ctx)
end

------------------------------------------------------------------------------------------------------------
-- Push the current state (saves it)

function operations:PushState(scalex, scaley)

	cr.cairo_save(self.ctx)
end

------------------------------------------------------------------------------------------------------------
-- Pop the previous state (restores it)

function operations:PopState()

	cr.cairo_restore(self.ctx)
end

------------------------------------------------------------------------------------------------------------

function operations:Scale(scalex, scaley)
	cr.cairo_scale(self.ctx, scalex, scaley)
end

------------------------------------------------------------------------------------------------------------

function operations:Translate(transx, transy)
	cr.cairo_translate(self.ctx, transx, transy)
end

------------------------------------------------------------------------------------------------------------

function operations:Rotate(angle)
	cr.cairo_rotate(self.ctx, angle)
end

------------------------------------------------------------------------------------------------------------

function operations:DrawTriangle( pt, dir, high, base )

    -- dir is angle
    -- 0 to 360 degrees
    -- high is height of triangle
    -- base is width of triangle base

    -- work out the other two points.
    local viewdir = { math.sin(math.rad(dir)), math.cos(math.rad(dir)) }
    local ptonbase = { pt[1] + viewdir[1] * high, pt[2] + viewdir[2] * high }
    local pt2 = { ptonbase[1] + viewdir[2] * base * 0.5, ptonbase[2] + viewdir[1] * base * 0.5 }
    local pt3 = { ptonbase[1] - viewdir[2] * base * 0.5, ptonbase[2] - viewdir[1] * base * 0.5 }

    cr.cairo_save(self.ctx)
    cr.cairo_move_to(self.ctx, pt[1], pt[2])
    cr.cairo_line_to(self.ctx, pt2[1], pt2[2])
    cr.cairo_line_to(self.ctx, pt3[1], pt3[2])

    cr.cairo_close_path(self.ctx)
    cr.cairo_stroke_preserve(self.ctx)

    cr.cairo_fill( self.ctx )
    cr.cairo_restore(self.ctx)

end



------------------------------------------------------------------------------------------------------------

return operations

------------------------------------------------------------------------------------------------------------
