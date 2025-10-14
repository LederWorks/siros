# Siros - Multi-Cloud Resource Platform

🌐 **Siros** is a comprehensive Go-based multi-cloud resource platform that provides unified resource management across AWS, Azure, and Google Cloud Platform with advanced features including semantic search, blockchain change tracking, and multiple API interfaces.

## 📂 Monorepo Structure

```
siros/
├── backend/                      # Go backend code
│   ├── cmd/
│   │   └── siros-server/         # Main entry point for API server
│   │       └── main.go
│   │
│   ├── internal/                 # Non-exported application code
│   │   ├── api/                  # API layer (HTTP/Terraform/MCP)
│   │   ├── storage/              # Storage layer connectors
│   │   ├── providers/            # Cloud provider integrations
│   │   ├── config/               # Configuration management
│   │   ├── blockchain/           # Blockchain integration
│   │   └── terraform/            # Terraform integration
│   │
│   ├── pkg/                      # Exported packages
│   │   └── types/                # Type definitions
│   │
│   ├── static/                   # Built frontend assets (embedded)
│   ├── go.mod
│   └── go.sum
│
├── frontend/                     # React + TypeScript portal
│   ├── public/
│   ├── src/
│   │   ├── components/           # UI components
│   │   ├── pages/                # Views (Dashboard, Resources, Graph, Search)
│   │   ├── api/                  # API client
│   │   ├── App.tsx
│   │   └── main.tsx
│   ├── package.json
│   ├── tsconfig.json
│   └── vite.config.ts
│
├── scripts/                      # Build & deployment scripts
│   ├── build_all.sh             # Build frontend + embed into Go binary
│   └── dev.sh                   # Run backend & frontend in dev mode
│
├── README.md
└── .gitignore
```

## ✨ Features

### 🔌 Multi-Cloud Integration
- **AWS Support**: Full integration with EC2, S3, RDS including metadata extraction
- **Azure Support**: Virtual Machines, Storage Accounts (extensible framework)
- **GCP Support**: Compute Engine, Cloud Storage (extensible framework)
- **Unified API**: Single interface for all cloud providers with consistent resource models

### 🧠 Advanced Storage & Search
- **PostgreSQL + pgvector**: Vector database for semantic resource search
- **Resource Vectorization**: Automatic embedding generation for metadata
- **Semantic Search**: Find resources using natural language queries
- **Relationship Mapping**: Parent-child resource hierarchies and cross-cloud linking

### 🔗 Multiple API Interfaces
- **REST HTTP API**: Full CRUD operations for resource management
- **Terraform Integration**: Import Terraform state and map resources
- **MCP (Model Context Protocol)**: AI/LLM integration for intelligent queries
- **React Frontend**: Modern responsive web interface

### ⛓️ Change Tracking & Audit
- **Blockchain Framework**: Immutable change record architecture
- **Resource History**: Track all modifications with cryptographic hashes
- **Audit Compliance**: Full audit trail for compliance requirements

## 🚀 Quick Start

### Prerequisites
- Go 1.21 or higher
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
   ```bash
   # Starts both backend (:8080) and frontend dev server (:5173)
   ./scripts/dev.sh
   ```

5. **Production build**
   ```bash
   # Builds frontend and embeds it in Go binary
   ./scripts/build_all.sh
   
   # Run the single binary
   cd backend
   ./siros-server -config ../config.local.yaml
   ```

### Access Points
- **Frontend (Dev)**: http://localhost:5173 (with Vite dev server)
- **Frontend (Prod)**: http://localhost:8080 (embedded in Go binary)
- **API**: http://localhost:8080/api/v1/
- **Health Check**: http://localhost:8080/api/v1/health

## 🏗️ Development Workflow

### Frontend Development
```bash
cd frontend
npm install           # Install dependencies
npm run dev          # Start dev server with hot reload
npm run build        # Build for production
npm run lint         # Run ESLint
```

### Backend Development
```bash
cd backend
go mod tidy          # Update dependencies
go run ./cmd/siros-server  # Run server
go test ./...        # Run tests
go build -o siros-server ./cmd/siros-server  # Build binary
```

### Full Stack Development
```bash
# Development with hot reload for both frontend and backend
./scripts/dev.sh

# Production build (frontend embedded in Go binary)
./scripts/build_all.sh
```

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
