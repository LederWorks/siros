#!/bin/bash

# Siros Backend Test Orchestration Script
# Orchestrates comprehensive backend validation including tests, code quality, and security

set -e

# Default values
VERBOSE=false
COVERAGE=false
TEST_SUITE="all"
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
        --test-suite|-s)
            TEST_SUITE="$2"
            shift 2
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
            echo "🧪 Siros Backend Test Orchestration"
            echo ""
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --verbose, -v              Enable verbose output"
            echo "  --coverage                 Generate test coverage reports"
            echo "  --test-suite, -s SUITE     Run specific test suite"
            echo "  --skip-install             Skip automatic tool installation/updates"
            echo "  --config, -c PATH          Use custom config file"
            echo "  --help, -h                 Show this help message"
            echo ""
            echo "ORCHESTRATION FLOW:"
            echo "  1. backend_gotest   Core functionality tests"
            echo "  2. backend_lint     Code quality analysis"
            echo "  3. backend_gosec    Security vulnerability scan"
            echo ""
            echo "Test Suites:"
            echo "  all          Complete backend test suite"
            echo "  models       Business logic and validation tests"
            echo "  services     Business logic orchestration tests"
            echo "  controllers  HTTP handler and API tests"
            echo "  repositories Data access layer tests"
            echo "  integration  End-to-end tests with real dependencies"
            echo ""
            echo "Examples:"
            echo "  $0                         # Run all backend tests"
            echo "  $0 --coverage              # Run with coverage"
            echo "  $0 --test-suite models     # Run model tests only"
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

echo ""
echo -e "${BLUE}🧪 Siros Backend Test Orchestration${NC}"
echo ""

# Check if we're in the right directory
if [ ! -d "$BACKEND_DIR" ]; then
    print_error "Backend directory not found at: $BACKEND_DIR"
    print_warning "Please run this script from the project root"
    exit 1
fi

print_status "Backend test orchestration starting..."
print_status "Project root: $PROJECT_ROOT"

# Prepare component script arguments
COMPONENT_ARGS=()
if [ "$VERBOSE" = true ]; then
    COMPONENT_ARGS+=("--verbose")
fi
if [ "$COVERAGE" = true ]; then
    COMPONENT_ARGS+=("--coverage")
fi
if [ "$TEST_SUITE" != "all" ]; then
    COMPONENT_ARGS+=("--test-suite" "$TEST_SUITE")
fi
if [ "$SKIP_INSTALL" = true ]; then
    COMPONENT_ARGS+=("--skip-install")
fi
if [ -n "$CONFIG" ]; then
    COMPONENT_ARGS+=("--config" "$CONFIG")
fi

OVERALL_SUCCESS=true
START_TIME=$(date +%s)

# Step 1: Core functionality tests first
echo ""
print_status "Step 1/3: Running core functionality tests (backend_gotest)..."

GOTEST_SCRIPT="$SCRIPT_DIR/backend/backend_gotest.sh"
if [ -f "$GOTEST_SCRIPT" ]; then
    if "$GOTEST_SCRIPT" "${COMPONENT_ARGS[@]}"; then
        print_success "Backend Go tests passed!"
    else
        print_error "Backend Go tests failed!"
        OVERALL_SUCCESS=false
    fi
else
    print_warning "backend_gotest.sh not found at: $GOTEST_SCRIPT"
    print_warning "Skipping Go tests step"
fi

# Step 2: Code quality analysis
echo ""
print_status "Step 2/3: Running code quality analysis (backend_lint)..."

LINT_SCRIPT="$SCRIPT_DIR/backend/backend_lint.sh"
if [ -f "$LINT_SCRIPT" ]; then
    if "$LINT_SCRIPT" "${COMPONENT_ARGS[@]}"; then
        print_success "Backend linting passed!"
    else
        print_warning "Backend linting found issues, but continuing..."
        # Don't fail overall for linting issues, just warn
    fi
else
    print_warning "backend_lint.sh not found at: $LINT_SCRIPT"
    print_warning "Skipping linting step"
fi

# Step 3: Security vulnerability scan
echo ""
print_status "Step 3/3: Running security vulnerability scan (backend_gosec)..."

GOSEC_SCRIPT="$SCRIPT_DIR/backend/backend_gosec.sh"
if [ -f "$GOSEC_SCRIPT" ]; then
    if "$GOSEC_SCRIPT" "${COMPONENT_ARGS[@]}"; then
        print_success "Backend security scan passed!"
    else
        print_warning "Backend security scan found issues, but continuing..."
        # Don't fail overall for security warnings, just warn
    fi
else
    print_warning "backend_gosec.sh not found at: $GOSEC_SCRIPT"
    print_warning "Skipping security scan step"
fi

# Final results
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "============================================================"
if [ "$OVERALL_SUCCESS" = true ]; then
    print_success "Backend test orchestration completed successfully! (${DURATION}s)"
    echo ""
    exit 0
else
    print_error "Backend test orchestration failed! (${DURATION}s)"
    print_warning "Check the output above for specific failures"
    echo ""
    exit 1
fi
