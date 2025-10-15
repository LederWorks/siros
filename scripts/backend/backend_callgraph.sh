#!/bin/bash
# Backend Call Graph Generator for Siros
# Generates comprehensive call graph visualizations for the Go backend
# Automatically cleans up previous graphs before generating new ones

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${CYAN}[INFO] $1${NC}"
}

log_success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

log_error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

log_status() {
    echo -e "${BLUE}$1${NC}"
}

# Parse command line arguments
SKIP_INSTALL=0
VERBOSE_OUTPUT=0
SHOW_HELP=0

for arg in "$@"
do
    case $arg in
        --skip-install)
            SKIP_INSTALL=1
            shift
            ;;
        --verbose)
            VERBOSE_OUTPUT=1
            shift
            ;;
        --help)
            SHOW_HELP=1
            shift
            ;;
        *)
            log_error "Unknown option: $arg"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

if [ $SHOW_HELP -eq 1 ]; then
    log_status "Backend Call Graph Generator for Siros"
    echo ""
    echo -e "${YELLOW}USAGE:${NC}"
    echo "  ./scripts/backend_callgraph.sh [options]"
    echo ""
    echo -e "${YELLOW}OPTIONS:${NC}"
    echo "  --skip-install    Skip automatic installation of go-callvis"
    echo "  --verbose         Enable verbose output for debugging"
    echo "  --help            Show this help message"
    echo ""
    echo -e "${YELLOW}DESCRIPTION:${NC}"
    echo "  This script automatically cleans up previous call graphs and generates"
    echo "  new comprehensive visualizations of the Siros backend architecture."
    echo "  Generated SVG files are saved to docs/callgraph/"
    echo ""
    exit 0
fi

log_status "🔍 Siros Backend Call Graph Generator"
log_status "====================================="
echo ""

# Check if we're in the right directory
if [ ! -f "go.mod" ] && [ ! -d "backend" ]; then
    log_error "Please run this script from the project root"
    exit 1
fi

# Step 1: Clean up previous call graphs
log_info "Cleaning up previous call graph files..."
CALLGRAPH_DIR="docs/callgraph"
if [ -d "$CALLGRAPH_DIR" ]; then
    echo "🗑️  Removing existing call graphs..."
    rm -rf "$CALLGRAPH_DIR"
    log_success "Previous call graphs cleaned"
else
    echo -e "${GRAY}ℹ️  No previous call graphs to clean${NC}"
fi

# Create docs directory structure
mkdir -p docs
mkdir -p "$CALLGRAPH_DIR"

# Navigate to backend directory
cd backend

# Step 2: Check and install dependencies
log_info "Checking dependencies..."

# Check if go-callvis is installed
if ! command -v go-callvis &> /dev/null; then
    if [ $SKIP_INSTALL -eq 0 ]; then
        log_warning "go-callvis not found, installing latest version..."
        go install github.com/ofabry/go-callvis@latest
        if [ $? -ne 0 ]; then
            log_error "Failed to install go-callvis"
            exit 1
        fi
        log_success "go-callvis installed successfully"
    else
        log_error "go-callvis not found and --skip-install specified"
        echo -e "${GRAY}Install manually: go install github.com/ofabry/go-callvis@latest${NC}"
        exit 1
    fi
else
    if [ $SKIP_INSTALL -eq 0 ]; then
        log_info "go-callvis found, updating to latest version..."
        go install github.com/ofabry/go-callvis@latest
        if [ $? -eq 0 ]; then
            log_success "go-callvis updated to latest version"
        else
            log_warning "Failed to update go-callvis, using existing version"
        fi
    else
        log_success "go-callvis found (skipping update due to --skip-install)"
    fi
fi

# Check if dot (graphviz) is available
if ! command -v dot &> /dev/null; then
    log_warning "Graphviz 'dot' not found. Install for better output:"
    echo -e "${GRAY}   - Ubuntu/Debian: sudo apt install graphviz${NC}"
    echo -e "${GRAY}   - macOS: brew install graphviz${NC}"
    echo -e "${GRAY}   - Windows: choco install graphviz${NC}"
    USE_GRAPHVIZ=""
else
    log_success "Graphviz found, using enhanced rendering"
    USE_GRAPHVIZ="-graphviz"
fi

# Step 3: Generate call graphs
log_info "Generating call graph visualizations..."

# Function to generate call graphs
generate_callgraph() {
    local name="$1"
    local output_file="$2"
    local description="$3"
    local focus="$4"
    local limit="$5"
    local include="$6"
    local rankdir="${7:-LR}"
    local minlen="${8:-2}"
    local nodesep="${9:-0.5}"

    echo -e "${CYAN}📊 Generating $description...${NC}"

    # Build command arguments
    local cmd_args=()
    cmd_args+=("-format=svg")
    cmd_args+=("-file=$output_file")
    cmd_args+=("-nostd")

    if [ -n "$focus" ]; then
        cmd_args+=("-focus=$focus")
    fi
    if [ -n "$limit" ]; then
        cmd_args+=("-limit=$limit")
    fi
    if [ -n "$include" ]; then
        cmd_args+=("-include=$include")
    fi

    cmd_args+=("-rankdir=$rankdir")
    cmd_args+=("-minlen=$minlen")
    cmd_args+=("-nodesep=$nodesep")
    cmd_args+=("-group=pkg,type")

    if [ -n "$USE_GRAPHVIZ" ]; then
        cmd_args+=("$USE_GRAPHVIZ")
    fi

    cmd_args+=("github.com/LederWorks/siros/backend/cmd/siros-server")

    if [ $VERBOSE_OUTPUT -eq 1 ]; then
        echo -e "${GRAY}   Running: go-callvis ${cmd_args[*]}${NC}"
    fi

    # Execute go-callvis
    if go-callvis "${cmd_args[@]}" 2>/dev/null; then
        # Check if the output file was created successfully
        sleep 1  # Give it a moment to write the file

        if [ -f "$output_file.svg" ]; then
            local file_size=$(stat -f%z "$output_file.svg" 2>/dev/null || stat -c%s "$output_file.svg" 2>/dev/null || echo "0")
            if [ "$file_size" -gt 1000 ]; then
                # Check if file has reasonable content (>1KB)
                local size_kb=$((file_size / 1024))
                echo -e "${GREEN}✓ Generated: $output_file.svg (${size_kb} KB)${NC}"
                return 0
            else
                echo -e "${RED}✗ Generated file too small (${file_size} bytes): $output_file.svg${NC}"
                return 1
            fi
        else
            echo -e "${RED}✗ Output file not created: $output_file.svg${NC}"
            return 1
        fi
    else
        log_error "Error generating $name"
        return 1
    fi
}

# Generate different call graph views
success=true

# Main comprehensive overview
if ! generate_callgraph "full-comprehensive" "../docs/callgraph/full-comprehensive" "comprehensive call graph with enhanced depth" "" "" "" "LR" "1" "0.3"; then
    success=false
fi

# API layer visualization
if ! generate_callgraph "api-layer" "../docs/callgraph/api-layer" "API layer call graph" "github.com/LederWorks/siros/backend/internal/api" "" "" "LR" "3" "0.5"; then
    success=false
fi

# Services layer visualization
if ! generate_callgraph "services-layer" "../docs/callgraph/services-layer" "services layer call graph" "github.com/LederWorks/siros/backend/internal/services" "" "" "TB" "2" "0.5"; then
    success=false
fi

# Storage layer visualization
if ! generate_callgraph "storage-layer" "../docs/callgraph/storage-layer" "storage layer call graph" "github.com/LederWorks/siros/backend/internal/storage" "" "" "LR" "2" "0.5"; then
    success=false
fi

# Configuration layer visualization
if ! generate_callgraph "config-layer" "../docs/callgraph/config-layer" "configuration layer call graph" "github.com/LederWorks/siros/backend/internal/config" "" "" "LR" "2" "0.5"; then
    success=false
fi

# Middleware visualization
if ! generate_callgraph "middleware" "../docs/callgraph/middleware" "middleware call graph" "" "" "middleware,auth,cors" "LR" "2" "0.5"; then
    success=false
fi

# Step 4: Results summary
echo ""
if [ "$success" = true ]; then
    log_success "Call graph generation completed successfully! ✨"
else
    log_warning "Call graph generation completed with some errors"
fi

echo ""
log_info "Generated files in docs/callgraph/:"
if ls ../docs/callgraph/*.svg &> /dev/null; then
    for file in ../docs/callgraph/*.svg; do
        if [ -f "$file" ]; then
            local filename=$(basename "$file")
            local file_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0")
            local size_kb=$((file_size / 1024))
            echo -e "${GRAY}   📄 $filename (${size_kb} KB)${NC}"
        fi
    done
else
    log_warning "No SVG files found - check for errors above"
fi

echo ""
log_info "Next steps:"
echo -e "${GRAY}   📖 View documentation: docs/BACKEND_CALL_GRAPH.md${NC}"
echo -e "${GRAY}   🌐 Open SVG files in browser or VS Code for interactive viewing${NC}"

# Return to project root
cd ".."
