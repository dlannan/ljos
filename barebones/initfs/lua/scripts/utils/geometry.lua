------------------------------------------------------------------------------------------------------------

function InRegion(obj, mx, my)

	local wide = obj.width
	local high = obj.height
	-- check for scale and apply
	if(obj.scalex ~= nil) then wide = wide * obj.scalex end
	if(obj.scaley ~= nil) then high = high * obj.scaley end

	if obj.left < mx and obj.left + wide > mx and obj.top < my and obj.top + high > my then
		return true
	else
		return false
	end
end

------------------------------------------------------------------------------------------------------------