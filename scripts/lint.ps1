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
            $configPath = "$ProjectRoot\.golangci.yml"
            Write-Host "  Running: golangci-lint run --config $configPath" -ForegroundColor Gray
            Write-Host ""  # Add spacing for better readability

            # Use Start-Process to preserve exact output formatting and colors
            $process = Start-Process -FilePath "golangci-lint" -ArgumentList "run", "--config", $configPath -NoNewWindow -Wait -PassThru
            $lintExitCode = $process.ExitCode

            Write-Host ""  # Add spacing after output
            if ($lintExitCode -eq 0) {
                Write-Success "Backend linting passed!"
            }
            else {
                Write-Error "Backend linting failed! (Exit code: $lintExitCode)"
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
            Write-Host "  Running: npm run lint" -ForegroundColor Gray
            Write-Host ""  # Add spacing for better readability

            # Use Start-Process to preserve exact output formatting and colors
            $process = Start-Process -FilePath "npm" -ArgumentList "run", "lint" -NoNewWindow -Wait -PassThru
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
