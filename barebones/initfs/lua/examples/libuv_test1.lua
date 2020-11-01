local http = require 'uv.http'
local fs = require 'uv.fs'

http.listen('127.0.0.1', 80, function(request)
    pp("Reuqest:", request)
    local textdata = fs.readfile('/lua/examples/data/README.md')
    pp(textdata)
    return { status = 200, body = textdata }
end)
