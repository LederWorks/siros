# Siros Frontend Build Script for PowerShell
# Builds the React/TypeScript frontend application

[CmdletBinding()]
param(
    [switch]$VerboseOutput,
    [switch]$SkipInstall,
    [string]$Config = "",
    [switch]$Help
)

if ($Help) {
    Write-Host "🎨 Siros Frontend Build" -ForegroundColor Blue
    Write-Host ""
    Write-Host "USAGE:" -ForegroundColor Yellow
    Write-Host "  .\scripts\build_frontend.ps1 [options]"
    Write-Host ""
    Write-Host "OPTIONS:" -ForegroundColor Yellow
    Write-Host "  -VerboseOutput      Enable verbose output"
    Write-Host "  -SkipInstall        Skip automatic dependency installation"
    Write-Host "  -Config <path>      Use custom config file"
    Write-Host "  -Help               Show this help message"
    Write-Host ""
    Write-Host "DESCRIPTION:" -ForegroundColor Yellow
    Write-Host "  Builds the React/TypeScript frontend application using Vite."
    Write-Host "  Creates optimized production build in frontend/dist directory."
    Write-Host ""
    Write-Host "EXAMPLES:" -ForegroundColor Yellow
    Write-Host "  .\scripts\build_frontend.ps1                    # Build with default settings"
    Write-Host "  .\scripts\build_frontend.ps1 -VerboseOutput     # Build with verbose output"
    Write-Host "  .\scripts\build_frontend.ps1 -SkipInstall       # Build without installing dependencies"
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
$ScriptsDir = Split-Path -Parent $ScriptDir
$ProjectRoot = Split-Path -Parent $ScriptsDir
$FrontendDir = Join-Path $ProjectRoot "frontend"

Write-Host ""
Write-Host "🎨 Siros Frontend Build" -ForegroundColor Blue
Write-Host ""

# Check if we're in the right directory
if (-not (Test-Path $FrontendDir)) {
    Write-Error "Frontend directory not found at: $FrontendDir"
    Write-Warning "Please run this script from the project root"
    exit 1
}

try {
    # Change to frontend directory
    Set-Location $FrontendDir
    Write-Status "Working in frontend directory: $FrontendDir"

    # Check Node.js availability
    $nodeVersion = Get-Command node -ErrorAction SilentlyContinue
    if (-not $nodeVersion) {
        Write-Error "Node.js not found! Please install Node.js to build the frontend."
        exit 1
    }

    if ($VerboseOutput) {
        $nodeVersionOutput = node --version
        Write-Status "Using Node.js version: $nodeVersionOutput"
    }

    # Check npm availability
    $npmVersion = Get-Command npm -ErrorAction SilentlyContinue
    if (-not $npmVersion) {
        Write-Error "npm not found! Please install npm to build the frontend."
        exit 1
    }

    if ($VerboseOutput) {
        $npmVersionOutput = npm --version
        Write-Status "Using npm version: $npmVersionOutput"
    }

    # Install dependencies if needed and not skipped
    if (-not $SkipInstall) {
        if (-not (Test-Path "node_modules") -or -not (Test-Path "package-lock.json")) {
            Write-Status "Installing frontend dependencies..."
            npm install
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Failed to install frontend dependencies!"
                exit 1
            }
            Write-Success "Frontend dependencies installed successfully"
        }
        else {
            Write-Status "Dependencies already installed, using existing ones"
        }
    }
    else {
        Write-Status "Skipping dependency installation (SkipInstall flag set)"
        if (-not (Test-Path "node_modules")) {
            Write-Error "node_modules not found and SkipInstall flag is set!"
            Write-Warning "Please install dependencies manually: npm install"
            exit 1
        }
    }

    # Clean previous build
    if (Test-Path "dist") {
        Write-Status "Cleaning previous build..."
        Remove-Item "dist" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Success "Previous build cleaned"
    }

    # Build the frontend
    Write-Status "Building React/TypeScript frontend..."

    if ($VerboseOutput) {
        npm run build
    }
    else {
        npm run build 2>$null
    }

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Frontend build failed!"
        exit 1
    }

    # Verify build output
    if (-not (Test-Path "dist")) {
        Write-Error "Build completed but dist directory not found!"
        exit 1
    }

    $distFiles = Get-ChildItem "dist" -Recurse | Measure-Object
    Write-Success "Frontend build completed successfully!"
    Write-Status "Build output: frontend/dist ($($distFiles.Count) files generated)"

    if ($VerboseOutput) {
        Write-Status "Build contents:"
        Get-ChildItem "dist" -Recurse | ForEach-Object {
            Write-Host "  $($_.FullName.Replace($PWD, '.'))" -ForegroundColor Gray
        }
    }

    Write-Host ""
    Write-Status "Frontend build artifacts ready for embedding in backend binary"
    Write-Host ""

}
catch {
    Write-Error "Frontend build failed: $($_.Exception.Message)"
    exit 1
}
finally {
    # Return to project root
    Set-Location $ProjectRoot
}
