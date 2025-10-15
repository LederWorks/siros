#!/bin/bash

# Siros Infrastructure Deployment Automation Script
# Cross-platform deployment orchestration for multiple cloud providers and local environments

set -e

# Default values
TARGET="local"
ENVIRONMENT="development"
TOOL=""
VERBOSE=false
SKIP_VALIDATION=false
DRY_RUN=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --target|-t)
            TARGET="$2"
            shift 2
            ;;
        --environment|-e)
            ENVIRONMENT="$2"
            shift 2
            ;;
        --tool)
            TOOL="$2"
            shift 2
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --skip-validation)
            SKIP_VALIDATION=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help|-h)
            echo "🚀 Siros Infrastructure Deployment"
            echo ""
            echo "USAGE:"
            echo "  $0 [options]"
            echo ""
            echo "OPTIONS:"
            echo "  --target, -t <target>        Deployment target (local, aws, azure, gcp, pulumi)"
            echo "  --environment, -e <env>      Environment (development, staging, production)"
            echo "  --tool <tool>               IaC tool (terraform, cloudformation, arm, bicep, pulumi, docker)"
            echo "  --verbose, -v               Enable verbose output with detailed logging"
            echo "  --skip-validation           Skip infrastructure validation checks"
            echo "  --dry-run                   Show what would be deployed without actual deployment"
            echo "  --help, -h                  Show this help message"
            echo ""
            echo "EXAMPLES:"
            echo "  $0 --target local                           # Deploy local development environment"
            echo "  $0 --target aws --environment production    # Deploy to AWS production"
            echo "  $0 --target azure --tool terraform --dry-run # Dry run Azure deployment with Terraform"
            echo ""
            echo "TARGETS:"
            echo "  local   - Local development with Docker Compose"
            echo "  aws     - Amazon Web Services deployment"
            echo "  azure   - Microsoft Azure deployment"
            echo "  gcp     - Google Cloud Platform deployment"
            echo "  pulumi  - Multi-cloud Pulumi deployment"
            echo ""
            echo "TOOLS:"
            echo "  terraform      - HashiCorp Terraform (all clouds)"
            echo "  cloudformation - AWS CloudFormation"
            echo "  arm            - Azure Resource Manager templates"
            echo "  bicep          - Azure Bicep"
            echo "  pulumi         - Pulumi (TypeScript, Python, YAML)"
            echo "  docker         - Docker Compose (local only)"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

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

print_verbose() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${BLUE}[VERBOSE]${NC} $1"
    fi
}

# Path resolution
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRASTRUCTURE_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$INFRASTRUCTURE_DIR")"

print_status "🚀 Siros Infrastructure Deployment"
print_status "Target: $TARGET | Environment: $ENVIRONMENT | Tool: $TOOL"

if [ "$DRY_RUN" = true ]; then
    print_warning "DRY RUN MODE - No actual deployment will occur"
fi

# Determine deployment tool if not specified
if [ -z "$TOOL" ]; then
    case $TARGET in
        "local") TOOL="docker" ;;
        "aws") TOOL="terraform" ;;
        "azure") TOOL="terraform" ;;
        "gcp") TOOL="terraform" ;;
        "pulumi") TOOL="pulumi" ;;
    esac
    print_status "Auto-selected tool: $TOOL"
fi

# Validate target and tool combinations
validate_combination() {
    local target=$1
    local tool=$2

    case $target in
        "local")
            if [[ "$tool" != "docker" ]]; then
                return 1
            fi
            ;;
        "aws")
            if [[ ! "$tool" =~ ^(terraform|cloudformation|pulumi)$ ]]; then
                return 1
            fi
            ;;
        "azure")
            if [[ ! "$tool" =~ ^(terraform|arm|bicep|pulumi)$ ]]; then
                return 1
            fi
            ;;
        "gcp")
            if [[ ! "$tool" =~ ^(terraform|pulumi)$ ]]; then
                return 1
            fi
            ;;
        "pulumi")
            if [[ "$tool" != "pulumi" ]]; then
                return 1
            fi
            ;;
        *)
            return 1
            ;;
    esac
    return 0
}

if ! validate_combination "$TARGET" "$TOOL"; then
    print_error "Invalid combination: Target '$TARGET' does not support tool '$TOOL'"
    case $TARGET in
        "local") print_warning "Valid tools for $TARGET: docker" ;;
        "aws") print_warning "Valid tools for $TARGET: terraform, cloudformation, pulumi" ;;
        "azure") print_warning "Valid tools for $TARGET: terraform, arm, bicep, pulumi" ;;
        "gcp") print_warning "Valid tools for $TARGET: terraform, pulumi" ;;
        "pulumi") print_warning "Valid tools for $TARGET: pulumi" ;;
    esac
    exit 1
fi

# Pre-deployment validation
if [ "$SKIP_VALIDATION" = false ]; then
    print_status "Running pre-deployment validation..."

    # Check tool availability
    case $TOOL in
        "docker")
            if ! command -v docker &> /dev/null; then
                print_error "Docker is not installed or not in PATH"
                exit 1
            fi
            if ! command -v docker-compose &> /dev/null; then
                print_error "Docker Compose is not installed or not in PATH"
                exit 1
            fi
            ;;
        "terraform")
            if ! command -v terraform &> /dev/null; then
                print_error "Terraform is not installed or not in PATH"
                exit 1
            fi
            ;;
        "pulumi")
            if ! command -v pulumi &> /dev/null; then
                print_error "Pulumi is not installed or not in PATH"
                exit 1
            fi
            ;;
    esac

    print_success "Pre-deployment validation passed"
fi

# Target-specific deployment logic
case $TARGET in
    "local")
        print_status "Deploying local development environment..."
        COMPOSE_FILE="$INFRASTRUCTURE_DIR/local/docker-compose.yml"

        if [ "$ENVIRONMENT" = "production" ]; then
            COMPOSE_FILE="$INFRASTRUCTURE_DIR/local/docker-compose.prod.yml"
        fi

        if [ ! -f "$COMPOSE_FILE" ]; then
            print_error "Docker Compose file not found: $COMPOSE_FILE"
            exit 1
        fi

        print_verbose "Using Docker Compose file: $COMPOSE_FILE"

        if [ "$DRY_RUN" = true ]; then
            print_status "Would execute: docker-compose -f \"$COMPOSE_FILE\" up -d"
        else
            print_status "Starting services with Docker Compose..."
            cd "$(dirname "$COMPOSE_FILE")"
            docker-compose -f "$COMPOSE_FILE" up -d

            if [ $? -eq 0 ]; then
                print_success "Local environment deployed successfully"
                print_status "Backend API: http://localhost:8080"
                print_status "Frontend: http://localhost:5173 (if full-stack profile enabled)"
                print_status "Database: localhost:5432"
            else
                print_error "Docker Compose deployment failed"
                exit 1
            fi
        fi
        ;;

    "aws")
        print_status "Deploying to AWS with $TOOL..."
        AWS_DIR="$INFRASTRUCTURE_DIR/aws"

        case $TOOL in
            "terraform")
                TERRAFORM_DIR="$AWS_DIR/terraform"
                if [ ! -d "$TERRAFORM_DIR" ]; then
                    print_error "AWS Terraform directory not found: $TERRAFORM_DIR"
                    exit 1
                fi

                print_verbose "Using Terraform directory: $TERRAFORM_DIR"
                cd "$TERRAFORM_DIR"

                if [ "$DRY_RUN" = true ]; then
                    print_status "Would execute Terraform plan and apply"
                else
                    print_status "Initializing Terraform..."
                    terraform init

                    print_status "Planning Terraform deployment..."
                    terraform plan -var="environment=$ENVIRONMENT"

                    print_status "Applying Terraform configuration..."
                    terraform apply -var="environment=$ENVIRONMENT" -auto-approve

                    if [ $? -eq 0 ]; then
                        print_success "AWS deployment completed successfully"
                    else
                        print_error "AWS Terraform deployment failed"
                        exit 1
                    fi
                fi
                ;;

            "cloudformation")
                print_status "CloudFormation deployment not yet implemented"
                print_warning "Please use Terraform for AWS deployment"
                exit 1
                ;;
        esac
        ;;

    "azure")
        print_status "Deploying to Azure with $TOOL..."

        case $TOOL in
            "terraform")
                print_status "Azure Terraform deployment not yet implemented"
                print_warning "Please use local deployment for now"
                exit 1
                ;;

            "arm")
                print_status "ARM template deployment not yet implemented"
                print_warning "Please use local deployment for now"
                exit 1
                ;;

            "bicep")
                print_status "Bicep deployment not yet implemented"
                print_warning "Please use local deployment for now"
                exit 1
                ;;
        esac
        ;;

    "gcp")
        print_status "Deploying to GCP with $TOOL..."

        print_status "GCP deployment not yet implemented"
        print_warning "Please use local deployment for now"
        exit 1
        ;;

    "pulumi")
        print_status "Deploying with Pulumi..."

        print_status "Pulumi deployment not yet implemented"
        print_warning "Please use local deployment for now"
        exit 1
        ;;
esac

print_status "Deployment completed successfully"
