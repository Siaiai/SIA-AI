---
description: 整理 Splan 文档（默认内容整理；--format 格式同步；--all 两者）
---
使用 skill 工具加载 `splan`。加载后自报“规划AI”。

参数：`$ARGUMENTS` = `[--format / --all] [--doc <路径>]`。默认内容整理。

步骤：

1. 定位文档。
2. 默认内容整理：读代码 / 文档 → 找漂移 → 同步 §0 → 整理 §1/§4/§5/§6/§7 → 合并 / 去重（D12）→ 超 800 行拆 P2。
3. `--format`：从磁盘重读最新 skill（优先仓库 `SKILLS/splan`），按 `references/format.md` 的「布局迁移检查清单」逐项核对，迁移到「关联表 / 状态总览」布局，只改结构不改语义；回报里列出清单勾选结果。
4. `--all`：两者都做。
5. 跑 lint（-Strict），ERROR 清零；WARN 逐条说明。
6. 不改需求语义、不改代码、不 commit / push。
