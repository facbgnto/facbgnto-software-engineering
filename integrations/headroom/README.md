# Integración Headroom

Headroom comprime contexto, resultados de herramientas, logs, JSON y contenido documental antes de enviarlos al modelo.

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

El `output shaper` queda desactivado por defecto para evitar superposición con Caveman. Actívalo solo si no usarás Caveman.
