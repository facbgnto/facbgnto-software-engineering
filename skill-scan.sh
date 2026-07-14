#!/usr/bin/env bash
set -euo pipefail
path="${1:-}"
[[ -n "$path" ]] || { echo "Uso: ./skill-scan.sh /ruta/skill"; exit 1; }
if command -v skill-scanner >/dev/null; then scanner=skill-scanner
elif command -v skill_scanner >/dev/null; then scanner=skill_scanner
else echo "Cisco Skill Scanner no está instalado."; exit 1
fi
"$scanner" scan "$path"
