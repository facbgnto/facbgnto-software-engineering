<div align="center">

# 🚀 FACBGNTO Software Engineering

### Kit reutilizable de ingeniería de software para agentes de IA

Analiza el proyecto, comprende su arquitectura, planifica cambios, implementa incrementalmente, ejecuta pruebas y verifica resultados antes de finalizar.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![PowerShell](https://img.shields.io/badge/Windows-PowerShell-5391FE)
![Linux](https://img.shields.io/badge/Linux-Bash-FCC624)
![AI Agents](https://img.shields.io/badge/AI-Codex%20%7C%20Claude%20%7C%20Cursor-7C3AED)

</div>

---

## ✨ ¿Qué incluye?

Este repositorio instala un skill coordinador compatible con agentes de programación y agrega integraciones opcionales para mejorar el análisis, diseño, documentación y calidad del software.

| Herramienta | Función |
|---|---|
| **FACBGNTO Software Engineering** | Skill coordinador principal |
| **AGENTS.md** | Reglas persistentes específicas del proyecto |
| **Graphify** | Análisis estructural y relaciones del código |
| **LightRAG** | Base de conocimiento semántico y documental |
| **Superpowers** | Especificación, planificación, TDD y depuración |
| **Agent Skills** | Skills especializados para diferentes tareas |
| **UI/UX Pro Max** | Diseño, accesibilidad y experiencia de usuario |
| **Everything Claude Code ZH** | Catálogo opcional de agentes, reglas y skills |

---

## 🎯 Flujo de trabajo

```text
REQUERIMIENTO
      │
      ▼
DESCUBRIMIENTO
      │
      ├── AGENTS.md
      ├── documentación
      ├── arquitectura
      └── código existente
      │
      ▼
ANÁLISIS
      │
      ├── Graphify
      └── LightRAG
      │
      ▼
ESPECIFICACIÓN
      │
      ▼
PLAN DE IMPLEMENTACIÓN
      │
      ▼
IMPLEMENTACIÓN INCREMENTAL
      │
      ▼
PRUEBAS Y SEGURIDAD
      │
      ▼
REVISIÓN DEL DIFF
      │
      ▼
ENTREGA CON EVIDENCIA
```

---

## 📦 Estructura

```text
facbgnto-software-engineering/
├── README.md
├── LICENSE
├── .gitignore
├── install.ps1
├── install.sh
├── update.ps1
├── update.sh
├── skills/
│   └── facbgnto-software-engineering/
│       ├── SKILL.md
│       ├── references/
│       │   └── security-checklist.md
│       └── templates/
│           ├── AGENTS.md
│           ├── SPEC.md
│           └── PLAN.md
└── integrations/
    ├── README.md
    ├── graphify-and-lightrag.md
    ├── ui-ux-pro-max.md
    ├── everything-claude-code-zh.md
    └── lightrag/
        ├── README.md
        ├── .env.example
        └── .gitignore
```

---

## 📋 Requisitos recomendados

- Git
- Node.js 20 o superior
- npm
- Python 3.10 o superior
- PowerShell 7+ en Windows
- Bash en Linux/macOS

Para algunas integraciones también pueden ser necesarios:

- `uv`
- Ollama
- Docker
- Docker Compose

---

# 🚀 Instalación

## Windows

### 1. Clonar el repositorio

```powershell
git clone https://github.com/facbgnto/facbgnto-software-engineering.git
cd facbgnto-software-engineering
```

### 2. Instalar solo el skill principal

```powershell
.\install.ps1 `
  -ProjectPath "C:\repositorio\mi-proyecto"
```

### 3. Instalación completa

```powershell
.\install.ps1 `
  -ProjectPath "C:\repositorio\mi-proyecto" `
  -InstallSuperpowers `
  -InstallAgentSkills `
  -InstallUIUXProMax `
  -InstallEverythingClaudeCodeZH `
  -InstallLightRAG
```

### 4. Reemplazar una instalación existente

```powershell
.\install.ps1 `
  -ProjectPath "C:\repositorio\mi-proyecto" `
  -Force
```

---

## Linux / macOS

```bash
git clone https://github.com/facbgnto/facbgnto-software-engineering.git
cd facbgnto-software-engineering

chmod +x install.sh update.sh
./install.sh /ruta/al/proyecto
```

Para reemplazar archivos existentes:

```bash
FORCE=true ./install.sh /ruta/al/proyecto
```

---

# 🔄 Actualizar los skills

El repositorio incluye comandos para actualizar:

- el kit principal desde GitHub;
- el skill instalado en cada proyecto;
- Superpowers;
- Agent Skills;
- LightRAG;
- Everything Claude Code ZH;
- UI/UX Pro Max CLI.

## Windows

### Actualizar todo y reinstalar en un proyecto

```powershell
.\update.ps1 `
  -ProjectPath "C:\repositorio\mi-proyecto" `
  -UpdateExternalTools
```

### Actualizar solo el repositorio local

```powershell
.\update.ps1
```

### Actualizar y forzar reemplazo del skill

```powershell
.\update.ps1 `
  -ProjectPath "C:\repositorio\mi-proyecto" `
  -UpdateExternalTools `
  -Force
```

### Omitir actualización del repositorio principal

```powershell
.\update.ps1 `
  -ProjectPath "C:\repositorio\mi-proyecto" `
  -SkipGitPull
```

---

## Linux / macOS

Actualizar el kit y reinstalar:

```bash
./update.sh /ruta/al/proyecto
```

Actualizar también herramientas externas:

```bash
UPDATE_EXTERNAL_TOOLS=true ./update.sh /ruta/al/proyecto
```

Forzar reemplazo:

```bash
FORCE=true UPDATE_EXTERNAL_TOOLS=true ./update.sh /ruta/al/proyecto
```

---

# 📂 Resultado dentro del proyecto

```text
mi-proyecto/
├── AGENTS.md
├── .agents/
│   └── skills/
│       └── facbgnto-software-engineering/
├── .claude/
│   └── skills/
│       └── facbgnto-software-engineering/
├── .cursor/
│   └── skills/
│       └── facbgnto-software-engineering/
└── tools/
    └── lightrag/
```

---

# 🧑‍💻 Uso con el agente

Prompt básico:

```text
Usa el skill facbgnto-software-engineering para implementar este requerimiento.
```

Prompt recomendado para tareas grandes:

```text
Usa facbgnto-software-engineering.

Lee AGENTS.md y la documentación del proyecto.

Consulta Graphify para localizar el código relacionado.

Consulta LightRAG si existe documentación indexada.

Crea una especificación y un plan antes de modificar código.

Implementa incrementalmente.

Ejecuta pruebas, build, lint y typecheck disponibles.

Revisa seguridad y el diff completo.

No afirmes que funciona sin mostrar las validaciones realizadas.
```

---

# 🕸 Graphify

Graphify ayuda a localizar:

- archivos;
- funciones;
- clases;
- dependencias;
- controladores;
- servicios;
- modelos;
- rutas;
- impacto probable de una modificación.

Ejemplo:

```powershell
graphify . --code-only
```

Graphify es una ayuda de navegación. Sus resultados siempre deben confirmarse leyendo el código fuente.

---

# 🧠 LightRAG

LightRAG puede indexar:

- arquitectura;
- especificaciones;
- documentación técnica;
- reglas de negocio;
- decisiones técnicas;
- documentación de API;
- manuales;
- diccionarios de datos.

No deben indexarse:

```text
.env
tokens
credenciales
datos personales
backups productivos
logs sensibles
node_modules
archivos generados
```

---

# 🎨 UI/UX Pro Max

Instalación manual:

```powershell
npm install -g uipro-cli
```

Inicialización por agente:

```powershell
uipro init --ai codex
uipro init --ai claude
uipro init --ai cursor
```

Se recomienda para:

- dashboards;
- formularios;
- sistemas de diseño;
- diseño responsive;
- accesibilidad;
- consistencia visual;
- revisión de anti-patrones UI/UX.

---

# 🔐 Seguridad

El skill incluye una checklist para revisar:

- autenticación;
- autorización;
- aislamiento multi-tenant;
- SQL Injection;
- XSS;
- CSRF;
- SSRF;
- subida de archivos;
- secretos;
- logs;
- rate limiting;
- datos personales;
- dependencias.

---

# 🧪 Verificación obligatoria

Antes de finalizar una tarea significativa, el agente debe revisar:

```text
TEST
BUILD
LINT
TYPECHECK
SECURITY REVIEW
DIFF REVIEW
ACCEPTANCE CRITERIA
```

No debe afirmar que todo funciona sin indicar los comandos ejecutados y sus resultados.

---

# 🛣 Roadmap

- CLI global `facbgnto`
- detección automática del stack;
- generación dinámica de `AGENTS.md`;
- perfiles React + Node + PostgreSQL;
- perfiles Java + Spring Boot;
- perfiles Python;
- actualización selectiva de skills;
- integración con Ollama;
- comandos de auditoría;
- soporte CI/CD;
- servidor LightRAG compartido.

---

# 📄 Licencia

Este proyecto utiliza licencia MIT.

Las herramientas externas mantienen sus propias licencias y repositorios oficiales. Este proyecto no redistribuye automáticamente el contenido completo de terceros.

---

<div align="center">

Desarrollado por **FACBGNTO**

⭐ Marca el repositorio con una estrella si te resulta útil.

</div>
