local http = require 'uv.http'
local fs = require 'uv.fs'

http.listen('127.0.0.1', 8080, function(request)
  return { status = 200, body = fs.readfile('README.md') }
end)
