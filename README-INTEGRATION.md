# Archivos de integración Headroom + Caveman

Copiar estos archivos en la raíz de `facbgnto-software-engineering` respetando las carpetas.

## Archivos que reemplazan existentes

- `install.ps1`
- `install.sh`
- `doctor.ps1`
- `doctor.sh`

## Archivos nuevos

- `integrations/headroom/*`
- `integrations/caveman/*`
- `integrations/deportivox-skills.md`
- `integrations/token-optimization.md`
- `templates/token-optimization/*`

## Prueba Windows

```powershell
.\install.ps1 -ProjectPath "C:\repositorio\prueba" -InstallHeadroom -InstallCaveman -Agent codex -CavemanLevel lite -DryRun
.\validate-scripts.ps1
```

## Prueba Linux/macOS

```bash
chmod +x install.sh doctor.sh integrations/headroom/*.sh integrations/caveman/*.sh
DRY_RUN=true INSTALL_HEADROOM=true INSTALL_CAVEMAN=true AGENT=codex ./install.sh /ruta/al/proyecto
bash -n install.sh doctor.sh integrations/headroom/*.sh integrations/caveman/*.sh
```
