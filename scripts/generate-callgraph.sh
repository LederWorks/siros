#!/bin/bash

# Generate Call Graph Visualizations for Siros Backend
# This script uses go-callvis to create different call graph visualizations

set -e

echo "🔍 Generating Siros Backend Call Graph Visualizations..."

# Check if we're in the right directory
if [ ! -f "go.mod" ] && [ ! -d "backend" ]; then
    echo "❌ Error: Please run this script from the project root"
    exit 1
fi

# Navigate to backend directory
cd backend

# Check if go-callvis is installed
if ! command -v go-callvis &> /dev/null; then
    echo "📦 Installing go-callvis..."
    go install github.com/ofabry/go-callvis@latest
fi

# Check if dot (graphviz) is available
if ! command -v dot &> /dev/null; then
    echo "⚠️  Warning: Graphviz 'dot' not found. Install graphviz for better output:"
    echo "   - Ubuntu/Debian: sudo apt install graphviz"
    echo "   - macOS: brew install graphviz"
    echo "   - Windows: choco install graphviz"
    echo ""
    USE_GRAPHVIZ=""
else
    echo "✅ Graphviz found, using enhanced rendering"
    USE_GRAPHVIZ="-graphviz"
fi

# Create docs directory if it doesn't exist
mkdir -p ../docs/callgraph

echo "📊 Generating main application call graph..."
go-callvis \
    -format=svg \
    -file=../docs/callgraph/main-overview \
    -nostd \
    -focus=main \
    -rankdir=TB \
    -minlen=2 \
    -nodesep=0.5 \
    $USE_GRAPHVIZ \
    ./cmd/siros-server

echo "🌐 Generating API layer call graph..."
go-callvis \
    -format=svg \
    -file=../docs/callgraph/api-layer \
    -nostd \
    -limit=github.com/LederWorks/siros/backend/internal/api \
    -rankdir=LR \
    -minlen=3 \
    $USE_GRAPHVIZ \
    ./cmd/siros-server

echo "🏗️ Generating services and controllers call graph..."
go-callvis \
    -format=svg \
    -file=../docs/callgraph/services-controllers \
    -nostd \
    -limit=github.com/LederWorks/siros/backend/internal/controllers,github.com/LederWorks/siros/backend/internal/services \
    -rankdir=TB \
    -minlen=2 \
    $USE_GRAPHVIZ \
    ./cmd/siros-server

echo "🗃️ Generating storage and config call graph..."
go-callvis \
    -format=svg \
    -file=../docs/callgraph/storage-config \
    -nostd \
    -limit=github.com/LederWorks/siros/backend/internal/storage,github.com/LederWorks/siros/backend/internal/config \
    -rankdir=LR \
    -minlen=2 \
    $USE_GRAPHVIZ \
    ./cmd/siros-server

echo "☁️ Generating cloud providers call graph..."
go-callvis \
    -format=svg \
    -file=../docs/callgraph/cloud-providers \
    -nostd \
    -limit=github.com/LederWorks/siros/backend/internal/providers \
    -rankdir=TB \
    -minlen=2 \
    $USE_GRAPHVIZ \
    ./cmd/siros-server

echo "🔐 Generating middleware call graph..."
go-callvis \
    -format=svg \
    -file=../docs/callgraph/middleware \
    -nostd \
    -limit=github.com/LederWorks/siros/backend/internal/api/middleware \
    -rankdir=LR \
    -minlen=2 \
    $USE_GRAPHVIZ \
    ./cmd/siros-server

echo "✅ Call graph generation complete!"
echo ""
echo "📁 Generated files in docs/callgraph/:"
ls -la ../docs/callgraph/*.svg 2>/dev/null || echo "   (No SVG files found - check for errors above)"
echo ""
echo "📖 To view the documentation with embedded graphs:"
echo "   Open docs/BACKEND_CALL_GRAPH.md in VS Code or your preferred viewer"
