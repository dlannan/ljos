local http = require 'uv.http'
local fs = require 'uv.fs'

http.listen('0.0.0.0', 8080, function(request)
    pp("Reuqest:", request)
    local textdata = fs.readfile('/lua/examples/data/README.md')
    pp(textdata)
    return { status = 200, body = textdata }
end)
