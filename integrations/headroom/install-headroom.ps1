param(
    [Parameter(Mandatory=$true)][string]$ProjectPath,
    [ValidateSet("codex","claude","cursor","windsurf","cline","copilot","gemini","all")][string]$Agent="codex",
    [switch]$EnableOutputShaper,
    [switch]$DryRun,
    [switch]$Force
)
$ErrorActionPreference="Stop"
$HeadroomVersion = "0.31.0"
$HeadroomPackage = "headroom-ai[all]==$HeadroomVersion"
function Run([string]$Text,[scriptblock]$Action){ if($DryRun){Write-Host "[DRY-RUN] $Text" -ForegroundColor Cyan}else{& $Action} }
if(-not(Get-Command uv -ErrorAction SilentlyContinue)){throw "Headroom requiere uv. Instala uv y vuelve a ejecutar."}
Run "uv tool install $HeadroomPackage" {
    uv tool install --python 3.13 --reinstall $HeadroomPackage
    if($LASTEXITCODE -ne 0){throw "Falló la instalación de Headroom."}
}
$configDir=Join-Path $ProjectPath ".facbgnto"
$configFile=Join-Path $configDir "headroom.env"
if((Test-Path $configFile)-and-not$Force){Write-Host "Conservado: $configFile" -ForegroundColor DarkGray}else{
    $shaper=if($EnableOutputShaper){"1"}else{"0"}
    $content=@"
# FACBGNTO Headroom
HEADROOM_VERSION=$HeadroomVersion
HEADROOM_OUTPUT_SHAPER=$shaper
HEADROOM_OUTPUT_HOLDOUT=0.1
HEADROOM_UPDATE_CHECK=on
HEADROOM_PROXY_PORT=8787
"@
    Run "Crear $configFile" { New-Item -ItemType Directory -Force -Path $configDir|Out-Null; Set-Content -Path $configFile -Value $content -Encoding UTF8 }
}
if(-not$DryRun){ headroom doctor }
Write-Host "Headroom instalado. Inicia el agente con integrations/headroom/start-headroom.ps1." -ForegroundColor Green
