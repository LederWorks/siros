# GitHub Copilot Instructions| [🛠️ Scripts Instructions](instructions/scripts.instructions.md) | `scripts/**/*.ps1`, `scripts/**/*.sh`, `scripts/**/*.sql` | Script development standards, cross-platform compatibility, parameter conventions, output formatting, testing practices |

| [📜 PowerShell Instructions](instructions/powershell.instructions.md) | `scripts/**/*.ps1` | PowerShell-specific standards, [CmdletBinding()] patterns, Windows development, PowerShell 5.1+ compatibility |
| [🐚 Bash Instructions](instructions/bash.instructions.md) | `scripts/**/*.sh` | Bash-specific standards, POSIX compliance, Unix/Linux development, cross-shell compatibility |for Siros

## 🏗️ Project Overview

**Siros** (_Greek: σίρος - "silo" or "pit for holding grain"_) is a Go-based relational data structure tool designed for storing and serving cloud estate resources as JSON in a hierarchical, vector-based format. The platform provides unified resource management across AWS, Azure, Google Cloud Platform, and Oracle Cloud Infrastructure with advanced features including semantic search, blockchain change tracking, and multiple API interfaces (HTTP, Terraform, and MCP).

### Core Architecture Philosophy

Siros treats every cloud resource as an **individual vector** while preserving organizational hierarchies and cross-cloud relationships. Key architectural principles:

- **Vector-Based Storage**: Each resource stored as separate vector with original CSP structure + enriched metadata
- **Relationship Discovery**: Organizational structure maintained through vector queries, not rigid schemas
- **Multi-Cloud Native**: Simultaneous management across AWS, Azure, GCP, and OCI
- **Extensible Schemas**: Support for custom schemas beyond predefined cloud structures
- **Immutable Audit**: Blockchain-based change tracking for complete lifecycle visibility
- **AI Integration**: MCP server integration for intelligent resource discovery and analysis

## 📚 Instruction Files Reference

This project uses modular instruction files for platform-specific development guidelines. Each file contains targeted guidance for specific components or technologies:

### Instruction Standards

The Siros project follows a **hierarchical documentation architecture** designed for AI agent navigation and comprehensive development guidance:

```
AGENTS.md (root)                     ← Master tracking & component coordination
├── .github/copilot-instructions.md  ← GitHub Copilot project context (this file)
├── .github/instructions/*.md        ← Technology-specific development standards
└── */AGENTS.md                      ← Component-specific tracking documents
```

#### Documentation Hierarchy Purpose

- **[Root AGENTS.md](../AGENTS.md)**: Master project tracking, component status overview, cross-component coordination
- **copilot-instructions.md** (this file): GitHub Copilot context and instruction file navigation
- **\*.instructions.md**: Technology-specific development standards and implementation patterns
- **Component AGENTS.md**: Detailed tracking for subsystems (backend, frontend, scripts, infrastructure, docs)

#### AI Agent Navigation Pattern

1. **Start Here**: copilot-instructions.md provides project context and instruction file overview
2. **Technology Guidance**: Use appropriate \*.instructions.md for specific development tasks
3. **Component Tracking**: Reference relevant component AGENTS.md for detailed status and roadmaps
4. **Cross-Reference**: AGENTS.md files and instruction files cross-reference for comprehensive guidance

### Core Instruction Files

| File                                                                  | Scope                                                      | Description                                                                                                               |
| --------------------------------------------------------------------- | ---------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| [📝 Markdown Instructions](instructions/markdown.instructions.md)     | `*.md`, `*.markdown`                                       | Markdown writing standards, formatting guidelines, and documentation quality assurance                                    |
| [🔧 Go Instructions](instructions/go.instructions.md)                 | `backend/**/*.go`, `**/*_test.go`                          | Go development guidelines, MVC architecture, API development, database integration, testing standards                     |
| [⚛️ TypeScript Instructions](instructions/typescript.instructions.md) | `frontend/**/*.ts`, `frontend/**/*.tsx`                    | React/TypeScript development, component architecture, state management, API integration, accessibility                    |
| [🔄 GitHub Instructions](instructions/github.instructions.md)         | `.github/**/*.yml`, `.github/**/*.yaml`, `.github/**/*.md` | GitHub Actions workflows, repository configuration, issue templates, security practices                                   |
| [�️ Scripts Instructions](instructions/scripts.instructions.md)       | `scripts/**/*.ps1`, `scripts/**/*.sh`, `scripts/**/*.sql`  | Script development standards, cross-platform compatibility, parameter conventions, output formatting, testing practices   |
| [�💻 VSCode Instructions](instructions/vscode.instructions.md)        | `.vscode/**/*`                                             | VS Code workspace configuration, task automation, debugging, extension recommendations, development workflow optimization |

### AGENTS.md Files

The project includes component-specific AGENTS.md files for detailed development tracking:

| File                                                       | Component        | Description                                                                             |
| ---------------------------------------------------------- | ---------------- | --------------------------------------------------------------------------------------- |
| [📊 Root AGENTS.md](../AGENTS.md)                          | Project Overview | Master tracking, component coordination, cross-component issues, development priorities |
| [🔧 Backend AGENTS.md](../backend/AGENTS.md)               | Go Backend       | MVC implementation, API development, database integration, multi-cloud providers        |
| [⚛️ Frontend AGENTS.md](../frontend/AGENTS.md)             | React/TypeScript | UI components, dashboard, API integration, responsive design                            |
| [🛠️ Scripts AGENTS.md](../scripts/AGENTS.md)               | Build Automation | Cross-platform scripts, testing orchestration, development workflows                    |
| [🐳 Infrastructure AGENTS.md](../infrastructure/AGENTS.md) | Deployment       | Docker, database, CI/CD, production deployment                                          |
| [📚 Documentation AGENTS.md](../docs/AGENTS.md)            | Documentation    | API docs, guides, architecture specs, user documentation                                |

**AGENTS.md Schema**: Each component AGENTS.md follows a standardized 8-section structure:

- **📋 Documentation References**: Hierarchical documentation structure and cross-references
- **📁 Repository Inventory** (or **Scripts Inventory** for scripts): File/folder tracking with implementation status
- **🏗️ Architecture Overview**: Component architecture and design principles
- **📚 Component Status Overview**: Detailed implementation tracking and cross-component coordination
- **🎯 Cross-Component Coordination**: Interdependencies and coordination requirements with other components
- **🔄 Feature Roadmap**: Development priorities, phases, and long-term vision
- **📝 Standards Compliance**: Code quality, testing, and documentation standards adherence
- **🐛 Known Issues & Workarounds**: Current limitations, technical debt, and solutions
- **📚 Related Documentation**: Cross-references to instruction files and other documentation
- **🤝 Contributing**: Component-specific development guidance and workflow

### When to Use Each Instruction File

- **Markdown Instructions**: When creating or editing documentation, README files, or any markdown content
- **Go Backend Instructions**: When working on backend services, APIs, database operations, or server-side business logic
- **TypeScript Frontend Instructions**: When developing UI components, frontend application logic, or client-side integrations
- **GitHub Workflow Instructions**: When setting up CI/CD pipelines, configuring repository settings, or managing collaborative workflows
- **Scripts Instructions**: When creating or modifying build scripts, development automation, cross-platform scripts, or deployment automation
- **PowerShell Instructions**: When developing PowerShell scripts specifically, working with Windows-specific features, or dealing with [CmdletBinding()] patterns
- **Bash Instructions**: When developing Bash scripts specifically, working with Unix/Linux environments, or ensuring POSIX compliance
- **VS Code Instructions**: When configuring development environment, setting up debugging, managing tasks, or optimizing workspace settings

### Cross-Reference Guidelines

These instruction files work together to provide comprehensive development guidance:

1. **Documentation Standards**: All technical writing should follow the markdown instructions
2. **Full-Stack Development**: Backend and frontend instructions complement each other for complete application development
3. **DevOps Integration**: GitHub workflow instructions support the development processes defined in platform-specific files
4. **Scripts & Automation**: Scripts instructions provide standards for build automation, development workflows, and cross-platform compatibility
5. **Development Environment**: VS Code instructions provide workspace optimization and task automation for efficient development
6. **Quality Assurance**: Each instruction file includes testing and quality standards appropriate to its domain

## 📂 Repository Structure

```
siros/
├── .github/                      # GitHub configuration and workflows
│   ├── ISSUE_TEMPLATE/           # Bug reports, feature requests, documentation
│   ├── instructions/             # Platform-specific development guidelines
│   │   ├── go.instructions.md    # Go backend development standards
│   │   ├── typescript.instructions.md  # React/TypeScript frontend standards
│   │   ├── github.instructions.md      # GitHub workflow and CI/CD guidelines
│   │   ├── markdown.instructions.md    # Documentation writing standards
│   │   ├── scripts.instructions.md     # Script development and automation standards
│   │   ├── powershell.instructions.md  # PowerShell-specific development standards
│   │   ├── bash.instructions.md        # Bash-specific development standards
│   │   └── vscode.instructions.md      # VS Code workspace configuration
│   ├── workflows/                # GitHub Actions CI/CD workflows
│   ├── copilot-instructions.md   # GitHub Copilot project context
│   ├── CONTRIBUTING.md           # Contribution guidelines
│   └── dependabot.yml           # Dependency update automation
│
├── .vscode/                      # VS Code workspace configuration
│   ├── tasks.json               # Task automation (build, test, lint)
│   ├── settings.json            # Editor and language settings
│   ├── mcp.json                 # Model Context Protocol configuration
│   └── extensions.json          # Recommended extensions
│
├── backend/                      # Go backend code
│   ├── cmd/siros-server/         # Main entry point
│   ├── internal/                 # Non-exported application code
│   │   ├── api/                  # API layer (HTTP/Terraform/MCP)
│   │   │   ├── server.go         # HTTP server setup
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
│   │   ├── providers/            # Cloud provider integrations (AWS/Azure/GCP/OCI)
│   │   │   ├── manager.go        # Provider management
│   │   │   ├── aws.go            # AWS integration
│   │   │   ├── azure.go          # Azure integration
│   │   │   └── gcp.go            # Google Cloud integration
│   │   ├── storage/              # Storage layer (PostgreSQL + pgvector)
│   │   │   └── storage.go        # Database connection and operations
│   │   ├── config/               # Configuration management
│   │   │   └── config.go         # Application configuration
│   │   ├── blockchain/           # Blockchain change tracking
│   │   │   └── tracker.go        # Immutable audit trail
│   │   └── terraform/            # Terraform integration & state import
│   │       └── importer.go       # Terraform state import
│   ├── pkg/types/                # Shared type definitions
│   ├── static/                   # Built frontend assets (embedded)
│   └── assets.go                 # Go embed for static assets
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
│   ├── package.json
│   ├── tsconfig.json
│   ├── vite.config.ts
│   └── .eslintrc.cjs
│
├── scripts/                      # Build & deployment scripts
│   ├── build_all.sh             # Production build (orchestrates frontend + backend)
│   ├── build_all.ps1            # Windows production build orchestration
│   ├── build_backend.sh         # Backend-only build with embedded assets
│   ├── build_backend.ps1        # Windows backend build
│   ├── build_frontend.sh        # Frontend-only build (React/TypeScript)
│   ├── build_frontend.ps1       # Windows frontend build
│   ├── dev.sh                   # Development mode (hot reload)
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
│   ├── CALL_GRAPH.md            # Call graph documentation
│   ├── MVC_IMPLEMENTATION_SUMMARY.md  # MVC architecture overview
│   ├── SCRIPTS.md               # Build scripts documentation
│   └── SCRIPTS_IMPLEMENTATION_SUMMARY.md  # Scripts implementation details
│
└── build/                        # Build artifacts
    ├── siros.exe                 # Compiled binary (Windows)
    └── ...                       # Platform-specific binaries
```

## 🎯 Platform Engineering Context

### Resource Management Philosophy

Siros is designed to solve real-world Platform Engineering challenges:

**Multi-Cloud Estate Visibility**: Manage resources across AWS, Azure, GCP, and OCI simultaneously
**Resource Coverage Analysis**: Identify gaps between Terraform-managed and manually created resources
**Cross-Cloud Relationships**: Automatically discover VPN tunnels, networking, shared resources (Oracle@Azure)
**Custom Schema Support**: Store any data structure as vectors, not limited to cloud resources
**Immutable Audit Trail**: Blockchain-based tracking for compliance and governance

### Example Scenario

Organization has 20,000 resources across 3 clouds:

- 14,000 managed through Terraform (stored via siros_key resources)
- 6,000 discovered through cloud scanning (stored via HTTP API)

Siros identifies this gap, connects but doesn't merge resources,
providing Platform Engineering teams clear visibility into
managed vs. unmanaged infrastructure.

## 🎯 Development Guidelines

For detailed platform-specific coding guidelines, please refer to the appropriate instruction files:

- **Backend Development**: See [Go Backend Instructions](instructions/go.instructions.md) for MVC architecture, database integration, API development, and testing standards
- **Frontend Development**: See [TypeScript Frontend Instructions](instructions/typescript.instructions.md) for React patterns, component architecture, and state management
- **Documentation**: See [Markdown Instructions](instructions/markdown.instructions.md) for writing standards and formatting guidelines
- **CI/CD & Repository Management**: See [GitHub Workflow Instructions](instructions/github.instructions.md) for workflow automation and collaboration processes
- **Scripts & Automation**: See [Scripts Instructions](instructions/scripts.instructions.md) for build automation, development workflows, and cross-platform script development

### General Development Principles

- **MVC Architecture**: Follow Model-View-Controller pattern for clean separation of concerns
- **Monorepo Structure**: Maintain clean separation between backend and frontend
- **Vector-First Architecture**: Every resource is an individual vector with enriched metadata
- **Type Safety**: Use TypeScript for frontend and Go's strong typing for backend
- **API-First Design**: Design APIs that can be consumed by multiple clients (HTTP, Terraform, MCP)
- **Multi-Cloud Native**: Support simultaneous operations across AWS, Azure, GCP, and OCI
- **Production Ready**: Write code that's ready for production deployment
- **Blockchain Integration**: All changes must be trackable through immutable audit trail
- **Dependency Injection**: Use interfaces and DI for testability and modularity

## 🔧 Development Workflow

For detailed script development guidelines including cross-platform compatibility, parameter standards, and automation best practices, see [Scripts Instructions](instructions/scripts.instructions.md).

### Cross-Platform Development Commands

Siros provides comprehensive build automation through modular scripts that work across Windows, Linux, and macOS:

#### Linux/macOS (Bash)

```bash
# Start development environment (both backend and frontend)
./scripts/dev.sh

# Build production version (orchestrated frontend + backend)
./scripts/build_all.sh

# Build individual components
./scripts/build_frontend.sh    # Frontend only
./scripts/build_backend.sh     # Backend only

# Run comprehensive test suite
./scripts/test.sh

# Run specific test suite with coverage
./scripts/test.sh --suite models --coverage

# Backend development only
cd backend && go run ./cmd/siros-server

# Frontend development only
cd frontend && npm run dev
```

#### Windows (PowerShell)

```powershell
# Start development environment (both backend and frontend)
.\scripts\dev.ps1

# Build production version (orchestrated frontend + backend)
.\scripts\build_all.ps1

# Build individual components
.\scripts\build_frontend.ps1    # Frontend only
.\scripts\build_backend.ps1     # Backend only

# Run comprehensive test suite
.\scripts\test.ps1

# Run specific test suite with coverage
.\scripts\test.ps1 -TestSuite models -Coverage

# Backend development only
cd backend; go run ./cmd/siros-server

# Frontend development only
cd frontend; npm run dev
```

### Script Development Standards

All scripts in the Siros project follow comprehensive standards for cross-platform compatibility, consistent parameter interfaces, and maintainable automation. For detailed guidelines on:

- **Cross-Platform Pairs**: PowerShell (.ps1) and Bash (.sh) implementations
- **Parameter Standards**: Consistent -Verbose, -SkipInstall, -Config, -Help parameters
- **Output Formatting**: Color-coded status messages and error handling
- **Dependency Management**: Automatic tool installation and update patterns
- **Testing Requirements**: Script validation and cross-platform testing

See [Scripts Instructions](instructions/scripts.instructions.md) for complete development guidelines.

### Testing Guidelines

- Write **unit tests** for all business logic
- Create **integration tests** for API endpoints
- Use **test fixtures** for consistent test data
- Mock **external dependencies** (cloud providers, databases)
- Utilize **comprehensive test suites** for different layers (models, services, controllers, repositories)
- Generate **coverage reports** to track test effectiveness
- Support **cross-platform testing** on Windows, Linux, and macOS

#### Test Suite Organization

- **models**: Business logic and validation tests
- **services**: Business logic orchestration tests
- **controllers**: HTTP handler and API tests
- **repositories**: Data access layer tests
- **integration**: End-to-end tests with real dependencies
- **all**: Complete test suite (default)

## 🌐 Multi-Cloud Integration

### Provider Pattern

```go
type CloudProvider interface {
    ListResources(ctx context.Context, filters ResourceFilters) ([]Resource, error)
    GetResource(ctx context.Context, id string) (*Resource, error)
    CreateResource(ctx context.Context, spec ResourceSpec) (*Resource, error)
    UpdateResource(ctx context.Context, id string, updates ResourceUpdates) (*Resource, error)
    DeleteResource(ctx context.Context, id string) error
    DiscoverRelationships(ctx context.Context, resourceID string) ([]Relationship, error)
}

// Implement for each cloud provider
type AWSProvider struct {
    ec2Client    *ec2.Client
    s3Client     *s3.Client
    rdsClient    *rds.Client
    vpcClient    *ec2.Client
}

type AzureProvider struct {
    resourceClient   *armresources.Client
    networkClient    *armnetwork.Client
    computeClient    *armcompute.Client
}

type GCPProvider struct {
    computeService   *compute.Service
    storageClient    *storage.Client
    resourceManager  *cloudresourcemanager.Service
}

type OCIProvider struct {
    computeClient    core.ComputeClient
    networkClient    core.VirtualNetworkClient
    identityClient   identity.IdentityClient
}
```

### Resource Modeling

- Use **consistent resource schemas** across providers
- Implement **provider-specific adapters** to normalize data
- Support **cross-cloud relationships** and hierarchies (VPN tunnels, Oracle@Azure)
- Store **metadata as JSON** with **vector embeddings** for search
- Preserve **original CSP structure** while adding enriched metadata
- Enable **relationship discovery** through vector similarity queries

## 🔍 API Design Patterns

### REST API Structure

```
GET    /api/v1/resources              # List resources with filtering
POST   /api/v1/resources              # Create new resource
GET    /api/v1/resources/{id}         # Get specific resource
PUT    /api/v1/resources/{id}         # Update resource
DELETE /api/v1/resources/{id}         # Delete resource

POST   /api/v1/search                 # Semantic search
GET    /api/v1/schemas                # List available schemas
POST   /api/v1/terraform/import       # Import Terraform state

POST   /api/v1/mcp/initialize         # MCP protocol endpoints
POST   /api/v1/mcp/resources/list
POST   /api/v1/mcp/resources/read

GET    /api/v1/relationships/{id}     # Get resource relationships
POST   /api/v1/discovery/scan         # Trigger cloud resource discovery
GET    /api/v1/blockchain/audit/{id}  # Get resource audit trail
```

### Terraform Provider API

```
POST   /api/v1/terraform/siros_key           # Store terraform resource metadata
GET    /api/v1/terraform/siros_key/{key}     # Retrieve resource by key
POST   /api/v1/terraform/siros_key_path      # Query resources by path
DELETE /api/v1/terraform/siros_key/{key}     # Remove terraform resource
```

### Response Formats

```go
type APIResponse struct {
    Data    interface{} `json:"data,omitempty"`
    Error   *APIError   `json:"error,omitempty"`
    Meta    *Meta       `json:"meta,omitempty"`
}

type APIError struct {
    Code    string `json:"code"`
    Message string `json:"message"`
    Details string `json:"details,omitempty"`
}

type Resource struct {
    ID           string                 `json:"id"`
    Type         string                 `json:"type"`
    Provider     string                 `json:"provider"`
    Name         string                 `json:"name"`
    Data         map[string]interface{} `json:"data"`          // Original CSP structure
    Metadata     ResourceMetadata       `json:"metadata"`      // Enriched metadata
    Vector       []float32              `json:"vector,omitempty"`
    ParentID     *string                `json:"parent_id,omitempty"`
    CreatedAt    time.Time              `json:"created_at"`
    ModifiedAt   time.Time              `json:"modified_at"`
}

type ResourceMetadata struct {
    CreatedBy    string            `json:"created_by"`
    ModifiedBy   string            `json:"modified_by"`
    IAM          map[string]interface{} `json:"iam,omitempty"`
    Tags         map[string]string `json:"tags,omitempty"`
    Region       string            `json:"region,omitempty"`
    Environment  string            `json:"environment,omitempty"`
    CostCenter   string            `json:"cost_center,omitempty"`
    Custom       map[string]interface{} `json:"custom,omitempty"`
}
```

## 🚀 Deployment Considerations

### Single Binary Deployment

- **Embed frontend assets** in Go binary using `embed.FS`
- Support **configuration via files and environment variables**
- Implement **graceful shutdown** and **health checks**
- Provide **Docker images** for containerized deployment

### Security Best Practices

- Validate **all user inputs**
- Use **parameterized queries** to prevent SQL injection
- Implement **CORS** properly for frontend integration
- **Sanitize sensitive data** in logs and responses
- Use **HTTPS** in production

## 🧪 When Suggesting Code

### For Backend Changes

- Consider **error handling** and **edge cases**
- Ensure **database transactions** are used when needed
- Add **appropriate logging** for debugging
- Consider **performance implications** of database queries
- Think about **concurrency** and **race conditions**

### For Frontend Changes

- Ensure **TypeScript types** are properly defined
- Consider **loading states** and **error handling**
- Think about **user experience** and **accessibility**
- Ensure **responsive design** works on different screen sizes
- Consider **SEO** implications for public pages

### For API Changes

- Maintain **backward compatibility** when possible
- Update **API documentation** and **TypeScript types**
- Consider **versioning** for breaking changes
- Think about **rate limiting** and **caching**
- Ensure **proper HTTP status codes**

## 🎨 UI/UX Guidelines

### Design Principles

- **Clean and modern** interface design
- **Responsive** layout that works on mobile and desktop
- **Consistent** color scheme and typography
- **Intuitive** navigation and user flows
- **Accessible** design following WCAG guidelines

### Component Patterns

- Create **reusable components** for common UI elements
- Use **consistent prop interfaces** across similar components
- Implement **loading states** and **error boundaries**
- Support **keyboard navigation** and **screen readers**

This file helps GitHub Copilot understand the Siros project structure, coding patterns, and best practices to provide more contextually appropriate suggestions.

## 🎯 Terraform Provider Integration

### Siros Key Resources

```hcl
# Store resource metadata during Terraform deployment
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

# Query resources by path
data "siros_key_path" "production_web" {
  path = "/infrastructure/production/web"
}
```

### Integration Workflow

1. **Terraform Deployment**: Resources stored via `siros_key` during deployment
2. **Cloud Discovery**: External scanning stores discovered resources via HTTP API
3. **Resource Correlation**: Automatic identification of managed vs. unmanaged resources
4. **Gap Analysis**: Clear visibility into Platform Engineering coverage gaps

## 🔗 MCP Server Integration

Separate MCP server repository provides AI/LLM capabilities:

- **Natural Language Queries**: AI-powered resource exploration
- **Semantic Discovery**: Vector-based relationship discovery
- **Policy Compliance**: Automated governance checking
- **Predictive Analytics**: Capacity planning and optimization insights

## ⛓️ Blockchain Architecture

### Change Tracking

```go
type BlockchainRecord struct {
    ResourceID    string                 `json:"resource_id"`
    Timestamp     time.Time              `json:"timestamp"`
    Operation     string                 `json:"operation"` // CREATE, UPDATE, DELETE
    PreviousHash  string                 `json:"previous_hash"`
    DataHash      string                 `json:"data_hash"`
    Signature     string                 `json:"signature"`
    Actor         string                 `json:"actor"`
    Changes       map[string]interface{} `json:"changes,omitempty"`
}
```

### Immutable Audit Trail

- **Resource Lifecycle**: Track creation, modification, deletion, recreation
- **Change Attribution**: Full audit trail with actor identification
- **Compliance**: Built-in governance for regulatory requirements
- **Data Integrity**: Cryptographic verification of all changes
