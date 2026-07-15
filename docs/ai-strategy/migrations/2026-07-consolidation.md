# 2026-07 — Consolidate AI tooling to `.opencode/` with retrocompat shims

**Date**: 2026-07-14
**Author**: opencode-driven audit, executed by Gabriel
**Type**: consolidation (low-risk add → high-risk shim → low-risk doc/commit)

## What changed

This migration was triggered by the existence of duplicated Claude Code + OpenCode tooling paths and the absence of an OpenCode-native configuration. Single source of truth is now `.opencode/`.

### Files added (canonical, in git)

| Path | Purpose |
|---|---|
| `opencode.json` | Canonical OpenCode config: `MiniMax/MiniMax-M3` default + small_model, `enabled_providers: ["MiniMax"]`, permissive base permissions with `.env` denied by default, `instructions: [AGENTS.md, AGENTS.local.md]`, `compaction.auto: true`, `share: manual`, `autoupdate: notify`. |
| `.mcp.json` | Project-scope MCP servers (no credentials): `context7` (remote) + `playwright` (local via `npx`). Credentialed servers (`github`, `google-analytics`) intentionally stay in local scope per `docs/00-SHARED/operations/MCP_SERVERS.md`. |
| `AGENTS.local.md` | Per-machine overrides template. Already gitignored (line 30 of `.gitignore`). Auto-loaded via `opencode.json` → `instructions`. |
| `.opencode/agents/<6 files>` | Specialists (`lua-mod-expert`, `wetlands-landing-page-developer`, `wetlands-mod-deployment`, `wetlands-mod-testing`, `wetlands-npc-expert`) + `wetlands-orchestrator` (delegator). Copied verbatim from `.claude/agents/` with the `model: sonnet` line dropped (OpenCode inherits the global default = `MiniMax/MiniMax-M3`). |
| `.opencode/commands/<3 files>` | `check-server`, `deploy`, `new-mod`. Copied from `.claude/commands/` with Claude-Code-only frontmatter trimmed (`argument-hint:`, `allowed-tools:`). Body unchanged. |
| `.opencode/skills/lua-style/SKILL.md` | Converted from `.claude/rules/lua-style.md`. Frontmatter: `name`, `description` only — `globs:` field dropped (OpenCode skills discover by description, not by glob). |
| `.opencode/skills/mod-structure/SKILL.md` | Converted from `.claude/rules/mod-structure.md`. |
| `.opencode/skills/voxelibre-compat/SKILL.md` | Converted from `.claude/rules/voxelibre-compat.md`. |
| `.opencode/skills/add-music/SKILL.md` | Copied from `.claude/skills/add-music/SKILL.md` with `argument-hint:`, `disable-model-invocation:`, `allowed-tools:` dropped. |
| `.opencode/skills/add-skin/SKILL.md` | Same pattern. |
| `scripts/setup-ai-shims.sh` | POSIX (Linux/macOS) script: replaces `.claude/{agents,commands,skills}/` with `ln -s` symlinks pointing at `.opencode/{agents,commands,skills}/`. Idempotent, with `--dry-run` and `--yes` flags. |
| `scripts/setup-ai-shims.ps1` | Windows PowerShell 5.1+ script: replaces the same dirs with `New-Item -ItemType Junction` (NTFS reparse points). Idempotent, with `-DryRun` and `-Yes` flags. Uses absolute target paths to avoid a PowerShell 5.1 quirk where `..\foo` is resolved against the cwd rather than the junction's parent. |
| `docs/ai-strategy/research-2026-07-14.md` | Phase 1 research output (OpenCode docs audit, MiniMax-M3 context, repo state inventory). |
| `docs/ai-strategy/plan-2026-07-14.md` | Phase 3 implementation plan (4 sub-phases, risk classification, rollback per step). |
| `docs/ai-strategy/migrations/2026-07-consolidation.md` | This file. |

### Files modified

- `AGENTS.md` — added an **AI tooling** section (between the mod-inventory tables and the Documentation index) listing skills, agents, commands, models & data residency, MCP servers, and a "When you change AI tooling" checklist. +65 lines, no removals.
- `.claude/{agents,commands,skills}/<tracked files>` — replaced by junctions pointing at `.opencode/{agents,commands,skills}/`. Each tracked file's content (visible through the junction) drops the same 1–3 frontmatter lines described above.

### Files left untouched (by design)

- `.claude/settings.json` — Claude Code reads this; OpenCode reads `opencode.json`.
- `.claude/settings.local.json` — gitignored; broad per-machine allow-list preserved.
- `.claude/rules/*.md` — Claude Code reads these. We converted the *content* to `.opencode/skills/` (above), but the originals stay for any direct Claude Code session that doesn't run setup-ai-shims.

### Files now gitignored

- `.claude/*.bak-*` (new pattern) — backs up directories before junction replacement. Created by `scripts/setup-ai-shims.{sh,ps1}` and intended for one-off rollback.

## Why

- The repo already had `.claude/{agents,commands,skills,rules,settings}` populated. OpenCode reads `.claude/` paths natively, so functionality was already there — but there was no canonical OpenCode config, no project-scope MCP, no `instructions:` array, no provider hygiene.
- Per Section 7.1 of the audit prompt, AGENTS.md should list Skills, Agents, Commands, and Models. It didn't.
- The Claude-Code-only frontmatter (`model: sonnet`, `allowed-tools:`, `disable-model-invocation:`, `globs:`, `argument-hint:`) was noise on the OpenCode side.
- The provider list would have shown 75+ providers by default; we whitelist `["MiniMax"]` to keep `/models` clean.

## Lessons learned

1. **PowerShell 5.1 `New-Item -ItemType Junction` rejects relative targets.** The `-Target` argument is resolved against the current working directory, not against the junction's parent. The first attempt at the script used `..\.opencode\agents` which PowerShell resolved as `<repo>/.opencode/..` = `<parent>/.opencode/agents` (which doesn't exist). Fix: pass the absolute target path from `Resolve-Path`. The standalone pre-flight test in `%TEMP%` caught this immediately on the second run, validating the "pre-flight mandatory before production shim" rule from the audit.
2. **Git's rename detection doesn't follow junctions.** With `.claude/agents/` as a junction to `.opencode/agents/`, git sees the directory contents as a normal `.claude/agents/` listing. Renaming `wetlands-server-orchestrator.md` → `wetlands-orchestrator.md` inside `.opencode/agents/` appears in git diff as a delete + add (the file moved to a different tracked path through the junction's lens). Reverting that rename gave a clean diff of just the 1-line `model:` trim per agent. Lesson: prefer keeping filenames identical across canonical and shimmed paths to minimize git diff noise. (Frontmatter `name:` is what OpenCode uses for discovery anyway.)
3. **Pre-existing character-encoding issues in source files are not the migration's responsibility.** The original `.claude/rules/lua-style.md` had a garbled em-dash between "server/mods/" and "covers structure". My `Write` preserved it verbatim because the migration is byte-preserving. Documented here for future cleanup but out of scope.
4. **Junctions produce "duplicate" entries in `git status`.** After the shim, `.claude/skills/{lua-style,mod-structure,voxelibre-compat}/` appear as untracked `??` because the junction makes those new `.opencode/skills/<name>/` paths visible at `.claude/skills/<name>/` too. The migration journal documents that these should NOT be committed — committing them would duplicate content in git history.

## Validation performed

- JSON syntax: `ConvertFrom-Json` on `opencode.json` + `.mcp.json` — both parse cleanly.
- Frontmatter extraction: every `.opencode/{agents,commands,skills}/*.md` (14 files) parsed with multiline-anchored regex; all have `name:` + `description:`; none have any Claude-Code-only field.
- File-count delta: agents `-1` line each (6 files), commands `-2` each (3 files), skills `-3` each (5 files), all consistent.
- `git status --short` before shim: 5 M (`.opencode/` tracked files) + 6 ?? (top-level new files/dirs).
- Junction resolution: `Get-Item .claude/skills/add-music` shows `Attributes = Directory, ReparsePoint` with `Target` populated. `Get-Content` through the junction returns the same content as through `.opencode/skills/add-music/SKILL.md`.
- SHA-256 equality: each `.claude/<dir>` (junction) and `.opencode/<dir>` (canonical) hash identically.
- Standalone junction test in `%TEMP%`: file content read through the junction matches the file written to the target.

## Rollback procedure

For any single shim pair (e.g. `.claude/skills`):

```powershell
# Windows
Remove-Item -LiteralPath ".claude\skills"                # remove the junction
Move-Item -LiteralPath ".claude\skills.bak-<timestamp>" ".claude\skills"
```

```bash
# POSIX
rm .claude/skills
mv .claude/skills.bak-<timestamp> .claude/skills
```

For a full rollback to pre-migration state:

```bash
git log --oneline -- docs/ai-strategy/migrations/2026-07-consolidation.md
# Find the migration commit, then:
git revert <commit-sha>
```

Or, if `.opencode/` files were removed:

```bash
git checkout HEAD~ -- .opencode/ opencode.json .mcp.json scripts/setup-ai-shims.{sh,ps1} docs/ai-strategy/
```

The .claude/{agents,commands,skills}/ originals are preserved as `.bak-<timestamp>` directories until the user explicitly deletes them.

## Related docs

- `docs/ai-strategy/research-2026-07-14.md` — Phase 1 research output.
- `docs/ai-strategy/plan-2026-07-14.md` — Phase 3 implementation plan.
- `docs/00-SHARED/operations/MCP_SERVERS.md` — MCP server inventory (now partly mirrored to `.mcp.json`).
- `AGENTS.md` "AI tooling" section — canonical inventory going forward.
