--- fstring module
-- @classmod fstring
local M = {}

-- function M.new()
--     return setmetatable()
-- end

--- Check if a string starts with other
-- @string s Base string.
-- @string str String that base starts with.
-- @treturn boolean
function M.starts_with(s, str)
    return s:sub(1, #str) == str
end

--- Check if a string ends with other
-- @string s Base string.
-- @string str String that base ends with.
-- @treturn boolean
function M.ends_with(s, str)
    return s:sub(#s-#str+1, #s) == str
end

--- Split a string by a given pattern
-- @string s Base string.
-- @string pattern Pattern to split.
-- @treturn table
function M.split(s, pattern)
    local split = {}
    for i in string.gmatch(s, pattern) do
        table.insert(split, i)
    end
    return split
end

--- Concat a string with multilpe strings
-- @string s Base string.
-- @param ... var args!
-- @treturn string
function M.concat(s, ...)
    local arguments = {...}
    local result = ""..s
    for k,v in pairs(arguments) do
        result = result .. v
    end
    return result 
end

--- Match pattern in string
-- @string s Base string.
-- @string pattern Pattern to match.
-- @treturn {table|nil}
function M.match(s, pattern)
    local matches = nil
    for word in s:gmatch(pattern) do
        matches = matches or {}
        table.insert(matches, word)
    end
    return matches
end

--- Repeat a string a number of times given
-- @string s Base string.
-- @number count Count repeat times.
-- @treturn string
function M.rep(s, count)
    return s:rep(count)
end

--- Trim start and end a string
-- @string s Base string.
-- @treturn string
function M.trim(s)
    return s:gsub("^%s*(.-)%s*$", "%1")
end

--- Trim start a string
-- @string s Base string.
-- @treturn string
function M.trim_start(s)
    return s:gsub("^%s*(.-)(%s*)$", "%1%2")
end

--- Trim end a string
-- @string s Base string.
-- @treturn string
function M.trim_end(s)
    return s:gsub("^(%s*)(.-)%s*$", "%1%2")
end

--- Pad start a string with a pad_string given until length given
-- @string s Base string.
-- @number target_length Target length of new string.
-- @number pad_string String to use to pad.
-- @treturn string
function M.pad_start(s, target_length, pad_string)
    local pad = target_length - #s
    if(pad < 0) then return s end
    local pad_repeat = math.floor(pad/#pad_string)
    local pad_rest = pad % #pad_string
    return M.rep(pad_string, pad_repeat) .. pad_string:sub(1, pad_rest) .. s
end

--- Pad end a string with a pad_string given until length given
-- @string s Base string.
-- @number target_length Target length of new string.
-- @number pad_string String to use to pad.
-- @treturn string
function M.pad_end(s, target_length, pad_string)
    local pad = target_length - #s
    if(pad < 0) then return s end
    local pad_repeat = math.floor(pad/#pad_string)
    local pad_rest = pad % #pad_string
    return s .. M.rep(pad_string, pad_repeat) .. pad_string:sub(1, pad_rest)
end

--- Check if an string is included in other
-- @string s Base string.
-- @string search_string Search string.
-- @number position Position to start to search.
-- @treturn boolean
function M.includes(s, search_string, position)
    return s:match(search_string, position) and true or false
end

-- function M.match(s, search_string, position)
--     return s:match(search_string, position)
-- end

--- Returns index of first match of pattern
-- @string s Base string.
-- @string pattern Pattern to match.
-- @number index Position to start to search.
-- @bool plain Search plain.
-- @treturn {number|nil}
function M.index_of(s, pattern, index, plain)
    return s:find(pattern, index, plain)
end

--- Replace a matched pattern in a string by other
-- @string s Base string.
-- @string pattern Pattern to search.
-- @string replace_string String with to replace.
-- @number substitutions Max number of replaces.
-- @treturn string
function M.replace(s, pattern, replace_string, substitutions)
    return s:gsub(pattern, replace_string, substitutions)
end

return M
-- return setmetatable({},{
--     __index = M,
--     __call = function(cls, s)
--         return M.new(s)
--     end
-- })
