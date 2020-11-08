--
-- Created by David Lannan
-- User: grover
-- Date: 28/03/13
-- Time: 12:06 AM
-- Copyright 2013  Developed for use with the byt3d engine.
--

------------------------------------------------------------------------------------------------------------
-- State - Cache Manager for the Editor
--
-- Decription: Manage the assets via a cache system so that everything is snappy
--				and nice to use. Cache should be able to be 'refreshed' on demand too.
--
--              All cache files should be maintained in the byt3d/editor/cache folder.
--              NOTES:
--                 Cache will have ability to maintain multiple project caches (selectable - up to 5?)
--                 Cache is updated 5 minutely and checks modify flags for changes in files.
--                 Only caches files that are vaild to projects.
--                 Should NOT make the user waste time waiting for cache updates.
------------------------------------------------------------------------------------------------------------
-- Specific win32 and OSX file functions that let us remove cache data (this is user space deletion).
--      These commands are run via os.system so they are _very_ dangerous.

------------------------------------------------------------------------------------------------------------
local fio = require("scripts/utils/fileio")
local dir = require("scripts/utils/directory")
------------------------------------------------------------------------------------------------------------

local SeditorCache	= NewState()

------------------------------------------------------------------------------------------------------------

SeditorCache.cache_path             = "byt3d/editor/cache"
SeditorCache.cache_current          = "current.cache"
SeditorCache.cache_directories      = "folders.cache"
SeditorCache.cache_file             = nil
SeditorCache.cache_tbl              = {}
SeditorCache.cache_folder_tbl       = {}

SeditorCache.cache_folders  = {}
SeditorCache.cache_folders.images   = "/images"
SeditorCache.cache_folders.meshes   = "/meshes"
SeditorCache.cache_folders.terrain  = "/terrain"
SeditorCache.cache_folders.svg      = "/svgs"
SeditorCache.cache_folders.audio    = "/audio"
SeditorCache.cache_folders.scripts  = "/scripts"

------------------------------------------------------------------------------------------------------------
-- Registered types
--
SeditorCache.types = {
    lua     = SeditorCache.cache_folders.scripts,
    gls     = SeditorCache.cache_folders.scripts,       -- GLSL OpenGLES shaders in Lua script.

    dae     = SeditorCache.cache_folders.meshes,
    obj     = SeditorCache.cache_folders.meshes,
    lwo     = SeditorCache.cache_folders.meshes,      -- Lightwave Object
    lws     = SeditorCache.cache_folders.meshes,      -- Lightwave Scene
    cob     = SeditorCache.cache_folders.meshes,      -- TrueSpace Object
    scn     = SeditorCache.cache_folders.meshes,      -- TrueSpace Scene

    ter     = SeditorCache.cache_folders.terrain,   -- Terragen Terrain - this needs to be treated differently.

    png     = SeditorCache.cache_folders.images,
    jpg     = SeditorCache.cache_folders.images,   -- JPEG Images supported via Cairo (TODO: need testing)

    wav     = SeditorCache.cache_folders.audio,
    mp3     = SeditorCache.cache_folders.audio,     -- Apparently SDL supports MP3 as well (TODO: need testing)

    svg     = SeditorCache.cache_folders.svg
}

------------------------------------------------------------------------------------------------------------
-- Convert a svg inplace - should be in the cache folders.
--     Also generate an icon if possible (render to texture from a appropriate distance)

function SeditorCache:ConvertSVG(localfile)

    print("Converting SVG...",localfile)
    local svgdata = Gcairo:LoadSvg(localfile)

    -- Generate an icon - named after the converted data set
    local render = byt3dLevel:New("icon_render", "byt3d/data/levels/icons.lvl")
    render.cameras["Default"]:InitPerspective(45, 1.7777, 0.5, 1000.0)
    render.cameras["Default"]:SetupView(0, 0, 256, 256)
    render:BuildFBO(256, 256)

    local mesh = byt3dMesh:New()
    local newshader = byt3dShader:NewProgram(colour_shader_vert, colour_shader_frag)
    newshader.name = "TShader_Default"

    mesh:SetShader(newshader)

    gl.glBindFramebuffer(gl.GL_FRAMEBUFFER, render.rframe)
    Gcairo:Begin()
    Gcairo:RenderSvg(svgdata)
    Gcairo:Render()
    gl.glBindFramebuffer(gl.GL_FRAMEBUFFER, 0)

    -- Copy render texture to an icon
    local cimage = Gcairo:CreateImageFromFBO(256, 256, render.rframe)
    local rootfilename = dir:osfile(string.gsub(localfile, "%.", "_").."_icon.png")
    Gcairo:SaveImage(rootfilename, cimage)
end

    ------------------------------------------------------------------------------------------------------------
-- Convert a mesh inplace - should be in the cache folders.
--     Also generate an icon if possible (render to texture from a appropriate distance)

function SeditorCache:ConvertMesh(localfile)

    print("Converting Mesh...",localfile)
    -- The mesh should convert the model to binary - to be used afterwards
    local tmodel = LoadModel(localfile)
    tmodel:SetMeshProperty("priority", byt3dRender.OPAQUE)

    -- Generate an icon - named after the converted data set
    local render = byt3dLevel:New("icon_render", "byt3d/data/levels/icons.lvl")
    render.cameras["Default"]:InitPerspective(45, 1.7777, 0.5, 1000.0)
    render.cameras["Default"]:SetupView(0, 0, 256, 256)
    render:BuildFBO(256, 256)

    render.nodes["root"]:AddChild(tmodel, "Model_Temp" )

    -- TODO: Need to sort out Shader<->Texture<->Mesh linking. Materials.. maybe.
    local newtex = byt3dTexture:New()
    newtex:NewColorImage( {255.0, 0.0, 255.0, 255.0} )

    local newshader = byt3dShader:NewProgram(colour_shader_vert, colour_shader_frag)
    newshader.name = "TShader_Default"

    tmodel:SetMeshProperty("shader", newshader)
    tmodel:SetSamplerTex(newtex, "s_tex0")
    tmodel.node.transform:RotateHPR(45.0, 0.0, 0.0)

    render.cameras["Default"]:CenterOnModel(tmodel)
    render:RenderTexture()

    -- Copy render texture to an icon
    local cimage = Gcairo:CreateImageFromFBO(256, 256, render.rframe)
    local rootfilename = dir:osfile(string.gsub(localfile, "%.", "_").."_icon.png")
    Gcairo:SaveImage(rootfilename, cimage)
end

------------------------------------------------------------------------------------------------------------
-- Mainly handlers for mesh conversion. Audio conversion and Script compile to come later

SeditorCache.type_handler = {

    dae     = SeditorCache.ConvertMesh,
    obj     = SeditorCache.ConvertMesh,
    lwo     = SeditorCache.ConvertMesh,         -- Lightwave Object
    lws     = SeditorCache.ConvertMesh,         -- Lightwave Scene
    cob     = SeditorCache.ConvertMesh,         -- TrueSpace Object
    scn     = SeditorCache.ConvertMesh,         -- TrueSpace Scene

    svg     = SeditorCache.ConvertSVG           -- SVG
}

------------------------------------------------------------------------------------------------------------

function SeditorCache:ResetCache()

    -- Check the cache folders exist
    for k,v in pairs(self.cache_folders) do
        local wfdir = dir:osfile(self.cache_path..v)
        if ffi.os == "Windows" then os.execute("mkdir "..wfdir) end
        if ffi.os == "OSX" then os.execute([[mkdir -p -m "a=rwx" ]]..wfdir) end

        -- make sure each folder is empty
        local res = dir:listfolder(self.cache_path..v)
        for i,f in pairs(res) do

            local wfname = dir:osfile(self.cache_path..v.."/"..f.name)
            os.remove(wfname)
        end
    end
    -- Now ready for updating...
end

------------------------------------------------------------------------------------------------------------
-- Load the current cache - cleanup a little too, and clean out any files than may have gone missing.

function SeditorCache:LoadCache()

    -- Load the file cache
    self.cache_file = io.open(self.cache_path.."/"..self.cache_current, "r")
    local line = self.cache_file:read("*l")
    while line ~= nil do
        -- line is the list of cache elements to keep track of.
        -- Original source file + path is the key for the file (this should be unique)
        local fsource, fmodified, fext, fsize, fconverted = string.match(line, "(.+)#(%w+)#(%w+)#(%w+)#(%w+)")
        if fsource ~= nil then
            -- check it still exists
            if fio:exists(fsource) then
                self.cache_tbl[fsource] = { source=fsource, modified=fmodified, ext=fext, size=fsize, converted=fconverted }

                -- Also check that we have a temp, local copy.. add to temp cache if not.
            end
        end
        line = self.cache_file:read("*l")
    end
    self.cache_file:close()

    -- Load the file cache
    self.cache_file = io.open(self.cache_path.."/"..self.cache_directories, "r")

    -- First line is folder info
    local folderinfo = self.cache_file:read("*l")
    while folderinfo ~= nil do

        local fpath, fcount = string.match(folderinfo, "(.+)#(%w+)")
        local files = {}
        -- Find all the lines using a loop
        for i=1,fcount do
            local line = self.cache_file:read("*l")
            local fsource, fmodified, fext, fsize, fconv = string.match(line, "(.+)#(%w+)#(%w+)#(%w+)#(%w+)")
            local finfo =  self:MakeCacheEntry(fsource, fmodified, fext, fsize, fconv)
            if finfo ~= nil then files[finfo.source] = finfo end
            -- print(finfo.source, finfo.modified, finfo.ext, finfo.size, finfo.converted)
        end
        self.cache_folder_tbl[fpath] = files
        folderinfo = self.cache_file:read("*l")
    end
    self.cache_file:close()
end

------------------------------------------------------------------------------------------------------------
-- Write the cache back out - this should happen regularly in case of crashes.

function SeditorCache:SaveCache()

    self.cache_file = io.open(self.cache_path.."/"..self.cache_current, "w")
    assert(self.cache_file, "Error: Unable to create a cache file. Cannot continue.")

    for i,c in pairs( self.cache_tbl ) do
        local cacheline = string.format("%s#%s#%s#%s#%s\n", c.source, c.modified, c.ext, c.size, c.converted )
        self.cache_file:write(cacheline)
    end
    self.cache_file:close()

    self.cache_file = io.open(self.cache_path.."/"..self.cache_directories, "w")
    assert(self.cache_file, "Error: Unable to create a folder cache file. Cannot continue.")

    for i,c in pairs( self.cache_folder_tbl ) do

        local count = 0
        for j,f in pairs( c ) do count = count + 1 end
        local cacheline = string.format("%s#%s\n", tostring(i), tostring( count )  )
        self.cache_file:write(cacheline)

        for j,f in pairs( c ) do
            local line = string.format("%s#%s#%s#%s#%s\n", tostring(f.source), tostring(f.modified), tostring(f.ext), tostring(f.size), tostring(f.converted) )
            self.cache_file:write(line)
        end
    end
    self.cache_file:close()
end

------------------------------------------------------------------------------------------------------------

function SeditorCache:MakeCacheEntry(filesource, filemod, fileext, filesize, conv)

    if filesource == nil then return nil end

    local fname = dir:getfilename(filesource)
    local fpath = dir:getfilepath(filesource)

    local entry = {
        name = fname,
        path = fpath,
        source = tostring(filesource),
        modified = tostring(filemod),
        ext = tostring(fileext),
        size = tostring(filesize),
        converted = tostring(conv)
    }
    return entry
end

------------------------------------------------------------------------------------------------------------

function SeditorCache:Begin()

    -- Check if cache file exists.. if not, reset.
    if fio:exists(self.cache_path.."/"..self.cache_current) == false then
        print("Creating editor cache....")
        self:ResetCache()

    -- Load Cache...
    else
        print("Loading editor cache....")
        self:LoadCache()
    end
end

------------------------------------------------------------------------------------------------------------
-- Need a list of registered file types - will take from the
--    File information should be passed on from the listfolder method or the fileinfo method.

function SeditorCache:AddToCache(finfo)
    -- Add a line of info into the cache, and then add file into temp folders.
    local filesource = finfo.path.."/"..finfo.name
    local fileext = dir:getextension(filesource)

    local file_cached = self.cache_tbl[filesource]
    if file_cached == nil then
        file_cached = self:MakeCacheEntry(filesource, finfo.mtime, fileext, finfo.size, 0)
        self.cache_tbl[filesource] = file_cached
        --print( finfo.name, finfo.path, finfo.size, finfo.ftype, finfo.ctime, finfo.mtime )

        -- Copy the file across first...
        local ftypepath = self.types[fileext]

        if filesource ~= nil and ftypepath ~= nil then
            local localfile = string.format("%s%s/%s", self.cache_path, ftypepath, finfo.name )
            local wfsource = dir:osfile(filesource)
            -- print(self.cache_path, ftypepath , finfo.name)
            local wfdest = dir:osfile( localfile )

            -- TODO : This and mkdir need to go into the directory or fileio
            print("copy...", wfsource, wfdest)
            if ffi.os == "Windows" then os.execute("copy /B /Y "..wfsource.." "..wfdest ) end
            if ffi.os == "OSX" then os.execute("cp "..wfsource.." "..wfdest ) end
        end

        -- Determine if any special operations are neededn
        if ftypepath ~= nil then
            local localfile = string.format("%s%s/%s", self.cache_path, ftypepath, finfo.name )

            local typehandler = self.type_handler[fileext]
            if typehandler ~= nil then
                typehandler(self, localfile)
            end
        end
    end

    return file_cached
end

------------------------------------------------------------------------------------------------------------

function SeditorCache:AddFolderToCache(folder, files)

    -- Need to reformat from directory listing - not the same (oops)
    local allfiles = {}
    for k, v in pairs(files) do
        if v.ftype == "file" then

            allfiles[k] = self:AddToCache(v)
            --print(allfiles[k].name, allfiles[k].source)
        end
    end

    self.cache_folder_tbl[folder] = allfiles
    return allfiles
end

------------------------------------------------------------------------------------------------------------
-- Update the cache to see if files are out of date - do this every now and then
--
--      Provide a user settable period so this can be made short or long interval

function SeditorCache:CheckCache(finfo)

    self:AddToCache(finfo)
end

------------------------------------------------------------------------------------------------------------
-- Get a file form the cache - return nil if failed
--
-- param - filesource - should be a full source file path

function SeditorCache:GetFile(filesource)

    local cachefile = self.cache_tbl[filesource]
    if cachefile == nil then return nil end

    local fileext = dir:getextension(cachefile.source)
    local fname = dir:getfilename(cachefile.source)
    local ftypepath = self.types[fileext]
    local localfile = string.format("%s%s/%s", self.cache_path, ftypepath, fname )
    return localfile
end

------------------------------------------------------------------------------------------------------------
-- Update the cache to see if files are out of date - do this every now and then
--
--      Provide a user settable period so this can be made short or long interval

function SeditorCache:CheckCacheFolder(folder, templist, callback)

    local cfolders = self.cache_folder_tbl[folder]

    if cfolders == nil then
        local results = {}
        local res = dir:listfolder(folder, results, 1, callback)
        cfolders = self:AddFolderToCache(folder, res)
    end

    -- Always merge with templist
    for l,w in pairs(cfolders) do
        templist[w.source] = w
    end

    return templist
end

------------------------------------------------------------------------------------------------------------
-- Update calls the check cache. Before any scripts attempt to use whats in it.

function SeditorCache:Update(mxi, myi, buttons)

end

------------------------------------------------------------------------------------------------------------

function SeditorCache:Render()

end

------------------------------------------------------------------------------------------------------------

function SeditorCache:Finish()
    -- Always save on exit
    self:SaveCache()
end

------------------------------------------------------------------------------------------------------------

return SeditorCache

------------------------------------------------------------------------------------------------------------
