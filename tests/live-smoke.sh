#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLI="$ROOT/bin/multiplus"
TMP_DIR="$ROOT/.tmp/live-smoke"
WORKSPACE="$TMP_DIR/workspace"
ARTIFACT_DIR="$TMP_DIR/execution-artifacts"
REPORT_DIR="$TMP_DIR/status-artifacts"

ACCOUNT="${MULTIPLUS_LIVE_ACCOUNT:-personal}"
SOURCE_AUTH_HOME="${MULTIPLUS_LIVE_SOURCE_AUTH_HOME:-${HOME:-}}"
INIT_MODE="${MULTIPLUS_LIVE_INIT_MODE:-skip-fuelcheck}"
PROMPT_TEXT="${MULTIPLUS_LIVE_PROMPT:-Reply with exactly LIVE_MULTIPLUS_OK}"

echo "[live-smoke] root: $ROOT"
echo "[live-smoke] workspace: $WORKSPACE"
echo "[live-smoke] account: $ACCOUNT"
echo "[live-smoke] auth source home: $SOURCE_AUTH_HOME"
echo "[live-smoke] init mode: $INIT_MODE"

command -v codex >/dev/null 2>&1 || {
  echo "[live-smoke] codex is required on PATH" >&2
  exit 1
}

bash -n "$CLI"

rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

case "$INIT_MODE" in
  managed-fuelcheck)
    "$CLI" init "$WORKSPACE"
    ;;
  skip-fuelcheck)
    "$CLI" init --skip-fuelcheck "$WORKSPACE"
    ;;
  *)
    echo "[live-smoke] unsupported MULTIPLUS_LIVE_INIT_MODE: $INIT_MODE" >&2
    exit 1
    ;;
esac

"$CLI" profile add "$ACCOUNT" --workspace "$WORKSPACE"

SOURCE_AUTH_FILE="$SOURCE_AUTH_HOME/.codex/auth.json"
DEST_AUTH_FILE="$WORKSPACE/.codex-home/profiles/$ACCOUNT/.codex/auth.json"

[[ -f "$SOURCE_AUTH_FILE" ]] || {
  echo "[live-smoke] missing source auth file: $SOURCE_AUTH_FILE" >&2
  exit 1
}

mkdir -p "$(dirname "$DEST_AUTH_FILE")"
cp "$SOURCE_AUTH_FILE" "$DEST_AUTH_FILE"

echo "[live-smoke] running doctor"
"$CLI" doctor --workspace "$WORKSPACE" --account "$ACCOUNT"

echo "[live-smoke] running routed login status"
"$CLI" codex --account "$ACCOUNT" --workspace "$WORKSPACE" login status

echo "[live-smoke] running routed exec with execution artifact"
"$CLI" codex \
  --account "$ACCOUNT" \
  --workspace "$WORKSPACE" \
  --write-artifact \
  --artifact-dir "$ARTIFACT_DIR" \
  exec --ephemeral --skip-git-repo-check "$PROMPT_TEXT"

[[ -f "$ARTIFACT_DIR/latest-execution.json" ]]
grep -q '"schema_version": "1"' "$ARTIFACT_DIR/latest-execution.json"
grep -q '"preflight_ok": true' "$ARTIFACT_DIR/latest-execution.json"
grep -q "\"account\": \"$ACCOUNT\"" "$ARTIFACT_DIR/latest-execution.json"

echo "[live-smoke] running report status"
"$CLI" report status --all --workspace "$WORKSPACE" --output-dir "$REPORT_DIR"

[[ -f "$REPORT_DIR/status-report.json" ]]
[[ -f "$REPORT_DIR/status-report.md" ]]
grep -q '"schema_version": "1"' "$REPORT_DIR/status-report.json"

echo "[live-smoke] artifacts:"
echo "  $ARTIFACT_DIR/latest-execution.json"
echo "  $REPORT_DIR/status-report.json"
echo "  $REPORT_DIR/status-report.md"

echo "[live-smoke] ok"
