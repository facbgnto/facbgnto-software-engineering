param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath,

    [switch]$Force,
    [switch]$IncludeDocuments,
    [string]$Backend,
    [switch]$SkipIgnoreTemplate
)

$ErrorActionPreference = "Stop"

function Assert-Command {
    param([string]$Name, [string]$Help)

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "No se encontró '$Name'. $Help"
    }
}

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$ResolvedProject = [System.IO.Path]::GetFullPath($ProjectPath)

if (-not (Test-Path $ResolvedProject)) {
    throw "No existe el proyecto: $ResolvedProject"
}

Assert-Command -Name "graphify" -Help "Ejecuta install.ps1 -InstallGraphify o instala graphifyy con uv."

$IgnoreDestination = Join-Path $ResolvedProject ".graphifyignore"
$IgnoreTemplate = Join-Path $Root "templates\.graphifyignore"

if (-not $SkipIgnoreTemplate -and -not (Test-Path $IgnoreDestination)) {
    Copy-Item -Force $IgnoreTemplate $IgnoreDestination
    Write-Host "Creado: $IgnoreDestination" -ForegroundColor Green
}

$Arguments = @(".")

if (-not $IncludeDocuments) {
    $Arguments += "--code-only"
}

if ($Force) {
    $Arguments += "--force"
}

if ($Backend) {
    $Arguments += @("--backend", $Backend)
}

Write-Host "Indexando con Graphify: $ResolvedProject" -ForegroundColor Cyan
Write-Host "Comando: graphify $($Arguments -join ' ')" -ForegroundColor DarkGray

Push-Location $ResolvedProject
try {
    & graphify @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Graphify terminó con código $LASTEXITCODE."
    }
}
finally {
    Pop-Location
}

Write-Host "Indexación completada." -ForegroundColor Green
