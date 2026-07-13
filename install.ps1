param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath,

    [switch]$InstallSuperpowers,
    [switch]$InstallAgentSkills,
    [switch]$InstallUIUXProMax,
    [switch]$InstallEverythingClaudeCodeZH,
    [switch]$InstallLightRAG,
    [switch]$InstallGraphify,
    [switch]$IndexGraphify,
    [switch]$InstallDocumentationTools,
    [switch]$InitializeDocumentation,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$SourceRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillSource = Join-Path $SourceRoot "skills\facbgnto-software-engineering"
$ResolvedProject = [System.IO.Path]::GetFullPath($ProjectPath)

if (-not (Test-Path $ResolvedProject)) {
    throw "No existe el proyecto: $ResolvedProject"
}

if (-not (Test-Path $SkillSource)) {
    throw "No se encontró el skill fuente: $SkillSource"
}

function Copy-Skill {
    param([string]$Destination)

    if ((Test-Path $Destination) -and -not $Force) {
        Write-Host "Ya existe: $Destination (usa -Force para reemplazar)" -ForegroundColor Yellow
        return
    }

    if (Test-Path $Destination) {
        Remove-Item -Recurse -Force $Destination
    }

    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Destination) | Out-Null
    Copy-Item -Recurse -Force $SkillSource $Destination
    Write-Host "Instalado: $Destination" -ForegroundColor Green
}

Copy-Skill (Join-Path $ResolvedProject ".agents\skills\facbgnto-software-engineering")
Copy-Skill (Join-Path $ResolvedProject ".claude\skills\facbgnto-software-engineering")
Copy-Skill (Join-Path $ResolvedProject ".cursor\skills\facbgnto-software-engineering")

$AgentsTemplate = Join-Path $SkillSource "templates\AGENTS.md"
$AgentsDestination = Join-Path $ResolvedProject "AGENTS.md"

if (-not (Test-Path $AgentsDestination) -or $Force) {
    Copy-Item -Force $AgentsTemplate $AgentsDestination
    Write-Host "Creado: $AgentsDestination" -ForegroundColor Green
}
else {
    Write-Host "AGENTS.md ya existe; no fue reemplazado." -ForegroundColor Yellow
}

$ExternalRoot = Join-Path $SourceRoot ".external"
New-Item -ItemType Directory -Force -Path $ExternalRoot | Out-Null

if ($InstallSuperpowers) {
    $SuperpowersPath = Join-Path $ExternalRoot "superpowers"
    if (Test-Path $SuperpowersPath) {
        git -C $SuperpowersPath pull
    }
    else {
        git clone https://github.com/obra/superpowers.git $SuperpowersPath
    }
    Write-Host "Superpowers descargado en $SuperpowersPath. Sigue su instalador oficial para tu agente." -ForegroundColor Cyan
}

if ($InstallAgentSkills) {
    $AgentSkillsPath = Join-Path $ExternalRoot "agent-skills"
    if (Test-Path $AgentSkillsPath) {
        git -C $AgentSkillsPath pull
    }
    else {
        git clone https://github.com/addyosmani/agent-skills.git $AgentSkillsPath
    }
    Write-Host "Agent Skills descargado en $AgentSkillsPath." -ForegroundColor Cyan
}


if ($InstallUIUXProMax) {
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        throw "npm no está disponible. Instala Node.js antes de instalar UI/UX Pro Max."
    }

    npm install -g uipro-cli

    Push-Location $ResolvedProject
    try {
        uipro init --ai codex
        uipro init --ai claude
        uipro init --ai cursor
    }
    finally {
        Pop-Location
    }

    Write-Host "UI/UX Pro Max instalado para Codex, Claude y Cursor." -ForegroundColor Cyan
}

if ($InstallEverythingClaudeCodeZH) {
    $EverythingClaudePath = Join-Path $ExternalRoot "everything-claude-code-zh"

    if (Test-Path $EverythingClaudePath) {
        git -C $EverythingClaudePath pull
    }
    else {
        git clone https://github.com/xu-xiang/everything-claude-code-zh.git $EverythingClaudePath
    }

    Write-Host "Everything Claude Code ZH descargado en $EverythingClaudePath." -ForegroundColor Cyan
    Write-Host "No se copió automáticamente al proyecto para evitar conflictos con AGENTS.md, Superpowers y otros skills." -ForegroundColor Yellow
    Write-Host "Consulta integrations/everything-claude-code-zh.md para una instalación selectiva." -ForegroundColor Yellow
}

if ($InstallLightRAG) {
    $LightRAGPath = Join-Path $ExternalRoot "LightRAG"

    if (Test-Path $LightRAGPath) {
        git -C $LightRAGPath pull
    }
    else {
        git clone https://github.com/HKUDS/LightRAG.git $LightRAGPath
    }

    $LightRAGTemplateSource = Join-Path $SourceRoot "integrations\lightrag"
    $LightRAGTemplateDestination = Join-Path $ResolvedProject "tools\lightrag"

    if ((Test-Path $LightRAGTemplateDestination) -and -not $Force) {
        Write-Host "Ya existe $LightRAGTemplateDestination; no se reemplazó." -ForegroundColor Yellow
    }
    else {
        if (Test-Path $LightRAGTemplateDestination) {
            Remove-Item -Recurse -Force $LightRAGTemplateDestination
        }
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $LightRAGTemplateDestination) | Out-Null
        Copy-Item -Recurse -Force $LightRAGTemplateSource $LightRAGTemplateDestination
    }

    Write-Host "LightRAG descargado y plantilla creada en tools\lightrag." -ForegroundColor Cyan
}


if ($InstallGraphify) {
    if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
        throw "uv no está instalado. Instálalo desde https://docs.astral.sh/uv/ y vuelve a ejecutar."
    }

    if (Get-Command graphify -ErrorAction SilentlyContinue) {
        Write-Host "Actualizando Graphify..." -ForegroundColor Cyan
        uv tool upgrade graphifyy
    }
    else {
        Write-Host "Instalando Graphify..." -ForegroundColor Cyan
        uv tool install graphifyy
    }

    $GraphifyIgnoreSource = Join-Path $SourceRoot "templates\.graphifyignore"
    $GraphifyIgnoreDestination = Join-Path $ResolvedProject ".graphifyignore"

    if (-not (Test-Path $GraphifyIgnoreDestination) -or $Force) {
        Copy-Item -Force $GraphifyIgnoreSource $GraphifyIgnoreDestination
        Write-Host "Creado: $GraphifyIgnoreDestination" -ForegroundColor Green
    }
}

if ($IndexGraphify) {
    if (-not (Get-Command graphify -ErrorAction SilentlyContinue)) {
        throw "Graphify no está disponible. Usa también -InstallGraphify."
    }

    $GraphScript = Join-Path $SourceRoot "graph.ps1"
    & $GraphScript -ProjectPath $ResolvedProject -Force:$Force
}


if ($InstallDocumentationTools) {
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        throw "npm no está disponible. Instala Node.js antes de instalar Mermaid CLI."
    }

    Write-Host "Instalando o actualizando Mermaid CLI..." -ForegroundColor Cyan
    npm install -g @mermaid-js/mermaid-cli@latest
}

if ($InitializeDocumentation) {
    $DocsScript = Join-Path $SourceRoot "docs.ps1"
    & $DocsScript -ProjectPath $ResolvedProject -RenderDiagrams:$InstallDocumentationTools
}

Write-Host ""
Write-Host "Instalación completada en: $ResolvedProject" -ForegroundColor Green
Write-Host "Prueba: Usa el skill facbgnto-software-engineering para revisar este proyecto."
