#!/usr/bin/env bash
set -euo pipefail
PROJECT_PATH="${1:-$PWD}"; AGENT="${2:-codex}"; ENV_FILE="$PROJECT_PATH/.facbgnto/headroom.env"
[[ -f "$ENV_FILE" ]] && set -a && source "$ENV_FILE" && set +a
command -v headroom >/dev/null 2>&1 || { echo "Headroom no está instalado."; exit 1; }
exec headroom wrap "$AGENT"
