local cf = require "cf"
local sys = require "sys"

local collectgarbage = collectgarbage

local fmt = string.format

local u, k = '0.0', '0.0'
local utime, ktime = nil, nil

local USAGE = [[

stat [command] :

  [cpu]    -   CPU kernel space and user space usage of the current process.

  [mem]    -   Memory usage report of the current process.

  [page]   -   `hard_page_fault` and `soft_page_fault` of the current process.

  [all]    -   Return all of the above information.
]]

local CPU = [[

CPU(User): %2.2f%%

CPU(Kernel): %2.2f%%
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

cf.at(1, function ()
  local info = sys.usage()
  if not info then
    return
  end
  local su, sk = info.utime, info.ktime
  if not utime or not ktime then
    u, k = su, sk
    utime, ktime = su, sk
  else
    u, k = (su - utime) * 1e2, (sk - ktime) * 1e2
    utime, ktime = su, sk
  end
  -- print(u, utime, k, ktime)
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
