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

## Base Capabilities

MultiPlus gives you a local workspace foundation for Codex-oriented projects:

- workspace bootstrap for new local Codex-enabled projects
- multiple named profiles such as `personal`, `work`, or `free`
- isolated `.codex-home/` state per workspace and per profile
- official Codex login and run flows under a profile-local home
- first-class `fuelcheck` reporting installed by default during workspace init
- explicit provider-root overrides for Codex, Claude, and Gemini
- normalized JSON and Markdown report artifacts for later automation
- usage inventory output that shows which workspace or worktree is tied to which account

## Exec Capabilities

MultiPlus can also route Codex execution through a selected account context:

- account-routed `codex` execution with `--account <name>`
- passthrough of native Codex `--profile ...` selection inside that account
- account-targeted `doctor` preflight before routed execution
- optional execution-artifact writing for automation and audit trails
- support for long-running routed modes such as `mcp-server`
- usage snapshot dashboards for current five-hour and weekly usage visibility
- local usage history so recent snapshots can be compared without external storage
- repo rollups that show which accounts and worktrees are currently carrying usage

## Worktree Capabilities

MultiPlus includes a narrow account-aware Git worktree layer:

- bootstrap a new Git worktree into a MultiPlus workspace
- record local linkage metadata in `.codex-home/state/worktree-link.json`
- inspect known linked worktrees for a repo
- run narrow diagnostics for one linked worktree
- keep the scope limited to task-isolated worktrees rather than general Git lifecycle management

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

## Verification

Deterministic local regression check:

```bash
bash ./tests/smoke.sh
```

Opt-in live validation against a real local Codex account:

```bash
bash ./tests/live-smoke.sh
```

Optional environment overrides for the live script:

- `MULTIPLUS_LIVE_ACCOUNT`
- `MULTIPLUS_LIVE_SOURCE_AUTH_HOME`
- `MULTIPLUS_LIVE_INIT_MODE`
- `MULTIPLUS_LIVE_PROMPT`

## Quick Start

### Base Setup

Create a workspace:

```bash
./bin/multiplus init ~/work/my-agent-project
```

By default, `init` installs a workspace-managed `fuelcheck` under `.codex-home/tools/fuelcheck/`.

The managed install exposes:

- `.codex-home/tools/fuelcheck/bin/fuelcheck`
- `.codex-home/tools/fuelcheck/bin/fuelcheck-cli`

`MultiPlus` uses the stable `fuelcheck` wrapper path, while the managed install currently comes from the `fuelcheck-cli` package underneath.

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

### Exec Flow

Run Codex under a profile-local home:

```bash
./bin/multiplus run personal --workspace ~/work/my-agent-project -- --profile deep
```

Route an external Codex invocation through an explicit account:

```bash
./bin/multiplus codex --account work --workspace ~/work/my-agent-project exec "review this repo"
```

Write a machine-readable execution artifact for a routed run:

```bash
./bin/multiplus codex --account work --workspace ~/work/my-agent-project --write-artifact exec --profile deep "review this repo"
```

Start a Codex MCP server in a selected account context:

```bash
./bin/multiplus codex --account personal --workspace ~/work/my-agent-project mcp-server
./bin/multiplus codex --account client-a --workspace ~/work/client-a mcp-server
```

### Worktree Flow

Create a Git worktree that is bootstrapped for a dedicated MultiPlus account:

```bash
./bin/multiplus worktree create \
  --repo ~/src/my-repo \
  --branch feature/client-a \
  --path ~/src/my-repo-client-a \
  --account client-a
```

Inspect linked worktrees for a repo:

```bash
./bin/multiplus worktree list --repo ~/src/my-repo
```

Run a narrow diagnostic for one linked worktree:

```bash
./bin/multiplus worktree doctor --path ~/src/my-repo-client-a
```

Combine account routing with a native Codex profile:

```bash
./bin/multiplus codex --account work --workspace ~/work/my-agent-project exec --profile deep "analyze this codebase"
```

Check all profiles:

```bash
./bin/multiplus status --all --workspace ~/work/my-agent-project
```

Run a targeted preflight for one account:

```bash
./bin/multiplus doctor --workspace ~/work/my-agent-project --account work
```

Write a report artifact:

```bash
./bin/multiplus report status --all --workspace ~/work/my-agent-project
```

Map workspace/account usage boundaries:

```bash
./bin/multiplus usage map --all --workspace ~/work/my-agent-project
./bin/multiplus usage map --repo ~/src/my-repo
```

Show current usage against those boundaries:

```bash
./bin/multiplus usage snapshot --all --workspace ~/work/my-agent-project
```

Compare recent saved snapshots:

```bash
./bin/multiplus usage history --workspace ~/work/my-agent-project
```

Roll up one repo across linked worktrees:

```bash
./bin/multiplus usage rollup --repo ~/src/my-repo
```

## Base Commands

```text
multiplus init [--skip-fuelcheck] <target>
multiplus profile add <name> [--workspace <dir>]
multiplus profile list [--workspace <dir>]
multiplus provider-root set <provider> <path> [--workspace <dir>]
multiplus provider-root list [--workspace <dir>]
multiplus use <name> [--workspace <dir>]
multiplus login <name> [--workspace <dir>] [-- codex-login-args...]
multiplus status [<name>] [--all] [--workspace <dir>] [--adapter <auto|codex|fuelcheck>]
multiplus report status [<name>] [--all] [--workspace <dir>] [--adapter <auto|codex|fuelcheck>] [--output-dir <dir>]
multiplus usage map --all [--workspace <dir>] [--output-dir <dir>]
multiplus usage map --repo <repo> [--output-dir <dir>]
multiplus usage snapshot --all --workspace <dir> [--output-dir <dir>]
multiplus usage history --workspace <dir> [--output-dir <dir>]
multiplus usage rollup --repo <repo> [--output-dir <dir>]
multiplus doctor [--workspace <dir>] [--account <name>]
```

## Exec Commands

```text
multiplus run [<name>] [--workspace <dir>] [-- codex-args...]
multiplus codex --account <name> [--workspace <dir>] [--write-artifact] [--artifact-dir <dir>] [-- codex-args...]
multiplus doctor [--workspace <dir>] [--account <name>]
```

## Worktree Commands

```text
multiplus worktree create --repo <repo> --branch <branch> --path <path> --account <name> [--skip-fuelcheck]
multiplus worktree list --repo <repo>
multiplus worktree doctor --path <path>
```

## Account vs Profile

- `--account` selects the isolated MultiPlus Codex home to use.
- `codex --profile ...` selects a native Codex config profile inside that selected home.
- MultiPlus does not invent a second profile system for Codex execution. It routes the account context and passes native Codex profile flags through.
- If a requested Codex profile is not defined in the selected account’s `.codex/config.toml`, MultiPlus fails early with a clear error.
- Long-running modes such as `mcp-server` run inside the selected account context. Run one process per account if you need separate Codex-backed servers.
- `--write-artifact` writes execution metadata under `.codex-home/artifacts/execution/` by default, or to `--artifact-dir` if you specify one.

## How It Works

After `init`, a workspace looks like this:

```text
my-project/
├── .codex/
│   ├── config.toml
│   └── scripts/
├── .codex-home/
│   ├── profiles/
│   ├── state/
│   └── tools/
├── AGENTS.md
├── .gitignore
└── multiplus-local.sh
```

The important part is `.codex-home/`:

- `profiles/` holds isolated local homes
- `state/` stores selected profile and provider-root config
- `tools/` stores managed helper binaries such as `fuelcheck`
- report artifacts are written under `.codex-home/artifacts/status/`

Worktree-created workspaces also record local linkage metadata at:

- `.codex-home/state/worktree-link.json`

That file records the source repo, worktree path, branch, and linked MultiPlus account for the bootstrap command. It is local bootstrap metadata, not a general Git orchestration layer.

`multiplus worktree list` reads the Git worktree set for a repo and annotates known MultiPlus-linked entries with branch, account, and resolved Codex home.

`multiplus worktree doctor` validates one linked worktree narrowly:

- the path still exists
- the Git worktree is still attached
- the recorded repo, branch, and path still match
- the linked MultiPlus account still exists
- routed `doctor --account ...` still passes for that workspace

## Reporting and Provider Roots

`multiplus status` is intentionally conservative.

- It always uses `codex login status` as the stable baseline for auth state
- With `--adapter auto`, it prefers the workspace-managed `fuelcheck` binary and then falls back to a global one on `PATH`
- If `fuelcheck` is unavailable, it falls back to Codex-only status
- `report status` preserves raw provider files so parsing can evolve safely
- Managed installs use the newer `fuelcheck-cli` interface under the hood, and MultiPlus adapts that output into the same normalized report shape
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
- `latest-status-report.json`
- `latest-status-report.md`
- `usage-map.json`
- `usage-map.md`
- `latest-usage-map.json`
- `latest-usage-map.md`
- `latest-usage-snapshot.json`
- `latest-usage-snapshot.md`
- `usage-rollup.json`
- `usage-rollup.md`
- `latest-usage-rollup.json`
- `latest-usage-rollup.md`
- `raw/<profile>-login-status.txt`
- `raw/<profile>-fuelcheck-codex.json`
- `raw/<profile>-fuelcheck-claude.json`
- `raw/<profile>-fuelcheck-gemini.json`

Generated execution artifact files:

- `execution-<timestamp>-<account>.json`
- `latest-execution.json`

Artifact contract docs:

- [`docs/ARTIFACTS.md`](./docs/ARTIFACTS.md)
- [`docs/schemas/status-report.v1.json`](./docs/schemas/status-report.v1.json)
- [`docs/schemas/execution-artifact.v1.json`](./docs/schemas/execution-artifact.v1.json)
- [`docs/schemas/usage-map.v1.json`](./docs/schemas/usage-map.v1.json)

Live validation script:

- [`tests/live-smoke.sh`](./tests/live-smoke.sh)

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

Subsequent work in this tree also adds:

- account-routed `multiplus codex --account ...` execution
- account-targeted `doctor --account ...` preflight
- routed MCP/server support
- routed execution artifacts
- managed `fuelcheck-cli` installation behind the stable `fuelcheck` wrapper path
- status/report compatibility with the newer managed `fuelcheck-cli` JSON interface
- schema-versioned JSON artifacts for status and routed execution
- usage inventory reporting for workspace and repo/worktree boundaries
- usage snapshot dashboards backed by current fuelcheck and auth state
- local usage history built from saved snapshot artifacts
- repo/worktree rollups that surface linked accounts and broken linkage states together
- consistent `latest-*` pointers across report, usage-map, usage-snapshot, usage-rollup, and execution artifacts for simpler automation
- a GitHub Actions smoke workflow and a release checklist
- an opt-in `tests/live-smoke.sh` for real local validation against Codex auth

## Security Model

- This repo ships wrapper logic and templates only
- Auth files remain inside the user’s local `.codex-home/`
- Generated auth, session, history, log, and cache files are ignored by git
- Profile homes should not be committed
- Report artifacts may contain provider usage data and should be treated as local by default

## License

The code and templates in this repository are MIT licensed.
