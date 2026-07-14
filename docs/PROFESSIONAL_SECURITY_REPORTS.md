# Informes profesionales de seguridad

## Crear un paquete

```powershell
.\security-report.ps1 `
  -ProjectPath "C:\repositorio\deportivox 2" `
  -ReportName "2026-07-14-authentication"
```

Resultado:

```text
reports/security/2026-07-14-authentication/
├── security-report.md
├── executive-summary.md
├── remediation-plan.md
├── risk-matrix.md
├── metrics.json
├── review-history.md
└── evidence/
    ├── README.md
    ├── commands/
    ├── sanitized-output/
    ├── diagrams/
    └── screenshots/
```

## Actualizar Deportivox

Desde el repositorio del kit:

```powershell
.\update.ps1 `
  -UpdateDeportivox `
  -DeportivoxPath "C:\repositorio\deportivox 2" `
  -UpdateSecurity `
  -UpdateSecurityWorkflow
```

Crear además un nuevo paquete:

```powershell
.\update.ps1 `
  -UpdateDeportivox `
  -DeportivoxPath "C:\repositorio\deportivox 2" `
  -InitializeSecurityReports `
  -SecurityReportName "2026-07-14-authentication"
```

El actualizador modifica únicamente archivos del repositorio raíz:

- `.agents/`;
- `.claude/`;
- `.cursor/`;
- `AGENTS.md`;
- `.gitleaks.toml`;
- `.semgrep.yml`;
- `SECURITY.md`;
- `.github/workflows/security.yml`;
- `reports/security/`.

No ejecuta Git dentro de `deportivox-backend` ni `deportivox-front`.
