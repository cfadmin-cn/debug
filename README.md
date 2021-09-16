## Debug Console

  cfadmin debug console

## 使用介绍

  1. 将当前库克隆到`3rd`目录下.

  2. 导入`local console = require "debug.console"`库.

  3. 使用`console.start('::1', 6666)`代码启动.

  4. 使用在终端使用命令`nc localhost 6666`进行连接

## 内部演示

  以下内容仅做参考, 实际功能以后续版本迭代为主.


```lua
local console = require "debug.console"

console.start("localhost", 6666)
```

```shell
[candy@MacBookPro:~] $ nc localhost 6666

Welcome! This is cfadmin Debug Console:

  gc     -  Can run/stop/modify/count garbage collectors.

  run    -  Execute the lua script like `main` coroutine.

  dump   -  Prints more information about the specified data structure. 

>>> 
```
