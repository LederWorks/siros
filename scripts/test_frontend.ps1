# Siros Frontend Test Orchestration Script for PowerShell
# Orchestrates comprehensive frontend validation including linting, type checking, and tests

[CmdletBinding()]
param(
    [switch]$VerboseOutput,
    [switch]$Coverage,
    [switch]$Watch,
    [switch]$SkipInstall,
    [string]$Config = "",
    [switch]$Help
)

if ($Help) {
    Write-Host "🧪 Siros Frontend Test Orchestration" -ForegroundColor Blue
    Write-Host ""
    Write-Host "This script orchestrates comprehensive frontend testing through specialized components:" -ForegroundColor White
    Write-Host ""
    Write-Host "ORCHESTRATION FLOW:" -ForegroundColor Yellow
    Write-Host "  1. frontend_lint.ps1    - Code quality analysis (ESLint + TypeScript)" -ForegroundColor Gray
    Write-Host "  2. frontend_test.ps1    - Unit tests (Jest/Vitest when implemented)" -ForegroundColor Gray
    Write-Host "  3. frontend_typecheck.ps1 - TypeScript compilation verification" -ForegroundColor Gray
    Write-Host ""
    Write-Host "USAGE:" -ForegroundColor Yellow
    Write-Host "  .\scripts\test_frontend.ps1 [options]"
    Write-Host ""
    Write-Host "OPTIONS:" -ForegroundColor Yellow
    Write-Host "  -VerboseOutput      Enable verbose output across all components"
    Write-Host "  -SkipInstall        Skip automatic tool installation/updates"
    Write-Host "  -Coverage           Enable test coverage reporting (when tests implemented)"
    Write-Host "  -Watch              Run tests in watch mode (when tests implemented)"
    Write-Host "  -Config <path>      Use custom config file"
    Write-Host "  -Help               Show this help message"
    Write-Host ""
    Write-Host "EXAMPLES:" -ForegroundColor Yellow
    Write-Host "  .\scripts\test_frontend.ps1                    # Run full frontend test orchestration"
    Write-Host "  .\scripts\test_frontend.ps1 -VerboseOutput     # Run with verbose output"
    Write-Host "  .\scripts\test_frontend.ps1 -Coverage          # Run with coverage reporting"
    Write-Host "  .\scripts\test_frontend.ps1 -Watch             # Run in watch mode"
    Write-Host ""
    Write-Host "COMPONENT SCRIPTS:" -ForegroundColor Yellow
    Write-Host "  frontend/frontend_lint.ps1      - ESLint and TypeScript linting"
    Write-Host "  frontend/frontend_test.ps1      - Jest/Vitest unit testing (future)"
    Write-Host "  frontend/frontend_typecheck.ps1 - TypeScript compilation check (future)"
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
$FrontendDir = Join-Path $ProjectRoot "frontend"

Write-Host ""
Write-Host "🧪 Siros Frontend Test Orchestration" -ForegroundColor Blue
Write-Host ""

# Check if frontend directory exists
if (-not (Test-Path $FrontendDir)) {
    Write-Error "Frontend directory not found at: $FrontendDir"
    Write-Warning "Please run this script from the project root"
    exit 1
}

Write-Status "Frontend test orchestration starting..."
Write-Status "Project root: $ProjectRoot"

# Prepare component script arguments
$componentArgs = @()
if ($VerboseOutput) { $componentArgs += "-VerboseOutput" }
if ($SkipInstall) { $componentArgs += "-SkipInstall" }
if ($Coverage) { $componentArgs += "-Coverage" }
if ($Watch) { $componentArgs += "-Watch" }
if ($Config) { $componentArgs += "-Config"; $componentArgs += $Config }

$overallSuccess = $true
$startTime = Get-Date

# Step 1: Code quality analysis (ESLint + TypeScript)
Write-Host ""
Write-Status "Step 1/3: Running code quality analysis (frontend_lint)..."

$lintScript = Join-Path $ScriptDir "frontend\frontend_lint.ps1"
if (Test-Path $lintScript) {
    try {
        & $lintScript @componentArgs
        Write-Success "Frontend linting passed!"
    }
    catch {
        Write-Warning "Frontend linting found issues, but continuing..."
        # Don't fail overall for linting issues, just warn
    }
}
else {
    Write-Warning "frontend_lint.ps1 not found at: $lintScript"
    Write-Warning "Skipping linting step"
}

# Step 2: Unit tests (when implemented)
Write-Host ""
Write-Status "Step 2/3: Running unit tests (frontend_test)..."

$testScript = Join-Path $ScriptDir "frontend\frontend_test.ps1"
if (Test-Path $testScript) {
    try {
        & $testScript @componentArgs
        Write-Success "Frontend tests passed!"
    }
    catch {
        Write-Error "Frontend tests failed!"
        $overallSuccess = $false
    }
}
else {
    Write-Warning "frontend_test.ps1 not found at: $testScript"
    Write-Warning "Frontend unit testing not yet implemented - skipping"
}

# Step 3: TypeScript compilation verification (when implemented)
Write-Host ""
Write-Status "Step 3/3: Running TypeScript compilation verification (frontend_typecheck)..."

$typecheckScript = Join-Path $ScriptDir "frontend\frontend_typecheck.ps1"
if (Test-Path $typecheckScript) {
    try {
        & $typecheckScript @componentArgs
        Write-Success "TypeScript compilation verification passed!"
    }
    catch {
        Write-Error "TypeScript compilation verification failed!"
        $overallSuccess = $false
    }
}
else {
    Write-Warning "frontend_typecheck.ps1 not found at: $typecheckScript"
    Write-Warning "TypeScript type checking not yet implemented - skipping"
}

# Final results
$endTime = Get-Date
$duration = [math]::Round(($endTime - $startTime).TotalSeconds, 1)

Write-Host ""
Write-Host "============================================================" -ForegroundColor Gray
if ($overallSuccess) {
    Write-Success "Frontend test orchestration completed successfully! ($($duration)s)"
    Write-Host ""
    exit 0
}
else {
    Write-Error "Frontend test orchestration failed! ($($duration)s)"
    Write-Warning "Check the output above for specific failures"
    Write-Host ""
    exit 1
}
