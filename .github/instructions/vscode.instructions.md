---
applyTo: ".vscode/**/*"
---

# VS Code Configuration and Development Instructions

This document provides comprehensive guidance for using VS Code with the Siros project, including workspace configuration, task automation, debugging, and development workflow optimization.

## Configuration Overview

The Siros VS Code workspace includes several configuration files designed to streamline the development experience:

- **`.vscode/tasks.json`** - Task automation for building, testing, and development
- **`.vscode/settings.json`** - Workspace-specific editor and language settings
- **`.vscode/mcp.json`** - Model Context Protocol configuration for AI integration with multiple servers including GitHub, memory persistence, sequential thinking, document processing, knowledge base search, and Siros-specific cloud resource management
- **`.vscode/extensions.json`** - Recommended extensions for optimal development
- **`.vscode/launch.json`** - Debug configurations (if needed)

## Task Automation

### Available Tasks

The workspace includes comprehensive task definitions accessible via **Ctrl+Shift+P** → "Tasks: Run Task":

#### Build Tasks
- **Build All (Production)** - Complete production build (frontend + backend)
- **Build Backend Only** - Go backend compilation
- **Build Frontend Only** - React/TypeScript compilation and bundling

#### Development Tasks
- **Start Development Server** - Concurrent backend and frontend development servers
- **Start Backend Dev** - Go backend with hot reload (background task)
- **Start Frontend Dev** - React development server with hot reload (background task)

#### Testing Tasks
- **Test All** - Complete test suite (backend + frontend)
- **Test Backend** - Go unit and integration tests
- **Test Frontend** - React/TypeScript tests with Jest
- **Test with Coverage** - Generate test coverage reports

#### Code Quality Tasks
- **Lint All** - Lint both backend and frontend code
- **Lint Backend** - golangci-lint for Go code
- **Lint Frontend** - ESLint for TypeScript/React code
- **Format All** - Format all code files
- **Format Backend** - gofmt/goimports for Go code
- **Format Frontend** - Prettier for TypeScript/React code

#### Dependency Management
- **Install Backend Dependencies** - Download Go modules
- **Install Frontend Dependencies** - Install npm packages
- **Update Dependencies** - Update all project dependencies
- **Clean Dependencies** - Clean module cache and node_modules

#### Docker Tasks
- **Docker Build** - Build Siros container image
- **Docker Run** - Run containerized application
- **Docker Compose Up** - Start full stack with docker-compose

#### Database Tasks
- **Initialize Database** - Set up PostgreSQL with pgvector extension

### Task Usage

**Quick Access**: Use **Ctrl+Shift+P** → "Tasks: Run Task" to see all available tasks

**Keyboard Shortcuts**: Configure custom shortcuts in **Ctrl+Shift+P** → "Preferences: Open Keyboard Shortcuts (JSON)":

```json
[
    {
        "key": "ctrl+shift+b",
        "command": "workbench.action.tasks.runTask",
        "args": "Build All (Production)"
    },
    {
        "key": "ctrl+shift+t",
        "command": "workbench.action.tasks.runTask",
        "args": "Test All"
    },
    {
        "key": "ctrl+shift+d",
        "command": "workbench.action.tasks.runTask",
        "args": "Start Development Server"
    }
]
```

**Task Groups**: Tasks are organized into logical groups:
- **build** - All build-related tasks
- **test** - All testing tasks

### Background Tasks

Development server tasks run as background processes:
- **Start Backend Dev** - Runs in background, use terminal to view logs
- **Start Frontend Dev** - Runs in background, automatically opens browser
- **Start Development Server** - Runs both frontend and backend concurrently

**Managing Background Tasks**: Use **Ctrl+Shift+P** → "Tasks: Terminate Task" to stop background processes.

## Language Configuration

### Go Development

#### Settings
```json
{
    "go.useLanguageServer": true,
    "go.lintTool": "golangci-lint",
    "go.formatTool": "goimports",
    "go.testFlags": ["-v", "-race"],
    "go.buildOnSave": "off",
    "go.vetOnSave": "package",
    "go.lintOnSave": "package"
}
```

#### Features
- **Automatic Import Organization** - Imports organized on save
- **Lint on Save** - golangci-lint runs on package save
- **Format on Save** - goimports formatting applied automatically
- **Test Explorer** - Integrated test discovery and execution
- **Code Coverage** - Visual coverage indicators in editor

#### Go-Specific Tasks
- Use **"Test Backend"** task for comprehensive Go testing
- Use **"Lint Backend"** task for code quality checks
- Use **"Build Backend Only"** for quick compilation checks

### TypeScript/React Development

#### Settings
```json
{
    "typescript.preferences.quoteStyle": "single",
    "typescript.suggest.autoImports": true,
    "typescript.updateImportsOnFileMove.enabled": "always",
    "eslint.format.enable": true,
    "editor.codeActionsOnSave": {
        "source.fixAll.eslint": "explicit",
        "source.organizeImports": "explicit"
    }
}
```

#### Features
- **Auto Import Management** - Imports added and organized automatically
- **ESLint Integration** - Real-time linting with auto-fix on save
- **Type Checking** - Real-time TypeScript error detection
- **React Support** - JSX/TSX syntax highlighting and IntelliSense
- **Path Intelligence** - Auto-completion for file paths and imports

#### Frontend-Specific Tasks
- Use **"Start Frontend Dev"** for development server with hot reload
- Use **"Test Frontend"** for Jest-based React testing
- Use **"Lint Frontend"** for ESLint code quality checks

## Debugging Configuration

### Go Debugging

Create `.vscode/launch.json` for Go debugging:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Launch Siros Server",
            "type": "go",
            "request": "launch",
            "mode": "debug",
            "program": "${workspaceFolder}/backend/cmd/siros-server",
            "env": {
                "SIROS_ENV": "development",
                "SIROS_LOG_LEVEL": "debug"
            },
            "args": [],
            "showLog": true
        },
        {
            "name": "Debug Current Go Test",
            "type": "go",
            "request": "launch",
            "mode": "test",
            "program": "${workspaceFolder}/backend",
            "args": [
                "-test.run",
                "^${input:testName}$"
            ]
        }
    ],
    "inputs": [
        {
            "id": "testName",
            "description": "Test function name",
            "default": "",
            "type": "promptString"
        }
    ]
}
```

### Frontend Debugging

Frontend debugging works through browser DevTools:
1. Start frontend development server: **"Start Frontend Dev"** task
2. Open browser at `http://localhost:5173`
3. Use browser DevTools for debugging React components
4. VS Code breakpoints work with browser debugging via source maps

## Extension Recommendations

### Essential Extensions

The workspace automatically recommends essential extensions:

#### Go Development
- **Go** (`golang.go`) - Official Go language support
- **Go Outliner** (`766b.go-outliner`) - Code outline for Go files

#### TypeScript/React Development
- **ESLint** (`dbaeumer.vscode-eslint`) - JavaScript/TypeScript linting
- **Prettier** (`esbenp.prettier-vscode`) - Code formatting
- **TypeScript Importer** - Auto import suggestions

#### Infrastructure & DevOps
- **Docker** (`ms-azuretools.vscode-docker`) - Container management
- **HashiCorp Terraform** (`hashicorp.terraform`) - Terraform support
- **Azure Tools** - Various Azure integration extensions
- **AWS Toolkit** (`AmazonWebServices.aws-toolkit-vscode`) - AWS integration
- **Google Cloud Code** (`googlecloudtools.cloudcode`) - GCP integration

#### Git & Collaboration
- **GitLens** (`eamodio.gitlens`) - Enhanced Git capabilities
- **GitHub Pull Requests** (`GitHub.vscode-pull-request-github`) - PR management
- **GitHub Copilot** (`GitHub.copilot`) - AI code assistance

#### Database & Data
- **PostgreSQL** (`cweijan.vscode-postgresql-client2`) - Database management
- **REST Client** (`humao.rest-client`) - API testing

### Extension Installation

Extensions install automatically when opening the workspace. Manual installation:
1. **Ctrl+Shift+X** to open Extensions panel
2. Search for recommended extensions
3. Install suggested extensions from the workspace recommendations

## Cross-Platform Development

### Windows Configuration

The workspace is optimized for Windows development:

```json
{
    "terminal.integrated.defaultProfile.windows": "PowerShell",
    "terminal.integrated.profiles.windows": {
        "PowerShell": {
            "source": "PowerShell",
            "icon": "terminal-powershell"
        },
        "Git Bash": {
            "source": "Git Bash"
        }
    }
}
```

#### Windows-Specific Features
- **PowerShell Integration** - Default terminal for Windows
- **Git Bash Support** - Alternative shell option
- **Windows Path Handling** - Proper path resolution for scripts
- **Cross-Platform Scripts** - Tasks work with both .sh and .ps1 scripts

### Linux/macOS Support

All tasks include cross-platform script detection:
- **Auto-Detection** - Tasks automatically choose .sh or .ps1 scripts
- **Environment Variables** - Consistent environment setup across platforms
- **Path Normalization** - Proper file path handling per platform

## Environment Variables

### Development Environment

Set via workspace settings or terminal:

```json
{
    "terminal.integrated.env.windows": {
        "SIROS_ENV": "development",
        "SIROS_LOG_LEVEL": "debug"
    }
}
```

#### Common Variables
- **SIROS_ENV** - Environment mode (development, staging, production)
- **SIROS_LOG_LEVEL** - Logging verbosity (debug, info, warn, error)
- **SIROS_DB_URL** - PostgreSQL connection string
- **SIROS_MCP_MODE** - Enable MCP server mode

### Cloud Provider Credentials

Configure cloud provider credentials through environment variables or AWS CLI/Azure CLI/gcloud CLI:

#### AWS
```bash
export AWS_PROFILE=default
export AWS_REGION=us-west-2
```

#### Azure
```bash
az login
az account set --subscription "your-subscription-id"
```

#### GCP
```bash
gcloud auth login
gcloud config set project your-project-id
```

#### Oracle Cloud
```bash
export OCI_CONFIG_FILE=~/.oci/config
export OCI_CONFIG_PROFILE=DEFAULT
```

## File Associations and Language Support

### Automatic Language Detection

VS Code automatically detects file types:
- **`.go`** files use Go language server
- **`.ts`, `.tsx`** files use TypeScript language server
- **`.js`, `.jsx`** files use JavaScript language server
- **`.sql`** files use SQL language support
- **`.dockerfile`, `Dockerfile`** use Docker language support
- **`.tf`** files use Terraform language support

### Custom File Associations

Additional associations configured in settings:

```json
{
    "files.associations": {
        "*.tmpl": "html",
        "*.gotmpl": "html",
        "docker-compose*.yml": "dockercompose",
        "*.hcl": "terraform"
    }
}
```

## Problem Matchers and Error Detection

### Go Error Detection

Tasks include `$go` problem matcher for:
- **Compilation Errors** - Build failures with file/line navigation
- **Test Failures** - Failed test navigation
- **Lint Issues** - golangci-lint warnings and errors

### TypeScript Error Detection

Tasks include `$tsc` problem matcher for:
- **Type Errors** - TypeScript compilation issues
- **Syntax Errors** - JavaScript/TypeScript syntax problems

### ESLint Problem Matcher

Tasks include `$eslint-stylish` for:
- **Code Quality Issues** - ESLint rule violations
- **Style Problems** - Formatting and consistency issues

## Workspace Tips and Best Practices

### Efficient Development Workflow

1. **Start Development**: Use **"Start Development Server"** task
2. **Code Changes**: Make changes with auto-save and format-on-save
3. **Quick Testing**: Use **"Test All"** task regularly
4. **Pre-Commit**: Run **"Lint All"** before committing
5. **Production Build**: Use **"Build All (Production)"** before deployment

### Performance Optimization

#### File Watching
```json
{
    "files.watcherExclude": {
        "**/node_modules/**": true,
        "**/dist/**": true,
        "**/build/**": true,
        "**/.git/**": true,
        "**/coverage/**": true
    }
}
```

#### Search Exclusions
```json
{
    "search.exclude": {
        "**/node_modules": true,
        "**/dist": true,
        "**/build": true,
        "**/.git": true,
        "**/coverage": true
    }
}
```

### Multi-Root Workspace (Alternative)

For advanced users, create a multi-root workspace:

```json
{
    "folders": [
        {
            "name": "Backend",
            "path": "./backend"
        },
        {
            "name": "Frontend",
            "path": "./frontend"
        },
        {
            "name": "Scripts",
            "path": "./scripts"
        }
    ],
    "settings": {
        "go.gopath": "${workspaceFolder:Backend}",
        "typescript.preferences.includePackageJsonAutoImports": "on"
    }
}
```

## Troubleshooting

### Common Issues

#### Go Module Issues
**Problem**: Go modules not found
**Solution**: Run **"Install Backend Dependencies"** task or `go mod download`

#### Frontend Dependencies
**Problem**: npm packages missing
**Solution**: Run **"Install Frontend Dependencies"** task or `npm install`

#### Port Conflicts
**Problem**: Development server port already in use
**Solution**:
- Stop background tasks: **Ctrl+Shift+P** → "Tasks: Terminate Task"
- Check running processes: `netstat -ano | findstr :8080` (Windows)
- Kill processes or change ports in task configuration

#### File Permission Issues (Linux/macOS)
**Problem**: Scripts not executable
**Solution**: Make scripts executable: `chmod +x scripts/*.sh`

### Extension Issues

#### Go Extension Problems
**Problem**: Go extension not working
**Solution**:
1. Install Go tools: **Ctrl+Shift+P** → "Go: Install/Update Tools"
2. Restart VS Code
3. Check Go installation: `go version`

#### TypeScript Issues
**Problem**: TypeScript errors not showing
**Solution**:
1. Reload TypeScript: **Ctrl+Shift+P** → "TypeScript: Reload Projects"
2. Check TypeScript version: **Ctrl+Shift+P** → "TypeScript: Select TypeScript Version"

### Performance Issues

#### Slow IntelliSense
**Solution**:
- Exclude large directories from file watching
- Reduce TypeScript strict mode temporarily
- Close unused editor tabs

#### High Memory Usage
**Solution**:
- Disable unused extensions
- Reduce file watcher scope
- Use workspace instead of individual folder opening

## Security Considerations

### Credential Management

**Never commit credentials**: Use environment variables or external credential management:

```json
{
    "files.exclude": {
        "**/.env": true,
        "**/credentials.json": true,
        "**/*.pem": true,
        "**/*.key": true
    }
}
```

### Extension Security

**Review Extensions**: Only install extensions from trusted publishers
**Extension Permissions**: Review permissions before installation
**Workspace Trust**: Enable workspace trust for enhanced security

## Integration with External Tools

### Model Context Protocol (MCP) Configuration

The workspace includes comprehensive MCP server configurations in `.vscode/mcp.json` for AI-powered development assistance:

#### Core MCP Servers

**GitHub Integration**
- **Server**: `github` (HTTP-based)
- **Purpose**: Repository operations and GitHub API integration
- **URL**: `https://api.githubcopilot.com/mcp/`
- **Usage**: Pull request management, issue tracking, repository insights

**Memory Server**
- **Server**: `memory` (stdio-based)
- **Purpose**: Persistent context across development sessions
- **Command**: `npx -y @modelcontextprotocol/server-memory@latest`
- **Usage**: Maintains conversation history and project context

**Sequential Thinking**
- **Server**: `sequentialthinking` (stdio-based)
- **Purpose**: Complex problem-solving and step-by-step reasoning
- **Command**: `npx -y @modelcontextprotocol/server-sequential-thinking@latest`
- **Usage**: Breaking down complex development tasks

**Document Processing**
- **Server**: `markitdown` (stdio-based)
- **Purpose**: Document conversion and processing
- **Command**: `uvx markitdown-mcp`
- **Usage**: Converting documentation formats, extracting text from files

**Knowledge Base Search**
- **Server**: `deepwiki` (HTTP-based)
- **Purpose**: Deep wiki and knowledge base search
- **URL**: `https://api.deepwiki.com/mcp/sse`
- **Usage**: Searching technical documentation and knowledge bases

**Library Documentation**
- **Server**: `context7` (stdio-based)
- **Purpose**: Library and framework documentation access
- **Command**: `npx -y @upstash/context7-mcp@latest`
- **Usage**: Quick access to API documentation and code examples

#### Siros-Specific MCP Server

**Siros MCP Server**
- **Server**: `siros-mcp`
- **Purpose**: AI-powered cloud resource management
- **Command**: `siros-server --mode=mcp`
- **Environment**: Development mode with debug logging

**Available Tools:**
- `list_resources` - List cloud resources with filtering
- `get_resource` - Get detailed resource information
- `search_resources` - Semantic search using vector embeddings
- `discover_relationships` - Find resource relationships and dependencies
- `analyze_coverage` - Terraform coverage vs discovered resources analysis
- `get_audit_trail` - Blockchain-based audit trail access
- `import_terraform_state` - Import Terraform state for resource mapping
- `scan_cloud_provider` - Trigger cloud provider resource discovery

**Available Prompts:**
- `resource_summary` - Generate comprehensive resource summaries
- `security_analysis` - Analyze security posture of resources
- `cost_optimization` - Provide cost optimization recommendations
- `compliance_check` - Check resources for compliance violations

**Resource URIs:**
- `siros://resources` - Access to all cloud resources
- `siros://relationships` - Resource relationship graph
- `siros://audit` - Blockchain-based audit trail
- `siros://terraform` - Terraform-managed resource mappings
- `siros://schemas` - Resource schemas and custom types

#### MCP Configuration Settings

**Server Configuration:**
- Each MCP server is configured with its type (stdio/http), command/URL, and optional environment variables
- Server-specific capabilities and tools are defined within each server configuration
- Resource URIs provide access to different data types and functionalities

**Input Variables:**
```json
{
  "inputs": [
    {
      "id": "memory_file_path",
      "description": "Path to memory file for persistent context",
      "default": "./.memory",
      "type": "promptString"
    }
  ]
}
```

#### Using MCP Servers

**Prerequisites:**
- Ensure Node.js and npm are installed for stdio-based servers
- Install Python and uvx for document processing servers
- Configure cloud provider credentials for Siros MCP server

**Activation:**
1. MCP servers are automatically available when VS Code opens the workspace
2. Use GitHub Copilot Chat to interact with MCP capabilities
3. Access tools through natural language prompts
4. Monitor server status in VS Code output panel

**Example Usage:**
- "Show me all AWS EC2 instances in production environment"
- "Analyze the security posture of resource xyz-123"
- "What's the relationship between these two resources?"
- "Generate a cost optimization report for Azure resources"

### Database Tools

Connect to PostgreSQL for development:
```json
{
    "mssql.connections": [
        {
            "server": "localhost",
            "database": "siros",
            "user": "siros",
            "password": "siros",
            "port": 5432
        }
    ]
}
```

### API Testing

Use REST Client extension for API testing:
```http
### Get All Resources
GET http://localhost:8080/api/v1/resources
Content-Type: application/json

### Search Resources
POST http://localhost:8080/api/v1/search
Content-Type: application/json

{
    "query": "EC2 instances in production",
    "filters": {
        "provider": "aws",
        "environment": "production"
    }
}
```

### Container Development

For container-based development:
1. Install Docker extension
2. Use **"Docker Build"** and **"Docker Run"** tasks
3. Enable container development: **Ctrl+Shift+P** → "Remote-Containers: Reopen in Container"

This comprehensive VS Code configuration provides an optimized development environment for the Siros multi-cloud resource management platform, supporting efficient development workflows across Go backend and React/TypeScript frontend development.
