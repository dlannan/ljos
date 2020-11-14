math.randomseed(os.time()*10000000)

local ffi = require("ffi")
ffi.cdef[[
int sleep(int useconds);
]]

local lfb = require("lua/ffi/libfb")

lfb.fillscr(0x00FF00)

for i = 0, 5000 do 
	x = math.random() * 100
	p = math.random() * 100
	x1 = x % 100 * (lfb.width / 100)
	x2 = p % 100 * (lfb.width / 100)
	y1 = x * (lfb.height / 100)
	y2 = p * (lfb.height / 100)
	lfb.fillbox(x1, x2, y1, y2, ffi.cast("int", math.random()*0x0F0F0F0F))
	lfb.refresh()
--	ffi.C.sleep(1)
end

