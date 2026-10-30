---
name: splan
version: 1.0.0
description: >
  Maintain long-lived project planning documents (plan / task table / implementation log /
  change log) in any repository or folder. Use when the user creates or updates PLAN.md,
  docs/plan.md, *.plan.md, asks 下一步做什么 / 这条做完了 / 需求变了 / 检查规划, or invokes
  /splan-new, /splan-next, /splan-done, /splan-change, /splan-check. Plain Markdown with no
  Obsidian dependency. Covers task IDs, P0/P1 ordering, change log (C IDs), one-line
  implementation records, archiving, and lint. Do NOT use for one-off edits or pure Q&A.
---

# Splan — 长期规划文档工作流

用于「一个项目跨多天、多任务、需求会变」的规划文档。纯 Markdown，不依赖 Obsidian 或任何笔记软件；放在哪个仓库、哪个目录都可以。

> **怎么用**：读 `references/sop.md`（使用手册）。里面是"什么时候发什么提示词"的时刻表，全部可复制。

## 启动自检

加载本 skill 后、开始任务前先做一次命令注册自检；同一会话已通过可跳过。自检失败只提示，不阻断后续。

1. **判断当前工具**（按优先级；不猜）：
   - 用户 / 命令参数显式指定：`/splan-setup <tool>`、`-Target <tool>`
   - 运行环境 / 进程特征：`CLAUDECODE`、`OPENCODE`、`CURSOR`、`CODEX`、`GEMINI`、`COPILOT`、`WINDSURF`、`CLINE`、`ROO`、`CONTINUE`
   - skill 安装路径：`.../.claude/skills/` → claude；`.../.config/opencode/skills/` → opencode
   - 项目级目录：`.github` → copilot、`.windsurf` → windsurf、`.clinerules` → cline、`.roo` → roo、`.continue` → continue
   - 仍无法判断：不要猜，提示用户用 `/splan-setup <tool>` 或 `install_commands.ps1 -Target <tool>`
   - 工具：claude / opencode / cursor / codex / copilot / windsurf / cline / roo / continue / gemini
2. **检查目标目录**：对应 command 目录应有 8 个任务命令：`splan-new` / `splan-req` / `splan-next` / `splan-done` / `splan-change` / `splan-check` / `splan-enter` / `splan-tidy`（另加入口 `splan-setup.md`）。比对数量与文件名；若存在退役入口 `splan.md`，删除它。
3. **缺失 / 不一致**：运行
   `powershell -NoProfile -ExecutionPolicy Bypass -File "<skill目录>\scripts\install_commands.ps1" -Target <tool>`
   项目级工具加 `-Project <项目根>`；自定义目录用 `-Target <目录>`。
4. **告知用户**：`检测到 <tool> → <目录>，已安装 <N>/8 个任务命令（入口：有/无）`；补装 / 修复了哪些一并说明。
5. **失败不阻断**：安装失败、无权限或检测不到工具时，输出目标目录、错误摘要和手动命令，继续当前任务；缺失 / 不一致时覆盖同步（同名以仓库为准），不删除其它命令（退役入口 `splan.md` 除外）。

## 角色与边界

加载本 skill 后先自报角色：**规划AI** 或 **执行AI**，再按各自边界干活。

| 角色 | 职责 | 不做什么 |
|---|---|---|
| **规划AI** | 拆任务 / 记变更 / 出执行提示词 / 收尾记录（§5 / §6 / §0） | 不做实现；不跑命令验证；不问"要不要我来干"，直接出提示词 |
| **执行AI** | 只做一条任务 / 跑命令验证 / 按 7 段式回报 | 不改规划文档；不 commit / push；越界或需新建机制先停下 |

规划AI 只写规划文档并出提示词；执行AI 只改代码并回报，不动规划文档。越界反例见 `references/pitfalls.md`（角色越界）。

角色例外：需求 intake 可问「选哪个方案」；执行阶段不问「要不要我来干」。

提交归属：规划AI 在 `/splan-done` 审 diff、核对验证、更新文档后按默认规则判断提交（本任务文件 + 验证通过 + 文档更新 + lint 0）；`--commit` 强制提交、`--no-commit` 跳过；执行AI 不提交；push 永不自动。

执行AI 回报固定 7 段式（≤15 行 / 300 字），只给事实，不写下一步：

1. **结论**：一句话说清做了什么、是否通过
2. **改动清单**：文件 + 改了什么
3. **原理与机制**：为什么这么做、机制、取舍、替代方案（代码改动必填；纯文档可省略）
4. **验证**：命令 / 人工步骤 + 结果
5. **行为变化**：用户可见的前后差异
6. **§5 记录**：一行可直接粘贴的记录
7. **遗留与风险**：未完成、已知偏差、后续注意

验证归属：命令由执行AI 跑并在回报给命令 + 结果；人工由用户按步骤确认；未确认不勾 `[x]`。规划AI 不重跑，只审 diff / 文档 + 跑 Splan lint。

## 分支策略（D19）

- 执行AI 仅在用户明确要求时，基于当前分支新建 `<type>/<T#-#>-<任务简称>`；未指定则留在当前分支。
- `type` ∈ feature / bugfix / docs / refactor / chore。
- dirty / 非 git：执行AI 先停并报告，不新建分支。
- 规划AI 在当前分支提交；不自动 merge / push：merge 需显式要求，push 禁止。

## 何时用

- 新建或维护项目规划：`PLAN.md`、`docs/plan.md`、`*.plan.md`，或用户指定的任意路径
- 从规划文档领任务、写实施记录、收尾归档
- 需求变更，任务取消 / 取代 / 延期
- 用户说：下一步做什么、这条做完了、需求变了、检查规划
- 调用 `/splan-*` 命令

不适用：一次性小改动、纯问答、写文章。

需求随时可加：用 `/splan-req`。不要求一次想清楚——不明确就先记 `状态=待澄清`，生成一条带时盒、"产出=结论"的探索任务，后面再转实现。入口只有需求登记表 / 假设。

## 文件位置

- 默认：项目根 `PLAN.md`；也可用 `docs/plan.md` 或用户指定路径
- 定位顺序：`--doc <路径>` → 第一个参数是存在的 `.md`（旧写法） → `AGENTS.md` 指针 → `PLAN.md` → `docs/plan.md` → 最近 `*.plan.md`（Obsidian 取最近含 `plan-doc:v1` 标记的笔记）
- 多文档命中：列出候选并询问，不猜
- 如果目标文件位于 Obsidian vault 内：位置按该 vault 规范（如 `{领域}/{项目}/YYMMDD{任务}.md`），笔记属性参考 vault 的 `规范.md` / 模板（映射见 `references/obsidian.md`）；否则使用本 skill 的通用格式
- 本 skill 不要求任何特定属性名；通用格式只有 `title / status / created / updated`

## 方案单一入口

- 方案只放规划文档 §3；任务行只保留摘要；不另建方案文档
- 用户可改 §3；规划AI 以 §3 为准，`/splan-next` 先复述方案差异，冲突记 C，不覆盖用户编辑
- 方案讨论：规划AI 给 1–3 个选项，用户确认后落 §3

## 单一事实源（冲突优先级）

1. 目标仓库的 `AGENTS.md` / `README.md`
2. 本 skill 的 `references/format.md`
3. 目标文档 §2 契约
4. 代码与测试

在 Obsidian vault 内：vault 的 `规范.md` 优先于本 skill 的 frontmatter 约定。

代码/测试与文档冲突时：**以代码为准**，并把差异作为一条 C 变更写回文档。

## 铁律

1. 任务 ID 只增不改，取消的号永久作废；新任务往后排。
2. 已完成任务的原文不改；后续一切变化只追加 C 条目。
3. `[x]` 只代表验证手段已通过（命令跑过或人工确认）；未通过不许勾。
4. §1 只放未完成；完成 / 取消 / 取代 / 延期移到 §6 归档。
5. 一条任务 = 一次会话能完成 + 验证手段可复现。
6. 任务必须挂 `需求：R#`，说清为什么做；没有 R 的任务不该存在。
7. 需求变更必须落到某个 R，并打到五个面：任务、契约、测试、文档、机制。
8. 每次会话结束更新三处：§0 状态、§1 下一条、§5 一行记录。
9. 一功能一机制：优先扩展现有机制；新建机制必须先立 D 决策，执行中发现要新建必须停下。
10. 不删改无关文件；不碰 `.git/`；执行AI 不 commit / push；规划AI 在 `/splan-done` 默认判断提交（本任务文件 + 验证通过 + 文档更新 + lint 0），`--commit` 强制、`--no-commit` 跳过，push 禁止。
11. 改完必须更新文档；没更新文档的"完成"不算完成（§5 一行 + §6 归档 + §0 同步）。

## 命令

主对象在前（需求 / 任务ID / 描述），`--doc <路径>` 可选；未传时按「文件位置」的定位顺序查找，多文档命中先询问。

| 命令                       | 作用                                |
| ------------------------ | --------------------------------- |
| `/splan-setup [tool]`    | **引导入口**：自检命令注册、安装缺失命令；`tool` 缺省 auto |
| `/splan-new <标题> [--doc <路径>]`    | **初始化**：读代码 + 建基线 / 机制 / 索引，不规划需求 |
| `/splan-req <需求> [--doc <路径>] [--fast]`    | **随时新增需求**（唯一需求入口）；默认两阶段，确认后分配 R / 建任务；`--fast` 跳过阶段 1 |
| `/splan-next [<任务ID>] [--doc <路径>]`   | 只读，输出下一条任务的执行提示词                  |
| `/splan-done <任务ID> [--doc <路径>] [--commit / --no-commit]` | 审 diff、验证、更新三处；默认判断提交 |
| `/splan-change <描述> [--doc <路径>]` | 记录 C 变更并更新受影响任务                   |
| `/splan-check [--doc <路径>]`    | 跑 lint，汇总 ERROR / WARN            |
| `/splan-enter [--doc <路径>]` | 进入规划AI：复述阶段 / 下一条 / 活跃变更；不实现 |
| `/splan-tidy [--format / --all] [--doc <路径>]` | 整理文档；默认合并去重，`--format` 同步格式、`--all` 两者 |

`/splan-enter` 只指定规划AI；执行AI 直接用 `/splan-next` 的自包含提示词，完成后由规划AI 用 `/splan-done` 收尾。

`/splan-req` 默认阶段 1 只讨论：不写文档、不分配 R、不建任务、不跑 lint；确认后分配 R / 写 §3 / 建任务。`--fast` 跳过讨论，但仍做查重 / 冲突检查。

`/splan-req --doc <外部笔记>`：按 `references/obsidian.md` 读入笔记 → 登记 R + `文档` 列 + 拆任务；未传 `--doc` 时行为不变；笔记缺失不猜，提示补。

`/splan-done` 时若该 R 有 `文档`：回写外部笔记——勾待办项；该 R 全部任务完成才置完成并写 `完成时间`，未全完成只置进行；笔记缺失或找不到待办项记 WARN，不猜。

命令未加载时，按 `references/tasks.md` 中的同名流程手工执行。

## Lint 门禁

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "<skill目录>\scripts\plan_lint.ps1" -Path "<文档>" -Strict
```

- ERROR：必须修完才能继续
- WARN：可以接受，但回复里要逐条说明原因
- `/splan-done`、`/splan-change`、`/splan-check` 收尾必须跑一次
- 文档含 `<!-- plan-doc:v1 -->` 标记才启用严格检查；旧文档自动降级为兼容模式（只报 WARN）
- 目录扫描加 `-PlanOnly` 只检查含该标记的规划文档；显式传文件总是检查

## 参考文件

- `references/sop.md`：**使用手册**——什么时候发什么提示词（人读这个）
- `assets/plan-template.md`：创建模板（/splan-new 使用）
- `references/recon.md`：初始化侦察清单（读代码 → 基线 / 机制 / 索引）
- `references/format.md`：文档骨架、任务行、机制登记、变更规则
- `references/tasks.md`：任务粒度、ID、验收、拆分、变更操作流
- `references/pitfalls.md`：常见坑
- `references/obsidian.md`：可选的 Obsidian 笔记属性映射（不绑定）

## 安装与加载

- Skill：`~/.claude/skills/splan/`（Claude）或 `~/.config/opencode/skills/splan/`（opencode）
- 入口：`/splan-setup [tool]`；自检命令注册并同步 8 个任务命令 + 入口 `splan-setup.md`，`tool` 缺省 auto
- 命令：运行 `scripts/install_commands.ps1`（`-Target auto` 自动检测；symlink 优先，失败回退复制；缺失 / 不一致时覆盖同步，同名以仓库为准，不删除其它命令，退役入口 `splan.md` 除外），或手动复制 `commands/splan*.md` 到对应工具的 command 目录
- 命令目录：Claude `~/.claude/commands/`；opencode `~/.config/opencode/command/`；其他工具见 `INSTALL.md`
- 新增 / 修改 skill 或 command 后重启对应工具
