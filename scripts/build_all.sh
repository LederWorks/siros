#!/bin/bash
set -e

echo "🚀 Building Siros monorepo..."

# Check if we're in the right directory
if [ ! -f "go.mod" ] && [ ! -d "backend" ]; then
    echo "❌ Error: Please run this script from the project root"
    exit 1
fi

echo "📦 Building frontend..."
cd frontend

# Check if node_modules exists, if not install dependencies
if [ ! -d "node_modules" ]; then
    echo "📥 Installing frontend dependencies..."
    npm install
fi

echo "🔨 Building React app..."
npm run build

echo "📁 Copying build to backend/static..."
cd ..
rm -rf backend/static/*
mkdir -p backend/static
cp -r frontend/dist/* backend/static/

echo "⚙️ Building backend binary..."
cd backend
go mod tidy

# Create build directory in repo root if it doesn't exist
mkdir -p ../build

# Determine the binary name based on OS
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OS" == "Windows_NT" ]]; then
    BINARY_NAME="../build/siros.exe"
else
    BINARY_NAME="../build/siros"
fi

go build -o "$BINARY_NAME" ./cmd/siros-server

echo "✅ Build complete!"
echo ""
echo "🏃 To run the server:"
if [[ "$BINARY_NAME" == *.exe ]]; then
    echo "   .\\build\\siros.exe"
else
    echo "   ./build/siros"
fi
echo ""
echo "🌐 The server will be available at:"
echo "   Frontend: http://localhost:8080"
echo "   API:      http://localhost:8080/api/v1"
