#!/usr/bin/env bash
set -euo pipefail

PROJECT_PATH="${1:-}"
FORCE="${FORCE:-false}"
RENDER_DIAGRAMS="${RENDER_DIAGRAMS:-false}"

if [[ -z "$PROJECT_PATH" || ! -d "$PROJECT_PATH" ]]; then
  echo "Uso: ./docs.sh /ruta/al/proyecto"
  exit 1
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCS_ROOT="$PROJECT_PATH/docs"
SOURCE_ROOT="$DOCS_ROOT/diagrams/source"
GENERATED_ROOT="$DOCS_ROOT/diagrams/generated"
ARCH_ROOT="$DOCS_ROOT/architecture"

mkdir -p "$DOCS_ROOT" "$SOURCE_ROOT" "$GENERATED_ROOT" "$ARCH_ROOT"

copy_tree() {
  local source="$1"
  local destination="$2"

  while IFS= read -r -d '' file; do
    rel="${file#"$source/"}"
    target="$destination/$rel"
    mkdir -p "$(dirname "$target")"

    if [[ ! -f "$target" || "$FORCE" == "true" ]]; then
      cp "$file" "$target"
      echo "Creado: $target"
    else
      echo "Conservado: $target"
    fi
  done < <(find "$source" -type f -print0)
}

copy_tree "$ROOT/templates/documentation" "$DOCS_ROOT"

for file in "$ROOT"/templates/diagrams/*.mmd; do
  target="$SOURCE_ROOT/$(basename "$file")"
  if [[ ! -f "$target" || "$FORCE" == "true" ]]; then
    cp "$file" "$target"
    echo "Creado: $target"
  fi
done

if [[ ! -f "$ARCH_ROOT/workspace.dsl" || "$FORCE" == "true" ]]; then
  cp "$ROOT/templates/diagrams/workspace.dsl" "$ARCH_ROOT/workspace.dsl"
fi

if [[ "$RENDER_DIAGRAMS" == "true" ]]; then
  "$ROOT/diagrams.sh" "$PROJECT_PATH"
fi

echo "Documentación inicializada en $DOCS_ROOT"
