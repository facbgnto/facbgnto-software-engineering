param([string]$ProjectPath)
$ErrorActionPreference = "Continue"
$failed = $false

function Test-Tool {
    param([string]$Name, [scriptblock]$VersionCommand, [bool]$Required = $false)
    if (Get-Command $Name -ErrorAction SilentlyContinue) {
        try { $version = & $VersionCommand 2>$null | Select-Object -First 1; Write-Host "[OK] $Name $version" -ForegroundColor Green }
        catch { Write-Host "[OK] $Name instalado" -ForegroundColor Green }
    } else {
        $label = if ($Required) { "[FAIL]" } else { "[WARN]" }
        $color = if ($Required) { "Red" } else { "Yellow" }
        Write-Host "$label $Name no encontrado" -ForegroundColor $color
        if ($Required) { $script:failed = $true }
    }
}

Write-Host "FACBGNTO Software Engineering Doctor" -ForegroundColor Cyan
Write-Host "-------------------------------------"
Test-Tool "git" { git --version } $true
Test-Tool "node" { node --version }
Test-Tool "npm" { npm --version }
Test-Tool "python" { python --version } $true
Test-Tool "uv" { uv --version }
Test-Tool "graphify" { graphify --version }
Test-Tool "headroom" { headroom --version }
Test-Tool "mmdc" { mmdc --version }
Test-Tool "ollama" { ollama --version }
Test-Tool "docker" { docker --version }

if (Get-Command headroom -ErrorAction SilentlyContinue) {
    try { headroom doctor; if ($LASTEXITCODE -ne 0) { Write-Host "[WARN] headroom doctor informó problemas" -ForegroundColor Yellow } }
    catch { Write-Host "[WARN] No se pudo ejecutar headroom doctor" -ForegroundColor Yellow }
}

if ($ProjectPath) {
    $ResolvedProject = [System.IO.Path]::GetFullPath($ProjectPath)
    Write-Host ""; Write-Host "Proyecto: $ResolvedProject" -ForegroundColor Cyan
    if (-not (Test-Path $ResolvedProject)) { Write-Host "[FAIL] El proyecto no existe." -ForegroundColor Red; $failed = $true }
    else {
        $checks = @(
            @{ Name = "AGENTS.md"; Path = (Join-Path $ResolvedProject "AGENTS.md") },
            @{ Name = ".graphifyignore"; Path = (Join-Path $ResolvedProject ".graphifyignore") },
            @{ Name = "Skill Codex/Agents"; Path = (Join-Path $ResolvedProject ".agents\skills\facbgnto-software-engineering\SKILL.md") },
            @{ Name = "Skill Claude"; Path = (Join-Path $ResolvedProject ".claude\skills\facbgnto-software-engineering\SKILL.md") },
            @{ Name = "Skill Cursor"; Path = (Join-Path $ResolvedProject ".cursor\skills\facbgnto-software-engineering\SKILL.md") },
            @{ Name = "Configuración Headroom"; Path = (Join-Path $ResolvedProject ".facbgnto\headroom.env") },
            @{ Name = "Configuración Caveman"; Path = (Join-Path $ResolvedProject ".facbgnto\caveman.json") }
        )
        foreach ($check in $checks) {
            if (Test-Path $check.Path) { Write-Host "[OK] $($check.Name)" -ForegroundColor Green }
            else { Write-Host "[WARN] Falta $($check.Name)" -ForegroundColor Yellow }
        }
    }
}

if ($failed) { Write-Host ""; Write-Host "Diagnóstico finalizado con errores obligatorios." -ForegroundColor Red; exit 1 }
Write-Host ""; Write-Host "Diagnóstico completado." -ForegroundColor Green
