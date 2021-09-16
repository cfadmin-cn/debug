-- 注意: 不可运行在多进程模式下.
assert(not worker, "[Lua Debug Console Error]: Only available in single process mode.")

local cf = require "cf"
local tcp = require "internal.TCP"

local server

local USAGE = [[

Welcome! This is cfadmin Debug Console:

  gc     -  Can run/stop/modify/count garbage collectors.

  run    -  Execute the lua script like `main` coroutine.

  dump   -  Prints more information about the specified data structure. 

>>> ]]

local command = {}

command['gc'] = require "debug.gc"

command['run'] = require "debug.run"

command['dump'] = require "debug.dump"

-- 解析客户端请求
local function command_split(cmd)
  local cmds = {}
  string.gsub(cmd, "[^ \r\n]+", function (s)
    cmds[#cmds+1] = s
  end)
  return table.remove(cmds, 1), cmds
end

-- 客户端处理事件
local function dispatch(ip, port)
  assert(server:listen(ip, port, function (fd, ipaddr)
    local client = tcp:new():set_fd(fd)
    client:send(USAGE)
    while true do
      local cmd = client:readline("[\r]?\n", true)
      if not cmd then
        break
      end
      local args
      cmd, args = command_split(cmd)
      if cmd then
        cmd = cmd:lower()
      end
      local f = command[cmd]
      if f then
        client:send(f(table.unpack(args)))
        client:send("\r\n>>> ")
      else
        client:send(USAGE)
      end
    end
    return client:close()
  end))
  return cf.wait()
end

local debug = {}

---comment 启动服务
---@param ip string    @监听地址
---@param port integer @监听端口
function debug.start(ip, port)
  assert(not server, "[Lua Debug Console Error]: Attempted to start multiple debug console.")
  server = tcp:new()
  return cf.fork(dispatch, ip, port)
end

return debug
