# Siros API Testing Scripts

This document describes the comprehensive API testing scripts created for the Siros multi-cloud resource management platform.

## Scripts Overview

### PowerShell Script (`scripts/curl.ps1`)

Windows-native PowerShell script for comprehensive API testing.

### Bash Script (`scripts/curl.sh`)

Cross-platform bash script for Unix-like systems.

Both scripts provide identical functionality with platform-appropriate implementations.

## Usage

### PowerShell (Windows)

```powershell
# Run all API tests
.\scripts\curl.ps1

# Test specific endpoint group
.\scripts\curl.ps1 -Endpoint health
.\scripts\curl.ps1 -Endpoint resources
.\scripts\curl.ps1 -Endpoint schemas

# Enable verbose output
.\scripts\curl.ps1 -Verbose

# Test against remote server
.\scripts\curl.ps1 -BaseUrl "https://api.siros.dev"

# Combine options
.\scripts\curl.ps1 -Endpoint terraform -Verbose
```

### Bash (Linux/macOS)

```bash
# Run all API tests
./scripts/curl.sh

# Test specific endpoint group
./scripts/curl.sh health
./scripts/curl.sh resources
./scripts/curl.sh schemas

# Enable verbose output
./scripts/curl.sh --verbose

# Test against remote server
./scripts/curl.sh --base-url https://api.siros.dev

# Combine options
./scripts/curl.sh --verbose terraform
```

## Available Endpoint Groups

### 1. Health & System (`health`)

- **Root Health**: `GET /api/v1/health` ✅
- **Detailed Health**: `GET /api/v1/health/check` (route needs implementation)
- **Version Info**: `GET /api/v1/health/version` (route needs implementation)

### 2. Schema Management (`schemas`)

- **List Schemas**: `GET /api/v1/schemas` ✅
- **Get Schema**: `GET /api/v1/schemas/{name}` (needs implementation)

### 3. Resource Management (`resources`)

- **List Resources**: `GET /api/v1/resources` (database connection needed)
- **Create Resource**: `POST /api/v1/resources` (database connection needed)
- **Get Resource**: `GET /api/v1/resources/{id}`
- **Update Resource**: `PUT /api/v1/resources/{id}`
- **Delete Resource**: `DELETE /api/v1/resources/{id}`

### 4. Search & Discovery (`search`)

- **Semantic Search**: `POST /api/v1/search` ✅
- **Text Search**: `POST /api/v1/search/text` ✅
- **Cloud Provider Scan**: `POST /api/v1/discovery/scan` ✅

### 5. Terraform Integration (`terraform`)

- **Coverage Analysis**: `GET /api/v1/terraform/coverage` ✅
- **Create Siros Key**: `POST /api/v1/terraform/siros_key` ✅
- **Query by Path**: `POST /api/v1/terraform/siros_key_path` ✅
- **Get Key**: `GET /api/v1/terraform/siros_key/{key}`
- **Update Key**: `PUT /api/v1/terraform/siros_key/{key}`
- **Delete Key**: `DELETE /api/v1/terraform/siros_key/{key}`

### 6. Model Context Protocol (`mcp`)

- **Initialize**: `POST /api/v1/mcp/initialize` ✅
- **List Resources**: `POST /api/v1/mcp/resources/list` ✅
- **List Tools**: `POST /api/v1/mcp/tools/list` ✅
- **Read Resource**: `POST /api/v1/mcp/resources/read`
- **Call Tool**: `POST /api/v1/mcp/tools/call`
- **List Prompts**: `POST /api/v1/mcp/prompts/list`
- **Get Prompt**: `POST /api/v1/mcp/prompts/get`

### 7. Blockchain Audit (`audit`)

- **List Changes**: `GET /api/v1/audit/changes` (route needs implementation)
- **Get Audit Trail**: `GET /api/v1/audit/trail/{id}`
- **Verify Integrity**: `GET /api/v1/audit/verify/{id}`

### 8. Cloud Discovery (`discovery`)

- **Scan Providers**: `POST /api/v1/discovery/scan` ✅
- **Discover Relationships**: `POST /api/v1/discovery/relationships`

## Test Results Summary

### ✅ Working Endpoints (10/16 tested)

1. **Health Check (Root)** - `GET /api/v1/health`
2. **List Schemas** - `GET /api/v1/schemas`
3. **Semantic Search** - `POST /api/v1/search`
4. **Text Search** - `POST /api/v1/search/text`
5. **Terraform Coverage** - `GET /api/v1/terraform/coverage`
6. **Create Siros Key** - `POST /api/v1/terraform/siros_key`
7. **Query by Path** - `POST /api/v1/terraform/siros_key_path`
8. **MCP Initialize** - `POST /api/v1/mcp/initialize`
9. **MCP List Resources** - `POST /api/v1/mcp/resources/list`
10. **MCP List Tools** - `POST /api/v1/mcp/tools/list`

### ❌ Issues Found (6/16 tested)

1. **Health Check (Detailed)** - Route `/health/check` returns 404
2. **Health Version** - Route `/health/version` returns 404
3. **Get AWS Schema** - Returns 400 Bad Request
4. **List Resources** - Returns 500 Internal Server Error (database issue)
5. **Create Resource** - Returns 500 Internal Server Error (database issue)
6. **List Audit Changes** - Route `/audit/changes` returns 404

## Sample API Responses

### Health Check

```json
{
  "data": {
    "service": "siros-backend",
    "status": "healthy",
    "timestamp": 1760484375,
    "version": "1.0.0"
  },
  "meta": {
    "timestamp": "2025-10-15T01:26:15.9451624+02:00",
    "version": "1.0"
  }
}
```

### List Schemas

```json
{
  "data": {
    "schemas": [
      {
        "created_at": "2024-01-01T00:00:00Z",
        "description": "AWS EC2 Instance schema",
        "name": "aws_instance",
        "provider": "aws",
        "version": "1.0"
      },
      {
        "created_at": "2024-01-01T00:00:00Z",
        "description": "Azure Virtual Machine schema",
        "name": "azure_vm",
        "provider": "azure",
        "version": "1.0"
      }
    ],
    "total": 2
  },
  "meta": {
    "timestamp": "2025-10-15T01:34:01.443026+02:00",
    "version": "1.0"
  }
}
```

### Terraform Coverage Analysis

```json
{
  "data": {
    "analysis_date": "2025-10-15T01:34:32+02:00",
    "coverage_percentage": 75,
    "providers": {
      "aws": {
        "coverage": 83.3,
        "terraform_managed": 50,
        "total": 60
      },
      "azure": {
        "coverage": 62.5,
        "terraform_managed": 25,
        "total": 40
      }
    },
    "terraform_managed": 75,
    "total_resources": 100,
    "unmanaged": 25
  },
  "meta": {
    "timestamp": "2025-10-15T01:34:32.1410052+02:00",
    "version": "1.0"
  }
}
```

### Semantic Search Results

```json
{
  "data": {
    "query": "EC2 instances in production",
    "results": [
      {
        "id": "resource-1",
        "name": "example-ec2",
        "provider": "aws",
        "similarity": 0.95,
        "type": "aws_instance"
      }
    ],
    "total": 1
  },
  "meta": {
    "timestamp": "2025-10-15T01:34:41.7270157+02:00",
    "version": "1.0"
  }
}
```

## Next Steps

### Routes Needing Implementation

1. Fix health subroutes: `/health/check` and `/health/version`
2. Implement schema detail endpoint: `/schemas/{name}`
3. Fix audit routes: `/audit/changes`, `/audit/trail/{id}`, `/audit/verify/{id}`

### Database Integration

1. Fix resource endpoints to properly connect to PostgreSQL
2. Ensure vector operations work with pgvector extension
3. Test resource CRUD operations with real data

### Development Workflow

1. Use `.\scripts\curl.ps1` for quick API testing during development
2. Run specific endpoint groups when working on particular features
3. Enable verbose mode when debugging API responses
4. Use remote base URL for testing deployed instances

## Dependencies

### PowerShell Script

- PowerShell 5.1+ or PowerShell Core 6+
- `Invoke-RestMethod` cmdlet (built-in)
- `ConvertTo-Json` and `ConvertFrom-Json` cmdlets (built-in)

### Bash Script

- `curl` command-line tool
- `jq` for JSON formatting (optional but recommended)
- Bash 4.0+ for associative arrays

## Error Handling

Both scripts provide:

- Color-coded output for success/failure
- Detailed error messages in verbose mode
- Summary statistics
- Non-zero exit codes on failure for CI/CD integration

## Integration with Development Workflow

These scripts integrate with the Siros development environment:

- Work with `dev.ps1` script that starts the backend
- Test against `localhost:8080` by default
- Support custom base URLs for deployed environments
- Provide machine-readable exit codes for automation
