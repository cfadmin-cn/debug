## Debug Console

  基于`cfadmin`实现的终端调试库.

## 安装介绍

  1. 将代码克隆到`3rd`目录下.

  2. 使用`local console = require "debug.console"`导入.

## 启动方式

  内部支持以下两种连接方式:

  1. 监听端口 - `console.start("127.0.0.1", 6666)`

  2. 监听文件 - `console.start("loca.sock")`

  第`1`种只能支持单进程模式, 第`2`种可自行配置文件名后支持多进程模式.

## 使用方法

  我们在`script/main.lua`内写入以下内容:

```lua
local console  = require "debug.console"
console.startx("local.sock")
```

  然后运行`./cfadmin -e script/main.lua`启动即可.(实际业务里只需要把代码写在最终启动之前即可)

  最后我们在命令行运行`nc -U local.sock`, 如看到如下输出则代表连接成功.

```bash
[candy@MacBookPro:~/Documents/cfadmin] $ nc -U local.sock

Welcome! This is cfadmin Debug Console:

  gc     -  Can run/stop/modify/count garbage collectors.

  run    -  Execute the lua script like `main` coroutine.

  dump   -  Prints more information about the specified data structure.

  stat   -  Process usage data analysis report.

>>>
```

  * `stat` - 输出进程使用状态

  * `run` - 启动指定文件名的脚本

  * `dump` - 可以格式化输出一些指定数据结构

  * `gc` - 允许用户手动操作`GC`

### 1. 查看进程状态

  我们运行`stat`, 然后会输出一些使用帮助. 

```bash
>>> stat

stat [command] :

  [cpu]    -   CPU kernel space and user space usage of the current process.

  [mem]    -   Memory usage report of the current process.

  [page]   -   `hard_page_fault` and `soft_page_fault` of the current process.

  [all]    -   Return all of the above information.

>>>
```

  使用`stat all`则可以输出所有内容. 如下所示:

```bash
>>> stat all

CPU(User): 0.40%

CPU(Kernel): 0.33%

Lua Memory: 239.7256/KB

Swap Memory: 0.0000/KB

Total Memory: 2.1720/MB

Hard Page Faults: 0

Soft Page Faults: 739

>>>
```

  其它命令参数只会输出指定内容.

### 2. 查看内部数据

  有时候我们需要查看Lua内部的一些数据, 这时候可以使用`dump`来完成:

```bash
>>> dump

dump [command] [key1] [key1] [keyN] :

  [global] - dump global table (`_G`).

  [registery] - dump lua debug registery table.

  [filename] - dump already loaded package and its return table .

  --

  `keyX` means we can get `deep value` like `table[key1][key2]..[keyN]`

  e.g :
   1. dump cf wait
   2. dump global string

>>>
```

  比如我们要打印全局表`_G`，看下内部有`Key`存在. 那么我们可以这样:

```bash
>>> dump g

global{
  ['tonumber'] = function: 0x107b22ec0
  ['error'] = function: 0x107b22550
  ['setmetatable'] = function: 0x107b22e20
  ['string'] = table: 0x7ffd8b508120
  ['pcall'] = function: 0x107b229b0
  ['rawset'] = function: 0x107b22d10
  ['rawget'] = function: 0x107b22cc0
  ['print'] = function: 0x107b22a40
  ['os'] = table: 0x7ffd8b5070f0
  ['io'] = table: 0x7ffd8b507620
  ['loadfile'] = function: 0x107b22670
  ['require'] = function: 0x7ffd8b506bb0
  ['coroutine'] = table: 0x7ffd8b5071b0
  ['utf8'] = table: 0x7ffd8b506870
  ['assert'] = function: 0x107b22280
  ['pairs'] = function: 0x107b22920
  ['rawequal'] = function: 0x107b22c10
  ['collectgarbage'] = function: 0x107b22300
  ['warn'] = function: 0x107b22b50
  ['table'] = table: 0x7ffd8b507420
  ['NULL'] = userdata: 0x0
  ['null'] = userdata: 0x0
  ['debug'] = table: 0x7ffd8b5073c0
  ['tostring'] = function: 0x107b23110
  ['math'] = table: 0x7ffd8b508850
  ['load'] = function: 0x107b22750
  ['ipairs'] = function: 0x107b22620
  ['_G'] = table: 0x7ffd8b505c30
  ['rawlen'] = function: 0x107b22c60
  ['type'] = function: 0x107b23140
  ['next'] = function: 0x107b228c0
  ['_VERSION'] = 'Lua 5.4'
  ['dofile'] = function: 0x107b224e0
  ['select'] = function: 0x107b22d70
  ['package'] = table: 0x7ffd8b506510
  ['getmetatable'] = function: 0x107b225d0
  ['xpcall'] = function: 0x107b231a0
}

counter:
  total keys count: 37
  string value count: 1
  function value count: 24
  usedata value count: 2
  table value count: 10

Done.
>>>
```

  是的! 你没有看错. 如果打印的是一个`table`则会对内部进行统计完成数据化返回.

  那么如果是一个函数呢? 如果函数是`lua`编写的, 那么`dump`可以定位到文件位置:

```bash
>>> dump g package loaded debug.console

debug.console{
  ['startx'] = function: 0x7ffd8b4118a0(3rd/debug/console.lua:86)
  ['start'] = function: 0x7ffd8b415760(3rd/debug/console.lua:76)
}

counter:
  total keys count: 2
  function value count: 2

Done.
>>>
```

  那如果想看一下`注册表`呢? 可以把`g`改为`r`来查看注册表的内容:

```bash
>>> dump r

registery{
  [1] = thread: 0x7ffd8c009a08
  [2] = table: 0x7ffd8b505c30
  ['__Task__'] = table: 0x7ffd8b406620
  ['FILE*'] = table: 0x7ffd8b507920
  ['_IO_input'] = file (0x7fff975c5d90)
  ['__G_UDP__'] = table: 0x7ffd8b510360
  ['_LOADED'] = table: 0x7ffd8b5062f0
  ['_UBOX*'] = table: 0x7ffd8b708c30
  ['_PRELOAD'] = table: 0x7ffd8b507090
  ['_IO_output'] = file (0x7fff975c5e28)
  ['__G_TCP__'] = table: 0x7ffd8b413ca0
  ['__TCP__'] = table: 0x7ffd8b5145f0
  ['__TIMER__'] = table: 0x7ffd8b409880
  ['_CLIBS'] = table: 0x7ffd8b506b70
  ['__G_TIMER__'] = table: 0x7ffd8b40a0a0
  ['__UDP__'] = table: 0x7ffd8b5102e0
}

counter:
  total keys count: 16
  usedata value count: 2
  thread value count: 1
  table value count: 13

Done.
>>>
```

  从这里可以看到, 语法就是`keyname` + `空格`的方式.

  这样也方便使用者可以快速定位, 增加运行时定位问题的一些能力.

### 3. 运行调试代码

  假设我们的代码有一个隐藏的`bug`, 但是每次重启后就无法定位了.

  并且每次启动一段时间内也没问题, 而一旦**某个时间点**或**某个特殊条件成立**就出现了.

  这时候我们就需要更多**运行时调试**的能力, 但是这时候我们并不`attach`来影响进程的执行能力.

  所以我们的框架必须提供一种**任何时候都能安全执行代码**的能力!

  现在让我们编写一个`script/demo.lua`的文件并写入如下的代码:

```lua
local function f1()
  print("f1")
end

local function f2()
  print("f2")
end


local function f()
  f1()
  f2()
end

f()
```
  
  编写完成后, 我们就尝试在运行中的框架内执行这个脚本:

```bash
>>> run script/demo.lua

Total Running Time: 0.000
Done.
>>>
```

  然后你会发现之前我们启动的框架那边输出了2行内容.

```bash
[candy@MacBookPro:~/Documents/cfadmin] $ ./cfadmin
f1
f2
```

  这就说明我们的代码运行成功了!
  
  但是这并不够! 因为有时候我们还需要运行的这段脚本只执行过程是什么.

  这时候我们可以在最后加上一个参数, 则会补充输出运行的脚本调用栈.

```bash
>>> run script/demo.lua true
callstack traceback:
 └----> [OK] [NEXT LINE] [script/demo.lua:3]
 └----> [OK] [NEXT LINE] [script/demo.lua:7]
 └----> [OK] [NEXT LINE] [script/demo.lua:13]
 └----> [OK] [NEXT LINE] [script/demo.lua:15]
 └--------> [OK] [NEXT LINE] [script/demo.lua:11]
 └------------> [OK] [NEXT LINE] [script/demo.lua:2]
 └------------> [OK] [NEXT LINE] [script/demo.lua:3]
 └------------> [OK] [GOTO BACK] [script/demo.lua:3]
 └--------> [OK] [NEXT LINE] [script/demo.lua:12]
 └------------> [OK] [NEXT LINE] [script/demo.lua:6]
 └------------> [OK] [NEXT LINE] [script/demo.lua:7]
 └------------> [OK] [GOTO BACK] [script/demo.lua:7]
 └--------> [OK] [NEXT LINE] [script/demo.lua:13]
 └--------> [OK] [GOTO BACK] [script/demo.lua:13]
 └----> [OK] [GOTO BACK] [script/demo.lua:15]
 └----> [OK] [NEXT LINE] [3rd/debug/run.lua:83]
 └----> [OK] [NEXT LINE] [3rd/debug/run.lua:84]

Total Running Time: 0.000
Done.
>>>
```

### 4. 开始调试GC

  一般情况下`GC`都会工作的很好, 而我们无需特意去干预它的执行.

  但有时候我们想尝试对其进行一些特殊操作, 以借助这些修改来观察其运行差异.

  这时候我们就需要利用到它的一些命令:

```bash
>>> gc

gc [command] [args]:

  [count]   -  Let the garbage collector report memory usage.

  [step]    -  Let the garbage collector do a step garbage collection.

  [collect] -  Let the garbage collector do a full garbage collection.

  [start]   -  Let the garbage collector (re)start.

  [stop]    -  Let the garbage collector stop working.

  [mode]    -  Let the garbage change work mode(`incremental` or `generational`).

>>>
```

  运行期间的垃圾收集器很敏感! 除非十分清除自己在干什么, 否则请不要随意干预它.

## 获取帮助

  有其它任何疑问, 请到我们的框架交流群内咨询.