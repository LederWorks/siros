---
applyTo: "backend/**/*.go,go.mod,go.sum"
---

# Go Backend Development Instructions

This document provides comprehensive guidelines for developing the Siros backend using Go, following MVC architecture patterns and best practices for multi-cloud resource management.

## Architecture Guidelines

### MVC Pattern Implementation

Follow the Model-View-Controller pattern with clean separation of concerns:

#### Controllers (`internal/controllers/`)
Controllers handle HTTP requests and orchestrate business logic without containing it:

```go
type ResourceController struct {
    resourceService services.ResourceService
    vectorService   services.VectorService
    auditService   services.AuditService
    logger         *log.Logger
}

func (c *ResourceController) CreateResource(w http.ResponseWriter, r *http.Request) {
    // 1. Parse and validate request
    var req CreateResourceRequest
    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        views.WriteError(w, http.StatusBadRequest, "invalid request body", err)
        return
    }

    // 2. Delegate to service layer
    resource, err := c.resourceService.CreateResource(r.Context(), req)
    if err != nil {
        views.WriteError(w, http.StatusInternalServerError, "failed to create resource", err)
        return
    }

    // 3. Format response via view layer
    views.WriteResourceResponse(w, http.StatusCreated, resource)
}
```

**Controller Standards:**
- **Thin Controllers**: Only handle HTTP concerns, delegate business logic to services
- **Validation**: Validate input before passing to service layer
- **Error Handling**: Convert service errors to appropriate HTTP responses
- **Logging**: Log request processing for debugging and audit
- **Context Propagation**: Pass context through all service calls

#### Models (`internal/models/`)
Models define data structures and core business logic:

```go
type Resource struct {
    ID           string                 `json:"id" db:"id"`
    Type         string                 `json:"type" db:"type"`
    Provider     string                 `json:"provider" db:"provider"`
    Name         string                 `json:"name" db:"name"`
    Data         map[string]interface{} `json:"data" db:"data"`
    Metadata     ResourceMetadata       `json:"metadata" db:"metadata"`
    Vector       []float32              `json:"vector,omitempty" db:"vector"`
    ParentID     *string                `json:"parent_id,omitempty" db:"parent_id"`
    CreatedAt    time.Time              `json:"created_at" db:"created_at"`
    ModifiedAt   time.Time              `json:"modified_at" db:"modified_at"`
}

func (r *Resource) Validate() error {
    if r.ID == "" {
        return errors.New("resource ID is required")
    }
    if r.Type == "" {
        return errors.New("resource type is required")
    }
    if r.Provider == "" {
        return errors.New("resource provider is required")
    }
    return nil
}

func (r *Resource) GenerateVector(vectorizer VectorService) error {
    // Business logic for vector generation
    vector, err := vectorizer.GenerateVector(r.Data, r.Metadata)
    if err != nil {
        return fmt.Errorf("failed to generate vector: %w", err)
    }
    r.Vector = vector
    return nil
}
```

**Model Standards:**
- **Data Validation**: Models enforce business rules and data integrity
- **Immutable Core**: Use value objects where appropriate
- **Business Logic**: Encapsulate domain-specific operations
- **Vector Operations**: Include vector-specific methods
- **Audit Trail**: Support blockchain change tracking

#### Views (`internal/views/`)
Views handle response formatting and data presentation:

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

func WriteResourceResponse(w http.ResponseWriter, status int, resource *models.Resource) {
    response := APIResponse{
        Data: resource,
        Meta: &Meta{
            Timestamp: time.Now(),
            Version:   "1.0",
        },
    }
    WriteJSONResponse(w, status, response)
}

func WriteError(w http.ResponseWriter, status int, message string, err error) {
    response := APIResponse{
        Error: &APIError{
            Code:    fmt.Sprintf("E%d", status),
            Message: message,
            Details: err.Error(),
        },
    }
    WriteJSONResponse(w, status, response)
}
```

**View Standards:**
- **Consistent Formatting**: Use standardized response structures
- **Data Sanitization**: Remove sensitive information from responses
- **Content Negotiation**: Support multiple response formats
- **Error Standardization**: Consistent error response format
- **Security**: Prevent information leakage in error messages

#### Services (`internal/services/`)
Services contain business logic and coordinate between models and repositories:

```go
type ResourceService interface {
    CreateResource(ctx context.Context, req CreateResourceRequest) (*models.Resource, error)
    GetResource(ctx context.Context, id string) (*models.Resource, error)
    UpdateResource(ctx context.Context, id string, updates ResourceUpdates) (*models.Resource, error)
    DeleteResource(ctx context.Context, id string) error
    ListResources(ctx context.Context, filters ResourceFilters) ([]*models.Resource, error)
}

type resourceService struct {
    repo        repositories.ResourceRepository
    vectorRepo  repositories.VectorRepository
    auditRepo   repositories.BlockchainRepository
    vectorizer  VectorService
}

func (s *resourceService) CreateResource(ctx context.Context, req CreateResourceRequest) (*models.Resource, error) {
    // Business logic and orchestration
    resource := &models.Resource{
        ID:       generateID(),
        Type:     req.Type,
        Provider: req.Provider,
        Name:     req.Name,
        Data:     req.Data,
        Metadata: enrichMetadata(req.Metadata),
        CreatedAt: time.Now(),
        ModifiedAt: time.Now(),
    }

    // Validate business rules
    if err := resource.Validate(); err != nil {
        return nil, fmt.Errorf("validation failed: %w", err)
    }

    // Generate vector
    if err := resource.GenerateVector(s.vectorizer); err != nil {
        return nil, fmt.Errorf("vector generation failed: %w", err)
    }

    // Store in database
    if err := s.repo.Create(ctx, resource); err != nil {
        return nil, fmt.Errorf("storage failed: %w", err)
    }

    // Record in blockchain
    if err := s.auditRepo.RecordChange(ctx, resource.ID, "CREATE", resource); err != nil {
        return nil, fmt.Errorf("audit recording failed: %w", err)
    }

    return resource, nil
}
```

#### Repositories (`internal/repositories/`)
Repositories handle data access and persistence:

```go
type ResourceRepository interface {
    Create(ctx context.Context, resource *models.Resource) error
    GetByID(ctx context.Context, id string) (*models.Resource, error)
    Update(ctx context.Context, resource *models.Resource) error
    Delete(ctx context.Context, id string) error
    List(ctx context.Context, filters ResourceFilters) ([]*models.Resource, error)
}

type resourceRepository struct {
    db *sql.DB
}

func (r *resourceRepository) Create(ctx context.Context, resource *models.Resource) error {
    query := `
        INSERT INTO resources (id, type, provider, name, data, metadata, vector, parent_id, created_at, modified_at)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
    `
    _, err := r.db.ExecContext(ctx, query,
        resource.ID, resource.Type, resource.Provider, resource.Name,
        resource.Data, resource.Metadata, resource.Vector, resource.ParentID,
        resource.CreatedAt, resource.ModifiedAt,
    )
    if err != nil {
        return fmt.Errorf("failed to insert resource: %w", err)
    }
    return nil
}
```

## Code Style Guidelines

### Function Naming and Structure
```go
// Use clear, descriptive function names
func CreateMultiCloudResource(ctx context.Context, req CreateResourceRequest) (*Resource, error)

// Implement proper error handling
if err != nil {
    return nil, fmt.Errorf("failed to create resource: %w", err)
}

// Use context for cancellation and timeouts
ctx, cancel := context.WithTimeout(ctx, 30*time.Second)
defer cancel()
```

### Architecture Patterns
- Follow **clean architecture** principles with clear layer separation
- Implement **dependency injection** for testability using interfaces
- Use **interfaces** for abstractions between layers
- Apply **single responsibility principle** to each component

## API Development

### HTTP Routing
- Use **Gorilla Mux** for HTTP routing
- Implement **middleware** for CORS, logging, and authentication
- Follow **REST conventions** for endpoint design
- Provide **JSON responses** with consistent error formats
- Support **filtering, pagination, and sorting** for list endpoints

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

## Database Integration

### PostgreSQL with pgvector
- Use **PostgreSQL** with **pgvector** extension for vector operations
- Implement **prepared statements** to prevent SQL injection
- Use **database transactions** for atomic operations
- Create **proper indexes** for query performance
- Design **vector similarity queries** for resource relationship discovery
- Implement **blockchain record insertion** for all resource changes

### Transaction Management
```go
func (s *resourceService) CreateResourceWithAudit(ctx context.Context, req CreateResourceRequest) (*models.Resource, error) {
    tx, err := s.db.BeginTx(ctx, nil)
    if err != nil {
        return nil, fmt.Errorf("failed to begin transaction: %w", err)
    }
    defer tx.Rollback()

    // Create resource
    resource, err := s.createResourceInTx(ctx, tx, req)
    if err != nil {
        return nil, err
    }

    // Record audit trail
    if err := s.recordAuditInTx(ctx, tx, resource.ID, "CREATE", resource); err != nil {
        return nil, err
    }

    if err := tx.Commit(); err != nil {
        return nil, fmt.Errorf("failed to commit transaction: %w", err)
    }

    return resource, nil
}
```

## Multi-Cloud Provider Integration

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

### Resource Management
- Store resources as **individual vectors** with original CSP structure
- Enrich with **metadata**: parent_id, created, created_by, modified, modified_by, IAM
- Support **custom schemas** beyond predefined cloud resource types
- Implement **deduplication logic** to identify related resources without merging
- Maintain **cross-cloud relationship** discovery through vector queries

## Testing Standards

### Unit Testing
```go
func TestCreateResource(t *testing.T) {
    // Setup
    mockStorage := &MockStorage{}
    service := NewResourceService(mockStorage)
    
    // Test case
    resource, err := service.CreateResource(context.Background(), validRequest)
    
    // Assertions
    assert.NoError(t, err)
    assert.NotNil(t, resource)
    assert.Equal(t, "expected-name", resource.Name)
}
```

### Controller Testing
```go
func TestResourceController_CreateResource(t *testing.T) {
    // Setup
    mockService := &MockResourceService{}
    controller := NewResourceController(mockService, logger)

    // Mock expectations
    expectedResource := &models.Resource{ID: "test-id", Name: "test"}
    mockService.On("CreateResource", mock.Anything, mock.Anything).Return(expectedResource, nil)

    // Test
    req := httptest.NewRequest("POST", "/resources", strings.NewReader(`{"name":"test"}`))
    w := httptest.NewRecorder()

    controller.CreateResource(w, req)

    // Assertions
    assert.Equal(t, http.StatusCreated, w.Code)
    mockService.AssertExpectations(t)
}
```

### Service Testing
```go
func TestResourceService_CreateResource(t *testing.T) {
    // Setup with mocked dependencies
    mockRepo := &MockResourceRepository{}
    mockVectorRepo := &MockVectorRepository{}
    mockAuditRepo := &MockBlockchainRepository{}
    service := NewResourceService(mockRepo, mockVectorRepo, mockAuditRepo, vectorizer)

    // Test business logic in isolation
    resource, err := service.CreateResource(context.Background(), validRequest)

    assert.NoError(t, err)
    assert.NotNil(t, resource)
    mockRepo.AssertExpectations(t)
}
```

### Test Suite Organization
- **models**: Business logic and validation tests
- **services**: Business logic orchestration tests  
- **controllers**: HTTP handler and API tests
- **repositories**: Data access layer tests
- **integration**: End-to-end tests with real dependencies

## Security Best Practices

### Input Validation
- Validate **all user inputs** at the controller layer
- Use **parameterized queries** to prevent SQL injection
- Implement **input sanitization** for all user-provided data
- Use **struct tags** for validation rules

### Error Handling
- Use **structured logging** for debugging and monitoring
- **Sanitize sensitive data** in logs and responses
- Implement **proper error wrapping** with context
- Provide **meaningful error messages** without exposing internals

### Authentication & Authorization
- Implement **middleware** for authentication
- Use **context** to pass user information through request pipeline
- Validate **permissions** at the service layer
- Implement **audit logging** for security events

## Development Commands

### Cross-Platform Development
```bash
# Linux/macOS
cd backend && go run ./cmd/siros-server
go test ./...
go build -o siros-server ./cmd/siros-server

# Windows
cd backend; go run ./cmd/siros-server
go test ./...
go build -o siros-server.exe ./cmd/siros-server
```

### Testing
```bash
# Run comprehensive test suite
./scripts/test.sh                    # Linux/macOS
.\scripts\test.ps1                   # Windows

# Run specific test suite with coverage
./scripts/test.sh --suite models --coverage     # Linux/macOS
.\scripts\test.ps1 -TestSuite models -Coverage  # Windows
```

## Performance Considerations

### Database Optimization
- Use **connection pooling** for database connections
- Implement **proper indexing** for vector similarity queries
- Use **prepared statements** for frequently executed queries
- Consider **read replicas** for high-traffic scenarios

### Concurrency
- Think about **concurrency** and **race conditions**
- Use **context** for cancellation and timeouts
- Implement **proper locking** for shared resources
- Consider **worker pools** for parallel processing

### Memory Management
- Be mindful of **memory allocation** for large datasets
- Use **streaming** for large data processing
- Implement **proper cleanup** of resources
- Monitor **garbage collection** performance

## Deployment Considerations

### Single Binary Deployment
- **Embed frontend assets** in Go binary using `embed.FS`
- Support **configuration via files and environment variables**
- Implement **graceful shutdown** and **health checks**
- Provide **Docker images** for containerized deployment

### Configuration Management
- Use **environment variables** for sensitive configuration
- Provide **default values** for optional settings
- Implement **configuration validation** at startup
- Support **hot reloading** of non-sensitive configuration

### Monitoring and Observability
- Implement **structured logging** with appropriate levels
- Add **metrics collection** for key operations
- Include **health check endpoints** for monitoring
- Implement **distributed tracing** for complex operations