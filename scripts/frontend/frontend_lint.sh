#!/bin/bash

# Siros Frontend Linting Script
# Runs TypeScript/React code quality checks using ESLint and TypeScript compiler

set -e

# Parse command line arguments
VERBOSE=false
SKIP_LINT=false
SKIP_TYPE_CHECK=false
FIX=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --skip-lint)
            SKIP_LINT=true
            shift
            ;;
        --skip-type-check)
            SKIP_TYPE_CHECK=true
            shift
            ;;
        --fix)
            FIX=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --verbose, -v         Enable verbose output"
            echo "  --skip-lint           Skip ESLint checking"
            echo "  --skip-type-check     Skip TypeScript type checking"
            echo "  --fix                 Automatically fix linting issues"
            echo "  --help, -h            Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "🔍 Running Siros frontend code quality checks..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Check if frontend dependencies exist
if [ ! -f "$PROJECT_ROOT/frontend/package.json" ]; then
    print_error "Frontend package.json not found!"
    exit 1
fi

if [ ! -d "$PROJECT_ROOT/frontend/node_modules" ]; then
    print_error "Frontend dependencies not found!"
    print_warning "Run 'npm ci' in the frontend directory first"
    exit 1
fi

cd "$PROJECT_ROOT/frontend"

# ESLint checking
if [ "$SKIP_LINT" = false ]; then
    print_status "Running frontend linting (ESLint)..."

    if [ "$FIX" = true ]; then
        LINT_COMMAND="lint:fix"
    else
        LINT_COMMAND="lint"
    fi

    echo "  Running: npm run $LINT_COMMAND"
    echo ""  # Add spacing for better readability

    if npm run "$LINT_COMMAND"; then
        echo ""  # Add spacing after output
        print_success "Frontend linting passed!"
    else
        echo ""  # Add spacing after output
        print_error "Frontend linting failed!"
        exit 1
    fi
fi

# TypeScript type checking
if [ "$SKIP_TYPE_CHECK" = false ]; then
    print_status "Running TypeScript type checking..."
    echo "  Running: npm run type-check"
    echo ""  # Add spacing for better readability

    if npm run type-check; then
        echo ""  # Add spacing after output
        print_success "TypeScript type checking passed!"
    else
        echo ""  # Add spacing after output
        print_error "TypeScript type checking failed!"
        exit 1
    fi
fi

# Prettier formatting check (optional)
print_status "Checking code formatting (Prettier)..."
echo "  Running: npm run format:check"
echo ""  # Add spacing for better readability

if npm run format:check 2>/dev/null; then
    echo ""  # Add spacing after output
    print_success "Code formatting is correct!"
else
    echo ""  # Add spacing after output
    print_warning "Code formatting issues found"
    print_warning "Run 'npm run format' to fix formatting issues"
fi

print_success "Frontend code quality checks completed successfully! ✨"
