local cf = require "cf"
local sys = require "sys"

local collectgarbage = collectgarbage

local fmt = string.format

local mrandom = math.random

local bu, bk = 0, 0
local u, k = "0.0", "0.0"

local USAGE = [[

stat [command] :

  [cpu]    -   CPU kernel space and user space usage of the current process.

  [mem]    -   Memory usage report of the current process.

  [page]   -   `hard_page_fault` and `soft_page_fault` of the current process.

  [all]    -   Return all of the above information.

]]

local CPU = [[

CPU(User): %s%%

CPU(Kernel): %s%%
]]

local MEM = [[

Lua Memory: %s

Swap Memory: %s

Total Memory: %s
]]

local PAGE = [[

Hard Page Faults: %d

Soft Page Faults: %d
]]

local function check_wrap(cpu)
  local radio = cpu * 0.01
  if radio <= 1 then
    return cpu
  end
  return cpu * (mrandom(4, 6) * 0.1) * radio
end

cf.at(0.5, function ()
  local info = sys.usage()
  if not info then
    return
  end
  local utime, ktime = info.utime, info.ktime
  local uradio, kradio = (utime - bu) * 100, (ktime - bk) * 100
  if uradio > 0.09 then
    u = fmt("%.1f", check_wrap(uradio))
  end
  if kradio > 0.09 then
    k = fmt("%.1f", check_wrap(kradio))
  end
  bu, bk = utime, ktime
  -- print(u, k, bu, bk)
  -- TODO
end)

local function calc_usage(size)
  if size > 1024 * 1024 * 128 then
    size = fmt("%.4f/TB", size / 1024 / 1024 / 1024)
  elseif size > 1024 * 128 then
    size = fmt("%.4f/GB", size / 1024 / 1024)
  elseif size > 1024 then
    size = fmt("%.4f/MB", size / 1024)
  else
    size = fmt("%.4f/KB", size)
  end
  return (size)
end

local function get_info(cpu, mem, page)
  local info, err = sys.usage()
  if not info then
    return fmt("\r\nERROR: %s\r\n", err)
  end
  local str = ""
  if cpu then
    str = str .. fmt(CPU, u, k)
  end
  if mem then
    str = str .. fmt(MEM, calc_usage(collectgarbage("count")), calc_usage(sys.os() == 'Linux' and info.swap or info.swap * 1e-3), calc_usage(sys.os() == 'Linux' and info.rss or info.rss * 1e-3))
  end
  if page then
    str = str .. fmt(PAGE, info.hard_page_fault, info.soft_page_fault)
  end
  return str
end

return function (action)
  -- CPU使用率
  if action == 'cpu' or action == 'c' then
    return get_info(true, false, false)
  end
  -- 内存使用率
  if action == 'mem' or action == 'm' then
    return get_info(false, true, false)
  end
  -- 缺页 (PAGE FAULTS)
  if action == 'page' or action == 'p' then
    return get_info(false, false, true)
  end
  -- 获取所有信息
  if action == 'all' or action == 'a' then
    return get_info(true, true, true)
  end
  return USAGE
end
