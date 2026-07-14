#!/usr/bin/env bash
set -u
project="${1:-}"
[[ -n "$project" && -d "$project" ]] || { echo "Uso: ./security.sh /ruta/proyecto"; exit 1; }
root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$root/skill-activity.sh" "$project" facbgnto-security-review start "Revisión automatizada"
folder="$project/reports/security"
mkdir -p "$folder"
report="$folder/security-$(date +%Y%m%d-%H%M%S).md"
failed=0
printf '# Informe automatizado de seguridad\n\n- Fecha: %s\n- Skill: facbgnto-security-review\n\n' "$(date -Iseconds)" > "$report"

run_check(){
  name="$1"; shift
  printf '\n## %s\n\n```text\n' "$name" >> "$report"
  "$@" >> "$report" 2>&1
  code=$?
  printf '\n```\n\n- Código: %s\n' "$code" >> "$report"
  [[ "$code" -eq 0 ]] || failed=1
}

[[ "${RUN_GITLEAKS:-false}" == "true" ]] && command -v gitleaks >/dev/null && run_check Gitleaks gitleaks detect --source "$project" --no-banner --redact
[[ "${RUN_SEMGREP:-false}" == "true" ]] && command -v semgrep >/dev/null && run_check Semgrep semgrep scan --config auto "$project"
if [[ "${RUN_DEPENDENCY_AUDIT:-false}" == "true" && -f "$project/package.json" ]]; then
  (cd "$project" && npm audit --audit-level=high) >> "$report" 2>&1 || failed=1
fi

"$root/skill-activity.sh" "$project" facbgnto-security-review finish "Revisión finalizada"
echo "Informe generado: $report"
[[ "${FAIL_ON_FINDINGS:-false}" == "true" && "$failed" -ne 0 ]] && exit 1
