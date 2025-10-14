#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Siros API Testing Script (PowerShell)

.DESCRIPTION
    Comprehensive API testing script for the Siros multi-cloud resource management platform.
    Tests all available endpoints including health, resources, search, schemas, terraform, and audit.

.PARAMETER BaseUrl
    Base URL for the Siros API (default: http://localhost:8080)

.PARAMETER Endpoint
    Specific endpoint to test (default: all)

.PARAMETER Verbose
    Enable verbose output with request/response details

.EXAMPLE
    .\scripts\curl.ps1
    Run all API tests with default settings

.EXAMPLE
    .\scripts\curl.ps1 -Endpoint health -Verbose
    Test only health endpoints with verbose output

.EXAMPLE
    .\scripts\curl.ps1 -BaseUrl "https://api.siros.dev"
    Test against remote API server
#>

param(
    [string]$BaseUrl = "http://localhost:8080",
    [string]$Endpoint = "all",
    [switch]$Verbose
)

# Colors for output formatting
$Colors = @{
    Green  = "`e[32m"
    Red    = "`e[31m"
    Yellow = "`e[33m"
    Blue   = "`e[34m"
    Cyan   = "`e[36m"
    Reset  = "`e[0m"
}

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "Reset"
    )
    Write-Host "$($Colors[$Color])$Message$($Colors.Reset)"
}

function Write-Section {
    param([string]$Title)
    Write-Host ""
    Write-ColorOutput "=" * 60 "Blue"
    Write-ColorOutput " $Title" "Cyan"
    Write-ColorOutput "=" * 60 "Blue"
}

function Test-ApiEndpoint {
    param(
        [string]$Method = "GET",
        [string]$Url,
        [string]$Description,
        [hashtable]$Headers = @{},
        [string]$Body = $null
    )

    Write-ColorOutput "→ Testing: $Description" "Yellow"

    if ($Verbose) {
        Write-ColorOutput "  Method: $Method" "Blue"
        Write-ColorOutput "  URL: $Url" "Blue"
        if ($Body) {
            Write-ColorOutput "  Body: $Body" "Blue"
        }
    }

    try {
        $params = @{
            Uri         = $Url
            Method      = $Method
            Headers     = $Headers
            ContentType = "application/json"
        }

        if ($Body) {
            $params.Body = $Body
        }

        $response = Invoke-RestMethod @params

        Write-ColorOutput "  ✅ SUCCESS" "Green"

        if ($Verbose) {
            Write-ColorOutput "  Response:" "Blue"
            $response | ConvertTo-Json -Depth 10 | Write-Host
        }
        else {
            # Show abbreviated response
            if ($response.data) {
                Write-ColorOutput "  Data: $($response.data.GetType().Name)" "Blue"
            }
            if ($response.meta) {
                Write-ColorOutput "  Meta: version=$($response.meta.version), timestamp=$($response.meta.timestamp)" "Blue"
            }
        }

        return $true
    }
    catch {
        Write-ColorOutput "  ❌ FAILED: $($_.Exception.Message)" "Red"

        if ($Verbose) {
            Write-ColorOutput "  Full Error:" "Red"
            $_.Exception | Format-List | Out-String | Write-Host
        }

        return $false
    }
}

function Test-HealthEndpoints {
    Write-Section "HEALTH & SYSTEM ENDPOINTS"

    $results = @()

    # Root health endpoint
    $results += Test-ApiEndpoint -Url "$BaseUrl/api/v1/health" -Description "Health Check (Root)"

    # Health check
    $results += Test-ApiEndpoint -Url "$BaseUrl/api/v1/health/check" -Description "Health Check (Detailed)"

    # Health version (may not exist yet)
    $results += Test-ApiEndpoint -Url "$BaseUrl/api/v1/health/version" -Description "Health Version"

    return $results
}function Test-ResourceEndpoints {
    Write-Section "RESOURCE MANAGEMENT ENDPOINTS"

    $results = @()

    # List resources
    $results += Test-ApiEndpoint -Url "$BaseUrl/api/v1/resources" -Description "List Resources"

    # Create a test resource
    $testResource = @{
        type     = "aws_instance"
        provider = "aws"
        name     = "test-instance-$(Get-Random)"
        data     = @{
            instance_type = "t3.micro"
            region        = "us-east-1"
            ami_id        = "ami-12345678"
        }
        metadata = @{
            environment = "test"
            created_by  = "api-test"
            tags        = @{
                "test"       = "true"
                "created_by" = "curl-script"
            }
        }
    } | ConvertTo-Json -Depth 10

    $results += Test-ApiEndpoint -Method "POST" -Url "$BaseUrl/api/v1/resources" -Description "Create Test Resource" -Body $testResource

    return $results
}

function Test-SchemaEndpoints {
    Write-Section "SCHEMA MANAGEMENT ENDPOINTS"

    $results = @()

    # List schemas
    $results += Test-ApiEndpoint -Url "$BaseUrl/api/v1/schemas" -Description "List Schemas"

    # Get specific schema (if available)
    $results += Test-ApiEndpoint -Url "$BaseUrl/api/v1/schemas/aws_instance" -Description "Get AWS Instance Schema"

    return $results
}

function Test-SearchEndpoints {
    Write-Section "SEARCH & DISCOVERY ENDPOINTS"

    $results = @()

    # Semantic search
    $searchQuery = @{
        query   = "EC2 instances in production"
        filters = @{
            provider = "aws"
            type     = "aws_instance"
        }
    } | ConvertTo-Json -Depth 10

    $results += Test-ApiEndpoint -Method "POST" -Url "$BaseUrl/api/v1/search" -Description "Semantic Search" -Body $searchQuery

    # Text search
    $textQuery = @{
        query  = "test instance"
        fields = @("name", "metadata.tags")
    } | ConvertTo-Json -Depth 10

    $results += Test-ApiEndpoint -Method "POST" -Url "$BaseUrl/api/v1/search/text" -Description "Text Search" -Body $textQuery

    return $results
}

function Test-TerraformEndpoints {
    Write-Section "TERRAFORM INTEGRATION ENDPOINTS"

    $results = @()

    # Get terraform coverage
    $results += Test-ApiEndpoint -Url "$BaseUrl/api/v1/terraform/coverage" -Description "Terraform Coverage Analysis"

    # Create siros_key resource
    $sirosKey = @{
        key      = "test.environment.instance-$(Get-Random)"
        path     = "/test/environment"
        data     = @{
            resource_type     = "aws_instance"
            instance_id       = "i-$(Get-Random -Minimum 100000 -Maximum 999999)"
            terraform_managed = $true
        }
        metadata = @{
            deployed_by   = "terraform"
            deployment_id = "test-deployment-$(Get-Random)"
        }
    } | ConvertTo-Json -Depth 10

    $results += Test-ApiEndpoint -Method "POST" -Url "$BaseUrl/api/v1/terraform/siros_key" -Description "Create Siros Key Resource" -Body $sirosKey

    # Query by path
    $pathQuery = @{
        path      = "/test"
        recursive = $true
    } | ConvertTo-Json -Depth 10

    $results += Test-ApiEndpoint -Method "POST" -Url "$BaseUrl/api/v1/terraform/siros_key_path" -Description "Query Resources by Path" -Body $pathQuery

    return $results
}

function Test-MCPEndpoints {
    Write-Section "MODEL CONTEXT PROTOCOL ENDPOINTS"

    $results = @()

    # Initialize MCP
    $mcpInit = @{
        protocolVersion = "2024-11-05"
        capabilities    = @{
            roots    = @{
                listChanged = $true
            }
            sampling = @{}
        }
        clientInfo      = @{
            name    = "siros-api-test"
            version = "1.0.0"
        }
    } | ConvertTo-Json -Depth 10

    $results += Test-ApiEndpoint -Method "POST" -Url "$BaseUrl/api/v1/mcp/initialize" -Description "MCP Initialize" -Body $mcpInit

    # List MCP resources
    $mcpListResources = @{
        method = "resources/list"
        params = @{}
    } | ConvertTo-Json -Depth 10

    $results += Test-ApiEndpoint -Method "POST" -Url "$BaseUrl/api/v1/mcp/resources/list" -Description "MCP List Resources" -Body $mcpListResources

    # List MCP tools
    $mcpListTools = @{
        method = "tools/list"
        params = @{}
    } | ConvertTo-Json -Depth 10

    $results += Test-ApiEndpoint -Method "POST" -Url "$BaseUrl/api/v1/mcp/tools/list" -Description "MCP List Tools" -Body $mcpListTools

    return $results
}

function Test-AuditEndpoints {
    Write-Section "BLOCKCHAIN AUDIT ENDPOINTS"

    $results = @()

    # List changes
    $results += Test-ApiEndpoint -Url "$BaseUrl/api/v1/audit/changes" -Description "List Audit Changes"

    return $results
}

function Test-DiscoveryEndpoints {
    Write-Section "CLOUD DISCOVERY ENDPOINTS"

    $results = @()

    # Scan providers
    $scanRequest = @{
        providers = @("aws")
        regions   = @("us-east-1")
        filters   = @{
            resource_types = @("ec2", "s3")
        }
    } | ConvertTo-Json -Depth 10

    $results += Test-ApiEndpoint -Method "POST" -Url "$BaseUrl/api/v1/discovery/scan" -Description "Cloud Provider Scan" -Body $scanRequest

    return $results
}

# Main execution
function Main {
    Write-ColorOutput @"
🌐 Siros API Testing Script
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Base URL: $BaseUrl
Target Endpoint: $Endpoint
Verbose Mode: $($Verbose ? 'Enabled' : 'Disabled')
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
"@ "Cyan"

    $allResults = @()

    if ($Endpoint -eq "all" -or $Endpoint -eq "health") {
        $allResults += Test-HealthEndpoints
    }

    if ($Endpoint -eq "all" -or $Endpoint -eq "schemas") {
        $allResults += Test-SchemaEndpoints
    }

    if ($Endpoint -eq "all" -or $Endpoint -eq "resources") {
        $allResults += Test-ResourceEndpoints
    }

    if ($Endpoint -eq "all" -or $Endpoint -eq "search") {
        $allResults += Test-SearchEndpoints
    }

    if ($Endpoint -eq "all" -or $Endpoint -eq "terraform") {
        $allResults += Test-TerraformEndpoints
    }

    if ($Endpoint -eq "all" -or $Endpoint -eq "mcp") {
        $allResults += Test-MCPEndpoints
    }

    if ($Endpoint -eq "all" -or $Endpoint -eq "audit") {
        $allResults += Test-AuditEndpoints
    }

    if ($Endpoint -eq "all" -or $Endpoint -eq "discovery") {
        $allResults += Test-DiscoveryEndpoints
    }

    # Summary
    Write-Section "TEST SUMMARY"

    $successCount = ($allResults | Where-Object { $_ -eq $true }).Count
    $totalCount = $allResults.Count
    $failureCount = $totalCount - $successCount

    Write-ColorOutput "Total Tests: $totalCount" "Blue"
    Write-ColorOutput "Successful: $successCount" "Green"
    Write-ColorOutput "Failed: $failureCount" "Red"

    if ($failureCount -eq 0) {
        Write-ColorOutput "🎉 All tests passed!" "Green"
        exit 0
    }
    else {
        Write-ColorOutput "⚠️  Some tests failed. Check output above for details." "Yellow"
        exit 1
    }
}

# Run the main function
Main
