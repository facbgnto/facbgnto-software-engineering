#!/usr/bin/env bash
set -euo pipefail

PROJECT_PATH="${1:-}"
FORCE="${FORCE:-false}"
DRY_RUN="${DRY_RUN:-false}"
INSTALL_GRAPHIFY="${INSTALL_GRAPHIFY:-false}"
INDEX_GRAPHIFY="${INDEX_GRAPHIFY:-false}"
INSTALL_DOCUMENTATION_TOOLS="${INSTALL_DOCUMENTATION_TOOLS:-false}"
INITIALIZE_DOCUMENTATION="${INITIALIZE_DOCUMENTATION:-false}"
INSTALL_SECURITY="${INSTALL_SECURITY:-false}"
INSTALL_SECURITY_WORKFLOW="${INSTALL_SECURITY_WORKFLOW:-false}"
INITIALIZE_SECURITY_REPORTS="${INITIALIZE_SECURITY_REPORTS:-false}"
SECURITY_REPORT_NAME="${SECURITY_REPORT_NAME:-}"
INSTALL_HEADROOM="${INSTALL_HEADROOM:-false}"
INSTALL_CAVEMAN="${INSTALL_CAVEMAN:-false}"
HEADROOM_OUTPUT_SHAPER="${HEADROOM_OUTPUT_SHAPER:-false}"
AGENT="${AGENT:-codex}"
CAVEMAN_LEVEL="${CAVEMAN_LEVEL:-lite}"

if [[ -z "$PROJECT_PATH" || ! -d "$PROJECT_PATH" ]]; then
  echo "Uso: ./install.sh /ruta/al/proyecto"
  exit 1
fi

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAIN_SKILL="$SOURCE_ROOT/skills/facbgnto-software-engineering"
SECURITY_SKILL="$SOURCE_ROOT/skills/facbgnto-security-review"
SECURITY_STORAGE_SKILL="$SOURCE_ROOT/skills/security-storage"

run() {
  if [[ "$DRY_RUN" == "true" ]]; then printf '[DRY-RUN]'; printf ' %q' "$@"; printf '\n';
  else "$@"; fi
}

copy_skill() {
  local source="$1" destination="$2"
  if [[ -e "$destination" && "$FORCE" != "true" ]]; then echo "Conservado: $destination"; return; fi
  run rm -rf "$destination"
  run mkdir -p "$(dirname "$destination")"
  run cp -R "$source" "$destination"
  echo "Instalado: $destination"
}

copy_file() {
  local source="$1" destination="$2"
  if [[ -e "$destination" && "$FORCE" != "true" ]]; then echo "Conservado: $destination"; return; fi
  run mkdir -p "$(dirname "$destination")"
  run cp "$source" "$destination"
  echo "Creado: $destination"
}

for base in .agents/skills .claude/skills .cursor/skills; do
  copy_skill "$MAIN_SKILL" "$PROJECT_PATH/$base/facbgnto-software-engineering"
done
copy_file "$MAIN_SKILL/templates/AGENTS.md" "$PROJECT_PATH/AGENTS.md"

if [[ "$INSTALL_GRAPHIFY" == "true" ]]; then
  command -v uv >/dev/null 2>&1 || { echo "uv no está instalado."; exit 1; }
  if command -v graphify >/dev/null 2>&1; then run uv tool upgrade graphifyy; else run uv tool install graphifyy; fi
  copy_file "$SOURCE_ROOT/templates/.graphifyignore" "$PROJECT_PATH/.graphifyignore"
fi
if [[ "$INDEX_GRAPHIFY" == "true" ]]; then run "$SOURCE_ROOT/graph.sh" "$PROJECT_PATH"; fi
if [[ "$INSTALL_DOCUMENTATION_TOOLS" == "true" ]]; then
  command -v npm >/dev/null 2>&1 || { echo "npm no está disponible."; exit 1; }
  run npm install -g @mermaid-js/mermaid-cli@latest
fi
if [[ "$INITIALIZE_DOCUMENTATION" == "true" ]]; then
  FORCE="$FORCE" RENDER_DIAGRAMS="$INSTALL_DOCUMENTATION_TOOLS" "$SOURCE_ROOT/docs.sh" "$PROJECT_PATH"
fi
if [[ "$INSTALL_SECURITY" == "true" ]]; then
  [[ -d "$SECURITY_SKILL" ]] || { echo "No se encontró: $SECURITY_SKILL"; exit 1; }
  [[ -d "$SECURITY_STORAGE_SKILL" ]] || { echo "No se encontro: $SECURITY_STORAGE_SKILL"; exit 1; }
  for base in .agents/skills .claude/skills .cursor/skills; do
    copy_skill "$SECURITY_SKILL" "$PROJECT_PATH/$base/facbgnto-security-review"
    copy_skill "$SECURITY_STORAGE_SKILL" "$PROJECT_PATH/$base/security-storage"
  done
  copy_file "$SOURCE_ROOT/templates/security/.gitleaks.toml" "$PROJECT_PATH/.gitleaks.toml"
  copy_file "$SOURCE_ROOT/templates/security/.semgrep.yml" "$PROJECT_PATH/.semgrep.yml"
  copy_file "$SOURCE_ROOT/templates/security/SECURITY.md" "$PROJECT_PATH/SECURITY.md"
  run mkdir -p "$PROJECT_PATH/reports/agent-activity" "$PROJECT_PATH/reports/security"
fi
if [[ "$INSTALL_SECURITY_WORKFLOW" == "true" ]]; then copy_file "$SOURCE_ROOT/templates/github/workflows/security.yml" "$PROJECT_PATH/.github/workflows/security.yml"; fi
if [[ "$INITIALIZE_SECURITY_REPORTS" == "true" ]]; then
  if [[ -n "$SECURITY_REPORT_NAME" ]]; then REPORT_NAME="$SECURITY_REPORT_NAME" FORCE="$FORCE" "$SOURCE_ROOT/security-report.sh" "$PROJECT_PATH";
  else FORCE="$FORCE" "$SOURCE_ROOT/security-report.sh" "$PROJECT_PATH"; fi
fi
if [[ "$INSTALL_HEADROOM" == "true" ]]; then
  PROJECT_PATH="$PROJECT_PATH" AGENT="$AGENT" ENABLE_OUTPUT_SHAPER="$HEADROOM_OUTPUT_SHAPER" DRY_RUN="$DRY_RUN" FORCE="$FORCE" "$SOURCE_ROOT/integrations/headroom/install-headroom.sh"
fi
if [[ "$INSTALL_CAVEMAN" == "true" ]]; then
  PROJECT_PATH="$PROJECT_PATH" AGENT="$AGENT" CAVEMAN_LEVEL="$CAVEMAN_LEVEL" DRY_RUN="$DRY_RUN" FORCE="$FORCE" "$SOURCE_ROOT/integrations/caveman/install-caveman.sh"
fi

echo "Instalación completada en: $PROJECT_PATH"
