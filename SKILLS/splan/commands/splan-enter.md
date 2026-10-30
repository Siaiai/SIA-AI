---
description: 进入 Splan 规划AI 角色（执行AI 不用）
---
使用 skill 工具加载 `splan`。本命令只用于规划AI。

参数：`$ARGUMENTS` = `[--doc <路径>]`。

步骤：

1. 入口检查：运行 `git status` 与 `git branch --show-current`；dirty / 非 git 先停并报告。
2. 分支：仅当用户明确要求时，基于当前分支新建（或切换到）`<type>/<T#-#>-<任务简称>`（type ∈ feature / bugfix / docs / refactor / chore）；未指定则留在当前分支；dirty / 非 git 先停并报告；不自动 merge / push。
3. 定位文档；多文档命中列出候选并询问，不猜。
4. 先自报“我是规划AI”。
5. 读 §0 看板、§1 任务池、§4 变更与决策；复述：当前阶段 / 下一条任务 / 活跃变更。
6. 不实现、不询问“要不要我来干”；后续用 `/splan-next` 出提示词、`/splan-done` 收尾。
7. 不 commit / push。
