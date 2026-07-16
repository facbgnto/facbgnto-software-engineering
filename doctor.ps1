param(
    [string]$ProjectPath,
    [ValidateSet("Default", "Deportivox")]
    [string]$Profile = "Default"
)
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
            @{ Name = "Security Storage Auditor"; Path = (Join-Path $ResolvedProject ".agents\skills\security-storage\SKILL.md") },
            @{ Name = "Configuración Headroom"; Path = (Join-Path $ResolvedProject ".facbgnto\headroom.env") },
            @{ Name = "Configuración Caveman"; Path = (Join-Path $ResolvedProject ".facbgnto\caveman.json") }
        )
        foreach ($check in $checks) {
            if (Test-Path $check.Path) { Write-Host "[OK] $($check.Name)" -ForegroundColor Green }
            else { Write-Host "[WARN] Falta $($check.Name)" -ForegroundColor Yellow }
        }

        if ($Profile -eq "Deportivox") {
            Write-Host ""; Write-Host "Perfil Deportivox" -ForegroundColor Cyan
            $deportivoxChecks = @(
                @{ Name = ".agents facbgnto-security-review"; Path = (Join-Path $ResolvedProject ".agents\skills\facbgnto-security-review\SKILL.md") },
                @{ Name = ".agents security-storage"; Path = (Join-Path $ResolvedProject ".agents\skills\security-storage\SKILL.md") },
                @{ Name = ".agents facbgnto-software-engineering"; Path = (Join-Path $ResolvedProject ".agents\skills\facbgnto-software-engineering\SKILL.md") },
                @{ Name = ".claude facbgnto-security-review"; Path = (Join-Path $ResolvedProject ".claude\skills\facbgnto-security-review\SKILL.md") },
                @{ Name = ".claude security-storage"; Path = (Join-Path $ResolvedProject ".claude\skills\security-storage\SKILL.md") },
                @{ Name = ".claude facbgnto-software-engineering"; Path = (Join-Path $ResolvedProject ".claude\skills\facbgnto-software-engineering\SKILL.md") },
                @{ Name = ".claude frontend-ui-engineering"; Path = (Join-Path $ResolvedProject ".claude\skills\frontend-ui-engineering\SKILL.md") },
                @{ Name = ".claude graphify"; Path = (Join-Path $ResolvedProject ".claude\skills\graphify\SKILL.md") }
            )
            foreach ($check in $deportivoxChecks) {
                if (Test-Path $check.Path) { Write-Host "[OK] $($check.Name)" -ForegroundColor Green }
                else { Write-Host "[WARN] Falta $($check.Name)" -ForegroundColor Yellow }
            }

            $headroomEnv = Join-Path $ResolvedProject ".facbgnto\headroom.env"
            if ((Test-Path $headroomEnv) -and ((Get-Content $headroomEnv) -contains "HEADROOM_VERSION=0.31.0")) {
                Write-Host "[OK] Headroom 0.31.0 configurado" -ForegroundColor Green
            }
            else {
                Write-Host "[WARN] Falta HEADROOM_VERSION=0.31.0 en .facbgnto\headroom.env" -ForegroundColor Yellow
            }

            $codexSkillsRoot = "C:\Users\Socius\.codex\skills"
            foreach ($skill in @(
                "api-and-interface-design", "api-design", "backend-patterns", "banner-design", "brand",
                "browser-testing-with-devtools", "ci-cd-and-automation", "code-review-and-quality",
                "code-simplification", "coding-standards", "context-engineering", "database-migrations",
                "debugging-and-error-recovery", "deployment-patterns", "deprecation-and-migration",
                "design", "design-system", "docker-patterns", "documentation-and-adrs",
                "doubt-driven-development", "e2e-testing", "facbgnto-security-review",
                "facbgnto-software-engineering", "frontend-patterns", "frontend-ui-engineering",
                "git-workflow-and-versioning", "idea-refine", "incremental-implementation",
                "interview-me", "iterative-retrieval", "observability-and-instrumentation",
                "performance-optimization", "planning-and-task-breakdown", "postgres-patterns",
                "search-first", "security-and-hardening", "security-review", "security-scan",
                "shipping-and-launch", "slides", "source-driven-development", "spec-driven-development",
                "tdd-workflow", "test-driven-development", "ui-styling", "ui-ux-pro-max",
                "using-agent-skills", "verification-loop"
            )) {
                $skillPath = Join-Path $codexSkillsRoot $skill
                if (Test-Path $skillPath) { Write-Host "[OK] Codex global $skill" -ForegroundColor Green }
                else { Write-Host "[WARN] Falta Codex global $skill" -ForegroundColor Yellow }
            }
        }
    }
}

if ($failed) { Write-Host ""; Write-Host "Diagnóstico finalizado con errores obligatorios." -ForegroundColor Red; exit 1 }
Write-Host ""; Write-Host "Diagnóstico completado." -ForegroundColor Green
