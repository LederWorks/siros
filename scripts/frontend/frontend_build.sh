#!/bin/bash

# Siros Frontend Build Script
# Builds the React/TypeScript frontend application

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
            echo "🎨 Siros Frontend Build"
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
            echo "  Builds the React/TypeScript frontend application using Vite."
            echo "  Creates optimized production build in frontend/dist directory."
            echo ""
            echo "Examples:"
            echo "  $0                    # Build with default settings"
            echo "  $0 --verbose          # Build with verbose output"
            echo "  $0 --skip-install     # Build without installing dependencies"
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
FRONTEND_DIR="$PROJECT_ROOT/frontend"

echo ""
echo -e "${BLUE}🎨 Siros Frontend Build${NC}"
echo ""

# Check if we're in the right directory
if [ ! -d "$FRONTEND_DIR" ]; then
    print_error "Frontend directory not found at: $FRONTEND_DIR"
    print_warning "Please run this script from the project root"
    exit 1
fi

# Change to frontend directory
cd "$FRONTEND_DIR"
print_status "Working in frontend directory: $FRONTEND_DIR"

# Check Node.js availability
if ! command -v node &> /dev/null; then
    print_error "Node.js not found! Please install Node.js to build the frontend."
    exit 1
fi

if [ "$VERBOSE" = true ]; then
    NODE_VERSION=$(node --version)
    print_status "Using Node.js version: $NODE_VERSION"
fi

# Check npm availability
if ! command -v npm &> /dev/null; then
    print_error "npm not found! Please install npm to build the frontend."
    exit 1
fi

if [ "$VERBOSE" = true ]; then
    NPM_VERSION=$(npm --version)
    print_status "Using npm version: $NPM_VERSION"
fi

# Install dependencies if needed and not skipped
if [ "$SKIP_INSTALL" = false ]; then
    if [ ! -d "node_modules" ] || [ ! -f "package-lock.json" ]; then
        print_status "Installing frontend dependencies..."
        npm install
        if [ $? -ne 0 ]; then
            print_error "Failed to install frontend dependencies!"
            exit 1
        fi
        print_success "Frontend dependencies installed successfully"
    else
        print_status "Dependencies already installed, updating if needed..."
        npm ci --silent
        if [ $? -ne 0 ]; then
            print_warning "Failed to update dependencies, continuing with existing ones"
        else
            print_success "Dependencies verified and updated"
        fi
    fi
else
    print_status "Skipping dependency installation (skip-install flag set)"
    if [ ! -d "node_modules" ]; then
        print_error "node_modules not found and skip-install flag is set!"
        print_warning "Please install dependencies manually: npm install"
        exit 1
    fi
fi

# Clean previous build
if [ -d "dist" ]; then
    print_status "Cleaning previous build..."
    rm -rf dist
    print_success "Previous build cleaned"
fi

# Build the frontend
print_status "Building React/TypeScript frontend..."

if [ "$VERBOSE" = true ]; then
    npm run build
else
    npm run build --silent
fi

if [ $? -ne 0 ]; then
    print_error "Frontend build failed!"
    exit 1
fi

# Verify build output
if [ ! -d "dist" ]; then
    print_error "Build completed but dist directory not found!"
    exit 1
fi

DIST_FILES=$(find dist -type f | wc -l)
print_success "Frontend build completed successfully!"
print_status "Build output: frontend/dist ($DIST_FILES files generated)"

if [ "$VERBOSE" = true ]; then
    print_status "Build contents:"
    find dist -type f | while read -r file; do
        echo "  ${file#$PWD/}"
    done
fi

echo ""
print_status "Frontend build artifacts ready for embedding in backend binary"
echo ""

# Return to project root
cd "$PROJECT_ROOT"
