param(
    [string]$ProjectPath,

    [switch]$UpdateDeportivox,
    [string]$DeportivoxPath = "C:\repositorio\deportivox 2",

    [switch]$UpdateExternalTools,
    [switch]$UpdateGraphify,
    [switch]$ReindexGraphify,
    [switch]$UpdateDocumentationTools,
    [switch]$RegenerateDocumentation,
    [switch]$UpdateSecurity,
    [switch]$UpdateSecurityWorkflow,
    [switch]$InitializeSecurityReports,
    [string]$SecurityReportName,

    [switch]$SkipGitPull,
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

function Invoke-GitUpdate {
    param([string]$RepositoryPath)

    if (-not (Test-Path (Join-Path $RepositoryPath ".git"))) {
        Write-Host "No es un repositorio Git: $RepositoryPath" -ForegroundColor Yellow
        return
    }

    git -C $RepositoryPath fetch --all --prune

    if ($LASTEXITCODE -ne 0) {
        throw "Falló git fetch en $RepositoryPath"
    }

    git -C $RepositoryPath pull --ff-only

    if ($LASTEXITCODE -ne 0) {
        throw "Falló git pull --ff-only en $RepositoryPath"
    }
}

if (-not $SkipGitPull) {
    Write-Host "Actualizando FACBGNTO Software Engineering..." -ForegroundColor Cyan
    Invoke-GitUpdate -RepositoryPath $Root
}

if ($UpdateExternalTools) {
    $ExternalRoot = Join-Path $Root ".external"

    $Repositories = @{
        "superpowers"               = "https://github.com/obra/superpowers.git"
        "agent-skills"              = "https://github.com/addyosmani/agent-skills.git"
        "LightRAG"                  = "https://github.com/HKUDS/LightRAG.git"
        "everything-claude-code-zh" = "https://github.com/xu-xiang/everything-claude-code-zh.git"
    }

    New-Item -ItemType Directory -Force -Path $ExternalRoot | Out-Null

    foreach ($Name in $Repositories.Keys) {
        $Path = Join-Path $ExternalRoot $Name
        $Url = $Repositories[$Name]

        if (Test-Path (Join-Path $Path ".git")) {
            Write-Host "Actualizando $Name..." -ForegroundColor Cyan
            Invoke-GitUpdate -RepositoryPath $Path
        }
        else {
            Write-Host "Clonando $Name..." -ForegroundColor Cyan
            git clone $Url $Path

            if ($LASTEXITCODE -ne 0) {
                throw "No fue posible clonar $Name."
            }
        }
    }

    if (Get-Command npm -ErrorAction SilentlyContinue) {
        npm install -g uipro-cli@latest
    }
    else {
        Write-Host "npm no está disponible; UI/UX Pro Max no fue actualizado." -ForegroundColor Yellow
    }
}

if ($UpdateGraphify) {
    if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
        throw "uv no está instalado; no se puede actualizar Graphify."
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
}

if ($UpdateDocumentationTools) {
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        throw "npm no está disponible; no se puede actualizar Mermaid CLI."
    }

    npm install -g @mermaid-js/mermaid-cli@latest

    if ($LASTEXITCODE -ne 0) {
        throw "No fue posible actualizar Mermaid CLI."
    }
}

$TargetProject = $ProjectPath

if ($UpdateDeportivox) {
    if ($ProjectPath) {
        Write-Host "Se usará -ProjectPath en lugar de -DeportivoxPath." -ForegroundColor Yellow
    }
    else {
        $TargetProject = $DeportivoxPath
    }
}

if ($TargetProject) {
    $ResolvedTarget = [System.IO.Path]::GetFullPath($TargetProject)

    if (-not (Test-Path $ResolvedTarget)) {
        throw "No existe el proyecto destino: $ResolvedTarget"
    }

    Write-Host "Actualizando assets en: $ResolvedTarget" -ForegroundColor Cyan
    Write-Host "No se modificarán repositorios internos ni submódulos." -ForegroundColor DarkGray

    $InstallArguments = @{
        ProjectPath = $ResolvedTarget
        Force = $true
    }

    if ($UpdateSecurity -or $UpdateDeportivox) {
        $InstallArguments.InstallSecurity = $true
    }

    if ($UpdateSecurityWorkflow -or $UpdateDeportivox) {
        $InstallArguments.InstallSecurityWorkflow = $true
    }

    if ($InitializeSecurityReports) {
        $InstallArguments.InitializeSecurityReports = $true

        if ($SecurityReportName) {
            $InstallArguments.SecurityReportName = $SecurityReportName
        }
    }

    & (Join-Path $Root "install.ps1") @InstallArguments
}

if ($ReindexGraphify) {
    if (-not $TargetProject) {
        throw "-ReindexGraphify requiere -ProjectPath o -UpdateDeportivox."
    }

    & (Join-Path $Root "graph.ps1") `
        -ProjectPath $TargetProject `
        -Force:$Force
}

if ($RegenerateDocumentation) {
    if (-not $TargetProject) {
        throw "-RegenerateDocumentation requiere -ProjectPath o -UpdateDeportivox."
    }

    & (Join-Path $Root "docs.ps1") `
        -ProjectPath $TargetProject

    & (Join-Path $Root "diagrams.ps1") `
        -ProjectPath $TargetProject `
        -Force
}

Write-Host ""
Write-Host "Actualización completada." -ForegroundColor Green
