# Actualización de skills e integraciones

## Objetivo

Mantener actualizado el skill `facbgnto-software-engineering` y las herramientas externas sin reemplazar manualmente carpetas.

## Windows

```powershell
.\update.ps1 `
  -ProjectPath "C:\repositorio\mi-proyecto" `
  -UpdateExternalTools
```

Parámetros:

| Parámetro | Función |
|---|---|
| `-ProjectPath` | Reinstala el skill en el proyecto indicado |
| `-UpdateExternalTools` | Actualiza o clona integraciones externas |
| `-SkipGitPull` | No ejecuta `git pull` del kit principal |
| `-Force` | Mantiene compatibilidad con reinstalaciones forzadas |

## Linux/macOS

```bash
UPDATE_EXTERNAL_TOOLS=true ./update.sh /ruta/al/proyecto
```

Variables:

| Variable | Función |
|---|---|
| `UPDATE_EXTERNAL_TOOLS=true` | Actualiza integraciones externas |
| `SKIP_GIT_PULL=true` | Omite actualización del kit |
| `FORCE=true` | Reemplaza instalación existente |

## Recomendación

Antes de actualizar en proyectos críticos:

1. Confirma que el árbol Git esté limpio.
2. Crea una rama.
3. Ejecuta el actualizador.
4. Revisa el diff.
5. Ejecuta pruebas, lint, typecheck y build.
