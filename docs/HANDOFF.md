# Handoff: MultiPlus OSS CLI
Date: 2026-04-11

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
- Verified the CLI install path by running [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/install.sh`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/install.sh) into `/tmp/multiplus-handoff-bin` and executing `/tmp/multiplus-handoff-bin/multiplus --help`.
- Verified a real managed install into [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/.tmp/live-managed-verify/workspace/.codex-home/tools/fuelcheck/bin/fuelcheck`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/.tmp/live-managed-verify/workspace/.codex-home/tools/fuelcheck/bin/fuelcheck) and confirmed the managed wrapper runs successfully.
- Verified a live routed Codex execution in [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/.tmp/live-real/workspace`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/.tmp/live-real/workspace), including `doctor --account`, routed `login status`, and a real `exec --ephemeral` run returning `LIVE_MULTIPLUS_OK`.
- Ran a real CLI surface sweep in [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/.tmp/cli-sweep/workspace`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/.tmp/cli-sweep/workspace) covering `init`, profile commands, provider-root commands, `doctor`, `login`, `run`, routed `codex`, `status`, and `report status`.
- Verified the repo with `bash /mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/tests/smoke.sh` and `bash /mnt/gitea-drive/apps/livekit-codex-dev-workspace/.codex/scripts/verify.sh`.

## What's Left
- Create or clean up the GitHub remote history if you want the first push to be conflict-free.
- Decide whether `0.1.0` is the release you want to publish or whether you want one more polish pass first.
- Add CI and release automation if you want repeatable checks on GitHub.
- Optionally add screenshots, badges, or usage demos to [`/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/README.md`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/README.md).
- Optionally decide whether the workspace-local directory should remain `.codex-home/` forever or eventually get a branded alias.

## Key Files
| File | Purpose |
|------|---------|
| [/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/bin/multiplus](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/bin/multiplus) | Main CLI implementation. All command behavior lives here. |
| [/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/README.md](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/README.md) | Product-facing overview, install instructions, quick start, and behavior notes. |
| [/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/tests/smoke.sh](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/tests/smoke.sh) | End-to-end smoke coverage, including managed `fuelcheck` install and `--skip-fuelcheck`. |
| [/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/tests/live-smoke.sh](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/tests/live-smoke.sh) | Manual live validation against a real local Codex auth source and real routed execution/report flows. |
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
- GitHub push was blocked earlier by remote-history mismatch. If the remote repo already has starter commits, decide whether to rebase onto them or replace them intentionally.

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
