#!/usr/bin/env bash
set -euo pipefail

PROJECT_PATH="${1:-}"
UPDATE_DEPORTIVOX="${UPDATE_DEPORTIVOX:-false}"
DEPORTIVOX_PATH="${DEPORTIVOX_PATH:-$HOME/repositorio/deportivox 2}"

UPDATE_EXTERNAL_TOOLS="${UPDATE_EXTERNAL_TOOLS:-false}"
UPDATE_GRAPHIFY="${UPDATE_GRAPHIFY:-false}"
REINDEX_GRAPHIFY="${REINDEX_GRAPHIFY:-false}"
UPDATE_DOCUMENTATION_TOOLS="${UPDATE_DOCUMENTATION_TOOLS:-false}"
REGENERATE_DOCUMENTATION="${REGENERATE_DOCUMENTATION:-false}"
UPDATE_SECURITY="${UPDATE_SECURITY:-false}"
UPDATE_SECURITY_WORKFLOW="${UPDATE_SECURITY_WORKFLOW:-false}"
INITIALIZE_SECURITY_REPORTS="${INITIALIZE_SECURITY_REPORTS:-false}"
SECURITY_REPORT_NAME="${SECURITY_REPORT_NAME:-}"

SKIP_GIT_PULL="${SKIP_GIT_PULL:-false}"
FORCE="${FORCE:-true}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

git_update() {
  local repository="$1"

  if [[ ! -d "$repository/.git" ]]; then
    echo "No es un repositorio Git: $repository"
    return
  fi

  git -C "$repository" fetch --all --prune
  git -C "$repository" pull --ff-only
}

if [[ "$SKIP_GIT_PULL" != "true" ]]; then
  echo "Actualizando FACBGNTO Software Engineering..."
  git_update "$ROOT"
fi

if [[ "$UPDATE_EXTERNAL_TOOLS" == "true" ]]; then
  mkdir -p "$ROOT/.external"

  declare -A repositories=(
    ["superpowers"]="https://github.com/obra/superpowers.git"
    ["agent-skills"]="https://github.com/addyosmani/agent-skills.git"
    ["LightRAG"]="https://github.com/HKUDS/LightRAG.git"
    ["everything-claude-code-zh"]="https://github.com/xu-xiang/everything-claude-code-zh.git"
  )

  for name in "${!repositories[@]}"; do
    path="$ROOT/.external/$name"

    if [[ -d "$path/.git" ]]; then
      git_update "$path"
    else
      git clone "${repositories[$name]}" "$path"
    fi
  done

  if command -v npm >/dev/null 2>&1; then
    npm install -g uipro-cli@latest
  fi
fi

if [[ "$UPDATE_GRAPHIFY" == "true" ]]; then
  command -v uv >/dev/null 2>&1 || {
    echo "uv no está instalado."
    exit 1
  }

  if command -v graphify >/dev/null 2>&1; then
    uv tool upgrade graphifyy
  else
    uv tool install graphifyy
  fi
fi

if [[ "$UPDATE_DOCUMENTATION_TOOLS" == "true" ]]; then
  command -v npm >/dev/null 2>&1 || {
    echo "npm no está disponible."
    exit 1
  }

  npm install -g @mermaid-js/mermaid-cli@latest
fi

target="$PROJECT_PATH"

if [[ "$UPDATE_DEPORTIVOX" == "true" && -z "$target" ]]; then
  target="$DEPORTIVOX_PATH"
fi

if [[ -n "$target" ]]; then
  [[ -d "$target" ]] || {
    echo "No existe el proyecto: $target"
    exit 1
  }

  echo "Actualizando assets en: $target"
  echo "No se modificarán repositorios internos ni submódulos."

  INSTALL_SECURITY_VALUE="$UPDATE_SECURITY"
  INSTALL_WORKFLOW_VALUE="$UPDATE_SECURITY_WORKFLOW"

  if [[ "$UPDATE_DEPORTIVOX" == "true" ]]; then
    INSTALL_SECURITY_VALUE=true
    INSTALL_WORKFLOW_VALUE=true
  fi

  INSTALL_SECURITY="$INSTALL_SECURITY_VALUE" \
  INSTALL_SECURITY_WORKFLOW="$INSTALL_WORKFLOW_VALUE" \
  INITIALIZE_SECURITY_REPORTS="$INITIALIZE_SECURITY_REPORTS" \
  SECURITY_REPORT_NAME="$SECURITY_REPORT_NAME" \
  FORCE=true \
  "$ROOT/install.sh" "$target"
fi

if [[ "$REINDEX_GRAPHIFY" == "true" ]]; then
  [[ -n "$target" ]] || {
    echo "REINDEX_GRAPHIFY requiere un proyecto."
    exit 1
  }

  FORCE="$FORCE" "$ROOT/graph.sh" "$target"
fi

if [[ "$REGENERATE_DOCUMENTATION" == "true" ]]; then
  [[ -n "$target" ]] || {
    echo "REGENERATE_DOCUMENTATION requiere un proyecto."
    exit 1
  }

  "$ROOT/docs.sh" "$target"
  FORCE=true "$ROOT/diagrams.sh" "$target"
fi

echo "Actualización completada."
