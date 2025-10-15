#!/bin/bash

# Siros Backend Linting Script
# Runs Go code quality checks using golangci-lint

set -e

# Parse command line arguments
VERBOSE=false
SKIP_SECURITY=false
SKIP_INSTALL=false
CONFIG=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --skip-security)
            SKIP_SECURITY=true
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
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --verbose, -v         Enable verbose output"
            echo "  --skip-security       Skip security scanning"
            echo "  --skip-install        Skip automatic tool installation/updates"
            echo "  --config, -c PATH     Use custom golangci-lint config"
            echo "  --help, -h            Show this help message"
            echo "  --config, -c PATH     Use custom golangci-lint config"
            echo "  --help, -h            Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "🔍 Running Siros backend code quality checks..."

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

# Backend linting
print_status "Running backend linting (golangci-lint)..."
cd "$PROJECT_ROOT/backend"

if command -v golangci-lint &> /dev/null; then
    if [ "$SKIP_INSTALL" = false ]; then
        print_status "golangci-lint found, updating to latest version..."
        go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
        if [ $? -eq 0 ]; then
            print_success "golangci-lint updated to latest version"
        else
            print_warning "Failed to update golangci-lint, using existing version"
        fi
    else
        print_status "golangci-lint found, skipping update (skip-install flag set)"
    fi

    # Determine config path
    if [ -n "$CONFIG" ]; then
        CONFIG_PATH="$CONFIG"
    else
        CONFIG_PATH="$PROJECT_ROOT/.golangci.yml"
    fi

    if [ "$VERBOSE" = true ]; then
        echo "  Using config: $CONFIG_PATH"
    fi

    echo "  Running: golangci-lint run --config $CONFIG_PATH"
    echo ""  # Add spacing for better readability

    # Build arguments
    ARGS=("run" "--config" "$CONFIG_PATH")
    if [ "$VERBOSE" = true ]; then
        ARGS+=("--verbose")
    fi

    if golangci-lint "${ARGS[@]}"; then
        echo ""  # Add spacing after output
        print_success "Backend linting passed!"
    else
        echo ""  # Add spacing after output
        print_error "Backend linting failed!"
        exit 1
    fi
else
    if [ "$SKIP_INSTALL" = false ]; then
        print_status "golangci-lint not found, installing..."
        go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
        if [ $? -eq 0 ]; then
            print_success "golangci-lint installed successfully"

            # Set config path after installation
            if [ -n "$CONFIG" ]; then
                CONFIG_PATH="$CONFIG"
            else
                CONFIG_PATH="$PROJECT_ROOT/.golangci.yml"
            fi
        else
            print_error "Failed to install golangci-lint!"
            exit 1
        fi
    else
        print_error "golangci-lint not found and skip-install flag is set!"
        print_warning "Please install manually: go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
        exit 1
    fi
fi

# Security scanning (optional)
if [ "$SKIP_SECURITY" = false ]; then
    print_status "Running security scan (gosec)..."

    if command -v gosec &> /dev/null; then
        if [ "$SKIP_INSTALL" = false ]; then
            print_status "gosec found, updating to latest version..."
            go install github.com/securecodewarrior/gosec/v2/cmd/gosec@latest
            if [ $? -eq 0 ]; then
                print_success "gosec updated to latest version"
            else
                print_warning "Failed to update gosec, using existing version"
            fi
        else
            print_status "gosec found, skipping update (skip-install flag set)"
        fi

        echo "  Running: gosec ./..."
        echo ""  # Add spacing for better readability

        if gosec ./...; then
            echo ""  # Add spacing after output
            print_success "Security scan passed!"
        else
            echo ""  # Add spacing after output
            print_warning "Security scan found issues"
            print_warning "Run 'gosec ./...' for details"
        fi
    else
        if [ "$SKIP_INSTALL" = false ]; then
            print_status "gosec not found, installing..."
            go install github.com/securecodewarrior/gosec/v2/cmd/gosec@latest
            if [ $? -eq 0 ]; then
                print_success "gosec installed successfully"
                echo "  Running: gosec ./..."
                echo ""  # Add spacing for better readability

                if gosec ./...; then
                    echo ""  # Add spacing after output
                    print_success "Security scan passed!"
                else
                    echo ""  # Add spacing after output
                    print_warning "Security scan found issues"
                    print_warning "Run 'gosec ./...' for details"
                fi
            else
                print_warning "Failed to install gosec, skipping security scan"
            fi
        else
            print_warning "gosec not found and skip-install flag is set, skipping security scan"
            print_warning "To install manually: go install github.com/securecodewarrior/gosec/v2/cmd/gosec@latest"
        fi
    fi
fi

print_success "Backend code quality checks completed successfully! ✨"
