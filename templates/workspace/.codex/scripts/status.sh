#!/usr/bin/env bash
set -euo pipefail

echo "=== Branch ==="
git branch --show-current 2>/dev/null || echo "(not a git repo)"

echo
echo "=== Status ==="
git status --short 2>/dev/null || echo "(not a git repo)"

echo
echo "=== Recent Commits ==="
git log --oneline -5 2>/dev/null || echo "(no commits)"
