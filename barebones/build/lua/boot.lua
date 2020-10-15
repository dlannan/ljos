local ffi = require("ffi")
require("pprint")
local tm = math.floor(os.clock())

local tbl = {
    stuff   = "Stuff",
    num     = 1.0,
    sub     = {
        d1  = 0xffff,
        d2  = "More stuff.",
        d3  = ffi.new("char[?]", 10),
    },
}

while tm < 5 do

	local thistm = math.floor(os.clock())
	if( thistm ~= tm ) then
		print("Hello...", tm)
		tm = thistm
	end
end

p("Testing Pretty Print.")
p(tbl)

-- ffi.cdef[[
-- unsigned int sleep(unsigned int seconds);
-- ]]

-- while true do
-- 	print("Better Hello..")
-- 	ffi.C.sleep(1)
-- end
