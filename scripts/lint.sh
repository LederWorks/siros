#!/bin/bash

# Siros Linting Script
# Runs code quality checks for both backend and frontend

set -e

echo "🔍 Running Siros code quality checks..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
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

# Backend linting
print_status "Running backend linting (golangci-lint)..."
cd "$PROJECT_ROOT/backend"

if command -v golangci-lint &> /dev/null; then
    if golangci-lint run; then
        print_success "Backend linting passed!"
    else
        print_error "Backend linting failed!"
        exit 1
    fi
else
    print_warning "golangci-lint not found, skipping backend linting"
    print_warning "Install with: go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
fi

# Frontend linting
print_status "Running frontend linting (ESLint)..."
cd "$PROJECT_ROOT/frontend"

if [ -f "package.json" ] && [ -d "node_modules" ]; then
    if npm run lint; then
        print_success "Frontend linting passed!"
    else
        print_error "Frontend linting failed!"
        exit 1
    fi
else
    print_warning "Frontend dependencies not found, skipping frontend linting"
    print_warning "Run 'npm ci' in the frontend directory first"
fi

# Type checking
print_status "Running TypeScript type checking..."
if [ -f "$PROJECT_ROOT/frontend/package.json" ] && [ -d "$PROJECT_ROOT/frontend/node_modules" ]; then
    cd "$PROJECT_ROOT/frontend"
    if npm run type-check; then
        print_success "TypeScript type checking passed!"
    else
        print_error "TypeScript type checking failed!"
        exit 1
    fi
else
    print_warning "Frontend dependencies not found, skipping type checking"
fi

print_success "All linting checks completed successfully! ✨"
