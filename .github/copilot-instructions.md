# GitHub Copilot Instructions for Siros

## 🏗️ Project Overview

Siros is a Go-based multi-cloud resource platform with a React TypeScript frontend, structured as a monorepo with clean backend/frontend separation. The platform provides unified resource management across AWS, Azure, and Google Cloud Platform with semantic search, blockchain change tracking, and multiple API interfaces.

## 📂 Repository Structure

```
siros/
├── backend/                      # Go backend code
│   ├── cmd/siros-server/         # Main entry point
│   ├── internal/                 # Non-exported application code
│   │   ├── api/                  # API layer (HTTP/Terraform/MCP)
│   │   ├── storage/              # Storage layer (PostgreSQL + pgvector)
│   │   ├── providers/            # Cloud provider integrations
│   │   ├── config/               # Configuration management
│   │   ├── blockchain/           # Blockchain integration
│   │   └── terraform/            # Terraform integration
│   ├── pkg/types/                # Shared type definitions
│   └── static/                   # Built frontend assets (embedded)
│
├── frontend/                     # React + TypeScript portal
│   ├── src/
│   │   ├── components/           # Reusable UI components
│   │   ├── pages/                # Views (Dashboard, Resources, Graph, Search)
│   │   └── api/                  # Type-safe API client
│
└── scripts/                      # Build & deployment scripts
    ├── build_all.sh             # Production build (embed frontend in Go binary)
    └── dev.sh                   # Development mode (hot reload)
```

## 🎯 Coding Guidelines

### General Principles
- **Monorepo Structure**: Maintain clean separation between backend and frontend
- **Type Safety**: Use TypeScript for frontend and Go's strong typing for backend
- **API-First Design**: Design APIs that can be consumed by multiple clients
- **Production Ready**: Write code that's ready for production deployment

### Backend (Go) Guidelines

#### Architecture Patterns
- Use **internal packages** for application-specific code
- Follow **clean architecture** principles with clear layer separation
- Implement **dependency injection** for testability
- Use **interfaces** for abstractions between layers

#### Code Style
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

#### API Development
- Use **Gorilla Mux** for HTTP routing
- Implement **middleware** for CORS, logging, and authentication
- Follow **REST conventions** for endpoint design
- Provide **JSON responses** with consistent error formats
- Support **filtering, pagination, and sorting** for list endpoints

#### Database Integration
- Use **PostgreSQL** with **pgvector** extension for vector operations
- Implement **prepared statements** to prevent SQL injection
- Use **database transactions** for atomic operations
- Create **proper indexes** for query performance

### Frontend (React + TypeScript) Guidelines

#### Component Architecture
```tsx
// Use functional components with hooks
interface ResourceCardProps {
  resource: Resource;
  onEdit: (resource: Resource) => void;
}

export const ResourceCard: React.FC<ResourceCardProps> = ({ resource, onEdit }) => {
  // Component implementation
};
```

#### State Management
- Use **React hooks** (useState, useEffect, useReducer) for local state
- Consider **Context API** for global state if needed
- Implement **custom hooks** for reusable logic

#### API Integration
```typescript
// Create type-safe API client functions
export async function fetchResources(filters?: ResourceFilters): Promise<Resource[]> {
  const response = await fetch('/api/v1/resources', {
    method: 'GET',
    headers: { 'Content-Type': 'application/json' },
  });
  
  if (!response.ok) {
    throw new Error(`Failed to fetch resources: ${response.statusText}`);
  }
  
  return response.json();
}
```

#### Styling
- Use **CSS-in-JS** for component styling (styled-jsx or similar)
- Follow **responsive design** principles
- Maintain **consistent design system** across components
- Use **semantic HTML** for accessibility

## 🔧 Development Workflow

### Development Commands
```bash
# Start development environment (both backend and frontend)
./scripts/dev.sh

# Build production version (embed frontend in Go binary)
./scripts/build_all.sh

# Backend development
cd backend && go run ./cmd/siros-server

# Frontend development
cd frontend && npm run dev
```

### Testing Guidelines
- Write **unit tests** for all business logic
- Create **integration tests** for API endpoints
- Use **test fixtures** for consistent test data
- Mock **external dependencies** (cloud providers, databases)

#### Go Testing
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

#### React Testing
```tsx
import { render, screen, fireEvent } from '@testing-library/react';

test('renders resource card with correct data', () => {
  const mockResource = { id: '1', name: 'Test Resource' };
  render(<ResourceCard resource={mockResource} onEdit={jest.fn()} />);
  
  expect(screen.getByText('Test Resource')).toBeInTheDocument();
});
```

## 🌐 Multi-Cloud Integration

### Provider Pattern
```go
type CloudProvider interface {
    ListResources(ctx context.Context, filters ResourceFilters) ([]Resource, error)
    GetResource(ctx context.Context, id string) (*Resource, error)
    CreateResource(ctx context.Context, spec ResourceSpec) (*Resource, error)
    UpdateResource(ctx context.Context, id string, updates ResourceUpdates) (*Resource, error)
    DeleteResource(ctx context.Context, id string) error
}

// Implement for each cloud provider
type AWSProvider struct {
    ec2Client *ec2.Client
    s3Client  *s3.Client
    rdsClient *rds.Client
}
```

### Resource Modeling
- Use **consistent resource schemas** across providers
- Implement **provider-specific adapters** to normalize data
- Support **cross-cloud relationships** and hierarchies
- Store **metadata as JSON** with **vector embeddings** for search

## 🔍 API Design Patterns

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
```

### Response Formats
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
```

## 🚀 Deployment Considerations

### Single Binary Deployment
- **Embed frontend assets** in Go binary using `embed.FS`
- Support **configuration via files and environment variables**
- Implement **graceful shutdown** and **health checks**
- Provide **Docker images** for containerized deployment

### Security Best Practices
- Validate **all user inputs**
- Use **parameterized queries** to prevent SQL injection
- Implement **CORS** properly for frontend integration
- **Sanitize sensitive data** in logs and responses
- Use **HTTPS** in production

## 🧪 When Suggesting Code

### For Backend Changes
- Consider **error handling** and **edge cases**
- Ensure **database transactions** are used when needed
- Add **appropriate logging** for debugging
- Consider **performance implications** of database queries
- Think about **concurrency** and **race conditions**

### For Frontend Changes
- Ensure **TypeScript types** are properly defined
- Consider **loading states** and **error handling**
- Think about **user experience** and **accessibility**
- Ensure **responsive design** works on different screen sizes
- Consider **SEO** implications for public pages

### For API Changes
- Maintain **backward compatibility** when possible
- Update **API documentation** and **TypeScript types**
- Consider **versioning** for breaking changes
- Think about **rate limiting** and **caching**
- Ensure **proper HTTP status codes**

## 🎨 UI/UX Guidelines

### Design Principles
- **Clean and modern** interface design
- **Responsive** layout that works on mobile and desktop
- **Consistent** color scheme and typography
- **Intuitive** navigation and user flows
- **Accessible** design following WCAG guidelines

### Component Patterns
- Create **reusable components** for common UI elements
- Use **consistent prop interfaces** across similar components
- Implement **loading states** and **error boundaries**
- Support **keyboard navigation** and **screen readers**

This file helps GitHub Copilot understand the Siros project structure, coding patterns, and best practices to provide more contextually appropriate suggestions.