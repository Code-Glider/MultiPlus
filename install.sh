#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${1:-$HOME/.local/bin}"
TARGET="$INSTALL_DIR/multiplus"
SOURCE="$SCRIPT_DIR/bin/multiplus"

mkdir -p "$INSTALL_DIR"
cp "$SOURCE" "$TARGET"
chmod +x "$TARGET"

printf 'Installed multiplus to %s\n' "$TARGET"
printf 'Add %s to PATH if needed.\n' "$INSTALL_DIR"
