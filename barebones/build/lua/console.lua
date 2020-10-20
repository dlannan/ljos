local LINE_CARET    = "$"
local LINE_SEP      = ":"

-- Print a prompt an read an input line
local function getline(line)

    if line ~= "" then
      io.write(">> ")
      return line .. "\n" .. io.read()
    end
  
    io.write(LINE_CARET.." ")
    return io.read()
  end
  
  -- Print an error message
  local function printerr(error_msg)
  
    error_msg = error_msg:gsub("%[.*%]:", "")
    print(error_msg)
  end
  
  -- Load code from string
  local function getcode(line)
  
    local code, error_msg = loadstring(line)              -- try to load the code
  
    if code == nil then                                   -- if syntax error
      code = loadstring("print(" .. line .. ")")            -- try auto print
    else                                                  -- else
      local retcode, err = loadstring("return " .. line)    -- try auto return
      if not err then
        code = retcode
      end
    end
  
    return code, error_msg
  end
  
  -- main
  
  local runconsole = function()
  --print(_VERSION)
  local line = getline("")
  
  while line ~= nil do
  
    local code, error_msg = getcode(line)         -- load code from line
  
    if code ~= nil then                           -- if code is valid
  
      local success, err = pcall(code)       -- execute the code
      line = ""                                     -- clear the line
  
      if not success then                           -- if failure
        printerr(err)                          -- print error
      end
  
    elseif error_msg:sub(-5) ~= "<eof>" then      -- else if not incomplete
      line = ""                                     -- clear the line
      printerr(error_msg)                           -- print error
    end
  
    line = getline(line)                          -- read next line
  end
  
  print()
end

return {
    runconsole = runconsole
}