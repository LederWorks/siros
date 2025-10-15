---
applyTo: 'backend/**'
---

# Siros Backend Component & Go Development Tracking

This document provides a comprehensive overview of the Siros project's backend component, Go development implementation, and multi-cloud API architecture.

## 📋 Documentation References

The Siros project uses a hierarchical documentation structure for comprehensive development guidance:

```
AGENTS.md (root)                            ← Master tracking & entry point
├── .github/copilot-instructions.md         ← GitHub Copilot project context
├── .github/instructions/*.instructions.md  ← Technology-specific development standards
└── */AGENTS.md                             ← Component-specific tracking documents
```

### 🎯 Documentation Purpose

- **Root AGENTS.md**: Master tracking, project overview, cross-component coordination
- **copilot-instructions.md**: GitHub Copilot context and instruction file navigation
- **\*.instructions.md**: Technology-specific development standards and patterns
- **Component AGENTS.md**: Detailed tracking for specific subsystems and components

### 📋 Hierarchical AGENTS.md Authority System

This backend AGENTS.md file operates under the **bottom-up precedence** hierarchy where component-level decisions override root-level coordination:

**Backend Component Authority:**
- **Full Authority**: Complete control over backend architecture decisions, Go development patterns, API design, and data modeling
- **Implementation Details**: Technical implementation and tracking of MVC architecture, database integration, and multi-cloud provider support
- **Resource Allocation**: Backend development resource and priority management
- **Standards Compliance**: Backend-specific compliance and quality standards

**Coordination with Root AGENTS.md:**
- **Defers to Backend Authority**: Root AGENTS.md defers to this file for all backend-specific decisions
- **Cross-Component Integration**: Root coordinates backend integration with frontend, infrastructure, and other components
- **Backend Standards**: This file defines Go development and backend architecture standards

## 📁 Backend Inventory

### Backend Directory Structure

| Directory/File | Purpose | Status | Description |
|----------------|---------|--------|-------------|
| **AGENTS.md** | Backend component tracking and Go development coordination | ✅ Active | This file - backend development guidance and tracking |
| **assets.go** | Embedded frontend assets for production builds | ✅ Complete | Go embed for static frontend assets |
| **go.mod** | Go module definition and dependency management | ✅ Active | Go 1.24+ with PostgreSQL, AWS SDK, Azure SDK, GCP SDK dependencies |
| **go.sum** | Go module checksums for dependency verification | ✅ Generated | Automatically maintained by Go toolchain |
| **siros-server.exe** | Compiled backend binary (Windows) | 📦 Generated | Production-ready executable with embedded assets |
| **coverage/** | Test coverage reports and analysis | 📦 Generated | HTML and text coverage reports from testing |
| **cmd/** | Application entry points and main packages | ✅ Complete | Main server executable and static assets |
| **internal/** | Private application code (non-exportable) | ✅ Active Development | MVC architecture, services, repositories, providers |
| **pkg/** | Public packages (exportable to other projects) | ✅ Complete | Shared types and utilities |
| **static/** | Static frontend assets (development) | ✅ Complete | Built frontend assets for development mode |

### Command Line Applications (`cmd/`)

| Directory/File | Purpose | Status | Description |
|----------------|---------|--------|-------------|
| **siros-server/** | Main API server application | ✅ Complete | HTTP server, MCP server, Terraform provider modes |
| **siros-server/main.go** | Application entry point and server initialization | ✅ Complete | Configuration loading, service setup, server startup |
| **siros-server/static/** | Embedded static assets directory | ✅ Complete | Frontend assets embedded in production builds |

### Internal Application Code (`internal/`)

#### API Layer (`internal/api/`)

| Directory/File | Purpose | Status | Description |
|----------------|---------|--------|-------------|
| **server.go** | HTTP server setup and configuration | ✅ Complete | Gorilla Mux router, middleware chain, CORS setup |
| **middleware/** | HTTP middleware components | ✅ Complete | Authentication, CORS, logging, request ID, middleware chain |
| **routes/** | API route definitions and organization | ✅ Complete | REST endpoints, route grouping, handler registration |

#### MVC Architecture Implementation

##### Controllers (`internal/controllers/`)

| File | Purpose | Status | Description |
|------|---------|--------|-------------|
| **controllers.go** | Controller factory and dependency injection | ✅ Complete | Controller initialization and service binding |
| **resource.go** | Resource CRUD operations controller | ✅ Complete | HTTP handlers for resource management |
| **search.go** | Semantic search operations controller | ✅ Complete | Vector search and relationship discovery |
| **terraform.go** | Terraform provider endpoints controller | ✅ Complete | siros_key resource management |
| **mcp.go** | MCP protocol handlers controller | ✅ Complete | Model Context Protocol server integration |
| **schema.go** | Schema management controller | ✅ Complete | Custom schema validation and storage |
| **audit.go** | Blockchain audit operations controller | ✅ Complete | Immutable change tracking and audit trail |
| **health.go** | Health check and monitoring controller | ✅ Complete | System health and readiness endpoints |

##### Models (`internal/models/`)

| File | Purpose | Status | Description |
|------|---------|--------|-------------|
| **resource.go** | Core resource data model and validation | ✅ Complete | Resource structure, metadata, validation rules |
| **resource_test.go** | Resource model unit tests | ✅ Complete | Model validation and business logic testing |

##### Services (`internal/services/`)

| File | Purpose | Status | Description |
|------|---------|--------|-------------|
| **services.go** | Service factory and dependency injection | ✅ Complete | Service initialization and repository binding |
| **resource.go** | Resource business logic and orchestration | ✅ Complete | Resource lifecycle management, validation, transformation |
| **search.go** | Vector search and semantic operations | ✅ Complete | pgvector integration, similarity queries, relationship discovery |
| **schema_terraform_mcp.go** | Schema management for Terraform and MCP | ✅ Complete | Schema validation, custom types, protocol integration |
| **simple_resource.go** | Simplified resource operations | ✅ Complete | Basic CRUD operations without complex orchestration |
| **idgen.go** | ID generation utilities | ✅ Complete | Unique identifier generation for resources |

##### Repositories (`internal/repositories/`)

| File | Purpose | Status | Description |
|------|---------|--------|-------------|
| **repositories.go** | Repository factory and dependency injection | ✅ Complete | Repository initialization and database binding |
| **resource.go** | Resource data access layer | ✅ Complete | PostgreSQL operations, pgvector queries, transactions |
| **schema.go** | Schema storage and retrieval | ✅ Complete | Schema persistence, validation, versioning |
| **blockchain.go** | Blockchain storage operations | ✅ Complete | Immutable audit trail storage and retrieval |
| **migrate.go** | Database migration utilities | ✅ Complete | Schema creation, pgvector setup, index management |

##### Views (`internal/views/`)

| File | Purpose | Status | Description |
|------|---------|--------|-------------|
| **response.go** | HTTP response formatting and serialization | ✅ Complete | JSON API responses, error formatting, metadata inclusion |

#### Supporting Infrastructure

##### Multi-Cloud Providers (`internal/providers/`)

| File | Purpose | Status | Description |
|------|---------|--------|-------------|
| **manager.go** | Multi-cloud provider coordination | ✅ Complete | Provider factory, configuration management, unified interface |
| **aws.go** | Amazon Web Services integration | ✅ Complete | EC2, S3, RDS, VPC resource discovery and management |
| **azure.go** | Microsoft Azure integration | ✅ Complete | Resource Manager, Compute, Network resource integration |
| **gcp.go** | Google Cloud Platform integration | ✅ Complete | Compute Engine, Cloud Storage, Cloud SQL integration |

##### Storage Layer (`internal/storage/`)

| File | Purpose | Status | Description |
|------|---------|--------|-------------|
| **storage.go** | Database connection and operations | ✅ Complete | PostgreSQL connection pooling, transaction management, pgvector setup |

##### Configuration Management (`internal/config/`)

| File | Purpose | Status | Description |
|------|---------|--------|-------------|
| **config.go** | Application configuration loading | ✅ Complete | YAML/environment configuration, validation, defaults |
| **config_test.go** | Configuration testing and validation | ✅ Complete | Configuration loading and validation testing |

##### Blockchain Integration (`internal/blockchain/`)

| File | Purpose | Status | Description |
|------|---------|--------|-------------|
| **tracker.go** | Blockchain change tracking implementation | ✅ Complete | Immutable audit trail, cryptographic verification, change history |

##### Terraform Integration (`internal/terraform/`)

| File | Purpose | Status | Description |
|------|---------|--------|-------------|
| **importer.go** | Terraform state import and parsing | ✅ Complete | Terraform state file processing, resource mapping, siros_key integration |

### Public Packages (`pkg/`)

| Directory/File | Purpose | Status | Description |
|----------------|---------|--------|-------------|
| **types/** | Shared type definitions | ✅ Complete | Common types, interfaces, data structures |
| **types/types.go** | Core type definitions | ✅ Complete | Resource types, metadata structures, API contracts |
| **types/types_test.go** | Type validation and testing | ✅ Complete | Type safety and validation testing |

## 🏗️ Architecture Overview

The Siros backend implements a comprehensive **MVC (Model-View-Controller) architecture** designed for multi-cloud resource management with vector-based storage and AI integration.

### 🎯 Backend Architecture Principles

- **MVC Pattern**: Clean separation of concerns with controllers, models, services, repositories, and views
- **Vector-Based Storage**: Each cloud resource stored as individual vector with pgvector integration
- **Multi-Cloud Native**: Unified interface for AWS, Azure, GCP, and OCI resource management
- **API-First Design**: RESTful HTTP API, Terraform Provider API, and MCP server protocol
- **Blockchain Audit**: Immutable change tracking for compliance and governance
- **Dependency Injection**: Interface-based dependency injection for testability and modularity
- **Database Transactions**: ACID compliance with PostgreSQL transaction management
- **Semantic Search**: Vector similarity queries for resource relationship discovery

### 🚀 MVC Architecture Implementation

#### Request Flow Architecture
```
HTTP Request → Middleware Chain → Controllers → Services → Repositories → Database
     ↓              ↓              ↓           ↓           ↓             ↓
CORS/Auth     Request ID     Business     Data Access  PostgreSQL   pgvector
Logging       Validation     Logic       Layer        +Blockchain   Storage
     ↓              ↓              ↓           ↓           ↓             ↓
HTTP Response ← Views ← Controllers ← Services ← Repositories ← Query Results
```

#### Component Responsibilities

**Controllers (HTTP Layer)**
- HTTP request/response handling
- Input validation and sanitization
- Authentication and authorization
- Error handling and HTTP status codes
- Request routing and parameter extraction

**Services (Business Logic Layer)**
- Business rule enforcement
- Transaction orchestration
- Multi-step operations coordination
- External provider integration
- Vector generation and processing

**Repositories (Data Access Layer)**
- Database query execution
- Transaction management
- Data persistence and retrieval
- pgvector operations
- Blockchain record management

**Models (Data Layer)**
- Data structure definitions
- Validation rules and constraints
- Business logic encapsulation
- Serialization/deserialization
- Type safety enforcement

**Views (Presentation Layer)**
- Response formatting and serialization
- JSON API structure standardization
- Error message formatting
- Metadata inclusion and pagination

### 🔧 Technology Stack

#### Core Technologies
- **Go 1.24+**: Backend runtime with modern language features
- **PostgreSQL**: Primary database with ACID compliance
- **pgvector**: Vector similarity search and storage
- **Gorilla Mux**: HTTP routing and middleware
- **Database/SQL**: Standard database interface with connection pooling

#### Multi-Cloud SDKs
- **AWS SDK v2**: Complete AWS service integration
- **Azure SDK**: Resource Manager and service-specific clients
- **Google Cloud SDK**: Comprehensive GCP service coverage
- **OCI SDK**: Oracle Cloud Infrastructure integration

#### Development Tools
- **golangci-lint**: Comprehensive code quality analysis
- **gosec**: Security vulnerability scanning
- **go test**: Unit and integration testing framework
- **go-callvis**: Call graph visualization and documentation

## 📚 Component Status Overview

### Backend Development

**Status**: ✅ **ACTIVE DEVELOPMENT**
**Lead Technology**: Go 1.24+, PostgreSQL + pgvector, MVC Architecture

#### Completed Implementation

- [x] **MVC Architecture**: Complete separation of controllers, models, services, repositories, views
- [x] **Multi-Cloud Providers**: AWS, Azure, GCP integration with unified interface
- [x] **Vector Storage**: pgvector integration with semantic search capabilities
- [x] **HTTP REST API**: Comprehensive endpoints for resource management, search, and administration
- [x] **Terraform Provider**: siros_key resource type with state import capabilities
- [x] **MCP Server Protocol**: Model Context Protocol integration for AI-powered resource management
- [x] **Blockchain Audit**: Immutable change tracking with cryptographic verification
- [x] **Database Integration**: PostgreSQL with transaction management and connection pooling
- [x] **Configuration Management**: YAML and environment variable configuration
- [x] **Testing Infrastructure**: Unit tests, integration tests, and coverage reporting
- [x] **Security Implementation**: Input validation, SQL injection prevention, error sanitization
- [x] **API Documentation**: Comprehensive endpoint documentation and OpenAPI specification

#### Active Development Areas

- [ ] **Enhanced Cloud Provider Coverage**: Oracle@Azure scenarios, IBM Cloud integration
- [ ] **Advanced Vector Algorithms**: Improved similarity scoring and relationship discovery
- [ ] **Performance Optimization**: Query optimization, caching strategies, connection pooling tuning
- [ ] **Advanced Audit Analytics**: Trend analysis, compliance reporting, change impact assessment
- [ ] **Real-time Notifications**: WebSocket integration for live resource updates
- [ ] **Advanced Search Features**: Full-text search, filtered queries, aggregation endpoints
- [ ] **Monitoring Integration**: Metrics collection, distributed tracing, health monitoring

#### Development Priorities

1. **Performance Optimization** - Query performance tuning and caching strategies
2. **Advanced Relationships** - Enhanced resource dependency mapping and visualization
3. **Real-time Features** - WebSocket integration for live updates and notifications
4. **Security Hardening** - Advanced authentication, authorization, and audit capabilities
5. **Monitoring & Observability** - Comprehensive metrics, logging, and distributed tracing
6. **API Enhancement** - GraphQL endpoints, advanced filtering, bulk operations

### Cross-Component Coordination

#### Integration Requirements

| Integration Point | Requirement | Status |
|-------------------|-------------|---------|
| **Frontend API** | JSON REST endpoints, WebSocket support, error handling | ✅ Complete |
| **Infrastructure** | Container configuration, environment variables, health checks | 🔄 In Progress |
| **Scripts** | Build automation, testing orchestration, deployment scripts | ✅ Complete |
| **Database** | PostgreSQL setup, pgvector configuration, migration scripts | ✅ Complete |
| **Cloud Providers** | Multi-cloud authentication, resource discovery, API integration | ✅ Complete |

#### Backend API Endpoints

**Resource Management:**
```
GET    /api/v1/resources              # List resources with filtering
POST   /api/v1/resources              # Create new resource
GET    /api/v1/resources/{id}         # Get specific resource
PUT    /api/v1/resources/{id}         # Update resource
DELETE /api/v1/resources/{id}         # Delete resource
```

**Search & Discovery:**
```
POST   /api/v1/search                 # Semantic search with vector similarity
GET    /api/v1/relationships/{id}     # Get resource relationships
POST   /api/v1/discovery/scan         # Trigger cloud resource discovery
```

**Schema Management:**
```
GET    /api/v1/schemas                # List available schemas
POST   /api/v1/schemas                # Create custom schema
GET    /api/v1/schemas/{name}         # Get schema definition
```

**Terraform Integration:**
```
POST   /api/v1/terraform/siros_key           # Store terraform resource metadata
GET    /api/v1/terraform/siros_key/{key}     # Retrieve resource by key
POST   /api/v1/terraform/siros_key_path      # Query resources by path
DELETE /api/v1/terraform/siros_key/{key}     # Remove terraform resource
```

**MCP Protocol:**
```
POST   /api/v1/mcp/initialize         # MCP protocol initialization
POST   /api/v1/mcp/resources/list     # MCP resource listing
POST   /api/v1/mcp/resources/read     # MCP resource reading
```

**Audit & Monitoring:**
```
GET    /api/v1/blockchain/audit/{id}  # Get resource audit trail
GET    /api/v1/health                 # Health check endpoint
GET    /api/v1/metrics                # Application metrics
```

## 🎯 Cross-Component Coordination

This section documents the interdependencies between backend components and other parts of the Siros project that require coordination when changes occur.

### Frontend Integration Requirements

When backend APIs or data structures change, the following frontend components require updates:

#### API Client Updates

- **TypeScript Types**: Update frontend API client with new request/response types
- **Error Handling**: Coordinate error response formats and status codes
- **Authentication**: Synchronize authentication mechanisms and token handling
- **Real-time Updates**: WebSocket event coordination for live data updates
- **Required Updates**: API client regeneration, type definitions, error handling patterns

#### Data Flow Coordination

- **Resource Models**: Frontend resource types must match backend resource structures
- **Search Results**: Search response formatting and result presentation
- **Relationship Data**: Resource relationship visualization and graph rendering
- **Audit Information**: Blockchain audit trail display and history navigation
- **Required Updates**: Component props, state management, data transformation

### Infrastructure Integration Requirements

When backend configuration or deployment requirements change:

#### Container Configuration

- **Environment Variables**: Database connections, cloud provider credentials, API keys
- **Health Checks**: HTTP health endpoints for container orchestration
- **Resource Limits**: Memory and CPU requirements for optimal performance
- **Port Configuration**: API server ports, health check endpoints, metrics exposure
- **Required Updates**: Docker configurations, Kubernetes manifests, deployment scripts

#### Database Integration

- **Schema Migrations**: Database schema changes and migration scripts
- **Connection Configuration**: PostgreSQL connection strings and pooling settings
- **pgvector Setup**: Vector extension installation and index configuration
- **Backup Procedures**: Database backup and disaster recovery coordination
- **Required Updates**: Migration scripts, connection configs, backup automation

### Scripts Integration Requirements

When backend tooling or build processes change:

#### Build Automation

- **Go Module Updates**: Dependency changes and module version updates
- **Asset Embedding**: Frontend asset compilation and embedding coordination
- **Binary Generation**: Cross-platform compilation and distribution
- **Test Orchestration**: Backend test execution and coverage reporting
- **Required Updates**: Build scripts, test automation, dependency management

#### Testing Coordination

- **Test Data**: Shared test fixtures and database setup
- **Coverage Reporting**: Test coverage aggregation and reporting
- **Integration Tests**: API endpoint testing and validation
- **Security Scanning**: Vulnerability assessment and code quality checks
- **Required Updates**: Test scripts, coverage configs, security scanning rules

### Cloud Provider Integration Requirements

When cloud provider SDKs or configurations change:

#### Provider Configuration

- **Authentication**: Cloud provider credential management and rotation
- **Service Discovery**: New cloud service integration and resource mapping
- **API Changes**: Cloud provider API updates and SDK compatibility
- **Resource Types**: New resource type support and schema extensions
- **Required Updates**: Provider configurations, authentication, resource mappings

#### Multi-Cloud Coordination

- **Unified Interface**: Consistent resource representation across providers
- **Cross-Cloud Relationships**: Oracle@Azure, hybrid cloud scenarios
- **Cost Management**: Resource cost tracking and optimization
- **Compliance**: Multi-cloud security and compliance validation
- **Required Updates**: Provider interfaces, relationship mapping, cost tracking

### Database Schema Coordination Requirements

When data models or database schema change:

#### Schema Management

- **Migration Scripts**: Database schema evolution and version management
- **Index Optimization**: pgvector index creation and performance tuning
- **Data Validation**: Schema validation and constraint enforcement
- **Backup Compatibility**: Schema change impact on backup and recovery
- **Required Updates**: Migration scripts, index definitions, validation rules

#### Vector Operations

- **Vector Generation**: Resource vectorization and similarity algorithms
- **Index Configuration**: pgvector index types and performance optimization
- **Query Optimization**: Vector search performance and result relevance
- **Storage Efficiency**: Vector storage optimization and compression
- **Required Updates**: Vector algorithms, index configs, query optimization

### Coordination Checklist

When making changes to backend components, review this coordination checklist:

- [ ] **API Changes**: Update frontend API client, TypeScript types, error handling
- [ ] **Data Models**: Update frontend components, database migrations, test fixtures
- [ ] **Configuration**: Update container configs, environment variables, deployment scripts
- [ ] **Dependencies**: Update build scripts, test automation, dependency management
- [ ] **Provider Integration**: Update authentication, resource mappings, cost tracking
- [ ] **Database Schema**: Update migration scripts, indexes, validation rules
- [ ] **Security**: Update authentication, authorization, audit trail requirements
- [ ] **Performance**: Update query optimization, caching, connection pooling

## 🔄 Feature Roadmap

### 🚀 Phase 1: Core Enhancement (HIGH PRIORITY)

- [ ] **Performance Optimization**: Database query optimization and connection pooling tuning
  - [ ] PostgreSQL query performance analysis and optimization
  - [ ] pgvector index optimization for large-scale deployments
  - [ ] Connection pooling configuration and monitoring
  - [ ] Caching strategies for frequently accessed resources
- [ ] **Advanced Relationship Discovery**: Enhanced resource dependency mapping
  - [ ] Improved vector similarity algorithms
  - [ ] Cross-cloud relationship detection (Oracle@Azure scenarios)
  - [ ] Resource dependency graph visualization
  - [ ] Automated relationship validation and verification
- [ ] **Real-time Features**: WebSocket integration for live updates
  - [ ] Resource change notifications and live updates
  - [ ] Real-time search result streaming
  - [ ] Live audit trail monitoring
  - [ ] Performance metrics and health monitoring dashboards

### 🔒 Phase 2: Security & Compliance (HIGH PRIORITY)

- [ ] **Advanced Authentication**: Enterprise authentication and authorization
  - [ ] OAuth 2.0 / OpenID Connect integration
  - [ ] Role-based access control (RBAC) implementation
  - [ ] Multi-factor authentication support
  - [ ] Session management and token lifecycle
- [ ] **Enhanced Audit Capabilities**: Advanced compliance and governance
  - [ ] Trend analysis and compliance reporting
  - [ ] Change impact assessment and risk evaluation
  - [ ] Automated compliance validation
  - [ ] Audit trail export and archival
- [ ] **Security Hardening**: Advanced security features and vulnerability management
  - [ ] API rate limiting and DDoS protection
  - [ ] Input validation enhancement and sanitization
  - [ ] Encryption at rest and in transit
  - [ ] Security scanning integration and vulnerability management

### 🌐 Phase 3: Multi-Cloud Expansion (MEDIUM PRIORITY)

- [ ] **Oracle Cloud Infrastructure (OCI)**: Complete OCI integration
  - [ ] OCI SDK integration and resource discovery
  - [ ] Autonomous Database and container service support
  - [ ] Oracle@Azure hybrid scenarios
  - [ ] OCI-specific resource types and relationships
- [ ] **IBM Cloud Integration**: Enterprise cloud platform support
  - [ ] IBM Cloud SDK integration
  - [ ] Kubernetes Service and Databases for PostgreSQL support
  - [ ] IBM Cloud resource discovery and management
  - [ ] Cost optimization and resource lifecycle management
- [ ] **Cross-Cloud Operations**: Advanced multi-cloud capabilities
  - [ ] Cross-cloud resource migration and replication
  - [ ] Multi-cloud cost optimization and resource rightsizing
  - [ ] Unified monitoring and alerting across cloud providers
  - [ ] Cross-cloud disaster recovery and backup strategies

### 📊 Phase 4: Advanced Features (MEDIUM PRIORITY)

- [ ] **GraphQL API**: Modern API interface with flexible queries
  - [ ] GraphQL schema design and implementation
  - [ ] Real-time subscriptions for resource changes
  - [ ] Advanced filtering and aggregation capabilities
  - [ ] Performance optimization for complex queries
- [ ] **Advanced Search**: Enhanced search and discovery capabilities
  - [ ] Full-text search integration with vector search
  - [ ] Advanced filtering and faceted search
  - [ ] Search analytics and query optimization
  - [ ] Saved searches and alert management
- [ ] **Monitoring & Observability**: Comprehensive monitoring and metrics
  - [ ] Distributed tracing with OpenTelemetry integration
  - [ ] Custom metrics and alerting rules
  - [ ] Performance profiling and bottleneck identification
  - [ ] Log aggregation and analysis

### 🤖 Phase 5: AI Integration (LONG-TERM)

- [ ] **Enhanced MCP Capabilities**: Advanced AI-powered resource management
  - [ ] Natural language query processing
  - [ ] Automated resource optimization recommendations
  - [ ] Predictive analytics for capacity planning
  - [ ] Intelligent cost optimization and resource rightsizing
- [ ] **Machine Learning Integration**: AI-powered insights and automation
  - [ ] Resource usage pattern analysis
  - [ ] Anomaly detection and alerting
  - [ ] Automated resource lifecycle management
  - [ ] Predictive maintenance and optimization

### 📈 Long-Term Vision & Roadmap

#### Short-Term Goals (Next 2-4 weeks)

- [ ] Complete performance optimization and query tuning
- [ ] Implement real-time WebSocket features for live updates
- [ ] Enhanced relationship discovery algorithms
- [ ] Advanced authentication and authorization mechanisms

#### Medium-Term Goals (Next 2-3 months)

- [ ] Complete OCI and IBM Cloud integration
- [ ] GraphQL API implementation with advanced querying
- [ ] Comprehensive monitoring and observability stack
- [ ] Advanced security hardening and compliance features

#### Long-Term Vision (6+ months)

- [ ] AI-powered resource optimization and predictive analytics
- [ ] Enterprise-grade security and compliance automation
- [ ] Advanced multi-cloud management and orchestration
- [ ] Open-source ecosystem and community development

## 📝 Standards Compliance

### Go Development Standards

- [x] **MVC Architecture**: Clean separation of controllers, models, services, repositories, views
- [x] **Code Quality**: golangci-lint integration with comprehensive rule sets
- [x] **Security Scanning**: gosec vulnerability analysis and remediation
- [x] **Testing Standards**: Unit tests, integration tests, coverage reporting
- [x] **API Design**: RESTful endpoints, consistent error handling, proper HTTP status codes
- [x] **Database Integration**: PostgreSQL + pgvector with proper indexing and transactions
- [x] **Input Validation**: Comprehensive validation across all input vectors
- [x] **Error Handling**: Secure error messages without information leakage
- [x] **Documentation**: Comprehensive API documentation and code comments

### Development Standards Compliance

#### Code Quality Metrics

- [x] **Go Linting**: golangci-lint with comprehensive rule coverage and zero tolerance policy
- [x] **Security Scanning**: gosec for Go security vulnerability detection and remediation
- [x] **Dependency Management**: Automated updates via Dependabot with security prioritization
- [x] **Test Coverage**: Minimum 80% test coverage across all packages
- [x] **Code Review**: Mandatory peer review for all backend changes

#### Performance Standards

- [x] **Database Optimization**: Query performance monitoring and optimization
- [x] **Connection Pooling**: PostgreSQL connection pool tuning and monitoring
- [x] **Memory Management**: Efficient memory usage and garbage collection optimization
- [x] **Concurrency**: Proper goroutine management and race condition prevention
- [x] **API Performance**: Response time monitoring and optimization

#### Security Standards

- [x] **Input Validation**: Comprehensive validation across all API endpoints
- [x] **SQL Injection Prevention**: Parameterized queries throughout data layer
- [x] **Error Handling**: Secure error messages without information leakage
- [x] **Authentication**: JWT-based authentication with secure token management
- [x] **Authorization**: Role-based access control and permission validation

### Remaining Compliance Tasks

#### High Priority

- [ ] **GraphQL API**: Implement GraphQL endpoints with type-safe schema
- [ ] **Performance Monitoring**: Application performance metrics and alerting
- [ ] **Security Enhancement**: Advanced authentication and authorization
- [ ] **Real-time Features**: WebSocket integration for live updates

#### Medium Priority

- [ ] **API Versioning**: Comprehensive API versioning strategy
- [ ] **Documentation Automation**: Automated API documentation generation
- [ ] **Logging Standards**: Structured logging with correlation IDs
- [ ] **Error Recovery**: Enhanced error recovery and retry mechanisms

#### Long-Term

- [ ] **Enterprise Security**: Advanced authentication, authorization, and audit capabilities
- [ ] **Scalability Standards**: Load testing and performance optimization for enterprise scale
- [ ] **Compliance Frameworks**: SOC 2, ISO 27001, and other enterprise compliance standards
- [ ] **Multi-Tenant Support**: Multi-tenant architecture and resource isolation

## 🐛 Known Issues & Workarounds

### Current Backend Issues

1. **Vector Query Performance**: Large-scale vector similarity queries can be slow with >10,000 resources
   - **Issue**: pgvector similarity queries performance degradation with large datasets
   - **Component**: Search service and repository layer
   - **Workaround**: Implement pagination and result limiting
   - **Priority**: High (scalability concern)

2. **Cloud Provider Rate Limiting**: AWS/Azure/GCP API rate limits can cause discovery timeouts
   - **Issue**: Resource discovery fails with rate limiting errors during large scans
   - **Component**: Cloud provider integration services
   - **Workaround**: Implement exponential backoff and request queuing
   - **Priority**: Medium (operational concern)

3. **Connection Pool Exhaustion**: High concurrent load can exhaust PostgreSQL connections
   - **Issue**: Database connection pool exhaustion under heavy load
   - **Component**: Storage layer and repository connection management
   - **Workaround**: Tune connection pool settings and implement connection monitoring
   - **Priority**: High (production readiness)

### Technical Debt

- [ ] **Configuration Management**: Centralized configuration system with hot reloading
- [ ] **Error Handling**: Consistent error handling patterns across all services
- [ ] **Logging**: Structured logging with correlation IDs and distributed tracing
- [ ] **Testing**: Automated integration testing pipeline with real cloud resources
- [ ] **Documentation**: Automated API documentation generation from code annotations
- [ ] **Monitoring**: Comprehensive application metrics and health monitoring
- [ ] **Caching**: Redis integration for frequently accessed data
- [ ] **Background Jobs**: Asynchronous job processing for long-running operations

### Performance Bottlenecks

- [ ] **Database Queries**: Optimize complex vector similarity queries and joins
- [ ] **Memory Usage**: Optimize resource object memory footprint for large datasets
- [ ] **API Response Times**: Implement response caching for frequently accessed endpoints
- [ ] **Provider Discovery**: Parallel resource discovery across multiple cloud providers
- [ ] **Vector Operations**: Optimize vector generation and similarity calculations

## 📚 Related Documentation

### Core Backend Documentation

- **[Root AGENTS.md](../AGENTS.md)**: Master project tracking and component coordination
- **[Go Backend Instructions](../.github/instructions/go.instructions.md)**: Go development standards and MVC patterns
- **[GitHub Copilot Instructions](../.github/copilot-instructions.md)**: Project context for AI assistance

### Technology-Specific Instructions

- **[Scripts Instructions](../.github/instructions/scripts.instructions.md)**: Build automation and testing standards
- **[TypeScript Instructions](../.github/instructions/typescript.instructions.md)**: Frontend integration patterns
- **[VS Code Instructions](../.github/instructions/vscode.instructions.md)**: Development environment configuration

### Component Integration

- **[Scripts AGENTS.md](../scripts/AGENTS.md)**: Build automation tracking and coordination
- **[Frontend AGENTS.md](../frontend/AGENTS.md)**: React/TypeScript frontend tracking (planned)
- **[Infrastructure AGENTS.md](../infrastructure/AGENTS.md)**: Deployment tracking and coordination

### API and Architecture Documentation

- **[MVC Implementation Summary](../docs/MVC_IMPLEMENTATION_SUMMARY.md)**: Technical architecture documentation
- **[Backend Call Graph](../docs/CALL_GRAPH.md)**: Code structure visualization and analysis
- **[Contributing Guidelines](../.github/CONTRIBUTING.md)**: Development workflow and standards

## 🤝 Contributing

### Backend Development Workflow

1. **Local Setup**: Use `scripts/env_dev.ps1` or `scripts/env_dev.sh` for backend development environment
2. **Testing**: Run `scripts/test_backend.ps1` or `scripts/test_backend.sh` for comprehensive testing
3. **Code Quality**: Use `scripts/backend/backend_lint.ps1/sh` for linting and quality checks
4. **Security**: Run `scripts/backend/backend_gosec.ps1/sh` for security vulnerability scanning
5. **Documentation**: Update backend AGENTS.md with significant architectural changes

### Backend Standards

1. **Follow MVC Patterns**: Use established controller, service, repository, and model patterns
2. **Write Tests**: Unit tests for business logic, integration tests for database operations
3. **Security First**: Input validation, SQL injection prevention, secure error handling
4. **Performance Optimization**: Consider database query performance and memory usage
5. **Documentation**: Comment complex business logic and maintain API documentation

### AI Agent Guidance

This backend documentation is designed for AI agents to:

- **Navigate Architecture**: Find specific MVC components and understand their responsibilities
- **Implement Features**: Follow established patterns for controllers, services, and repositories
- **Integrate APIs**: Understand endpoint design and multi-cloud provider integration
- **Maintain Quality**: Follow testing, security, and performance standards
- **Coordinate Changes**: Understand cross-component dependencies and integration requirements

---

_Last Updated: October 16, 2025 - This document serves as the authoritative source for all Siros backend development activities_
