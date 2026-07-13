# Documentación y diagramas como código

FACBGNTO Software Engineering incluye scripts para crear una estructura documental estándar y renderizar diagramas Mermaid.

## Documentación generada

```text
docs/
├── README.md
├── ARCHITECTURE.md
├── MODULES.md
├── DATABASE.md
├── API.md
├── SECURITY.md
├── TESTING.md
├── DEPLOYMENT.md
├── RUNBOOK.md
├── CHANGELOG.md
├── adr/
│   └── 0001-template.md
└── diagrams/
    ├── source/
    │   ├── system-context.mmd
    │   ├── containers.mmd
    │   ├── components.mmd
    │   ├── sequence-main-flow.mmd
    │   ├── deployment.mmd
    │   ├── data-flow.mmd
    │   └── entity-relationship.mmd
    └── generated/
```

## Crear la estructura

### Windows

```powershell
.\docs.ps1 `
  -ProjectPath "C:\repositorio\mi-proyecto"
```

### Linux/macOS

```bash
./docs.sh /ruta/al/proyecto
```

## Renderizar diagramas

### Windows

```powershell
.\diagrams.ps1 `
  -ProjectPath "C:\repositorio\mi-proyecto"
```

### Linux/macOS

```bash
./diagrams.sh /ruta/al/proyecto
```

Los archivos `.mmd` se convierten a SVG dentro de `docs/diagrams/generated`.

## Instalar Mermaid CLI

```powershell
npm install -g @mermaid-js/mermaid-cli
```

También puedes instalarlo con:

```powershell
.\install.ps1 `
  -ProjectPath "C:\repositorio\mi-proyecto" `
  -InstallDocumentationTools
```

## Formatos

```powershell
.\diagrams.ps1 `
  -ProjectPath "C:\repositorio\mi-proyecto" `
  -Format png
```

Formatos permitidos:

- `svg`
- `png`
- `pdf`

## Validación

```powershell
.\diagrams.ps1 `
  -ProjectPath "C:\repositorio\mi-proyecto" `
  -CheckOnly
```

Esto valida que Mermaid pueda procesar todos los diagramas sin conservar los archivos temporales.

## Diagramas que debe mantener el agente

Para cambios significativos, el agente debe actualizar los diagramas afectados:

| Cambio | Diagrama/documento |
|---|---|
| Nuevo sistema externo | Contexto |
| Nuevo frontend, backend o worker | Contenedores |
| Nuevo módulo importante | Componentes |
| Nuevo flujo crítico | Secuencia |
| Cambio de infraestructura | Despliegue |
| Cambio de tratamiento de datos | Flujo de datos |
| Cambio de tablas o relaciones | ER |
| Decisión arquitectónica | ADR |
| Cambio de API | API.md |
| Cambio operacional | RUNBOOK.md |

## Structurizr

Para proyectos grandes puede mantenerse un modelo C4 único en `docs/architecture/workspace.dsl`.

Structurizr permite crear varias vistas desde el mismo modelo. La plantilla se encuentra en:

```text
templates/diagrams/workspace.dsl
```

## SchemaSpy

Para documentación avanzada de bases de datos se recomienda SchemaSpy. Genera un sitio HTML navegable con tablas, columnas, relaciones y diagramas ER.

No almacenes contraseñas de base de datos en el repositorio.
