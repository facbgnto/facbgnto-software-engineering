#!/usr/bin/env bash
set -euo pipefail

PROJECT_PATH="${1:-}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UPDATE_EXTERNAL_TOOLS="${UPDATE_EXTERNAL_TOOLS:-false}"
SKIP_GIT_PULL="${SKIP_GIT_PULL:-false}"
FORCE="${FORCE:-true}"

git_update() {
  local repo="$1"
  if [[ ! -d "$repo/.git" ]]; then
    echo "No es un repositorio Git: $repo"
    return
  fi
  git -C "$repo" fetch --all --prune
  git -C "$repo" pull --ff-only
}

if [[ "$SKIP_GIT_PULL" != "true" ]]; then
  echo "Actualizando FACBGNTO Software Engineering..."
  git_update "$ROOT"
fi

if [[ "$UPDATE_EXTERNAL_TOOLS" == "true" ]]; then
  mkdir -p "$ROOT/.external"

  declare -A repos=(
    ["superpowers"]="https://github.com/obra/superpowers.git"
    ["agent-skills"]="https://github.com/addyosmani/agent-skills.git"
    ["LightRAG"]="https://github.com/HKUDS/LightRAG.git"
    ["everything-claude-code-zh"]="https://github.com/xu-xiang/everything-claude-code-zh.git"
  )

  for name in "${!repos[@]}"; do
    path="$ROOT/.external/$name"
    if [[ -d "$path/.git" ]]; then
      echo "Actualizando $name..."
      git_update "$path"
    else
      echo "Clonando $name..."
      git clone "${repos[$name]}" "$path"
    fi
  done

  if command -v npm >/dev/null 2>&1; then
    npm install -g uipro-cli@latest
  else
    echo "npm no está disponible; UI/UX Pro Max no fue actualizado."
  fi
fi

if [[ -n "$PROJECT_PATH" ]]; then
  echo "Reinstalando skill en $PROJECT_PATH..."
  FORCE="$FORCE" "$ROOT/install.sh" "$PROJECT_PATH"
fi

echo "Actualización completada."
