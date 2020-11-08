local social = require"social"
--------------------------------
local mime = require"mime" -- luarocks install luasocket
local url = require"socket.url" -- luasocket
local json = require"json" -- json4lua

--- SocialLua - Google module.
-- This module does not work at all as of yet.
-- @author Linus Sjögren (thelinx@unreliablepollution.net)
module("social.google", package.seeall) -- seeall for now

function full(page)
    return "https://www.google.com/"..page
end

client = {}
local cl_mt = { __index = client }

--- Creates a new Google client
-- For a list of services' names see http://code.google.com/apis/gdata/faq.html#clientlogin
-- For a howto on your client's name see http://code.google.com/apis/contacts/docs/3.0/developers_guide_protocol.html#client_login
function client:new(service, name)
    return setmetatable({service = assert(service, "you need to specify a service"), source = assert(name, "you need to specify your client's name"), authed = false}, cl_mt)
end


function client:login(email, password)
    local s,d,h,c = social.post(full("accounts/ClientLogin"), {
        accountType = "HOSTED_OR_GOOGLE",
        Email = email,
        Passwd = password,
        service = self.service,
        source = self.source
    })
    print(full("accounts/ClientLogin"),s,d,h,c)
end