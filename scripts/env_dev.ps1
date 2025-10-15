# Siros Development Environment - Windows PowerShell Version
param(
    [switch]$Help
)

if ($Help) {
    Write-Host "🔧 Siros Development Environment" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: .\scripts\dev.ps1"
    Write-Host ""
    Write-Host "This script starts the complete development environment:"
    Write-Host "  - PostgreSQL database with pgvector (Docker container)"
    Write-Host "  - Backend server on port 8080 (Go with hot reload)"
    Write-Host "  - Frontend dev server on port 5173 (Vite with hot reload)"
    Write-Host ""
    Write-Host "Prerequisites:"
    Write-Host "  - Docker must be installed and running"
    Write-Host "  - Go 1.24+ must be installed"
    Write-Host "  - Node.js 18+ and npm must be installed"
    Write-Host ""
    Write-Host "Press Ctrl+C to stop all servers"
    Write-Host ""
    Write-Host "Note: The PostgreSQL container will continue running after you stop"
    Write-Host "      the dev environment. This is intentional to preserve data."
    exit 0
}

Write-Host "🔧 Starting Siros development environment..." -ForegroundColor Cyan

# Function to kill background jobs on exit
function Cleanup {
    Write-Host ""
    Write-Host "🛑 Stopping development servers..." -ForegroundColor Yellow
    Get-Job | Stop-Job
    Get-Job | Remove-Job

    # Optionally stop the database (uncomment if you want to stop PostgreSQL on exit)
    # Write-Host "🗄️  Stopping PostgreSQL database..." -ForegroundColor Yellow
    # docker-compose stop postgres | Out-Null

    exit 0
}

# Function to check if PostgreSQL is running
function Test-PostgreSQL {
    try {
        $result = docker-compose ps --services --filter "status=running" 2>$null
        return $result -contains "postgres"
    }
    catch {
        return $false
    }
}

# Function to start PostgreSQL database
function Start-Database {
    Write-Host "🗄️  Setting up PostgreSQL database..." -ForegroundColor Yellow

    # Use docker-compose for proper initialization
    Write-Host "📋 Starting PostgreSQL with docker-compose..." -ForegroundColor Blue
    docker-compose up postgres -d | Out-Null

    # Wait for database to be ready
    Write-Host "⏳ Waiting for database to be ready..." -ForegroundColor Yellow
    $maxAttempts = 30
    $attempt = 0

    do {
        Start-Sleep -Seconds 1
        $attempt++
        try {
            # Get the actual container name from docker-compose
            $containerName = docker-compose ps -q postgres 2>$null
            if ($containerName) {
                $result = docker exec $containerName pg_isready -U siros 2>$null
                if ($LASTEXITCODE -eq 0) {
                    # Test actual connection
                    docker exec $containerName psql -U siros -d siros -c "SELECT 1;" 2>$null | Out-Null
                    if ($LASTEXITCODE -eq 0) {
                        break
                    }
                }
            }
        }
        catch {
            # Continue waiting
        }

        if ($attempt -ge $maxAttempts) {
            throw "Database failed to start within 30 seconds"
        }
    } while ($true)

    Write-Host "✅ Database ready!" -ForegroundColor Green
}

# Set up signal handlers
Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action { Cleanup }

try {
    # Ensure database is running
    if (-not (Test-PostgreSQL)) {
        Start-Database
    }
    else {
        Write-Host "✅ PostgreSQL database is already running" -ForegroundColor Green
    }

    # Start backend server
    Write-Host "🚀 Starting backend server on :8080..." -ForegroundColor Green
    Push-Location backend
    $backendJob = Start-Job -ScriptBlock {
        Set-Location $using:PWD
        $env:SIROS_DB_PASSWORD = "siros"
        go run ./cmd/siros-server
    }
    Pop-Location

    # Wait a moment for backend to start
    Start-Sleep -Seconds 2

    # Start frontend dev server
    Write-Host "🌐 Starting frontend dev server on :5173..." -ForegroundColor Green
    Push-Location frontend

    # Check if node_modules exists
    if (-not (Test-Path "node_modules")) {
        Write-Host "📥 Installing frontend dependencies..." -ForegroundColor Yellow
        npm install
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to install frontend dependencies"
        }
    }

    $frontendJob = Start-Job -ScriptBlock {
        Set-Location $using:PWD
        npm run dev
    }
    Pop-Location

    Write-Host ""
    Write-Host "✅ Development environment started!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🌐 Frontend (dev): http://localhost:5173" -ForegroundColor Cyan
    Write-Host "🔧 Backend API:    http://localhost:8080/api/v1" -ForegroundColor Cyan
    Write-Host "📊 API Health:     http://localhost:8080/api/v1/health" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Press Ctrl+C to stop both servers" -ForegroundColor Yellow

    # Monitor jobs and wait
    while ($true) {
        $runningJobs = Get-Job | Where-Object { $_.State -eq "Running" }
        if ($runningJobs.Count -eq 0) {
            Write-Host "❌ All services have stopped" -ForegroundColor Red
            break
        }

        # Check for failed jobs
        $failedJobs = Get-Job | Where-Object { $_.State -eq "Failed" }
        if ($failedJobs.Count -gt 0) {
            Write-Host "❌ Some services failed:" -ForegroundColor Red
            $failedJobs | ForEach-Object {
                Write-Host "  - $($_.Name): $($_.ChildJobs[0].JobStateInfo.Reason)" -ForegroundColor Red
            }
            break
        }

        Start-Sleep -Seconds 1
    }
}
catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
finally {
    Cleanup
}
