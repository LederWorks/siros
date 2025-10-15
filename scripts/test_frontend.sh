#!/bin/bash

# Siros Frontend Test Orchestration Script
# Orchestrates comprehensive frontend validation including linting, type checking, and tests

set -e

# Default values
VERBOSE=false
COVERAGE=false
WATCH=false
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
        --coverage)
            COVERAGE=true
            shift
            ;;
        --watch|-w)
            WATCH=true
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
            echo "🧪 Siros Frontend Test Orchestration"
            echo ""
            echo "This script orchestrates comprehensive frontend testing through specialized components:"
            echo ""
            echo "ORCHESTRATION FLOW:"
            echo "  1. frontend_lint      Code quality analysis (ESLint + TypeScript)"
            echo "  2. frontend_test      Unit tests (Jest/Vitest when implemented)"
            echo "  3. frontend_typecheck TypeScript compilation verification"
            echo ""
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --verbose, -v         Enable verbose output across all components"
            echo "  --coverage            Enable test coverage reporting (when tests implemented)"
            echo "  --watch, -w           Run tests in watch mode (when tests implemented)"
            echo "  --skip-install        Skip automatic tool installation/updates"
            echo "  --config, -c PATH     Use custom config file"
            echo "  --help, -h            Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                    # Run full frontend test orchestration"
            echo "  $0 --verbose          # Run with verbose output"
            echo "  $0 --coverage         # Run with coverage reporting"
            echo "  $0 --watch            # Run in watch mode"
            echo ""
            echo "Component Scripts:"
            echo "  frontend/frontend_lint.sh      ESLint and TypeScript linting"
            echo "  frontend/frontend_test.sh      Jest/Vitest unit testing (future)"
            echo "  frontend/frontend_typecheck.sh TypeScript compilation check (future)"
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
echo -e "${BLUE}🧪 Siros Frontend Test Orchestration${NC}"
echo ""

# Check if frontend directory exists
if [ ! -d "$FRONTEND_DIR" ]; then
    print_error "Frontend directory not found at: $FRONTEND_DIR"
    print_warning "Please run this script from the project root"
    exit 1
fi

print_status "Frontend test orchestration starting..."
print_status "Project root: $PROJECT_ROOT"

# Prepare component script arguments
COMPONENT_ARGS=()
if [ "$VERBOSE" = true ]; then
    COMPONENT_ARGS+=("--verbose")
fi
if [ "$SKIP_INSTALL" = true ]; then
    COMPONENT_ARGS+=("--skip-install")
fi
if [ "$COVERAGE" = true ]; then
    COMPONENT_ARGS+=("--coverage")
fi
if [ "$WATCH" = true ]; then
    COMPONENT_ARGS+=("--watch")
fi
if [ -n "$CONFIG" ]; then
    COMPONENT_ARGS+=("--config" "$CONFIG")
fi

OVERALL_SUCCESS=true
START_TIME=$(date +%s)

# Step 1: Code quality analysis (ESLint + TypeScript)
echo ""
print_status "Step 1/3: Running code quality analysis (frontend_lint)..."

LINT_SCRIPT="$SCRIPT_DIR/frontend/frontend_lint.sh"
if [ -f "$LINT_SCRIPT" ]; then
    if "$LINT_SCRIPT" "${COMPONENT_ARGS[@]}"; then
        print_success "Frontend linting passed!"
    else
        print_warning "Frontend linting found issues, but continuing..."
        # Don't fail overall for linting issues, just warn
    fi
else
    print_warning "frontend_lint.sh not found at: $LINT_SCRIPT"
    print_warning "Skipping linting step"
fi

# Step 2: Unit tests (when implemented)
echo ""
print_status "Step 2/3: Running unit tests (frontend_test)..."

TEST_SCRIPT="$SCRIPT_DIR/frontend/frontend_test.sh"
if [ -f "$TEST_SCRIPT" ]; then
    if "$TEST_SCRIPT" "${COMPONENT_ARGS[@]}"; then
        print_success "Frontend tests passed!"
    else
        print_error "Frontend tests failed!"
        OVERALL_SUCCESS=false
    fi
else
    print_warning "frontend_test.sh not found at: $TEST_SCRIPT"
    print_warning "Frontend unit testing not yet implemented - skipping"
fi

# Step 3: TypeScript compilation verification (when implemented)
echo ""
print_status "Step 3/3: Running TypeScript compilation verification (frontend_typecheck)..."

TYPECHECK_SCRIPT="$SCRIPT_DIR/frontend/frontend_typecheck.sh"
if [ -f "$TYPECHECK_SCRIPT" ]; then
    if "$TYPECHECK_SCRIPT" "${COMPONENT_ARGS[@]}"; then
        print_success "TypeScript compilation verification passed!"
    else
        print_error "TypeScript compilation verification failed!"
        OVERALL_SUCCESS=false
    fi
else
    print_warning "frontend_typecheck.sh not found at: $TYPECHECK_SCRIPT"
    print_warning "TypeScript type checking not yet implemented - skipping"
fi

# Final results
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "============================================================"
if [ "$OVERALL_SUCCESS" = true ]; then
    print_success "Frontend test orchestration completed successfully! (${DURATION}s)"
    echo ""
    exit 0
else
    print_error "Frontend test orchestration failed! (${DURATION}s)"
    print_warning "Check the output above for specific failures"
    echo ""
    exit 1
fi
