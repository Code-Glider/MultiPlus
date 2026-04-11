# Artifact Contracts

`MultiPlus` writes two machine-readable artifact families:

- status reports under `.codex-home/artifacts/status/`
- routed execution artifacts under `.codex-home/artifacts/execution/`

These files are intended for local automation, agent handoff, and CI-style inspection. They are a compatibility surface and should be treated as such.

## Versioning

Every JSON artifact now includes:

```json
{
  "schema_version": "1"
}
```

Compatibility rules for `schema_version: "1"`:

- existing documented fields are stable
- documented nullable fields may be `null`
- provider sections may show partial success
- consumers must ignore unknown future fields
- raw provider files remain the source of truth if normalization changes upstream

If a breaking shape change is needed later, bump `schema_version` instead of silently repurposing existing fields.

## Status Report

Default path:

```text
<workspace>/.codex-home/artifacts/status/status-report.json
<workspace>/.codex-home/artifacts/status/status-report.md
```

Raw provider captures:

```text
<workspace>/.codex-home/artifacts/status/raw/
```

Schema reference:

- [`schemas/status-report.v1.json`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/docs/schemas/status-report.v1.json)

Behavior notes:

- `adapter_requested` is what the caller asked for
- `adapter_used` is what MultiPlus actually used
- `status_source` is per-profile and may differ from the adapter request
- `fuelcheck_status` is specific to Codex quota collection in the normalized summary
- provider sections may be `ok` for one provider and `unavailable` for another in the same report
- `raw_files` should be preserved for debugging parser drift or provider-side changes

## Execution Artifact

Default path:

```text
<workspace>/.codex-home/artifacts/execution/
```

Files:

- `execution-<timestamp>-<account>.json`
- `latest-execution.json`

Schema reference:

- [`schemas/execution-artifact.v1.json`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/docs/schemas/execution-artifact.v1.json)

Behavior notes:

- artifacts are only written when `multiplus codex` is called with `--write-artifact`
- `command` is the routed Codex command array, ready for machine inspection
- `preflight_ok` reflects MultiPlus preflight before execution
- `exit_code` is the real Codex exit code
- `codex_profile` may be `null`

## Consumer Guidance

- Prefer `schema_version` over ad hoc field detection.
- Treat `null` as a valid outcome, not necessarily a failure.
- Treat raw provider captures as canonical when diagnosing discrepancies.
- Do not assume quota data exists just because auth exists.
- Do not assume all providers are configured in every workspace.

## Validation

For local verification after changes:

```bash
bash ./tests/smoke.sh
bash /mnt/gitea-drive/apps/livekit-codex-dev-workspace/.codex/scripts/verify.sh
```
