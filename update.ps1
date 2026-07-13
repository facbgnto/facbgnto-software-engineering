param(
    [string]$ProjectPath,
    [switch]$UpdateExternalTools,
    [switch]$UpdateGraphify,
    [switch]$ReindexGraphify,
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
    git -C $RepositoryPath pull --ff-only
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
        }
    }

    if (Get-Command npm -ErrorAction SilentlyContinue) {
        Write-Host "Actualizando UI/UX Pro Max CLI..." -ForegroundColor Cyan
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
}

if ($ProjectPath) {
    $InstallScript = Join-Path $Root "install.ps1"
    $Arguments = @{
        ProjectPath = $ProjectPath
        Force = $true
    }

    Write-Host "Reinstalando skill en $ProjectPath..." -ForegroundColor Cyan
    & $InstallScript @Arguments
}


if ($ReindexGraphify) {
    if (-not $ProjectPath) {
        throw "-ReindexGraphify requiere -ProjectPath."
    }

    $GraphScript = Join-Path $Root "graph.ps1"
    & $GraphScript -ProjectPath $ProjectPath -Force:$Force
}

Write-Host ""
Write-Host "Actualización completada." -ForegroundColor Green
