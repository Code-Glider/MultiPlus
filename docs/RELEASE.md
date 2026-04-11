# Release Checklist

Use this checklist before publishing a new `MultiPlus` version.

## Pre-Release

- Confirm `README.md` matches the current CLI surface.
- Confirm [`docs/ARTIFACTS.md`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/docs/ARTIFACTS.md) matches the current artifact output.
- Confirm [`VERSION`](/mnt/gitea-drive/apps/livekit-codex-dev-workspace/MultiPlus/VERSION) is intentionally set.
- Confirm managed `fuelcheck` install behavior is still current.

## Verification

Run:

```bash
bash ./tests/smoke.sh
bash /mnt/gitea-drive/apps/livekit-codex-dev-workspace/.codex/scripts/verify.sh
```

If you are changing routing, auth handling, or artifacts, also run at least one live local validation:

- `multiplus doctor --account <name>`
- `multiplus codex --account <name> login status`
- `multiplus report status --all --workspace <dir>`
- or `bash ./tests/live-smoke.sh`

## Release Steps

1. Update `VERSION`.
2. Commit the release changes.
3. Tag the release.
4. Push commits and tags.
5. Publish GitHub release notes if desired.

## Post-Release

- Verify install instructions still work from a clean shell.
- Verify the GitHub Actions smoke workflow is green.
- Verify no docs still reference removed command names or stale adapter behavior.
