param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath,

    [ValidateSet("svg", "png", "pdf")]
    [string]$Format = "svg",

    [switch]$CheckOnly,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command mmdc -ErrorAction SilentlyContinue)) {
    throw "Mermaid CLI no está instalado. Ejecuta: npm install -g @mermaid-js/mermaid-cli"
}

$ResolvedProject = [System.IO.Path]::GetFullPath($ProjectPath)
$SourceRoot = Join-Path $ResolvedProject "docs\diagrams\source"
$OutputRoot = Join-Path $ResolvedProject "docs\diagrams\generated"

if (-not (Test-Path $SourceRoot)) {
    throw "No existe $SourceRoot. Ejecuta docs.ps1 primero."
}

New-Item -ItemType Directory -Force -Path $OutputRoot | Out-Null

$Files = Get-ChildItem -Path $SourceRoot -Filter "*.mmd" -File
if ($Files.Count -eq 0) {
    throw "No se encontraron diagramas .mmd."
}

$TempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("facbgnto-diagrams-" + [guid]::NewGuid())
New-Item -ItemType Directory -Force -Path $TempRoot | Out-Null

try {
    foreach ($File in $Files) {
        $BaseName = [System.IO.Path]::GetFileNameWithoutExtension($File.Name)
        $Output = if ($CheckOnly) {
            Join-Path $TempRoot "$BaseName.$Format"
        }
        else {
            Join-Path $OutputRoot "$BaseName.$Format"
        }

        if (-not $CheckOnly -and (Test-Path $Output) -and -not $Force -and
            ((Get-Item $Output).LastWriteTimeUtc -ge $File.LastWriteTimeUtc)) {
            Write-Host "Sin cambios: $($File.Name)" -ForegroundColor DarkGray
            continue
        }

        Write-Host "Renderizando $($File.Name)..." -ForegroundColor Cyan
        & mmdc -i $File.FullName -o $Output -e $Format -b transparent

        if ($LASTEXITCODE -ne 0) {
            throw "Falló Mermaid CLI para $($File.FullName)."
        }

        if (-not $CheckOnly) {
            Write-Host "Generado: $Output" -ForegroundColor Green
        }
    }
}
finally {
    Remove-Item -Recurse -Force $TempRoot -ErrorAction SilentlyContinue
}

if ($CheckOnly) {
    Write-Host "Todos los diagramas Mermaid son válidos." -ForegroundColor Green
}
else {
    Write-Host "Diagramas actualizados en $OutputRoot" -ForegroundColor Green
}
