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

### Key Features and Improvements

The Siros CI/CD pipeline includes several modern optimizations:

**Built-in Go Module Caching:**

- Uses `actions/setup-go@v6` with `cache-dependency-path: backend/go.sum`
- Eliminates manual `actions/cache` steps for Go modules
- Automatic cache invalidation based on dependency changes
- Optimized for monorepo structure with backend subdirectory

**Security Scanning Integration:**

- **Trivy** for filesystem vulnerability scanning with SARIF output
- **Gosec** using existing backend_gosec.sh script with comprehensive error handling and auto-installation
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

### Main CI/CD Pipeline (`.github/workflows/ci-cd.yml`)

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]
  release:
    types: [published]

env:
  GO_VERSION: '1.21'
  NODE_VERSION: '18'
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  # Backend testing and linting
  backend-test:
    name: Backend Tests
    runs-on: ubuntu-latest

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

    steps:
      - uses: actions/checkout@v5

      - name: Set up Go
        uses: actions/setup-go@v6
        with:
          go-version: ${{ env.GO_VERSION }}
          cache-dependency-path: backend/go.sum

      - name: Setup database
        run: |
          sudo apt-get update
          sudo apt-get install -y postgresql-client
          # Note: Using standard PostgreSQL for CI tests
          # pgvector extension would be available in production deployment
          PGPASSWORD=postgres psql -h localhost -U postgres -d siros_test -c "SELECT version();"

      - name: Download Go dependencies
        working-directory: ./backend
        run: go mod download

      - name: Run Go linting
        uses: golangci/golangci-lint-action@v3
        with:
          version: latest
          working-directory: ./backend
          args: --timeout=5m

      - name: Run Go tests
        working-directory: ./backend
        run: go test -v -race -coverprofile=coverage.out ./...
        env:
          DATABASE_URL: postgres://postgres:postgres@localhost:5432/siros_test?sslmode=disable

  # Frontend testing and linting
  frontend-test:
    name: Frontend Tests
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v5

      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json

      - name: Install dependencies
        working-directory: ./frontend
        run: npm ci

      - name: Run ESLint
        working-directory: ./frontend
        run: npm run lint

      - name: Run TypeScript check
        working-directory: ./frontend
        run: npx tsc --noEmit

      - name: Run tests
        working-directory: ./frontend
        run: npm test

  # Build and test the complete application
  build-test:
    name: Build Integration Test
    runs-on: ubuntu-latest
    needs: [backend-test, frontend-test]

    steps:
      - uses: actions/checkout@v5

      - name: Set up Go
        uses: actions/setup-go@v6
        with:
          go-version: ${{ env.GO_VERSION }}
          cache-dependency-path: backend/go.sum

      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json

      - name: Build complete application
        run: ./scripts/build.sh

      - name: Test binary execution
        working-directory: ./backend
        run: |
          timeout 10s ./siros-server --help || true

      - name: Upload build artifacts
        uses: actions/upload-artifact@v4
        with:
          name: siros-binary
          path: build/siros
          retention-days: 7

  # Security scanning
  security-scan:
    name: Security Scan
    runs-on: ubuntu-latest
    needs: [backend-test, frontend-test]

    steps:
      - uses: actions/checkout@v5

      - name: Set up Go
        uses: actions/setup-go@v6
        with:
          go-version: ${{ env.GO_VERSION }}
          cache-dependency-path: backend/go.sum

      - name: Download Go dependencies
        working-directory: ./backend
        run: go mod download

      - name: Verify Go modules
        working-directory: ./backend
        run: go mod verify

      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'sarif'
          output: 'trivy-results.sarif'

      - name: Upload Trivy scan results
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'

      - name: Run Gosec Security Scanner
        run: ./scripts/backend/backend_gosec.sh

  # Docker build and push
  docker:
    name: Docker Build and Push
    runs-on: ubuntu-latest
    needs: [build-test, security-scan]
    if: github.event_name == 'push' || github.event_name == 'release'

    permissions:
      contents: read
      packages: write

    steps:
      - uses: actions/checkout@v5

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

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

  # Release workflow
  release:
    name: Create Release
    runs-on: ubuntu-latest
    needs: [docker]
    if: github.event_name == 'release'

    steps:
      - uses: actions/checkout@v5

      - name: Download build artifacts
        uses: actions/download-artifact@v4
        with:
          name: siros-binary
          path: ./artifacts

      - name: Create release assets
        run: |
          mkdir -p release
          cd artifacts
          tar -czf ../release/siros-linux-amd64.tar.gz siros-server
          cd ../release
          sha256sum *.tar.gz > checksums.txt

      - name: Upload release assets
        uses: softprops/action-gh-release@v1
        with:
          files: |
            release/*.tar.gz
            release/checksums.txt
          generate_release_notes: true
```

### Release Workflow (`.github/workflows/release.yml`)

```yaml
name: Release

on:
  release:
    types: [published]

env:
  GO_VERSION: '1.21'
  NODE_VERSION: '18'

jobs:
  build-release:
    name: Build Release Binaries
    runs-on: ubuntu-latest

    strategy:
      matrix:
        include:
          - goos: linux
            goarch: amd64
            asset_name: siros-linux-amd64
          - goos: linux
            goarch: arm64
            asset_name: siros-linux-arm64
          - goos: darwin
            goarch: amd64
            asset_name: siros-darwin-amd64
          - goos: darwin
            goarch: arm64
            asset_name: siros-darwin-arm64
          - goos: windows
            goarch: amd64
            asset_name: siros-windows-amd64.exe

    steps:
      - uses: actions/checkout@v5

      - name: Set up Go
        uses: actions/setup-go@v6
        with:
          go-version: ${{ env.GO_VERSION }}
          cache-dependency-path: backend/go.sum

      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          cache-dependency-path: 'frontend/package-lock.json'

      - name: Build frontend
        working-directory: ./frontend
        run: |
          npm ci
          npm run build

      - name: Copy frontend assets to backend
        run: |
          mkdir -p backend/static
          cp -r frontend/dist/* backend/static/

      - name: Build binary
        working-directory: ./backend
        env:
          GOOS: ${{ matrix.goos }}
          GOARCH: ${{ matrix.goarch }}
          CGO_ENABLED: 0
        run: |
          go build -ldflags="-s -w -X main.version=${{ github.event.release.tag_name }}" \
            -o ${{ matrix.asset_name }} ./cmd/siros-server

      - name: Upload release asset
        uses: softprops/action-gh-release@v1
        with:
          files: ./backend/${{ matrix.asset_name }}
```

### Dependency Update Workflow (`.github/workflows/dependabot-auto-merge.yml`)

```yaml
name: Dependabot Auto-merge

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  auto-merge:
    name: Auto-merge Dependabot PRs
    runs-on: ubuntu-latest
    if: github.actor == 'dependabot[bot]'

    steps:
      - name: Fetch Dependabot metadata
        id: dependabot-metadata
        uses: dependabot/fetch-metadata@v1
        with:
          github-token: '${{ secrets.GITHUB_TOKEN }}'

      - name: Auto-merge minor and patch updates
        if: steps.dependabot-metadata.outputs.update-type != 'version-update:semver-major'
        run: |
          gh pr merge --auto --squash "$PR_URL"
        env:
          PR_URL: ${{ github.event.pull_request.html_url }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Issue and Pull Request Templates

### Bug Report Template (`.github/ISSUE_TEMPLATE/bug_report.yml`)

```yaml
name: Bug Report
description: File a bug report to help us improve Siros
title: '[Bug]: '
labels: ['bug', 'needs-triage']

body:
  - type: markdown
    attributes:
      value: |
        Thank you for taking the time to file a bug report! Please fill out this form as completely as possible.

  - type: checkboxes
    attributes:
      label: Prerequisites
      description: Please confirm these before submitting your issue
      options:
        - label: I have searched existing issues to avoid duplicates
          required: true
        - label: I have read the documentation
          required: true
        - label: I am using the latest version of Siros
          required: true

  - type: textarea
    attributes:
      label: Description
      description: A clear and concise description of what the bug is
      placeholder: Describe the bug...
    validations:
      required: true

  - type: textarea
    attributes:
      label: Steps to Reproduce
      description: Steps to reproduce the behavior
      placeholder: |
        1. Start the application with '...'
        2. Navigate to '...'
        3. Click on '...'
        4. See error
    validations:
      required: true

  - type: textarea
    attributes:
      label: Expected Behavior
      description: A clear and concise description of what you expected to happen
    validations:
      required: true

  - type: textarea
    attributes:
      label: Actual Behavior
      description: What actually happened instead
    validations:
      required: true

  - type: textarea
    attributes:
      label: Environment
      description: Please provide information about your environment
      value: |
        - OS: [e.g., Windows 11, macOS 13, Ubuntu 22.04]
        - Go version: [e.g., 1.21.0]
        - Node.js version: [e.g., 18.17.0]
        - Database: [e.g., PostgreSQL 15.3]
        - Cloud Providers: [e.g., AWS, Azure, GCP]
    validations:
      required: true

  - type: textarea
    attributes:
      label: Logs
      description: If applicable, add logs to help explain your problem
      render: shell

  - type: textarea
    attributes:
      label: Additional Context
      description: Add any other context about the problem here
```

### Feature Request Template (`.github/ISSUE_TEMPLATE/feature_request.yml`)

```yaml
name: Feature Request
description: Suggest a new feature or enhancement for Siros
title: '[Feature]: '
labels: ['enhancement', 'needs-triage']

body:
  - type: markdown
    attributes:
      value: |
        Thank you for suggesting a new feature! Please provide as much detail as possible.

  - type: checkboxes
    attributes:
      label: Prerequisites
      description: Please confirm these before submitting your request
      options:
        - label: I have searched existing issues to avoid duplicates
          required: true
        - label: I have read the documentation
          required: true
        - label: This feature would benefit other users, not just me
          required: true

  - type: textarea
    attributes:
      label: Feature Description
      description: A clear and concise description of what you want to happen
      placeholder: Describe the feature...
    validations:
      required: true

  - type: textarea
    attributes:
      label: Problem Statement
      description: What problem does this feature solve?
      placeholder: This feature would solve...
    validations:
      required: true

  - type: textarea
    attributes:
      label: Proposed Solution
      description: Describe the solution you'd like to see implemented
    validations:
      required: true

  - type: textarea
    attributes:
      label: Alternatives Considered
      description: Describe any alternative solutions or workarounds you've considered

  - type: dropdown
    attributes:
      label: Component
      description: Which part of Siros would this feature affect?
      options:
        - Backend API
        - Frontend UI
        - Database/Storage
        - Cloud Providers
        - Documentation
        - CI/CD
        - Other
    validations:
      required: true

  - type: dropdown
    attributes:
      label: Priority
      description: How important is this feature to you?
      options:
        - Low - Nice to have
        - Medium - Would improve my workflow
        - High - Critical for my use case
    validations:
      required: true
```

### Pull Request Template (`.github/pull_request_template.md`)

```markdown
## Description

Brief description of what this PR does.

Closes _[issue number]_

## Type of Change

Please delete options that are not relevant.

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Code refactoring
- [ ] Test improvements

## Testing

Please describe how you tested your changes.

- [ ] Unit tests pass locally
- [ ] Integration tests pass locally
- [ ] Manual testing completed
- [ ] Added new tests for new functionality

## Checklist

- [ ] My code follows the project's coding standards
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings or errors
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
- [ ] Any dependent changes have been merged and published

## Screenshots (if applicable)

Add screenshots to help explain your changes.

## Additional Notes

Any additional information, configuration changes, or migration notes.
```

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
