#!/usr/bin/env bash
set -euo pipefail

PROJECT_PATH="${1:-}"
FORMAT="${FORMAT:-svg}"
CHECK_ONLY="${CHECK_ONLY:-false}"
FORCE="${FORCE:-false}"

if [[ -z "$PROJECT_PATH" ]]; then
  echo "Uso: ./diagrams.sh /ruta/al/proyecto"
  exit 1
fi

if ! command -v mmdc >/dev/null 2>&1; then
  echo "Mermaid CLI no está instalado."
  echo "Ejecuta: npm install -g @mermaid-js/mermaid-cli"
  exit 1
fi

SOURCE_ROOT="$PROJECT_PATH/docs/diagrams/source"
OUTPUT_ROOT="$PROJECT_PATH/docs/diagrams/generated"

if [[ ! -d "$SOURCE_ROOT" ]]; then
  echo "No existe $SOURCE_ROOT. Ejecuta docs.sh primero."
  exit 1
fi

mkdir -p "$OUTPUT_ROOT"
TEMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEMP_ROOT"' EXIT

found=0
for file in "$SOURCE_ROOT"/*.mmd; do
  [[ -e "$file" ]] || continue
  found=1
  name="$(basename "$file" .mmd)"

  if [[ "$CHECK_ONLY" == "true" ]]; then
    output="$TEMP_ROOT/$name.$FORMAT"
  else
    output="$OUTPUT_ROOT/$name.$FORMAT"
  fi

  if [[ "$CHECK_ONLY" != "true" && "$FORCE" != "true" && -f "$output" && "$output" -nt "$file" ]]; then
    echo "Sin cambios: $(basename "$file")"
    continue
  fi

  echo "Renderizando $(basename "$file")..."
  mmdc -i "$file" -o "$output" -e "$FORMAT" -b transparent
done

if [[ "$found" -eq 0 ]]; then
  echo "No se encontraron archivos .mmd."
  exit 1
fi

if [[ "$CHECK_ONLY" == "true" ]]; then
  echo "Todos los diagramas Mermaid son válidos."
else
  echo "Diagramas actualizados en $OUTPUT_ROOT"
fi
