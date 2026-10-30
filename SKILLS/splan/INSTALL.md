# Splan 安装

## 1. 放 Skill

- Claude Code：`~/.claude/skills/splan/`
- opencode：`~/.config/opencode/skills/splan/`
- 其他工具：按该工具的 skill / instructions 目录放置，保持 `SKILL.md` + `references/` + `commands/` + `scripts/`

## 2. 注册命令

在 skill 目录运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/install_commands.ps1
```

默认 `-Target auto`：
- 检测已安装的工具（`~/.claude`、`~/.config/opencode`、`~/.cursor`、`~/.codex`、`~/.gemini`、项目级 `.github` / `.windsurf` / `.clinerules` / `.roo` / `.continue`）
- 检测到几个装几个，并输出工具名与目标目录
- 每个 `splan-*.md` 优先建 symlink；Windows 无权限时回退复制

指定工具或目录：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/install_commands.ps1 -Target claude
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/install_commands.ps1 -Target opencode
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/install_commands.ps1 -Target "D:\my-tool\commands"
```

项目级工具可用 `-Project` 指定项目根：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/install_commands.ps1 -Target copilot -Project "D:\my-project"
```

## 3. 工具目录

| 工具 | 目录 |
|---|---|
| claude | `~/.claude/commands` |
| opencode | `~/.config/opencode/command` |
| cursor | `~/.cursor/commands` |
| codex | `~/.codex/prompts` |
| copilot | `<project>/.github/prompts` |
| windsurf | `<project>/.windsurf/workflows` |
| cline | `<project>/.clinerules/workflows` |
| roo | `<project>/.roo/commands` |
| continue | `<project>/.continue/prompts` |
| gemini | `~/.gemini/commands`（TOML，Markdown 可能需转换） |

## 4. 验证

- 目标目录应有 8 个 `splan-*.md`
- 重启对应工具后，`/splan-new`、`/splan-req`、`/splan-next`、`/splan-done`、`/splan-change`、`/splan-check`、`/splan-enter`、`/splan-tidy` 可用
- `-WhatIf` 可预览安装动作
