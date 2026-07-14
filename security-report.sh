#!/usr/bin/env bash
set -euo pipefail

PROJECT_PATH="${1:-}"
REPORT_NAME="${REPORT_NAME:-$(date +%F)-security-review}"
FORCE="${FORCE:-false}"

if [[ -z "$PROJECT_PATH" || ! -d "$PROJECT_PATH" ]]; then
  echo "Uso: ./security-report.sh /ruta/al/proyecto"
  exit 1
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES="$ROOT/skills/facbgnto-security-review/templates"
REPORT_ROOT="$PROJECT_PATH/reports/security/$REPORT_NAME"
EVIDENCE="$REPORT_ROOT/evidence"

mkdir -p "$REPORT_ROOT" "$EVIDENCE"/{commands,sanitized-output,diagrams,screenshots}

copy_template() {
  local source="$1"
  local destination="$2"

  if [[ -f "$destination" && "$FORCE" != "true" ]]; then
    echo "Conservado: $destination"
    return
  fi

  cp "$source" "$destination"
  echo "Creado: $destination"
}

copy_template "$TEMPLATES/SECURITY-REPORT.md" "$REPORT_ROOT/security-report.md"
copy_template "$TEMPLATES/EXECUTIVE-SUMMARY.md" "$REPORT_ROOT/executive-summary.md"
copy_template "$TEMPLATES/REMEDIATION-PLAN.md" "$REPORT_ROOT/remediation-plan.md"
copy_template "$TEMPLATES/RISK-MATRIX.md" "$REPORT_ROOT/risk-matrix.md"
copy_template "$TEMPLATES/REVIEW-HISTORY.md" "$REPORT_ROOT/review-history.md"
copy_template "$TEMPLATES/metrics.json" "$REPORT_ROOT/metrics.json"
copy_template "$TEMPLATES/evidence/README.md" "$EVIDENCE/README.md"

echo "Paquete profesional creado en: $REPORT_ROOT"
