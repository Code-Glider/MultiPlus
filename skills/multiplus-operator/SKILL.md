---
name: multiplus-operator
description: Use when an agent needs to bootstrap, inspect, repair, execute Codex/MCP in account-routed mode, or report on a MultiPlus workspace, including profile setup, provider-root overrides, preflight checks, and artifact generation.
keywords:
  - multiplus
  - multiplus-cli
  - workspace bootstrap
  - profile management
  - provider roots
  - quota report
  - status artifacts
  - account routing
  - codex execution
  - mcp server
  - preflight
  - fuelcheck
  - non-interactive setup
tags:
  - cli
  - automation
  - workspace
  - profiles
  - auth
  - quotas
  - reporting
  - codex
  - claude
  - gemini
when_to_use:
  - When the task is mainly about operating the `multiplus` CLI
  - When a workspace must be initialized, inspected, repaired, or reported on
  - When profiles must be created, selected, or inspected
  - When provider roots for Codex, Claude, or Gemini must be configured or verified
  - When a non-interactive status or quota artifact must be generated
when_not_to_use:
  - When the task is general AI advice or prompt design without `multiplus`
  - When the task is about provider theory rather than workspace operation
  - When the task does not involve `multiplus` state, profiles, provider roots, or artifacts
  - When the work is unrelated repo setup that should not touch MultiPlus
---

# MultiPlus Operator

Use this skill when the task is primarily about operating the `multiplus` CLI or reasoning about the state it creates.

## Scope

- Create a local workspace in any target folder
- Add, select, and inspect profiles
- Configure or inspect provider roots for Codex, Claude, and Gemini
- Install and use the workspace-managed `fuelcheck` dependency
- Run account-routed `codex` and `mcp-server` commands
- Run `preflight` checks for account-specific auth readiness
- Run `doctor`, `status`, and `report status`
- Produce machine-readable status and execution artifacts for later agents, scripts, or CI

## Defaults

Use safe defaults unless they would risk reading or mutating the wrong account.

- Workspace: the user-named path, otherwise a clearly named subdirectory in the current tree
- Default profile: `personal`
- `fuelcheck`: install during `init` by default; use `--skip-fuelcheck` only when the task explicitly calls for it
- Adapter: `fuelcheck` when the managed install is present, otherwise `auto`
- Report output dir: `<workspace>/.codex-home/artifacts/status`
- Execution artifact dir: `<workspace>/.codex-home/artifacts/execution` when `--artifact` is enabled
- Operating mode: inspect first, mutate only when needed

## Operating Stance

Operate like a high-agency systems wrapper, not a conversational assistant.

- Prefer execution over questions when a safe default exists
- Prefer additive inspection over mutation
- Prefer current CLI output over memory
- Prefer fresh artifacts over stale ones
- Prefer explicit partial-success reporting over polished summaries
- Prefer preserving raw evidence over paraphrasing it away

## Trigger Boundary

Use this skill when the task is mainly about `multiplus`.

Strong triggers:

- set up a MultiPlus workspace
- add or switch profiles
- run Codex for a specific account/workspace
- run account-routed MCP server mode
- verify account login readiness with `preflight`
- configure provider roots
- check provider availability
- generate usage or quota artifacts
- run the workflow non-interactively

Weak or non-triggers:

- general prompt engineering
- generic provider/account theory
- unrelated repo setup that does not use this CLI

If only part of the task involves `multiplus`, use this skill for that part only.

## Evidence Ladder

When sources conflict, trust them in this order:

1. Current CLI output from the resolved `multiplus` path
2. Freshly generated report artifacts
3. Current workspace state on disk
4. Raw provider JSON captures
5. Current config files such as provider-root state
6. Older artifacts
7. User expectations about what "should" be configured
8. Model memory

If a higher-ranked source contradicts a lower-ranked source, report the contradiction and use the higher-ranked source.

## CLI Discovery

Resolve the CLI path before using it. Prefer:

1. `multiplus` on `PATH`
2. `./bin/multiplus` when operating inside the repo
3. an explicit absolute path from the user

Bind the resolved path once:

```bash
MULTIPLUS_CLI="${MULTIPLUS_CLI:-./bin/multiplus}"
$MULTIPLUS_CLI --help
```

Always state which CLI path you used. Do not assume the current working directory is the repo root.

## Workflow

For bootstrap plus report:

```bash
$MULTIPLUS_CLI init /target/path
$MULTIPLUS_CLI profile add personal --workspace /target/path
$MULTIPLUS_CLI use personal --workspace /target/path
$MULTIPLUS_CLI doctor --workspace /target/path
$MULTIPLUS_CLI report status personal --adapter fuelcheck --workspace /target/path
```

If the task explicitly does not want managed `fuelcheck`, bootstrap with:

```bash
$MULTIPLUS_CLI init --skip-fuelcheck /target/path
```

For an existing workspace:

```bash
$MULTIPLUS_CLI profile list --workspace /target/path
$MULTIPLUS_CLI provider-root list --workspace /target/path
$MULTIPLUS_CLI doctor --workspace /target/path
```

For provider roots:

```bash
$MULTIPLUS_CLI provider-root set codex /path/to/codex-home --workspace /target/path
$MULTIPLUS_CLI provider-root set claude /real/user/home --workspace /target/path
$MULTIPLUS_CLI provider-root set gemini /real/user/home --workspace /target/path
```

For report-only tasks:

- inspect current profiles and roots first
- avoid creating extra profiles unless required
- refresh artifacts if the user asked for current status
- preserve raw provider files whenever available
- prefer the workspace-managed `fuelcheck` over any unrelated global install

For account-routed execution:

```bash
$MULTIPLUS_CLI preflight --account personal --workspace /target/path
$MULTIPLUS_CLI codex --account personal --workspace /target/path -- exec "review this repo"
$MULTIPLUS_CLI codex --account work --profile deep --workspace /target/path -- exec "analyze this project"
$MULTIPLUS_CLI mcp-server --account personal --workspace /target/path
```

For execution observability:

```bash
$MULTIPLUS_CLI codex --account personal --workspace /target/path --artifact -- exec "review this repo"
$MULTIPLUS_CLI mcp-server --account personal --workspace /target/path --artifact-dir /target/path/.codex-home/artifacts/execution
```

Semantics to preserve:

- `--account` chooses auth/workspace context.
- `--profile` chooses native Codex profile inside that account context.
- Pass-through Codex/MCP args should remain untouched.
- Codex exit code should be returned unchanged.

## Recovery Loop

When a step fails:

1. classify the failure
2. identify the narrowest likely cause
3. try one fix or one fallback
4. rerun the relevant command
5. stop after two meaningful attempts unless new evidence appears

Meaningful attempts include correcting the CLI path, adding a missing profile, setting the right provider root, or switching to a documented fallback.

## Anti-Patterns

- Do not ask for a profile name if `personal` is sufficient
- Do not hardcode a repo-relative CLI path without discovery
- Do not assume the repo root and workspace root are the same
- Do not parse provider auth files directly when the CLI or `fuelcheck` can do it
- Do not manually export `CODEX_HOME` when `multiplus codex`/`multiplus mcp-server` can route context
- Do not treat `fuelcheck` as optional during bootstrap unless the user explicitly chose `--skip-fuelcheck`
- Do not claim a provider is configured without current evidence
- Do not treat missing provider data as success; mark it `unavailable`
- Do not confuse `auth available` with `quota available`
- Do not overwrite provider roots or profiles during read-only tasks
- Do not report stale artifacts as current status
- Do not hide fallback behavior or partial success
- Do not leak credential contents in logs, summaries, or artifacts
- Do not rebuild a workspace when targeted repair is enough
- Do not silently mix provider results from different roots without saying which root each provider used
- Do not prefer a random global `fuelcheck` when the workspace-managed one exists

## Failure Modes

- `cli-not-found`
- `workspace-not-initialized`
- `profile-missing`
- `account-missing`
- `provider-root-ambiguous`
- `provider-root-mispointed`
- `adapter-missing`
- `adapter-partial`
- `managed-dependency-skipped`
- `artifact-stale`
- `artifact-missing`
- `schema-drift`
- `preflight-failed`
- `execution-artifact-missing`

Report the failure class and the narrowest truthful explanation.

## Completion States

- `completed`
- `completed-with-partial-provider-coverage`
- `completed-with-fallback`
- `blocked-by-missing-auth`
- `blocked-by-missing-tool`
- `blocked-by-ambiguous-root`

Do not say "done" when one of these is more accurate.

## Validation

Before finishing, confirm:

- the CLI path was resolved intentionally
- the workspace exists and contains `.codex-home/`
- the intended profile exists and is selected or explicitly named
- the managed `fuelcheck` binary exists unless the task intentionally used `--skip-fuelcheck`
- `preflight` was run for account-routed execution tasks
- `provider-root list` was checked if overrides matter
- `doctor` completed without blocking errors
- `status` or `report status` completed
- `status-report.json` and `status-report.md` exist for report tasks
- the artifact timestamp is current enough for the request
- unavailable providers are called out explicitly
- summary values match the current artifact, not memory

Minimum report validation:

```bash
$MULTIPLUS_CLI doctor --workspace /target/path
$MULTIPLUS_CLI provider-root list --workspace /target/path
$MULTIPLUS_CLI report status --adapter fuelcheck --workspace /target/path
test -x /target/path/.codex-home/tools/fuelcheck/bin/fuelcheck
test -f /target/path/.codex-home/artifacts/status/status-report.json
test -f /target/path/.codex-home/artifacts/status/status-report.md
```

If the task intentionally used `--skip-fuelcheck`, replace the binary check with an explicit note that the managed dependency was skipped by request and that fallback behavior may occur.

If provider-specific roots are involved, validate the outcome, not only the setting:

- the normalized provider section exists
- the provider-specific raw artifact exists
- the provider is explicitly `ok` or `unavailable`
- humanized reset fields, if present, correspond to actual source fields

## Output

Include:

- CLI path used
- workspace path
- active profile
- provider roots if relevant
- artifact paths
- artifact generation time when reporting usage
- whether data came from workspace-managed `fuelcheck`, global `fuelcheck`, or Codex fallback
- per-provider availability
- any partial-success or schema-drift caveats

For larger tasks, report in this order: execution context, state changes, provider observations, artifacts, caveats.

## Final Validation Checklist

- CLI path resolved and stated
- workspace path confirmed
- intended profile confirmed
- provider roots listed if relevant
- managed `fuelcheck` present or intentionally skipped
- `doctor` run
- `status` or `report status` run
- `status-report.json` exists for report tasks
- `status-report.md` exists for report tasks
- execution artifact exists for tasks that requested `--artifact`/`--artifact-dir`
- artifact timestamp checked when freshness matters
- per-provider availability stated
- fallback or partial-success boundaries stated
- artifact paths included in the handoff
