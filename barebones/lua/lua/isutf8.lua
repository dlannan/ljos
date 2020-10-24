local find = string.find

-- Based on http://notebook.kulchenko.com/programming/fixing-malformed-utf8-in-lua
return function (str)
  local i = 1
  local len = #str
  while i <= len do
    if     i == find(str, '[%z\1-\127]', i) then i = i + 1
    elseif i == find(str, '[\194-\223][\128-\191]', i) then i = i + 2
    elseif i == find(str,        '\224[\160-\191][\128-\191]', i)
        or i == find(str, '[\225-\236][\128-\191][\128-\191]', i)
        or i == find(str,        '\237[\128-\159][\128-\191]', i)
        or i == find(str, '[\238-\239][\128-\191][\128-\191]', i) then i = i + 3
    elseif i == find(str,        '\240[\144-\191][\128-\191][\128-\191]', i)
        or i == find(str, '[\241-\243][\128-\191][\128-\191][\128-\191]', i)
        or i == find(str,        '\244[\128-\143][\128-\191][\128-\191]', i) then i = i + 4
    else
      return false, i
    end
  end
  return true
end
