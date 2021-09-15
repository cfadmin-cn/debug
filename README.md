## Debug Console

  cfadmin debug console

## 使用介绍

  1. 将当前库克隆到`3rd`目录下.

  2. 导入`local console = require "debug.console"`库.

  3. 使用`console.start('::1', 6666)`代码启动.

  4. 使用在终端使用命令`nc localhost 666`进行连接

## 演示

```shell
[candy@MacBookPro:~] $ nc localhost 9999

Welcome! This is cfadmin Debug Console:

  gc     -  can run/stop/modify/count garbage collectors.

  run    -  Execute the lua script like `main` coroutine.

-> gc

gc [command] [args]:

    [count]   -  Let the garbage collector report memory usage.

    [collect] -  Let the garbage collector do a full garbage collection.

    [start]   -  Let the garbage collector (re)start.

    [stop]    -  Let the garbage collector stop working.

    [mode]    -  Let the garbage change work mode(`incremental` or `generational`).

-> run

Run [command] :

  [filename] - Execute lua script file.(e.g: script/test.lua)

->
```
