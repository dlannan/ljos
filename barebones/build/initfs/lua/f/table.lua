--- ftable module
-- @classmod ftable
local M = {}

function M.new(t)
    return setmetatable(t or {}, {
        __index = M,
        __tostring = function(t) return M.tostring(t) end
    })
end

local function is_from_module(t, new_t)
    local mt = getmetatable(t)
    if(mt and mt.__index == M and new_t) then
        return M.new(new_t)
    end
    return new_t or t
end

--- Apply a function by each element in table
-- @tparam table t Base table.
-- @func fn Function to apply to each element.
function M.for_each(t, fn)
    for k, v in pairs(t) do
        fn(v, k , t)
    end
end

--- Apply a function by each element in table of reverse way
-- @tparam table t Base table.
-- @func fn Function to apply to each element.
function M.for_each_reverse(t, fn)
    local length = #t
    for i = length, 1, -1 do
        fn(v, k , t)
    end
end

--- Create a new table whose values are result of apply a function to each element.
-- @tparam table t Base table.
-- @func fn Function to apply to each element.
-- @treturn table
function M.map(t, fn)
    local new_t = {}
    for k, v in pairs(t) do
        new_t[k] = fn(v, k, t)
    end
    return is_from_module(t, new_t)
end

--- Create a new table whose values pass a function.
-- @tparam table t Base table.
-- @func fn Function to apply to each element.
-- @treturn table
function M.filter(t, fn)
    local new_t = {}
    for k, v in pairs(t) do
        if(fn(v, k, t)) then table.insert(new_t, v) end
    end
    return is_from_module(t, new_t)
end

--- Find a new table whose values pass a function.
-- @tparam table t Base table.
-- @func fn Function to apply to each element.
-- @treturn {table|string|number|boolean|nil} number
function M.find(t, fn)
    local found, index = nil, -1
    for k, v in pairs(t) do
        if(fn(v, k, t)) then found = v;index = k break end
    end
    return found, index
end

--- Find index of first element that pass the function.
-- @tparam table t Base table.
-- @func fn Function to apply to each element.
-- @treturn {number|nil}
function M.find_index(t, fn)
    local _, index = M.find(t, fn)
    return index
end

--- Find index of first element whose value is same to given.
-- @tparam table t Base table.
-- @param value Value to find index.
-- @treturn {number|nil}
function M.index_of(t, value)
    local _, index = M.find(t, function(v) return v == value end)
    return index
end

--- Reduce a table to a value passing a function to each element.
-- @tparam table t Base table.
-- @func fn Function to apply to each element. Params (accumulator, element_value, element_key, table).
-- @param accumulator Init value of accumulator.
-- @return accumulator
function M.reduce(t, fn, accumulator)
    M.for_each(t, function(v, k, a)
        accumulator = fn(accumulator, v, k, a)
    end)
    return accumulator
end

--- Reduce a reversed table to a value passing a function to each element.
-- @tparam table t Base table.
-- @func fn Function to apply to each element. Params (accumulator, element_value, element_key, table).
-- @param accumulator Init value of accumulator.
-- @return accumulator
function M.reduce_reverse(t, fn, accumulator)
    M.for_each_reverse(t, function(v, k, a)
        accumulator = fn(accumulator, v, k, a)
    end)
    return accumulator
end

--- Inserts a value at end of table.
-- @tparam table t Base table.
-- @param value Value to insert
-- @return length of table
function M.push(t, value)
    table.insert(t, value)
    return #t
end

--- Removes last item of table.
-- @tparam table t Base table.
-- @return item removed
function M.pop(t)
    return table.remove(t, #t)
end

--- Inserts a value at start of table.
-- @tparam table t Base table.
-- @param value Value to insert
-- @return length of table
function M.unshift(t, value)
    table.insert(t, 1, value)
    return #t
end

--- Removes first item of table.
-- @tparam table t Base table.
-- @return item removed
function M.shift(t)
    return table.remove(t, 1)
end

--- Reverse a table. Create a new table.
-- @tparam table t Base table.
-- @return reversed table
function M.reverse(t)
    local new_t = {}
    local length = M.length(t)
    for i=length, 1, -1 do
        M.push(new_t, t[i])
    end
    return is_from_module(t, new_t)
end

local function flat(t, depth, new_t, level)
    depth = depth or 1
    new_t = new_t or {}
    level = level or 0
    M.for_each(t, function(v, k)
        if (type(v) == "table" and depth > level) then
            flat(v, depth, new_t, level + 1)
        else
            M.push(new_t, v)
        end
    end)
    return is_from_module(t, new_t)
end

--- Flat a table. Create a new table.
-- @tparam table t Base table.
-- @number[opt=1] depth Depth to flat the table.
-- @treturn table
function M.flat(t, depth)
    return flat(t, depth)
end



--- Flat and map combined. Apply a function to a flat table. Create a new table. Flat depth is 1.
-- @tparam table t Base table.
-- @func fn Function to apply to each element of flatted table.
-- @treturn table
function M.flat_map(t, fn)
    local flat = M.flat(t, 1)
    return M.map(flat, fn)
end

--- Slice a table start-ends. Create a new table.
-- @tparam table t Base table.
-- @number[opt=1] start Start position.
-- @number[opt=#t] endv End position.
-- @treturn table
function M.slice(t, start, endv)
    start = start or 1
    endv = endv or #t
    local new_t = {}
    for i = start, endv do
        M.push(new_t, t[i])
    end
    return is_from_module(t, new_t)
end

--- Sort a table.
-- @tparam table t Base table.
-- @func fn Compare function. fn(a, b)
-- @treturn table
function M.sort(t, fn)
    table.sort(t, fn)
    return t
end

-- TODO
-- function M.splice(t, start, delete, ...)
--     local length = #t
--     if (start > length) then start = length + 1
--     elseif (start < 0) then start = length + start end

--     local items = {...}
--     if(#items < 1) then return t end
--     local endv = start + delete
--     local items_count = 1
--     local t_before_start = M.slice(t, 1, start)
--     for i = start, endv do

--     end
-- end

--- Check if some element of a table pass a function.
-- @tparam table t Base table.
-- @func fn Function to pass.
-- @treturn table
function M.some(t, fn)
    return M.find(t, fn) and true or false
end

--- Check if every element of a table pass a function.
-- @tparam table t Base table.
-- @func fn Function to pass.
-- @treturn boolean
function M.every(t, fn)
    local result = true
    for k, v in pairs(t) do
        if(not fn(v, k, t)) then result = false; break end
    end
    return result
end

--- Concat a table with other.
-- @tparam table t Base table.
-- @tparam table ot Other table.
-- @treturn table
function M.concat(t, ot)
    local new_t = {}
    M.for_each(t, function(v)
        M.push(new_t, v)
    end)
    M.for_each(ot, function(v)
        M.push(new_t, v)
    end)
    return is_from_module(t, new_t)
end

--- Fill a table with a element.
-- @tparam table t Base table.
-- @param value Fill element.
-- @tparam number[opt=1] start Start position.
-- @tparam number[opt=#t] endv End position.
-- @treturn table
function M.fill(t, value, start, endv)
    start = start or 1
    endv = endv or #t
    for i = start, endv do
        t[i] = value
    end
    return is_from_module(t, t)
end

--- Fill a table with a element.
-- @tparam table t Base table.
-- @param value Value to include.
-- @treturn boolean
function M.includes(t, value)
    return M.some(t, function(v) return v == value end)
end

--- Join table elements to a string.
-- @tparam table t Base table.
-- @string[opt=""] separator Separator.
-- @treturn string
function M.join(t, separator)
    separator = separator or ""
    local result = ""
    M.for_each(t, function(v,k) result = result .. ((k > 1 and separator) or "") .. v end)
    return result
end

--- Returns a new table with keys table.
-- @tparam table t Base table.
-- @treturn table
function M.keys(t)
    return M.map(t, function(_, k) return k end)
end

--- Returns a new table with values table.
-- @tparam table t Base table.
-- @treturn table
function M.values(t)
    return M.map(t, function(v) return v end)
end

--- Returns table length.
-- @tparam table t Base table.
-- @treturn number
function M.length(t)
    return #t
end

function pvalue(value)
    if(type(value) == "string") then return "\"" .. value .. "\""
    else return tostring(value) end
end

local function _tostring(t, depth, level)
    level = level or 1
    local sep = " "
    local result = "{\n"
    M.for_each(t, function(v, k)
        if(type(v) == "table") then
            result = result .. (sep:rep(level)) .. "[" .. k .. "] = " .. (depth > level and _tostring(v, level + 1) or tostring(v)) .. ",\n"
        else
            result = result .. (sep:rep(level)) .. "[" .. k .. "] = " .. pvalue(v) .. ",\n"
        end
    end)
    return result .. (sep:rep(level-1)) .. "}"
end
--- Returns table tostring.
-- @tparam table t Base table.
-- @number[opt=1] depth Depth.
-- @treturn string
function M.tostring(t, depth)
    depth = depth or 1
    return _tostring(t, depth)
end

--- Print a table.
-- @tparam table t Base table.
-- @number[opt=1] depth Depth.
function M.print(t, depth)
    print(M.tostring(t, depth))
end

return setmetatable({},{
    __index = M,
    __call = function(cls, t)
        return M.new(t)
    end
})