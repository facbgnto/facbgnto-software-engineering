#!/usr/bin/env bash
set -euo pipefail
PROJECT_PATH="${PROJECT_PATH:?PROJECT_PATH requerido}"; AGENT="${AGENT:-codex}"; ENABLE_OUTPUT_SHAPER="${ENABLE_OUTPUT_SHAPER:-false}"; DRY_RUN="${DRY_RUN:-false}"; FORCE="${FORCE:-false}"
run(){ if [[ "$DRY_RUN" == true ]]; then printf '[DRY-RUN]'; printf ' %q' "$@"; printf '\n'; else "$@"; fi; }
command -v uv >/dev/null 2>&1 || { echo "Headroom requiere uv."; exit 1; }
if command -v headroom >/dev/null 2>&1; then run uv tool upgrade headroom-ai; else run uv tool install --python 3.13 'headroom-ai[all]'; fi
mkdir -p "$PROJECT_PATH/.facbgnto"
file="$PROJECT_PATH/.facbgnto/headroom.env"
if [[ -f "$file" && "$FORCE" != true ]]; then echo "Conservado: $file"; else
  shaper=0; [[ "$ENABLE_OUTPUT_SHAPER" == true ]] && shaper=1
  if [[ "$DRY_RUN" == true ]]; then echo "[DRY-RUN] Crear $file"; else cat > "$file" <<CFG
# FACBGNTO Headroom
HEADROOM_OUTPUT_SHAPER=$shaper
HEADROOM_OUTPUT_HOLDOUT=0.1
HEADROOM_UPDATE_CHECK=on
HEADROOM_PROXY_PORT=8787
CFG
  fi
fi
[[ "$DRY_RUN" == true ]] || headroom doctor
echo "Headroom instalado."
