----------------------------------------------------------------
-- Simple State Manager.
----------------------------------------------------------------

local function ParseCSVLine (line,sep) 
	local res = {}
	local pos = 1
	sep = sep or ','
	while true do 
		local c = string.sub(line,pos,pos)
		if (c == "") then break end
		if (c == '"') then
			-- quoted value (ignore separator within)
			local txt = ""
			repeat
				local startp,endp = string.find(line,'^%b""',pos)
				txt = txt..string.sub(line,startp+1,endp-1)
				pos = endp + 1
				c = string.sub(line,pos,pos) 
				if (c == '"') then txt = txt..'"' end 
				-- check first char AFTER quoted string, if it is another
				-- quoted string without separator, then append it
				-- this is the way to "escape" the quote char in a quote. example:
				--   value1,"blub""blip""boing",value3  will result in blub"blip"boing  for the middle
			until (c ~= '"')
			table.insert(res,txt)
			assert(c == sep or c == "")
			pos = pos + 1
		else	
			-- no quotes used, just look for the first separator
			local startp,endp = string.find(line,sep,pos)
			if (startp) then 
				table.insert(res,string.sub(line,pos,startp-1))
				pos = endp + 1
			else
				-- no separator found -> use rest of string and terminate
				table.insert(res,string.sub(line,pos))
				break
			end 
		end
	end
	return res
end

----------------------------------------------------------------

function utf2lat(s)
   local t = {}
   local i = 1
   while i <= #s do
      local c = s:byte(i)
      i = i + 1
      if c < 128 then
         table.insert(t, string.char(c))
      elseif 192 <= c and c < 224 then
         local d = s:byte(i)
         i = i + 1
         if (not d) or d < 128 or d >= 192 then
            return nil, "UTF8 format error"
         end
         c = 64*(c - 192) + (d - 128)
         table.insert(t, string.char(c))
      else
         return nil, "UTF8 Chinese or Greek or something"
      end
   end
   return table.concat(t)
end

----------------------------------------------------------------
-- Load a CSV and parse it into a table. Each table entry has
--  a line of "subtables" with cell entries. 

function LoadCSV(filename)

	local csv = {}
	local linecount = 1
	for line in io.lines(filename) do 
		csv[linecount] = ParseCSVLine(line)
		linecount = linecount + 1
	end

	return csv
end

----------------------------------------------------------------
