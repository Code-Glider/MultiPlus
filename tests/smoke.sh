#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLI="$ROOT/bin/multiplus"
TMP_DIR="$ROOT/.tmp/smoke"
WORKSPACE="$TMP_DIR/workspace"
FAKE_BIN="$TMP_DIR/bin"

rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

bash -n "$CLI"
bash -n "$ROOT/install.sh"
[[ -f "$ROOT/skills/multiplus-operator/SKILL.md" ]]
grep -q '## Operating Stance' "$ROOT/skills/multiplus-operator/SKILL.md"
grep -q '## Evidence Ladder' "$ROOT/skills/multiplus-operator/SKILL.md"
grep -q '## Anti-Patterns' "$ROOT/skills/multiplus-operator/SKILL.md"
grep -q '## Validation' "$ROOT/skills/multiplus-operator/SKILL.md"
grep -q '## Completion States' "$ROOT/skills/multiplus-operator/SKILL.md"
"$CLI" init "$WORKSPACE"
"$CLI" profile add personal --workspace "$WORKSPACE"
"$CLI" profile add work --workspace "$WORKSPACE"
"$CLI" use work --workspace "$WORKSPACE"

default_profile="$(cat "$WORKSPACE/.codex-home/state/default-profile")"
[[ "$default_profile" == "work" ]]
[[ -f "$WORKSPACE/.codex/config.toml" ]]
[[ -f "$WORKSPACE/.codex-home/profiles/personal/.codex/config.toml" ]]
[[ -f "$WORKSPACE/.codex-home/profiles/work/.codex/config.toml" ]]

"$CLI" profile list --workspace "$WORKSPACE" >/dev/null
"$CLI" doctor --workspace "$WORKSPACE" >/dev/null
"$CLI" status --all --workspace "$WORKSPACE" >/dev/null

mkdir -p "$FAKE_BIN"
cat >"$FAKE_BIN/fuelcheck" <<'EOF'
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
EOF
chmod +x "$FAKE_BIN/fuelcheck"

PATH="$FAKE_BIN:$PATH" "$CLI" provider-root set claude /home/stonefreetall --workspace "$WORKSPACE" >/dev/null
PATH="$FAKE_BIN:$PATH" "$CLI" provider-root set gemini /home/stonefreetall --workspace "$WORKSPACE" >/dev/null
PATH="$FAKE_BIN:$PATH" "$CLI" status --all --adapter fuelcheck --workspace "$WORKSPACE" >/dev/null
PATH="$FAKE_BIN:$PATH" "$CLI" report status --all --adapter fuelcheck --workspace "$WORKSPACE" --output-dir "$TMP_DIR/artifacts" >/dev/null

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
