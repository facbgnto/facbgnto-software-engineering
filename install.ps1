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
    [switch]$InstallSecurity,
    [switch]$InstallSecurityWorkflow,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$SourceRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ResolvedProject = [System.IO.Path]::GetFullPath($ProjectPath)
$MainSkillSource = Join-Path $SourceRoot "skills\facbgnto-software-engineering"
$SecuritySkillSource = Join-Path $SourceRoot "skills\facbgnto-security-review"

if (-not (Test-Path $ResolvedProject)) {
    throw "No existe el proyecto: $ResolvedProject"
}

if (-not (Test-Path $MainSkillSource)) {
    throw "No se encontró el skill principal: $MainSkillSource"
}

function Copy-Skill {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Source,

        [Parameter(Mandatory = $true)]
        [string]$Destination
    )

    if ((Test-Path $Destination) -and -not $Force) {
        Write-Host "Ya existe: $Destination (usa -Force para reemplazar)" -ForegroundColor Yellow
        return
    }

    if (Test-Path $Destination) {
        Remove-Item -Recurse -Force $Destination
    }

    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Destination) | Out-Null
    Copy-Item -Recurse -Force $Source $Destination
    Write-Host "Instalado: $Destination" -ForegroundColor Green
}

function Copy-TemplateFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Source,

        [Parameter(Mandatory = $true)]
        [string]$Destination
    )

    if ((Test-Path $Destination) -and -not $Force) {
        Write-Host "Conservado: $Destination" -ForegroundColor DarkGray
        return
    }

    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Destination) | Out-Null
    Copy-Item -Force $Source $Destination
    Write-Host "Creado: $Destination" -ForegroundColor Green
}

foreach ($base in @(".agents\skills", ".claude\skills", ".cursor\skills")) {
    Copy-Skill `
        -Source $MainSkillSource `
        -Destination (Join-Path $ResolvedProject "$base\facbgnto-software-engineering")
}

Copy-TemplateFile `
    -Source (Join-Path $MainSkillSource "templates\AGENTS.md") `
    -Destination (Join-Path $ResolvedProject "AGENTS.md")

$ExternalRoot = Join-Path $SourceRoot ".external"
New-Item -ItemType Directory -Force -Path $ExternalRoot | Out-Null

if ($InstallSuperpowers) {
    $path = Join-Path $ExternalRoot "superpowers"
    if (Test-Path (Join-Path $path ".git")) {
        git -C $path pull --ff-only
    }
    else {
        git clone https://github.com/obra/superpowers.git $path
    }
}

if ($InstallAgentSkills) {
    $path = Join-Path $ExternalRoot "agent-skills"
    if (Test-Path (Join-Path $path ".git")) {
        git -C $path pull --ff-only
    }
    else {
        git clone https://github.com/addyosmani/agent-skills.git $path
    }
}

if ($InstallUIUXProMax) {
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        throw "npm no está disponible. Instala Node.js."
    }

    npm install -g uipro-cli@latest

    Push-Location $ResolvedProject
    try {
        foreach ($agent in @("codex", "claude", "cursor")) {
            & uipro init --ai $agent
            if ($LASTEXITCODE -ne 0) {
                throw "Falló UI/UX Pro Max para $agent."
            }
        }
    }
    finally {
        Pop-Location
    }
}

if ($InstallEverythingClaudeCodeZH) {
    $path = Join-Path $ExternalRoot "everything-claude-code-zh"
    if (Test-Path (Join-Path $path ".git")) {
        git -C $path pull --ff-only
    }
    else {
        git clone https://github.com/xu-xiang/everything-claude-code-zh.git $path
    }

    Write-Host "Descargado en $path. Selecciona componentes para evitar reglas duplicadas." -ForegroundColor Yellow
}

if ($InstallLightRAG) {
    $path = Join-Path $ExternalRoot "LightRAG"
    if (Test-Path (Join-Path $path ".git")) {
        git -C $path pull --ff-only
    }
    else {
        git clone https://github.com/HKUDS/LightRAG.git $path
    }

    $destination = Join-Path $ResolvedProject "tools\lightrag"
    if ((Test-Path $destination) -and -not $Force) {
        Write-Host "Conservado: $destination" -ForegroundColor DarkGray
    }
    else {
        if (Test-Path $destination) {
            Remove-Item -Recurse -Force $destination
        }

        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
        Copy-Item -Recurse -Force (Join-Path $SourceRoot "integrations\lightrag") $destination
    }
}

if ($InstallGraphify) {
    if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
        throw "uv no está instalado. Instálalo antes de Graphify."
    }

    if (Get-Command graphify -ErrorAction SilentlyContinue) {
        uv tool upgrade graphifyy
    }
    else {
        uv tool install graphifyy
    }

    if ($LASTEXITCODE -ne 0) {
        throw "No fue posible instalar o actualizar Graphify."
    }

    Copy-TemplateFile `
        -Source (Join-Path $SourceRoot "templates\.graphifyignore") `
        -Destination (Join-Path $ResolvedProject ".graphifyignore")
}

if ($IndexGraphify) {
    if (-not (Get-Command graphify -ErrorAction SilentlyContinue)) {
        throw "Graphify no está disponible. Usa -InstallGraphify."
    }

    & (Join-Path $SourceRoot "graph.ps1") `
        -ProjectPath $ResolvedProject `
        -Force:$Force
}

if ($InstallDocumentationTools) {
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        throw "npm no está disponible. Instala Node.js."
    }

    npm install -g @mermaid-js/mermaid-cli@latest
    if ($LASTEXITCODE -ne 0) {
        throw "No fue posible instalar Mermaid CLI."
    }
}

if ($InitializeDocumentation) {
    & (Join-Path $SourceRoot "docs.ps1") `
        -ProjectPath $ResolvedProject `
        -RenderDiagrams:$InstallDocumentationTools `
        -Force:$Force
}

if ($InstallSecurity) {
    if (-not (Test-Path $SecuritySkillSource)) {
        throw "No se encontró el skill de seguridad: $SecuritySkillSource"
    }

    foreach ($base in @(".agents\skills", ".claude\skills", ".cursor\skills")) {
        Copy-Skill `
            -Source $SecuritySkillSource `
            -Destination (Join-Path $ResolvedProject "$base\facbgnto-security-review")
    }

    Copy-TemplateFile `
        -Source (Join-Path $SourceRoot "templates\security\.gitleaks.toml") `
        -Destination (Join-Path $ResolvedProject ".gitleaks.toml")

    Copy-TemplateFile `
        -Source (Join-Path $SourceRoot "templates\security\.semgrep.yml") `
        -Destination (Join-Path $ResolvedProject ".semgrep.yml")

    Copy-TemplateFile `
        -Source (Join-Path $SourceRoot "templates\security\SECURITY.md") `
        -Destination (Join-Path $ResolvedProject "SECURITY.md")

    New-Item -ItemType Directory -Force `
        -Path (Join-Path $ResolvedProject "reports\agent-activity") | Out-Null

    New-Item -ItemType Directory -Force `
        -Path (Join-Path $ResolvedProject "reports\security") | Out-Null
}

if ($InstallSecurityWorkflow) {
    Copy-TemplateFile `
        -Source (Join-Path $SourceRoot "templates\github\workflows\security.yml") `
        -Destination (Join-Path $ResolvedProject ".github\workflows\security.yml")
}

Write-Host ""
Write-Host "Instalación completada en: $ResolvedProject" -ForegroundColor Green
Write-Host "Ejecuta doctor.ps1 para comprobar la instalación."
