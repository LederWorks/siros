#!/bin/bash

# Clean Call Graph Files
# This script removes all generated call graph files

set -e

echo "🧹 Cleaning call graph files..."

# Check if we're in the right directory
if [ ! -f "go.mod" ] && [ ! -d "backend" ]; then
    echo "❌ Error: Please run this script from the project root"
    exit 1
fi

# Remove call graph directory
if [ -d "docs/callgraph" ]; then
    echo "🗑️  Removing docs/callgraph directory..."
    rm -rf docs/callgraph
    echo "✅ Call graph files cleaned"
else
    echo "ℹ️  No call graph files to clean"
fi

echo ""
echo "🔄 To regenerate call graphs, run:"
echo "   ./scripts/generate-callgraph.sh (Linux/macOS)"
echo "   .\\scripts\\generate-callgraph.ps1 (Windows)"
