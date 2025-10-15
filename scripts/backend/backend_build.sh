#!/bin/bash

# Siros Backend Build Script
# Builds the Go backend server with embedded frontend assets

set -e

# Default values
VERBOSE=false
SKIP_INSTALL=false
CONFIG=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --skip-install)
            SKIP_INSTALL=true
            shift
            ;;
        --config|-c)
            CONFIG="$2"
            shift 2
            ;;
        --help|-h)
            echo "⚙️ Siros Backend Build"
            echo ""
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --verbose, -v         Enable verbose output"
            echo "  --skip-install        Skip automatic dependency installation"
            echo "  --config, -c PATH     Use custom config file"
            echo "  --help, -h            Show this help message"
            echo ""
            echo "Description:"
            echo "  Builds the Go backend server binary with embedded frontend assets."
            echo "  Copies frontend build artifacts to backend/static/ before building."
            echo "  Creates production binary at build/siros"
            echo ""
            echo "Examples:"
            echo "  $0                    # Build with default settings"
            echo "  $0 --verbose          # Build with verbose output"
            echo "  $0 --skip-install     # Build without updating dependencies"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BACKEND_DIR="$PROJECT_ROOT/backend"
FRONTEND_DIST_DIR="$PROJECT_ROOT/frontend/dist"
BACKEND_STATIC_DIR="$BACKEND_DIR/static"
BUILD_DIR="$PROJECT_ROOT/build"

echo ""
echo -e "${BLUE}⚙️ Siros Backend Build${NC}"
echo ""

# Check if we're in the right directory
if [ ! -d "$BACKEND_DIR" ]; then
    print_error "Backend directory not found at: $BACKEND_DIR"
    print_warning "Please run this script from the project root"
    exit 1
fi

# Check Go availability
if ! command -v go &> /dev/null; then
    print_error "Go not found! Please install Go to build the backend."
    exit 1
fi

if [ "$VERBOSE" = true ]; then
    GO_VERSION=$(go version)
    print_status "Using Go version: $GO_VERSION"
fi

# Change to backend directory
cd "$BACKEND_DIR"
print_status "Working in backend directory: $BACKEND_DIR"

# Update Go dependencies if not skipped
if [ "$SKIP_INSTALL" = false ]; then
    print_status "Updating Go dependencies..."
    go mod tidy
    if [ $? -ne 0 ]; then
        print_error "Failed to update Go dependencies!"
        exit 1
    fi
    print_success "Go dependencies updated successfully"
else
    print_status "Skipping dependency updates (skip-install flag set)"
fi

# Copy frontend assets if they exist
if [ -d "$FRONTEND_DIST_DIR" ]; then
    print_status "Copying frontend assets to backend/static/..."

    # Clean existing static directory
    if [ -d "$BACKEND_STATIC_DIR" ]; then
        rm -rf "${BACKEND_STATIC_DIR:?}"/*
    else
        mkdir -p "$BACKEND_STATIC_DIR"
    fi

    # Copy frontend build artifacts
    cp -r "$FRONTEND_DIST_DIR"/* "$BACKEND_STATIC_DIR"/

    STATIC_FILES=$(find "$BACKEND_STATIC_DIR" -type f | wc -l)
    print_success "Frontend assets copied ($STATIC_FILES files)"

    if [ "$VERBOSE" = true ]; then
        print_status "Static assets:"
        find "$BACKEND_STATIC_DIR" -type f | while read -r file; do
            echo "  ${file#$BACKEND_STATIC_DIR/}"
        done
    fi
else
    print_warning "Frontend dist directory not found at: $FRONTEND_DIST_DIR"
    print_warning "Backend will be built without embedded frontend assets"
    print_status "Run 'build_frontend.sh' first to include frontend assets"

    # Create placeholder frontend if no static directory exists
    if [ ! -d "$BACKEND_STATIC_DIR" ]; then
        print_status "Creating placeholder frontend assets..."
        mkdir -p "$BACKEND_STATIC_DIR"

        # Copy placeholder HTML template
        PLACEHOLDER_HTML_PATH="$SCRIPT_DIR/placeholder-index.html"
        if [ -f "$PLACEHOLDER_HTML_PATH" ]; then
            cp "$PLACEHOLDER_HTML_PATH" "$BACKEND_STATIC_DIR/index.html"
            print_success "Placeholder frontend created from template"
        else
            print_warning "Placeholder HTML template not found at: $PLACEHOLDER_HTML_PATH"
            print_status "Creating basic placeholder..."
            cat > "$BACKEND_STATIC_DIR/index.html" << 'EOF'
<!DOCTYPE html>
<html>
<head><title>Siros - Multi-Cloud Resource Platform</title></head>
<body>
<h1>🌐 Siros</h1>
<p>Multi-Cloud Resource Platform</p>
<p><a href="/api/v1/health">Health Check</a> | <a href="/api/v1/resources">Resources</a></p>
</body>
</html>
EOF
            print_success "Basic placeholder frontend created"
        fi
    fi
fi

# Create build directory if it doesn't exist
if [ ! -d "$BUILD_DIR" ]; then
    mkdir -p "$BUILD_DIR"
    print_status "Created build directory: $BUILD_DIR"
fi

# Build the backend binary
print_status "Building Go backend binary..."

# Determine the binary name based on OS
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OS" == "Windows_NT" ]]; then
    BINARY_NAME="../build/siros.exe"
else
    BINARY_NAME="../build/siros"
fi

if [ "$VERBOSE" = true ]; then
    print_status "Build command: go build -o $BINARY_NAME ./cmd/siros-server"
    go build -o "$BINARY_NAME" ./cmd/siros-server
else
    go build -o "$BINARY_NAME" ./cmd/siros-server 2>/dev/null
fi

if [ $? -ne 0 ]; then
    print_error "Backend build failed!"
    exit 1
fi

# Verify build output
if [ ! -f "$BINARY_NAME" ]; then
    print_error "Build completed but binary not found at: $BINARY_NAME"
    exit 1
fi

BINARY_SIZE=$(stat -c%s "$BINARY_NAME" 2>/dev/null || stat -f%z "$BINARY_NAME" 2>/dev/null || echo "0")
BINARY_SIZE_MB=$(echo "scale=2; $BINARY_SIZE / 1024 / 1024" | bc -l 2>/dev/null || echo "unknown")

print_success "Backend build completed successfully!"
print_status "Binary location: $BINARY_NAME"
print_status "Binary size: ${BINARY_SIZE_MB} MB"

if [ "$VERBOSE" = true ]; then
    print_status "Binary details:"
    ls -la "$BINARY_NAME"
fi

echo ""
print_status "Backend binary ready for deployment"
echo ""

# Return to project root
cd "$PROJECT_ROOT"
