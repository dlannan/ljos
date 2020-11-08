----------------------------------------------------------------
--/**
-- * traverse the directory recursively
-- * @return TRUE if success, otherwise FALSE.
-- */
----------------------------------------------------------------

----------------------------------------------------------------
local dir	= {  init = 0, debug = false }
----------------------------------------------------------------

if ffi.os == "OSX" then
    dir.folder_sep = "/"
end

if ffi.os == "Windows" then
    dir.folder_sep = "\\"
end

----------------------------------------------------------------

function dir:Init()

end

----------------------------------------------------------------

function dir:osfile(filename)

    local newfile = filename
    if ffi.os == "OSX" then
        newfile = string.gsub(filename, "\\", "/")
    end
    if ffi.os == "Windows" then
        newfile = string.gsub(filename, "/", "\\")
    end

    return newfile
end

----------------------------------------------------------------

function dir:getfilepath(filepath)
    -- Try windows backslash first
    local s,e,fpath = string.find(filepath, "(.+)\\")
    -- Then try unix forward slash
    if fpath == nil then s,e,fpath = string.find(filepath, "(.+)/") end
    return fpath
end

----------------------------------------------------------------

function dir:getfilename(filepath)

    -- Try windows backslash first
    local s,e,fpath = string.find(filepath, "(.+)\\")
    -- Then try unix forward slash
    if fpath == nil then s,e,fpath = string.find(filepath, "(.+)/") end
    -- We have the last slash, so return the remaining.
    if fpath == nil then return nil end -- TODO: Should assert or something I think.
    local fname = string.sub(filepath, e+1)
    return fname
end

----------------------------------------------------------------

function dir:getextension(filepath)

	local s,e = string.find(filepath, "%.")
	local ext = ""
	if s ~= nil then ext = string.sub(filepath, e+1) end
	return ext
end

----------------------------------------------------------------
-- The listfolder is capable of a number of different uses.
--  <params:dirpath> - The path to get the directory list of files/folders
--  <params:res> - The results table to put all the entries in
--  <params:dir_expand> - Whether to iterate into subfolders to collect results - BE CAREFUL!!
--  <params:callback> - this is called for each iteration of a file entry (can return updates for feedback)
--  returns the results list of the entries.
--
-- NOTE: All '.' and '..' paths are added as entries but are not included in expansion (of course).
--       Be sure to filter/remove these directories if they are not needed.

function dir:listfolder(dirpath, res, dir_expand, callback)

	-- folder list results - should always have "." and ".." in the list ?!
	if res == nil then res 	= {} end
    if callback then callback() end
    local tfile = nil

	for tfile in lfs.dir(dirpath) do

        local f = dirpath..'/'..tfile
        local attr = lfs.attributes(f)

        local name = self:getfilename(f)
        local entry = { name = name, path = dirpath, size = attr.size, ftype = attr.mode, ctime = attr.change, mtime = attr.modification  }
	    table.insert(res, entry)

        -- Expand into the folder and collect all files
        if dir_expand ~= nil and attr.mode == "directory" then
            if name ~= "." and name ~= ".." then
                local folderlist = dirpath.."/"..name
                self:listfolder(folderlist, res, dir_expand)
            end
        end

	    -- Below is used for debugging.
	    ----------------------------------------------------------------------------------------------------
	    if self.debug then
	        local fields = { "name", "path", "size", "ftype", "mtime", "ctime" }
	        for k, field in ipairs(fields) do
		 	    local v = entry[field]
		 	    print( k, field, tostring(v) )
	        end
	    end
    end

	return res
end

----------------------------------------------------------------

function dir:fileinfo(filename)

    local attr = lfs.attributes(filename)
    local entry = { name = self:getfilename(filename), path = self:getfilepath(filename), size = attr.size, ftype = attr.mode, ctime = attr.change, mtime = attr.modification  }
    return entry
end

----------------------------------------------------------------

function dir:Finalize()

    print("Closing directory system.")
end
----------------------------------------------------------------

return dir

----------------------------------------------------------------
