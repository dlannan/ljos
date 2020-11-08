
------------------------------------------------------------------------------------------------------------
-- Convert html typw colour string to rgb table
--      Must be format SVG - mX,Y|X,Y|X,Y|X,Yz

function ConvertToPath(htmlC)
	-- strip off start and end letters first
	local htmlN = string.sub(htmlC, 2, -2).."l"
	-- Get the seperation pairs of X,Y 
	local xycount = 1 
	local xypairs = {}
	string.gsub(htmlN, "([%d%-]+),([%d%-]+)l", function (a,b)
		xypairs[xycount] = { x=tonumber(a), y=tonumber(b) }
		xycount = xycount + 1
	end )
	return xypairs
end

------------------------------------------------------------------------------------------------------------
-- Convert html typw colour string to rgb table
--      Must be format #000000

function ConvertToRGB(htmlC)

	local hexstr = "0x"..string.sub(htmlC, 2, 7)
	local hex = bit.tobit(hexstr)
	
	r = bit.rshift(hex, 16)
	g = bit.rshift( bit.band( hex, 0x00ff00 ) , 8)
	b = bit.band( hex, 0x0000ff )
	local newColor = { r=r, g=g, b=b }  
	return newColor
end

------------------------------------------------------------------------------------------------------------