# Siros - Multi-Cloud Resource Platform

🌐 **Siros** (*Greek: σίρος - "silo" or "pit for holding grain"*) is a comprehensive Go-based relational data structure tool designed for storing and serving cloud estate resources as JSON in a hierarchical, vector-based format. Siros provides unified resource management across AWS, Azure, Google Cloud Platform, and Oracle Cloud Infrastructure with advanced features including semantic search, blockchain change tracking, and multiple API interfaces (HTTP, Terraform, and MCP).

## 🎯 Core Philosophy

Siros is fundamentally a **relational data structure platform** that treats every cloud resource as an individual vector while preserving organizational hierarchies and cross-cloud relationships. The platform enables comprehensive cloud estate management where resources can be:

- **Stored as individual vectors** with original CSP (Cloud Service Provider) structure plus enriched metadata
- **Connected through vector queries** to maintain organizational structure and relationships
- **Tracked throughout lifecycle** using immutable blockchain records
- **Managed simultaneously across multiple clouds** with unified visibility
- **Extended with custom schemas** beyond predefined cloud structures
- **Integrated with Terraform** and **AI/LLM systems** through dedicated APIs

## 📂 Repository Structure

```fs
siros/
├── .github/                      # GitHub configuration and templates
│   ├── ISSUE_TEMPLATE/           # Bug reports, feature requests, documentation
│   ├── instructions/             # Platform-specific development guidelines
│   │   ├── go.instructions.md    # Go backend development standards
│   │   ├── typescript.instructions.md  # React/TypeScript frontend standards
│   │   ├── github.instructions.md      # GitHub workflow and CI/CD guidelines
│   │   ├── markdown.instructions.md    # Documentation writing standards
│   │   └── vscode.instructions.md      # VS Code workspace configuration
│   ├── workflows/                # GitHub Actions CI/CD workflows
│   ├── copilot-instructions.md   # GitHub Copilot project context
│   ├── CONTRIBUTING.md           # Contribution guidelines
│   ├── dependabot.yml           # Dependency update automation
│   └── pull_request_template.md  # PR template
│
├── .vscode/                      # VS Code workspace configuration
│   ├── tasks.json               # Task automation (build, test, lint)
│   ├── settings.json            # Editor and language settings
│   ├── mcp.json                 # Model Context Protocol configuration
│   └── extensions.json          # Recommended extensions
│
├── backend/                      # Go backend code
│   ├── cmd/
│   │   └── siros-server/         # Main entry point for API server
│   │       ├── main.go
│   │       └── static/           # Embedded frontend assets location
│   │
│   ├── internal/                 # Non-exported application code
│   │   ├── api/                  # HTTP server and routing
│   │   │   ├── server.go
│   │   │   ├── middleware/       # CORS, auth, logging, request ID
│   │   │   └── routes/           # API route definitions
│   │   ├── controllers/          # HTTP handlers (MVC controllers)
│   │   │   ├── resource.go       # Resource CRUD operations
│   │   │   ├── search.go         # Semantic search operations
│   │   │   ├── terraform.go      # Terraform provider endpoints
│   │   │   ├── mcp.go            # MCP protocol handlers
│   │   │   ├── schema.go         # Schema management
│   │   │   ├── audit.go          # Blockchain audit operations
│   │   │   └── health.go         # Health check endpoint
│   │   ├── models/               # Data structures and business logic
│   │   │   └── resource.go       # Resource model with validation
│   │   ├── services/             # Business logic layer
│   │   │   ├── resource.go       # Resource management business logic
│   │   │   ├── search.go         # Vector search and semantic operations
│   │   │   ├── schema_terraform_mcp.go  # Schema management
│   │   │   ├── simple_resource.go       # Simplified resource operations
│   │   │   └── idgen.go          # ID generation utilities
│   │   ├── repositories/         # Data access layer
│   │   │   ├── resource.go       # Resource database operations
│   │   │   ├── schema.go         # Schema database operations
│   │   │   ├── blockchain.go     # Blockchain storage operations
│   │   │   └── migrate.go        # Database migration utilities
│   │   ├── views/                # Response formatting (MVC views)
│   │   │   └── response.go       # JSON API response formatters
│   │   ├── providers/            # Cloud provider integrations
│   │   │   ├── manager.go        # Provider management
│   │   │   ├── aws.go            # AWS integration
│   │   │   ├── azure.go          # Azure integration
│   │   │   └── gcp.go            # Google Cloud integration
│   │   ├── storage/              # Storage layer connectors
│   │   │   └── storage.go        # PostgreSQL + pgvector integration
│   │   ├── config/               # Configuration management
│   │   │   └── config.go         # Application configuration
│   │   ├── blockchain/           # Blockchain change tracking
│   │   │   └── tracker.go        # Immutable audit trail
│   │   └── terraform/            # Terraform integration
│   │       └── importer.go       # Terraform state import
│   │
│   ├── pkg/                      # Exported packages
│   │   └── types/                # Shared type definitions
│   │
│   ├── static/                   # Built frontend assets (embedded)
│   ├── assets.go                 # Go embed for static assets
│   ├── go.mod
│   └── go.sum
│
├── frontend/                     # React + TypeScript portal
│   ├── src/
│   │   ├── components/           # Reusable UI components
│   │   │   └── Layout.tsx
│   │   ├── pages/                # Views (Dashboard, Resources, Graph, Search)
│   │   │   ├── Dashboard.tsx
│   │   │   ├── ResourcesPage.tsx
│   │   │   ├── SearchPage.tsx
│   │   │   └── GraphView.tsx
│   │   ├── api/                  # Type-safe API client
│   │   │   └── client.ts
│   │   ├── App.tsx
│   │   ├── App.css
│   │   ├── main.tsx
│   │   └── index.css
│   ├── index.html
│   ├── package.json
│   ├── package-lock.json
│   ├── tsconfig.json
│   ├── tsconfig.node.json
│   ├── vite.config.ts
│   └── .eslintrc.cjs
│
├── scripts/                      # Build & deployment scripts
│   ├── build_all.sh             # Build frontend + embed into Go binary
│   ├── build_all.ps1            # Windows production build
│   ├── build.sh                 # Backend-only build
│   ├── build.ps1                # Windows backend build
│   ├── dev.sh                   # Run backend & frontend in dev mode
│   ├── dev.ps1                  # Windows development mode
│   ├── test.sh                  # Comprehensive test runner
│   ├── test.ps1                 # Windows test runner
│   ├── lint.sh                  # Code linting (Go + TypeScript)
│   ├── lint.ps1                 # Windows code linting
│   ├── generate-callgraph.sh    # Generate code call graphs
│   ├── generate-callgraph.ps1   # Windows call graph generation
│   ├── clean-callgraph.sh       # Clean generated call graphs
│   ├── clean-callgraph.ps1      # Windows call graph cleanup
│   └── init.sql                 # PostgreSQL database initialization
│
├── docs/                         # Project documentation
│   ├── callgraph/               # Generated call graph visualizations
│   │   ├── *.gv                 # Graphviz source files
│   │   └── *.svg                # SVG visualizations
│   ├── CALL_GRAPH.md            # Call graph documentation
│   ├── CALL_GRAPH_STATUS.md     # Call graph generation status
│   ├── MVC_IMPLEMENTATION_SUMMARY.md  # MVC architecture overview
│   ├── SCRIPTS.md               # Build scripts documentation
│   └── SCRIPTS_IMPLEMENTATION_SUMMARY.md  # Scripts implementation details
│
├── build/                        # Build artifacts
│   └── siros.exe                # Compiled binary (Windows)
│
├── config.yaml                   # Default configuration
├── docker-compose.yml           # Docker development environment
├── Dockerfile                   # Container image definition
├── Makefile                     # Alternative build commands
├── .golangci.yml                # Go linting configuration
├── siros.code-workspace         # VS Code workspace file
├── LICENSE
├── CODE_OF_CONDUCT.md
├── README.md
└── .gitignore
```

## ✨ Core Features

### 🏗️ Vector-Based Resource Architecture

- **Individual Resource Vectors**: Each cloud resource stored as a separate vector preserving original CSP structure
- **Enriched Metadata**: Original resource data enhanced with `parent_id`, `created`, `created_by`, `modified`, `modified_by`, IAM information, and custom attributes
- **Hierarchical Relationships**: Organizational structure maintained through vector queries rather than rigid schemas
- **Cross-Cloud Connections**: Automatic detection and mapping of relationships like VPN tunnels, networking, and shared resources (e.g., Oracle@Azure)

### 🌐 Multi-Cloud Estate Management

- **AWS Integration**: Complete support for all AWS services with automatic resource discovery
- **Azure Integration**: Full Azure Resource Manager integration including specialized services
- **Google Cloud Platform**: Comprehensive GCP resource management and discovery
- **Oracle Cloud Infrastructure**: Native OCI support for hybrid and multi-cloud deployments
- **Unified View**: Single interface showing resources across all cloud providers with relationship mapping

### 🗄️ Advanced Data Storage & Retrieval

- **PostgreSQL + pgvector**: Enterprise-grade vector database for semantic resource operations
- **Custom Schema Support**: Beyond predefined cloud schemas - store any data structure as vectors
- **Incomplete Structure Tolerance**: Store and retrieve data even when complete organizational structure is unavailable
- **Resource Deduplication**: Identify and connect (without merging) duplicate resources across deployment methods
- **Semantic Search**: Natural language queries across entire cloud estate

### 🔗 Multiple API Interfaces

- **HTTP REST API**: Full CRUD operations for direct resource management
- **Terraform Provider Integration**: Dedicated `siros_key` and `siros_key_path` resources/data sources for IaC workflows
- **Model Context Protocol (MCP)**: AI/LLM integration for intelligent resource discovery and analysis
- **Web Portal**: Modern React frontend for visualization and interactive management

### ⛓️ Blockchain Change Tracking

- **Immutable Audit Trail**: Every resource change recorded in blockchain for complete lifecycle tracking
- **Resource Lifecycle Management**: Track resources through creation, modification, deletion, and recreation cycles
- **Compliance & Governance**: Built-in audit capabilities for regulatory compliance
- **Change Attribution**: Full traceability of who changed what and when

### 🔍 Platform Engineering Insights

- **Resource Coverage Analysis**: Identify gaps between managed (Terraform) and discovered (cloud scan) resources
- **Estate Visibility**: Comprehensive view showing managed vs. unmanaged resources across your cloud estate
- **Tooling Foundation**: Rich dataset enabling vast ecosystem of custom tooling and automation
- **Deployment Tracking**: Automatic correlation between Terraform deployments and actual cloud resources

## 🎯 Use Cases & Scenarios

### Infrastructure Discovery & Management

```txt
Scenario: You have 20,000 resources across AWS, Azure, and GCP
- 14,000 managed through Terraform
- 6,000 created outside your Platform Engineering ecosystem

Result: Siros identifies the gap, connects resources without merging,
providing clear visibility into managed vs. unmanaged infrastructure
```

### Multi-Cloud Relationship Mapping

```txt
Scenario: Complex networking across clouds
- VPN tunnels between AWS and Azure
- Oracle@Azure shared resources
- Cross-cloud database connections

Result: Vector queries automatically discover and visualize these
relationships in the web portal
```

### Compliance & Audit

```txt
Scenario: Regulatory requirement for complete audit trail
- Every resource change must be tracked
- Historical state reconstruction needed
- Change attribution required

Result: Blockchain-based change tracking provides immutable audit
trail with complete lifecycle visibility
```

### AI-Powered Infrastructure Analysis

```txt
Scenario: Need intelligent infrastructure insights
- Natural language queries about resource relationships
- Automated policy compliance checking
- Predictive analysis for capacity planning

Result: MCP API enables AI/LLM integration for intelligent
infrastructure management and analysis
```

## �️ Architecture & Integration

### Terraform Provider Integration

Siros integrates seamlessly with Infrastructure as Code workflows through a dedicated Terraform provider (developed separately):

```hcl
# Store resource metadata in Siros during deployment
resource "siros_key" "web_server" {
  key   = "production.web.server-001"
  path  = "/infrastructure/production/web"
  data  = {
    resource_type = "aws_instance"
    instance_id   = aws_instance.web.id
    environment   = "production"
    team          = "platform"
  }
  metadata = {
    deployed_by    = "terraform"
    deployment_id  = var.deployment_id
    cost_center    = "engineering"
  }
}

# Retrieve resource information from Siros
data "siros_key_path" "production_web" {
  path = "/infrastructure/production/web"
}
```

### External Cloud Scanning Workflow

1. **Terraform Deployment**: Resources created with `siros_key` resources storing metadata
2. **External Cloud Scan**: HTTP API used to discover and store all cloud resources
3. **Resource Correlation**: Automatic identification of managed vs. unmanaged resources
4. **Gap Analysis**: Clear visibility into Platform Engineering coverage

### MCP Server Integration

Dedicated MCP server (separate repository) provides AI/LLM capabilities:

- **Natural Language Queries**: "Show me all production databases in AWS with high CPU usage"
- **Resource Discovery**: AI-powered exploration of cloud estate relationships
- **Policy Compliance**: Automated checking against organizational policies
- **Predictive Analysis**: Capacity planning and cost optimization insights

## 🏛️ MVC Architecture Standards

Siros follows the Model-View-Controller (MVC) architectural pattern to ensure clean separation of concerns, maintainable code, and scalable development across both backend and frontend components.

### 🎯 MVC Design Principles

#### Backend (Go) MVC Structure

```fs
backend/
├── internal/
│   ├── controllers/          # Controllers - Handle HTTP requests, orchestrate business logic
│   │   ├── resource.go       # Resource CRUD operations
│   │   ├── search.go         # Semantic search operations
│   │   ├── terraform.go      # Terraform provider endpoints
│   │   └── mcp.go           # MCP protocol handlers
│   │
│   ├── models/              # Models - Data structures and business logic
│   │   ├── resource.go      # Resource model with validation and business rules
│   │   ├── provider.go      # Cloud provider abstractions
│   │   ├── blockchain.go    # Blockchain record models
│   │   └── schema.go        # Custom schema definitions
│   │
│   ├── views/               # Views - Response formatting and data presentation
│   │   ├── json.go          # JSON API response formatters
│   │   ├── terraform.go     # Terraform provider response formats
│   │   └── mcp.go          # MCP protocol response handlers
│   │
│   ├── services/            # Business Logic Layer
│   │   ├── resource.go      # Resource management business logic
│   │   ├── discovery.go     # Cloud resource discovery service
│   │   ├── vector.go        # Vector operations and similarity search
│   │   └── audit.go         # Blockchain audit service
│   │
│   └── repositories/        # Data Access Layer
│       ├── resource.go      # Resource database operations
│       ├── vector.go        # Vector database operations
│       └── blockchain.go    # Blockchain storage operations
```

#### Frontend (React) MVC Structure

```
frontend/src/
├── components/              # Views - UI Components and presentation logic
│   ├── common/             # Reusable UI components
│   ├── resource/           # Resource-specific components
│   ├── search/             # Search interface components
│   └── layout/             # Layout and navigation components
│
├── controllers/            # Controllers - Application logic and state management
│   ├── resourceController.ts    # Resource management logic
│   ├── searchController.ts      # Search functionality
│   └── navigationController.ts  # Navigation and routing logic
│
├── models/                 # Models - Data structures and API interfaces
│   ├── resource.ts         # Resource model and TypeScript interfaces
│   ├── search.ts           # Search models and filters
│   ├── api.ts              # API response models
│   └── validation.ts       # Client-side validation models
│
├── services/               # API Communication Layer
│   ├── apiClient.ts        # HTTP client for API communication
│   ├── resourceService.ts  # Resource-specific API calls
│   └── searchService.ts    # Search API integration
│
└── stores/                 # State Management (if using Context/Redux)
    ├── resourceStore.ts    # Resource state management
    └── appStore.ts         # Global application state
```

### 📋 MVC Implementation Standards

#### Controller Layer Standards

- **Single Responsibility**: Each controller handles one specific domain (resources, search, etc.)
- **Thin Controllers**: Controllers orchestrate but don't contain business logic
- **Dependency Injection**: Use interfaces for testability and modularity
- **Error Handling**: Consistent error handling and HTTP status codes
- **Validation**: Input validation before passing to business logic

#### Model Layer Standards

- **Data Integrity**: Models enforce business rules and data validation
- **Immutable Operations**: Use blockchain tracking for audit trails
- **Vector Operations**: Encapsulate vector database operations within models
- **Provider Abstraction**: Abstract cloud provider differences in model layer
- **Custom Schemas**: Support extensible schema definitions

#### View Layer Standards

- **Response Formatting**: Consistent JSON API response structures
- **Data Presentation**: Transform internal models to API-appropriate formats
- **Content Negotiation**: Support multiple response formats (JSON, Terraform HCL)
- **Security**: Sanitize sensitive data in responses
- **Pagination**: Implement consistent pagination for list endpoints

### 🔧 Dependency Injection Pattern

```go
// Example: Resource Controller with Dependency Injection
type ResourceController struct {
    resourceService  services.ResourceService
    vectorService    services.VectorService
    auditService     services.AuditService
    logger          *log.Logger
}

func NewResourceController(
    resourceSvc services.ResourceService,
    vectorSvc services.VectorService,
    auditSvc services.AuditService,
    logger *log.Logger,
) *ResourceController {
    return &ResourceController{
        resourceService: resourceSvc,
        vectorService:   vectorSvc,
        auditService:    auditSvc,
        logger:         logger,
    }
}
```

### 🧪 Testing Standards for MVC

#### Unit Testing

- **Controllers**: Test HTTP handling, validation, and orchestration
- **Models**: Test business logic, validation rules, and data transformations
- **Services**: Test business logic in isolation with mocked dependencies
- **Views**: Test response formatting and data presentation

#### Integration Testing

- **API Endpoints**: Test complete request/response cycles
- **Database Operations**: Test data persistence and retrieval
- **Multi-Cloud Integration**: Test provider-specific implementations

#### Frontend Testing

- **Component Testing**: Test React components in isolation
- **Controller Testing**: Test application logic and state management
- **Service Testing**: Test API integration with mock backends

## 🚀 Quick Start

### Prerequisites

- Go 1.24 or higher
- Node.js 18+ and npm
- PostgreSQL 15+ with pgvector extension
- Docker (optional, for database)

### Development Setup

1. **Clone the repository**

   ```bash
   git clone https://github.com/LederWorks/siros.git
   cd siros
   ```

2. **Set up PostgreSQL with pgvector**

   ```bash
   # Using Docker (recommended for development)
   docker run --name siros-postgres \
     -e POSTGRES_PASSWORD=siros \
     -e POSTGRES_USER=siros \
     -e POSTGRES_DB=siros \
     -p 5432:5432 -d postgres:15-alpine

   # Enable pgvector extension
   docker exec siros-postgres psql -U siros -d siros -c "CREATE EXTENSION IF NOT EXISTS vector;"
   ```

3. **Configure cloud providers**

   ```bash
   cp config.yaml config.local.yaml
   # Edit config.local.yaml with your cloud credentials
   ```

4. **Development mode (hot reload)**

   #### Linux/macOS

   ```bash
   # Starts both backend (:8080) and frontend dev server (:5173)
   ./scripts/dev.sh
   ```

   #### Windows

   ```powershell
   # Starts both backend (:8080) and frontend dev server (:5173)
   .\scripts\dev.ps1
   ```

5. **Production build**

   #### Linux/macOS

   ```bash
   # Builds frontend and embeds it in Go binary
   ./scripts/build_all.sh

   # Run the single binary
   cd backend
   ./siros-server -config ../config.local.yaml
   ```

   #### Windows

   ```powershell
   # Builds frontend and embeds it in Go binary
   .\scripts\build_all.ps1

   # Run the single binary
   cd backend
   .\siros-server.exe -config ..\config.local.yaml
   ```

6. **Testing**

   #### Linux/macOS

   ```bash
   # Run all tests
   ./scripts/test.sh

   # Run specific test suite with coverage
   ./scripts/test.sh --suite models --coverage
   ```

   #### Windows

   ```powershell
   # Run all tests
   .\scripts\test.ps1

   # Run specific test suite with coverage
   .\scripts\test.ps1 -TestSuite models -Coverage
   ```

### Access Points

- **Frontend (Dev)**: <http://localhost:5173> (with Vite dev server)
- **Frontend (Prod)**: <http://localhost:8080> (embedded in Go binary)
- **API**: <http://localhost:8080/api/v1/>
- **Health Check**: <http://localhost:8080/api/v1/health>

## 🏗️ Development Workflow

### Cross-Platform Development

#### Frontend Development

```bash
cd frontend
npm install           # Install dependencies
npm run dev          # Start dev server with hot reload
npm run build        # Build for production
npm run lint         # Run ESLint
```

#### Backend Development

```bash
cd backend
go mod tidy          # Update dependencies
go run ./cmd/siros-server  # Run server
go test ./...        # Run tests
go build -o siros-server ./cmd/siros-server  # Build binary
```

#### Full Stack Development

**Linux/macOS:**

```bash
# Development with hot reload for both frontend and backend
./scripts/dev.sh

# Production build (frontend embedded in Go binary)
./scripts/build_all.sh

# Run comprehensive test suite
./scripts/test.sh

# Run specific test suite with coverage
./scripts/test.sh --suite models --coverage
```

**Windows (PowerShell):**

```powershell
# Development with hot reload for both frontend and backend
.\scripts\dev.ps1

# Production build (frontend embedded in Go binary)
.\scripts\build_all.ps1

# Run comprehensive test suite
.\scripts\test.ps1

# Run specific test suite with coverage
.\scripts\test.ps1 -TestSuite models -Coverage
```

#### Test Suites Available

- **all**: Complete test suite (default)
- **models**: Business logic and validation tests
- **services**: Business logic orchestration tests
- **controllers**: HTTP handler and API tests
- **repositories**: Data access layer tests
- **integration**: End-to-end tests

### Binary Outputs

The build scripts generate platform-specific binaries:

- **Linux/macOS**: `backend/siros-server` (executable)
- **Windows**: `backend/siros-server.exe` (executable)

All binaries include the embedded React frontend for single-file deployment.

## 📋 API Examples

### REST API

```bash
# Health check
curl http://localhost:8080/api/v1/health

# List resources
curl http://localhost:8080/api/v1/resources

# Search with semantic query
curl -X POST http://localhost:8080/api/v1/search \
  -H "Content-Type: application/json" \
  -d '{"query": "web servers in production", "filters": {"provider": "aws"}}'

# Create custom resource
curl -X POST http://localhost:8080/api/v1/resources \
  -H "Content-Type: application/json" \
  -d '{
    "id": "my-app-server-1",
    "type": "custom.application",
    "provider": "aws",
    "name": "Production Web Server",
    "tags": {"environment": "production", "team": "platform"}
  }'
```

### MCP Integration

```bash
# Initialize MCP session
curl -X POST http://localhost:8080/api/v1/mcp/initialize

# List resources for AI/LLM
curl -X POST http://localhost:8080/api/v1/mcp/resources/list

# Read resource content
curl -X POST http://localhost:8080/api/v1/mcp/resources/read \
  -H "Content-Type: application/json" \
  -d '{"uri": "resource://siros/my-app-server-1"}'
```

## 🐳 Docker Deployment

### Full Stack with Docker Compose

```bash
# Run PostgreSQL + Siros
docker-compose up -d

# Stop services
docker-compose down
```

### Custom Docker Build

```bash
# Build custom image
docker build -t siros .

# Run container
docker run -p 8080:8080 siros
```

## �� Configuration

Create a `config.yaml` file or use environment variables:

```yaml
server:
  host: "0.0.0.0"
  port: 8080

database:
  driver: "postgres"
  host: "localhost"
  port: 5432
  database: "siros"
  username: "siros"
  password: "siros"

providers:
  aws:
    region: "us-east-1"
    # Credentials via AWS CLI or environment variables

  azure:
    tenant_id: "${AZURE_TENANT_ID}"
    client_id: "${AZURE_CLIENT_ID}"
    subscription_id: "${AZURE_SUBSCRIPTION_ID}"

  gcp:
    project_id: "${GCP_PROJECT_ID}"
    region: "us-central1"
```

### Environment Variables

- `SIROS_DB_PASSWORD`: Database password
- `AWS_REGION`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`: AWS credentials
- `AZURE_TENANT_ID`, `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`: Azure credentials
- `GCP_PROJECT_ID`: Google Cloud project ID

## 🎯 Frontend Features

The React frontend provides:

- **📊 Dashboard**: System status, quick stats, and feature overview
- **📦 Resources**: Browse and filter multi-cloud resources
- **🔍 Search**: Semantic search with natural language queries
- **🔗 Graph View**: Interactive resource relationship visualization (coming soon)

### Frontend Tech Stack

- **React 18** with TypeScript
- **Vite** for fast development and building
- **React Router** for navigation
- **D3.js** & **Cytoscape.js** for visualizations (planned)
- **CSS-in-JS** for styling

---

**Siros** - Unify your multi-cloud infrastructure with intelligent resource management. 🌐✨

## 📚 Etymology

**Siros** (Greek: σίρος) means "silo" or "pit for holding grain" - reflecting the platform's purpose as a comprehensive storage system for cloud infrastructure data. Just as ancient silos preserved and organized grain for communities, Siros preserves and organizes cloud resources for modern platform engineering teams, providing a centralized repository where infrastructure data can be stored, retrieved, and analyzed across multiple cloud providers and organizational boundaries.
