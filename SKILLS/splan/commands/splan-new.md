---
description: 初始化 Splan 规划文档（只读侦察 + 基线/机制/索引，不规划需求）
---
使用 skill 工具加载 `splan`。加载后自报“规划AI”。

参数：`$ARGUMENTS` = `<标题> [--doc <路径>]`。标题必填；`--doc` 可选，未传时按 SKILL.md「文件位置」定位，找不到则新建。

步骤：

1. 确定目标：`--doc` 指定；未传时按定位顺序查找，找不到就在当前目录新建 `PLAN.md`；Obsidian vault 内按 vault 规范 `{领域}/{项目}/YYMMDD{任务}.md`。
2. 确定仓库：参数里的仓库路径；否则当前目录；多个仓库都记下。
3. **只读侦察**（`references/recon.md`）：README / AGENTS / docs、构建文件、测试、入口、关键模块、`git log -20`、现有机制。
4. 用 `assets/plan-template.md` 建文档，只填：§0 基线 / 机制登记、§7 参考与索引、§3 可选 mermaid。
5. **需求登记和任务池留空/占位**，不编造需求。
6. Obsidian vault 内读 `规范.md` 补属性（见 `references/obsidian.md`）。
7. 跑 lint（不加 `-Strict`）：`powershell -NoProfile -ExecutionPolicy Bypass -File "<skill目录>\scripts\plan_lint.ps1" -Path "<目标>"`。
8. 回复：读到了什么（仓库/构建/测试/机制）、路径、lint、下一步 `/splan-req`。
9. 不 commit / push。
