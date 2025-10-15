package services

import (
	"context"
	"log"

	"github.com/LederWorks/siros/backend/internal/repositories"
)

// Services holds all service instances
type Services struct {
	Resource  ResourceService
	Search    SearchService
	Schema    SchemaService
	Terraform TerraformService
	MCP       MCPService
}

// SearchService defines the interface for search operations
type SearchService interface {
	SemanticSearch(ctx context.Context, query string, filters SearchFilters) ([]SearchResult, error)
	TextSearch(ctx context.Context, query string, filters SearchFilters) ([]SearchResult, error)
	SimilaritySearch(ctx context.Context, resourceID string, limit int) ([]SearchResult, error)
	ScanProviders(ctx context.Context, providers []string) (*ProviderScanResult, error)
	DiscoverRelationships(ctx context.Context, resourceID string) ([]ResourceRelationship, error)
}

// MCPService defines the interface for Model Context Protocol operations
type MCPService interface {
	Initialize(ctx context.Context, req MCPInitRequest) (*MCPInitResponse, error)
	ListResources(ctx context.Context) ([]MCPResource, error)
	ReadResource(ctx context.Context, uri string) (*MCPResourceContent, error)
	ListTools(ctx context.Context) ([]MCPTool, error)
	CallTool(ctx context.Context, name string, arguments map[string]interface{}) (*MCPToolResult, error)
	ListPrompts(ctx context.Context) ([]MCPPrompt, error)
	GetPrompt(ctx context.Context, name string, arguments map[string]interface{}) (*MCPPromptResult, error)
}

// Additional type definitions
type SearchFilters map[string]interface{}
type SearchResult map[string]interface{}
type ProviderScanResult map[string]interface{}
type ResourceRelationship struct {
	ID         string                 `json:"id"`
	SourceID   string                 `json:"source_id"`
	TargetID   string                 `json:"target_id"`
	Type       string                 `json:"type"`
	Direction  string                 `json:"direction"`
	Confidence float64                `json:"confidence"`
	Properties map[string]interface{} `json:"properties,omitempty"`
}

// MCP types
type MCPInitRequest map[string]interface{}
type MCPInitResponse map[string]interface{}
type MCPResource map[string]interface{}
type MCPResourceContent map[string]interface{}
type MCPTool map[string]interface{}
type MCPToolResult map[string]interface{}
type MCPPrompt map[string]interface{}
type MCPPromptResult map[string]interface{}

// NewServices creates a new Services instance with all services
func NewServices(repos *repositories.Repositories, logger *log.Logger) *Services {
	// Create simplified services for now
	return &Services{
		Resource:  NewSimpleResourceService(repos.Resource, logger),
		Search:    NewSearchService(repos.Resource, logger),
		Schema:    NewSchemaService(repos.Schema, logger),
		Terraform: NewTerraformService(repos.Resource, logger),
		MCP:       NewMCPService(repos.Resource, logger),
	}
}
