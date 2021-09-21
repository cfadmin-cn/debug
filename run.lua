local cf = require "cf"

local sys = require "sys"
local now = sys.now

local type = type
local pcall = pcall
local loadfile = loadfile

local srep = string.rep
local fmt = string.format
local debug_getinfo = debug.getinfo
local debug_sethook = debug.sethook

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

return function (filename, trace)
  if not filename then
    return USAGE
  end
  local f, err = loadfile(filename)
  if type(f) ~= "function" then
    return string.format(cmd.loaderr, err)
  end

  local co = cf.self()

  cf.fork(function ()

    local list = {}

    local space = 0

    local back = nil

    local function hook(action)
      local info = debug_getinfo(2, 'Snulf')
      if info.what ~= 'C' then
        if action == 'line' then
          list[#list+1] = info
          info.action = action
          info.space = space
        elseif action == 'call' then
          space = space + 1
        elseif action == 'tail call' then
          space = space + 1
          back = (back or 0) + 1
        elseif action == 'return' then
          list[#list+1] = info
          info.action = action
          info.space = space
          space = space - 1
          if back then
            space = space - back
            back = nil
          end
        end
      end
    end

    local s = now()
    if trace then
      debug_sethook(hook, 'crl')
    end
    local ok, errinfo = pcall(f)
    if trace then
      debug_sethook(nil)
    end
    local e = now()

    if trace then

      for index = 1, #list do
        local current = list[index]
        list[index] = fmt(" %s [OK] [%s] [%s:%d]", '└' .. srep('--', ((current.space and current.space > 0 and current.space or 1 ) or 1) * 2) .. ">", current.action == "line" and "NEXT LINE" or "GOTO BACK", current.short_src, current.currentline)
      end

      list[1] = fmt("callstack traceback:")

      if not ok then
        list[#list-1] = fmt(' %s [ERR] %s', '└' .. srep('--', 2) .. ">", errinfo)
      end

    end

    -- 计算运行耗时.
    list[#list] = fmt("\r\nTotal Running Time: %.3f\r\nDone.", e - s)

    cf.wakeup(co, table.concat(list, "\r\n"))
  end)

  return cf.wait()
end
