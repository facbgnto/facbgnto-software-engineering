#!/usr/bin/env bash
set -euo pipefail

PROJECT_PATH="${1:-}"
FORCE="${FORCE:-false}"
INSTALL_GRAPHIFY="${INSTALL_GRAPHIFY:-false}"
INDEX_GRAPHIFY="${INDEX_GRAPHIFY:-false}"
INSTALL_DOCUMENTATION_TOOLS="${INSTALL_DOCUMENTATION_TOOLS:-false}"
INITIALIZE_DOCUMENTATION="${INITIALIZE_DOCUMENTATION:-false}"
INSTALL_SECURITY="${INSTALL_SECURITY:-false}"
INSTALL_SECURITY_WORKFLOW="${INSTALL_SECURITY_WORKFLOW:-false}"
INITIALIZE_SECURITY_REPORTS="${INITIALIZE_SECURITY_REPORTS:-false}"
SECURITY_REPORT_NAME="${SECURITY_REPORT_NAME:-}"

if [[ -z "$PROJECT_PATH" || ! -d "$PROJECT_PATH" ]]; then
  echo "Uso: ./install.sh /ruta/al/proyecto"
  exit 1
fi

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAIN_SKILL="$SOURCE_ROOT/skills/facbgnto-software-engineering"
SECURITY_SKILL="$SOURCE_ROOT/skills/facbgnto-security-review"

copy_skill() {
  local source="$1"
  local destination="$2"

  if [[ -e "$destination" && "$FORCE" != "true" ]]; then
    echo "Conservado: $destination"
    return
  fi

  rm -rf "$destination"
  mkdir -p "$(dirname "$destination")"
  cp -R "$source" "$destination"
  echo "Instalado: $destination"
}

copy_file() {
  local source="$1"
  local destination="$2"

  if [[ -e "$destination" && "$FORCE" != "true" ]]; then
    echo "Conservado: $destination"
    return
  fi

  mkdir -p "$(dirname "$destination")"
  cp "$source" "$destination"
  echo "Creado: $destination"
}

for base in ".agents/skills" ".claude/skills" ".cursor/skills"; do
  copy_skill "$MAIN_SKILL" "$PROJECT_PATH/$base/facbgnto-software-engineering"
done

copy_file "$MAIN_SKILL/templates/AGENTS.md" "$PROJECT_PATH/AGENTS.md"

if [[ "$INSTALL_GRAPHIFY" == "true" ]]; then
  command -v uv >/dev/null 2>&1 || {
    echo "uv no está instalado."
    exit 1
  }

  if command -v graphify >/dev/null 2>&1; then
    uv tool upgrade graphifyy
  else
    uv tool install graphifyy
  fi

  copy_file "$SOURCE_ROOT/templates/.graphifyignore" "$PROJECT_PATH/.graphifyignore"
fi

if [[ "$INDEX_GRAPHIFY" == "true" ]]; then
  "$SOURCE_ROOT/graph.sh" "$PROJECT_PATH"
fi

if [[ "$INSTALL_DOCUMENTATION_TOOLS" == "true" ]]; then
  command -v npm >/dev/null 2>&1 || {
    echo "npm no está disponible."
    exit 1
  }

  npm install -g @mermaid-js/mermaid-cli@latest
fi

if [[ "$INITIALIZE_DOCUMENTATION" == "true" ]]; then
  if [[ "$INSTALL_DOCUMENTATION_TOOLS" == "true" ]]; then
    FORCE="$FORCE" RENDER_DIAGRAMS=true "$SOURCE_ROOT/docs.sh" "$PROJECT_PATH"
  else
    FORCE="$FORCE" "$SOURCE_ROOT/docs.sh" "$PROJECT_PATH"
  fi
fi

if [[ "$INSTALL_SECURITY" == "true" ]]; then
  [[ -d "$SECURITY_SKILL" ]] || {
    echo "No se encontró: $SECURITY_SKILL"
    exit 1
  }

  for base in ".agents/skills" ".claude/skills" ".cursor/skills"; do
    copy_skill "$SECURITY_SKILL" "$PROJECT_PATH/$base/facbgnto-security-review"
  done

  copy_file "$SOURCE_ROOT/templates/security/.gitleaks.toml" "$PROJECT_PATH/.gitleaks.toml"
  copy_file "$SOURCE_ROOT/templates/security/.semgrep.yml" "$PROJECT_PATH/.semgrep.yml"
  copy_file "$SOURCE_ROOT/templates/security/SECURITY.md" "$PROJECT_PATH/SECURITY.md"

  mkdir -p "$PROJECT_PATH/reports/agent-activity" "$PROJECT_PATH/reports/security"
fi

if [[ "$INSTALL_SECURITY_WORKFLOW" == "true" ]]; then
  copy_file \
    "$SOURCE_ROOT/templates/github/workflows/security.yml" \
    "$PROJECT_PATH/.github/workflows/security.yml"
fi

if [[ "$INITIALIZE_SECURITY_REPORTS" == "true" ]]; then
  if [[ -n "$SECURITY_REPORT_NAME" ]]; then
    REPORT_NAME="$SECURITY_REPORT_NAME" FORCE="$FORCE" "$SOURCE_ROOT/security-report.sh" "$PROJECT_PATH"
  else
    FORCE="$FORCE" "$SOURCE_ROOT/security-report.sh" "$PROJECT_PATH"
  fi
fi


echo "Instalación completada en: $PROJECT_PATH"
