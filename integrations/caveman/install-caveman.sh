#!/usr/bin/env bash
set -euo pipefail
PROJECT_PATH="${PROJECT_PATH:?PROJECT_PATH requerido}"; AGENT="${AGENT:-codex}"; CAVEMAN_LEVEL="${CAVEMAN_LEVEL:-lite}"; DRY_RUN="${DRY_RUN:-false}"; FORCE="${FORCE:-false}"
command -v node >/dev/null 2>&1 || { echo "Caveman requiere Node.js 18+."; exit 1; }
command -v npx >/dev/null 2>&1 || { echo "npx no está disponible."; exit 1; }
[[ "$AGENT" == all ]] && agents=(codex claude cursor windsurf cline copilot gemini) || agents=("$AGENT")
cd "$PROJECT_PATH"
for target in "${agents[@]}"; do
  if [[ "$DRY_RUN" == true ]]; then echo "[DRY-RUN] npx --yes skills@latest add JuliusBrussee/caveman -a $target"; else npx --yes skills@latest add JuliusBrussee/caveman -a "$target"; fi
done
mkdir -p "$PROJECT_PATH/.facbgnto"; file="$PROJECT_PATH/.facbgnto/caveman.json"
if [[ -f "$file" && "$FORCE" != true ]]; then echo "Conservado: $file"; elif [[ "$DRY_RUN" == true ]]; then echo "[DRY-RUN] Crear $file"; else
cat > "$file" <<CFG
{
  "level": "$CAVEMAN_LEVEL",
  "preserve": ["code", "commands", "paths", "urls", "sql", "errors", "security-evidence", "test-results"],
  "installedAgent": "$AGENT"
}
CFG
fi
echo "Caveman instalado. Nivel recomendado: $CAVEMAN_LEVEL"
