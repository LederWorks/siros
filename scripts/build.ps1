# Siros Full Production Build Script for PowerShell
# Builds the complete Siros platform using modular frontend and backend scripts

[CmdletBinding()]
param(
    [switch]$VerboseOutput,
    [switch]$SkipInstall,
    [switch]$SkipTests,
    [string]$Config = "",
    [switch]$Help
)

if ($Help) {
    Write-Host "🔨 Siros Full Production Build" -ForegroundColor Blue
    Write-Host ""
    Write-Host "USAGE:" -ForegroundColor Yellow
    Write-Host "  .\scripts\build.ps1 [options]"
    Write-Host ""
    Write-Host "OPTIONS:" -ForegroundColor Yellow
    Write-Host "  -VerboseOutput      Enable verbose output"
    Write-Host "  -SkipInstall        Skip automatic dependency installation"
    Write-Host "  -SkipTests          Skip testing steps and build directly"
    Write-Host "  -Config <path>      Use custom config file"
    Write-Host "  -Help               Show this help message"
    Write-Host ""
    Write-Host "DESCRIPTION:" -ForegroundColor Yellow
    Write-Host "  Builds the complete Siros platform in production mode:"
    if (-not $SkipTests) {
        Write-Host "  1. Tests frontend (scripts\test_frontend.ps1)"
        Write-Host "  2. Builds React frontend (scripts\frontend\frontend_build.ps1)"
        Write-Host "  3. Tests backend (scripts\test_backend.ps1)"
        Write-Host "  4. Builds Go backend with embedded frontend assets (scripts\backend\backend_build.ps1)"
        Write-Host "  5. Creates single production binary at build/siros.exe"
    }
    else {
        Write-Host "  1. Builds React frontend (scripts\frontend\frontend_build.ps1)"
        Write-Host "  2. Builds Go backend with embedded frontend assets (scripts\backend\backend_build.ps1)"
        Write-Host "  3. Creates single production binary at build/siros.exe"
    }
    Write-Host ""
    Write-Host "EXAMPLES:" -ForegroundColor Yellow
    Write-Host "  .\scripts\build.ps1                    # Build with default settings (includes tests)"
    Write-Host "  .\scripts\build.ps1 -VerboseOutput     # Build with verbose output"
    Write-Host "  .\scripts\build.ps1 -SkipTests         # Build without running tests"
    Write-Host "  .\scripts\build.ps1 -SkipInstall       # Build without installing dependencies"
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

Write-Host ""
Write-Host "� Siros Full Production Build" -ForegroundColor Blue
Write-Host ""

# Check if we're in the right directory
if (-not (Test-Path (Join-Path $ProjectRoot "backend")) -or -not (Test-Path (Join-Path $ProjectRoot "frontend"))) {
    Write-Error "Backend or frontend directory not found"
    Write-Warning "Please run this script from the project root"
    exit 1
}

try {
    if (-not $SkipTests) {
        # Step 1: Test frontend first
        Write-Status "Step 1/4: Testing frontend..."
        $frontendTestArgs = @()
        if ($VerboseOutput) { $frontendTestArgs += "-VerboseOutput" }
        if ($SkipInstall) { $frontendTestArgs += "-SkipInstall" }
        if ($Config) { $frontendTestArgs += "-Config", $Config }

        $frontendTestScript = Join-Path $ScriptDir "test_frontend.ps1"
        & $frontendTestScript @frontendTestArgs

        if ($LASTEXITCODE -ne 0) {
            Write-Error "Frontend tests failed!"
            exit 1
        }
        Write-Success "Frontend tests completed"
    }

    # Step 2: Build frontend (or Step 1 if skipping tests)
    $stepNumber = if ($SkipTests) { "1/2" } else { "2/4" }
    Write-Status "Step ${stepNumber}: Building React frontend..."
    $frontendArgs = @()
    if ($VerboseOutput) { $frontendArgs += "-VerboseOutput" }
    if ($SkipInstall) { $frontendArgs += "-SkipInstall" }
    if ($Config) { $frontendArgs += "-Config", $Config }

    $frontendScript = Join-Path $ScriptDir "frontend\frontend_build.ps1"
    & $frontendScript @frontendArgs

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Frontend build failed!"
        exit 1
    }
    Write-Success "Frontend build completed"

    if (-not $SkipTests) {
        # Step 3: Test backend
        Write-Status "Step 3/4: Testing backend..."
        $backendTestArgs = @()
        if ($VerboseOutput) { $backendTestArgs += "-VerboseOutput" }
        if ($SkipInstall) { $backendTestArgs += "-SkipInstall" }
        if ($Config) { $backendTestArgs += "-Config", $Config }

        $backendTestScript = Join-Path $ScriptDir "test_backend.ps1"
        & $backendTestScript @backendTestArgs

        if ($LASTEXITCODE -ne 0) {
            Write-Error "Backend tests failed!"
            exit 1
        }
        Write-Success "Backend tests completed"
    }

    # Step 4: Build backend with embedded frontend (or Step 2 if skipping tests)
    $stepNumber = if ($SkipTests) { "2/2" } else { "4/4" }
    Write-Status "Step ${stepNumber}: Building Go backend with embedded frontend..."
    $backendArgs = @()
    if ($VerboseOutput) { $backendArgs += "-VerboseOutput" }
    if ($SkipInstall) { $backendArgs += "-SkipInstall" }
    if ($Config) { $backendArgs += "-Config", $Config }

    $backendScript = Join-Path $ScriptDir "backend\backend_build.ps1"
    & $backendScript @backendArgs

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Backend build failed!"
        exit 1
    }
    Write-Success "Backend build completed"

    # Verify final binary
    $binaryPath = Join-Path $ProjectRoot "build" "siros.exe"
    if (-not (Test-Path $binaryPath)) {
        Write-Error "Build completed but binary not found at: $binaryPath"
        exit 1
    }

    $binaryInfo = Get-Item $binaryPath
    Write-Host ""
    Write-Success "Complete production build finished!"
    Write-Status "Binary location: $binaryPath"
    Write-Status "Binary size: $([math]::Round($binaryInfo.Length / 1MB, 2)) MB"
    Write-Host ""
    Write-Host "🏃 To run the server:" -ForegroundColor Cyan
    Write-Host "   .\build\siros.exe" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🌐 The server will be available at:" -ForegroundColor Cyan
    Write-Host "   Frontend: http://localhost:8080" -ForegroundColor Gray
    Write-Host "   API:      http://localhost:8080/api/v1" -ForegroundColor Gray
    Write-Host ""

}
catch {
    Write-Error "Build failed: $($_.Exception.Message)"
    exit 1
}
