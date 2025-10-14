# Siros Test Runner - Windows PowerShell Version
param(
    [string]$TestSuite = "all",
    [switch]$Coverage,
    [switch]$Verbose,
    [switch]$Help
)

if ($Help) {
    Write-Host "🧪 Siros Test Runner" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: .\scripts\test.ps1 [options]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -TestSuite <suite>   Run specific test suite (all, models, services, controllers, integration)"
    Write-Host "  -Coverage           Generate coverage report"
    Write-Host "  -Verbose            Show verbose output"
    Write-Host "  -Help               Show this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\scripts\test.ps1                    # Run all tests"
    Write-Host "  .\scripts\test.ps1 -TestSuite models  # Run models tests only"
    Write-Host "  .\scripts\test.ps1 -Coverage          # Run tests with coverage"
    exit 0
}

$ErrorActionPreference = "Stop"

Write-Host "🧪 Siros Test Runner" -ForegroundColor Cyan

# Check if we're in the right directory
if (-not (Test-Path "backend")) {
    Write-Host "❌ Error: Please run this script from the project root" -ForegroundColor Red
    exit 1
}

try {
    Push-Location backend

    $testArgs = @()
    if ($Verbose) {
        $testArgs += "-v"
    }

    switch ($TestSuite.ToLower()) {
        "all" {
            Write-Host "🔍 Running all tests..." -ForegroundColor Green
            if ($Coverage) {
                go test -coverprofile=coverage.out ./... @testArgs
                if ($LASTEXITCODE -eq 0) {
                    Write-Host ""
                    Write-Host "📊 Coverage Report:" -ForegroundColor Cyan
                    go tool cover -func=coverage.out
                    
                    Write-Host ""
                    Write-Host "🌐 Generating HTML coverage report..." -ForegroundColor Green
                    go tool cover -html=coverage.out -o coverage.html
                    Write-Host "📄 Coverage report saved to backend/coverage.html" -ForegroundColor Cyan
                }
            } else {
                go test ./... @testArgs
            }
        }
        "models" {
            Write-Host "🏗️ Running models tests..." -ForegroundColor Green
            go test ./internal/models/ @testArgs
        }
        "services" {
            Write-Host "⚙️ Running services tests..." -ForegroundColor Green
            go test ./internal/services/ @testArgs
        }
        "controllers" {
            Write-Host "🌐 Running controllers tests..." -ForegroundColor Green
            go test ./internal/controllers/ @testArgs
        }
        "repositories" {
            Write-Host "🗄️ Running repositories tests..." -ForegroundColor Green
            go test ./internal/repositories/ @testArgs
        }
        "integration" {
            Write-Host "🔗 Running integration tests..." -ForegroundColor Green
            # Note: Integration tests to be implemented
            Write-Host "⚠️ Integration tests not yet implemented" -ForegroundColor Yellow
        }
        default {
            Write-Host "❌ Unknown test suite: $TestSuite" -ForegroundColor Red
            Write-Host "Available suites: all, models, services, controllers, repositories, integration"
            exit 1
        }
    }

    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✅ All tests passed!" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "❌ Some tests failed!" -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "❌ Test execution failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
finally {
    Pop-Location -ErrorAction SilentlyContinue
}