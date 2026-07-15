param(
 [Parameter(Mandatory=$true)][string]$ProjectPath,
 [ValidateSet("codex","claude","cursor","windsurf","cline","copilot","gemini","all")][string]$Agent="codex",
 [ValidateSet("lite","full","ultra")][string]$Level="lite",
 [switch]$DryRun,[switch]$Force
)
$ErrorActionPreference="Stop"
if(-not(Get-Command node -ErrorAction SilentlyContinue)){throw "Caveman requiere Node.js 18+."}
if(-not(Get-Command npx -ErrorAction SilentlyContinue)){throw "npx no está disponible."}
$agents=if($Agent -eq "all"){@("codex","claude","cursor","windsurf","cline","copilot","gemini")}else{@($Agent)}
Push-Location $ProjectPath
try{
 foreach($target in $agents){
  $cmd="npx --yes skills@latest add JuliusBrussee/caveman -a $target"
  if($DryRun){Write-Host "[DRY-RUN] $cmd" -ForegroundColor Cyan}else{& npx --yes skills@latest add JuliusBrussee/caveman -a $target; if($LASTEXITCODE-ne 0){throw "Falló Caveman para $target"}}
 }
}finally{Pop-Location}
$configDir=Join-Path $ProjectPath ".facbgnto"; $config=Join-Path $configDir "caveman.json"
if((Test-Path $config)-and-not$Force){Write-Host "Conservado: $config"}else{
 $json=@{level=$Level;preserve=@("code","commands","paths","urls","sql","errors","security-evidence","test-results");installedAgents=$agents}|ConvertTo-Json -Depth 4
 if($DryRun){Write-Host "[DRY-RUN] Crear $config"}else{New-Item -ItemType Directory -Force -Path $configDir|Out-Null;Set-Content $config $json -Encoding UTF8}
}
Write-Host "Caveman instalado. Nivel recomendado: $Level" -ForegroundColor Green
