# Siros Frontend Linting Script for PowerShell
# Runs TypeScript/React code quality checks using ESLint and TypeScript compiler

param(
    [switch]$VerboseOutput,
    [switch]$SkipLint,
    [switch]$SkipTypeCheck,
    [switch]$Fix
)

# Set error action preference
$ErrorActionPreference = "Stop"

Write-Host "🔍 Running Siros frontend code quality checks..." -ForegroundColor Blue

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

# Get script directory and project root
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ScriptsDir = Split-Path -Parent $ScriptDir
$ProjectRoot = Split-Path -Parent $ScriptsDir

try {
    # Check if frontend dependencies exist
    if (-not (Test-Path "$ProjectRoot\frontend\package.json")) {
        Write-Error "Frontend package.json not found!"
        exit 1
    }

    if (-not (Test-Path "$ProjectRoot\frontend\node_modules")) {
        Write-Error "Frontend dependencies not found!"
        Write-Host "Run 'npm ci' in the frontend directory first" -ForegroundColor Yellow
        exit 1
    }

    Set-Location "$ProjectRoot\frontend"

    # ESLint checking
    if (-not $SkipLint) {
        Write-Status "Running frontend linting (ESLint)..."

        $lintCommand = if ($Fix) { "lint:fix" } else { "lint" }
        Write-Host "  Running: npm run $lintCommand" -ForegroundColor Gray
        Write-Host ""  # Add spacing for better readability

        # Use Start-Process to preserve exact output formatting and colors
        $process = Start-Process -FilePath "npm" -ArgumentList "run", $lintCommand -NoNewWindow -Wait -PassThru
        $lintExitCode = $process.ExitCode

        Write-Host ""  # Add spacing after output
        if ($lintExitCode -eq 0) {
            Write-Success "Frontend linting passed!"
        }
        else {
            Write-Error "Frontend linting failed! (Exit code: $lintExitCode)"
            exit 1
        }
    }

    # TypeScript type checking
    if (-not $SkipTypeCheck) {
        Write-Status "Running TypeScript type checking..."
        Write-Host "  Running: npm run type-check" -ForegroundColor Gray
        Write-Host ""  # Add spacing for better readability

        # Use Start-Process to preserve exact output formatting and colors
        $process = Start-Process -FilePath "npm" -ArgumentList "run", "type-check" -NoNewWindow -Wait -PassThru
        $typeCheckExitCode = $process.ExitCode

        Write-Host ""  # Add spacing after output
        if ($typeCheckExitCode -eq 0) {
            Write-Success "TypeScript type checking passed!"
        }
        else {
            Write-Error "TypeScript type checking failed! (Exit code: $typeCheckExitCode)"
            exit 1
        }
    }

    # Prettier formatting check (optional)
    Write-Status "Checking code formatting (Prettier)..."
    Write-Host "  Running: npm run format:check" -ForegroundColor Gray
    Write-Host ""  # Add spacing for better readability

    $process = Start-Process -FilePath "npm" -ArgumentList "run", "format:check" -NoNewWindow -Wait -PassThru -ErrorAction SilentlyContinue
    $formatExitCode = $process.ExitCode

    Write-Host ""  # Add spacing after output
    if ($formatExitCode -eq 0) {
        Write-Success "Code formatting is correct!"
    }
    else {
        Write-Warning "Code formatting issues found"
        Write-Host "Run 'npm run format' to fix formatting issues" -ForegroundColor Yellow
    }

    Write-Success "Frontend code quality checks completed successfully! ✨"
}
catch {
    Write-Error "Frontend linting script failed: $_"
    exit 1
}
finally {
    # Return to project root
    Set-Location $ProjectRoot
}
