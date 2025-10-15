# Siros Backend Linting Script for PowerShell
# Runs Go code quality checks using golangci-lint and optional security scanning

[CmdletBinding()]
param(
    [switch]$VerboseOutput,
    [switch]$SkipInstall,
    [string]$Config = "",
    [switch]$Help
)

if ($Help) {
    Write-Host "🔍 Siros Backend Code Quality Checker" -ForegroundColor Blue
    Write-Host ""
    Write-Host "USAGE:" -ForegroundColor Yellow
    Write-Host "  .\scripts\backend_lint.ps1 [options]"
    Write-Host ""
    Write-Host "OPTIONS:" -ForegroundColor Yellow
    Write-Host "  -VerboseOutput      Enable verbose output"
    Write-Host "  -SkipInstall        Skip automatic tool installation/updates"
    Write-Host "  -Config <path>      Use custom golangci-lint config file"
    Write-Host "  -Help               Show this help message"
    Write-Host ""
    Write-Host "EXAMPLES:" -ForegroundColor Yellow
    Write-Host "  .\scripts\backend_lint.ps1                      # Run with default settings"
    Write-Host "  .\scripts\backend_lint.ps1 -VerboseOutput       # Run with verbose output"
    Write-Host "  .\scripts\backend_lint.ps1 -SkipInstall       # Skip tool updates"
    exit 0
}

# Set error action preference
$ErrorActionPreference = "Stop"

Write-Host "🔍 Running Siros backend code quality checks..." -ForegroundColor Blue

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
    # Backend linting
    Write-Status "Running backend linting (golangci-lint)..."
    Set-Location "$ProjectRoot\backend"

    # Check if golangci-lint is available
    $golangciPath = Get-Command golangci-lint -ErrorAction SilentlyContinue
    if ($golangciPath) {
        if (-not $SkipInstall) {
            Write-Status "golangci-lint found, updating to latest version..."
            go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
            if ($LASTEXITCODE -eq 0) {
                Write-Success "golangci-lint updated to latest version"
            }
            else {
                Write-Warning "Failed to update golangci-lint, using existing version"
            }
        }
        else {
            Write-Status "golangci-lint found, skipping update (SkipInstall flag set)"
        }

        # Determine config path
        $configPath = if ($Config) { $Config } else { "$ProjectRoot\.golangci.yml" }

        if ($VerboseOutput) {
            Write-Host "  Using config: $configPath" -ForegroundColor Gray
        }

        Write-Host "  Running: golangci-lint run --config $configPath" -ForegroundColor Gray
        Write-Host ""  # Add spacing for better readability

        # Build arguments
        $golangciArgs = @("run", "--config", $configPath)
        if ($VerboseOutput) {
            $golangciArgs += "--verbose"
        }

        # Use Start-Process to preserve exact output formatting and colors
        $process = Start-Process -FilePath "golangci-lint" -ArgumentList $golangciArgs -NoNewWindow -Wait -PassThru
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
        if (-not $SkipInstall) {
            Write-Status "golangci-lint not found, installing latest version..."
            go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Failed to install golangci-lint!"
                exit 1
            }
            Write-Success "golangci-lint installed successfully"

            # Set config path after installation
            $configPath = if ($Config) { $Config } else { "$ProjectRoot\.golangci.yml" }
        }
        else {
            Write-Error "golangci-lint not found and SkipInstall flag is set!"
            Write-Warning "Please install manually: go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
            exit 1
        }
    }

    Write-Success "Backend code quality checks completed successfully! ✨"
}
catch {
    Write-Error "Backend linting script failed: $_"
    exit 1
}
finally {
    # Return to project root
    Set-Location $ProjectRoot
}
