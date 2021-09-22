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

  stat   -  Process usage data analysis report.

>>> ]]

local command = {}

-- GC 命令行处理
command['gc'] = require "debug.gc"

-- RUN 命令行处理
command['run'] = require "debug.run"

-- DUMP 命令处理
command['dump'] = require "debug.dump"

-- STAT 命令处理
command['stat'] = require "debug.stat"

-- 解析客户端请求
local function command_split(cmd)
  local cmds = {}
  string.gsub(cmd, "[^   \t\r\n]+", function (s)
    cmds[#cmds+1] = s
  end)
  return table.remove(cmds, 1), cmds
end

-- 客户端处理事件
local function dispatch(fd)
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
end

local debug = {}

---comment 启动`IP`与`Port`服务
---@param ip string    @监听地址
---@param port integer @监听端口
function debug.start(ip, port)
  assert(not server, "[Lua Debug Console Error]: Attempted to start multiple debug console.")
  return cf.fork(function ()
    server = tcp:new()
    assert(server:listen(ip, port, dispatch))
  end)
end

---comment 启动`Unix Domain Socket`监听服务
---@param unix_domain_path string @启动环境
function debug.startx(unix_domain_path)
  assert(not server, "[Lua Debug Console Error]: Attempted to start multiple debug console.")
  return cf.fork(function ()
    server = tcp:new()
    assert(server:listen_ex(unix_domain_path, true, dispatch))
  end)
end

return debug