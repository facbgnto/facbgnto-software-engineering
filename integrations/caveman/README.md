# Integración Caveman

Caveman reduce texto de relleno en las respuestas del agente. No debe alterar código, comandos, SQL, rutas, URL, errores, resultados de pruebas ni evidencia de seguridad.

## Instalar

```powershell
.\install.ps1 -ProjectPath "C:\repositorio\mi-proyecto" -InstallCaveman -Agent codex -CavemanLevel lite
```

```bash
INSTALL_CAVEMAN=true AGENT=codex CAVEMAN_LEVEL=lite ./install.sh /ruta/al/proyecto
```

Se recomienda `lite`. Los modos `full` y `ultra` pueden reducir demasiado explicaciones de arquitectura, auditorías y documentación.
