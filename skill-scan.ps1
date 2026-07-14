param([Parameter(Mandatory=$true)][string]$SkillPath)
$path=[System.IO.Path]::GetFullPath($SkillPath)
if(-not(Test-Path $path)){throw "No existe: $path"}
$scanner=@("skill-scanner","skill_scanner") | Where-Object {Get-Command $_ -ErrorAction SilentlyContinue} | Select-Object -First 1
if(-not $scanner){throw "Cisco Skill Scanner no está instalado o no está en PATH."}
& $scanner scan $path
exit $LASTEXITCODE
