#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="__WORKSPACE_ROOT__"
PROJECT_HOME="$PROJECT_ROOT/.codex-home/profiles/${MULTIPLUS_PROFILE:-default}"

mkdir -p "$PROJECT_HOME/.codex" "$PROJECT_HOME/.config" "$PROJECT_HOME/.cache" "$PROJECT_HOME/.local/share"

export HOME="$PROJECT_HOME"
export XDG_CONFIG_HOME="$PROJECT_HOME/.config"
export XDG_CACHE_HOME="$PROJECT_HOME/.cache"
export XDG_DATA_HOME="$PROJECT_HOME/.local/share"

exec codex -C "$PROJECT_ROOT" "$@"
