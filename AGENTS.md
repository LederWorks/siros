# Siros AI Agent Development & Component Tracking

This document serves as the master entry point for AI agent development guidance and component tracking across the Siros multi-cloud resource management platform.

## 📋 Documentation References

The Siros project uses a hierarchical documentation structure for comprehensive development guidance:

```
AGENTS.md (root)                            ← Master tracking & entry point
├── .github/copilot-instructions.md         ← GitHub Copilot project context
├── .github/instructions/*.instructions.md  ← Technology-specific development standards
└── */AGENTS.md                             ← Component-specific tracking documents
```

### 🎯 Documentation Purpose

- **Root AGENTS.md** (this file): Master tracking, project overview, cross-component coordination
- **copilot-instructions.md**: GitHub Copilot context and instruction file navigation
- **\*.instructions.md**: Technology-specific development standards and patterns
- **Component AGENTS.md**: Detailed tracking for specific subsystems and components

## 📁 Repository Inventory

### Root Level Files & Folders

| File/Folder              | Purpose                                               | Status               |
| ------------------------ | ----------------------------------------------------- | -------------------- |
| **AGENTS.md**            | Master project tracking and component coordination    | ✅ Active             |
| **README.md**            | Project overview, setup instructions, and usage guide | ✅ Current            |
| **LICENSE**              | Open source license (MPLv2.0)                         | ✅ Complete           |
| **CODE_OF_CONDUCT.md**   | Community guidelines and behavioral standards         | ✅ Complete           |
| **Makefile**             | Cross-platform build automation shortcuts             | ✅ Complete           |
| **config.yaml**          | Application configuration template                    | ✅ Complete           |
| **docker-compose.yml**   | Multi-container development environment               | ✅ Complete           |
| **Dockerfile**           | Container image build configuration                   | ✅ Complete           |
| **siros.code-workspace** | VS Code workspace configuration                       | ✅ Complete           |
| **.github/**             | GitHub configuration, workflows, and templates        | ✅ Complete           |
| **.vscode/**             | VS Code tasks, settings, and extensions               | ✅ Complete           |
| **backend/**             | Go server implementation (MVC architecture)           | ✅ Active Development |
| **frontend/**            | React/TypeScript web application                      | ✅ Active Development |
| **scripts/**             | Cross-platform build and automation scripts           | ✅ Complete           |
| **docs/**                | Project documentation and generated content           | 🔄 In Progress         |
| **build/**               | Compiled binaries and build artifacts                 | 📦 Generated           |

### Key Configuration Files

- **backend/go.mod**: Go module dependencies and version management
- **frontend/package.json**: Node.js dependencies and npm scripts
- **frontend/tsconfig.json**: TypeScript compiler configuration
- **frontend/vite.config.ts**: Vite build tool configuration
- **.github/workflows/**: CI/CD automation workflows
- **.vscode/tasks.json**: Development task automation
- **.vscode/mcp.json**: Model Context Protocol server configurations

## 🏗️ Architecture Overview

**Siros** (_Greek: σίρος - "silo" or "pit for holding grain"_) is a Go-based relational data structure tool designed for storing and serving cloud estate resources as JSON in a hierarchical, vector-based format.

### Core Components

| Component | Purpose | Status | AGENTS.md |
|-----------|---------|--------|-----------|
| **Backend (Go)** | API server, business logic, data persistence | ✅ Active Development | [backend/AGENTS.md](backend/AGENTS.md) |
| **Frontend (React/TS)** | Web portal, user interface, dashboard | ✅ Active Development | [frontend/AGENTS.md](frontend/AGENTS.md) |
| **Scripts** | Build automation, cross-platform tooling | ✅ Complete | [scripts/AGENTS.md](scripts/AGENTS.md) |
| **Infrastructure** | Docker, database, deployment configs | 🔄 In Progress | [infrastructure/AGENTS.md](infrastructure/AGENTS.md) |
| **Documentation** | Guides, API docs, architecture specs | 🔄 In Progress | [docs/AGENTS.md](docs/AGENTS.md) |

### Architecture Principles

- **Vector-Based Storage**: Each cloud resource as individual vector with original CSP structure
- **Multi-Cloud Native**: Simultaneous management across AWS, Azure, GCP, OCI
- **MVC Pattern**: Clean separation of concerns across all components
- **API-First Design**: HTTP, Terraform Provider, and MCP server interfaces
- **Blockchain Audit**: Immutable change tracking for compliance
- **Cross-Platform**: Windows, Linux, macOS support

## 📚 Component Status Overview

### Backend Development

**Status**: ✅ **ACTIVE DEVELOPMENT**
**Lead Technology**: Go 1.21+, PostgreSQL + pgvector, MVC Architecture

#### Current Implementation

- [x] MVC architecture (controllers, models, services, repositories, views)
- [x] Multi-cloud provider integration (AWS, Azure, GCP, OCI)
- [x] Vector-based resource storage with pgvector
- [x] HTTP REST API with comprehensive endpoints
- [x] Terraform provider integration (siros_key resources)
- [x] MCP server protocol for AI integration
- [x] Blockchain audit trail implementation
- [x] Semantic search and relationship discovery

#### Active Development Areas

- [ ] Enhanced cloud provider coverage (Oracle@Azure scenarios)
- [ ] Advanced vector similarity algorithms
- [ ] Performance optimization for large-scale deployments
- [ ] Advanced audit analytics and reporting

**Details**: See [backend/AGENTS.md](backend/AGENTS.md)

### Frontend Development

**Status**: ✅ **ACTIVE DEVELOPMENT**
**Lead Technology**: React 18, TypeScript, Vite, Modern UI

#### Current Implementation

- [x] React-based web portal with TypeScript
- [x] Responsive dashboard with resource visualization
- [x] Type-safe API client integration
- [x] Component architecture following MVC patterns
- [x] Modern build tooling with Vite
- [x] Cross-platform development support

#### Active Development Areas

- [ ] Advanced resource relationship visualization
- [ ] Real-time resource monitoring dashboard
- [ ] Enhanced search and filtering capabilities
- [ ] Mobile-responsive design improvements

**Details**: See [frontend/AGENTS.md](frontend/AGENTS.md)

### Script Architecture

**Status**: ✅ **COMPLETE**
**Lead Technology**: PowerShell + Bash, Cross-Platform Automation

#### Implemented Features

- [x] Modular script architecture (utility vs component scripts)
- [x] Cross-platform automation (PowerShell .ps1 + Bash .sh pairs)
- [x] Comprehensive testing orchestration (backend + frontend)
- [x] Build automation with embedded frontend assets
- [x] Code quality and security scanning integration
- [x] Development environment automation
- [x] Call graph generation and documentation

#### Maintenance Mode

- [x] All core functionality implemented and tested
- [x] Standards compliance achieved
- [x] Documentation comprehensive and current

**Details**: See [scripts/AGENTS.md](scripts/AGENTS.md)

## 🎯 Cross-Component Coordination

### Development Workflow Integration

| Workflow Stage | Backend | Frontend | Scripts | Status |
|----------------|---------|----------|---------|---------|
| **Local Development** | Go hot reload | React dev server | env_dev.ps1/sh | ✅ Working |
| **Testing** | Go test suites | Jest/Vitest | test_*.ps1/sh | ✅ Working |
| **Code Quality** | golangci-lint, gosec | ESLint, TypeScript | lint.ps1/sh | ✅ Working |
| **Building** | Go compilation | Vite bundling | build_all.ps1/sh | ✅ Working |
| **Deployment** | Container packaging | Asset embedding | Docker integration | 🔄 In Progress |

### API Integration Matrix

| Interface | Backend Implementation | Frontend Consumption | Status |
|-----------|----------------------|---------------------|---------|
| **HTTP REST API** | Go controllers/services | TypeScript API client | ✅ Implemented |
| **Terraform Provider** | Custom provider endpoints | N/A | ✅ Implemented |
| **MCP Protocol** | MCP server mode | Future AI integration | ✅ Implemented |
| **WebSocket (Future)** | Real-time updates | Live dashboard | 📋 Planned |

## 🔄 Feature Roadmap

### High Priority (Current Sprint)

1. **Backend Optimization**
   - [ ] Vector similarity performance tuning
   - [ ] Database query optimization for large datasets
   - [ ] Enhanced error handling and logging

2. **Frontend Enhancement**
   - [ ] Advanced resource visualization components
   - [ ] Real-time dashboard updates
   - [ ] Improved search and filtering UX

3. **Integration Testing**
   - [ ] End-to-end API testing
   - [ ] Multi-cloud provider integration testing
   - [ ] Performance testing under load

### Medium Priority (Next Sprint)

1. **Documentation Completion**
   - [ ] API documentation generation
   - [ ] User guide and tutorials
   - [ ] Architecture decision records

2. **Deployment Automation**
   - [ ] Production deployment scripts
   - [ ] Container orchestration
   - [ ] CI/CD pipeline optimization

3. **Security Hardening**
   - [ ] Authentication and authorization
   - [ ] Audit trail enhancement
   - [ ] Security scanning automation

### 📈 Long-Term Vision & Roadmap

#### Short-Term Goals (Next 2-4 weeks)

- [ ] Complete frontend testing implementation
- [ ] Enhance backend performance optimization
- [ ] Finalize production deployment automation
- [ ] Complete API documentation

#### Medium-Term Goals (Next 2-3 months)

- [ ] Advanced resource relationship visualization
- [ ] Multi-tenant support and RBAC
- [ ] Enhanced cloud provider integrations
- [ ] Real-time monitoring and alerting

#### Long-Term Vision (6+ months)

- [ ] AI-powered resource optimization recommendations
- [ ] Advanced analytics and reporting platform
- [ ] Enterprise-grade security and compliance features
- [ ] Open-source community ecosystem

## 📝 Standards Compliance

### Documentation Standards

- [x] **AGENTS.md Schema**: All component AGENTS.md files follow unified 8-section structure
- [x] **Hierarchical Documentation**: Proper cross-referencing between root, component, and instruction files
- [x] **Markdown Standards**: Consistent formatting, heading hierarchy, and content organization
- [x] **Technology Instructions**: Comprehensive platform-specific development guidelines
- [x] **Component Tracking**: Detailed implementation status and roadmap documentation

### Development Standards

#### Backend Compliance (Go)

- [x] **MVC Architecture**: Clean separation of controllers, models, services, repositories, views
- [x] **Code Quality**: golangci-lint integration with comprehensive rule sets
- [x] **Security Scanning**: gosec vulnerability analysis and remediation
- [x] **Testing Standards**: Unit tests, integration tests, coverage reporting
- [x] **API Design**: RESTful endpoints, consistent error handling, proper HTTP status codes
- [x] **Database Integration**: PostgreSQL + pgvector with proper indexing and transactions

#### Frontend Compliance (TypeScript/React)

- [x] **Component Architecture**: Functional components with hooks, proper TypeScript typing
- [x] **Code Quality**: ESLint integration with React and TypeScript rule sets
- [x] **Build Process**: Vite bundling, asset optimization, cross-platform compatibility
- [x] **API Integration**: Type-safe client with proper error handling
- [ ] **Testing Implementation**: Jest/Vitest unit tests (planned implementation)
- [ ] **Accessibility Standards**: WCAG compliance and semantic HTML (in progress)

#### Scripts Compliance (PowerShell/Bash)

- [x] **Cross-Platform Pairs**: Every .ps1 script has corresponding .sh version
- [x] **Parameter Standards**: Consistent -VerboseOutput, -SkipInstall, -Config, -Help parameters
- [x] **Error Handling**: Comprehensive error checking and graceful degradation
- [x] **Output Functions**: Standardized color-coded status messages
- [x] **Tool Management**: Automated installation and version compatibility checking
- [x] **Documentation**: Comprehensive help text and usage examples

### Quality Assurance

#### Code Quality Metrics

- [x] **Backend Linting**: golangci-lint with comprehensive rule coverage
- [x] **Frontend Linting**: ESLint with TypeScript and React-specific rules
- [x] **Security Scanning**: gosec for Go security vulnerability detection
- [x] **Dependency Management**: Automated updates via Dependabot
- [x] **Cross-Platform Testing**: Validation on Windows, Linux, macOS

#### Testing Standards

- [x] **Backend Testing**: Go unit tests with coverage reporting
- [x] **Integration Testing**: API endpoint validation and database integration
- [x] **Script Testing**: Cross-platform functionality validation
- [ ] **Frontend Testing**: React component testing (implementation pending)
- [ ] **End-to-End Testing**: Full application workflow validation (planned)

### Security & Compliance

#### Security Standards

- [x] **Input Validation**: Comprehensive validation across all input vectors
- [x] **SQL Injection Prevention**: Parameterized queries throughout data layer
- [x] **Error Handling**: Secure error messages without information leakage
- [x] **File Path Validation**: Security-focused path handling and traversal prevention
- [x] **Dependency Scanning**: Regular vulnerability assessment of dependencies

#### Audit & Governance

- [x] **Blockchain Audit Trail**: Immutable change tracking for all resource operations
- [x] **Configuration Management**: Secure credential handling and environment separation
- [x] **Access Control**: Role-based access patterns and authorization frameworks
- [ ] **Compliance Reporting**: Automated compliance validation (planned enhancement)

### Remaining Compliance Tasks

#### High Priority

- [ ] **Frontend Testing**: Complete Jest/Vitest implementation for component testing
- [ ] **API Documentation**: Automated OpenAPI/Swagger documentation generation
- [ ] **Performance Monitoring**: Application performance metrics and alerting
- [ ] **Accessibility Compliance**: WCAG 2.1 AA compliance validation

#### Medium Priority

- [ ] **Configuration Validation**: Centralized configuration schema validation
- [ ] **Logging Standards**: Structured logging with correlation IDs across all components
- [ ] **Error Recovery**: Enhanced error recovery and retry mechanisms
- [ ] **Documentation Automation**: Automated documentation updates and synchronization

#### Long-Term

- [ ] **Enterprise Security**: Advanced authentication, authorization, and audit capabilities
- [ ] **Compliance Frameworks**: SOC 2, ISO 27001, and other enterprise compliance standards
- [ ] **Multi-Environment**: Production-ready deployment with staging and development environments
- [ ] **Scalability Standards**: Load testing and performance optimization for enterprise scale

## 🐛 Known Issues & Workarounds

### Known Integration Issues

1. **Windows Development Environment**
   - **Issue**: npm execution issues in some PowerShell environments
   - **Component**: Frontend + Scripts
   - **Workaround**: Use VS Code integrated terminal
   - **Priority**: Low (environment-specific)

2. **Resource Relationship Performance**
   - **Issue**: Vector similarity queries slow with >10k resources
   - **Component**: Backend + Database
   - **Workaround**: Implement pagination
   - **Priority**: High (scalability concern)

### Technical Debt Tracking

- [ ] **Configuration Management**: Centralized configuration system
- [ ] **Error Handling**: Consistent error handling patterns across all components
- [ ] **Logging**: Structured logging with correlation IDs
- [ ] **Testing**: Automated integration testing pipeline
- [ ] **Documentation**: Automated documentation generation

## 📚 Related Documentation

### Core Documentation

- **[GitHub Copilot Instructions](.github/copilot-instructions.md)**: Project context for AI assistance
- **[Contributing Guidelines](.github/CONTRIBUTING.md)**: Development workflow and standards
- **[Architecture Overview](docs/MVC_IMPLEMENTATION_SUMMARY.md)**: Technical architecture documentation

### Technology-Specific Instructions

- **[Go Backend Instructions](.github/instructions/go.instructions.md)**: Backend development standards
- **[TypeScript Instructions](.github/instructions/typescript.instructions.md)**: Frontend development standards
- **[Scripts Instructions](.github/instructions/scripts.instructions.md)**: Automation and tooling standards
- **[Markdown Instructions](.github/instructions/markdown.instructions.md)**: Documentation writing standards

### Component Tracking

- **[Backend AGENTS.md](backend/AGENTS.md)**: Go backend development tracking
- **[Frontend AGENTS.md](frontend/AGENTS.md)**: React/TypeScript frontend tracking
- **[Scripts AGENTS.md](scripts/AGENTS.md)**: Build automation tracking

## 🤝 Contributing

### Getting Started

1. **Read Instructions**: Start with [copilot-instructions.md](.github/copilot-instructions.md)
2. **Choose Component**: Select backend, frontend, or infrastructure work
3. **Follow Standards**: Use appropriate technology-specific instruction files
4. **Update Tracking**: Update relevant AGENTS.md files with progress
5. **Cross-Reference**: Ensure changes work across all integrated components

### Development Workflow

1. **Local Setup**: Use `scripts/env_dev.ps1` or `scripts/env_dev.sh`
2. **Testing**: Run component-specific tests via `scripts/test_*.ps1/sh`
3. **Quality Checks**: Use `scripts/lint.ps1/sh` before committing
4. **Documentation**: Update AGENTS.md files with significant changes
5. **Integration**: Test cross-component functionality

### AI Agent Guidance

This documentation structure is designed for AI agents to:

- **Navigate efficiently** through hierarchical documentation
- **Find specific guidance** via technology-specific instruction files
- **Track component status** through AGENTS.md files
- **Maintain consistency** across all development activities
- **Coordinate changes** across integrated components

---

_Last Updated: October 15, 2025 - This document serves as the master coordination point for all Siros development activities_
