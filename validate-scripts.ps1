param(
    [string]$RepositoryPath = $PSScriptRoot
)

$ErrorActionPreference = "Stop"
$ResolvedRepository = [System.IO.Path]::GetFullPath($RepositoryPath)
$Files = Get-ChildItem -Path $ResolvedRepository -Filter "*.ps1" -File

$HasErrors = $false

foreach ($File in $Files) {
    $Tokens = $null
    $Errors = $null

    [void][System.Management.Automation.Language.Parser]::ParseFile(
        $File.FullName,
        [ref]$Tokens,
        [ref]$Errors
    )

    if ($Errors.Count -gt 0) {
        $HasErrors = $true
        Write-Host "[FAIL] $($File.Name)" -ForegroundColor Red

        foreach ($ErrorItem in $Errors) {
            Write-Host "  Línea $($ErrorItem.Extent.StartLineNumber): $($ErrorItem.Message)"
        }
    }
    else {
        Write-Host "[OK]   $($File.Name)" -ForegroundColor Green
    }
}

if ($HasErrors) {
    exit 1
}

Write-Host ""
Write-Host "Todos los scripts PowerShell tienen sintaxis válida." -ForegroundColor Green
