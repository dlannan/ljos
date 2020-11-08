return {
    command = "kilo [file]",
    description = "edit a file in a simple text editor",
    action = function(parsed, command, app)
        local editfile = parsed.file
        if(editfile == nil) then 
            local tmpfh = io.tmpfile()
            editfile = os.tmpname()
            tmpfh:close()
        end

        local isfile, err = lfs.attributes( editfile )
        if(isfile == nil) then print("Error:", tostring(err)); return end
        if(isfile.mode == "directory") then print("Not a file."); return end

        print("[ "..editfile.." ]")
        local status, retval = pcall( runproc, { "/sbin/kilo", editfile } )
        print("\027c")
        if(status == false) then print("Error:", retval) end        
    end, 
}