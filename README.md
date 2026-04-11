# MultiPlus

`MultiPlus` turns Codex account state into portable project infrastructure.

Instead of treating `~/.codex` as one global bucket for every project, account, and workflow, `MultiPlus` gives you a clean local home per workspace and per profile. That means you can keep `personal`, `work`, `oss`, or experiment-specific setups separate, reproducible, and easy to automate.

It is a thin wrapper around the official `codex` CLI. It does not invent its own auth system, scrape secrets directly, or replace the real Codex workflow. It organizes it.

## Why MultiPlus

If you use Codex heavily, the default global-home model gets messy fast:

- one project leaks into another
- multiple accounts are awkward to juggle
- local auth and session state become hard to reason about
- automation wants artifacts, not interactive guesswork

MultiPlus fixes that by making the workspace the unit of control.

- Each workspace gets its own local `.codex-home/`
- Each profile gets its own isolated Codex home
- Auth, sessions, logs, and caches stay local and uncommitted
- Status and report flows can produce machine-readable artifacts for agents and scripts

## What It Does

MultiPlus gives you:

- workspace bootstrap for new local Codex-enabled projects
- multiple named profiles such as `personal`, `work`, or `free`
- official Codex login and run flows under a profile-local home
- first-class `fuelcheck` reporting installed by default during workspace init
- explicit provider-root overrides for Codex, Claude, and Gemini
- normalized JSON and Markdown report artifacts for later automation

## Good Fit

MultiPlus is useful when you want to:

- keep multiple Codex identities separate
- spin up a clean Codex workspace in any folder
- give AI agents a predictable local setup to operate against
- generate repeatable status artifacts instead of relying on terminal output
- point Claude or Gemini checks at a different real home while keeping Codex local

## Requirements

- `bash`
- `codex` on `PATH`
- `cargo` on `PATH` if you want `init` to install managed `fuelcheck` automatically
- optional: `jq` for profile metadata inspection

## Install

Run it directly from the repo:

```bash
./bin/multiplus --help
```

Or install it into your local bin directory:

```bash
./install.sh
```

Install somewhere else:

```bash
./install.sh /usr/local/bin
```

## Quick Start

Create a workspace:

```bash
./bin/multiplus init ~/work/my-agent-project
```

By default, `init` installs a workspace-managed `fuelcheck` under `.codex-home/tools/fuelcheck/`.

If you need to skip that step:

```bash
./bin/multiplus init --skip-fuelcheck ~/work/my-agent-project
```

Add profiles:

```bash
./bin/multiplus profile add personal --workspace ~/work/my-agent-project
./bin/multiplus profile add work --workspace ~/work/my-agent-project
```

Log in with the official Codex flow:

```bash
./bin/multiplus login personal --workspace ~/work/my-agent-project
./bin/multiplus login work --workspace ~/work/my-agent-project
```

Run Codex under a profile-local home:

```bash
./bin/multiplus run personal --workspace ~/work/my-agent-project -- --profile deep
```

Route Codex through an explicit account/workspace context:

```bash
./bin/multiplus codex --account personal --workspace ~/work/my-agent-project -- exec "review this project"
./bin/multiplus codex --account work --profile deep --workspace ~/work/my-agent-project -- exec "analyze this repo"
./bin/multiplus codex --account work --profile deep --workspace ~/work/my-agent-project --artifact -- exec "analyze with artifact"
```

`--account` selects the auth/workspace context. `--profile` selects a native Codex profile inside that account context.
`--artifact` writes a JSON execution record under `.codex-home/artifacts/execution/`. Use `--artifact-dir <dir>` to override the output path.

Run account-routed MCP servers for external agent tools:

```bash
./bin/multiplus mcp-server --account personal --workspace ~/work/my-agent-project
./bin/multiplus mcp-server --account client-a --workspace ~/work/my-agent-project -- --transport stdio
./bin/multiplus mcp-server --account client-a --workspace ~/work/my-agent-project --artifact
```

Check all profiles:

```bash
./bin/multiplus status --all --workspace ~/work/my-agent-project
```

Write a report artifact:

```bash
./bin/multiplus report status --all --workspace ~/work/my-agent-project
```

## Core Commands

```text
multiplus init [--skip-fuelcheck] <target>
multiplus profile add <name> [--workspace <dir>]
multiplus profile list [--workspace <dir>]
multiplus provider-root set <provider> <path> [--workspace <dir>]
multiplus provider-root list [--workspace <dir>]
multiplus use <name> [--workspace <dir>]
multiplus login <name> [--workspace <dir>] [-- codex-login-args...]
multiplus run [<name>] [--workspace <dir>] [-- codex-args...]
multiplus codex --account <name> [--profile <codex-profile>] [--workspace <dir>] [--artifact|--artifact-dir <dir>] [-- codex-args...]
multiplus mcp-server --account <name> [--profile <codex-profile>] [--workspace <dir>] [--artifact|--artifact-dir <dir>] [-- codex-mcp-args...]
multiplus status [<name>] [--all] [--workspace <dir>] [--adapter <auto|codex|fuelcheck>]
multiplus report status [<name>] [--all] [--workspace <dir>] [--adapter <auto|codex|fuelcheck>] [--output-dir <dir>]
multiplus doctor [--workspace <dir>]
```

## How It Works

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

The important part is `.codex-home/`:

- `profiles/` holds isolated local homes
- `state/` stores selected profile and provider-root config
- `tools/` stores managed helper binaries such as `fuelcheck`
- report artifacts are written under `.codex-home/artifacts/status/`

## Reporting and Provider Roots

`multiplus status` is intentionally conservative.

- It always uses `codex login status` as the stable baseline for auth state
- With `--adapter auto`, it prefers the workspace-managed `fuelcheck` binary and then falls back to a global one on `PATH`
- If `fuelcheck` is unavailable, it falls back to Codex-only status
- `report status` preserves raw provider files so parsing can evolve safely
- MultiPlus does not parse private tokens directly or invent unofficial quota math on its own

Provider-root overrides let you keep Codex profile-local while checking other providers from a different real home.

Default roots:

- Codex: selected profile home
- Claude: selected profile home unless overridden
- Gemini: selected profile home unless overridden

Environment overrides:

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

## Bundled Agent Skill

This repo includes a standard skill at [`skills/multiplus-operator`](./skills/multiplus-operator) for agents that need to operate MultiPlus without getting stuck in unnecessary back-and-forth.

The skill includes:

- trigger boundaries
- anti-patterns
- validation rules
- a final validation checklist
- artifact-oriented reporting guidance

## Release Notes

Version `0.1.0` includes:

- workspace bootstrap and profile-local Codex homes
- official Codex login and run wrapping
- managed `fuelcheck` install during `init`, with `--skip-fuelcheck` opt-out
- normalized multi-provider JSON and Markdown artifacts
- explicit provider-root overrides for Codex, Claude, and Gemini

## Security Model

- This repo ships wrapper logic and templates only
- Auth files remain inside the user’s local `.codex-home/`
- Generated auth, session, history, log, and cache files are ignored by git
- Profile homes should not be committed
- Report artifacts may contain provider usage data and should be treated as local by default

## License

The code and templates in this repository are MIT licensed.
