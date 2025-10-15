# Siros Script Architecture & Development Tracking

This document provides a comprehensive overview of the Siros project's script architecture, implementation status, and future enhancements.

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
- **Scripts Instructions**: [scripts.instructions.md](../.github/instructions/scripts.instructions.md) - Script development standards, cross-platform compatibility, parameter conventions

## 📁 Scripts Inventory

### Root Level Scripts

| File/Folder              | Purpose                                                      | Status     |
| ------------------------ | ------------------------------------------------------------ | ---------- |
| **build.ps1/sh**         | Complete production build orchestration (frontend + backend) | ✅ Complete |
| **env_dev.ps1/sh**       | Development environment orchestration (concurrent servers)   | ✅ Complete |
| **test_apis.ps1/sh**     | Comprehensive API testing with cURL                          | ✅ Complete |
| **test_backend.ps1/sh**  | Backend-specific testing orchestration                       | ✅ Complete |
| **test_frontend.ps1/sh** | Frontend-specific testing orchestration                      | ✅ Complete |
| **docs_backend.ps1/sh**  | Backend call graph visualization generation                  | ✅ Complete |
| **docs_frontend.ps1/sh** | Call graph artifact cleanup                                  | ✅ Complete |
| **init.sql**             | PostgreSQL database initialization script                    | ✅ Complete |
| **backend/**             | Backend-specific component scripts                           | 📂 Directory |
| **frontend/**            | Frontend-specific component scripts                          | 📂 Directory |
| **postgres/**            | Database-related scripts and utilities                       | 📂 Directory |

### Component Scripts (Subdirectories)

#### Backend Component Scripts (`backend/`)

| File | Purpose | Status |
|------|---------|--------|
| **backend_build.ps1/sh** | Go compilation with asset embedding | ✅ Complete |
| **backend_gotest.ps1/sh** | Go test execution with coverage | ✅ Complete |
| **backend_lint.ps1/sh** | golangci-lint code quality analysis | ✅ Complete |
| **backend_gosec.ps1/sh** | gosec security vulnerability scanning | ✅ Complete |
| **backend_callgraph.ps1/sh** | Backend call graph generation | ✅ Complete |
| **placeholder-index.html** | Placeholder file for static assets | ✅ Complete |

#### Frontend Component Scripts (`frontend/`)

| File | Purpose | Status |
|------|---------|--------|
| **frontend_build.ps1/sh** | React/TypeScript build with Vite | ✅ Complete |
| **frontend_lint.ps1/sh** | ESLint code quality analysis | ✅ Complete |
| **frontend_test.ps1/sh** | Jest/Vitest unit test execution | ❌ Not Implemented |
| **frontend_typecheck.ps1/sh** | TypeScript compilation verification | ❌ Not Implemented |

#### Database Scripts (`postgres/`)

| File | Purpose | Status |
|------|---------|--------|
| **init.sql** | PostgreSQL schema and pgvector extension setup | ✅ Complete |

### Script Architecture Standards

- **Cross-Platform Pairs**: Every .ps1 script has corresponding .sh version
- **Parameter Consistency**: Common -VerboseOutput, -SkipInstall, -Config, -Help parameters
- **Orchestration Pattern**: Utility scripts call component scripts in logical sequence
- **Error Handling**: Comprehensive error tracking and graceful degradation
- **Path Resolution**: Proper cross-platform path handling and working directory management

## 🏗️ Architecture Overview

The Siros project uses a **modular script architecture** with clear separation between utility (orchestration) and component (implementation) scripts:

### 🎯 Utility Scripts (Orchestration Level)

Located in `/scripts/` root directory - these scripts orchestrate multiple component operations:

- **Purpose**: Coordinate complex workflows across multiple tools and components
- **Location**: `/scripts/*.ps1` and `/scripts/*.sh`
- **Pattern**: Call component scripts in logical sequence with proper error handling
- **Cross-Platform**: Both PowerShell (.ps1) and Bash (.sh) versions maintained

### 🔧 Component Scripts (Implementation Level)

Located in `/scripts/{component}/` subdirectories - these scripts perform specific operations:

- **Purpose**: Execute specialized tasks (testing, linting, building, security scanning)
- **Location**: `/scripts/backend/`, `/scripts/frontend/`, `/scripts/postgres/`
- **Pattern**: Focus on single responsibility with tool-specific logic
- **Cross-Platform**: Both PowerShell (.ps1) and Bash (.sh) versions maintained

## 📚 Component Status Overview

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

### Cross-Component Coordination

#### Development Workflow Integration

| Workflow Stage | Backend Scripts | Frontend Scripts | Status |
|----------------|-----------------|------------------|---------|
| **Testing** | test_backend.ps1/sh | test_frontend.ps1/sh | ✅ Working |
| **Code Quality** | backend_lint.ps1/sh | frontend_lint.ps1/sh | ✅ Working |
| **Building** | backend_build.ps1/sh | frontend_build.ps1/sh | ✅ Working |
| **Development** | Individual component execution | Orchestrated via env_dev.ps1/sh | ✅ Working |

#### Script Integration Matrix

| Interface | Backend Implementation | Frontend Implementation | Status |
|-----------|----------------------|------------------------|---------|
| **Testing Orchestration** | Go test suites with coverage | ESLint + Future Jest/Vitest | ✅ Partial |
| **Build Automation** | Go compilation with embedding | Vite bundling and optimization | ✅ Complete |
| **Quality Assurance** | golangci-lint + gosec security | ESLint + TypeScript checking | ✅ Complete |
| **Development Environment** | Hot reload via go run | Vite dev server integration | ✅ Complete |

### 🧪 Backend Testing Scripts

#### Utility Script: `test_backend.ps1/sh`

**Status**: ✅ **COMPLETE & TESTED**

**Purpose**: Orchestrates comprehensive backend validation through three specialized components

**Orchestration Flow**:

1. `backend_gotest.ps1/sh` - Core functionality tests (unit/integration)
2. `backend_lint.ps1/sh` - Code quality analysis (golangci-lint)
3. `backend_gosec.ps1/sh` - Security vulnerability scan (gosec)

##### ✅ Implementation Checklist

- [x] PowerShell version with [CmdletBinding()] and VerboseOutput parameter
- [x] Bash version with equivalent functionality
- [x] Orchestration pattern calling component scripts in sequence
- [x] Parameter passing to component scripts
- [x] Error handling with overall success tracking
- [x] Missing component script detection with warnings
- [x] Cross-platform path resolution
- [x] Comprehensive help documentation
- [x] Testing completed successfully

#### 🚀 Future Enhancements

- [ ] Add performance benchmarking component
- [ ] Implement test result aggregation and reporting
- [ ] Add integration with CI/CD pipeline metrics
- [ ] Support for test parallelization
- [ ] Add database migration testing component
- [ ] Implement custom test suite filtering (beyond current models/services/controllers/repositories/integration)

#### Component Scripts Status

##### `backend/backend_gotest.ps1/sh`

**Status**: ✅ **COMPLETE & TESTED**

- [x] Go test execution with coverage support
- [x] Test suite selection (models, services, controllers, repositories, integration, all)
- [x] VerboseOutput parameter compliance
- [x] Coverage reporting with HTML output
- [x] Cross-platform compatibility

##### `backend/backend_lint.ps1/sh`

**Status**: ✅ **COMPLETE & TESTED**

- [x] golangci-lint integration with auto-install
- [x] Project root path resolution fixed
- [x] Configuration file detection (.golangci.yml)
- [x] VerboseOutput parameter compliance
- [x] SkipInstall parameter support

##### `backend/backend_gosec.ps1/sh`

**Status**: ✅ **COMPLETE & TESTED**

- [x] gosec security scanner integration
- [x] Auto-installation with correct package URL
- [x] Project root path resolution fixed
- [x] VerboseOutput parameter compliance
- [x] Comprehensive security reporting

### 🎨 Frontend Testing Scripts

#### Utility Script: `test_frontend.ps1/sh`

**Status**: ✅ **ORCHESTRATION COMPLETE** | ⚠️ **COMPONENTS PARTIAL**

**Purpose**: Orchestrates comprehensive frontend validation through specialized components

**Orchestration Flow**:

1. `frontend_lint.ps1/sh` - Code quality analysis (ESLint + TypeScript)
2. `frontend_test.ps1/sh` - Unit tests (Jest/Vitest)
3. `frontend_typecheck.ps1/sh` - TypeScript compilation verification

##### ✅ Implementation Checklist

- [x] PowerShell version with [CmdletBinding()] and VerboseOutput parameter
- [x] Bash version with equivalent functionality
- [x] Orchestration pattern calling component scripts in sequence
- [x] Parameter passing to component scripts
- [x] Error handling with overall success tracking
- [x] Missing component script detection with warnings
- [x] Cross-platform path resolution
- [x] Comprehensive help documentation
- [x] Testing completed successfully

#### 🚀 Future Enhancements

- [ ] Add component testing (React Testing Library)
- [ ] Implement visual regression testing
- [ ] Add accessibility testing component
- [ ] Support for E2E testing integration
- [ ] Add bundle analysis and optimization checks
- [ ] Implement dependency vulnerability scanning

#### Component Scripts Status

##### `frontend/frontend_lint.ps1/sh`

**Status**: ✅ **COMPLETE** | ⚠️ **NPM ENVIRONMENT ISSUE**

- [x] ESLint integration for TypeScript/React
- [x] Project root path resolution fixed
- [x] VerboseOutput parameter compliance
- [x] npm command execution
- ⚠️ Windows npm execution issue (environment-specific)

##### `frontend/frontend_test.ps1/sh`

**Status**: ❌ **NOT IMPLEMENTED**

- [ ] Jest/Vitest test runner integration
- [ ] Coverage reporting support
- [ ] Watch mode support
- [ ] Component testing setup
- [ ] Snapshot testing support

##### `frontend/frontend_typecheck.ps1/sh`

**Status**: ❌ **NOT IMPLEMENTED**

- [ ] TypeScript compiler integration
- [ ] Type checking without emission
- [ ] Error reporting and formatting
- [ ] Project configuration detection

### 🏗️ Build & Development Scripts

#### Build Scripts Status

##### `build_all.ps1/sh`

**Status**: ✅ **COMPLETE**

- [x] Frontend build orchestration
- [x] Backend build with embedded assets
- [x] Cross-platform compatibility
- [x] Error handling and cleanup

##### `backend/backend_build.ps1/sh`

**Status**: ✅ **COMPLETE**

- [x] Go compilation with proper flags
- [x] Static asset embedding
- [x] Cross-platform binary generation
- [x] Build artifact management

##### `frontend/frontend_build.ps1/sh`

**Status**: ✅ **COMPLETE**

- [x] Vite build integration
- [x] TypeScript compilation
- [x] Asset optimization
- [x] Output directory management

#### Development Scripts Status

##### `env_dev.ps1/sh` (formerly `dev.ps1/sh`)

**Status**: ✅ **COMPLETE**

- [x] Concurrent backend and frontend development servers
- [x] Hot reload support
- [x] Environment variable management
- [x] Port configuration

### 🛠️ Utility & Infrastructure Scripts

#### Code Quality Scripts

##### `lint.ps1/sh`

**Status**: ✅ **COMPLETE**

- [x] Backend and frontend linting orchestration
- [x] golangci-lint and ESLint integration
- [x] Error aggregation and reporting

#### Call Graph Generation

##### `generate-callgraph.ps1/sh`

**Status**: ✅ **COMPLETE**

- [x] go-callvis integration
- [x] Multiple visualization targets
- [x] SVG and Graphviz output
- [x] Documentation generation

##### `clean-callgraph.ps1/sh`

**Status**: ✅ **COMPLETE**

- [x] Generated file cleanup
- [x] Documentation removal
- [x] Artifact management

#### Database Scripts

##### `postgres/init.sql`

**Status**: ✅ **COMPLETE**

- [x] PostgreSQL schema initialization
- [x] pgvector extension setup
- [x] Required table creation

## 🎯 Cross-Component Coordination

This section documents the interdependencies between script components and other parts of the Siros project that require coordination when changes occur.

### Backend API Changes → Script Updates Required

When backend APIs are modified, the following scripts need updates:

#### API Testing Scripts

- **`test_apis.ps1/sh`**: Add new endpoint tests when APIs are added
- **Required Updates**: URL patterns, request/response validation, authentication headers
- **Coordination**: Backend controller changes should trigger API test script updates

#### Integration Testing

- **`backend/backend_gotest.ps1/sh`**: Integration test suite may need new test cases
- **Required Updates**: Test data fixtures, mock configurations, database schema changes
- **Coordination**: New service methods require corresponding integration tests

### Frontend Changes → Script Updates Required

When frontend components or build processes change:

#### Frontend Testing Scripts

- **`frontend/frontend_test.ps1/sh`** (when implemented): New component tests for added features
- **`frontend/frontend_typecheck.ps1/sh`** (when implemented): TypeScript configuration updates
- **Required Updates**: Test configurations, mock data, component test suites
- **Coordination**: New React components should have corresponding test scripts

#### Build Process Updates

- **`frontend/frontend_build.ps1/sh`**: Vite configuration changes, new build targets
- **`build_all.ps1/sh`**: Asset embedding updates when frontend structure changes
- **Required Updates**: Build flags, output directories, asset copying logic

### Database Schema Changes → Script Updates Required

When database schema or models change:

#### Database Scripts

- **`postgres/init.sql`**: Schema migrations, new tables, index updates
- **Required Updates**: CREATE statements, constraint definitions, pgvector configurations
- **Coordination**: Backend model changes must be reflected in database initialization

#### Backend Testing

- **`backend/backend_gotest.ps1/sh`**: Test fixtures for new schema elements
- **Required Updates**: Migration testing, model validation tests
- **Coordination**: Repository layer changes require database test updates

### Go Module Dependencies → Script Updates Required

When Go dependencies change:

#### Tool Management

- **All backend scripts**: golangci-lint, gosec, go-callvis version compatibility
- **Required Updates**: Tool installation URLs, version pinning, configuration files
- **Coordination**: New linting rules may require script configuration updates

#### Build Process

- **`backend/backend_build.ps1/sh`**: Go build flags, CGO settings, compilation targets
- **Required Updates**: Build constraints, module paths, embed directives

### Security & Quality Standards → Script Updates Required

When security or quality requirements change:

#### Security Scanning

- **`backend/backend_gosec.ps1/sh`**: New security rules, exclusion patterns
- **Required Updates**: gosec configuration, severity thresholds, report formats
- **Coordination**: Security policy changes require script rule updates

#### Code Quality

- **`backend/backend_lint.ps1/sh`**: golangci-lint configuration updates
- **`frontend/frontend_lint.ps1/sh`**: ESLint rule changes, TypeScript strict mode
- **Required Updates**: Linting rules, exclusion patterns, error thresholds

### Cloud Provider Integration → Script Updates Required

When cloud provider SDKs or configurations change:

#### Testing Requirements

- **`test_apis.ps1/sh`**: New cloud provider endpoint testing
- **`backend/backend_gotest.ps1/sh`**: Provider-specific integration tests
- **Required Updates**: Mock configurations, credential management, endpoint URLs

#### Build Dependencies

- **`backend/backend_build.ps1/sh`**: New SDK dependencies, build tags
- **Required Updates**: Conditional compilation, provider-specific build flags

### Development Environment → Script Updates Required

When development tooling changes:

#### Development Scripts

- **`env_dev.ps1/sh`**: Port changes, environment variables, service dependencies
- **Required Updates**: Service startup order, health checks, configuration files
- **Coordination**: New services require development script integration

#### VS Code Integration

- **Task Definitions**: VS Code tasks.json updates for new script patterns
- **Required Updates**: Task labels, command paths, dependency chains
- **Coordination**: New scripts should have corresponding VS Code tasks

### Documentation Standards → Script Updates Required

When documentation requirements change:

#### Call Graph Generation

- **`generate-callgraph.ps1/sh`**: New visualization targets, documentation formats
- **Required Updates**: Output formats, target functions, documentation templates
- **Coordination**: Architecture changes require call graph script updates

#### Help Documentation

- **All scripts**: Standardized help text, parameter documentation
- **Required Updates**: Help format consistency, example updates, parameter descriptions
- **Coordination**: New parameters require help text updates across all scripts

### CI/CD Pipeline → Script Updates Required

When CI/CD requirements change:

#### Automation Scripts

- **All utility scripts**: Exit codes, output formatting, error handling
- **Required Updates**: Machine-readable output, pipeline integration points
- **Coordination**: CI/CD changes require script automation compatibility

#### Reporting Integration

- **Test scripts**: Coverage reporting, test result formats
- **Required Updates**: Report generation, artifact uploading, metric collection
- **Coordination**: New CI/CD tools require script output format updates

### Coordination Checklist

When making changes to other components, review this checklist:

- [ ] **Backend API Changes**: Update test_apis.ps1/sh with new endpoints
- [ ] **Frontend Components**: Plan for frontend_test.ps1/sh implementation
- [ ] **Database Schema**: Update postgres/init.sql and test fixtures
- [ ] **Dependencies**: Check tool compatibility in backend scripts
- [ ] **Security Rules**: Update gosec and linting configurations
- [ ] **Cloud Providers**: Add provider-specific testing requirements
- [ ] **Development Setup**: Update env_dev.ps1/sh for new services
- [ ] **Documentation**: Update help text and call graph targets
- [ ] **CI/CD Integration**: Verify script automation compatibility

---

## 🔄 Feature Roadmap

### 🔄 Phase 1: Core Orchestration (COMPLETE)

- [x] Modular script architecture implementation
- [x] Backend test orchestration (test_backend.ps1/sh)
- [x] Frontend test orchestration (test_frontend.ps1/sh)
- [x] Cross-platform compatibility
- [x] Parameter standardization (VerboseOutput pattern)
- [x] Path resolution fixes
- [x] Component script auto-discovery

### 🚀 Phase 2: Enhanced Testing (IN PROGRESS)

- [ ] **Frontend Unit Testing**: Implement Jest/Vitest integration
- [ ] **Frontend Type Checking**: TypeScript compilation verification
- [ ] **Component Testing**: React Testing Library integration
- [ ] **E2E Testing**: Playwright/Cypress integration
- [ ] **Visual Regression**: Screenshot-based testing
- [ ] **Accessibility Testing**: axe-core integration

### 🔒 Phase 3: Security & Quality (PLANNED)

- [ ] **Dependency Scanning**: npm audit and Go vulnerability scanning
- [ ] **License Compliance**: License compatibility checking
- [ ] **Code Coverage**: Enhanced coverage reporting with thresholds
- [ ] **Performance Testing**: Load testing and benchmarking
- [ ] **Static Analysis**: Advanced code quality metrics
- [ ] **Container Security**: Docker image vulnerability scanning

### 📊 Phase 4: Reporting & CI/CD (PLANNED)

- [ ] **Test Results Aggregation**: Unified reporting across all test types
- [ ] **Metrics Dashboard**: Test metrics and trends visualization
- [ ] **CI/CD Integration**: GitHub Actions workflow optimization
- [ ] **Notification System**: Slack/Teams integration for test results
- [ ] **Quality Gates**: Automated pass/fail criteria
- [ ] **Historical Tracking**: Test result history and trends

### 🔧 Phase 5: Developer Experience (PLANNED)

- [ ] **Interactive Mode**: Watch mode for continuous testing
- [ ] **IDE Integration**: Enhanced VS Code task integration
- [ ] **Script Generator**: Automated script creation for new components
- [ ] **Configuration Management**: Centralized script configuration
- [ ] **Documentation Generator**: Auto-generated script documentation
- [ ] **Performance Profiling**: Script execution time optimization

### 📈 Long-Term Vision & Roadmap

#### Short-Term Goals (Next 2-4 weeks)

- [ ] Complete frontend testing script implementation (Jest/Vitest)
- [ ] Implement TypeScript type checking scripts
- [ ] Enhanced script performance optimization
- [ ] Complete script documentation updates

#### Medium-Term Goals (Next 2-3 months)

- [ ] Advanced testing orchestration with parallel execution
- [ ] Enhanced CI/CD integration and reporting
- [ ] Script-based deployment automation
- [ ] Real-time development environment monitoring

#### Long-Term Vision (6+ months)

- [ ] AI-powered script generation and optimization
- [ ] Advanced development workflow automation
- [ ] Enterprise-grade script security and compliance
- [ ] Open-source script architecture adoption

---

## 📝 Standards Compliance

### Script Instructions Compliance Status

- [x] **VerboseOutput Parameter**: All scripts updated to avoid PowerShell conflicts
- [x] **Cross-Platform Pairs**: All utility scripts have both .ps1 and .sh versions
- [x] **Help Documentation**: Comprehensive help text for all utility scripts
- [x] **Error Handling**: Consistent error handling patterns
- [x] **Output Functions**: Standardized color-coded output functions
- [x] **Parameter Standards**: Common parameters across all scripts
- [x] **Path Resolution**: Proper cross-platform path handling

### Remaining Compliance Tasks

- [ ] **Component Script Help**: Add comprehensive help to all component scripts
- [ ] **Error Code Standardization**: Consistent exit codes across all scripts
- [ ] **Logging Enhancement**: Structured logging for better debugging
- [ ] **Configuration Validation**: Input validation for all script parameters
- [ ] **Tool Version Management**: Automated tool version compatibility checking

---

## 🐛 Known Issues & Workarounds

### Current Issues

1. **Windows npm Execution**: Frontend linting encounters npm execution issues in some Windows environments
   - **Workaround**: Run from PowerShell with proper PATH configuration
   - **Status**: Environment-specific, not script architecture issue

2. **WSL Go Availability**: Bash scripts fail in WSL environments without Go
   - **Workaround**: Install Go in WSL or use PowerShell versions on Windows
   - **Status**: Expected behavior, not a bug

3. **Component Script Discovery**: Missing component scripts generate warnings but don't fail orchestration
   - **Status**: Intentional design for graceful degradation
   - **Action**: Implement missing component scripts as needed

### Technical Debt

- [ ] **Script Testing**: Automated testing for script functionality
- [ ] **Configuration Management**: Centralized configuration system
- [ ] **Error Recovery**: Enhanced error recovery and retry mechanisms
- [ ] **Performance Optimization**: Script execution time optimization
- [ ] **Documentation Sync**: Automated documentation updates

---

## 📚 Related Documentation

- **[Script Instructions](../github/instructions/scripts.instructions.md)**: Comprehensive development standards
- **[SCRIPTS.md](./SCRIPTS.md)**: Script usage documentation
- **[MVC Implementation](../docs/MVC_IMPLEMENTATION_SUMMARY.md)**: Architecture overview
- **[Call Graph Documentation](../docs/CALL_GRAPH.md)**: Backend visualization guide

---

## 🤝 Contributing

When adding new scripts or modifying existing ones:

1. **Follow Standards**: Refer to script instructions for compliance guidelines
2. **Update Documentation**: Update this AGENTS.md file with changes
3. **Cross-Platform**: Ensure both PowerShell and Bash versions
4. **Test Thoroughly**: Validate on multiple platforms
5. **Update Checklists**: Mark completed features and add new ones

---

*Last Updated: $(date +'%Y-%m-%d') - Keep this document current as the script architecture evolves*
