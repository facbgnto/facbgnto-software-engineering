#!/usr/bin/env bash
set -euo pipefail

PROJECT_PATH="${1:-}"
FORCE="${FORCE:-false}"
INSTALL_GRAPHIFY="${INSTALL_GRAPHIFY:-false}"
INDEX_GRAPHIFY="${INDEX_GRAPHIFY:-false}"

if [[ -z "$PROJECT_PATH" ]]; then
  echo "Uso: ./install.sh /ruta/al/proyecto"
  exit 1
fi

if [[ ! -d "$PROJECT_PATH" ]]; then
  echo "No existe el proyecto: $PROJECT_PATH"
  exit 1
fi

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_SOURCE="$SOURCE_ROOT/skills/facbgnto-software-engineering"

copy_skill() {
  local destination="$1"

  if [[ -e "$destination" && "$FORCE" != "true" ]]; then
    echo "Ya existe: $destination (usa FORCE=true para reemplazar)"
    return
  fi

  rm -rf "$destination"
  mkdir -p "$(dirname "$destination")"
  cp -R "$SKILL_SOURCE" "$destination"
  echo "Instalado: $destination"
}

copy_skill "$PROJECT_PATH/.agents/skills/facbgnto-software-engineering"
copy_skill "$PROJECT_PATH/.claude/skills/facbgnto-software-engineering"
copy_skill "$PROJECT_PATH/.cursor/skills/facbgnto-software-engineering"

if [[ ! -f "$PROJECT_PATH/AGENTS.md" || "$FORCE" == "true" ]]; then
  cp "$SKILL_SOURCE/templates/AGENTS.md" "$PROJECT_PATH/AGENTS.md"
  echo "Creado: $PROJECT_PATH/AGENTS.md"
else
  echo "AGENTS.md ya existe; no fue reemplazado."
fi


if [[ "$INSTALL_GRAPHIFY" == "true" ]]; then
  if ! command -v uv >/dev/null 2>&1; then
    echo "uv no está instalado. Instálalo desde https://docs.astral.sh/uv/"
    exit 1
  fi

  if command -v graphify >/dev/null 2>&1; then
    uv tool upgrade graphifyy
  else
    uv tool install graphifyy
  fi

  cp "$SOURCE_ROOT/templates/.graphifyignore" "$PROJECT_PATH/.graphifyignore"
  echo "Creado: $PROJECT_PATH/.graphifyignore"
fi

if [[ "$INDEX_GRAPHIFY" == "true" ]]; then
  "$SOURCE_ROOT/graph.sh" "$PROJECT_PATH"
fi


echo "Instalación completada."
