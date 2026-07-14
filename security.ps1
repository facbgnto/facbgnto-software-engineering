param(
  [Parameter(Mandatory=$true)][string]$ProjectPath,
  [switch]$RunGitleaks,
  [switch]$RunSemgrep,
  [switch]$RunDependencyAudit,
  [switch]$GenerateReport,
  [switch]$FailOnFindings
)

$ErrorActionPreference="Continue"
$root=Split-Path -Parent $MyInvocation.MyCommand.Path
$project=[System.IO.Path]::GetFullPath($ProjectPath)
if(-not(Test-Path $project)){throw "No existe el proyecto: $project"}

& (Join-Path $root "skill-activity.ps1") -ProjectPath $project -Skill "facbgnto-security-review" -Action start -Reason "Revisión automatizada"

$results=@()
$failed=$false

function Add-Result($tool,$command,$code,$output){
  $script:results += [PSCustomObject]@{Tool=$tool;Command=$command;Code=$code;Output=$output}
  if($code -ne 0){$script:failed=$true}
}

if($RunGitleaks){
  if(Get-Command gitleaks -ErrorAction SilentlyContinue){
    $out=& gitleaks detect --source $project --no-banner --redact 2>&1 | Out-String
    Add-Result "Gitleaks" "gitleaks detect --source <project> --no-banner --redact" $LASTEXITCODE $out
  } else { Add-Result "Gitleaks" "not installed" 127 "Gitleaks no instalado." }
}

if($RunSemgrep){
  if(Get-Command semgrep -ErrorAction SilentlyContinue){
    $cfg=Join-Path $project ".semgrep.yml"
    $args=@("scan","--config","auto")
    if(Test-Path $cfg){$args+=@("--config",$cfg)}
    $args+=$project
    $out=& semgrep @args 2>&1 | Out-String
    Add-Result "Semgrep" ("semgrep "+($args -join " ")) $LASTEXITCODE $out
  } else { Add-Result "Semgrep" "not installed" 127 "Semgrep no instalado." }
}

if($RunDependencyAudit -and (Test-Path (Join-Path $project "package.json"))){
  Push-Location $project
  try{
    $out=& npm audit --audit-level=high 2>&1 | Out-String
    Add-Result "npm audit" "npm audit --audit-level=high" $LASTEXITCODE $out
  } finally { Pop-Location }
}

if($GenerateReport -or $results.Count -gt 0){
  $folder=Join-Path $project "reports\security"
  New-Item -ItemType Directory -Force -Path $folder | Out-Null
  $file=Join-Path $folder ("security-"+(Get-Date -Format "yyyyMMdd-HHmmss")+".md")
  $lines=@("# Informe automatizado de seguridad","","- Fecha: $(Get-Date -Format o)","- Skill: facbgnto-security-review","","## Resultados")
  foreach($r in $results){
    $lines+=@("","### $($r.Tool)","- Comando: ``$($r.Command)``","- Código: $($r.Code)","","```text",$r.Output.Trim(),"```")
  }
  $lines+=@("","## Estado",$(if($failed){"REVIEW_REQUIRED"}else{"PASSED_AUTOMATED_CHECKS"}),"","Los resultados automáticos requieren revisión manual.")
  $lines -join "`n" | Set-Content $file -Encoding UTF8
  Write-Host "Informe generado: $file" -ForegroundColor Green
}

& (Join-Path $root "skill-activity.ps1") -ProjectPath $project -Skill "facbgnto-security-review" -Action finish -Reason "Revisión finalizada"
if($FailOnFindings -and $failed){exit 1}
