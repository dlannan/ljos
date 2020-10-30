
pp(package.cpath)
local uv = require('luv')

local function create_server(host, port, on_connection)

  local server = uv.new_tcp()
  server:bind(host, port)

  server:listen(128, function(err)
    -- Make sure there was no problem setting up listen
    assert(not err, err)

    -- Accept the client
    local client = uv.new_tcp()
    server:accept(client)

    on_connection(client)
  end)

  return server
end

local server = create_server("0.0.0.0", 0, function (client)

  client:read_start(function (err, chunk)

    -- Crash on errors
    assert(not err, err)

    if chunk then
      -- Echo anything heard
      client:write(chunk)
    else
      -- When the stream ends, close the socket
      client:close()
    end
  end)
end)

print("TCP Echo server listening on port " .. server:getsockname().port)

uv.run()
