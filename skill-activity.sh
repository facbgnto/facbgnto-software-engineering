#!/usr/bin/env bash
set -euo pipefail
project="${1:-}"
skill="${2:-}"
action="${3:-note}"
reason="${4:-}"
[[ -n "$project" && -n "$skill" ]] || { echo "Uso: ./skill-activity.sh proyecto skill acción motivo"; exit 1; }
folder="$project/reports/agent-activity"
mkdir -p "$folder"
date_value="$(date +%F)"
file="$folder/$date_value-skill-activity.md"
[[ -f "$file" ]] || printf '# Registro de actividad de skills — %s\n' "$date_value" > "$file"
cat >> "$file" <<EOF

## $(date +%Y-%m-%dT%H-%M-%S) — $action
- Skill: $skill
- Motivo: $reason
EOF
echo "Actividad registrada: $file"
