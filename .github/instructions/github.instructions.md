---
applyTo: '.github/**/*.yml,.github/**/*.yaml,.github/**/*.md,**/workflow/**/*,.github/ISSUE_TEMPLATE/*,.github/PULL_REQUEST_TEMPLATE/*'
---

# GitHub Configuration and Workflow Instructions

This document provides comprehensive guidelines for GitHub repository configuration, workflow automation, and collaboration processes for the Siros project.

## Repository Configuration

### Branch Protection Rules

Configure branch protection for the main branch with the following settings:

```yaml
# Branch protection configuration
main:
  required_status_checks:
    strict: true
    checks:
      - 'build-and-test'
      - 'lint-backend'
      - 'lint-frontend'
      - 'security-scan'
  enforce_admins: true
  required_pull_request_reviews:
    required_approving_review_count: 1
    dismiss_stale_reviews: true
    require_code_owner_reviews: true
  restrictions: null
  required_linear_history: true
  allow_force_pushes: false
  allow_deletions: false
```

### Repository Settings

- Enable **vulnerability alerts** and **dependency security updates**
- Configure **code scanning** with CodeQL
- Set up **secret scanning** for sensitive data
- Enable **discussions** for community engagement
- Configure **wiki** if documentation needs it

## GitHub Actions Workflows

### Workflow Files

| File                                                       | Purpose                 | Triggers                     | Description                                                                                                                               |
| ---------------------------------------------------------- | ----------------------- | ---------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| [📋 CI/CD Pipeline](../workflows/ci-cd.yml)                | `ci-cd.yml`             | push, pull_request, release  | Main CI/CD pipeline with 6 jobs: backend tests, frontend tests, build integration, security scan, Docker build/push, and release creation |
| [🔒 CodeQL Analysis](../workflows/codeql.yml)              | `codeql.yml`            | push, pull_request, schedule | Advanced security analysis with Go autobuild and TypeScript manual build modes, enhanced security queries                                 |
| [🏷️ Auto Label](../workflows/auto-label.yml)               | `auto-label.yml`        | pull_request                 | Automatic PR labeling based on file changes using labeler configuration                                                                   |
| [📦 Dependency Review](../workflows/dependency-review.yml) | `dependency-review.yml` | pull_request                 | Security review of dependency changes in PRs with vulnerability detection                                                                 |
| [🗂️ Stale Management](../workflows/stale.yml)              | `stale.yml`             | schedule (daily)             | Automatic stale issue/PR management with configurable timeouts and exempt labels                                                          |

### Pipeline Overview

**CI/CD Pipeline Features:**

- **Built-in Go Module Caching**: Uses `actions/setup-go@v6` with `cache-dependency-path: backend/go.sum`
- **Security Integration**: Trivy vulnerability scanning, Gosec security analysis, golangci-lint quality checks
- **Multi-Platform Support**: Cross-platform builds (Linux, macOS, Windows) with ARM64/AMD64 architecture support
- **Monorepo Optimization**: Coordinated frontend/backend builds with embedded assets and proper working directories
- **Container Publishing**: Multi-architecture Docker images pushed to GitHub Container Registry
- **Release Automation**: Automatic binary creation and GitHub release publishing

## GitHub Tasks and Actions

### Core Actions Used in Workflows

#### Repository and Environment Setup

**actions/checkout@v5** - Checkout repository code

```yaml
- uses: actions/checkout@v5
```

**actions/setup-go@v6** - Set up Go environment with built-in caching

```yaml
- name: Set up Go
  uses: actions/setup-go@v6
  with:
    go-version: ${{ env.GO_VERSION }}
    cache-dependency-path: backend/go.sum
```

**actions/setup-node@v6** - Set up Node.js environment with npm caching

```yaml
- name: Set up Node.js
  uses: actions/setup-node@v6
  with:
    node-version: ${{ env.NODE_VERSION }}
    cache: 'npm'
    cache-dependency-path: frontend/package-lock.json
```

#### Artifact Management

**actions/upload-artifact@v4** - Upload build artifacts

```yaml
- name: Upload build artifacts
  uses: actions/upload-artifact@v4
  with:
    name: siros-binary
    path: build/siros
    retention-days: 7
```

**actions/download-artifact@v4** - Download build artifacts

```yaml
- name: Download build artifacts
  uses: actions/download-artifact@v4
  with:
    name: siros-binary
    path: ./artifacts
```

#### Code Quality and Security

**golangci/golangci-lint-action@v3** - Run Go linting with golangci-lint

```yaml
- name: Run Go linting
  uses: golangci/golangci-lint-action@v3
  with:
    version: latest
    working-directory: ./backend
    args: --timeout=5m
```

**aquasecurity/trivy-action@master** - Security vulnerability scanning

```yaml
- name: Run Trivy vulnerability scanner
  uses: aquasecurity/trivy-action@master
  with:
    scan-type: 'fs'
    scan-ref: '.'
    format: 'sarif'
    output: 'trivy-results.sarif'
```

**github/codeql-action/init@v4** - Initialize CodeQL security analysis

```yaml
- name: Initialize CodeQL
  uses: github/codeql-action/init@v4
  with:
    languages: ${{ matrix.language }}
    build-mode: ${{ matrix.build-mode }}
    queries: security-and-quality
```

**github/codeql-action/analyze@v4** - Perform CodeQL security analysis

```yaml
- name: Perform CodeQL Analysis
  uses: github/codeql-action/analyze@v4
  with:
    category: '/language:${{matrix.language}}'
    upload: true
```

**github/codeql-action/upload-sarif@v2** - Upload security analysis results

```yaml
- name: Upload Trivy scan results
  uses: github/codeql-action/upload-sarif@v2
  with:
    sarif_file: 'trivy-results.sarif'
```

#### Docker and Container Management

**docker/setup-buildx-action@v3** - Set up Docker Buildx for multi-platform builds

```yaml
- name: Set up Docker Buildx
  uses: docker/setup-buildx-action@v3
```

**docker/login-action@v3** - Log in to container registry

```yaml
- name: Log in to Container Registry
  uses: docker/login-action@v3
  with:
    registry: ${{ env.REGISTRY }}
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}
```

**docker/metadata-action@v5** - Extract metadata for Docker images

```yaml
- name: Extract metadata
  id: meta
  uses: docker/metadata-action@v5
  with:
    images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
    tags: |
      type=ref,event=branch
      type=ref,event=pr
      type=semver,pattern={{version}}
      type=semver,pattern={{major}}.{{minor}}
      type=sha,prefix={{branch}}-
```

**docker/build-push-action@v5** - Build and push Docker images

```yaml
- name: Build and push Docker image
  uses: docker/build-push-action@v5
  with:
    context: .
    platforms: linux/amd64,linux/arm64
    push: true
    tags: ${{ steps.meta.outputs.tags }}
    labels: ${{ steps.meta.outputs.labels }}
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

#### Release and Repository Management

**softprops/action-gh-release@v1** - Create GitHub releases

```yaml
- name: Upload release assets
  uses: softprops/action-gh-release@v1
  with:
    files: |
      release/*.tar.gz
      release/checksums.txt
    generate_release_notes: true
```

**actions/labeler@v4** - Automatic PR labeling

```yaml
- name: Label based on file changes
  uses: actions/labeler@v4
  with:
    repo-token: ${{ secrets.GITHUB_TOKEN }}
    configuration-path: .github/labeler.yml
    sync-labels: true
```

**actions/dependency-review-action@v4** - Review dependency changes

```yaml
- name: Dependency Review
  uses: actions/dependency-review-action@v4
  with:
    config-file: '.github/dependency-review-config.yml'
```

**actions/stale@v8** - Manage stale issues and PRs

```yaml
- uses: actions/stale@v8
  with:
    repo-token: ${{ secrets.GITHUB_TOKEN }}
    stale-issue-message: |
      This issue has been automatically marked as stale because it has not had recent activity.
    days-before-issue-stale: 60
    days-before-issue-close: 7
    stale-issue-label: 'stale'
    exempt-issue-labels: 'pinned,security,critical'
```

### Service Containers

**PostgreSQL** - Database for backend tests

```yaml
services:
  postgres:
    image: postgres:15-alpine
    env:
      POSTGRES_PASSWORD: postgres
      POSTGRES_USER: postgres
      POSTGRES_DB: siros_test
    options: >-
      --health-cmd pg_isready
      --health-interval 10s
      --health-timeout 5s
      --health-retries 5
    ports:
      - 5432:5432
```

### Environment Variables

```yaml
env:
  GO_VERSION: '1.24'
  NODE_VERSION: '18'
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}
```

## Issue and Pull Request Templates

### Template Files

| Template                                                    | Purpose                      | File                       | Description                                                                              |
| ----------------------------------------------------------- | ---------------------------- | -------------------------- | ---------------------------------------------------------------------------------------- |
| [🐛 Bug Report](../ISSUE_TEMPLATE/bug_report.yml)           | Bug reports                  | `bug_report.yml`           | Structured bug reporting with environment details, reproduction steps, and validation    |
| [💡 Feature Request](../ISSUE_TEMPLATE/feature_request.yml) | Feature suggestions          | `feature_request.yml`      | Feature proposals with problem statements, solutions, and priority assessment            |
| [📚 Documentation](../ISSUE_TEMPLATE/documentation.yml)     | Documentation improvements   | `documentation.yml`        | Documentation requests and improvements                                                  |
| [⚙️ Template Config](../ISSUE_TEMPLATE/config.yml)          | Issue template configuration | `config.yml`               | Template routing and external link configuration                                         |
| [🔄 Pull Request](../pull_request_template.md)              | Pull request submissions     | `pull_request_template.md` | PR description template with checklists, testing requirements, and change categorization |

## Code Owners Configuration

### CODEOWNERS file (`.github/CODEOWNERS`)

```
# Global owners
* @maintainer-team

# Backend Go code
/backend/ @backend-team @go-experts

# Frontend TypeScript/React code
/frontend/ @frontend-team @react-experts

# DevOps and CI/CD
/.github/ @devops-team
/scripts/ @devops-team
/docker-compose.yml @devops-team
/Dockerfile @devops-team

# Documentation
/docs/ @documentation-team
README.md @documentation-team

# Configuration files
/config.yaml @backend-team @devops-team

# Database related
/scripts/init.sql @backend-team @database-team
```

## GitHub Repository Settings

### Security Settings

```yaml
# Security configuration recommendations
security:
  vulnerability_alerts: true
  dependency_security_updates: true
  code_scanning:
    enabled: true
    tools:
      - CodeQL
      - Trivy
  secret_scanning:
    enabled: true
    push_protection: true

  # Recommended security tools integration
  integrations:
    - name: Snyk
      type: vulnerability_scanning
    - name: SonarCloud
      type: code_quality
```

### Branch Protection Strategy

```yaml
# Recommended branch protection rules
branches:
  main:
    protection_rules:
      required_status_checks:
        strict: true
        checks:
          - 'build-and-test'
          - 'lint-backend'
          - 'lint-frontend'
          - 'security-scan'
      enforce_admins: true
      required_pull_request_reviews:
        required_approving_review_count: 2
        dismiss_stale_reviews: true
        require_code_owner_reviews: true
        require_last_push_approval: true
      restrictions:
        users: []
        teams: ['maintainer-team']
      required_linear_history: true
      allow_force_pushes: false
      allow_deletions: false

  develop:
    protection_rules:
      required_status_checks:
        strict: true
        checks:
          - 'build-and-test'
          - 'lint-backend'
          - 'lint-frontend'
      required_pull_request_reviews:
        required_approving_review_count: 1
        dismiss_stale_reviews: true
```

## Dependabot Configuration

### dependabot.yml (`.github/dependabot.yml`)

```yaml
version: 2
updates:
  - package-ecosystem: 'gomod'
    directory: '/backend'
    schedule:
      interval: 'weekly'
      day: 'monday'
      time: '09:00'
      timezone: 'UTC'
    open-pull-requests-limit: 5
    reviewers:
      - 'backend-team'
    assignees:
      - 'maintainer-team'
    commit-message:
      prefix: 'backend'
      include: 'scope'

  - package-ecosystem: 'npm'
    directory: '/frontend'
    schedule:
      interval: 'weekly'
      day: 'monday'
      time: '09:00'
      timezone: 'UTC'
    open-pull-requests-limit: 5
    reviewers:
      - 'frontend-team'
    assignees:
      - 'maintainer-team'
    commit-message:
      prefix: 'frontend'
      include: 'scope'

  - package-ecosystem: 'docker'
    directory: '/'
    schedule:
      interval: 'weekly'
      day: 'monday'
      time: '09:00'
      timezone: 'UTC'
    reviewers:
      - 'devops-team'
    assignees:
      - 'maintainer-team'

  - package-ecosystem: 'github-actions'
    directory: '/.github/workflows'
    schedule:
      interval: 'weekly'
      day: 'monday'
      time: '09:00'
      timezone: 'UTC'
    reviewers:
      - 'devops-team'
    assignees:
      - 'maintainer-team'
```

## Release Management

### Semantic Release Configuration

```json
{
  "branches": [
    "main",
    {
      "name": "develop",
      "prerelease": "beta"
    }
  ],
  "plugins": [
    "@semantic-release/commit-analyzer",
    "@semantic-release/release-notes-generator",
    "@semantic-release/changelog",
    "@semantic-release/github",
    [
      "@semantic-release/exec",
      {
        "publishCmd": "echo '${nextRelease.version}' > VERSION"
      }
    ]
  ]
}
```

### Commit Convention

Follow the Conventional Commits specification:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types:**

- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that do not affect the meaning of the code
- `refactor`: A code change that neither fixes a bug nor adds a feature
- `perf`: A code change that improves performance
- `test`: Adding missing tests or correcting existing tests
- `chore`: Changes to the build process or auxiliary tools

**Examples:**

```
feat(api): add semantic search endpoint
fix(frontend): resolve resource card loading state
docs(readme): update installation instructions
chore(deps): update Go dependencies
```

## GitHub Apps and Integrations

### Recommended GitHub Apps

1. **CodeQL** - Security scanning
2. **Dependabot** - Dependency updates
3. **Codecov** - Code coverage reporting
4. **SonarCloud** - Code quality analysis
5. **Snyk** - Vulnerability scanning

### Webhook Configuration

```yaml
webhooks:
  - url: 'https://api.example.com/github-webhook'
    content_type: 'json'
    events:
      - 'push'
      - 'pull_request'
      - 'release'
      - 'issues'
    active: true
    secret: '${{ secrets.WEBHOOK_SECRET }}'
```

## Monitoring and Analytics

### GitHub Insights Configuration

- Enable **repository insights** for traffic and performance monitoring
- Set up **code frequency** tracking
- Monitor **contributor activity** and **community health**
- Track **security advisories** and **dependency graphs**

### Custom Analytics

```yaml
# GitHub API integration for custom metrics
metrics:
  pull_requests:
    - time_to_merge
    - review_count
    - size_distribution
  issues:
    - time_to_resolution
    - label_distribution
    - contributor_engagement
  releases:
    - frequency
    - download_statistics
    - version_adoption
```

This comprehensive GitHub configuration ensures proper workflow automation, security practices, and collaboration processes for the Siros project.
