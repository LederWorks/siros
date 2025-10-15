package services

import (
	"context"
	"crypto/rand"
	"fmt"
	"log"
	"time"

	"github.com/LederWorks/siros/backend/internal/models"
	"github.com/LederWorks/siros/backend/internal/repositories"
)

// simpleResourceService is a simplified implementation of ResourceService
type simpleResourceService struct {
	resourceRepo repositories.ResourceRepository
	logger       *log.Logger
}

// NewSimpleResourceService creates a simplified resource service
func NewSimpleResourceService(resourceRepo repositories.ResourceRepository, logger *log.Logger) ResourceService {
	return &simpleResourceService{
		resourceRepo: resourceRepo,
		logger:       logger,
	}
}

// generateID generates a simple unique ID
func (s *simpleResourceService) generateID() string {
	b := make([]byte, 16)
	if _, err := rand.Read(b); err != nil {
		// Fall back to timestamp-based ID if random generation fails
		return fmt.Sprintf("%d", time.Now().UnixNano())
	}
	return fmt.Sprintf("%x", b)
}

func (s *simpleResourceService) CreateResource(ctx context.Context, req *models.CreateResourceRequest) (*models.Resource, error) {
	// Validate the request
	if err := req.Validate(); err != nil {
		return nil, fmt.Errorf("validation failed: %w", err)
	}

	// Convert request to resource model
	resource := req.ToResource()

	// Generate unique ID
	resource.ID = s.generateID()

	// Validate the resource
	if err := resource.Validate(); err != nil {
		return nil, fmt.Errorf("resource validation failed: %w", err)
	}

	// Store the resource
	if err := s.resourceRepo.Create(ctx, resource); err != nil {
		return nil, fmt.Errorf("failed to store resource: %w", err)
	}

	s.logger.Printf("Created resource: %s", resource.ID)
	return resource, nil
}

func (s *simpleResourceService) GetResource(ctx context.Context, id string) (*models.Resource, error) {
	if id == "" {
		return nil, fmt.Errorf("resource ID is required")
	}

	resource, err := s.resourceRepo.GetByID(ctx, id)
	if err != nil {
		return nil, fmt.Errorf("failed to get resource: %w", err)
	}

	return resource, nil
}

func (s *simpleResourceService) UpdateResource(ctx context.Context, id string, req models.UpdateResourceRequest, modifiedBy string) (*models.Resource, error) {
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

	// Apply updates
	req.ApplyTo(resource, modifiedBy)

	// Validate updated resource
	if err := resource.Validate(); err != nil {
		return nil, fmt.Errorf("updated resource validation failed: %w", err)
	}

	// Update the resource
	if err := s.resourceRepo.Update(ctx, resource); err != nil {
		return nil, fmt.Errorf("failed to update resource: %w", err)
	}

	s.logger.Printf("Updated resource: %s", resource.ID)
	return resource, nil
}

func (s *simpleResourceService) DeleteResource(ctx context.Context, id string, deletedBy string) error {
	if id == "" {
		return fmt.Errorf("resource ID is required")
	}

	if deletedBy == "" {
		return fmt.Errorf("deleted_by is required")
	}

	// Delete the resource
	if err := s.resourceRepo.Delete(ctx, id); err != nil {
		return fmt.Errorf("failed to delete resource: %w", err)
	}

	s.logger.Printf("Deleted resource: %s by %s", id, deletedBy)
	return nil
}

func (s *simpleResourceService) ListResources(ctx context.Context, query *models.SearchQuery) ([]models.Resource, error) {
	// Validate and set defaults
	if err := query.Validate(); err != nil {
		return nil, fmt.Errorf("query validation failed: %w", err)
	}
	query.SetDefaults()

	resources, err := s.resourceRepo.List(ctx, *query)
	if err != nil {
		return nil, fmt.Errorf("failed to list resources: %w", err)
	}

	return resources, nil
}

func (s *simpleResourceService) SearchResources(ctx context.Context, query *models.SearchQuery) ([]models.Resource, error) {
	// Validate and set defaults
	if err := query.Validate(); err != nil {
		return nil, fmt.Errorf("query validation failed: %w", err)
	}
	query.SetDefaults()

	resources, err := s.resourceRepo.Search(ctx, *query)
	if err != nil {
		return nil, fmt.Errorf("failed to search resources: %w", err)
	}

	return resources, nil
}

func (s *simpleResourceService) GetResourcesByParent(ctx context.Context, parentID string) ([]models.Resource, error) {
	if parentID == "" {
		return nil, fmt.Errorf("parent ID is required")
	}

	resources, err := s.resourceRepo.GetByParentID(ctx, parentID)
	if err != nil {
		return nil, fmt.Errorf("failed to get resources by parent: %w", err)
	}

	return resources, nil
}
