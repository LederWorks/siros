# Siros - Multi-Cloud Resource Platform

🌐 **Siros** is a comprehensive Go-based multi-cloud resource platform that provides unified resource management across AWS, Azure, and Google Cloud Platform with advanced features including semantic search, blockchain change tracking, and multiple API interfaces.

## ✨ Features

### 🔌 Multi-Cloud Integration
- **AWS Support**: EC2, S3, RDS with full metadata extraction
- **Azure Support**: Virtual Machines, Storage Accounts (placeholder implementation)
- **GCP Support**: Compute Engine, Cloud Storage (placeholder implementation)
- **Unified API**: Single interface for all cloud providers

### 🧠 Advanced Storage & Search
- **PostgreSQL with pgvector**: Vector database for semantic resource search
- **Resource Vectorization**: Automatic embedding generation for metadata
- **Semantic Search**: Find resources using natural language queries
- **Relationship Mapping**: Parent-child resource hierarchies

### 🔗 Multiple API Interfaces
- **REST HTTP API**: Standard RESTful resource management
- **Terraform Integration**: Provider support for Infrastructure as Code
- **MCP (Model Context Protocol)**: AI/LLM integration for intelligent resource queries
- **WebSocket Support**: Real-time resource updates

### ⛓️ Change Tracking & Audit
- **Blockchain Integration**: Immutable change records
- **Resource History**: Track all modifications over time
- **Audit Compliance**: Full audit trail for compliance requirements

### 📊 Resource Management
- **Custom Schemas**: Define your own resource types
- **Cross-Cloud Linking**: Connect resources across providers
- **Hierarchy Support**: Parent-child resource relationships
- **Metadata Enrichment**: Automatic metadata extraction and tagging

## 🚀 Quick Start

### Prerequisites
- Go 1.21 or higher
- PostgreSQL 15+ with pgvector extension
- Docker (optional, for database)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/LederWorks/siros.git
   cd siros
   ```

2. **Set up PostgreSQL with pgvector**
   ```bash
   # Using Docker (recommended for development)
   make init-db
   
   # Or manually with existing PostgreSQL
   createdb siros
   psql -d siros -c "CREATE EXTENSION vector;"
   ```

3. **Configure cloud providers**
   ```bash
   cp config.yaml config.local.yaml
   # Edit config.local.yaml with your cloud credentials
   ```

4. **Build and run**
   ```bash
   make build
   ./build/siros -config config.local.yaml
   ```

5. **Access the platform**
   - Web Interface: http://localhost:8080
   - API Health: http://localhost:8080/api/v1/health
   - Resources API: http://localhost:8080/api/v1/resources

## 📋 Configuration

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

## 🔧 API Usage

### REST API Examples

**List all resources:**
```bash
curl http://localhost:8080/api/v1/resources
```

**Get specific resource:**
```bash
curl http://localhost:8080/api/v1/resources/{resource-id}
```

**Search resources:**
```bash
curl -X POST http://localhost:8080/api/v1/search \
  -H "Content-Type: application/json" \
  -d '{"query": "web servers", "filters": {"provider": "aws"}}'
```

**Create resource:**
```bash
curl -X POST http://localhost:8080/api/v1/resources \
  -H "Content-Type: application/json" \
  -d '{
    "id": "my-resource-1",
    "type": "custom.server",
    "provider": "aws",
    "name": "My Web Server",
    "tags": {"environment": "production"}
  }'
```

### MCP Integration

Siros implements the Model Context Protocol for AI/LLM integration:

```bash
# Initialize MCP session
curl -X POST http://localhost:8080/api/v1/mcp/initialize

# List available resources
curl -X POST http://localhost:8080/api/v1/mcp/resources/list

# Read resource content
curl -X POST http://localhost:8080/api/v1/mcp/resources/read \
  -H "Content-Type: application/json" \
  -d '{"uri": "resource://siros/my-resource-1"}'
```

## 🔨 Development

### Build Commands
```bash
make build          # Build the application
make build-prod     # Production build with optimizations
make test           # Run tests
make lint           # Run linter
make clean          # Clean build artifacts
```

### Database Commands
```bash
make init-db        # Initialize development database
make stop-db        # Stop development database
```

### Development Tools
```bash
make install-tools  # Install development tools
make dev           # Run with live reload (requires air)
```

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Web Frontend  │    │   HTTP API      │    │   MCP API       │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          └──────────────────────┼──────────────────────┘
                                 │
                    ┌─────────────┴───────────┐
                    │    API Server           │
                    │  (Gorilla Mux + CORS)  │
                    └─────────────┬───────────┘
                                  │
                    ┌─────────────┴───────────┐
                    │   Business Logic        │
                    │ - Resource Management   │
                    │ - Provider Abstraction │
                    │ - Vector Search         │
                    └─────────────┬───────────┘
                                  │
          ┌───────────────────────┼───────────────────────┐
          │                       │                       │
┌─────────┴───────┐    ┌─────────┴───────┐    ┌─────────┴───────┐
│ PostgreSQL      │    │ Cloud Providers │    │ Blockchain      │
│ + pgvector      │    │ - AWS           │    │ Integration     │
│                 │    │ - Azure         │    │                 │
│ - Resources     │    │ - GCP           │    │ - Change Log    │
│ - Metadata      │    │                 │    │ - Audit Trail   │
│ - Vector Index  │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the Mozilla Public License 2.0 - see the [LICENSE](LICENSE) file for details.

## 🔮 Roadmap

- [ ] **Enhanced Frontend**: Full React/TypeScript SPA with D3.js visualizations
- [ ] **Terraform Provider**: Complete Terraform integration
- [ ] **Blockchain Implementation**: Ethereum/Polygon change tracking
- [ ] **Advanced Analytics**: Resource cost analysis and optimization
- [ ] **Multi-tenancy**: Organization and user management
- [ ] **Plugin System**: Custom provider plugins
- [ ] **GraphQL API**: Alternative query interface
- [ ] **Real-time Updates**: WebSocket-based live resource updates

## 📞 Support

- 📧 **Email**: support@lederworks.com
- 🐛 **Issues**: [GitHub Issues](https://github.com/LederWorks/siros/issues)
- 📖 **Documentation**: [Wiki](https://github.com/LederWorks/siros/wiki)

---

**Siros** - Unify your multi-cloud infrastructure with intelligent resource management. 🌐✨
