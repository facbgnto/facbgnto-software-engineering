#!/usr/bin/env bash
set -u
PROJECT_PATH="${1:-}"
failed=0
check_tool(){ local name="$1" required="${2:-false}"; if command -v "$name" >/dev/null 2>&1; then echo "[OK] $name $($name --version 2>/dev/null | head -n1 || true)"; elif [[ "$required" == true ]]; then echo "[FAIL] $name no encontrado"; failed=1; else echo "[WARN] $name no encontrado"; fi; }
echo "FACBGNTO Software Engineering Doctor"
echo "-------------------------------------"
check_tool git true; check_tool node; check_tool npm; check_tool python true; check_tool uv; check_tool graphify; check_tool headroom; check_tool mmdc; check_tool ollama; check_tool docker
if command -v headroom >/dev/null 2>&1; then headroom doctor || echo "[WARN] headroom doctor informó problemas"; fi
if [[ -n "$PROJECT_PATH" ]]; then
  echo; echo "Proyecto: $PROJECT_PATH"
  if [[ ! -d "$PROJECT_PATH" ]]; then echo "[FAIL] El proyecto no existe."; failed=1
  else
    for entry in \
      "AGENTS.md:AGENTS.md" \
      ".graphifyignore:.graphifyignore" \
      ".agents/skills/facbgnto-software-engineering/SKILL.md:Skill Codex/Agents" \
      ".claude/skills/facbgnto-software-engineering/SKILL.md:Skill Claude" \
      ".cursor/skills/facbgnto-software-engineering/SKILL.md:Skill Cursor" \
      ".facbgnto/headroom.env:Configuración Headroom" \
      ".facbgnto/caveman.json:Configuración Caveman"; do
      path="${entry%%:*}"; name="${entry#*:}"; [[ -f "$PROJECT_PATH/$path" ]] && echo "[OK] $name" || echo "[WARN] Falta $name"
    done
  fi
fi
[[ "$failed" -ne 0 ]] && { echo; echo "Diagnóstico finalizado con errores obligatorios."; exit 1; }
echo; echo "Diagnóstico completado."
