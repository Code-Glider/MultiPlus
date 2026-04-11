#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLI="$ROOT/bin/multiplus"
TMP_DIR="$ROOT/.tmp/smoke"
WORKSPACE="$TMP_DIR/workspace"
SKIP_WORKSPACE="$TMP_DIR/workspace-skip"
FAKE_BIN="$TMP_DIR/bin"

rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"
mkdir -p "$FAKE_BIN"

bash -n "$CLI"
bash -n "$ROOT/install.sh"
[[ -f "$ROOT/skills/multiplus-operator/SKILL.md" ]]
grep -q '## Operating Stance' "$ROOT/skills/multiplus-operator/SKILL.md"
grep -q '## Evidence Ladder' "$ROOT/skills/multiplus-operator/SKILL.md"
grep -q '## Anti-Patterns' "$ROOT/skills/multiplus-operator/SKILL.md"
grep -q '## Validation' "$ROOT/skills/multiplus-operator/SKILL.md"
grep -q '## Completion States' "$ROOT/skills/multiplus-operator/SKILL.md"

cat >"$FAKE_BIN/cargo" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
root=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      root="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done
[[ -n "$root" ]] || exit 2
mkdir -p "$root/bin"
cat >"$root/bin/fuelcheck" <<'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail
provider="${1:-}"
mode="${2:-}"
if [[ "$provider" == "--json" ]]; then
  provider="codex"
  mode="--json"
fi
if [[ "$mode" == "--json" ]]; then
  case "$provider" in
    codex)
      cat <<'JSON'
{
  "Codex": {
    "plan_type": "plus",
    "credits": {
      "balance": "12",
      "unlimited": false
    },
    "rate_limit": {
      "primary_window": {
        "used_percent": 20,
        "reset_after_seconds": 1200
      },
      "secondary_window": {
        "used_percent": 40,
        "reset_after_seconds": 172800
      }
    }
  },
  "Claude": {
    "usage": {
      "five_hour": {
        "utilization": 0.35,
        "resets_at": "2099-01-01T12:00:00Z"
      },
      "seven_day": {
        "utilization": 0.55,
        "resets_at": "2099-01-07T12:00:00Z"
      }
    },
    "account": {
      "subscriptionType": "pro"
    },
    "source": "oauth"
  },
  "Gemini": {
    "tier": "Enterprise",
    "token_refreshed": true,
    "buckets": [
      {
        "modelId": "gemini-2.5-flash",
        "remainingFraction": 0.7,
        "resetTime": "2099-01-01T18:00:00Z"
      },
      {
        "modelId": "gemini-2.5-pro",
        "remainingFraction": 0.2,
        "resetTime": "2099-01-02T18:00:00Z"
      }
    ]
  }
}
JSON
      ;;
    claude)
      cat <<'JSON'
{
  "Claude": {
    "usage": {
      "five_hour": {
        "utilization": 0.35,
        "resets_at": "2099-01-01T12:00:00Z"
      },
      "seven_day": {
        "utilization": 0.55,
        "resets_at": "2099-01-07T12:00:00Z"
      }
    },
    "account": {
      "subscriptionType": "pro"
    },
    "source": "oauth"
  }
}
JSON
      ;;
    gemini)
      cat <<'JSON'
{
  "Gemini": {
    "tier": "Enterprise",
    "token_refreshed": true,
    "buckets": [
      {
        "modelId": "gemini-2.5-flash",
        "remainingFraction": 0.7,
        "resetTime": "2099-01-01T18:00:00Z"
      },
      {
        "modelId": "gemini-2.5-pro",
        "remainingFraction": 0.2,
        "resetTime": "2099-01-02T18:00:00Z"
      }
    ]
  }
}
JSON
      ;;
    *)
      exit 2
      ;;
  esac
else
  exit 2
fi
SCRIPT
chmod +x "$root/bin/fuelcheck"
EOF
chmod +x "$FAKE_BIN/cargo"

cat >"$FAKE_BIN/codex" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [[ "${1:-}" == "login" && "${2:-}" == "status" ]]; then
  if [[ -f "${HOME:-}/.codex/.logged-in" ]]; then
    printf 'logged in (smoke)\n'
  else
    printf 'not logged in\n'
  fi
  exit 0
fi
if [[ "$*" == *"__exit42__"* ]]; then
  exit 42
fi
printf 'fake codex invoked HOME=%s ARGS=%s\n' "${HOME:-}" "$*"
EOF
chmod +x "$FAKE_BIN/codex"

PATH="$FAKE_BIN:$PATH" "$CLI" init "$WORKSPACE"
[[ -x "$WORKSPACE/.codex-home/tools/fuelcheck/bin/fuelcheck" ]]
PATH="$FAKE_BIN:$PATH" "$CLI" init --skip-fuelcheck "$SKIP_WORKSPACE"
[[ ! -e "$SKIP_WORKSPACE/.codex-home/tools/fuelcheck/bin/fuelcheck" ]]
"$CLI" profile add personal --workspace "$WORKSPACE"
"$CLI" profile add work --workspace "$WORKSPACE"
"$CLI" use work --workspace "$WORKSPACE"
if "$CLI" use missing --workspace "$WORKSPACE" >/dev/null 2>"$TMP_DIR/use-missing.err"; then
  echo "expected use missing account to fail"
  exit 1
fi
grep -q 'unknown account: missing' "$TMP_DIR/use-missing.err"
if PATH="$FAKE_BIN:$PATH" "$CLI" preflight --account personal --workspace "$WORKSPACE" >/dev/null 2>"$TMP_DIR/preflight-no-login.err"; then
  echo "expected preflight without login to fail"
  exit 1
fi
grep -q 'no active login for selected account: personal' "$TMP_DIR/preflight-no-login.err"
touch "$WORKSPACE/.codex-home/profiles/personal/.codex/.logged-in"
PATH="$FAKE_BIN:$PATH" "$CLI" preflight --account personal --workspace "$WORKSPACE" >/dev/null
if PATH="$FAKE_BIN:$PATH" "$CLI" preflight --account missing --workspace "$WORKSPACE" >/dev/null 2>"$TMP_DIR/preflight-missing.err"; then
  echo "expected preflight missing account to fail"
  exit 1
fi
grep -q 'unknown account: missing' "$TMP_DIR/preflight-missing.err"
codex_output="$(PATH="$FAKE_BIN:$PATH" "$CLI" codex --account personal --profile deep --workspace "$WORKSPACE" -- exec 'review this repo')"
printf '%s\n' "$codex_output" | grep -q "HOME=$WORKSPACE/.codex-home/profiles/personal"
printf '%s\n' "$codex_output" | grep -q 'ARGS=-C'
printf '%s\n' "$codex_output" | grep -q -- '--profile deep exec review this repo'
if PATH="$FAKE_BIN:$PATH" "$CLI" codex --account personal --profile missing --workspace "$WORKSPACE" -- exec hi >/dev/null 2>"$TMP_DIR/codex-profile-missing.err"; then
  echo "expected codex with unknown profile to fail"
  exit 1
fi
grep -q 'requested profile not defined in selected account: missing' "$TMP_DIR/codex-profile-missing.err"
mcp_output="$(PATH="$FAKE_BIN:$PATH" "$CLI" mcp-server --account personal --workspace "$WORKSPACE" -- --transport stdio)"
printf '%s\n' "$mcp_output" | grep -q "HOME=$WORKSPACE/.codex-home/profiles/personal"
printf '%s\n' "$mcp_output" | grep -q 'mcp-server --transport stdio'
if PATH="$FAKE_BIN:$PATH" "$CLI" mcp-server --account missing --workspace "$WORKSPACE" >/dev/null 2>"$TMP_DIR/mcp-missing.err"; then
  echo "expected mcp-server with unknown account to fail"
  exit 1
fi
grep -q 'unknown account: missing' "$TMP_DIR/mcp-missing.err"
set +e
PATH="$FAKE_BIN:$PATH" "$CLI" codex --account personal --workspace "$WORKSPACE" -- __exit42__
codex_exit_code="$?"
set -e
[[ "$codex_exit_code" -eq 42 ]]

default_profile="$(cat "$WORKSPACE/.codex-home/state/default-profile")"
[[ "$default_profile" == "work" ]]
[[ -f "$WORKSPACE/.codex/config.toml" ]]
[[ -f "$WORKSPACE/.codex-home/profiles/personal/.codex/config.toml" ]]
[[ -f "$WORKSPACE/.codex-home/profiles/work/.codex/config.toml" ]]

"$CLI" profile list --workspace "$WORKSPACE" >/dev/null
"$CLI" doctor --workspace "$WORKSPACE" >/dev/null
"$CLI" status --all --workspace "$WORKSPACE" >/dev/null
doctor_skip="$("$CLI" doctor --workspace "$SKIP_WORKSPACE")"
printf '%s\n' "$doctor_skip" | grep -q 'fuelcheck: missing'
if "$CLI" login missing --workspace "$WORKSPACE" >/dev/null 2>"$TMP_DIR/login-missing.err"; then
  echo "expected login missing account to fail"
  exit 1
fi
grep -q 'unknown account: missing' "$TMP_DIR/login-missing.err"

"$CLI" provider-root set claude /home/stonefreetall --workspace "$WORKSPACE" >/dev/null
"$CLI" provider-root set gemini /home/stonefreetall --workspace "$WORKSPACE" >/dev/null
"$CLI" status --all --adapter fuelcheck --workspace "$WORKSPACE" >/dev/null
"$CLI" report status --all --adapter fuelcheck --workspace "$WORKSPACE" --output-dir "$TMP_DIR/artifacts" >/dev/null

[[ -f "$TMP_DIR/artifacts/status-report.json" ]]
[[ -f "$TMP_DIR/artifacts/status-report.md" ]]
[[ -f "$TMP_DIR/artifacts/raw/personal-fuelcheck-codex.json" ]]
[[ -f "$TMP_DIR/artifacts/raw/personal-fuelcheck-claude.json" ]]
[[ -f "$TMP_DIR/artifacts/raw/personal-fuelcheck-gemini.json" ]]
[[ -f "$TMP_DIR/artifacts/raw/work-fuelcheck-codex.json" ]]
[[ -f "$TMP_DIR/artifacts/raw/work-fuelcheck-claude.json" ]]
[[ -f "$TMP_DIR/artifacts/raw/work-fuelcheck-gemini.json" ]]
grep -q '"providers"' "$TMP_DIR/artifacts/status-report.json"
grep -q '"claude"' "$TMP_DIR/artifacts/status-report.json"
grep -q '"gemini"' "$TMP_DIR/artifacts/status-report.json"
grep -q '0.1.0' "$ROOT/README.md"
[[ "$(cat "$ROOT/VERSION")" == "0.1.0" ]]

echo "smoke: ok"
