#!/usr/bin/env pwsh

# Siros Infrastructure Deployment Automation Script
# Cross-platform deployment orchestration for multiple cloud providers and local environments

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("local", "aws", "azure", "gcp", "pulumi")]
    [string]$Target = "local",

    [Parameter(Mandatory = $false)]
    [ValidateSet("development", "staging", "production")]
    [string]$Environment = "development",

    [Parameter(Mandatory = $false)]
    [ValidateSet("terraform", "cloudformation", "arm", "bicep", "pulumi", "docker")]
    [string]$Tool = "",

    [switch]$VerboseOutput,
    [switch]$SkipValidation,
    [switch]$DryRun,
    [switch]$Help
)

if ($Help) {
    Write-Host "🚀 Siros Infrastructure Deployment" -ForegroundColor Blue
    Write-Host ""
    Write-Host "USAGE:" -ForegroundColor Yellow
    Write-Host "  .\scripts\deploy.ps1 [options]"
    Write-Host ""
    Write-Host "OPTIONS:" -ForegroundColor Yellow
    Write-Host "  -Target <target>        Deployment target (local, aws, azure, gcp, pulumi)"
    Write-Host "  -Environment <env>      Environment (development, staging, production)"
    Write-Host "  -Tool <tool>           IaC tool (terraform, cloudformation, arm, bicep, pulumi, docker)"
    Write-Host "  -VerboseOutput         Enable verbose output with detailed logging"
    Write-Host "  -SkipValidation        Skip infrastructure validation checks"
    Write-Host "  -DryRun                Show what would be deployed without actual deployment"
    Write-Host "  -Help                  Show this help message"
    Write-Host ""
    Write-Host "EXAMPLES:" -ForegroundColor Yellow
    Write-Host "  .\scripts\deploy.ps1 -Target local                           # Deploy local development environment"
    Write-Host "  .\scripts\deploy.ps1 -Target aws -Environment production     # Deploy to AWS production"
    Write-Host "  .\scripts\deploy.ps1 -Target azure -Tool terraform -DryRun  # Dry run Azure deployment with Terraform"
    Write-Host ""
    Write-Host "TARGETS:" -ForegroundColor Yellow
    Write-Host "  local   - Local development with Docker Compose"
    Write-Host "  aws     - Amazon Web Services deployment"
    Write-Host "  azure   - Microsoft Azure deployment"
    Write-Host "  gcp     - Google Cloud Platform deployment"
    Write-Host "  pulumi  - Multi-cloud Pulumi deployment"
    Write-Host ""
    Write-Host "TOOLS:" -ForegroundColor Yellow
    Write-Host "  terraform      - HashiCorp Terraform (all clouds)"
    Write-Host "  cloudformation - AWS CloudFormation"
    Write-Host "  arm            - Azure Resource Manager templates"
    Write-Host "  bicep          - Azure Bicep"
    Write-Host "  pulumi         - Pulumi (TypeScript, Python, YAML)"
    Write-Host "  docker         - Docker Compose (local only)"
    exit 0
}

# Color-coded output functions
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-Verbose {
    param([string]$Message)
    if ($VerboseOutput) {
        Write-Host "[VERBOSE] $Message" -ForegroundColor Blue
    }
}

# Path resolution
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$InfrastructureDir = Split-Path -Parent $ScriptDir
$ProjectRoot = Split-Path -Parent $InfrastructureDir

Write-Status "🚀 Siros Infrastructure Deployment"
Write-Status "Target: $Target | Environment: $Environment | Tool: $Tool"

if ($DryRun) {
    Write-Warning "DRY RUN MODE - No actual deployment will occur"
}

# Determine deployment tool if not specified
if (-not $Tool) {
    switch ($Target) {
        "local" { $Tool = "docker" }
        "aws" { $Tool = "terraform" }
        "azure" { $Tool = "terraform" }
        "gcp" { $Tool = "terraform" }
        "pulumi" { $Tool = "pulumi" }
    }
    Write-Status "Auto-selected tool: $Tool"
}

# Validate target and tool combinations
$validCombinations = @{
    "local"  = @("docker")
    "aws"    = @("terraform", "cloudformation", "pulumi")
    "azure"  = @("terraform", "arm", "bicep", "pulumi")
    "gcp"    = @("terraform", "pulumi")
    "pulumi" = @("pulumi")
}

if (-not $validCombinations[$Target].Contains($Tool)) {
    Write-Error "Invalid combination: Target '$Target' does not support tool '$Tool'"
    Write-Warning "Valid tools for $Target: $($validCombinations[$Target] -join ', ')"
    exit 1
}

# Pre-deployment validation
if (-not $SkipValidation) {
    Write-Status "Running pre-deployment validation..."

    # Check tool availability
    $toolAvailable = $false
    switch ($Tool) {
        "docker" {
            $toolAvailable = Get-Command docker -ErrorAction SilentlyContinue
            if (-not $toolAvailable) {
                Write-Error "Docker is not installed or not in PATH"
                exit 1
            }
        }
        "terraform" {
            $toolAvailable = Get-Command terraform -ErrorAction SilentlyContinue
            if (-not $toolAvailable) {
                Write-Error "Terraform is not installed or not in PATH"
                exit 1
            }
        }
        "pulumi" {
            $toolAvailable = Get-Command pulumi -ErrorAction SilentlyContinue
            if (-not $toolAvailable) {
                Write-Error "Pulumi is not installed or not in PATH"
                exit 1
            }
        }
    }

    Write-Success "Pre-deployment validation passed"
}

# Target-specific deployment logic
switch ($Target) {
    "local" {
        Write-Status "Deploying local development environment..."
        $composeFile = Join-Path $InfrastructureDir "local\docker-compose.yml"

        if ($Environment -eq "production") {
            $composeFile = Join-Path $InfrastructureDir "local\docker-compose.prod.yml"
        }

        if (-not (Test-Path $composeFile)) {
            Write-Error "Docker Compose file not found: $composeFile"
            exit 1
        }

        Write-Verbose "Using Docker Compose file: $composeFile"

        if ($DryRun) {
            Write-Status "Would execute: docker-compose -f `"$composeFile`" up -d"
        }
        else {
            Write-Status "Starting services with Docker Compose..."
            Set-Location (Split-Path $composeFile)
            docker-compose -f $composeFile up -d

            if ($LASTEXITCODE -eq 0) {
                Write-Success "Local environment deployed successfully"
                Write-Status "Backend API: http://localhost:8080"
                Write-Status "Frontend: http://localhost:5173 (if full-stack profile enabled)"
                Write-Status "Database: localhost:5432"
            }
            else {
                Write-Error "Docker Compose deployment failed"
                exit 1
            }
        }
    }

    "aws" {
        Write-Status "Deploying to AWS with $Tool..."
        $awsDir = Join-Path $InfrastructureDir "aws"

        switch ($Tool) {
            "terraform" {
                $terraformDir = Join-Path $awsDir "terraform"
                if (-not (Test-Path $terraformDir)) {
                    Write-Error "AWS Terraform directory not found: $terraformDir"
                    exit 1
                }

                Write-Verbose "Using Terraform directory: $terraformDir"
                Set-Location $terraformDir

                if ($DryRun) {
                    Write-Status "Would execute Terraform plan and apply"
                }
                else {
                    Write-Status "Initializing Terraform..."
                    terraform init

                    Write-Status "Planning Terraform deployment..."
                    terraform plan -var="environment=$Environment"

                    Write-Status "Applying Terraform configuration..."
                    terraform apply -var="environment=$Environment" -auto-approve

                    if ($LASTEXITCODE -eq 0) {
                        Write-Success "AWS deployment completed successfully"
                    }
                    else {
                        Write-Error "AWS Terraform deployment failed"
                        exit 1
                    }
                }
            }

            "cloudformation" {
                $cfnDir = Join-Path $awsDir "cloudformation"
                Write-Status "CloudFormation deployment not yet implemented"
                Write-Warning "Please use Terraform for AWS deployment"
                exit 1
            }
        }
    }

    "azure" {
        Write-Status "Deploying to Azure with $Tool..."
        $azureDir = Join-Path $InfrastructureDir "azure"

        switch ($Tool) {
            "terraform" {
                $terraformDir = Join-Path $azureDir "terraform"
                Write-Status "Azure Terraform deployment not yet implemented"
                Write-Warning "Please use local deployment for now"
                exit 1
            }

            "arm" {
                $armDir = Join-Path $azureDir "arm-templates"
                Write-Status "ARM template deployment not yet implemented"
                Write-Warning "Please use local deployment for now"
                exit 1
            }

            "bicep" {
                $bicepDir = Join-Path $azureDir "bicep"
                Write-Status "Bicep deployment not yet implemented"
                Write-Warning "Please use local deployment for now"
                exit 1
            }
        }
    }

    "gcp" {
        Write-Status "Deploying to GCP with $Tool..."
        $gcpDir = Join-Path $InfrastructureDir "gcp"

        Write-Status "GCP deployment not yet implemented"
        Write-Warning "Please use local deployment for now"
        exit 1
    }

    "pulumi" {
        Write-Status "Deploying with Pulumi..."
        $pulumiDir = Join-Path $InfrastructureDir "pulumi"

        Write-Status "Pulumi deployment not yet implemented"
        Write-Warning "Please use local deployment for now"
        exit 1
    }
}

Write-Status "Deployment completed successfully"
