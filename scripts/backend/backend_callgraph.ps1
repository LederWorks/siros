# Backend Call Graph Generator for Siros
# Generates comprehensive call graph visualizations for the Go backend
# Automatically cleans up previous graphs before generating new ones

[CmdletBinding()]
param(
    [switch]$SkipInstall,
    [switch]$VerboseOutput,
    [switch]$Help
)

if ($Help) {
    Write-Host "Backend Call Graph Generator for Siros" -ForegroundColor Blue
    Write-Host ""
    Write-Host "USAGE:" -ForegroundColor Yellow
    Write-Host "  .\scripts\backend_callgraph.ps1 [options]"
    Write-Host ""
    Write-Host "OPTIONS:" -ForegroundColor Yellow
    Write-Host "  -SkipInstall      Skip automatic installation of go-callvis"
    Write-Host "  -VerboseOutput    Enable verbose output for debugging"
    Write-Host "  -Help             Show this help message"
    Write-Host ""
    Write-Host "DESCRIPTION:" -ForegroundColor Yellow
    Write-Host "  This script automatically cleans up previous call graphs and generates"
    Write-Host "  new comprehensive visualizations of the Siros backend architecture."
    Write-Host "  Generated SVG files are saved to docs/callgraph/"
    Write-Host ""
    exit 0
}

Write-Host "🔍 Siros Backend Call Graph Generator" -ForegroundColor Blue
Write-Host "=====================================`n" -ForegroundColor Blue

# Check if we're in the right directory
if (-not (Test-Path "go.mod") -and -not (Test-Path "backend")) {
    Write-Host "❌ Error: Please run this script from the project root" -ForegroundColor Red
    exit 1
}

# Function to print colored output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Step 1: Clean up previous call graphs
Write-Status "Cleaning up previous call graph files..."
$CallGraphDir = "docs\callgraph"
if (Test-Path $CallGraphDir) {
    Write-Host "🗑️  Removing existing call graphs..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force $CallGraphDir
    Write-Success "Previous call graphs cleaned"
}
else {
    Write-Host "ℹ️  No previous call graphs to clean" -ForegroundColor Gray
}

# Create docs directory structure
if (-not (Test-Path "docs")) {
    New-Item -ItemType Directory -Path "docs" -Force | Out-Null
}
New-Item -ItemType Directory -Path $CallGraphDir -Force | Out-Null

# Navigate to backend directory
Set-Location backend

# Step 2: Check and install dependencies
Write-Status "Checking dependencies..."

# Check if go-callvis is installed
$goCallvisExists = $null -ne (Get-Command go-callvis -ErrorAction SilentlyContinue)
if (-not $goCallvisExists -and -not $SkipInstall) {
    Write-Warning "go-callvis not found, installing latest version..."
    go install github.com/ofabry/go-callvis@latest
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to install go-callvis"
        exit 1
    }
    Write-Success "go-callvis installed successfully"
}
elseif ($goCallvisExists -and -not $SkipInstall) {
    Write-Status "go-callvis found, updating to latest version..."
    go install github.com/ofabry/go-callvis@latest
    if ($LASTEXITCODE -eq 0) {
        Write-Success "go-callvis updated to latest version"
    }
    else {
        Write-Warning "Failed to update go-callvis, using existing version"
    }
}
elseif (-not $goCallvisExists) {
    Write-Error "go-callvis not found and -SkipInstall specified"
    Write-Host "Install manually: go install github.com/ofabry/go-callvis@latest" -ForegroundColor Gray
    exit 1
}
else {
    Write-Success "go-callvis found (skipping update due to -SkipInstall)"
}

# Check if dot (graphviz) is available
$dotExists = $null -ne (Get-Command dot -ErrorAction SilentlyContinue)
if (-not $dotExists) {
    Write-Warning "Graphviz 'dot' not found. Install for better output:"
    Write-Host "   Windows: choco install graphviz" -ForegroundColor Gray
    Write-Host "   Or download from: https://graphviz.org/download/" -ForegroundColor Gray
    $UseGraphviz = ""
}
else {
    Write-Success "Graphviz found, using enhanced rendering"
    $UseGraphviz = "-graphviz"
}

# Step 3: Generate call graphs
Write-Status "Generating call graph visualizations..."

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
        Write-Error "Error generating $Name`: $_"
        return $false
    }
}

# Generate different call graph views
$success = $true

# Main comprehensive overview
$success = $success -and (Invoke-GoCallvis -Name "full-comprehensive" -OutputFile "../docs/callgraph/full-comprehensive" -Focus "" -RankDir "LR" -MinLen 1 -NodeSep 0.3 -NoStd $false -Group "pkg,type" -Description "comprehensive call graph with enhanced depth")

# API layer visualization
$success = $success -and (Invoke-GoCallvis -Name "api-layer" -OutputFile "../docs/callgraph/api-layer" -Focus "github.com/LederWorks/siros/backend/internal/api" -RankDir "LR" -MinLen 3 -Description "API layer call graph")

# Services layer visualization
$success = $success -and (Invoke-GoCallvis -Name "services-layer" -OutputFile "../docs/callgraph/services-layer" -Focus "github.com/LederWorks/siros/backend/internal/services" -RankDir "TB" -MinLen 2 -Description "services layer call graph")

# Storage layer visualization
$success = $success -and (Invoke-GoCallvis -Name "storage-layer" -OutputFile "../docs/callgraph/storage-layer" -Focus "github.com/LederWorks/siros/backend/internal/storage" -RankDir "LR" -MinLen 2 -Description "storage layer call graph")

# Configuration layer visualization
$success = $success -and (Invoke-GoCallvis -Name "config-layer" -OutputFile "../docs/callgraph/config-layer" -Focus "github.com/LederWorks/siros/backend/internal/config" -RankDir "LR" -MinLen 2 -Description "configuration layer call graph")

# Middleware visualization
$success = $success -and (Invoke-GoCallvis -Name "middleware" -OutputFile "../docs/callgraph/middleware" -Include "middleware,auth,cors" -RankDir "LR" -MinLen 2 -Description "middleware call graph")

# Step 4: Results summary
Write-Host "`n" -NoNewline
if ($success) {
    Write-Success "Call graph generation completed successfully! ✨"
}
else {
    Write-Warning "Call graph generation completed with some errors"
}

Write-Host ""
Write-Status "Generated files in docs/callgraph/:"
$svgFiles = Get-ChildItem "../docs/callgraph/*.svg" -ErrorAction SilentlyContinue
if ($svgFiles) {
    $svgFiles | ForEach-Object {
        $fileInfo = Get-Item $_.FullName
        Write-Host "   📄 $($_.Name) ($([math]::Round($fileInfo.Length/1024, 1)) KB)" -ForegroundColor Gray
    }
}
else {
    Write-Warning "No SVG files found - check for errors above"
}

Write-Host ""
Write-Status "Next steps:"
Write-Host "   📖 View documentation: docs/BACKEND_CALL_GRAPH.md" -ForegroundColor Gray
Write-Host "   🌐 Open SVG files in browser or VS Code for interactive viewing" -ForegroundColor Gray

# Return to project root
Set-Location ".."
