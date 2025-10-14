# Siros Linting Script for PowerShell
# Runs code quality checks for both backend and frontend

param(
    [switch]$Verbose,
    [switch]$SkipBackend,
    [switch]$SkipFrontend,
    [switch]$SkipTypeCheck
)

# Set error action preference
$ErrorActionPreference = "Stop"

Write-Host "🔍 Running Siros code quality checks..." -ForegroundColor Blue

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
$ProjectRoot = Split-Path -Parent $ScriptDir

try {
    # Backend linting
    if (-not $SkipBackend) {
        Write-Status "Running backend linting (golangci-lint)..."
        Set-Location "$ProjectRoot\backend"

        # Check if golangci-lint is available
        $golangciPath = Get-Command golangci-lint -ErrorAction SilentlyContinue
        if ($golangciPath) {
            $lintResult = & golangci-lint run
            if ($LASTEXITCODE -eq 0) {
                Write-Success "Backend linting passed!"
            }
            else {
                Write-Error "Backend linting failed!"
                if ($Verbose) {
                    Write-Host $lintResult
                }
                exit 1
            }
        }
        else {
            Write-Warning "golangci-lint not found, skipping backend linting"
            Write-Warning "Install with: go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
        }
    }

    # Frontend linting
    if (-not $SkipFrontend) {
        Write-Status "Running frontend linting (ESLint)..."
        Set-Location "$ProjectRoot\frontend"

        if ((Test-Path "package.json") -and (Test-Path "node_modules")) {
            $lintResult = & npm run lint
            if ($LASTEXITCODE -eq 0) {
                Write-Success "Frontend linting passed!"
            }
            else {
                Write-Error "Frontend linting failed!"
                if ($Verbose) {
                    Write-Host $lintResult
                }
                exit 1
            }
        }
        else {
            Write-Warning "Frontend dependencies not found, skipping frontend linting"
            Write-Warning "Run 'npm ci' in the frontend directory first"
        }
    }

    # Type checking
    if (-not $SkipTypeCheck) {
        Write-Status "Running TypeScript type checking..."
        if ((Test-Path "$ProjectRoot\frontend\package.json") -and (Test-Path "$ProjectRoot\frontend\node_modules")) {
            Set-Location "$ProjectRoot\frontend"
            $typeCheckResult = & npm run type-check
            if ($LASTEXITCODE -eq 0) {
                Write-Success "TypeScript type checking passed!"
            }
            else {
                Write-Error "TypeScript type checking failed!"
                if ($Verbose) {
                    Write-Host $typeCheckResult
                }
                exit 1
            }
        }
        else {
            Write-Warning "Frontend dependencies not found, skipping type checking"
        }
    }

    Write-Success "All linting checks completed successfully! ✨"
}
catch {
    Write-Error "Linting script failed: $_"
    exit 1
}
finally {
    # Return to project root
    Set-Location $ProjectRoot
}
