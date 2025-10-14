# Clean Call Graph Files
# This script removes all generated call graph files

[CmdletBinding()]
param()

Write-Host "🧹 Cleaning call graph files..." -ForegroundColor Blue

# Check if we're in the right directory
if (-not (Test-Path "go.mod") -and -not (Test-Path "backend")) {
    Write-Host "❌ Error: Please run this script from the project root" -ForegroundColor Red
    exit 1
}

# Remove call graph directory
$CallGraphDir = "docs\callgraph"
if (Test-Path $CallGraphDir) {
    Write-Host "🗑️  Removing docs\callgraph directory..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force $CallGraphDir
    Write-Host "✅ Call graph files cleaned" -ForegroundColor Green
}
else {
    Write-Host "ℹ️  No call graph files to clean" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "🔄 To regenerate call graphs, run:" -ForegroundColor Blue
Write-Host "   .\scripts\generate-callgraph.ps1 (Windows)" -ForegroundColor Gray
Write-Host "   ./scripts/generate-callgraph.sh (Linux/macOS)" -ForegroundColor Gray
