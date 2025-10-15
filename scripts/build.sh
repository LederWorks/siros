#!/bin/bash

# Siros Full Production Build Script
# Builds the complete Siros application (frontend + backend)

set -e

# Default values
VERBOSE_OUTPUT=false
SKIP_TESTS=false
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
            VERBOSE_OUTPUT=true
            shift
            ;;
        --skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        --config|-c)
            CONFIG="$2"
            shift 2
            ;;
        --help|-h)
            echo "🏗️ Siros Full Production Build"
            echo ""
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --verbose, -v         Enable verbose output"
            echo "  --skip-tests          Skip testing before building"
            echo "  --config, -c PATH     Use custom config file"
            echo "  --help, -h            Show this help message"
            echo ""
            echo "Description:"
            echo "  Complete production build process:"
            echo "  1. Run comprehensive tests (unless --skip-tests)"
            echo "  2. Build React frontend with Vite"
            echo "  3. Build Go backend with embedded frontend"
            echo ""
            echo "Examples:"
            echo "  $0                    # Full build with tests"
            echo "  $0 --skip-tests       # Build only, skip tests"
            echo "  $0 --verbose          # Build with verbose output"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo ""
echo -e "${BLUE}🏗️ Siros Full Production Build${NC}"
echo ""

# Check if we're in the right directory
if [ ! -d "$PROJECT_ROOT/backend" ] || [ ! -d "$PROJECT_ROOT/frontend" ]; then
    print_error "Backend or frontend directory not found"
    print_warning "Please run this script from the project root"
    exit 1
fi

# Change to project root
cd "$PROJECT_ROOT"

# Prepare component script arguments
COMPONENT_ARGS=()
if [ "$VERBOSE_OUTPUT" = true ]; then
    COMPONENT_ARGS+=(--verbose)
fi
if [ -n "$CONFIG" ]; then
    COMPONENT_ARGS+=(--config "$CONFIG")
fi

# Determine build steps
if [ "$SKIP_TESTS" = true ]; then
    TOTAL_STEPS=2
    print_status "Build mode: Production build only (tests skipped)"
else
    TOTAL_STEPS=4
    print_status "Build mode: Full build with comprehensive testing"
fi

try_run_script() {
    local script_path="$1"
    local description="$2"
    shift 2
    local args=("$@")

    if [ -f "$script_path" ]; then
        if [ "$VERBOSE_OUTPUT" = true ]; then
            print_status "Running: $script_path ${args[*]}"
        fi
        "$script_path" "${args[@]}"
    else
        print_warning "Script not found: $script_path"
        print_warning "Skipping: $description"
    fi
}

# Step 1: Test Backend (if not skipped)
if [ "$SKIP_TESTS" = false ]; then
    print_status "Step 1/$TOTAL_STEPS: Testing Go backend..."
    try_run_script "./scripts/test_backend.sh" "backend testing" "${COMPONENT_ARGS[@]}"
    if [ $? -ne 0 ]; then
        print_error "Backend tests failed!"
        exit 1
    fi
    print_success "Backend tests completed"
fi

# Step 2: Test Frontend (if not skipped)
if [ "$SKIP_TESTS" = false ]; then
    print_status "Step 2/$TOTAL_STEPS: Testing React frontend..."
    try_run_script "./scripts/test_frontend.sh" "frontend testing" "${COMPONENT_ARGS[@]}"
    if [ $? -ne 0 ]; then
        print_error "Frontend tests failed!"
        exit 1
    fi
    print_success "Frontend tests completed"
fi

# Determine step numbers for build phase
if [ "$SKIP_TESTS" = true ]; then
    FRONTEND_STEP="1"
    BACKEND_STEP="2"
else
    FRONTEND_STEP="3"
    BACKEND_STEP="4"
fi

# Step: Build Frontend
print_status "Step $FRONTEND_STEP/$TOTAL_STEPS: Building React frontend..."
try_run_script "./scripts/frontend/frontend_build.sh" "frontend build" "${COMPONENT_ARGS[@]}"
if [ $? -ne 0 ]; then
    print_error "Frontend build failed!"
    exit 1
fi
print_success "Frontend build completed"

# Step: Build Backend
print_status "Step $BACKEND_STEP/$TOTAL_STEPS: Building Go backend with embedded frontend..."
try_run_script "./scripts/backend/backend_build.sh" "backend build" "${COMPONENT_ARGS[@]}"
if [ $? -ne 0 ]; then
    print_error "Backend build failed!"
    exit 1
fi
print_success "Backend build completed"

echo ""
print_success "Complete production build finished!"

# Show build results
BINARY_PATH=""
if [ -f "$PROJECT_ROOT/build/siros" ]; then
    BINARY_PATH="$PROJECT_ROOT/build/siros"
elif [ -f "$PROJECT_ROOT/build/siros.exe" ]; then
    BINARY_PATH="$PROJECT_ROOT/build/siros.exe"
fi

if [ -n "$BINARY_PATH" ]; then
    BINARY_SIZE=$(stat -c%s "$BINARY_PATH" 2>/dev/null || stat -f%z "$BINARY_PATH" 2>/dev/null || echo "0")
    BINARY_SIZE_MB=$(echo "scale=2; $BINARY_SIZE / 1024 / 1024" | bc -l 2>/dev/null || echo "unknown")

    print_status "Binary location: $BINARY_PATH"
    print_status "Binary size: ${BINARY_SIZE_MB} MB"

    echo ""
    echo -e "${GREEN}🏃 To run the server:${NC}"
    if [[ "$BINARY_PATH" == *.exe ]]; then
        echo "   .\\build\\siros.exe"
    else
        echo "   ./build/siros"
    fi

    echo ""
    echo -e "${BLUE}🌐 The server will be available at:${NC}"
    echo "   Frontend: http://localhost:8080"
    echo "   API:      http://localhost:8080/api/v1"
else
    print_warning "Binary not found at expected location"
fi

echo ""
