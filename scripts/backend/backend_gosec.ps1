# Siros Backend Security Scanning Script for PowerShell
# Runs gosec security analysis on Go backend code

[CmdletBinding()]
param(
    [switch]$VerboseOutput,
    [switch]$Json,
    [switch]$SkipInstall,
    [string]$Format = "text",
    [string]$Output = "",
    [switch]$NoFail,
    [switch]$Help
)

if ($Help) {
    Write-Host "🔒 Siros Backend Security Scanner" -ForegroundColor Blue
    Write-Host ""
    Write-Host "USAGE:" -ForegroundColor Yellow
    Write-Host "  .\scripts\backend\backend_gosec.ps1 [options]"
    Write-Host ""
    Write-Host "OPTIONS:" -ForegroundColor Yellow
    Write-Host "  -VerboseOutput      Enable verbose output"
    Write-Host "  -Json               Output results in JSON format"
    Write-Host "  -SkipInstall        Skip automatic tool installation/updates"
    Write-Host "  -Format <format>    Output format (text, json, yaml, csv, sonarqube, junit-xml)"
    Write-Host "  -Output <file>      Output file path"
    Write-Host "  -NoFail             Don't fail on security issues"
    Write-Host "  -Help               Show this help message"
    Write-Host ""
    Write-Host "EXAMPLES:" -ForegroundColor Yellow
    Write-Host "  .\scripts\backend\backend_gosec.ps1                      # Run with default settings"
    Write-Host "  .\scripts\backend\backend_gosec.ps1 -VerboseOutput       # Run with verbose output"
    Write-Host "  .\scripts\backend\backend_gosec.ps1 -Json                # Output in JSON format"
    exit 0
}

# Set error action preference
$ErrorActionPreference = "Stop"

Write-Host "🔒 Running Siros backend security scan (gosec)..." -ForegroundColor Blue

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
    Write-Status "Running gosec security scanner on backend..."
    Set-Location "$ProjectRoot\backend"

    # Check if gosec is available
    $gosecPath = Get-Command gosec -ErrorAction SilentlyContinue
    if ($gosecPath) {
        if (-not $SkipInstall) {
            Write-Status "gosec found, updating to latest version..."
            $updateProcess = Start-Process -FilePath "go" -ArgumentList "install", "github.com/securecodewarrior/gosec/v2/cmd/gosec@latest" -NoNewWindow -Wait -PassThru
            if ($updateProcess.ExitCode -eq 0) {
                Write-Success "gosec updated to latest version"
            }
            else {
                Write-Warning "Failed to update gosec, using existing version"
            }
        }
        else {
            Write-Status "gosec found, skipping update (SkipInstall flag set)"
        }
    }
    else {
        if (-not $SkipInstall) {
            Write-Status "gosec not found, installing..."
            Write-Host "  Running: go install github.com/securecodewarrior/gosec/v2/cmd/gosec@latest" -ForegroundColor Gray

            $installProcess = Start-Process -FilePath "go" -ArgumentList "install", "github.com/securecodewarrior/gosec/v2/cmd/gosec@latest" -NoNewWindow -Wait -PassThru
            if ($installProcess.ExitCode -ne 0) {
                Write-Error "Failed to install gosec! Please install manually with: go install github.com/securecodewarrior/gosec/v2/cmd/gosec@latest"
                exit 1
            }

            Write-Success "gosec installed successfully!"

            # Refresh PATH for current session
            $gosecPath = Get-Command gosec -ErrorAction SilentlyContinue
            if (-not $gosecPath) {
                Write-Error "gosec still not found after installation. Please restart your terminal."
                exit 1
            }
        }
        else {
            Write-Error "gosec not found and SkipInstall flag is set!"
            Write-Warning "Please install manually: go install github.com/securecodewarrior/gosec/v2/cmd/gosec@latest"
            exit 1
        }
    }

    # Build gosec command arguments
    $gosecArgs = @("./...")

    if ($Json) {
        $gosecArgs += "-fmt=json"
    }
    elseif ($Format -ne "text") {
        $gosecArgs += "-fmt=$Format"
    }

    if ($Output) {
        $gosecArgs += "-out=$Output"
    }

    if ($NoFail) {
        $gosecArgs += "-no-fail"
    }

    if ($VerboseOutput) {
        $gosecArgs += "-verbose"
    }

    # Display command being run
    $commandStr = "gosec " + ($gosecArgs -join " ")
    Write-Host "  Running: $commandStr" -ForegroundColor Gray
    Write-Host ""  # Add spacing for better readability

    # Run gosec
    $process = Start-Process -FilePath "gosec" -ArgumentList $gosecArgs -NoNewWindow -Wait -PassThru
    $gosecExitCode = $process.ExitCode

    Write-Host ""  # Add spacing after output

    # Check results
    if ($gosecExitCode -eq 0) {
        Write-Success "Security scan completed successfully! No issues found. ✨"
    }
    elseif ($NoFail) {
        Write-Warning "Security scan completed with issues, but -NoFail flag was used."
        Write-Warning "Check the output above for security findings."
    }
    else {
        Write-Error "Security scan found issues! (Exit code: $gosecExitCode)"
        Write-Error "Review the security findings above and fix them before proceeding."
        exit 1
    }
}
catch {
    Write-Error "Security scanning script failed: $_"
    exit 1
}
finally {
    # Return to project root
    Set-Location $ProjectRoot
}
