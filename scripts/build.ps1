# Siros Backend Build - Windows PowerShell Version
param(
    [switch]$Help
)

if ($Help) {
    Write-Host "🔨 Siros Backend Build" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: .\scripts\build.ps1"
    Write-Host ""
    Write-Host "This script builds only the Siros backend with placeholder frontend:"
    Write-Host "  1. Creates placeholder frontend assets (if missing)"
    Write-Host "  2. Builds Go backend binary with embedded assets"
    Write-Host "  3. Creates development binary siros-server.exe"
    Write-Host ""
    Write-Host "Output: Backend binary at build/siros.exe"
    Write-Host ""
    Write-Host "For full production build (with React frontend), use:"
    Write-Host "  .\scripts\build_all.ps1"
    exit 0
}

$ErrorActionPreference = "Stop"

Write-Host "🔨 Building Siros backend with placeholder frontend..." -ForegroundColor Blue

# Check if we're in the right directory
if (-not (Test-Path "go.mod") -and -not (Test-Path "backend")) {
    Write-Host "❌ Error: Please run this script from the project root" -ForegroundColor Red
    exit 1
}

try {
    # Ensure backend/static directory exists with at least one file for embed
    if (-not (Test-Path "backend/static")) {
        New-Item -ItemType Directory -Path "backend/static" -Force | Out-Null
    }

    if (-not (Test-Path "backend/static/index.html")) {
        Write-Host "📝 Creating placeholder frontend assets..." -ForegroundColor Yellow

        $placeholderHtml = @'
<!DOCTYPE html>
<html>
<head>
    <title>Siros - Multi-Cloud Resource Platform</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            margin: 0;
            padding: 20px;
            background: #f5f5f5;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 8px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .header {
            text-align: center;
            margin-bottom: 40px;
            border-bottom: 2px solid #007cba;
            padding-bottom: 20px;
        }
        .api-link {
            display: inline-block;
            margin: 10px;
            padding: 12px 24px;
            background: #007cba;
            color: white;
            text-decoration: none;
            border-radius: 6px;
            transition: background 0.3s;
        }
        .api-link:hover {
            background: #005a8b;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🌐 Siros</h1>
            <p>Multi-Cloud Resource Platform</p>
        </div>

        <h2>🔗 API Endpoints</h2>
        <div style="text-align: center; margin: 20px 0;">
            <a href="/api/v1/health" class="api-link">🔍 Health Check</a>
            <a href="/api/v1/resources" class="api-link">📦 Resources</a>
            <a href="/api/v1/schemas" class="api-link">📋 Schemas</a>
        </div>

        <h2>✨ Features</h2>
        <ul>
            <li>✅ HTTP API for resource management</li>
            <li>✅ PostgreSQL with pgvector for semantic search</li>
            <li>✅ Multi-cloud provider support (AWS, Azure, GCP)</li>
            <li>✅ Terraform integration</li>
            <li>✅ MCP (Model Context Protocol) API</li>
            <li>🔄 Blockchain change tracking</li>
            <li>🔄 React frontend (embedded in binary)</li>
        </ul>
    </div>
</body>
</html>
'@

        Set-Content -Path "backend/static/index.html" -Value $placeholderHtml -Encoding UTF8
    }

    # Build the backend binary
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
    Write-Host "✅ Build successful! Binary created at build/siros.exe" -ForegroundColor Green
    Write-Host ""
    Write-Host "🚀 To run the server:" -ForegroundColor Cyan
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
