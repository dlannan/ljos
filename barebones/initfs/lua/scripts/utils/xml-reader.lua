----------------------------------------------------------------
-- Xml parser.
----------------------------------------------------------------

-- Some stdio functions so we can write and read data directly
-- into ffi data structures.
----------------------------------------------------------------

-- local dir = require( "byt3d/scripts/utils/directory" )
-- local byt3dio = require( "byt3d/scripts/utils/fileio" )

----------------------------------------------------------------

local gpath = nil

----------------------------------------------------------------

function parseargs(s)
	local arg = {}
	string.gsub(s, "([%w%-]+)=([\"'])(.-)%2", function (w, _, a)
		arg[w] = a
	end)
	return arg
end

----------------------------------------------------------------

function collect( s, label )
    local reversemap = { }          -- label to stack index mapping
    local stackmap = { }     -- index to label name

	local stack = {}
	local top = {}
	table.insert(stack, top)

	--stack["Root"] = top

	local ni,c,label,xarg, empty
	local i, j = 1, 1

	while true do
        -- Reads a element line start, whole line or end line
		ni,j,c,label,xarg, empty = string.find(s, "<(%/?)([_%w]+)(.-)(%/?)>", i)

        -- Must be complete..
        if not ni then break end

        -- Previous text - This is effectively white space (tabs, usually)
		local text = string.sub(s, i, ni-1)

        -- Save the line of text if there has been text between element tags
		if not string.find(text, "^%s*$") then
			table.insert(top, text)
        end

        -- Empty element?
		if empty == "/" then -- empty element tag
		    table.insert(top, {label=label, xarg=parseargs(xarg), empty=1})

        -- Start of new element
		elseif c == "" then -- start tag
			top = {label=label, xarg=parseargs(xarg) }
			table.insert(stack, top) -- new level

        -- Must be an end element tag
		else -- end tag

            local toclose = table.remove(stack) -- remove top
            top = stack[#stack]
            if #stack < 1 then
                error("nothing to close with "..label)
            end
            if toclose.label ~= label then
            	error("trying to close "..tostring(toclose.label).." with "..label)
            end

            -- table.insert(top, toclose)
            local argt = toclose.xarg
            if argt and #argt < 2 then
                if argt.type == "number" then
                    toclose = tonumber(toclose[1])
                elseif argt.type == "string" then
                    toclose = tostring(toclose[1])
                elseif argt.type == "table" then
                    toclose.xarg = nil
                end
            end

            if type(toclose) == "table" then
                if toclose.label and label then toclose.label = nil end
            end
            top[label] = toclose
		end
		i = j+1
	end
	local text = string.sub(s, i)
	if not string.find(text, "^%s*$") then
		table.insert(stack[#stack], text)
	end
	if #stack > 1 then
		error("unclosed "..stack[stack.n].label)
	end
	return stack[1]
end

----------------------------------------------------------------
-- Returns a table structued with xml "tags"

function LoadXml(filename, labels)

	local xmlFile = io.open(filename, "r")
    if xmlFile == nil then
        print("FILE ERROR: Cannot open file: ", filename )
        return nil
    end

	local myXml = xmlFile:read("*all")
    xmlFile:close()
	 
 	local xmlData = collect( myXml, labels )
 	return xmlData
end 
 
----------------------------------------------------------------
-- Dump the xml data table 
--     Outputs to console.

function DumpXml(xmldata, tab)

	if(tab == nil) then tab = "" end

	for k,v in pairs(xmldata) do
        print(tab..k, v)
		if(type(v) == "table") then DumpXml(v, tab..">>>") end
	end
end

----------------------------------------------------------------
 
function writeEntry(file, properties, parent, depth)

	local pad = ""
	for i=1,depth do pad = pad.."\t" end
 
    for k, v in pairs(properties) do
 		
        if type(v) == "table" then

            local tcount = 0
            for i,j in pairs(v) do tcount = tcount + 1 end
            if tcount > 0 then
                file:write(pad.."<" .. tostring(k) .. " type=\"table\">\n")
                writeEntry(file, v, tostring(k), depth+1)
                file:write(pad.."</" .. tostring(k) .. ">\n")
            end
        else
            -- This is to handle arrays only built using ffi
            if type(v) == "cdata" then
                -- Need to resolve the data type, get the array length and save all array to a bin file.
                local arr = tostring(v)
                -- format should follow something like:  cdata<unsigned short [35778]>: 0x07b41428
                -- only interested in what is between the < >
                local si, ei, fftype = string.find(arr, "<(.+)>")
                local s2i, e2i, arraysize = string.find(fftype, "%[(.+)%]")
                fftype = string.sub(fftype, 1, s2i-2)
                if fftype ~= nil and tonumber(arraysize) > 0 then

                    local elementsize = byt3dio:getffsize(fftype)

                    -- Write out a file using the parent name
                    -- get the path
                    -- local bpath = dir:getfilepath(gpath)
                    -- local fname = dir:getfilename(gpath)
                    fname = string.gsub(fname, "%.", "_")

                    local binfilename = bpath.."\\"..fname.."_"..parent.."_"..tostring(k)..".bin"
                    -- convert to local file type
                    -- binfilename = dir:osfile(binfilename)
                    local bsize = arraysize * elementsize

                    -- local res = byt3dio:savedata(binfilename, bsize, v )
                    if res ~= nil then
                        file:write(pad.."<" .. tostring(k) .. " type=\"" .. type(v) .. "\" ffitype=\"" .. fftype .. "\" arraysize=\"" .. arraysize .. "\">" .. binfilename .. "</" .. tostring(k) .. ">\n")
                    end
                 end
            else
                if type(v) ~= "function" then
                    file:write(pad.."<" .. tostring(k) .. " type=\"" .. type(v) .. "\">" .. tostring(v) .. "</" .. tostring(k) .. ">\n")
                end
            end
        end
    end
    depth = depth-1
end
 
----------------------------------------------------------------

function SaveXml(path, properties, ttype)

    gpath = path
	if ttype == nil then ttype = "byt3dData" end

    local file = io.open(path, "w+b")
    file:write("<"..ttype.." type=\"table\">\n")
    writeEntry(file, properties, ttype, 1)
    file:write("</"..ttype..">\n")
    file:write("")
    io.close(file)
end
 
----------------------------------------------------------------
 