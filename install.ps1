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
    [switch]$InitializeSecurityReports,
    [string]$SecurityReportName,
    [switch]$InstallHeadroom,
    [switch]$InstallCaveman,
    [ValidateSet("codex", "claude", "cursor", "windsurf", "cline", "copilot", "gemini", "all")]
    [string]$Agent = "codex",
    [ValidateSet("lite", "full", "ultra")]
    [string]$CavemanLevel = "lite",
    [switch]$EnableHeadroomOutputShaper,
    [switch]$DryRun,
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$SourceRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ResolvedProject = [System.IO.Path]::GetFullPath($ProjectPath)
$MainSkillSource = Join-Path $SourceRoot "skills\facbgnto-software-engineering"
$SecuritySkillSource = Join-Path $SourceRoot "skills\facbgnto-security-review"
$SecurityStorageSkillSource = Join-Path $SourceRoot "skills\security-storage"

if (-not (Test-Path $ResolvedProject)) { throw "No existe el proyecto: $ResolvedProject" }
if (-not (Test-Path $MainSkillSource)) { throw "No se encontró el skill principal: $MainSkillSource" }

function Invoke-Step {
    param([string]$Description, [scriptblock]$Action)
    if ($DryRun) { Write-Host "[DRY-RUN] $Description" -ForegroundColor Cyan; return }
    & $Action
}

function Copy-Skill {
    param([string]$Source, [string]$Destination)
    if ((Test-Path $Destination) -and -not $Force) {
        Write-Host "Conservado: $Destination" -ForegroundColor DarkGray
        return
    }
    Invoke-Step "Copiar $Source -> $Destination" {
        if (Test-Path $Destination) { Remove-Item -Recurse -Force $Destination }
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Destination) | Out-Null
        Copy-Item -Recurse -Force $Source $Destination
    }
    Write-Host "Instalado: $Destination" -ForegroundColor Green
}

function Copy-TemplateFile {
    param([string]$Source, [string]$Destination)
    if ((Test-Path $Destination) -and -not $Force) {
        Write-Host "Conservado: $Destination" -ForegroundColor DarkGray
        return
    }
    Invoke-Step "Copiar $Source -> $Destination" {
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Destination) | Out-Null
        Copy-Item -Force $Source $Destination
    }
    Write-Host "Creado: $Destination" -ForegroundColor Green
}

function Require-Command {
    param([string]$Name, [string]$Message)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) { throw $Message }
}

foreach ($base in @(".agents\skills", ".claude\skills", ".cursor\skills")) {
    Copy-Skill -Source $MainSkillSource -Destination (Join-Path $ResolvedProject "$base\facbgnto-software-engineering")
}
Copy-TemplateFile -Source (Join-Path $MainSkillSource "templates\AGENTS.md") -Destination (Join-Path $ResolvedProject "AGENTS.md")

$ExternalRoot = Join-Path $SourceRoot ".external"
Invoke-Step "Crear $ExternalRoot" { New-Item -ItemType Directory -Force -Path $ExternalRoot | Out-Null }

if ($InstallSuperpowers) {
    Require-Command "git" "Git no está disponible."
    $path = Join-Path $ExternalRoot "superpowers"
    Invoke-Step "Instalar o actualizar Superpowers" {
        if (Test-Path (Join-Path $path ".git")) { git -C $path pull --ff-only }
        else { git clone https://github.com/obra/superpowers.git $path }
    }
}

if ($InstallAgentSkills) {
    Require-Command "git" "Git no está disponible."
    $path = Join-Path $ExternalRoot "agent-skills"
    Invoke-Step "Instalar o actualizar Agent Skills" {
        if (Test-Path (Join-Path $path ".git")) { git -C $path pull --ff-only }
        else { git clone https://github.com/addyosmani/agent-skills.git $path }
    }
}

if ($InstallUIUXProMax) {
    Require-Command "npm" "npm no está disponible. Instala Node.js."
    Invoke-Step "Instalar UI/UX Pro Max" { npm install -g uipro-cli@latest }
    if (-not $DryRun) {
        Push-Location $ResolvedProject
        try {
            foreach ($targetAgent in @("codex", "claude", "cursor")) {
                & uipro init --ai $targetAgent
                if ($LASTEXITCODE -ne 0) { throw "Falló UI/UX Pro Max para $targetAgent." }
            }
        } finally { Pop-Location }
    }
}

if ($InstallEverythingClaudeCodeZH) {
    Require-Command "git" "Git no está disponible."
    $path = Join-Path $ExternalRoot "everything-claude-code-zh"
    Invoke-Step "Instalar o actualizar Everything Claude Code ZH" {
        if (Test-Path (Join-Path $path ".git")) { git -C $path pull --ff-only }
        else { git clone https://github.com/xu-xiang/everything-claude-code-zh.git $path }
    }
}

if ($InstallLightRAG) {
    Require-Command "git" "Git no está disponible."
    $path = Join-Path $ExternalRoot "LightRAG"
    Invoke-Step "Instalar o actualizar LightRAG" {
        if (Test-Path (Join-Path $path ".git")) { git -C $path pull --ff-only }
        else { git clone https://github.com/HKUDS/LightRAG.git $path }
    }
    Copy-Skill -Source (Join-Path $SourceRoot "integrations\lightrag") -Destination (Join-Path $ResolvedProject "tools\lightrag")
}

if ($InstallGraphify) {
    Require-Command "uv" "uv no está instalado. Instálalo antes de Graphify."
    Invoke-Step "Instalar o actualizar Graphify" {
        if (Get-Command graphify -ErrorAction SilentlyContinue) { uv tool upgrade graphifyy }
        else { uv tool install graphifyy }
        if ($LASTEXITCODE -ne 0) { throw "No fue posible instalar o actualizar Graphify." }
    }
    Copy-TemplateFile -Source (Join-Path $SourceRoot "templates\.graphifyignore") -Destination (Join-Path $ResolvedProject ".graphifyignore")
}

if ($IndexGraphify) {
    if (-not $DryRun -and -not (Get-Command graphify -ErrorAction SilentlyContinue)) { throw "Graphify no está disponible." }
    Invoke-Step "Indexar proyecto con Graphify" { & (Join-Path $SourceRoot "graph.ps1") -ProjectPath $ResolvedProject -Force:$Force }
}

if ($InstallDocumentationTools) {
    Require-Command "npm" "npm no está disponible. Instala Node.js."
    Invoke-Step "Instalar Mermaid CLI" { npm install -g @mermaid-js/mermaid-cli@latest }
}
if ($InitializeDocumentation) {
    Invoke-Step "Inicializar documentación" { & (Join-Path $SourceRoot "docs.ps1") -ProjectPath $ResolvedProject -RenderDiagrams:$InstallDocumentationTools -Force:$Force }
}

if ($InstallSecurity) {
    if (-not (Test-Path $SecuritySkillSource)) { throw "No se encontró el skill de seguridad: $SecuritySkillSource" }
    if (-not (Test-Path $SecurityStorageSkillSource)) { throw "No se encontro el skill de storage seguro: $SecurityStorageSkillSource" }
    foreach ($base in @(".agents\skills", ".claude\skills", ".cursor\skills")) {
        Copy-Skill -Source $SecuritySkillSource -Destination (Join-Path $ResolvedProject "$base\facbgnto-security-review")
        Copy-Skill -Source $SecurityStorageSkillSource -Destination (Join-Path $ResolvedProject "$base\security-storage")
    }
    Copy-TemplateFile -Source (Join-Path $SourceRoot "templates\security\.gitleaks.toml") -Destination (Join-Path $ResolvedProject ".gitleaks.toml")
    Copy-TemplateFile -Source (Join-Path $SourceRoot "templates\security\.semgrep.yml") -Destination (Join-Path $ResolvedProject ".semgrep.yml")
    Copy-TemplateFile -Source (Join-Path $SourceRoot "templates\security\SECURITY.md") -Destination (Join-Path $ResolvedProject "SECURITY.md")
    Invoke-Step "Crear directorios de reportes" {
        New-Item -ItemType Directory -Force -Path (Join-Path $ResolvedProject "reports\agent-activity") | Out-Null
        New-Item -ItemType Directory -Force -Path (Join-Path $ResolvedProject "reports\security") | Out-Null
    }
}
if ($InstallSecurityWorkflow) {
    Copy-TemplateFile -Source (Join-Path $SourceRoot "templates\github\workflows\security.yml") -Destination (Join-Path $ResolvedProject ".github\workflows\security.yml")
}
if ($InitializeSecurityReports) {
    $args = @{ ProjectPath = $ResolvedProject; Force = $Force }
    if ($SecurityReportName) { $args.ReportName = $SecurityReportName }
    Invoke-Step "Inicializar reportes de seguridad" { & (Join-Path $SourceRoot "security-report.ps1") @args }
}

if ($InstallHeadroom) {
    & (Join-Path $SourceRoot "integrations\headroom\install-headroom.ps1") -ProjectPath $ResolvedProject -Agent $Agent -EnableOutputShaper:$EnableHeadroomOutputShaper -DryRun:$DryRun -Force:$Force
}
if ($InstallCaveman) {
    & (Join-Path $SourceRoot "integrations\caveman\install-caveman.ps1") -ProjectPath $ResolvedProject -Agent $Agent -Level $CavemanLevel -DryRun:$DryRun -Force:$Force
}

Write-Host ""
Write-Host "Instalación completada en: $ResolvedProject" -ForegroundColor Green
Write-Host "Ejecuta doctor.ps1 -ProjectPath `"$ResolvedProject`" para comprobar la instalación."
