#!/bin/bash
set -e

# Siros Test Runner
SUITE="all"
COVERAGE=false
VERBOSE=false

show_help() {
    echo "🧪 Siros Test Runner"
    echo ""
    echo "Usage: ./scripts/test.sh [options]"
    echo ""
    echo "Options:"
    echo "  --suite <suite>     Run specific test suite (all, models, services, controllers, integration)"
    echo "  --coverage          Generate coverage report"
    echo "  --verbose           Show verbose output"
    echo "  --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./scripts/test.sh                     # Run all tests"
    echo "  ./scripts/test.sh --suite models     # Run models tests only"
    echo "  ./scripts/test.sh --coverage         # Run tests with coverage"
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --suite)
            SUITE="$2"
            shift 2
            ;;
        --coverage)
            COVERAGE=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help)
            show_help
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo "🧪 Siros Test Runner"

# Check if we're in the right directory
if [ ! -d "backend" ]; then
    echo "❌ Error: Please run this script from the project root"
    exit 1
fi

cd backend

TEST_ARGS=""
if [ "$VERBOSE" = true ]; then
    TEST_ARGS="-v"
fi

case $SUITE in
    "all")
        echo "🔍 Running all tests..."
        if [ "$COVERAGE" = true ]; then
            go test -coverprofile=coverage.out ./... $TEST_ARGS
            if [ $? -eq 0 ]; then
                echo ""
                echo "📊 Coverage Report:"
                go tool cover -func=coverage.out
                
                echo ""
                echo "🌐 Generating HTML coverage report..."
                go tool cover -html=coverage.out -o coverage.html
                echo "📄 Coverage report saved to backend/coverage.html"
            fi
        else
            go test ./... $TEST_ARGS
        fi
        ;;
    "models")
        echo "🏗️ Running models tests..."
        go test ./internal/models/ $TEST_ARGS
        ;;
    "services")
        echo "⚙️ Running services tests..."
        go test ./internal/services/ $TEST_ARGS
        ;;
    "controllers")
        echo "🌐 Running controllers tests..."
        go test ./internal/controllers/ $TEST_ARGS
        ;;
    "repositories")
        echo "🗄️ Running repositories tests..."
        go test ./internal/repositories/ $TEST_ARGS
        ;;
    "integration")
        echo "🔗 Running integration tests..."
        # Note: Integration tests to be implemented
        echo "⚠️ Integration tests not yet implemented"
        ;;
    *)
        echo "❌ Unknown test suite: $SUITE"
        echo "Available suites: all, models, services, controllers, repositories, integration"
        exit 1
        ;;
esac

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ All tests passed!"
else
    echo ""
    echo "❌ Some tests failed!"
    exit 1
fi