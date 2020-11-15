-- get a key, and atempt to resolve a defined multibyte sequences (recursive).

local get_mbs
get_mbs = function(callback, key_table, max_i, i)
	assert(type(key_table)=="table")
	i = tonumber(i) or 1
	max_i = tonumber(max_i) or 10
	local key_code = callback()
	if i>max_i then
		return key_code, false
	end
	local key_resolved = key_table[key_code]
	if type(key_resolved) == "function" then
		key_resolved = key_resolved(callback, key_code)
	end
	if type(key_resolved) == "table" then
		-- we're in a multibyte sequence, get more characters recursively(with maximum limit)
		return get_mbs(callback, key_resolved, max_i, i+1)
	elseif key_resolved then
		-- we resolved a multibyte sequence
		return key_code, key_resolved
	else
		-- Not in a multibyte sequence
		return key_code
	end
end

return get_mbs
