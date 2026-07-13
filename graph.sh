#!/usr/bin/env bash
set -euo pipefail

PROJECT_PATH="${1:-}"
FORCE="${FORCE:-false}"
INCLUDE_DOCUMENTS="${INCLUDE_DOCUMENTS:-false}"
BACKEND="${BACKEND:-}"
SKIP_IGNORE_TEMPLATE="${SKIP_IGNORE_TEMPLATE:-false}"

if [[ -z "$PROJECT_PATH" ]]; then
  echo "Uso: ./graph.sh /ruta/al/proyecto"
  exit 1
fi

if [[ ! -d "$PROJECT_PATH" ]]; then
  echo "No existe el proyecto: $PROJECT_PATH"
  exit 1
fi

if ! command -v graphify >/dev/null 2>&1; then
  echo "Graphify no está instalado. Ejecuta install.sh con INSTALL_GRAPHIFY=true."
  exit 1
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$SKIP_IGNORE_TEMPLATE" != "true" && ! -f "$PROJECT_PATH/.graphifyignore" ]]; then
  cp "$ROOT/templates/.graphifyignore" "$PROJECT_PATH/.graphifyignore"
  echo "Creado: $PROJECT_PATH/.graphifyignore"
fi

args=(".")
if [[ "$INCLUDE_DOCUMENTS" != "true" ]]; then
  args+=("--code-only")
fi
if [[ "$FORCE" == "true" ]]; then
  args+=("--force")
fi
if [[ -n "$BACKEND" ]]; then
  args+=("--backend" "$BACKEND")
fi

echo "Indexando con Graphify: $PROJECT_PATH"
(
  cd "$PROJECT_PATH"
  graphify "${args[@]}"
)

echo "Indexación completada."
