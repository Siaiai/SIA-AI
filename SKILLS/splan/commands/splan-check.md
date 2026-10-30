---
description: 跑 Splan lint，汇总 ERROR / WARN
---
使用 skill 工具加载 `splan`。加载后自报“规划AI”。

参数：`$ARGUMENTS` = `[--doc <路径或目录>]`。

步骤：

1. 定位文档或目录。
2. 运行：
   `powershell -NoProfile -ExecutionPolicy Bypass -File "<skill目录>\scripts\plan_lint.ps1" -Path "<目标>" -Strict`
3. 汇总 ERROR / WARN：ERROR 必须修；WARN 逐条说明原因。
4. 不改文件、不 commit / push。
