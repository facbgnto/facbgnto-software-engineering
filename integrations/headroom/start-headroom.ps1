param([string]$ProjectPath=(Get-Location).Path,[ValidateSet("codex","claude")][string]$Agent="codex")
$envFile=Join-Path $ProjectPath ".facbgnto\headroom.env"
if(Test-Path $envFile){ Get-Content $envFile | Where-Object {$_ -match '^[A-Z0-9_]+='} | ForEach-Object {$k,$v=$_.Split('=',2); [Environment]::SetEnvironmentVariable($k,$v,'Process')} }
if(-not(Get-Command headroom -ErrorAction SilentlyContinue)){throw "Headroom no está instalado."}
& headroom wrap $Agent
