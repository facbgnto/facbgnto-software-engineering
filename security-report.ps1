param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath,

    [string]$ReportName,

    [switch]$Force
)

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$ResolvedProject = [System.IO.Path]::GetFullPath($ProjectPath)
$TemplateRoot = Join-Path $Root "skills\facbgnto-security-review\templates"

if (-not (Test-Path $ResolvedProject)) {
    throw "No existe el proyecto: $ResolvedProject"
}

if (-not (Test-Path $TemplateRoot)) {
    throw "No se encontraron plantillas de seguridad: $TemplateRoot"
}

if (-not $ReportName) {
    $ReportName = Get-Date -Format "yyyy-MM-dd-security-review"
}

$ReportRoot = Join-Path $ResolvedProject "reports\security\$ReportName"
$EvidenceRoot = Join-Path $ReportRoot "evidence"

function Copy-ReportTemplate {
    param(
        [string]$SourceName,
        [string]$DestinationName
    )

    $Source = Join-Path $TemplateRoot $SourceName
    $Destination = Join-Path $ReportRoot $DestinationName

    if ((Test-Path $Destination) -and -not $Force) {
        Write-Host "Conservado: $Destination" -ForegroundColor DarkGray
        return
    }

    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Destination) | Out-Null
    Copy-Item -Force $Source $Destination
    Write-Host "Creado: $Destination" -ForegroundColor Green
}

New-Item -ItemType Directory -Force -Path $ReportRoot | Out-Null
New-Item -ItemType Directory -Force -Path $EvidenceRoot | Out-Null

Copy-ReportTemplate "SECURITY-REPORT.md" "security-report.md"
Copy-ReportTemplate "EXECUTIVE-SUMMARY.md" "executive-summary.md"
Copy-ReportTemplate "REMEDIATION-PLAN.md" "remediation-plan.md"
Copy-ReportTemplate "RISK-MATRIX.md" "risk-matrix.md"
Copy-ReportTemplate "REVIEW-HISTORY.md" "review-history.md"
Copy-ReportTemplate "metrics.json" "metrics.json"

$EvidenceTemplate = Join-Path $TemplateRoot "evidence\README.md"
$EvidenceReadme = Join-Path $EvidenceRoot "README.md"

if (-not (Test-Path $EvidenceReadme) -or $Force) {
    Copy-Item -Force $EvidenceTemplate $EvidenceReadme
}

foreach ($Folder in @("commands", "sanitized-output", "diagrams", "screenshots")) {
    New-Item -ItemType Directory -Force -Path (Join-Path $EvidenceRoot $Folder) | Out-Null
}

Write-Host ""
Write-Host "Paquete profesional de seguridad creado en:" -ForegroundColor Green
Write-Host $ReportRoot
