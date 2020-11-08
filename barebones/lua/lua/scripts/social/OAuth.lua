local http = require"socket.http" -- luarocks install luasocket
local mime = require"mime" -- luasocket
local url = require"socket.url" -- luasocket
local ltn12 = require"ltn12" -- luasocket

require("social.sha1")
local sha1,hmac_sha1 = sha1,hmac_sha1

local pairs,print,type,assert= pairs,print,type,assert
local mathRandom = math.random
local osTime = os.time
local stringFormat = string.format
local tableConcat,tableSort = table.concat,table.sort

--- SocialLua
-- @author Bart van Strien (bart.bes@gmail.com)
-- @author Linus Sjögren (thelinxswe@gmail.com)
module("social")

--- Generates GET arguments from a table.
-- @param t Table to convert.
-- @return The Get arguments, as a string.
function tabletoget(t)
	local s = "?"
	for k,v in pairs(t) do
		s = stringFormat("%s%s=%s&", s, url.escape(k), url.escape(v))
	end
	return s:sub(1,-2)
end

--- Generates POST arguments from a table.
-- @param t Table to convert.
-- @return The POST arguments, as a string.
function tabletopost(t)
	return tabletoget(t):sub(2)
end

--- Generates a Basic authentication string.
-- @param username Username
-- @param password Password
-- @return The Basic authentication string.
function authbasic(username, password)
	return "Basic "..mime.b64(username..":"..password)
end

--- Generates a OAuth authentication string.
-- @param indata A table with all the data.
function authoauth(indata)
	local t = {
		oauth_consumer_key = indata.consumerKey or indata,
		oauth_nonce = indata.nonce or sha1(osTime()..mathRandom(100)..mathRandom(100)),
		oauth_signature_method = indata.signatureMethod or "HMAC-SHA1",
		oauth_timestamp = indata.timestamp or osTime(),
		oauth_version = indata.version or "1.0"
	}
	return "OAuth "..
	'realm="'..(indata.realm or "")..'", '..
	'oauth_nonce="'..t.oauth_nonce..'", '..
	'oauth_timestamp="'..t.oauth_timestamp..'", '..
	'oauth_consumer_key="'..t.oauth_consumer_key..'", '..
	'oauth_signature_method="'..t.oauth_signature_method..'", '..
	'oauth_version="'..t.oauth_version..'", '..
	'oauth_signature="'..mime.b64(hmac_sha1(""..
	indata.method:upper().."&"..
	url.escape(indata.url).."&"..
	url.escape(
	"oauth_consumer_key="..t.oauth_consumer_key.."&"..
	"oauth_nonce="..t.oauth_nonce.."&"..
	"oauth_signature_method="..t.oauth_signature_method.."&"..
	"oauth_timestamp="..t.oauth_timestamp.."&"..
	"oauth_version="..t.oauth_version), indata.consumerSecret.."&"..(indata.tokenSecret or "")
	))..'"'
end

--- Makes a request.
-- This is a back-end function.
function request(method, url, auth, data)
	print(method, url, auth, data)
	local out = {}
	local r,c,h = http.request{
		url = url,
		method = method:upper(),
		headers = { authorization = auth, ["content-type"] = (data and "application/x-www-form-urlencoded"), ["content-length"] = (data and #data) },
		source = ltn12.source.string(data),
		sink = ltn12.sink.table(out)
	}
	if c == 301 or c == 302 then
		return request(method, h.location, headers, data)
	end
	return ((r and true) or false),tableConcat(out),h,c
end

--- Makes a GET request.
-- Automatically makes a GET request with the given data.
function get(url, data, auth)
	local r,d,h,c = request("get", url..tabletoget(data or {}), auth)
	if not r then
		return false,h.status
	end
	return true,d,h,c
end

--- Makes a POST request.
-- Automatically makes a POST request with the given data.
function post(url, data, auth)
	local r,d,h,c = request("post", url, auth, tabletopost(data or {}))
	if not r then
		return false,h.status
	end
	return true,d,h,c
end

--- Makes a DELETE request.
-- Automatically makes a DELETE request with the given data.
function delete(url, data, auth)
	local r,d,h,c = request("delete", url, auth, tabletopost(data or {}))
	if not r then
		return false,h.status
	end
	return true,d,h,c
end