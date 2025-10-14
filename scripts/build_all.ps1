# Siros Full Production Build - Windows PowerShell Version
param(
    [switch]$Help
)

if ($Help) {
    Write-Host "🔨 Siros Full Production Build" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: .\scripts\build_all.ps1"
    Write-Host ""
    Write-Host "This script builds the complete Siros platform:"
    Write-Host "  1. Builds React frontend (npm run build)"
    Write-Host "  2. Copies frontend build to backend/static/"
    Write-Host "  3. Embeds frontend in Go binary using embed.FS"
    Write-Host "  4. Creates production binary siros.exe"
    Write-Host ""
    Write-Host "Output: Single binary with embedded frontend at build/siros.exe"
    exit 0
}

$ErrorActionPreference = "Stop"

Write-Host "🚀 Building Siros monorepo..." -ForegroundColor Cyan

# Check if we're in the right directory
if (-not (Test-Path "go.mod") -and -not (Test-Path "backend")) {
    Write-Host "❌ Error: Please run this script from the project root" -ForegroundColor Red
    exit 1
}

try {
    Write-Host "📦 Building frontend..." -ForegroundColor Green
    Push-Location frontend

    # Check if node_modules exists, if not install dependencies
    if (-not (Test-Path "node_modules")) {
        Write-Host "📥 Installing frontend dependencies..." -ForegroundColor Yellow
        npm install
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to install frontend dependencies"
        }
    }

    Write-Host "🔨 Building React app..." -ForegroundColor Green
    npm run build
    if ($LASTEXITCODE -ne 0) {
        throw "Frontend build failed"
    }

    Pop-Location

    Write-Host "📁 Copying build to backend/static..." -ForegroundColor Green
    if (Test-Path "backend/static") {
        Remove-Item "backend/static/*" -Recurse -Force -ErrorAction SilentlyContinue
    }
    if (-not (Test-Path "backend/static")) {
        New-Item -ItemType Directory -Path "backend/static" -Force
    }

    Copy-Item "frontend/dist/*" -Destination "backend/static/" -Recurse -Force

    Write-Host "⚙️ Building backend binary..." -ForegroundColor Green
    Push-Location backend

    go mod tidy
    if ($LASTEXITCODE -ne 0) {
        throw "Go mod tidy failed"
    }

    # Create build directory in repo root if it doesn't exist
    if (-not (Test-Path "../build")) {
        New-Item -ItemType Directory -Path "../build" -Force | Out-Null
    }

    go build -o ../build/siros.exe ./cmd/siros-server
    if ($LASTEXITCODE -ne 0) {
        throw "Backend build failed"
    }

    Pop-Location

    Write-Host ""
    Write-Host "✅ Build complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🏃 To run the server:" -ForegroundColor Cyan
    Write-Host "   .\build\siros.exe" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🌐 The server will be available at:" -ForegroundColor Cyan
    Write-Host "   Frontend: http://localhost:8080" -ForegroundColor Gray
    Write-Host "   API:      http://localhost:8080/api/v1" -ForegroundColor Gray
}
catch {
    Write-Host "❌ Build failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
finally {
    # Return to original directory
    if (Get-Location | Where-Object { $_.Path -ne $PWD }) {
        Pop-Location -ErrorAction SilentlyContinue
    }
}
