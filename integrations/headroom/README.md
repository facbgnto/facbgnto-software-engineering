# Integracion Headroom

Headroom comprime contexto, resultados de herramientas, logs, JSON y contenido documental antes de enviarlos al modelo.

Version objetivo para esta integracion: `headroom 0.31.0`.

## Instalar

```powershell
.\install.ps1 -ProjectPath "C:\repositorio\mi-proyecto" -InstallHeadroom -Agent codex
```

```bash
INSTALL_HEADROOM=true AGENT=codex ./install.sh /ruta/al/proyecto
```

## Iniciar

```powershell
.\integrations\headroom\start-headroom.ps1 -ProjectPath "C:\repositorio\mi-proyecto" -Agent codex
```

```bash
./integrations/headroom/start-headroom.sh /ruta/al/proyecto codex
```

El `output shaper` queda desactivado por defecto para evitar superposicion con Caveman. Activalo solo si no usaras Caveman.

## Perfil Deportivox

Headroom es el complemento de contexto para Deportivox; no reemplaza las skills del proyecto ni las globales de Codex.

Inventario esperado del proyecto:

- `.agents/skills/facbgnto-security-review`
- `.agents/skills/facbgnto-software-engineering`
- `.claude/skills/facbgnto-security-review`
- `.claude/skills/facbgnto-software-engineering`
- `.claude/skills/frontend-ui-engineering`
- `.claude/skills/graphify`
- `.facbgnto/headroom.env` con `HEADROOM_VERSION=0.31.0`

Verificacion:

```powershell
.\doctor.ps1 -ProjectPath "C:\repositorio\Deportivox" -Profile Deportivox
```
