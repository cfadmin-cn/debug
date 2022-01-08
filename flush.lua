local Co = require "internal.Co"
local Timer = require "internal.Timer"
local TCP = require "internal.TCP"
local UDP = require "internal.UDP"

local sys = require "sys"
local now = sys.now

local USAGE = [[

flush [COMMAND]:

  all - flush all cache.
]]

local DONE = [[

  clean Co space : %.6f/Sec

  clean TCP space : %.6f/Sec

  clean UDP space : %.6f/Sec

  clean Timer space : %.6f/Sec

Done.]]

return function (cmd)
  if cmd ~= 'all' then
    return USAGE
  end

  local start, co, tcp, udp, timer
  -- 协程
  start = now()
  Co.flush()
  co = now() - start
  -- TCP
  start = now()
  TCP.flush()
  tcp = now() - start
  -- UDP
  start = now()
  UDP.flush()
  udp = now() - start
  -- 定时器
  start = now()
  Timer.flush()
  timer = now() - start

  return string.format(DONE, co, tcp, udp, timer)
end