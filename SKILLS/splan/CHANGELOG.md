# Changelog

Splan 版本记录。版本规则（D20）：

- **major**：破坏性变更
- **minor**：新增命令或规则
- **patch**：措辞或修复

## [1.0.0] - 2026-10-30

### 当前能力

- 由 plan-doc 重命名为 Splan，命令统一为 8 个 `/splan-*`。
- 新增 `/splan` 引导入口：启动自检 + 多工具命令安装。
- 多工具安装器：claude / opencode / cursor / codex / copilot / windsurf / cline / roo / continue / gemini；symlink 优先，失败回退复制。
- 加载 Splan 时自检 8 个 `splan-*.md`，缺失 / 不一致自动运行 `install_commands.ps1`，失败不阻断后续。
- 分支策略：仅在用户明确要求时新建分支；未指定留在当前分支；非 git 跳过。
- 版本策略：`SKILL.md` frontmatter `version` + 本 CHANGELOG（semver）。
