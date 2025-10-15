#!/bin/bash
# Siros Backend Security Scanning Script for Bash
# Runs gosec security analysis on Go backend code

set -e

# Default values
VERBOSE=false
JSON=false
SKIP_INSTALL=false
FORMAT="text"
OUTPUT=""
NO_FAIL=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose)
            VERBOSE=true
            shift
            ;;
        --json)
            JSON=true
            shift
            ;;
        --skip-install)
            SKIP_INSTALL=true
            shift
            ;;
        --format)
            FORMAT="$2"
            shift 2
            ;;
        --output)
            OUTPUT="$2"
            shift 2
            ;;
        --no-fail)
            NO_FAIL=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--verbose] [--json] [--skip-install] [--format FORMAT] [--output FILE] [--no-fail]"
            exit 1
            ;;
    esac
done

# Color functions
print_status() {
    echo -e "\033[36m[INFO] $1\033[0m"
}

print_success() {
    echo -e "\033[32m[SUCCESS] $1\033[0m"
}

print_warning() {
    echo -e "\033[33m[WARNING] $1\033[0m"
}

print_error() {
    echo -e "\033[31m[ERROR] $1\033[0m"
}

echo -e "\033[34m🔒 Running Siros backend security scan (gosec)...\033[0m"

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Change to backend directory
cd "$PROJECT_ROOT/backend"

print_status "Running gosec security scanner on backend..."

# Check if gosec is available
if command -v gosec &> /dev/null; then
    if [ "$SKIP_INSTALL" = false ]; then
        print_status "gosec found, updating to latest version..."
        if go install github.com/securego/gosec/v2/cmd/gosec@latest; then
            print_success "gosec updated to latest version"
        else
            print_warning "Failed to update gosec, using existing version"
        fi
    else
        print_status "gosec found, skipping update (skip-install flag set)"
    fi
else
    if [ "$SKIP_INSTALL" = false ]; then
        print_status "gosec not found, installing..."
        echo "  Running: go install github.com/securego/gosec/v2/cmd/gosec@latest"

        if ! go install github.com/securego/gosec/v2/cmd/gosec@latest; then
            print_error "Failed to install gosec! Please install manually with: go install github.com/securego/gosec/v2/cmd/gosec@latest"
            exit 1
        fi

        print_success "gosec installed successfully!"

        # Check if gosec is now available
        if ! command -v gosec &> /dev/null; then
            print_error "gosec still not found after installation. Please ensure \$GOPATH/bin is in your PATH."
            exit 1
        fi
    else
        print_error "gosec not found and skip-install flag is set!"
        print_warning "Please install manually: go install github.com/securego/gosec/v2/cmd/gosec@latest"
        exit 1
    fi
fi

# Build gosec command arguments
GOSEC_ARGS=("./...")

if [ "$JSON" = true ]; then
    GOSEC_ARGS+=("-fmt=json")
elif [ "$FORMAT" != "text" ]; then
    GOSEC_ARGS+=("-fmt=$FORMAT")
fi

if [ -n "$OUTPUT" ]; then
    GOSEC_ARGS+=("-out=$OUTPUT")
fi

if [ "$NO_FAIL" = true ]; then
    GOSEC_ARGS+=("-no-fail")
fi

if [ "$VERBOSE" = true ]; then
    GOSEC_ARGS+=("-verbose")
fi

# Display command being run
echo "  Running: gosec ${GOSEC_ARGS[*]}"
echo ""  # Add spacing for better readability

# Run gosec
set +e
gosec "${GOSEC_ARGS[@]}"
GOSEC_EXIT_CODE=$?
set -e

echo ""  # Add spacing after output

# Check results
if [ $GOSEC_EXIT_CODE -eq 0 ]; then
    print_success "Security scan completed successfully! No issues found. ✨"
elif [ "$NO_FAIL" = true ]; then
    print_warning "Security scan completed with issues, but --no-fail flag was used."
    print_warning "Check the output above for security findings."
else
    print_error "Security scan found issues! (Exit code: $GOSEC_EXIT_CODE)"
    print_error "Review the security findings above and fix them before proceeding."
    exit 1
fi
