---
description: Splan 引导入口：自检命令注册、安装缺失命令并进入规划流程
---
使用 skill 工具加载 `splan`。

参数：`$ARGUMENTS` = `[tool]`，缺省 `auto`。`tool` 可为 claude / opencode / cursor / codex / copilot / windsurf / cline / roo / continue / gemini，也可传命令目录路径。

步骤：

1. 解析参数：为空 → `auto`。
2. 判断工具：优先用参数；`auto` 时按环境变量、进程特征、skill 安装路径、项目级目录检测。检测不到不要猜，提示用户改用 `/splan-setup <tool>`（或 `install_commands.ps1 -Target <tool>`）。
3. 运行安装脚本自检 / 安装：
   `powershell -NoProfile -ExecutionPolicy Bypass -File "<skill目录>\scripts\install_commands.ps1" -Target <tool>`
   项目级工具加 `-Project <项目根>`；自定义目录用 `-Target <目录>`。
4. 检查目标目录的 8 个任务命令（不含入口 `splan-setup.md`），输出：
   `检测到 <tool> → <目录>，已安装 <N>/8 个任务命令（入口：有/无）`
   （N = 8 个任务命令中实际存在的数量；补装 / 修复了哪些一并说明。）
   多个工具命中就逐个输出；安装失败输出原因和手动命令，不阻断后续。
   目标目录若有退役入口 `splan.md`，删除它；不删除其它命令。
5. 告知下一步：规划AI 用 `/splan-enter`；执行AI 用 `/splan-next` 生成自包含提示词。
6. 不改规划文档、不 commit / push。
