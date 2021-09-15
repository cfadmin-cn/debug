local cf = require "cf"

local USAGE = [[

Run [command] :

  [filename] - Execute lua script file.(e.g: script/test.lua)
]]

local cmd = {}

cmd.runerr = [[

error: %s
]]

cmd.loaderr = [[

error: %s
]]

return function (filename, ...)
  if not filename then
    return USAGE
  end
  local f, errinfo = loadfile(filename)
  if type(f) ~= "function" then
    return string.format(cmd.loaderr, errinfo)
  end
  cf.fork(f, ...)
end