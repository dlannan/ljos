------------------------------------------------------------------------------------------------------------

local text = {}

------------------------------------------------------------------------------------------------------------
-- Draw some text on the surface somewhere
function text:RenderText( str, posx, posy, fsize, color)

	if(str == nil) then return end
	if(color == nil) then color = { r=1, g=1, b=1, a=1 } end
	
	cr.cairo_set_font_size(        self.ctx, fsize )
	cr.cairo_set_source_rgba(   self.ctx, color.b, color.g, color.r, color.a );  	
	cr.cairo_line_to(           self.ctx, posx, posy );          	
	cr.cairo_show_text(         self.ctx, str);                	
end

------------------------------------------------------------------------------------------------------------
-- Get "vector point size" of text draw with a particular font at particular font size.
--     Returns width, height

function text:GetTextSize( str, fsize)

	if(str == nil) then return 0, 0; end
	if string.len(str) < 1 then return 0, 0; end
	color = { r=1, g=1, b=1, a=1 }

	local textext = ffi.new('cairo_text_extents_t')	
	cr.cairo_set_font_size(     self.ctx, fsize )
	cr.cairo_text_extents( 		self.ctx, str, textext )	
	return textext.width, textext.height
end

------------------------------------------------------------------------------------------------------------

function text:GetFontExtents( )

	if self.font_ascent == nil and self.font_descent == nil then
		local fontext = ffi.new( "cairo_font_extents_t" )
		cr.cairo_font_extents( self.ctx, fontext )
		self.font_ascent = fontext.ascent
		self.font_descent = fontext.descent
	end 
	return  self.font_ascent, self.font_descent
end

------------------------------------------------------------------------------------------------------------

return text

------------------------------------------------------------------------------------------------------------
