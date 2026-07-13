# Integración con Graphify

Graphify se utiliza para analizar la estructura del código y localizar archivos, funciones, clases, rutas, controladores, servicios y modelos relacionados.

## Instalación en Windows

```powershell
.\install.ps1 `
  -ProjectPath "C:\repositorio\mi-proyecto" `
  -InstallGraphify
```

## Instalar e indexar

```powershell
.\install.ps1 `
  -ProjectPath "C:\repositorio\mi-proyecto" `
  -InstallGraphify `
  -IndexGraphify
```

La indexación predeterminada usa:

```powershell
graphify . --code-only
```

Esto evita requerir una API LLM para documentos e imágenes.

## Indexación manual

```powershell
.\graph.ps1 `
  -ProjectPath "C:\repositorio\mi-proyecto"
```

Forzar reconstrucción:

```powershell
.\graph.ps1 `
  -ProjectPath "C:\repositorio\mi-proyecto" `
  -Force
```

Incluir documentos:

```powershell
.\graph.ps1 `
  -ProjectPath "C:\repositorio\mi-proyecto" `
  -IncludeDocuments `
  -Backend ollama
```

Para documentos necesitarás un backend compatible y su configuración correspondiente.

## Actualización

```powershell
.\update.ps1 `
  -ProjectPath "C:\repositorio\mi-proyecto" `
  -UpdateGraphify `
  -ReindexGraphify
```

## Diagnóstico

```powershell
.\doctor.ps1 `
  -ProjectPath "C:\repositorio\mi-proyecto"
```

## Linux/macOS

```bash
INSTALL_GRAPHIFY=true INDEX_GRAPHIFY=true ./install.sh /ruta/al/proyecto
UPDATE_GRAPHIFY=true REINDEX_GRAPHIFY=true ./update.sh /ruta/al/proyecto
./doctor.sh /ruta/al/proyecto
```

## Seguridad

La plantilla `.graphifyignore` excluye secretos, dependencias, respaldos, bases de datos, archivos comprimidos y salidas generadas.

Revisa siempre la plantilla antes de indexar proyectos que contengan datos sensibles.
