#!/bin/bash

# Siros API Testing Script (Bash)
#
# Comprehensive API testing script for the Siros multi-cloud resource management platform.
# Tests all available endpoints including health, resources, search, schemas, terraform, and audit.
#
# Usage:
#   ./scripts/curl.sh                           # Run all tests
#   ./scripts/curl.sh health                    # Test only health endpoints
#   ./scripts/curl.sh --base-url https://api.siros.dev  # Test against remote API
#   ./scripts/curl.sh --verbose                 # Enable verbose output

set -euo pipefail

# Default configuration
BASE_URL="http://localhost:8080"
ENDPOINT="all"
VERBOSE=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --base-url)
            BASE_URL="$2"
            shift 2
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS] [ENDPOINT]"
            echo ""
            echo "OPTIONS:"
            echo "  --base-url URL    Set base URL (default: http://localhost:8080)"
            echo "  --verbose         Enable verbose output"
            echo "  --help            Show this help message"
            echo ""
            echo "ENDPOINTS:"
            echo "  all               Test all endpoints (default)"
            echo "  health            Test health endpoints only"
            echo "  resources         Test resource endpoints only"
            echo "  schemas           Test schema endpoints only"
            echo "  search            Test search endpoints only"
            echo "  terraform         Test terraform endpoints only"
            echo "  mcp               Test MCP endpoints only"
            echo "  audit             Test audit endpoints only"
            echo "  discovery         Test discovery endpoints only"
            exit 0
            ;;
        *)
            ENDPOINT="$1"
            shift
            ;;
    esac
done

# Helper functions
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_section() {
    local title=$1
    echo ""
    print_color $BLUE "$(printf '=%.0s' {1..60})"
    print_color $CYAN " $title"
    print_color $BLUE "$(printf '=%.0s' {1..60})"
}

test_endpoint() {
    local method=${1:-GET}
    local url=$2
    local description=$3
    local body=${4:-}

    print_color $YELLOW "→ Testing: $description"

    if [ "$VERBOSE" = true ]; then
        print_color $BLUE "  Method: $method"
        print_color $BLUE "  URL: $url"
        [ -n "$body" ] && print_color $BLUE "  Body: $body"
    fi

    local curl_args=(-s -X "$method" "$url" -H "Content-Type: application/json")

    if [ -n "$body" ]; then
        curl_args+=(-d "$body")
    fi

    if response=$(curl "${curl_args[@]}" 2>/dev/null); then
        print_color $GREEN "  ✅ SUCCESS"

        if [ "$VERBOSE" = true ]; then
            print_color $BLUE "  Response:"
            echo "$response" | jq . 2>/dev/null || echo "$response"
        else
            # Show abbreviated response
            if echo "$response" | jq -e '.data' >/dev/null 2>&1; then
                local data_type=$(echo "$response" | jq -r '.data | type' 2>/dev/null || echo "unknown")
                print_color $BLUE "  Data: $data_type"
            fi
            if echo "$response" | jq -e '.meta' >/dev/null 2>&1; then
                local version=$(echo "$response" | jq -r '.meta.version // "unknown"' 2>/dev/null)
                local timestamp=$(echo "$response" | jq -r '.meta.timestamp // "unknown"' 2>/dev/null)
                print_color $BLUE "  Meta: version=$version, timestamp=$timestamp"
            fi
        fi
        return 0
    else
        print_color $RED "  ❌ FAILED: HTTP request failed"
        return 1
    fi
}

test_health_endpoints() {
    print_section "HEALTH & SYSTEM ENDPOINTS"

    local results=0

    # Root health endpoint
    test_endpoint "GET" "$BASE_URL/api/v1/health" "Health Check (Root)" || ((results++))

    # Health check
    test_endpoint "GET" "$BASE_URL/api/v1/health/check" "Health Check (Detailed)" || ((results++))

    # Health version (may not exist yet)
    test_endpoint "GET" "$BASE_URL/api/v1/health/version" "Health Version" || ((results++))

    return $results
}test_resource_endpoints() {
    print_section "RESOURCE MANAGEMENT ENDPOINTS"

    local results=0
    local random_id=$RANDOM

    # List resources
    test_endpoint "GET" "$BASE_URL/api/v1/resources" "List Resources" || ((results++))

    # Create a test resource
    local test_resource=$(cat <<EOF
{
    "type": "aws_instance",
    "provider": "aws",
    "name": "test-instance-$random_id",
    "data": {
        "instance_type": "t3.micro",
        "region": "us-east-1",
        "ami_id": "ami-12345678"
    },
    "metadata": {
        "environment": "test",
        "created_by": "api-test",
        "tags": {
            "test": "true",
            "created_by": "curl-script"
        }
    }
}
EOF
)

    test_endpoint "POST" "$BASE_URL/api/v1/resources" "Create Test Resource" "$test_resource" || ((results++))

    return $results
}

test_schema_endpoints() {
    print_section "SCHEMA MANAGEMENT ENDPOINTS"

    local results=0

    # List schemas
    test_endpoint "GET" "$BASE_URL/api/v1/schemas" "List Schemas" || ((results++))

    # Get specific schema (if available)
    test_endpoint "GET" "$BASE_URL/api/v1/schemas/aws_instance" "Get AWS Instance Schema" || ((results++))

    return $results
}

test_search_endpoints() {
    print_section "SEARCH & DISCOVERY ENDPOINTS"

    local results=0

    # Semantic search
    local search_query=$(cat <<EOF
{
    "query": "EC2 instances in production",
    "filters": {
        "provider": "aws",
        "type": "aws_instance"
    }
}
EOF
)

    test_endpoint "POST" "$BASE_URL/api/v1/search" "Semantic Search" "$search_query" || ((results++))

    # Text search
    local text_query=$(cat <<EOF
{
    "query": "test instance",
    "fields": ["name", "metadata.tags"]
}
EOF
)

    test_endpoint "POST" "$BASE_URL/api/v1/search/text" "Text Search" "$text_query" || ((results++))

    return $results
}

test_terraform_endpoints() {
    print_section "TERRAFORM INTEGRATION ENDPOINTS"

    local results=0
    local random_id=$RANDOM

    # Get terraform coverage
    test_endpoint "GET" "$BASE_URL/api/v1/terraform/coverage" "Terraform Coverage Analysis" || ((results++))

    # Create siros_key resource
    local siros_key=$(cat <<EOF
{
    "key": "test.environment.instance-$random_id",
    "path": "/test/environment",
    "data": {
        "resource_type": "aws_instance",
        "instance_id": "i-$random_id",
        "terraform_managed": true
    },
    "metadata": {
        "deployed_by": "terraform",
        "deployment_id": "test-deployment-$random_id"
    }
}
EOF
)

    test_endpoint "POST" "$BASE_URL/api/v1/terraform/siros_key" "Create Siros Key Resource" "$siros_key" || ((results++))

    # Query by path
    local path_query=$(cat <<EOF
{
    "path": "/test",
    "recursive": true
}
EOF
)

    test_endpoint "POST" "$BASE_URL/api/v1/terraform/siros_key_path" "Query Resources by Path" "$path_query" || ((results++))

    return $results
}

test_mcp_endpoints() {
    print_section "MODEL CONTEXT PROTOCOL ENDPOINTS"

    local results=0

    # Initialize MCP
    local mcp_init=$(cat <<EOF
{
    "protocolVersion": "2024-11-05",
    "capabilities": {
        "roots": {
            "listChanged": true
        },
        "sampling": {}
    },
    "clientInfo": {
        "name": "siros-api-test",
        "version": "1.0.0"
    }
}
EOF
)

    test_endpoint "POST" "$BASE_URL/api/v1/mcp/initialize" "MCP Initialize" "$mcp_init" || ((results++))

    # List MCP resources
    local mcp_list_resources=$(cat <<EOF
{
    "method": "resources/list",
    "params": {}
}
EOF
)

    test_endpoint "POST" "$BASE_URL/api/v1/mcp/resources/list" "MCP List Resources" "$mcp_list_resources" || ((results++))

    # List MCP tools
    local mcp_list_tools=$(cat <<EOF
{
    "method": "tools/list",
    "params": {}
}
EOF
)

    test_endpoint "POST" "$BASE_URL/api/v1/mcp/tools/list" "MCP List Tools" "$mcp_list_tools" || ((results++))

    return $results
}

test_audit_endpoints() {
    print_section "BLOCKCHAIN AUDIT ENDPOINTS"

    local results=0

    # List changes
    test_endpoint "GET" "$BASE_URL/api/v1/audit/changes" "List Audit Changes" || ((results++))

    return $results
}

test_discovery_endpoints() {
    print_section "CLOUD DISCOVERY ENDPOINTS"

    local results=0

    # Scan providers
    local scan_request=$(cat <<EOF
{
    "providers": ["aws"],
    "regions": ["us-east-1"],
    "filters": {
        "resource_types": ["ec2", "s3"]
    }
}
EOF
)

    test_endpoint "POST" "$BASE_URL/api/v1/discovery/scan" "Cloud Provider Scan" "$scan_request" || ((results++))

    return $results
}

# Main execution
main() {
    print_color $CYAN "🌐 Siros API Testing Script"
    print_color $BLUE "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_color $CYAN "Base URL: $BASE_URL"
    print_color $CYAN "Target Endpoint: $ENDPOINT"
    print_color $CYAN "Verbose Mode: $([ "$VERBOSE" = true ] && echo 'Enabled' || echo 'Disabled')"
    print_color $BLUE "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local total_failures=0
    local total_tests=0

    if [[ "$ENDPOINT" == "all" || "$ENDPOINT" == "health" ]]; then
        test_health_endpoints
        ((total_failures += $?))
        ((total_tests += 2))
    fi

    if [[ "$ENDPOINT" == "all" || "$ENDPOINT" == "schemas" ]]; then
        test_schema_endpoints
        ((total_failures += $?))
        ((total_tests += 2))
    fi

    if [[ "$ENDPOINT" == "all" || "$ENDPOINT" == "resources" ]]; then
        test_resource_endpoints
        ((total_failures += $?))
        ((total_tests += 2))
    fi

    if [[ "$ENDPOINT" == "all" || "$ENDPOINT" == "search" ]]; then
        test_search_endpoints
        ((total_failures += $?))
        ((total_tests += 2))
    fi

    if [[ "$ENDPOINT" == "all" || "$ENDPOINT" == "terraform" ]]; then
        test_terraform_endpoints
        ((total_failures += $?))
        ((total_tests += 3))
    fi

    if [[ "$ENDPOINT" == "all" || "$ENDPOINT" == "mcp" ]]; then
        test_mcp_endpoints
        ((total_failures += $?))
        ((total_tests += 3))
    fi

    if [[ "$ENDPOINT" == "all" || "$ENDPOINT" == "audit" ]]; then
        test_audit_endpoints
        ((total_failures += $?))
        ((total_tests += 1))
    fi

    if [[ "$ENDPOINT" == "all" || "$ENDPOINT" == "discovery" ]]; then
        test_discovery_endpoints
        ((total_failures += $?))
        ((total_tests += 1))
    fi

    # Summary
    print_section "TEST SUMMARY"

    local success_count=$((total_tests - total_failures))

    print_color $BLUE "Total Tests: $total_tests"
    print_color $GREEN "Successful: $success_count"
    print_color $RED "Failed: $total_failures"

    if [ $total_failures -eq 0 ]; then
        print_color $GREEN "🎉 All tests passed!"
        exit 0
    else
        print_color $YELLOW "⚠️  Some tests failed. Check output above for details."
        exit 1
    fi
}

# Check dependencies
if ! command -v curl &> /dev/null; then
    print_color $RED "Error: curl is required but not installed."
    exit 1
fi

if ! command -v jq &> /dev/null; then
    print_color $YELLOW "Warning: jq is not installed. JSON responses will not be formatted."
fi

# Run the main function
main
