# Siros Backend Test Orchestration Script for PowerShell
# Orchestrates comprehensive backend validation including tests, code quality, and security

[CmdletBinding()]
param(
    [switch]$VerboseOutput,
    [switch]$Coverage,
    [string]$TestSuite = "all",
    [switch]$SkipInstall,
    [string]$Config = "",
    [switch]$Help
)

if ($Help) {
    Write-Host "🧪 Siros Backend Test Orchestration" -ForegroundColor Blue
    Write-Host ""
    Write-Host "USAGE:" -ForegroundColor Yellow
    Write-Host "  .\scripts\test_backend.ps1 [options]"
    Write-Host ""
    Write-Host "OPTIONS:" -ForegroundColor Yellow
    Write-Host "  -VerboseOutput      Enable verbose output"
    Write-Host "  -Coverage           Generate test coverage reports"
    Write-Host "  -TestSuite <suite>  Run specific test suite (all, models, services, controllers, repositories, integration)"
    Write-Host "  -SkipInstall        Skip automatic tool installation/updates"
    Write-Host "  -Config <path>      Use custom config file"
    Write-Host "  -Help               Show this help message"
    Write-Host ""
    Write-Host "ORCHESTRATION FLOW:" -ForegroundColor Yellow
    Write-Host "  1. backend_gotest   Core functionality tests"
    Write-Host "  2. backend_lint     Code quality analysis"
    Write-Host "  3. backend_gosec    Security vulnerability scan"
    Write-Host ""
    Write-Host "TEST SUITES:" -ForegroundColor Yellow
    Write-Host "  all          Complete backend test suite"
    Write-Host "  models       Business logic and validation tests"
    Write-Host "  services     Business logic orchestration tests"
    Write-Host "  controllers  HTTP handler and API tests"
    Write-Host "  repositories Data access layer tests"
    Write-Host "  integration  End-to-end tests with real dependencies"
    Write-Host ""
    Write-Host "EXAMPLES:" -ForegroundColor Yellow
    Write-Host "  .\scripts\test_backend.ps1                     # Run all backend tests"
    Write-Host "  .\scripts\test_backend.ps1 -Coverage           # Run with coverage"
    Write-Host "  .\scripts\test_backend.ps1 -TestSuite models   # Run model tests only"
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

Write-Host ""
Write-Host "🧪 Siros Backend Test Orchestration" -ForegroundColor Blue
Write-Host ""

# Check if we're in the right directory
if (-not (Test-Path $BackendDir)) {
    Write-Error "Backend directory not found at: $BackendDir"
    Write-Warning "Please run this script from the project root"
    exit 1
}

Write-Status "Backend test orchestration starting..."
Write-Status "Project root: $ProjectRoot"

# Prepare component script arguments
$componentArgs = @{}
if ($VerboseOutput) { $componentArgs.VerboseOutput = $true }
if ($Coverage) { $componentArgs.Coverage = $true }
if ($TestSuite -ne "all") { $componentArgs.TestSuite = $TestSuite }
if ($SkipInstall) { $componentArgs.SkipInstall = $true }
if ($Config) { $componentArgs.Config = $Config }

try {
    $overallSuccess = $true
    $startTime = Get-Date

    # Step 1: Core functionality tests first
    Write-Host ""
    Write-Status "Step 1/3: Running core functionality tests (backend_gotest)..."

    $gotestScript = Join-Path $ScriptDir "backend\backend_gotest.ps1"
    if (Test-Path $gotestScript) {
        & $gotestScript @componentArgs
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Backend Go tests failed!"
            $overallSuccess = $false
        }
        else {
            Write-Success "Backend Go tests passed!"
        }
    }
    else {
        Write-Warning "backend_gotest.ps1 not found at: $gotestScript"
        Write-Warning "Skipping Go tests step"
    }

    # Step 2: Code quality analysis
    Write-Host ""
    Write-Status "Step 2/3: Running code quality analysis (backend_lint)..."

    $lintScript = Join-Path $ScriptDir "backend\backend_lint.ps1"
    if (Test-Path $lintScript) {
        & $lintScript @componentArgs
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Backend linting found issues, but continuing..."
            # Don't fail overall for linting issues, just warn
        }
        else {
            Write-Success "Backend linting passed!"
        }
    }
    else {
        Write-Warning "backend_lint.ps1 not found at: $lintScript"
        Write-Warning "Skipping linting step"
    }

    # Step 3: Security vulnerability scan
    Write-Host ""
    Write-Status "Step 3/3: Running security vulnerability scan (backend_gosec)..."

    $gosecScript = Join-Path $ScriptDir "backend\backend_gosec.ps1"
    if (Test-Path $gosecScript) {
        & $gosecScript @componentArgs
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Backend security scan found issues, but continuing..."
            # Don't fail overall for security warnings, just warn
        }
        else {
            Write-Success "Backend security scan passed!"
        }
    }
    else {
        Write-Warning "backend_gosec.ps1 not found at: $gosecScript"
        Write-Warning "Skipping security scan step"
    }

    # Final results
    $endTime = Get-Date
    $duration = $endTime - $startTime

    Write-Host ""
    Write-Host "=" * 60 -ForegroundColor Blue
    if ($overallSuccess) {
        Write-Success "Backend test orchestration completed successfully! ($($duration.TotalSeconds.ToString('F2'))s)"
        Write-Host ""
        exit 0
    }
    else {
        Write-Error "Backend test orchestration failed! ($($duration.TotalSeconds.ToString('F2'))s)"
        Write-Warning "Check the output above for specific failures"
        Write-Host ""
        exit 1
    }

}
catch {
    Write-Error "Backend test orchestration failed: $($_.Exception.Message)"
    exit 1
}
