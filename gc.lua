local sys = require "sys"

local collectgarbage = collectgarbage

local USAGE = [[

gc [command] [args]:

    [count]   -  Let the garbage collector report memory usage.

    [collect] -  Let the garbage collector do a full garbage collection.

    [start]   -  Let the garbage collector (re)start.

    [stop]    -  Let the garbage collector stop working.

    [mode]    -  Let the garbage change work mode(`incremental` or `generational`).
]]

local cmd = {}

cmd.count = [[

collectgarbage response :

  currunt memory size: %s
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
  if size > 1024 then
    size = string.format("%.4f/MB", size / 1024)
  else
    size = string.format("%.4f/KB", size)
  end
  return size
end

return function (action, ...)
  if action == 'count' then
    return string.format(cmd[action], calc_memory())
  end
  -- 完成一次完整的垃圾收集
  if action == "collect" then
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
    collectgarbage('stop')
    return string.format(cmd[action], status, collectgarbage("isrunning") and "Running" or "Stoped")
  end
  -- 启动垃圾收集器
  if action == 'start' then
    local status = collectgarbage("isrunning") and "Running" or "Stoped"
    collectgarbage('restart')
    return string.format(cmd[action], status, collectgarbage("isrunning") and "Running" or "Stoped")
  end
  -- USAGE
  return string.format(USAGE)
end