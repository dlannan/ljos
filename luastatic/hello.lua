
local tm = math.floor(os.clock())
while tm < 5 do

	local thistm = math.floor(os.clock())
	if( thistm ~= tm ) then
		print("Hello...", tm)
		tm = thistm
	end
end

local ffi = require("ffi")
ffi.cdef[[
unsigned int sleep(unsigned int seconds);
]]

while true do
	print("Better Hello..")
	ffi.C.sleep(1)
end
