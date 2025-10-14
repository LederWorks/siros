# Generate Call Graph Visualizations for Siros Backend
# This script uses go-callvis to create different call graph visualizations

[CmdletBinding()]
param(
    [switch]$SkipInstall,
    [switch]$VerboseOutput
)

Write-Host "🔍 Generating Siros Backend Call Graph Visualizations..." -ForegroundColor Blue

# Check if we're in the right directory
if (-not (Test-Path "go.mod") -and -not (Test-Path "backend")) {
    Write-Host "❌ Error: Please run this script from the project root" -ForegroundColor Red
    exit 1
}

# Navigate to backend directory
Set-Location backend

# Check if go-callvis is installed
$goCallvisExists = $null -ne (Get-Command go-callvis -ErrorAction SilentlyContinue)
if (-not $goCallvisExists -and -not $SkipInstall) {
    Write-Host "📦 Installing go-callvis..." -ForegroundColor Yellow
    go install github.com/ofabry/go-callvis@latest
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to install go-callvis" -ForegroundColor Red
        exit 1
    }
}

# Check if dot (graphviz) is available
$dotExists = $null -ne (Get-Command dot -ErrorAction SilentlyContinue)
if (-not $dotExists) {
    Write-Host "⚠️  Warning: Graphviz 'dot' not found. Install graphviz for better output:" -ForegroundColor Yellow
    Write-Host "   Windows: choco install graphviz" -ForegroundColor Yellow
    Write-Host "   Or download from: https://graphviz.org/download/" -ForegroundColor Yellow
    Write-Host ""
    $UseGraphviz = ""
}
else {
    Write-Host "✅ Graphviz found, using enhanced rendering" -ForegroundColor Green
    $UseGraphviz = "-graphviz"
}

# Create docs directory if it doesn't exist
$DocsDir = "..\docs\callgraph"
if (-not (Test-Path $DocsDir)) {
    New-Item -ItemType Directory -Path $DocsDir -Force | Out-Null
}

function Invoke-GoCallvis {
    param(
        [string]$Name,
        [string]$OutputFile,
        [string]$Focus = "main",
        [string]$Include = "",
        [string]$Limit = "",
        [string]$Ignore = "",
        [string]$RankDir = "LR",
        [int]$MinLen = 2,
        [double]$NodeSep = 0.5,
        [bool]$NoStd = $true,
        [bool]$NoInter = $false,
        [string]$Group = "pkg",
        [string]$Description
    )

    Write-Host "📊 Generating $Description..." -ForegroundColor Cyan

    # Build parameters array
    $callvisArgs = @()

    if ($Focus) { $callvisArgs += "-focus=$Focus" }
    if ($Include) { $callvisArgs += "-include=$Include" }
    if ($Limit) { $callvisArgs += "-limit=$Limit" }
    if ($Ignore) { $callvisArgs += "-ignore=$Ignore" }
    if ($NoStd) { $callvisArgs += "-nostd" }
    if ($NoInter) { $callvisArgs += "-nointer" }
    $callvisArgs += "-rankdir=$RankDir"
    $callvisArgs += "-minlen=$MinLen"
    $callvisArgs += "-nodesep=$NodeSep"
    $callvisArgs += "-group=$Group"
    $callvisArgs += "-file=$OutputFile"
    $callvisArgs += "github.com/LederWorks/siros/backend/cmd/siros-server"

    if ($VerboseOutput) {
        Write-Host "   Running: go-callvis $($callvisArgs -join ' ')" -ForegroundColor Gray
    }

    try {
        & go-callvis @callvisArgs

        # Check if the output file was created successfully
        Start-Sleep -Seconds 1  # Give it a moment to write the file

        if (Test-Path "$OutputFile.svg") {
            $fileInfo = Get-Item "$OutputFile.svg"
            if ($fileInfo.Length -gt 1000) {
                # Check if file has reasonable content (>1KB)
                Write-Host "✓ Generated: $OutputFile.svg ($($fileInfo.Length) bytes)" -ForegroundColor Green
                return $true
            }
            else {
                Write-Host "✗ Generated file too small ($($fileInfo.Length) bytes): $OutputFile.svg" -ForegroundColor Red
                return $false
            }
        }
        else {
            Write-Host "✗ Output file not created: $OutputFile.svg" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "❌ Error generating $Name`: $_" -ForegroundColor Red
        return $false
    }
}

# Generate different call graph views
$success = $true

# Main comprehensive overview - the best visualization showing proper depth and detail
$success = $success -and (Invoke-GoCallvis -Name "full-comprehensive" -OutputFile "../docs/callgraph/full-comprehensive" -Focus "" -RankDir "LR" -MinLen 1 -NodeSep 0.3 -NoStd $false -Group "pkg,type" -Description "comprehensive call graph with enhanced depth")

$success = $success -and (Invoke-GoCallvis -Name "api-layer" -OutputFile "../docs/callgraph/api-layer" -Focus "github.com/LederWorks/siros/backend/internal/api" -RankDir "LR" -MinLen 3 -Description "API layer call graph")

$success = $success -and (Invoke-GoCallvis -Name "services-layer" -OutputFile "../docs/callgraph/services-layer" -Focus "github.com/LederWorks/siros/backend/internal/services" -RankDir "TB" -MinLen 2 -Description "services layer call graph")

$success = $success -and (Invoke-GoCallvis -Name "storage-layer" -OutputFile "../docs/callgraph/storage-layer" -Focus "github.com/LederWorks/siros/backend/internal/storage" -RankDir "LR" -MinLen 2 -Description "storage layer call graph")

# Note: providers-layer is currently not connected to main execution path, so it will be skipped
# $success = $success -and (Invoke-GoCallvis -Name "providers-layer" -OutputFile "../docs/callgraph/providers-layer" -Focus "github.com/LederWorks/siros/backend/internal/providers" -RankDir "TB" -MinLen 2 -Description "cloud providers call graph")

$success = $success -and (Invoke-GoCallvis -Name "config-layer" -OutputFile "../docs/callgraph/config-layer" -Focus "github.com/LederWorks/siros/backend/internal/config" -RankDir "LR" -MinLen 2 -Description "configuration layer call graph")

$success = $success -and (Invoke-GoCallvis -Name "middleware" -OutputFile "../docs/callgraph/middleware" -Include "middleware,auth,cors" -RankDir "LR" -MinLen 2 -Description "middleware call graph")

if ($success) {
    Write-Host "✅ Call graph generation complete!" -ForegroundColor Green
}
else {
    Write-Host "⚠️  Call graph generation completed with some errors" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📁 Generated files in docs/callgraph/:" -ForegroundColor Blue
$svgFiles = Get-ChildItem "../docs/callgraph/*.svg" -ErrorAction SilentlyContinue
if ($svgFiles) {
    $svgFiles | ForEach-Object { Write-Host "   $($_.Name)" -ForegroundColor Gray }
}
else {
    Write-Host "   (No SVG files found - check for errors above)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📖 To view the documentation with embedded graphs:" -ForegroundColor Blue
Write-Host "   Open docs/BACKEND_CALL_GRAPH.md in VS Code or your preferred viewer" -ForegroundColor Gray
