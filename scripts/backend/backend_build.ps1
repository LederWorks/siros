# Siros Backend Build Script for PowerShell
# Builds the Go backend server with embedded frontend assets

[CmdletBinding()]
param(
    [switch]$Verbose,
    [switch]$SkipInstall,
    [string]$Config = "",
    [switch]$Help
)

if ($Help) {
    Write-Host "⚙️ Siros Backend Build" -ForegroundColor Blue
    Write-Host ""
    Write-Host "USAGE:" -ForegroundColor Yellow
    Write-Host "  .\scripts\build_backend.ps1 [options]"
    Write-Host ""
    Write-Host "OPTIONS:" -ForegroundColor Yellow
    Write-Host "  -Verbose            Enable verbose output"
    Write-Host "  -SkipInstall        Skip automatic dependency installation"
    Write-Host "  -Config <path>      Use custom config file"
    Write-Host "  -Help               Show this help message"
    Write-Host ""
    Write-Host "DESCRIPTION:" -ForegroundColor Yellow
    Write-Host "  Builds the Go backend server binary with embedded frontend assets."
    Write-Host "  Copies frontend build artifacts to backend/static/ before building."
    Write-Host "  Creates production binary at build/siros.exe"
    Write-Host ""
    Write-Host "EXAMPLES:" -ForegroundColor Yellow
    Write-Host "  .\scripts\build_backend.ps1                    # Build with default settings"
    Write-Host "  .\scripts\build_backend.ps1 -Verbose           # Build with verbose output"
    Write-Host "  .\scripts\build_backend.ps1 -SkipInstall       # Build without updating dependencies"
    exit 0
}

# Set error action preference
$ErrorActionPreference = "Stop"

# Output functions
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

# Get script directory and project root
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$BackendDir = Join-Path $ProjectRoot "backend"
$FrontendDistDir = Join-Path $ProjectRoot "frontend" "dist"
$BackendStaticDir = Join-Path $BackendDir "static"
$BuildDir = Join-Path $ProjectRoot "build"

Write-Host ""
Write-Host "⚙️ Siros Backend Build" -ForegroundColor Blue
Write-Host ""

# Check if we're in the right directory
if (-not (Test-Path $BackendDir)) {
    Write-Error "Backend directory not found at: $BackendDir"
    Write-Warning "Please run this script from the project root"
    exit 1
}

try {
    # Check Go availability
    $goVersion = Get-Command go -ErrorAction SilentlyContinue
    if (-not $goVersion) {
        Write-Error "Go not found! Please install Go to build the backend."
        exit 1
    }

    if ($Verbose) {
        $goVersionOutput = go version
        Write-Status "Using Go version: $goVersionOutput"
    }

    # Change to backend directory
    Set-Location $BackendDir
    Write-Status "Working in backend directory: $BackendDir"

    # Update Go dependencies if not skipped
    if (-not $SkipInstall) {
        Write-Status "Updating Go dependencies..."
        go mod tidy
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to update Go dependencies!"
            exit 1
        }
        Write-Success "Go dependencies updated successfully"
    }
    else {
        Write-Status "Skipping dependency updates (SkipInstall flag set)"
    }

    # Copy frontend assets if they exist
    if (Test-Path $FrontendDistDir) {
        Write-Status "Copying frontend assets to backend/static/..."

        # Clean existing static directory
        if (Test-Path $BackendStaticDir) {
            Remove-Item "$BackendStaticDir/*" -Recurse -Force -ErrorAction SilentlyContinue
        }
        else {
            New-Item -ItemType Directory -Path $BackendStaticDir -Force | Out-Null
        }

        # Copy frontend build artifacts
        Copy-Item "$FrontendDistDir/*" -Destination $BackendStaticDir -Recurse -Force

        $staticFiles = Get-ChildItem $BackendStaticDir -Recurse | Measure-Object
        Write-Success "Frontend assets copied ($($staticFiles.Count) files)"

        if ($Verbose) {
            Write-Status "Static assets:"
            Get-ChildItem $BackendStaticDir -Recurse | ForEach-Object {
                Write-Host "  $($_.FullName.Replace($BackendStaticDir, './static'))" -ForegroundColor Gray
            }
        }
    }
    else {
        Write-Warning "Frontend dist directory not found at: $FrontendDistDir"
        Write-Warning "Backend will be built without embedded frontend assets"
        Write-Status "Run 'build_frontend.ps1' first to include frontend assets"

        # Create placeholder frontend if no static directory exists
        if (-not (Test-Path $BackendStaticDir)) {
            Write-Status "Creating placeholder frontend assets..."
            New-Item -ItemType Directory -Path $BackendStaticDir -Force | Out-Null

            # Copy placeholder HTML template
            $placeholderHtmlPath = Join-Path $ScriptDir "placeholder-index.html"
            if (Test-Path $placeholderHtmlPath) {
                Copy-Item $placeholderHtmlPath -Destination "$BackendStaticDir/index.html"
                Write-Success "Placeholder frontend created from template"
            }
            else {
                Write-Warning "Placeholder HTML template not found at: $placeholderHtmlPath"
                Write-Status "Creating basic placeholder..."
                $basicHtml = @'
<!DOCTYPE html>
<html>
<head><title>Siros - Multi-Cloud Resource Platform</title></head>
<body>
<h1>🌐 Siros</h1>
<p>Multi-Cloud Resource Platform</p>
<p><a href="/api/v1/health">Health Check</a> | <a href="/api/v1/resources">Resources</a></p>
</body>
</html>
'@
                Set-Content -Path "$BackendStaticDir/index.html" -Value $basicHtml -Encoding UTF8
                Write-Success "Basic placeholder frontend created"
            }
        }
    }

    # Create build directory if it doesn't exist
    if (-not (Test-Path $BuildDir)) {
        New-Item -ItemType Directory -Path $BuildDir -Force | Out-Null
        Write-Status "Created build directory: $BuildDir"
    }

    # Build the backend binary
    Write-Status "Building Go backend binary..."

    $buildArgs = @("-o", "../build/siros.exe", "./cmd/siros-server")

    if ($Verbose) {
        Write-Status "Build command: go build $($buildArgs -join ' ')"
        go build @buildArgs
    }
    else {
        go build @buildArgs 2>$null
    }

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Backend build failed!"
        exit 1
    }

    # Verify build output
    $binaryPath = Join-Path $BuildDir "siros.exe"
    if (-not (Test-Path $binaryPath)) {
        Write-Error "Build completed but binary not found at: $binaryPath"
        exit 1
    }

    $binaryInfo = Get-Item $binaryPath
    Write-Success "Backend build completed successfully!"
    Write-Status "Binary location: $binaryPath"
    Write-Status "Binary size: $([math]::Round($binaryInfo.Length / 1MB, 2)) MB"

    if ($Verbose) {
        Write-Status "Binary details:"
        Write-Host "  Path: $($binaryInfo.FullName)" -ForegroundColor Gray
        Write-Host "  Size: $($binaryInfo.Length) bytes" -ForegroundColor Gray
        Write-Host "  Created: $($binaryInfo.CreationTime)" -ForegroundColor Gray
    }

    Write-Host ""
    Write-Status "Backend binary ready for deployment"
    Write-Host ""

}
catch {
    Write-Error "Backend build failed: $($_.Exception.Message)"
    exit 1
}
finally {
    # Return to project root
    Set-Location $ProjectRoot
}
