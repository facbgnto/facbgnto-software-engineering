param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath,

    [switch]$RunGitleaks,
    [switch]$RunSemgrep,
    [switch]$RunDependencyAudit,
    [switch]$GenerateReport,
    [switch]$FailOnFindings
)

$ErrorActionPreference = "Continue"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$ResolvedProject = [System.IO.Path]::GetFullPath($ProjectPath)

if (-not (Test-Path $ResolvedProject)) {
    throw "No existe el proyecto: $ResolvedProject"
}

& (Join-Path $Root "skill-activity.ps1") `
    -ProjectPath $ResolvedProject `
    -Skill "facbgnto-security-review" `
    -Action start `
    -Reason "Revisión automatizada de seguridad"

$Results = @()
$HasFindings = $false

function Add-SecurityResult {
    param(
        [string]$Tool,
        [string]$Command,
        [int]$ExitCode,
        [string]$Output
    )

    $script:Results += [PSCustomObject]@{
        Tool = $Tool
        Command = $Command
        ExitCode = $ExitCode
        Output = $Output
    }

    if ($ExitCode -ne 0) {
        $script:HasFindings = $true
    }
}

if ($RunGitleaks) {
    if (Get-Command gitleaks -ErrorAction SilentlyContinue) {
        $Output = & gitleaks detect `
            --source $ResolvedProject `
            --no-banner `
            --redact 2>&1 | Out-String

        Add-SecurityResult `
            -Tool "Gitleaks" `
            -Command "gitleaks detect --source <project> --no-banner --redact" `
            -ExitCode $LASTEXITCODE `
            -Output $Output
    }
    else {
        Add-SecurityResult `
            -Tool "Gitleaks" `
            -Command "gitleaks" `
            -ExitCode 127 `
            -Output "Gitleaks no está instalado."
    }
}

if ($RunSemgrep) {
    if (Get-Command semgrep -ErrorAction SilentlyContinue) {
        $Arguments = @("scan", "--config", "auto")
        $LocalConfig = Join-Path $ResolvedProject ".semgrep.yml"

        if (Test-Path $LocalConfig) {
            $Arguments += @("--config", $LocalConfig)
        }

        $Arguments += $ResolvedProject

        $Output = & semgrep @Arguments 2>&1 | Out-String

        Add-SecurityResult `
            -Tool "Semgrep" `
            -Command ("semgrep " + ($Arguments -join " ")) `
            -ExitCode $LASTEXITCODE `
            -Output $Output
    }
    else {
        Add-SecurityResult `
            -Tool "Semgrep" `
            -Command "semgrep" `
            -ExitCode 127 `
            -Output "Semgrep no está instalado."
    }
}

if ($RunDependencyAudit) {
    $PackageJson = Join-Path $ResolvedProject "package.json"

    if ((Test-Path $PackageJson) -and (Get-Command npm -ErrorAction SilentlyContinue)) {
        Push-Location $ResolvedProject
        try {
            $Output = & npm audit --audit-level=high 2>&1 | Out-String

            Add-SecurityResult `
                -Tool "npm audit" `
                -Command "npm audit --audit-level=high" `
                -ExitCode $LASTEXITCODE `
                -Output $Output
        }
        finally {
            Pop-Location
        }
    }
    else {
        Add-SecurityResult `
            -Tool "Dependency audit" `
            -Command "npm audit" `
            -ExitCode 0 `
            -Output "No se detectó package.json o npm."
    }
}

if ($GenerateReport -or $Results.Count -gt 0) {
    $ReportRoot = Join-Path $ResolvedProject "reports\security"
    New-Item -ItemType Directory -Force -Path $ReportRoot | Out-Null

    $ReportFile = Join-Path $ReportRoot (
        "security-{0}.md" -f (Get-Date -Format "yyyyMMdd-HHmmss")
    )

    $Lines = @(
        "# Informe automatizado de seguridad",
        "",
        "- Fecha: $(Get-Date -Format o)",
        "- Proyecto: $ResolvedProject",
        "- Skill: facbgnto-security-review",
        "",
        "## Resultados"
    )

    foreach ($Result in $Results) {
        $SafeOutput = $Result.Output

        if ($SafeOutput.Length -gt 12000) {
            $SafeOutput = $SafeOutput.Substring(0, 12000) + "`n[Salida truncada]"
        }

        $Lines += @(
            "",
            "### $($Result.Tool)",
            "",
            "- Comando: ``$($Result.Command)``",
            "- Código de salida: $($Result.ExitCode)",
            "",
            '```text',
            $SafeOutput.Trim(),
            '```'
        )
    }

    $Status = if ($HasFindings) {
        "REVIEW_REQUIRED"
    }
    else {
        "PASSED_AUTOMATED_CHECKS"
    }

    $Lines += @(
        "",
        "## Estado",
        "",
        $Status,
        "",
        "Los resultados automáticos requieren revisión manual."
    )

    Set-Content `
        -Path $ReportFile `
        -Encoding UTF8 `
        -Value ($Lines -join [Environment]::NewLine)

    Write-Host "Informe generado: $ReportFile" -ForegroundColor Green
}

& (Join-Path $Root "skill-activity.ps1") `
    -ProjectPath $ResolvedProject `
    -Skill "facbgnto-security-review" `
    -Action finish `
    -Reason "Revisión automatizada finalizada" `
    -Tools ($Results.Tool)

if ($FailOnFindings -and $HasFindings) {
    exit 1
}
