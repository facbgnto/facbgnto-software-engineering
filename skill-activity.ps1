param(
  [Parameter(Mandatory=$true)][string]$ProjectPath,
  [Parameter(Mandatory=$true)][string]$Skill,
  [ValidateSet("start","finish","note")][string]$Action="note",
  [string]$Reason=""
)

$ErrorActionPreference="Stop"
$project=[System.IO.Path]::GetFullPath($ProjectPath)
if(-not(Test-Path $project)){throw "No existe el proyecto: $project"}

$folder=Join-Path $project "reports\agent-activity"
New-Item -ItemType Directory -Force -Path $folder | Out-Null
$date=Get-Date -Format "yyyy-MM-dd"
$time=Get-Date -Format "yyyy-MM-ddTHH-mm-ss"
$file=Join-Path $folder "$date-skill-activity.md"
$branch=""
$commit=""

if(Test-Path (Join-Path $project ".git")){
  $branch=git -C $project branch --show-current 2>$null
  $commit=git -C $project rev-parse --short HEAD 2>$null
}

if(-not(Test-Path $file)){
  "# Registro de actividad de skills — $date`n" | Set-Content $file -Encoding UTF8
}

@"

## $time — $Action
- Skill: $Skill
- Motivo: $Reason
- Rama: $branch
- Commit: $commit
"@ | Add-Content $file -Encoding UTF8

Write-Host "Actividad registrada: $file" -ForegroundColor Green
