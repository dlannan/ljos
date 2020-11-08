local colors_codes = {
    reset = 0,
    bold = 1,
    underline = 4,
    reversed = 7,
    black = 30,
    red = 31,
    green = 32,
    yellow = 33,
    blue = 34,
    magenta = 35,
    cyan = 36,
    white = 37,
    bgblack = 40,
    bgred = 41,
    bggreen = 42,
    bgyellow = 43,
    bgblue = 44,
    bgmagenta = 45,
    bgcyan = 46,
    bgwhite = 47
}

local escape_string = string.char(27) .. '[%dm' --"\u{001b}["..value.."m"
local function colorize(value)
    return escape_string:format(value)
end

local stylized 
function chalk(acummulator)
    acummulator = acummulator or ""
    return setmetatable({},{
        __index = function(t, key)
            if(colors_codes[key] ~= nil) then
                return chalk(acummulator .. colorize(colors_codes[key]))
            elseif (key == "__accum") then
                return acummulator
            elseif (key == "style") then
                return stylized
            else
                error(string.format("chalk key: %s is not valid", tostring(key)))
            end
        end,
        __call = function(cls, text)
            return acummulator .. text .. colorize(colors_codes.reset)
        end
    })
end

function stylized(style_str)
    local styles = {}
    for style in string.gmatch(style_str, "%S+") do
        table.insert(styles, style)
    end
    local result = chalk()
    for _, sty in ipairs(styles) do
        if(colors_codes[sty] ~= nil) then
            result = chalk(result.__accum .. colorize(colors_codes[sty]))
        else
            error(string.format("chalk.style contains a not valid key: %s is not valid", tostring(sty)))
        end
    end
    return result
end

return chalk()
