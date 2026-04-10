#!/usr/bin/env bash
set -euo pipefail

echo "[VERIFY] Shell syntax"
find . -type f \( -name '*.sh' -o -path './bin/*' \) -print0 | while IFS= read -r -d '' file; do
  bash -n "$file"
done

echo "[VERIFY] Done"
