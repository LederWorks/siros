package services

import (
	"context"
	"fmt"
	"log"

	"github.com/LederWorks/siros/backend/internal/models"
)

// ResourceService defines the interface for resource business logic
type ResourceService interface {
	CreateResource(ctx context.Context, req models.CreateResourceRequest) (*models.Resource, error)
	GetResource(ctx context.Context, id string) (*models.Resource, error)
	UpdateResource(ctx context.Context, id string, req models.UpdateResourceRequest, modifiedBy string) (*models.Resource, error)
	DeleteResource(ctx context.Context, id string, deletedBy string) error
	ListResources(ctx context.Context, query models.SearchQuery) ([]models.Resource, error)
	SearchResources(ctx context.Context, query models.SearchQuery) ([]models.Resource, error)
	GetResourcesByParent(ctx context.Context, parentID string) ([]models.Resource, error)
}

// VectorService defines the interface for vector operations
type VectorService interface {
	GenerateVector(ctx context.Context, data map[string]interface{}, metadata models.ResourceMetadata) ([]float32, error)
	FindSimilarResources(ctx context.Context, vector []float32, threshold float32, limit int) ([]models.Resource, error)
	UpdateVector(ctx context.Context, resourceID string, vector []float32) error
}

// BlockchainService defines the interface for blockchain operations
type BlockchainService interface {
	RecordChange(ctx context.Context, resourceID, operation, actor string, changes map[string]interface{}) error
	GetAuditTrail(ctx context.Context, resourceID string) ([]models.ChangeRecord, error)
	VerifyIntegrity(ctx context.Context, resourceID string) (bool, error)
}

// SchemaService defines the interface for schema operations
type SchemaService interface {
	CreateSchema(ctx context.Context, schema models.Schema) error
	GetSchema(ctx context.Context, name, provider string) (*models.Schema, error)
	ListSchemas(ctx context.Context, provider string) ([]models.Schema, error)
	UpdateSchema(ctx context.Context, name, provider string, schema models.Schema) error
	DeleteSchema(ctx context.Context, name, provider string) error
}

// TerraformService defines the interface for Terraform operations
type TerraformService interface {
	StoreKey(ctx context.Context, key models.TerraformKey) error
	GetKey(ctx context.Context, key string) (*models.TerraformKey, error)
	ListKeysByPath(ctx context.Context, path string) ([]models.TerraformKey, error)
	DeleteKey(ctx context.Context, key string) error
}

// ResourceRepository defines the interface for resource data access
type ResourceRepository interface {
	Create(ctx context.Context, resource *models.Resource) error
	GetByID(ctx context.Context, id string) (*models.Resource, error)
	Update(ctx context.Context, resource *models.Resource) error
	Delete(ctx context.Context, id string) error
	List(ctx context.Context, query models.SearchQuery) ([]models.Resource, error)
	Search(ctx context.Context, query models.SearchQuery) ([]models.Resource, error)
	GetByParentID(ctx context.Context, parentID string) ([]models.Resource, error)
	VectorSearch(ctx context.Context, vector []float32, threshold float32, limit int) ([]models.Resource, error)
}

// BlockchainRepository defines the interface for blockchain data access
type BlockchainRepository interface {
	CreateRecord(ctx context.Context, record *models.ChangeRecord) error
	GetRecordsByResourceID(ctx context.Context, resourceID string) ([]models.ChangeRecord, error)
	GetLatestRecord(ctx context.Context, resourceID string) (*models.ChangeRecord, error)
}

// SchemaRepository defines the interface for schema data access
type SchemaRepository interface {
	Create(ctx context.Context, schema *models.Schema) error
	GetByNameAndProvider(ctx context.Context, name, provider string) (*models.Schema, error)
	List(ctx context.Context, provider string) ([]models.Schema, error)
	Update(ctx context.Context, schema *models.Schema) error
	Delete(ctx context.Context, name, provider string) error
}

// TerraformRepository defines the interface for Terraform data access
type TerraformRepository interface {
	Create(ctx context.Context, key *models.TerraformKey) error
	GetByKey(ctx context.Context, key string) (*models.TerraformKey, error)
	ListByPath(ctx context.Context, path string) ([]models.TerraformKey, error)
	Update(ctx context.Context, key *models.TerraformKey) error
	Delete(ctx context.Context, key string) error
}

// resourceService implements ResourceService
type resourceService struct {
	resourceRepo      ResourceRepository
	vectorService     VectorService
	blockchainService BlockchainService
	idGenerator       IDGenerator
}

// IDGenerator defines the interface for generating unique IDs
type IDGenerator interface {
	Generate() string
}

// NewResourceService creates a new resource service
func NewResourceService(
	resourceRepo ResourceRepository,
	vectorService VectorService,
	blockchainService BlockchainService,
	idGenerator IDGenerator,
) ResourceService {
	return &resourceService{
		resourceRepo:      resourceRepo,
		vectorService:     vectorService,
		blockchainService: blockchainService,
		idGenerator:       idGenerator,
	}
}

func (s *resourceService) CreateResource(ctx context.Context, req models.CreateResourceRequest) (*models.Resource, error) {
	// Validate the request
	if err := req.Validate(); err != nil {
		return nil, fmt.Errorf("validation failed: %w", err)
	}

	// Convert request to resource model
	resource := req.ToResource()

	// Generate unique ID
	resource.ID = s.idGenerator.Generate()

	// Validate the resource
	if err := resource.Validate(); err != nil {
		return nil, fmt.Errorf("resource validation failed: %w", err)
	}

	// Generate vector for the resource
	vector, err := s.vectorService.GenerateVector(ctx, resource.Data, resource.Metadata)
	if err != nil {
		return nil, fmt.Errorf("failed to generate vector: %w", err)
	}
	resource.Vector = vector

	// Store the resource
	if err := s.resourceRepo.Create(ctx, resource); err != nil {
		return nil, fmt.Errorf("failed to store resource: %w", err)
	}

	// Record the change in blockchain
	changes := map[string]interface{}{
		"operation": "CREATE",
		"resource":  resource,
	}

	if err := s.blockchainService.RecordChange(ctx, resource.ID, "CREATE", resource.Metadata.CreatedBy, changes); err != nil {
		// Log but don't fail the operation
		log.Printf("Failed to record blockchain change for resource creation %s: %v", resource.ID, err)
	}

	return resource, nil
}

func (s *resourceService) GetResource(ctx context.Context, id string) (*models.Resource, error) {
	if id == "" {
		return nil, fmt.Errorf("resource ID is required")
	}

	resource, err := s.resourceRepo.GetByID(ctx, id)
	if err != nil {
		return nil, fmt.Errorf("failed to get resource: %w", err)
	}

	return resource, nil
}

func (s *resourceService) UpdateResource(ctx context.Context, id string, req models.UpdateResourceRequest, modifiedBy string) (*models.Resource, error) {
	if id == "" {
		return nil, fmt.Errorf("resource ID is required")
	}

	if modifiedBy == "" {
		return nil, fmt.Errorf("modified_by is required")
	}

	// Validate the request
	if err := req.Validate(); err != nil {
		return nil, fmt.Errorf("validation failed: %w", err)
	}

	// Get existing resource
	resource, err := s.resourceRepo.GetByID(ctx, id)
	if err != nil {
		return nil, fmt.Errorf("failed to get resource: %w", err)
	}

	// Store original data for change tracking
	originalData := resource.Data

	// Apply updates
	req.ApplyTo(resource, modifiedBy)

	// Validate updated resource
	if err := resource.Validate(); err != nil {
		return nil, fmt.Errorf("updated resource validation failed: %w", err)
	}

	// Regenerate vector if data changed
	if req.Data != nil {
		vector, err := s.vectorService.GenerateVector(ctx, resource.Data, resource.Metadata)
		if err != nil {
			return nil, fmt.Errorf("failed to generate vector: %w", err)
		}
		resource.Vector = vector
	}

	// Update the resource
	if err := s.resourceRepo.Update(ctx, resource); err != nil {
		return nil, fmt.Errorf("failed to update resource: %w", err)
	}

	// Record the change in blockchain
	changes := map[string]interface{}{
		"operation":     "UPDATE",
		"original_data": originalData,
		"updated_data":  resource.Data,
		"changes":       req,
	}

	if err := s.blockchainService.RecordChange(ctx, resource.ID, "UPDATE", modifiedBy, changes); err != nil {
		// Log but don't fail the operation
		log.Printf("Failed to record blockchain change for resource update %s: %v", resource.ID, err)
	}

	return resource, nil
}

func (s *resourceService) DeleteResource(ctx context.Context, id string, deletedBy string) error {
	if id == "" {
		return fmt.Errorf("resource ID is required")
	}

	if deletedBy == "" {
		return fmt.Errorf("deleted_by is required")
	}

	// Get existing resource for change tracking
	resource, err := s.resourceRepo.GetByID(ctx, id)
	if err != nil {
		return fmt.Errorf("failed to get resource: %w", err)
	}

	// Delete the resource
	if err := s.resourceRepo.Delete(ctx, id); err != nil {
		return fmt.Errorf("failed to delete resource: %w", err)
	}

	// Record the change in blockchain
	changes := map[string]interface{}{
		"operation":        "DELETE",
		"deleted_resource": resource,
	}

	if err := s.blockchainService.RecordChange(ctx, id, "DELETE", deletedBy, changes); err != nil {
		// Log but don't fail the operation
		log.Printf("Failed to record blockchain change for resource deletion %s: %v", id, err)
	}

	return nil
}

func (s *resourceService) ListResources(ctx context.Context, query models.SearchQuery) ([]models.Resource, error) {
	// Validate and set defaults
	if err := query.Validate(); err != nil {
		return nil, fmt.Errorf("query validation failed: %w", err)
	}
	query.SetDefaults()

	resources, err := s.resourceRepo.List(ctx, query)
	if err != nil {
		return nil, fmt.Errorf("failed to list resources: %w", err)
	}

	return resources, nil
}

func (s *resourceService) SearchResources(ctx context.Context, query models.SearchQuery) ([]models.Resource, error) {
	// Validate and set defaults
	if err := query.Validate(); err != nil {
		return nil, fmt.Errorf("query validation failed: %w", err)
	}
	query.SetDefaults()

	resources, err := s.resourceRepo.Search(ctx, query)
	if err != nil {
		return nil, fmt.Errorf("failed to search resources: %w", err)
	}

	return resources, nil
}

func (s *resourceService) GetResourcesByParent(ctx context.Context, parentID string) ([]models.Resource, error) {
	if parentID == "" {
		return nil, fmt.Errorf("parent ID is required")
	}

	resources, err := s.resourceRepo.GetByParentID(ctx, parentID)
	if err != nil {
		return nil, fmt.Errorf("failed to get resources by parent: %w", err)
	}

	return resources, nil
}
