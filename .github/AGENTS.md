---
applyTo: '.github/**'
---

# Siros GitHub Configuration & CI/CD Tracking

This document provides comprehensive tracking for GitHub configuration, CI/CD workflows, and repository management for the Siros multi-cloud resource management platform.

## 📋 Documentation References

The Siros project uses a hierarchical documentation structure for comprehensive development guidance:

```
AGENTS.md (root)                            ← Master tracking & entry point
├── .github/copilot-instructions.md         ← GitHub Copilot project context
├── .github/instructions/*.instructions.md  ← Technology-specific development standards
└── */AGENTS.md                             ← Component-specific tracking documents
```

### 🎯 Documentation Purpose

- **Root AGENTS.md**: Master project tracking, component status overview, cross-component coordination
- **copilot-instructions.md**: GitHub Copilot context and instruction file navigation
- **\*.instructions.md**: Technology-specific development standards and implementation patterns
- **Component AGENTS.md**: Detailed tracking for specific subsystems and components
- **GitHub Instructions**: [github.instructions.md](instructions/github.instructions.md) - GitHub workflow automation, repository configuration, security practices

## 📁 Github Inventory

### GitHub Configuration Files

| File/Folder | Purpose | Status |
|-------------|---------|--------|
| **AGENTS.md** | GitHub component tracking and CI/CD coordination | ✅ Complete |
| **copilot-instructions.md** | GitHub Copilot project context and navigation | ✅ Complete |
| **CONTRIBUTING.md** | Contribution guidelines and development workflow | ✅ Complete |
| **dependabot.yml** | Dependency update automation configuration | ✅ Complete |
| **instructions/** | Technology-specific development guidelines | 📂 Directory |
| **workflows/** | GitHub Actions CI/CD automation | 📂 Directory |
| **ISSUE_TEMPLATE/** | Issue templates for bug reports and features | 📂 Directory |
| **PULL_REQUEST_TEMPLATE.md** | Pull request template | ✅ Complete |

### GitHub Actions Workflows (`workflows/`)

| File | Purpose | Status |
|------|---------|--------|
| **ci-cd.yml** | Comprehensive CI/CD pipeline with testing, building, security scanning | ✅ Complete |
| **release.yml** | Cross-platform release automation for multiple architectures | ✅ Complete |
| **dependabot-auto-merge.yml** | Automated dependency update merging | ✅ Complete |

### Issue Templates (`ISSUE_TEMPLATE/`)

| File | Purpose | Status |
|------|---------|--------|
| **bug_report.yml** | Structured bug report template with validation | ✅ Complete |
| **feature_request.yml** | Feature request template with priority assessment | ✅ Complete |

### Instruction Files (`instructions/`)

| File | Purpose | Status |
|------|---------|--------|
| **github.instructions.md** | GitHub workflow and CI/CD configuration standards | ✅ Complete |
| **go.instructions.md** | Go backend development guidelines | ✅ Complete |
| **typescript.instructions.md** | React/TypeScript frontend development standards | ✅ Complete |
| **scripts.instructions.md** | Script development and automation standards | ✅ Complete |
| **powershell.instructions.md** | PowerShell-specific development standards | ✅ Complete |
| **bash.instructions.md** | Bash-specific development standards | ✅ Complete |
| **markdown.instructions.md** | Documentation writing standards | ✅ Complete |
| **vscode.instructions.md** | VS Code workspace configuration standards | ✅ Complete |

## 🏗️ Architecture Overview

The GitHub component provides comprehensive repository management, CI/CD automation, and collaborative development infrastructure for the Siros platform:

### Core Responsibilities

- **CI/CD Pipeline**: Automated testing, building, security scanning, and deployment
- **Repository Configuration**: Branch protection, security settings, collaboration workflows
- **Issue Management**: Structured templates for bug reports and feature requests
- **Dependency Management**: Automated updates via Dependabot with security scanning
- **Documentation Standards**: Technology-specific development guidelines
- **Security Integration**: Code scanning, vulnerability assessment, secret detection

### GitHub Actions Architecture

```
CI/CD Pipeline (ci-cd.yml)
├── Backend Testing (backend-test)
│   ├── PostgreSQL service integration
│   ├── Go test execution with coverage
│   └── golangci-lint code quality analysis
├── Frontend Testing (frontend-test)
│   ├── Node.js setup with npm caching
│   ├── ESLint and TypeScript validation
│   └── React component testing
├── Build Integration (build-test)
│   ├── Frontend build with Vite
│   ├── Backend compilation with asset embedding
│   └── Binary execution validation
├── Security Scanning (security-scan)
│   ├── Trivy vulnerability scanner
│   ├── Gosec Go security analysis
│   └── SARIF results upload to GitHub Security
└── Docker & Release (docker, release)
    ├── Multi-platform container builds
    ├── GitHub Container Registry publishing
    └── Cross-platform binary releases
```

### GitHub Automation Infrastructure

**Status**: 🔄 **IN PROGRESS**
**Lead Technology**: GitHub Actions, Semantic Release, Repository API

#### Planned Automation Components

##### Semantic Versioning & Release Management

- [ ] **Conventional Commits**: Enforce conventional commit format for automated versioning
- [ ] **Semantic Release**: Automated version calculation, changelog generation, and release creation
- [ ] **Release Assets**: Automated binary compilation and asset attachment for releases
- [ ] **Cross-Platform Releases**: Windows, Linux, macOS binaries with checksums
- [ ] **GitHub Releases**: Automated release notes with breaking changes and feature summaries

##### Repository Configuration Automation

- [ ] **Security Settings API**: Programmatic configuration using GitHub REST API
- [ ] **Branch Protection Rules**: Automated setup of protection rules with required checks
- [ ] **Repository Settings**: Consistent configuration across repositories and environments
- [ ] **Team Permissions**: Automated team-based access control and repository permissions
- [ ] **Webhook Configuration**: Automated webhook setup for external integrations

##### Dependabot Enhancement

- [ ] **Auto-Merge Workflows**: Merge dependency PRs automatically when tests pass
- [ ] **Security-First Updates**: Prioritize security updates over feature updates
- [ ] **Custom Update Schedules**: Environment-specific dependency update timing
- [ ] **Grouped Updates**: Logical grouping of related dependency updates
- [ ] **Update Validation**: Enhanced testing before auto-merge approval

#### Implementation Strategy

**Phase 2A: Core Automation (Next Sprint)**

1. **Semantic Release Setup**: Configure semantic-release with conventional commits
2. **Basic Auto-Merge**: Simple Dependabot auto-merge for patch updates
3. **Repository API Scripts**: Basic repository configuration scripts

**Phase 2B: Advanced Automation (Following Sprint)**

1. **Security Configuration**: Complete repository security automation
2. **Enhanced Branch Protection**: Complex branch protection with team reviews
3. **Release Strategy**: Multi-environment release workflows

## 📚 Component Status Overview

### GitHub Workflows

**Status**: ✅ **COMPLETE**
**Lead Technology**: GitHub Actions, Docker, Security Scanning

#### Implemented Features

- [x] Comprehensive CI/CD pipeline with job orchestration
- [x] Built-in Go module caching with cache-dependency-path optimization
- [x] Multi-platform support (Linux, macOS, Windows)
- [x] Security scanning integration (Trivy, Gosec, CodeQL)
- [x] Automated dependency management via Dependabot
- [x] Cross-platform release automation
- [x] Container registry integration
- [x] SARIF security results upload

#### Key Features & Improvements

**Built-in Go Module Caching:**

- Uses `actions/setup-go@v6` with `cache-dependency-path: backend/go.sum`
- Eliminates manual `actions/cache` steps for Go modules
- Automatic cache invalidation based on dependency changes
- Optimized for monorepo structure with backend subdirectory

**Security Scanning Integration:**

- **Trivy** for filesystem vulnerability scanning with SARIF output
- **Gosec** using official `securego/gosec@master` action for Go security analysis
- **golangci-lint** for comprehensive code quality checks
- Results uploaded to GitHub Security tab for centralized monitoring

**Multi-Platform Support:**

- Cross-platform release builds (Linux, macOS, Windows)
- ARM64 and AMD64 architecture support
- Embedded frontend assets in Go binaries
- Container images for multiple architectures

**Monorepo Optimization:**

- Proper `working-directory` configuration for frontend and backend
- Dependency path configuration for npm and Go module caching
- Coordinated build process with frontend asset embedding

### Repository Configuration

**Status**: ✅ **COMPLETE**
**Lead Technology**: GitHub Repository Settings, Branch Protection, Security

#### Implemented Features

- [x] Branch protection rules with required status checks
- [x] Code owners configuration (CODEOWNERS)
- [x] Issue and pull request templates
- [x] Dependabot configuration for automated updates
- [x] Security policy and vulnerability reporting
- [x] Repository settings optimization

#### Security & Compliance

- [x] **Vulnerability Alerts**: Enabled for dependency scanning
- [x] **Dependency Security Updates**: Automated security patches
- [x] **Code Scanning**: CodeQL and Trivy integration
- [x] **Secret Scanning**: Push protection enabled
- [x] **SARIF Upload**: Security results in GitHub Security tab

### Documentation System

**Status**: ✅ **COMPLETE**
**Lead Technology**: Markdown, Technology-Specific Instructions

#### Implemented Features

- [x] Hierarchical documentation architecture
- [x] Technology-specific instruction files
- [x] Component-specific AGENTS.md tracking
- [x] Cross-referencing between documentation levels
- [x] Comprehensive development guidelines

## 🎯 Cross-Component Coordination

### CI/CD Integration Requirements

When other components are updated, the following GitHub workflows require coordination:

#### Backend Changes → Workflow Updates

**Go Module Dependencies:**

- **ci-cd.yml**: Update Go version when backend dependencies change
- **release.yml**: Verify cross-platform compilation compatibility
- **Required Updates**: Go version matrix, build flags, compilation targets

**API Changes:**

- **Security Scanning**: Update gosec rules for new API endpoints
- **Integration Tests**: Add new endpoint testing to CI pipeline
- **Required Updates**: Test data fixtures, security configurations

#### Frontend Changes → Workflow Updates

**Node.js Dependencies:**

- **ci-cd.yml**: Update Node.js version for frontend compatibility
- **Dependency Caching**: Update package-lock.json cache keys
- **Required Updates**: npm version, build configurations, asset handling

**Build Process:**

- **Asset Embedding**: Update frontend build artifact handling
- **Container Images**: Update Dockerfile for new frontend dependencies
- **Required Updates**: Vite configuration, build optimization flags

#### Script Changes → Workflow Updates

**Testing Orchestration:**

- **Task Integration**: Update workflow to use script orchestration patterns
- **Cross-Platform**: Ensure workflows work with both .ps1 and .sh scripts
- **Required Updates**: Script paths, parameter passing, error handling

#### Database Changes → Workflow Updates

**PostgreSQL Services:**

- **Service Configuration**: Update PostgreSQL version and extensions
- **Migration Testing**: Add database migration validation
- **Required Updates**: Service definitions, connection strings, test data

### Documentation Coordination Requirements

When instruction files are updated, coordinate with:

#### Component AGENTS.md Files

- **Backend AGENTS.md**: Go instruction updates
- **Frontend AGENTS.md**: TypeScript instruction updates
- **Scripts AGENTS.md**: Script instruction updates
- **Required Updates**: Cross-references, status tracking, compliance checklists

#### VS Code Configuration

- **Tasks Integration**: Update tasks.json when script instructions change
- **Extension Recommendations**: Update when development tools change
- **Required Updates**: Task definitions, workspace settings, debug configurations

### Security & Compliance Coordination

When security requirements change:

#### Workflow Security Updates

- **Gosec Configuration**: Update security rules and exclusions
- **Trivy Scanning**: Update vulnerability thresholds and reporting
- **Required Updates**: Security configurations, SARIF upload settings

#### Repository Security

- **Branch Protection**: Update required status checks
- **Code Owners**: Update ownership patterns for new components
- **Required Updates**: Protection rules, review requirements, access controls

### Repository Automation Requirements

When implementing GitHub automation features:

#### Semantic Versioning Integration

**Conventional Commits Enforcement:**

- **Commit Lint**: GitHub Action to validate commit message format
- **PR Title Validation**: Ensure PR titles follow conventional commit format
- **Required Updates**: commitlint configuration, semantic-release config

**Release Automation:**

- **Semantic Release**: Automated version calculation and changelog generation
- **Asset Management**: Cross-platform binary compilation and upload
- **Required Updates**: Release workflow triggers, asset build scripts

#### Repository Configuration Automation

**GitHub API Integration:**

- **Repository Settings**: Programmatic security and branch protection setup
- **Team Management**: Automated team-based access control
- **Required Updates**: API tokens, configuration templates, validation scripts

**Security Policy Automation:**

- **Security Settings**: Automated vulnerability scanning and secret detection configuration
- **Compliance Validation**: Automated compliance checking and reporting
- **Required Updates**: Security policy templates, validation workflows

#### Dependabot Enhancement Requirements

**Auto-Merge Configuration:**

- **Test Validation**: Enhanced testing before automatic merge approval
- **Security Prioritization**: Security updates processed with higher priority
- **Required Updates**: Dependabot config, auto-merge workflows, test thresholds

**Dependency Management:**

- **Update Grouping**: Logical grouping of related dependency updates
- **Schedule Optimization**: Environment-specific update timing and frequency
- **Required Updates**: Grouping rules, schedule configurations, notification settings

## 🔄 Feature Roadmap

### 🔄 Phase 1: Core CI/CD (COMPLETE)

- [x] Comprehensive CI/CD pipeline implementation
- [x] Multi-platform testing and building
- [x] Security scanning integration
- [x] Dependency management automation
- [x] Built-in caching optimization
- [x] Cross-platform release automation

### 🚀 Phase 2: Enhanced Automation (IN PROGRESS)

- [ ] **Performance Testing**: Add performance benchmarking to CI pipeline
- [ ] **End-to-End Testing**: Integrate E2E testing with real services
- [ ] **Deployment Automation**: Production deployment workflows
- [ ] **Quality Gates**: Automated quality thresholds and gates
- [ ] **Notification Integration**: Slack/Teams notifications for build results
- [ ] **Advanced Security**: Enhanced security scanning and compliance checks
- [ ] **Auto-Kanban Workflow**: Develop workflow similar to auto-label that automatically opens tickets under a Kanban board for implementation issues, extracting tasks from AGENTS.md files and placing them in GitHub Projects
- [ ] **Semantic Versioning Automation**: Implement conventional commits and automated semantic versioning with release note generation using semantic-release or similar tools
- [ ] **Release Management Automation**: Automated release workflows with changelog generation, asset uploading, and cross-platform binary distribution
- [ ] **Repository Security Configuration**: Programmatic configuration of GitHub repository security settings including secret scanning, vulnerability alerts, and security policies
- [ ] **Branch Protection Automation**: Automated setup and maintenance of branch protection rules with required status checks and review requirements
- [ ] **Dependabot Auto-Merge**: Enhanced Dependabot configuration with automatic PR opening and merging when all tests pass and security checks are satisfied

### 🔒 Phase 3: Enterprise Features (PLANNED)

- [ ] **Multi-Environment**: Staging and production environment workflows
- [ ] **Compliance Automation**: SOC 2, ISO 27001 compliance validation
- [ ] **Advanced Monitoring**: Application performance monitoring integration
- [ ] **Disaster Recovery**: Backup and recovery automation
- [ ] **Audit Logging**: Enhanced audit trail and compliance reporting
- [ ] **Enterprise Security**: Advanced authentication and authorization
- [ ] **GitHub Repository Configuration API**: Programmatic repository setup using GitHub REST API for consistent security settings across repositories
- [ ] **Advanced Branch Protection**: Complex branch protection rules with required reviewers, status checks, and merge restrictions
- [ ] **Automated Security Policy Management**: Programmatic management of security policies, vulnerability disclosure, and incident response procedures
- [ ] **Dependabot Security Automation**: Advanced Dependabot configuration with security-first dependency updates and automatic vulnerability patching
- [ ] **Release Strategy Automation**: Multi-environment release strategies with canary deployments, rollback automation, and release validation

### 📊 Phase 4: Analytics & Optimization (PLANNED)

- [ ] **Metrics Dashboard**: CI/CD metrics and trends visualization
- [ ] **Cost Optimization**: Resource usage optimization and cost tracking
- [ ] **Performance Analytics**: Build time optimization and bottleneck analysis
- [ ] **Quality Metrics**: Code quality trends and improvement tracking
- [ ] **Security Analytics**: Security posture monitoring and reporting
- [ ] **Predictive Analytics**: Failure prediction and preventive measures

### 📚 Phase 5: Documentation & Standards Overhaul (PLANNED)

- [ ] **Instruction File Review & Refactoring**: Complete review and refactoring of all instruction files (remaining 80% after github.instructions.md completion)
  - [ ] **Go Instructions**: Review, cut, and refactor go.instructions.md for clarity and accuracy
  - [ ] **TypeScript Instructions**: Review, cut, and refactor typescript.instructions.md for modern practices
  - [ ] **Scripts Instructions**: Review, cut, and refactor scripts.instructions.md for cross-platform standards
  - [ ] **PowerShell Instructions**: Review, cut, and refactor powershell.instructions.md for best practices
  - [ ] **Bash Instructions**: Review, cut, and refactor bash.instructions.md for POSIX compliance
  - [ ] **Markdown Instructions**: Review, cut, and refactor markdown.instructions.md for documentation standards
  - [ ] **VS Code Instructions**: Review, cut, and refactor vscode.instructions.md for workspace optimization
- [ ] **CONTRIBUTING.md Updates**: Update contribution guidelines with latest script tasks and workflow developments
- [ ] **Copilot Instructions Enhancement**: Update copilot-instructions.md with latest MCP servers and available toolset integration to improve GitHub Copilot Chat utilization

### 📈 Long-Term Vision & Roadmap

#### Short-Term Goals (Next 2-4 weeks)

- [ ] **Fix CodeQL Workflows**: Debug and resolve CodeQL security analysis workflow issues
- [ ] **Test Docker & Release Pipelines**: Thoroughly test Docker build and release automation workflows
- [ ] **Complete Instruction File Reviews**: Begin systematic review of all instruction files starting with highest priority
- [ ] **Update CONTRIBUTING.md**: Add latest script tasks and workflow developments to contribution guidelines
- [ ] **Enhance Copilot Instructions**: Update with MCP servers and toolset integration information
- [ ] **Implement Semantic Versioning**: Set up conventional commits workflow and semantic-release automation for version management
- [ ] **Configure Repository Security**: Programmatically configure security settings, secret scanning, and vulnerability policies
- [ ] **Enhance Dependabot Configuration**: Set up automatic PR merging for dependency updates when tests pass

#### Medium-Term Goals (Next 2-3 months)

- [ ] Advanced quality gates and compliance automation
- [ ] Enhanced monitoring and alerting integration
- [ ] Multi-environment deployment workflows
- [ ] Enterprise-grade security features

#### Long-Term Vision (6+ months)

- [ ] AI-powered workflow optimization
- [ ] Advanced analytics and predictive capabilities
- [ ] Enterprise compliance and audit automation
- [ ] Open-source community workflow templates

## 📝 Standards Compliance

### GitHub Instructions Compliance Status

- [x] **CI/CD Pipeline**: Modern GitHub Actions with built-in optimizations
- [x] **Security Integration**: Comprehensive scanning with SARIF reporting
- [x] **Multi-Platform Support**: Cross-platform builds and releases
- [x] **Monorepo Optimization**: Proper directory and caching configuration
- [x] **Dependency Management**: Automated updates with security validation
- [x] **Documentation Standards**: Comprehensive workflow documentation

### Workflow Optimization Standards

- [x] **Built-in Caching**: Go module caching with cache-dependency-path
- [x] **Security Scanning**: Official gosec action, Trivy SARIF output
- [x] **Container Images**: Multi-platform Docker builds and registry publishing
- [x] **Release Automation**: Cross-platform binary releases with checksums
- [x] **Job Orchestration**: Proper dependency chains and parallel execution
- [x] **Error Handling**: Comprehensive error reporting and failure handling

### Remaining Compliance Tasks

#### High Priority

- [ ] **Performance Monitoring**: CI/CD pipeline performance metrics
- [ ] **Quality Thresholds**: Automated quality gates and failure criteria
- [ ] **Deployment Validation**: Production deployment verification
- [ ] **Security Compliance**: Enhanced security scanning coverage

#### Medium Priority

- [ ] **Workflow Templates**: Reusable workflow templates for common patterns
- [ ] **Environment Management**: Enhanced staging and production workflows
- [ ] **Compliance Automation**: Automated compliance validation and reporting
- [ ] **Monitoring Integration**: Application monitoring and alerting

#### Long-Term

- [ ] **Enterprise Integration**: Enterprise-grade security and compliance features
- [ ] **Advanced Analytics**: Workflow performance and quality analytics
- [ ] **AI Optimization**: AI-powered workflow optimization and recommendations
- [ ] **Community Templates**: Open-source workflow templates and best practices

## 🐛 Known Issues & Workarounds

### Current CI/CD Issues

1. **npm Execution in Windows Environments**
   - **Issue**: Some PowerShell environments have npm execution issues
   - **Component**: Frontend testing workflow
   - **Workaround**: Use Node.js setup action with proper PATH configuration
   - **Status**: Monitored, environment-specific

2. **Go Module Cache Restoration**
   - **Issue**: Previous manual cache conflicts with built-in setup-go caching
   - **Component**: Backend testing and build workflows
   - **Solution**: Removed manual cache steps, configured cache-dependency-path
   - **Status**: ✅ Resolved

3. **Security Scanning Results Delay**
   - **Issue**: SARIF upload may delay security results visibility
   - **Component**: Security scanning workflow
   - **Workaround**: Monitor GitHub Security tab for results
   - **Status**: Expected behavior, not a bug

4. **CodeQL Workflows Not Working**
   - **Issue**: CodeQL security analysis workflows are not functioning correctly
   - **Component**: Security scanning (CodeQL)
   - **Impact**: Limited security analysis coverage
   - **Status**: ❌ Requires investigation and fixes

5. **Docker Build and Release Pipelines Untested**
   - **Issue**: Docker build and release pipelines have not been thoroughly tested
   - **Component**: Container builds and release automation
   - **Impact**: No guarantee of successful production deployments
   - **Status**: ❌ Requires testing and validation

### Technical Debt

- [ ] **Workflow Performance**: Optimize workflow execution times
- [ ] **Resource Usage**: Monitor and optimize resource consumption
- [ ] **Error Recovery**: Enhanced error recovery and retry mechanisms
- [ ] **Documentation Sync**: Automated documentation updates with workflow changes

## 📚 Related Documentation

### Core Documentation

- **[GitHub Instructions](instructions/github.instructions.md)**: Comprehensive GitHub workflow and repository configuration
- **[Copilot Instructions](copilot-instructions.md)**: GitHub Copilot project context and navigation
- **[Contributing Guidelines](CONTRIBUTING.md)**: Development workflow and collaboration standards

### Technology-Specific Instructions

- **[Go Backend Instructions](instructions/go.instructions.md)**: Backend development standards
- **[TypeScript Instructions](instructions/typescript.instructions.md)**: Frontend development standards
- **[Scripts Instructions](instructions/scripts.instructions.md)**: Automation and tooling standards
- **[VS Code Instructions](instructions/vscode.instructions.md)**: Development environment configuration

### Component Tracking

- **[Root AGENTS.md](../AGENTS.md)**: Master project tracking and coordination
- **[Backend AGENTS.md](../backend/AGENTS.md)**: Go backend development tracking
- **[Frontend AGENTS.md](../frontend/AGENTS.md)**: React/TypeScript frontend tracking
- **[Scripts AGENTS.md](../scripts/AGENTS.md)**: Build automation tracking

## 🤝 Contributing

### GitHub Configuration Changes

When modifying GitHub configurations:

1. **Workflow Updates**: Test changes in feature branches before merging
2. **Security Settings**: Validate security configurations don't break development workflow
3. **Template Updates**: Ensure issue and PR templates remain user-friendly
4. **Documentation**: Update instruction files when workflows change
5. **Cross-Component**: Verify changes work with backend, frontend, and script components

### CI/CD Development Workflow

1. **Local Testing**: Test scripts and configurations locally before CI/CD
2. **Branch Protection**: Use feature branches for workflow modifications
3. **Gradual Rollout**: Test workflow changes incrementally
4. **Monitoring**: Monitor workflow execution and performance metrics
5. **Documentation**: Keep GitHub instructions current with workflow changes

### Security Best Practices

1. **Secret Management**: Never commit credentials or sensitive data
2. **Permission Reviews**: Regularly review and audit repository permissions
3. **Security Scanning**: Monitor security scan results and address findings
4. **Dependency Updates**: Keep dependencies current with security patches
5. **Compliance**: Ensure workflows meet security and compliance requirements

---

*Last Updated: October 15, 2025 - This document serves as the comprehensive tracking point for all GitHub configuration and CI/CD activities*
