-- folderpath/mycmd.lua
return {
    command = "ifconfig [arg1] [arg2]", -- Schema to parse. Required
    description = "Display network adaptor information", -- Command description
    positional_args = { -- Set description or {description, default} for positional arguments
        arg1 = "Network device name",
        arg2 = "Command for the network device - up/down/show",
    },
    action = function(parsed, command, app) -- same command:action(function)

        local ifconfig = "/sbin/ifconfig"
        local cargv = { ifconfig }
        if( parsed.arg1 ) then tinsert(cargv, parsed.arg1) end
        if( parsed.arg2 ) then tinsert(cargv, parsed.arg2) end

        local status, retval = pcall( runproc, cargv )
        if(status == false) then print("Error:", retval) end  
    end
}