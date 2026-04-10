# MultiPlus

`MultiPlus` is a small wrapper CLI for creating reusable, local Codex workspaces in any folder.

It does three things:

- bootstraps a clean workspace template
- manages multiple local profiles such as `personal`, `work`, or `free`
- delegates auth and execution to the official `codex` CLI instead of storing or inventing its own account system
- can optionally shell out to `fuelcheck --json` for richer per-profile status artifacts

## Why

The core idea is simple: treat Codex home state as local project infrastructure, not as a global one-size-fits-all dotfiles dump.

This project turns that idea into a sharable CLI with safe defaults:

- each workspace gets its own `.codex-home/`
- each profile gets its own local auth context
- auth, sessions, and caches stay local and are ignored by git

## Requirements

- `bash`
- `codex` on `PATH`
- optional: `fuelcheck` on `PATH` for richer status/report artifacts
- optional: `jq` for profile metadata inspection

## Install

Run the wrapper directly:

```bash
./bin/multiplus --help
```

Or add `bin/` to your `PATH`.

To install the CLI into `~/.local/bin`:

```bash
./install.sh
```

To install somewhere else:

```bash
./install.sh /usr/local/bin
```

## Quick Start

Create a workspace anywhere:

```bash
./bin/multiplus init ~/work/my-agent-project
```

Add profiles:

```bash
./bin/multiplus profile add personal --workspace ~/work/my-agent-project
./bin/multiplus profile add work --workspace ~/work/my-agent-project
```

Log in using the official Codex flow:

```bash
./bin/multiplus login personal --workspace ~/work/my-agent-project
./bin/multiplus login work --workspace ~/work/my-agent-project
```

Run Codex with a profile-local home:

```bash
./bin/multiplus run personal --workspace ~/work/my-agent-project -- --profile deep
```

Check all known profiles:

```bash
./bin/multiplus status --all --workspace ~/work/my-agent-project
```

Write a report artifact, using `fuelcheck` when available:

```bash
./bin/multiplus report status --all --workspace ~/work/my-agent-project
```

## Commands

```text
multiplus init <target>
multiplus profile add <name> [--workspace <dir>]
multiplus profile list [--workspace <dir>]
multiplus provider-root set <provider> <path> [--workspace <dir>]
multiplus provider-root list [--workspace <dir>]
multiplus use <name> [--workspace <dir>]
multiplus login <name> [--workspace <dir>] [-- codex-login-args...]
multiplus run [<name>] [--workspace <dir>] [-- codex-args...]
multiplus status [<name>] [--all] [--workspace <dir>] [--adapter <auto|codex|fuelcheck>]
multiplus report status [<name>] [--all] [--workspace <dir>] [--adapter <auto|codex|fuelcheck>] [--output-dir <dir>]
multiplus doctor [--workspace <dir>]
```

## Release Notes

Version `0.1.0` includes:

- workspace bootstrap and profile-local Codex homes
- official Codex login/run wrapping
- `fuelcheck` adapter support
- normalized multi-provider JSON and Markdown artifacts
- explicit provider auth-root overrides for Codex, Claude, and Gemini

## Bundled Skill

This repo also includes a standard skill at [`skills/multiplus-operator`](./skills/multiplus-operator) for AI agents that need to use `MultiPlus` autonomously. It is optimized for non-interactive setup, provider-root configuration, and artifact generation.

The skill also includes:

- anti-patterns to prevent vague or overly chatty agent behavior
- a validation checklist so agents verify artifacts and provider availability before claiming success

## Status Behavior

`multiplus status` is intentionally conservative.

- It always uses `codex login status` as the stable baseline for auth state.
- With `--adapter auto`, it prefers `fuelcheck --json` when `fuelcheck` is installed and falls back to Codex-only status when it is not.
- `report status` writes raw artifact files for each profile so richer provider-specific parsing can evolve without changing the profile model.
- This repo still does not parse private tokens or promise unofficial quota math on its own.
- `provider-root set` lets you keep Codex auth profile-local while pointing Claude or Gemini at a different real home root.

Provider-root behavior:

- Codex default root: the selected profile home
- Claude default root: the selected profile home unless overridden
- Gemini default root: the selected profile home unless overridden
- Environment overrides win over workspace config:
  - `MULTIPLUS_CODEX_HOME`
  - `MULTIPLUS_CLAUDE_HOME`
  - `MULTIPLUS_GEMINI_HOME`

Generated report files:

- `status-report.json`
- `status-report.md`
- `raw/<profile>-login-status.txt`
- `raw/<profile>-fuelcheck-codex.json`
- `raw/<profile>-fuelcheck-claude.json`
- `raw/<profile>-fuelcheck-gemini.json`

## Layout

After `init`, a workspace looks like this:

```text
my-project/
├── .codex/
│   ├── config.toml
│   └── scripts/
├── .codex-home/
│   ├── profiles/
│   └── state/
├── AGENTS.md
├── .gitignore
└── multiplus-local.sh
```

## Security Model

- This repo ships templates and wrapper logic only.
- Auth files remain inside the user's local `.codex-home/`.
- Generated auth, session, history, log, and cache files are ignored by git.
- Do not commit profile homes.
- Report artifacts may contain provider usage data; keep them local unless you intend to share them.

## License Notes

The code and templates in this repository are MIT licensed. Do not copy third-party Codex home dumps or vendored upstream skill bundles into this repo unless their licenses are preserved separately.
