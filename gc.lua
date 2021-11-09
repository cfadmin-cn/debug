local sys = require "sys"

local collectgarbage = collectgarbage

local USAGE = [[

gc [command] [args]:

  [count]   -  Let the garbage collector report memory usage.

  [step]    -  Let the garbage collector do a step garbage collection.

  [collect] -  Let the garbage collector do a full garbage collection.

  [start]   -  Let the garbage collector (re)start.

  [stop]    -  Let the garbage collector stop working.

  [mode]    -  Let the garbage change work mode(`incremental` or `generational`).
]]

local cmd = {}

cmd.mode = [[

collectgarbage response :

  change to '%s' mode.
]]

cmd.count = [[

collectgarbage response :

  current memory size: %s
]]

cmd.step = [[

collectgarbage response :

  before collectgarbage: %s

  after  collectgarbage: %s

  gc collect time: %.4f/s
]]

cmd.collect = [[

collectgarbage response :

  before collectgarbage: %s

  after  collectgarbage: %s

  gc collect time: %.4f/s
]]

cmd.start = [[

collectgarbage response :

  before status: %s

  current status: %s
]]

cmd.stop = [[

collectgarbage response :

  before status: %s

  current status: %s
]]


local function calc_memory()
  local size = collectgarbage("count")
  if size > 1024 * 128 then
    size = string.format("%.4f/GB", size / 1024 / 1024)
  elseif size > 1024 then
    size = string.format("%.4f/MB", size / 1024)
  else
    size = string.format("%.4f/KB", size)
  end
  return size
end

return function (action, mode, ...)
  -- 计算内存占用
  if action == 'count' then
    return string.format(cmd[action], calc_memory())
  end
  -- 变更运行模式
  if action == 'mode' then
    if mode == 'incremental' or mode == 'generational' then
      local v1, v2 = ...
      collectgarbage(mode, math.tointeger(v1), math.tointeger(v2))
    else
      return "\r\nYou can change to `incremental` or `generational` mode.\r\n"
    end
    return string.format(cmd[action], mode)
  end
  -- 完成一次单步的垃圾收集
  if action == 'step' then
    local s = sys.now()
    local before = calc_memory()
    collectgarbage("step", 0)
    local after = calc_memory()
    local e = sys.now()
    return string.format(cmd[action], before, after, e - s)
  end
  -- 完成一次完整的垃圾收集
  if action == 'collect' then
    local s = sys.now()
    local before = calc_memory()
    collectgarbage("collect")
    local after = calc_memory()
    local e = sys.now()
    return string.format(cmd[action], before, after, e - s)
  end
  -- 停止垃圾收集器
  if action == 'stop' then
    local status = collectgarbage("isrunning") and "Running" or "Stoped"
    if status == "Running" then
      collectgarbage('stop')
    end
    return string.format(cmd[action], status, "Stoped")
  end
  -- 启动垃圾收集器
  if action == 'start' then
    local status = collectgarbage("isrunning") and "Running" or "Stoped"
    if status == "Stoped" then
      collectgarbage('restart')
    end
    return string.format(cmd[action], status, "Running")
  end
  -- USAGE
  return string.format(USAGE)
end
