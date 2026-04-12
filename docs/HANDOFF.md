# Handoff: MultiPlus OSS CLI
Date: 2026-04-12

## What Was Done
- Built the `MultiPlus` project as a publishable OSS CLI at [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus).
- Renamed the project throughout from `CodexHomeOss` to `MultiPlus`, including the executable surface in [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/bin/multiplus`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/bin/multiplus).
- Implemented workspace bootstrap, profile management, provider-root configuration, Codex login/run wrapping, `status`, `report status`, and `doctor` in [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/bin/multiplus`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/bin/multiplus).
- Added managed `fuelcheck` installation during `multiplus init`, with opt-out support via `--skip-fuelcheck`, in [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/bin/multiplus`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/bin/multiplus).
- Corrected the managed `fuelcheck` install path so `multiplus init` now installs the `fuelcheck-cli` package and exposes a stable wrapper at [`.../.codex-home/tools/fuelcheck/bin/fuelcheck`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/.tmp/live-managed-verify/workspace/.codex-home/tools/fuelcheck/bin/fuelcheck).
- Added normalized JSON and Markdown report generation plus raw provider captures in [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/bin/multiplus`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/bin/multiplus).
- Added explicit artifact versioning with `schema_version: "1"` for status reports and routed execution artifacts, and documented the contract in [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/docs/ARTIFACTS.md`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/docs/ARTIFACTS.md).
- Updated `status` and `report status` so the managed `fuelcheck-cli` JSON shape is parsed correctly instead of incorrectly falling back to Codex auth-only status.
- Fixed account preflight so `codex login status` is captured from stderr as well as stdout, matching real Codex CLI behavior in non-TTY/captured execution.
- Added an internal account-context resolver layer in [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/bin/multiplus`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/bin/multiplus) so later account-routed execution work can share one workspace/account/home resolution path.
- Added account-targeted Codex preflight checks to [`multiplus doctor --account <name>`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/bin/multiplus), including Codex binary detection, resolved home checks, and selected-account auth validation.
- Added the core routed execution command [`multiplus codex --account <name> ...`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/bin/multiplus), which reuses the preflight checks, exports the selected isolated Codex home, passes arguments through to `codex`, and preserves the Codex exit code.
- Added lightweight native Codex profile validation for routed execution, so `--account` selects the isolated home while `codex --profile ...` is checked against the selected account’s `.codex/config.toml` before launch.
- Validated MCP/server-mode routing through [`multiplus codex --account <name> mcp-server`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/bin/multiplus), with docs and smoke coverage showing one routed server process per account context.
- Added optional routed-execution artifacts through [`multiplus codex --account <name> --write-artifact ...`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/bin/multiplus), writing stable JSON metadata under `.codex-home/artifacts/execution/` or a caller-specified directory.
- Added a bundled standard agent skill in [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/skills/multiplus-operator/SKILL.md`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/skills/multiplus-operator/SKILL.md).
- Rewrote the product README to be more human-facing while staying technically accurate in [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/README.md`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/README.md).
- Added and maintained smoke coverage in [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/tests/smoke.sh`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/tests/smoke.sh).
- Added an opt-in live validation script in [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/tests/live-smoke.sh`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/tests/live-smoke.sh) for real local Codex/auth/report validation without making default CI flaky.
- Added schema reference files in [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/docs/schemas/status-report.v1.json`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/docs/schemas/status-report.v1.json) and [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/docs/schemas/execution-artifact.v1.json`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/docs/schemas/execution-artifact.v1.json).
- Added a GitHub Actions smoke workflow in [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/.github/workflows/smoke.yml`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/.github/workflows/smoke.yml) and a release checklist in [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/docs/RELEASE.md`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/docs/RELEASE.md).
- Updated the bundled operator skill so agents distinguish deterministic `tests/smoke.sh` validation from opt-in `tests/live-smoke.sh` validation and do not overclaim live coverage.
- Verified the CLI install path by running [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/install.sh`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/install.sh) into `/tmp/multiplus-handoff-bin` and executing `/tmp/multiplus-handoff-bin/multiplus --help`.
- Verified a real managed install into [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/.tmp/live-managed-verify/workspace/.codex-home/tools/fuelcheck/bin/fuelcheck`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/.tmp/live-managed-verify/workspace/.codex-home/tools/fuelcheck/bin/fuelcheck) and confirmed the managed wrapper runs successfully.
- Verified a live routed Codex execution in [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/.tmp/live-real/workspace`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/.tmp/live-real/workspace), including `doctor --account`, routed `login status`, and a real `exec --ephemeral` run returning `LIVE_MULTIPLUS_OK`.
- Verified the new opt-in live validation script in [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/.tmp/live-smoke/workspace`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/.tmp/live-smoke/workspace), including routed `doctor`, routed `login status`, routed `exec --ephemeral` returning `LIVE_MULTIPLUS_OK`, and schema-versioned execution/status artifacts.
- Ran a real CLI surface sweep in [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/.tmp/cli-sweep/workspace`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/.tmp/cli-sweep/workspace) covering `init`, profile commands, provider-root commands, `doctor`, `login`, `run`, routed `codex`, `status`, and `report status`.
- Added `multiplus worktree create --repo <repo> --branch <branch> --path <path> --account <name>` as a narrow account-aware Git worktree bootstrap flow in [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/bin/multiplus`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/bin/multiplus).
- Implemented non-destructive worktree bootstrap behavior that creates only MultiPlus-owned workspace files when missing, creates the requested account profile, and records local linkage metadata in `.codex-home/state/worktree-link.json` inside the created worktree.
- Added `multiplus worktree list --repo <repo>` and `multiplus worktree doctor --path <path>` in [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/bin/multiplus`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/bin/multiplus), including narrow linked-state diagnostics for metadata drift, missing linked accounts, and routed account preflight failures.
- Updated the product docs and bundled operator skill so worktree inspection is documented alongside worktree bootstrap in [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/README.md`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/README.md) and [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/skills/multiplus-operator/SKILL.md`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/skills/multiplus-operator/SKILL.md).
- Extended deterministic smoke coverage in [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/tests/smoke.sh`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/tests/smoke.sh) to verify worktree listing, worktree doctor success, and a broken-link failure mode.
- Verified the new worktree inspection flow manually on minimal artifacts under `/tmp/multiplus-manual-min`, including successful `worktree create`, `worktree list`, `worktree doctor`, and a narrow `linked account missing for worktree` failure after removing the linked profile.
- Added `multiplus usage map --all --workspace <dir>` and `multiplus usage map --repo <repo>` in [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/bin/multiplus`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/bin/multiplus) as a thin usage inventory layer for workspace/worktree/account linkage.
- Added usage inventory artifacts in [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/docs/ARTIFACTS.md`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/docs/ARTIFACTS.md) and [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/docs/schemas/usage-map.v1.json`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/docs/schemas/usage-map.v1.json), with stable `usage-map.json` and `usage-map.md` outputs.
- Updated [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/README.md`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/README.md) and [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/skills/multiplus-operator/SKILL.md`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/skills/multiplus-operator/SKILL.md) so usage inventory is documented as the lightest way to answer which workspace or worktree is tied to which account.
- Extended deterministic smoke coverage in [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/tests/smoke.sh`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/tests/smoke.sh) to verify both workspace-mode and repo-mode usage map output plus artifacts.
- Added `multiplus usage snapshot --all --workspace <dir>` in [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/bin/multiplus`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/bin/multiplus) as a thin dashboard layer over the shipped usage inventory surface.
- Updated [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/README.md`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/README.md), [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/docs/ARTIFACTS.md`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/docs/ARTIFACTS.md), and [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/skills/multiplus-operator/SKILL.md`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/skills/multiplus-operator/SKILL.md) so current five-hour and weekly usage visibility is documented as distinct from full normalized provider reports.
- Extended deterministic smoke coverage in [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/tests/smoke.sh`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/tests/smoke.sh) to verify `usage snapshot` terminal output and `usage-snapshot.json` / `usage-snapshot.md` artifacts.
- Verified the repo with `bash /mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/tests/smoke.sh`, `bash /mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/tests/live-smoke.sh`, and `bash /mnt/gitea-drive/apps/livekit-codex-dev-workspace/.codex/scripts/verify.sh`.

## What's Left
- Decide whether `0.1.0` is the release you want to publish or whether you want one more polish pass first.
- Optionally add screenshots, badges, or usage demos to [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/README.md`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/README.md).
- Optionally decide whether the workspace-local directory should remain `.codex-home/` forever or eventually get a branded alias.
- Continue with PR 5: historical usage snapshots on top of the shipped usage inventory and dashboard layers.

## Key Files
| File | Purpose |
|------|---------|
| [/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/bin/multiplus](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/bin/multiplus) | Main CLI implementation. All command behavior lives here. |
| [/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/README.md](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/README.md) | Product-facing overview, install instructions, quick start, and behavior notes. |
| [/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/docs/HANDOFF.md](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/docs/HANDOFF.md) | Current continuation state, shipped features, and remaining product decisions. |
| [/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/tests/smoke.sh](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/tests/smoke.sh) | End-to-end smoke coverage, including managed `fuelcheck` install and `--skip-fuelcheck`. |
| [/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/tests/live-smoke.sh](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/tests/live-smoke.sh) | Manual live validation against a real local Codex auth source and real routed execution/report flows. |
| [/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/docs/ARTIFACTS.md](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/docs/ARTIFACTS.md) | Published artifact contract for schema-versioned status and execution JSON. |
| [/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/docs/schemas/usage-map.v1.json](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/docs/schemas/usage-map.v1.json) | Schema reference for usage inventory JSON artifacts. |
| [/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/.github/workflows/smoke.yml](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/.github/workflows/smoke.yml) | GitHub Actions smoke workflow for repeatable basic regression coverage. |
| [/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/docs/RELEASE.md](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/docs/RELEASE.md) | Release checklist for version bumps and publish-time verification. |
| [/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/skills/multiplus-operator/SKILL.md](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/skills/multiplus-operator/SKILL.md) | Standard skill for autonomous agent use of the CLI. |
| [/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/install.sh](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/install.sh) | Simple installer that copies `multiplus` into a target bin directory. |
| [/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/templates/workspace/multiplus-local.sh](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/templates/workspace/multiplus-local.sh) | Generated launcher for workspace-local Codex runs. |
| [/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/templates/workspace/AGENTS.md](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/templates/workspace/AGENTS.md) | Generated workspace instructions for end users. |
| [/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/VERSION](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/VERSION) | Current version marker, set to `0.1.0`. |

## Gotchas
- The project branding is `MultiPlus`, but the managed Codex state directory is still `.codex-home/` by design. That is intentional and tied to actual Codex state layout, not an incomplete rename.
- `multiplus init` now tries to install a workspace-managed `fuelcheck` by default. That means `cargo` must be available unless the caller passes `--skip-fuelcheck`.
- The managed tools path now contains both `fuelcheck-cli` and a stable `fuelcheck` wrapper entrypoint. Other MultiPlus commands should continue using the wrapper path, not the package-specific binary name.
- `multiplus status --adapter auto` prefers the workspace-managed `fuelcheck` first, then a global `fuelcheck` on `PATH`, then falls back to Codex-only status.
- The managed `fuelcheck` adapter now supports the newer `fuelcheck-cli usage -p <provider> --format json --json-only` interface. If status/report start falling back again, check for a provider JSON shape change first.
- Real Codex auth checks can print `login status` to stderr rather than stdout in captured execution. If preflight starts showing `status unavailable`, check stderr-capture behavior before assuming auth state is bad.
- Report artifacts can legitimately show per-provider partial success. Do not collapse that into a single “status worked” message.
- The smoke test uses a fake local `cargo` installer to avoid real network installs. That is intentional and should not be “simplified” away unless you replace it with another deterministic strategy.
- `tests/live-smoke.sh` is intentionally opt-in. It copies a real local Codex auth file into a temporary workspace and may hit live network/provider paths.
- `multiplus worktree create` is intentionally narrow in this phase. It bootstraps a Git worktree plus MultiPlus state, but it does not own deletion, pruning, merge, or rebase workflows.
- `multiplus worktree list` intentionally annotates Git's current worktree set; repo roots or unrelated Git worktrees can appear as `unlinked`, which is expected rather than an error.
- `multiplus worktree doctor` validates against the shared Git common-dir root, not the checkout's own `.git` indirection. That distinction matters for real Git worktree layouts.
- `multiplus usage map` is inventory, not billing enforcement. It shows workspace/worktree/account boundaries and current status source, not exact provider-side cost attribution.
- `multiplus usage snapshot` is a current-state dashboard, not historical analytics. It intentionally reuses live status and `fuelcheck` data and may show `null` quota fields when the active adapter is not `fuelcheck`.
- `tests/live-smoke.sh` may require network-enabled execution for routed Codex calls. A sandboxed failure there is not automatically a product bug; check whether the run had the network access it needed.
- The operator skill now requires truthful reporting of validation mode. Do not describe `tests/smoke.sh` as live provider validation.

## Environment Setup
1. `cd /mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus`
2. `./bin/multiplus --help`
3. `bash ./install.sh /tmp/multiplus-handoff-bin`
4. `/tmp/multiplus-handoff-bin/multiplus --help`
5. `bash ./tests/smoke.sh`
6. `bash ./tests/live-smoke.sh`  *(optional, real local validation)*
7. `bash /mnt/gitea-drive/apps/livekit-codex-dev-workspace/.codex/scripts/verify.sh`

## Open Questions
- Should GitHub release automation be added now, or should the repo ship first and add CI after the initial publish?
- Should `MultiPlus` eventually manage more first-class provider tooling beyond `fuelcheck`, or stay focused on Codex-home orchestration plus reporting?
- Should the project keep the current `.codex-home/` workspace naming permanently, or introduce a branded alias later while preserving compatibility?

## Suggested Next Phase

### PR 5: Historical Usage Snapshots

Goal: retain usage snapshots over time so workspace/worktree usage changes can be compared locally.

Proposed scope:
- Save timestamped usage snapshots alongside the latest snapshot
- Add `multiplus usage history --workspace <dir>`
- Add `multiplus usage history --account <name>` when the history shape is stable enough
- Show:
  - latest snapshot
  - previous snapshot
  - simple delta where data exists

Acceptance:
- A user can compare recent snapshots without external storage
- History remains local and artifact-based
- Missing older data fails narrowly rather than producing fake deltas
- Smoke coverage verifies snapshot persistence and basic comparison behavior

Explicitly out of scope:
- dollar estimates
- alerts
- billing enforcement claims
