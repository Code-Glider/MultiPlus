#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLI="$ROOT/bin/multiplus"
TMP_DIR="$ROOT/.tmp/smoke"
WORKSPACE="$TMP_DIR/workspace"
SKIP_WORKSPACE="$TMP_DIR/workspace-skip"
WT_REPO="$TMP_DIR/worktree-repo"
WT_PATH="$TMP_DIR/worktree-checkout"
WT_EXISTING_PATH="$TMP_DIR/existing-path"
FAKE_BIN="$TMP_DIR/bin"

rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"
mkdir -p "$FAKE_BIN"

bash -n "$CLI"
bash -n "$ROOT/install.sh"
bash -n "$ROOT/tests/live-smoke.sh"
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
  if [[ "${MULTIPLUS_TEST_CODEX_STATUS_MODE:-}" == "logged_out" ]]; then
    if [[ "${MULTIPLUS_TEST_CODEX_STATUS_STDERR:-}" == "1" ]]; then
      printf 'Not logged in\n' >&2
    else
      printf 'Not logged in\n'
    fi
    exit 0
  fi
  if [[ "${MULTIPLUS_TEST_CODEX_STATUS_STDERR:-}" == "1" ]]; then
    printf 'Logged in using ChatGPT\n' >&2
  else
    printf 'Logged in using ChatGPT\n'
  fi
  exit 0
fi
if [[ -n "${MULTIPLUS_TEST_CODEX_LOG:-}" ]]; then
  {
    printf 'HOME=%s\n' "${HOME:-}"
    printf 'XDG_CONFIG_HOME=%s\n' "${XDG_CONFIG_HOME:-}"
    printf 'PWD=%s\n' "$(pwd)"
    printf 'ARGS='
    printf '%s ' "$@"
    printf '\n'
  } >>"$MULTIPLUS_TEST_CODEX_LOG"
fi
exit "${MULTIPLUS_TEST_CODEX_EXIT_CODE:-0}"
EOF
chmod +x "$FAKE_BIN/codex"

PATH="$FAKE_BIN:$PATH" "$CLI" init "$WORKSPACE"
[[ -x "$WORKSPACE/.codex-home/tools/fuelcheck/bin/fuelcheck" ]]
PATH="$FAKE_BIN:$PATH" "$CLI" init --skip-fuelcheck "$SKIP_WORKSPACE"
[[ ! -e "$SKIP_WORKSPACE/.codex-home/tools/fuelcheck/bin/fuelcheck" ]]
"$CLI" profile add personal --workspace "$WORKSPACE"
"$CLI" profile add work --workspace "$WORKSPACE"
"$CLI" use work --workspace "$WORKSPACE"

MULTIPLUS_TEST_CODEX_LOG="$TMP_DIR/codex.log" PATH="$FAKE_BIN:$PATH" "$CLI" run --workspace "$WORKSPACE" -- exec "default account route" >/dev/null
grep -q "HOME=$WORKSPACE/.codex-home/profiles/work" "$TMP_DIR/codex.log"
grep -q 'ARGS=-C '"$WORKSPACE"' exec default account route ' "$TMP_DIR/codex.log"

MULTIPLUS_TEST_CODEX_LOG="$TMP_DIR/codex.log" PATH="$FAKE_BIN:$PATH" "$CLI" login personal --workspace "$WORKSPACE" >/dev/null
grep -q "HOME=$WORKSPACE/.codex-home/profiles/personal" "$TMP_DIR/codex.log"

MULTIPLUS_TEST_CODEX_LOG="$TMP_DIR/codex-router.log" PATH="$FAKE_BIN:$PATH" "$CLI" codex --account personal --workspace "$WORKSPACE" exec "router path" >/dev/null
grep -q "HOME=$WORKSPACE/.codex-home/profiles/personal" "$TMP_DIR/codex-router.log"
grep -q 'ARGS=-C '"$WORKSPACE"' exec router path ' "$TMP_DIR/codex-router.log"

MULTIPLUS_TEST_CODEX_LOG="$TMP_DIR/codex-router-profile.log" PATH="$FAKE_BIN:$PATH" "$CLI" codex --account work --workspace "$WORKSPACE" exec --profile deep "profile route" >/dev/null
grep -q 'ARGS=-C '"$WORKSPACE"' exec --profile deep profile route ' "$TMP_DIR/codex-router-profile.log"

MULTIPLUS_TEST_CODEX_LOG="$TMP_DIR/codex-mcp.log" PATH="$FAKE_BIN:$PATH" "$CLI" codex --account personal --workspace "$WORKSPACE" mcp-server >/dev/null
grep -q "HOME=$WORKSPACE/.codex-home/profiles/personal" "$TMP_DIR/codex-mcp.log"
grep -q 'ARGS=-C '"$WORKSPACE"' mcp-server ' "$TMP_DIR/codex-mcp.log"

router_exit=0
if MULTIPLUS_TEST_CODEX_EXIT_CODE=23 PATH="$FAKE_BIN:$PATH" "$CLI" codex --account work --workspace "$WORKSPACE" exec "exit passthrough" >/dev/null 2>"$TMP_DIR/codex-exit.err"; then
  router_exit=0
else
  router_exit=$?
fi
[[ "$router_exit" -eq 23 ]]

artifact_exit=0
if MULTIPLUS_TEST_CODEX_EXIT_CODE=17 PATH="$FAKE_BIN:$PATH" "$CLI" codex --account work --workspace "$WORKSPACE" --write-artifact --artifact-dir "$TMP_DIR/execution-artifacts" exec --profile deep "artifact route" >/dev/null 2>"$TMP_DIR/codex-artifact.err"; then
  artifact_exit=0
else
  artifact_exit=$?
fi
[[ "$artifact_exit" -eq 17 ]]
[[ -f "$TMP_DIR/execution-artifacts/latest-execution.json" ]]
grep -q '"schema_version": "1"' "$TMP_DIR/execution-artifacts/latest-execution.json"
grep -q '"account": "work"' "$TMP_DIR/execution-artifacts/latest-execution.json"
grep -q '"codex_profile": "deep"' "$TMP_DIR/execution-artifacts/latest-execution.json"
grep -q '"exit_code": 17' "$TMP_DIR/execution-artifacts/latest-execution.json"
grep -q '"preflight_ok": true' "$TMP_DIR/execution-artifacts/latest-execution.json"
grep -q '"auth_status": "Logged in using ChatGPT"' "$TMP_DIR/execution-artifacts/latest-execution.json"
grep -q '"command": \["-C", "'"$WORKSPACE"'", "exec", "--profile", "deep", "artifact route"\]' "$TMP_DIR/execution-artifacts/latest-execution.json"
grep -q 'Wrote '"$TMP_DIR/execution-artifacts/" "$TMP_DIR/codex-artifact.err"

mkdir -p "$WT_REPO"
git -C "$WT_REPO" init >/dev/null
git -C "$WT_REPO" config user.name "MultiPlus Smoke"
git -C "$WT_REPO" config user.email "smoke@example.com"
printf '# temp repo\n' >"$WT_REPO/README.md"
git -C "$WT_REPO" add README.md
git -C "$WT_REPO" commit -m "init" >/dev/null

PATH="$FAKE_BIN:$PATH" "$CLI" worktree create --repo "$WT_REPO" --branch feature-bootstrap --path "$WT_PATH" --account client-a >/dev/null
[[ -d "$WT_PATH/.git" || -f "$WT_PATH/.git" ]]
[[ -f "$WT_PATH/.codex/config.toml" ]]
[[ -x "$WT_PATH/multiplus-local.sh" ]]
[[ -f "$WT_PATH/.codex-home/profiles/client-a/.codex/config.toml" ]]
[[ -x "$WT_PATH/.codex-home/tools/fuelcheck/bin/fuelcheck" ]]
[[ -f "$WT_PATH/.codex-home/state/worktree-link.json" ]]
grep -q '"schema_version": "1"' "$WT_PATH/.codex-home/state/worktree-link.json"
grep -q '"branch": "feature-bootstrap"' "$WT_PATH/.codex-home/state/worktree-link.json"
grep -q '"account": "client-a"' "$WT_PATH/.codex-home/state/worktree-link.json"
grep -q "$WT_PATH" "$WT_PATH/.codex-home/state/worktree-link.json"
git -C "$WT_REPO" worktree list | grep -q "$WT_PATH"

worktree_list_output="$(PATH="$FAKE_BIN:$PATH" "$CLI" worktree list --repo "$WT_REPO")"
printf '%s\n' "$worktree_list_output" | grep -q "Repo: $WT_REPO"
printf '%s\n' "$worktree_list_output" | grep -q 'linked'
printf '%s\n' "$worktree_list_output" | grep -q 'feature-bootstrap'
printf '%s\n' "$worktree_list_output" | grep -q 'client-a'
printf '%s\n' "$worktree_list_output" | grep -q "$WT_PATH/.codex-home/profiles/client-a"

usage_map_repo_output="$(PATH="$FAKE_BIN:$PATH" "$CLI" usage map --repo "$WT_REPO" --output-dir "$TMP_DIR/usage-repo")"
printf '%s\n' "$usage_map_repo_output" | grep -q 'unlinked'
printf '%s\n' "$usage_map_repo_output" | grep -q 'linked'
printf '%s\n' "$usage_map_repo_output" | grep -q "$WT_PATH"
[[ -f "$TMP_DIR/usage-repo/usage-map.json" ]]
[[ -f "$TMP_DIR/usage-repo/usage-map.md" ]]
[[ -f "$TMP_DIR/usage-repo/latest-usage-map.json" ]]
[[ -f "$TMP_DIR/usage-repo/latest-usage-map.md" ]]
grep -q '"mode": "repo"' "$TMP_DIR/usage-repo/usage-map.json"
grep -q '"repo": "'"$WT_REPO"'"' "$TMP_DIR/usage-repo/usage-map.json"
grep -q '"linked_account": "client-a"' "$TMP_DIR/usage-repo/usage-map.json"

usage_rollup_output="$(PATH="$FAKE_BIN:$PATH" "$CLI" usage rollup --repo "$WT_REPO" --output-dir "$TMP_DIR/usage-rollup")"
printf '%s\n' "$usage_rollup_output" | grep -q "Repo: $WT_REPO"
printf '%s\n' "$usage_rollup_output" | grep -q 'ACCOUNT'
printf '%s\n' "$usage_rollup_output" | grep -q 'client-a'
printf '%s\n' "$usage_rollup_output" | grep -q 'Issues:'
printf '%s\n' "$usage_rollup_output" | grep -q 'unlinked'
[[ -f "$TMP_DIR/usage-rollup/usage-rollup.json" ]]
[[ -f "$TMP_DIR/usage-rollup/usage-rollup.md" ]]
[[ -f "$TMP_DIR/usage-rollup/latest-usage-rollup.json" ]]
[[ -f "$TMP_DIR/usage-rollup/latest-usage-rollup.md" ]]
grep -q '"schema_version": "1"' "$TMP_DIR/usage-rollup/usage-rollup.json"
grep -q '"repo": "'"$WT_REPO"'"' "$TMP_DIR/usage-rollup/usage-rollup.json"
grep -q '"account": "client-a"' "$TMP_DIR/usage-rollup/usage-rollup.json"
grep -q '"duplicate_account_groups": 0' "$TMP_DIR/usage-rollup/usage-rollup.json"
grep -q '| client-a | 1 |' "$TMP_DIR/usage-rollup/usage-rollup.md"

worktree_doctor_output="$(PATH="$FAKE_BIN:$PATH" "$CLI" worktree doctor --path "$WT_PATH")"
printf '%s\n' "$worktree_doctor_output" | grep -q "Worktree: $WT_PATH"
printf '%s\n' "$worktree_doctor_output" | grep -q "Repo: $WT_REPO"
printf '%s\n' "$worktree_doctor_output" | grep -q 'Account: client-a'
printf '%s\n' "$worktree_doctor_output" | grep -q 'Doctor: ok'

MULTIPLUS_TEST_CODEX_LOG="$TMP_DIR/worktree-codex.log" PATH="$FAKE_BIN:$PATH" "$CLI" codex --account client-a --workspace "$WT_PATH" exec "worktree route" >/dev/null
grep -q "HOME=$WT_PATH/.codex-home/profiles/client-a" "$TMP_DIR/worktree-codex.log"
grep -q 'ARGS=-C '"$WT_PATH"' exec worktree route ' "$TMP_DIR/worktree-codex.log"

rm -rf "$WT_PATH/.codex-home/profiles/client-a"
if PATH="$FAKE_BIN:$PATH" "$CLI" worktree doctor --path "$WT_PATH" >"$TMP_DIR/worktree-doctor-missing-account.out" 2>&1; then
  echo "expected missing linked account failure" >&2
  exit 1
fi
grep -q 'linked account missing for worktree: client-a' "$TMP_DIR/worktree-doctor-missing-account.out"

usage_rollup_broken_output="$(PATH="$FAKE_BIN:$PATH" "$CLI" usage rollup --repo "$WT_REPO")"
printf '%s\n' "$usage_rollup_broken_output" | grep -q 'account-missing'
printf '%s\n' "$usage_rollup_broken_output" | grep -q "$WT_PATH"

WT_BAD_REPO="$(mktemp -d /tmp/multiplus-nonrepo-XXXXXX)"
if PATH="$FAKE_BIN:$PATH" "$CLI" worktree create --repo "$WT_BAD_REPO" --branch bad-branch --path "$TMP_DIR/bad-worktree" --account broken >"$TMP_DIR/worktree-bad-repo.out" 2>&1; then
  echo "expected non-git repo failure" >&2
  exit 1
fi
grep -q "repo is not a git repository: $WT_BAD_REPO" "$TMP_DIR/worktree-bad-repo.out"

if PATH="$FAKE_BIN:$PATH" "$CLI" worktree create --repo "$WT_REPO" --branch feature-bootstrap --path "$TMP_DIR/duplicate-branch-worktree" --account other >"$TMP_DIR/worktree-duplicate-branch.out" 2>&1; then
  echo "expected duplicate branch failure" >&2
  exit 1
fi
grep -q "feature-bootstrap" "$TMP_DIR/worktree-duplicate-branch.out"

mkdir -p "$WT_EXISTING_PATH"
printf 'occupied\n' >"$WT_EXISTING_PATH/keep.txt"
if PATH="$FAKE_BIN:$PATH" "$CLI" worktree create --repo "$WT_REPO" --branch occupied-path --path "$WT_EXISTING_PATH" --account other >"$TMP_DIR/worktree-existing-path.out" 2>&1; then
  echo "expected existing path failure" >&2
  exit 1
fi
grep -q "$WT_EXISTING_PATH" "$TMP_DIR/worktree-existing-path.out"

if PATH="$FAKE_BIN:$PATH" "$CLI" run missing --workspace "$WORKSPACE" -- exec "should fail" >/dev/null 2>"$TMP_DIR/missing-account.err"; then
  echo "expected missing account failure" >&2
  exit 1
fi
grep -q 'unknown account: missing' "$TMP_DIR/missing-account.err"

if PATH="$FAKE_BIN:$PATH" "$CLI" codex --account missing --workspace "$WORKSPACE" exec "should fail" >/dev/null 2>"$TMP_DIR/missing-router-account.err"; then
  echo "expected missing routed account failure" >&2
  exit 1
fi
grep -q 'unknown account: missing' "$TMP_DIR/missing-router-account.err"

if PATH="$FAKE_BIN:$PATH" "$CLI" codex --account work --workspace "$WORKSPACE" exec --profile missing "should fail" >/dev/null 2>"$TMP_DIR/missing-codex-profile.err"; then
  echo "expected missing codex profile failure" >&2
  exit 1
fi
grep -q 'requested Codex profile not defined in selected account: missing' "$TMP_DIR/missing-codex-profile.err"

default_profile="$(cat "$WORKSPACE/.codex-home/state/default-profile")"
[[ "$default_profile" == "work" ]]
[[ -f "$WORKSPACE/.codex/config.toml" ]]
[[ -f "$WORKSPACE/.codex-home/profiles/personal/.codex/config.toml" ]]
[[ -f "$WORKSPACE/.codex-home/profiles/work/.codex/config.toml" ]]

"$CLI" profile list --workspace "$WORKSPACE" >/dev/null
"$CLI" doctor --workspace "$WORKSPACE" >/dev/null
doctor_account="$(PATH="$FAKE_BIN:$PATH" "$CLI" doctor --workspace "$WORKSPACE" --account work)"
printf '%s\n' "$doctor_account" | grep -q 'account: work'
printf '%s\n' "$doctor_account" | grep -q 'preflight: ok'

doctor_account_stderr="$(MULTIPLUS_TEST_CODEX_STATUS_STDERR=1 PATH="$FAKE_BIN:$PATH" "$CLI" doctor --workspace "$WORKSPACE" --account work)"
printf '%s\n' "$doctor_account_stderr" | grep -q 'auth: Logged in using ChatGPT'
printf '%s\n' "$doctor_account_stderr" | grep -q 'preflight: ok'

usage_map_workspace_output="$(PATH="$FAKE_BIN:$PATH" "$CLI" usage map --all --workspace "$WORKSPACE" --output-dir "$TMP_DIR/usage-workspace")"
printf '%s\n' "$usage_map_workspace_output" | grep -q 'KIND'
printf '%s\n' "$usage_map_workspace_output" | grep -q 'workspace'
printf '%s\n' "$usage_map_workspace_output" | grep -q "$WORKSPACE"
[[ -f "$TMP_DIR/usage-workspace/usage-map.json" ]]
[[ -f "$TMP_DIR/usage-workspace/usage-map.md" ]]
[[ -f "$TMP_DIR/usage-workspace/latest-usage-map.json" ]]
[[ -f "$TMP_DIR/usage-workspace/latest-usage-map.md" ]]
grep -q '"schema_version": "1"' "$TMP_DIR/usage-workspace/usage-map.json"
grep -q '"mode": "workspace"' "$TMP_DIR/usage-workspace/usage-map.json"
grep -q '"default_profile": "work"' "$TMP_DIR/usage-workspace/usage-map.json"

usage_snapshot_output="$(PATH="$FAKE_BIN:$PATH" "$CLI" usage snapshot --all --workspace "$WORKSPACE" --output-dir "$TMP_DIR/usage-snapshot")"
printf '%s\n' "$usage_snapshot_output" | grep -q 'KIND'
printf '%s\n' "$usage_snapshot_output" | grep -q 'SOURCE'
printf '%s\n' "$usage_snapshot_output" | grep -q '5H%'
[[ -f "$TMP_DIR/usage-snapshot/latest-usage-snapshot.json" ]]
[[ -f "$TMP_DIR/usage-snapshot/latest-usage-snapshot.md" ]]
grep -q '"schema_version": "1"' "$TMP_DIR/usage-snapshot/latest-usage-snapshot.json"
grep -q '"auth_status": "Logged in using ChatGPT"' "$TMP_DIR/usage-snapshot/latest-usage-snapshot.json"
grep -q '"status_source": "fuelcheck"' "$TMP_DIR/usage-snapshot/latest-usage-snapshot.json"
grep -q '"five_hour_used_percent": 20' "$TMP_DIR/usage-snapshot/latest-usage-snapshot.json"
grep -q '"weekly_used_percent": 40' "$TMP_DIR/usage-snapshot/latest-usage-snapshot.json"
grep -q '| workspace | workspace |' "$TMP_DIR/usage-snapshot/latest-usage-snapshot.md"

history_single_output="$(PATH="$FAKE_BIN:$PATH" "$CLI" usage history --workspace "$WORKSPACE" --output-dir "$TMP_DIR/usage-snapshot")"
printf '%s\n' "$history_single_output" | grep -q 'Previous snapshot: unavailable'
printf '%s\n' "$history_single_output" | grep -q '5h delta: unavailable'

cat >"$FAKE_BIN/fuelcheck" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
provider="${1:-}"
mode="${2:-}"
if [[ "$provider" == "usage" ]]; then
  shift
  provider="${1:-}"
  mode="${2:-}"
fi
if [[ "$provider" == "--json" ]]; then
  provider="codex"
  mode="--json"
fi
case "$provider" in
  codex)
    cat <<'JSON'
{
  "Codex": {
    "plan_type": "plus",
    "credits": {
      "balance": "9",
      "unlimited": false
    },
    "rate_limit": {
      "primary_window": {
        "used_percent": 35,
        "reset_after_seconds": 900
      },
      "secondary_window": {
        "used_percent": 55,
        "reset_after_seconds": 86400
      }
    }
  }
}
JSON
    ;;
  *)
    exit 2
    ;;
esac
EOF
chmod +x "$FAKE_BIN/fuelcheck"

second_usage_snapshot_output="$(FUELCHECK_BIN="$FAKE_BIN/fuelcheck" PATH="$FAKE_BIN:$PATH" "$CLI" usage snapshot --all --workspace "$WORKSPACE" --output-dir "$TMP_DIR/usage-snapshot")"
printf '%s\n' "$second_usage_snapshot_output" | grep -q '35'
printf '%s\n' "$second_usage_snapshot_output" | grep -q '55'
[[ "$(find "$TMP_DIR/usage-snapshot" -maxdepth 1 -type f -name 'usage-snapshot-*.json' | wc -l)" -ge 2 ]]

history_output="$(FUELCHECK_BIN="$FAKE_BIN/fuelcheck" PATH="$FAKE_BIN:$PATH" "$CLI" usage history --workspace "$WORKSPACE" --output-dir "$TMP_DIR/usage-snapshot")"
printf '%s\n' "$history_output" | grep -q 'Current snapshot:'
printf '%s\n' "$history_output" | grep -q 'Previous snapshot:'
printf '%s\n' "$history_output" | grep -q '5h delta: +15'
printf '%s\n' "$history_output" | grep -q 'Weekly delta: +15'

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

if MULTIPLUS_TEST_CODEX_STATUS_MODE=logged_out PATH="$FAKE_BIN:$PATH" "$CLI" doctor --workspace "$WORKSPACE" --account work >"$TMP_DIR/doctor-logged-out.out" 2>&1; then
  echo "expected logged out doctor failure" >&2
  exit 1
fi
grep -q 'no active login for selected account' "$TMP_DIR/doctor-logged-out.out"

if PATH="$FAKE_BIN:$PATH" "$CLI" doctor --workspace "$WORKSPACE" --account missing >"$TMP_DIR/doctor-missing.out" 2>&1; then
  echo "expected missing account doctor failure" >&2
  exit 1
fi
grep -q 'unknown account: missing' "$TMP_DIR/doctor-missing.out"

"$CLI" status --all --workspace "$WORKSPACE" >/dev/null
doctor_skip="$("$CLI" doctor --workspace "$SKIP_WORKSPACE")"
printf '%s\n' "$doctor_skip" | grep -q 'fuelcheck: missing'

"$CLI" provider-root set claude /home/stonefreetall --workspace "$WORKSPACE" >/dev/null
"$CLI" provider-root set gemini /home/stonefreetall --workspace "$WORKSPACE" >/dev/null
"$CLI" status --all --adapter fuelcheck --workspace "$WORKSPACE" >/dev/null
"$CLI" report status --all --adapter fuelcheck --workspace "$WORKSPACE" --output-dir "$TMP_DIR/artifacts" >/dev/null

[[ -f "$TMP_DIR/artifacts/status-report.json" ]]
[[ -f "$TMP_DIR/artifacts/status-report.md" ]]
[[ -f "$TMP_DIR/artifacts/latest-status-report.json" ]]
[[ -f "$TMP_DIR/artifacts/latest-status-report.md" ]]
grep -q '"schema_version": "1"' "$TMP_DIR/artifacts/status-report.json"
[[ -f "$TMP_DIR/artifacts/raw/personal-fuelcheck-codex.json" ]]
[[ -f "$TMP_DIR/artifacts/raw/personal-fuelcheck-claude.json" ]]
[[ -f "$TMP_DIR/artifacts/raw/personal-fuelcheck-gemini.json" ]]
[[ -f "$TMP_DIR/artifacts/raw/work-fuelcheck-codex.json" ]]
[[ -f "$TMP_DIR/artifacts/raw/work-fuelcheck-claude.json" ]]
[[ -f "$TMP_DIR/artifacts/raw/work-fuelcheck-gemini.json" ]]
grep -q '"providers"' "$TMP_DIR/artifacts/status-report.json"
grep -q '"claude"' "$TMP_DIR/artifacts/status-report.json"
grep -q '"gemini"' "$TMP_DIR/artifacts/status-report.json"
[[ -f "$ROOT/docs/ARTIFACTS.md" ]]
[[ -f "$ROOT/docs/RELEASE.md" ]]
[[ -f "$ROOT/docs/schemas/status-report.v1.json" ]]
[[ -f "$ROOT/docs/schemas/execution-artifact.v1.json" ]]
[[ -f "$ROOT/docs/schemas/usage-rollup.v1.json" ]]
[[ -f "$ROOT/tests/live-smoke.sh" ]]
[[ -f "$ROOT/.github/workflows/smoke.yml" ]]
grep -q '0.1.0' "$ROOT/README.md"
[[ "$(cat "$ROOT/VERSION")" == "0.1.0" ]]

echo "smoke: ok"
