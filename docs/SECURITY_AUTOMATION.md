# Seguridad automatizada y trazabilidad

## Activación

El skill `facbgnto-security-review` se activa por su descripción cuando la solicitud involucra seguridad, vulnerabilidades, ataques, autenticación, autorización, permisos, datos sensibles, archivos, pagos, endpoints públicos, dependencias o despliegue.

Los agentes compatibles deciden qué skill cargar según la descripción y el contexto. Tenerlo instalado no prueba que fue utilizado.

## Evidencia de uso

Cada ejecución debe:

1. declarar el skill activado;
2. registrar inicio y término en `reports/agent-activity/`;
3. informar herramientas y comandos ejecutados;
4. generar informe en `reports/security/` cuando corresponda.

## Ejecución

```powershell
.\security.ps1 `
  -ProjectPath "C:\repositorio\mi-proyecto" `
  -RunGitleaks `
  -RunSemgrep `
  -RunDependencyAudit `
  -GenerateReport
```

## Skills externos

Antes de confiar en un skill externo, usa Cisco Skill Scanner como análisis de mejor esfuerzo:

```powershell
.\skill-scan.ps1 -SkillPath ".external\nuevo-skill"
```

El escáner busca prompt injection, exfiltración y patrones maliciosos, pero no garantiza que el skill sea seguro.
