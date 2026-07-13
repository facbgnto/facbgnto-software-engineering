#!/usr/bin/env bash
set -u

PROJECT_PATH="${1:-}"
failed=0

check_tool() {
  local name="$1"
  local required="${2:-false}"

  if command -v "$name" >/dev/null 2>&1; then
    version="$("$name" --version 2>/dev/null | head -n 1 || true)"
    echo "[OK]   $name $version"
  else
    if [[ "$required" == "true" ]]; then
      echo "[FAIL] $name no encontrado"
      failed=1
    else
      echo "[WARN] $name no encontrado"
    fi
  fi
}

echo "FACBGNTO Software Engineering Doctor"
echo "-------------------------------------"

check_tool git true
check_tool node false
check_tool npm false
check_tool python true
check_tool uv false
check_tool graphify false
check_tool mmdc false
check_tool ollama false
check_tool docker false

if [[ -n "$PROJECT_PATH" ]]; then
  echo
  echo "Proyecto: $PROJECT_PATH"

  if [[ ! -d "$PROJECT_PATH" ]]; then
    echo "[FAIL] El proyecto no existe."
    failed=1
  else
    [[ -f "$PROJECT_PATH/AGENTS.md" ]] && echo "[OK]   AGENTS.md" || echo "[WARN] Falta AGENTS.md"
    [[ -f "$PROJECT_PATH/.graphifyignore" ]] && echo "[OK]   .graphifyignore" || echo "[WARN] Falta .graphifyignore"
    [[ -f "$PROJECT_PATH/.agents/skills/facbgnto-software-engineering/SKILL.md" ]] && echo "[OK]   Skill Codex/Agents" || echo "[WARN] Falta skill Codex/Agents"
    [[ -f "$PROJECT_PATH/.claude/skills/facbgnto-software-engineering/SKILL.md" ]] && echo "[OK]   Skill Claude" || echo "[WARN] Falta skill Claude"
    [[ -f "$PROJECT_PATH/.cursor/skills/facbgnto-software-engineering/SKILL.md" ]] && echo "[OK]   Skill Cursor" || echo "[WARN] Falta skill Cursor"
  fi
fi

echo
if [[ "$failed" -ne 0 ]]; then
  echo "Diagnóstico finalizado con errores obligatorios."
  exit 1
fi

echo "Diagnóstico completado."
