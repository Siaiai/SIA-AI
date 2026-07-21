---
name: eide-mcp-tools
description: >-
  Operate EIDE embedded projects via MCP tools (build, flash, source dirs,
  include paths, defines, builder options, targets). Use when modifying EIDE
  project configuration, building, flashing, or managing MCU firmware projects
  with the eide-mcp-server. Prefer MCP tools over editing .eide/eide.yml directly.
---

# EIDE MCP Tools

Use the EIDE MCP server tools to read and modify project settings. **Do not edit `.eide/eide.yml` directly** when an MCP tool can perform the same change.

## Critical rules

### 1. Prefer tools over manual YAML edits

| Task | Use this tool | Do NOT |
|------|---------------|--------|
| Add/remove source directory | `eide_add_src_dir` / `eide_del_src_dir` | Edit `srcDirs` in `eide.yml` |
| Exclude/include source file | `eide_exclude_src_file` / `eide_include_src_file` | Edit exclude lists in `eide.yml` |
| Set include directories | `eide_set_inc_dirs` | Edit `incList` in `eide.yml` |
| Set preprocessor defines | `eide_set_defines` | Edit `defineList` in `eide.yml` |
| Set builder/toolchain options | `eide_set_builder_opts` | Edit toolchain options in `eide.yml` |
| Switch build target | `eide_switch_target` | Edit active target in `eide.yml` |
| Build / rebuild / clean / flash | `eide_build` / `eide_rebuild` / `eide_clean` / `eide_flash` | Run shell commands manually |

Read current state with the matching `eide_get_*` tool before making changes.

### 2. Reload after editing `eide.yml`

If you **must** edit `.eide/eide.yml` manually (no tool covers the change, or the user edited the file), call **`eide_reload`** immediately afterward so EIDE reloads the project from disk.

```
edit eide.yml → eide_reload(uid) → wait for success → continue
```

`eide_reload` waits ~3 seconds after success before returning. Do not call other tools until it completes.

### 3. One tool at a time — no parallel calls

**Never invoke multiple EIDE MCP tools in parallel.** Run exactly one tool call, wait for its result, then proceed.

- Do not batch `eide_build` with `eide_set_defines` in the same turn.
- Do not fire read tools concurrently unless strictly necessary; prefer sequential `get` → `set` → verify.
- Long-running tools (`eide_build`, `eide_rebuild`, `eide_flash`) block until finished (timeout up to 300s).

## Project UID

Almost every tool requires `uid`:

```
<workspace>/.eide/eide.yml → miscInfo.uid
```

Read `eide.yml` only to obtain `uid` if unknown. Do not use file edits as the primary way to change project settings.

## Tool reference

### Build & flash

#### `eide_build`
Incremental build (no full rebuild).

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `uid` | string | yes | Project UID |

#### `eide_rebuild`
Full rebuild (clean + build).

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `uid` | string | yes | Project UID |

#### `eide_clean`
Remove generated artifacts under the project's `build` directory.

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `uid` | string | yes | Project UID |

#### `eide_flash`
Program flash memory on the MCU.

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `uid` | string | yes | Project UID |
| `eraseAll` | boolean | yes | If `true`, chip erase before programming |

Typical flow: `eide_build` → `eide_flash` (sequential, not parallel).

---

### Project lifecycle

#### `eide_reload`
Reload project from disk after manual changes to project files (especially `eide.yml`).

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `uid` | string | yes | Project UID |

Call after any direct edit to `.eide/eide.yml` or other EIDE project files that tools do not update.

#### `eide_get_targets`
Get active target and all target names.

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `uid` | string | yes | Project UID |

Returns JSON: `{ "actived": "...", "targets": ["..."] }`.

#### `eide_switch_target`
Switch the active build target.

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `uid` | string | yes | Project UID |
| `targetName` | string | yes | Target name from `eide_get_targets` |

---

### Source directories & files

#### `eide_get_src_dirs`
List all source root directories (JSON array of relative paths).

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `uid` | string | yes | Project UID |

#### `eide_add_src_dir`
Add a directory; EIDE collects C/C++ sources from it.

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `uid` | string | yes | Project UID |
| `path` | string | yes | Directory path (relative or absolute) |

#### `eide_del_src_dir`
Remove a source directory from the project (does not delete files on disk).

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `uid` | string | yes | Project UID |
| `path` | string | yes | Directory path to remove |

#### `eide_exclude_src_file`
Add a file to the build exclude list.

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `uid` | string | yes | Project UID |
| `path` | string | yes | Source file path |

#### `eide_include_src_file`
Remove a file from the exclude list so it is built again.

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `uid` | string | yes | Project UID |
| `path` | string | yes | Source file path |

---

### Include paths & defines

#### `eide_get_inc_dirs`
List include directories used for the build (JSON array).

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `uid` | string | yes | Project UID |

#### `eide_set_inc_dirs`
Replace include directories.

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `uid` | string | yes | Project UID |
| `paths` | string[] | yes | Full include directory list |

Workflow: `eide_get_inc_dirs` → modify list → `eide_set_inc_dirs`.

#### `eide_get_defines`
List preprocessor macro defines (JSON array).

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `uid` | string | yes | Project UID |

#### `eide_set_defines`
Replace user preprocessor defines.

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `uid` | string | yes | Project UID |
| `defines` | string[] | yes | e.g. `["DEBUG=1", "USE_HAL"]` |

Workflow: `eide_get_defines` → modify list → `eide_set_defines`.

---

### Builder / toolchain options

#### `eide_get_builder_opts_schema`
Get JSON Schema for builder options of the project's toolchain.

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `uid` | string | yes | Project UID |

Call before `eide_set_builder_opts` when unsure of valid fields.

#### `eide_get_builder_opts`
Get current builder options (JSON object).

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `uid` | string | yes | Project UID |

#### `eide_set_builder_opts`
Update builder options (validated against schema).

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `uid` | string | yes | Project UID |
| `options` | object | yes | Builder options JSON |

Workflow: `eide_get_builder_opts_schema` → `eide_get_builder_opts` → merge changes → `eide_set_builder_opts`.

---

## Common workflows

### Change defines and rebuild

```
1. eide_get_defines(uid)
2. eide_set_defines(uid, [...])
3. eide_build(uid)
```

Each step waits for the previous result. No parallel calls.

### Add a source folder

```
1. eide_get_src_dirs(uid)          # optional: verify current state
2. eide_add_src_dir(uid, path)
3. eide_build(uid)                 # optional: verify compile
```

### Fix project after manual `eide.yml` edit

```
1. (user or agent edited .eide/eide.yml)
2. eide_reload(uid)
3. eide_get_* or eide_build as needed
```

### Configure toolchain options

```
1. eide_get_builder_opts_schema(uid)
2. eide_get_builder_opts(uid)
3. eide_set_builder_opts(uid, options)
4. eide_rebuild(uid)
```

## Error handling

- `isError: true` in the tool result means failure; read the text content for details.
- Missing or wrong `uid` → project not found.
- After `eide_switch_target`, the server waits ~1.5s internally; still do not overlap with other tool calls.
- **MCP service-level failures** (connection errors, tools unavailable, repeated failures): follow “When MCP is unavailable” above—ask the user to check the service; use MCP-first priority, and **do not** automatically fall back to shell build/flash.
- **While editing `eide.yml`**: never add keys that do not exist in the file; never change `deviceName`.
