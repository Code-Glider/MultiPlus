---
name: multiplus-operator
description: Use when an agent needs to bootstrap, inspect, repair, or report on a MultiPlus workspace, including profile setup, account-aware worktree bootstrap, provider-root overrides, and non-interactive status/report artifact generation.
keywords:
  - multiplus
  - multiplus-cli
  - workspace bootstrap
  - git worktree bootstrap
  - profile management
  - provider roots
  - quota report
  - status artifacts
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
  - When a Git worktree must be bootstrapped into an account-aware MultiPlus workspace
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
- Create a Git worktree and bootstrap it into a MultiPlus workspace for one account
- Inspect linked worktrees for repo/account/path drift
- Add, select, and inspect profiles
- Route Codex through an explicit account while optionally passing a native Codex `--profile`
- Launch long-running Codex modes such as `mcp-server` inside an explicit account context
- Configure or inspect provider roots for Codex, Claude, and Gemini
- Install and use the workspace-managed `fuelcheck` dependency
- Run `doctor`, `status`, and `report status`
- Run `usage map` to inspect workspace/worktree/account boundaries
- Run `usage snapshot` when the task needs current usage values on top of those boundaries
- Produce machine-readable artifacts for later agents, scripts, or CI
- Produce execution artifacts for routed Codex runs when automation needs run metadata
- Choose the right validation mode: deterministic smoke or opt-in live validation

## Defaults

Use safe defaults unless they would risk reading or mutating the wrong account.

- Workspace: the user-named path, otherwise a clearly named subdirectory in the current tree
- Default profile: `personal`
- Account/profile semantics: `--account` chooses the MultiPlus-isolated Codex home; native Codex `--profile` chooses a config profile inside that home
- `fuelcheck`: install during `init` by default; use `--skip-fuelcheck` only when the task explicitly calls for it
- Managed install detail: MultiPlus exposes `.codex-home/tools/fuelcheck/bin/fuelcheck` as the stable path, even though the installed package may currently be `fuelcheck-cli` under the hood
- Adapter: `fuelcheck` when the managed install is present, otherwise `auto`
- Report output dir: `<workspace>/.codex-home/artifacts/status`
- Execution artifact dir: `<workspace>/.codex-home/artifacts/execution`
- Artifact schema version: `"1"` for current JSON contracts
- Deterministic validation: `bash ./tests/smoke.sh`
- Live validation: `bash ./tests/live-smoke.sh`
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

For account-aware worktree bootstrap:

```bash
$MULTIPLUS_CLI worktree create \
  --repo /repo/root \
  --branch feature/task \
  --path /repo-feature-task \
  --account personal
```

For linked worktree inspection:

```bash
$MULTIPLUS_CLI worktree list --repo /repo/root
$MULTIPLUS_CLI worktree doctor --path /repo-feature-task
```

The current worktree surface covers create, list, and doctor only. It does not imply delete, prune, merge, or rebase ownership.

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

For account-routed Codex execution with a native Codex profile:

```bash
$MULTIPLUS_CLI codex --account work --workspace /target/path exec --profile deep "review this repo"
```

For account-routed MCP/server mode:

```bash
$MULTIPLUS_CLI codex --account personal --workspace /target/path mcp-server
```

For an execution artifact:

```bash
$MULTIPLUS_CLI codex --account work --workspace /target/path --write-artifact exec --profile deep "review this repo"
```

For provider roots:

```bash
$MULTIPLUS_CLI provider-root set codex /path/to/codex-home --workspace /target/path
$MULTIPLUS_CLI provider-root set claude /real/user/home --workspace /target/path
$MULTIPLUS_CLI provider-root set gemini /real/user/home --workspace /target/path
```

For report-only tasks:

- inspect current profiles and roots first
- prefer `usage map` before heavier reporting when the task is about account/workspace linkage rather than quota values
- prefer `usage snapshot` when the task needs a current dashboard view rather than a full normalized provider report
- avoid creating extra profiles unless required
- refresh artifacts if the user asked for current status
- preserve raw provider files whenever available
- prefer the workspace-managed `fuelcheck` over any unrelated global install
- if quota parsing fails unexpectedly, verify whether the managed `fuelcheck` output shape changed before assuming auth is broken

For validation tasks:

- use `bash ./tests/smoke.sh` for deterministic regression coverage
- use `bash ./tests/live-smoke.sh` only when real local auth and network-backed validation are appropriate
- state explicitly which validation mode was used
- do not describe the deterministic smoke harness as a live provider validation

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
- Do not describe `multiplus worktree create` as a general Git lifecycle manager
- Do not describe `multiplus worktree list` or `worktree doctor` as ownership of broader Git lifecycle actions
- Do not overwrite existing repo-root files just because a worktree needs MultiPlus bootstrap state
- Do not parse provider auth files directly when the CLI or `fuelcheck` can do it
- Do not treat `fuelcheck` as optional during bootstrap unless the user explicitly chose `--skip-fuelcheck`
- Do not claim a provider is configured without current evidence
- Do not treat missing provider data as success; mark it `unavailable`
- Do not confuse `auth available` with `quota available`
- Do not confuse MultiPlus account selection with native Codex profile selection
- Do not claim a requested native Codex profile exists unless it is defined in the selected account config
- Do not imply one long-running server covers multiple accounts; start one routed server per account context
- Do not claim an execution artifact exists unless the JSON file was actually written
- Do not overwrite provider roots or profiles during read-only tasks
- Do not report stale artifacts as current status
- Do not hide fallback behavior or partial success
- Do not leak credential contents in logs, summaries, or artifacts
- Do not rebuild a workspace when targeted repair is enough
- Do not silently mix provider results from different roots without saying which root each provider used
- Do not prefer a random global `fuelcheck` when the workspace-managed one exists
- Do not patch parsing based on assumptions about one historical `fuelcheck` JSON shape; inspect the current raw provider artifact first
- Do not claim live validation if only `tests/smoke.sh` was run
- Do not run `tests/live-smoke.sh` casually in contexts where copying real local auth or using the network would be inappropriate

## Failure Modes

- `cli-not-found`
- `workspace-not-initialized`
- `profile-missing`
- `provider-root-ambiguous`
- `provider-root-mispointed`
- `adapter-missing`
- `adapter-partial`
- `managed-dependency-skipped`
- `artifact-stale`
- `artifact-missing`
- `schema-drift`
- `live-validation-skipped`
- `live-validation-blocked`

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
- for worktree bootstrap, the worktree path exists and is attached to the requested Git repo
- for worktree inspection, linked account, repo, branch, and path all match current Git state
- the intended profile exists and is selected or explicitly named
- if a native Codex `--profile` was requested, it exists in the selected account config
- if a long-running mode such as `mcp-server` was launched, the selected account context is stated explicitly
- if `--write-artifact` was used, the execution artifact exists and matches the invoked account, profile, and exit code
- the managed `fuelcheck` binary exists unless the task intentionally used `--skip-fuelcheck`
- `provider-root list` was checked if overrides matter
- `doctor` completed without blocking errors
- `status` or `report status` completed
- for worktree bootstrap, `.codex-home/state/worktree-link.json` exists and names the expected repo, branch, and account
- `status-report.json` and `status-report.md` exist for report tasks
- `usage-map.json` and `usage-map.md` exist for usage-map artifact tasks
- the artifact timestamp is current enough for the request
- unavailable providers are called out explicitly
- summary values match the current artifact, not memory
- if the task called for real validation, `tests/live-smoke.sh` was run or explicitly reported as skipped/blocked

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

Live validation, when appropriate:

```bash
bash ./tests/live-smoke.sh
```

Treat `tests/live-smoke.sh` as manual and environment-dependent:

- it copies a real local Codex auth file into a temp workspace
- it may require network access for routed Codex execution
- it should be reported separately from deterministic smoke results

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
- repo root, branch, and worktree path for worktree bootstrap tasks
- provider roots if relevant
- artifact paths
- execution artifact paths when routed execution used `--write-artifact`
- artifact generation time when reporting usage
- whether data came from workspace-managed `fuelcheck`, global `fuelcheck`, or Codex fallback
- whether validation was deterministic smoke, live smoke, or both
- per-provider availability
- any partial-success or schema-drift caveats

For larger tasks, report in this order: execution context, state changes, provider observations, artifacts, caveats.

## Final Validation Checklist

- CLI path resolved and stated
- workspace path confirmed
- intended profile confirmed
- worktree metadata file confirmed for worktree bootstrap tasks
- provider roots listed if relevant
- managed `fuelcheck` present or intentionally skipped
- `doctor` run
- `status` or `report status` run
- `status-report.json` exists for report tasks
- `status-report.md` exists for report tasks
- artifact timestamp checked when freshness matters
- validation mode stated truthfully
- per-provider availability stated
- fallback or partial-success boundaries stated
- artifact paths included in the handoff
