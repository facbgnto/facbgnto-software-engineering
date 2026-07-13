param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath,

    [switch]$Force,
    [switch]$RenderDiagrams
)

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$ResolvedProject = [System.IO.Path]::GetFullPath($ProjectPath)
$TemplateRoot = Join-Path $Root "templates\documentation"
$DiagramTemplateRoot = Join-Path $Root "templates\diagrams"
$DocsRoot = Join-Path $ResolvedProject "docs"
$DiagramSource = Join-Path $DocsRoot "diagrams\source"
$DiagramGenerated = Join-Path $DocsRoot "diagrams\generated"
$ArchitectureRoot = Join-Path $DocsRoot "architecture"

if (-not (Test-Path $ResolvedProject)) {
    throw "No existe el proyecto: $ResolvedProject"
}

function Copy-TemplateTree {
    param(
        [string]$Source,
        [string]$Destination
    )

    Get-ChildItem -Path $Source -Recurse -File | ForEach-Object {
        $relative = $_.FullName.Substring($Source.Length).TrimStart('\', '/')
        $target = Join-Path $Destination $relative
        $targetDirectory = Split-Path -Parent $target

        New-Item -ItemType Directory -Force -Path $targetDirectory | Out-Null

        if (-not (Test-Path $target) -or $Force) {
            Copy-Item -Force $_.FullName $target
            Write-Host "Creado: $target" -ForegroundColor Green
        }
        else {
            Write-Host "Conservado: $target" -ForegroundColor DarkGray
        }
    }
}

New-Item -ItemType Directory -Force -Path $DocsRoot | Out-Null
New-Item -ItemType Directory -Force -Path $DiagramSource | Out-Null
New-Item -ItemType Directory -Force -Path $DiagramGenerated | Out-Null
New-Item -ItemType Directory -Force -Path $ArchitectureRoot | Out-Null

Copy-TemplateTree -Source $TemplateRoot -Destination $DocsRoot

Get-ChildItem -Path $DiagramTemplateRoot -File -Filter "*.mmd" | ForEach-Object {
    $target = Join-Path $DiagramSource $_.Name
    if (-not (Test-Path $target) -or $Force) {
        Copy-Item -Force $_.FullName $target
        Write-Host "Creado: $target" -ForegroundColor Green
    }
}

$StructurizrSource = Join-Path $DiagramTemplateRoot "workspace.dsl"
$StructurizrTarget = Join-Path $ArchitectureRoot "workspace.dsl"
if (-not (Test-Path $StructurizrTarget) -or $Force) {
    Copy-Item -Force $StructurizrSource $StructurizrTarget
    Write-Host "Creado: $StructurizrTarget" -ForegroundColor Green
}

if ($RenderDiagrams) {
    & (Join-Path $Root "diagrams.ps1") -ProjectPath $ResolvedProject
}

Write-Host ""
Write-Host "Documentación inicializada en $DocsRoot" -ForegroundColor Green
