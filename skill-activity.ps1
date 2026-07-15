param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath,

    [Parameter(Mandatory = $true)]
    [string]$Skill,

    [ValidateSet("start", "finish", "note")]
    [string]$Action = "note",

    [string]$Reason = "",

    [string[]]$Tools = @()
)

$ErrorActionPreference = "Stop"
$ResolvedProject = [System.IO.Path]::GetFullPath($ProjectPath)

if (-not (Test-Path $ResolvedProject)) {
    throw "No existe el proyecto: $ResolvedProject"
}

$ReportRoot = Join-Path $ResolvedProject "reports\agent-activity"
New-Item -ItemType Directory -Force -Path $ReportRoot | Out-Null

$Date = Get-Date -Format "yyyy-MM-dd"
$Timestamp = Get-Date -Format "yyyy-MM-ddTHH-mm-ss"
$ReportFile = Join-Path $ReportRoot "$Date-skill-activity.md"

$Branch = ""
$Commit = ""

if (Test-Path (Join-Path $ResolvedProject ".git")) {
    $Branch = (git -C $ResolvedProject branch --show-current 2>$null | Out-String).Trim()
    $Commit = (git -C $ResolvedProject rev-parse --short HEAD 2>$null | Out-String).Trim()
}

if (-not (Test-Path $ReportFile)) {
    Set-Content `
        -Path $ReportFile `
        -Encoding UTF8 `
        -Value "# Registro de actividad de skills - $Date"
}

$ToolText = if ($Tools.Count -gt 0) {
    $Tools -join ", "
}
else {
    "No informado"
}

$Entry = @(
    "",
    "## $Timestamp - $Action",
    "",
    "- Skill: $Skill",
    "- Motivo: $Reason",
    "- Rama: $Branch",
    "- Commit: $Commit",
    "- Herramientas: $ToolText"
)

Add-Content `
    -Path $ReportFile `
    -Encoding UTF8 `
    -Value ($Entry -join [Environment]::NewLine)

Write-Host "Actividad registrada: $ReportFile" -ForegroundColor Green
