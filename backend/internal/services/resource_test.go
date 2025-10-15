package services

import (
	"context"
	"fmt"
	"testing"
	"time"

	"github.com/LederWorks/siros/backend/internal/models"
)

const testResourceID = "test-id"

// Mock implementations for testing

type mockResourceRepository struct {
	resources map[string]*models.Resource
}

func newMockResourceRepository() *mockResourceRepository {
	return &mockResourceRepository{
		resources: make(map[string]*models.Resource),
	}
}

func (m *mockResourceRepository) Create(_ context.Context, resource *models.Resource) error {
	m.resources[resource.ID] = resource
	return nil
}

func (m *mockResourceRepository) GetByID(_ context.Context, id string) (*models.Resource, error) {
	if resource, exists := m.resources[id]; exists {
		return resource, nil
	}
	return nil, fmt.Errorf("resource not found: %s", id)
}

func (m *mockResourceRepository) Update(_ context.Context, resource *models.Resource) error {
	if _, exists := m.resources[resource.ID]; !exists {
		return fmt.Errorf("resource not found: %s", resource.ID)
	}
	m.resources[resource.ID] = resource
	return nil
}

func (m *mockResourceRepository) Delete(_ context.Context, id string) error {
	if _, exists := m.resources[id]; !exists {
		return fmt.Errorf("resource not found: %s", id)
	}
	delete(m.resources, id)
	return nil
}

func (m *mockResourceRepository) List(_ context.Context, _ models.SearchQuery) ([]models.Resource, error) {
	var result []models.Resource
	for _, resource := range m.resources {
		result = append(result, *resource)
	}
	return result, nil
}

func (m *mockResourceRepository) Search(_ context.Context, _ models.SearchQuery) ([]models.Resource, error) {
	return m.List(context.Background(), models.SearchQuery{})
}

func (m *mockResourceRepository) GetByParentID(_ context.Context, parentID string) ([]models.Resource, error) {
	var result []models.Resource
	for _, resource := range m.resources {
		if resource.ParentID != nil && *resource.ParentID == parentID {
			result = append(result, *resource)
		}
	}
	return result, nil
}

func (m *mockResourceRepository) VectorSearch(_ context.Context, _ []float32, _ float32, _ int) ([]models.Resource, error) {
	return []models.Resource{}, nil
}

type mockVectorService struct{}

func (m *mockVectorService) GenerateVector(_ context.Context, _ map[string]interface{}, _ models.ResourceMetadata) ([]float32, error) {
	return []float32{1.0, 2.0, 3.0}, nil
}

func (m *mockVectorService) FindSimilarResources(_ context.Context, _ []float32, _ float32, _ int) ([]models.Resource, error) {
	return []models.Resource{}, nil
}

func (m *mockVectorService) UpdateVector(_ context.Context, _ string, _ []float32) error {
	return nil
}

type mockBlockchainService struct{}

func (m *mockBlockchainService) RecordChange(_ context.Context, _, _, _ string, _ map[string]interface{}) error {
	return nil
}

func (m *mockBlockchainService) GetAuditTrail(_ context.Context, _ string) ([]models.ChangeRecord, error) {
	return []models.ChangeRecord{}, nil
}

func (m *mockBlockchainService) VerifyIntegrity(_ context.Context, _ string) (bool, error) {
	return true, nil
}

type mockIDGenerator struct{}

func (m *mockIDGenerator) Generate() string {
	return testResourceID
}

func TestResourceService_CreateResource(t *testing.T) {
	// Setup
	repo := newMockResourceRepository()
	vectorService := &mockVectorService{}
	blockchainService := &mockBlockchainService{}
	idGenerator := &mockIDGenerator{}

	service := NewResourceService(repo, vectorService, blockchainService, idGenerator)

	// Test valid resource creation
	req := models.CreateResourceRequest{
		Type:     "test-type",
		Provider: "aws",
		Name:     "test-resource",
		Data:     map[string]interface{}{"key": "value"},
		Metadata: models.ResourceMetadata{
			CreatedBy:  "test-user",
			ModifiedBy: "test-user",
		},
	}

	resource, err := service.CreateResource(context.Background(), &req)
	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}

	if resource.ID != "test-id" {
		t.Errorf("Expected ID 'test-id', got %s", resource.ID)
	}

	if resource.Type != req.Type {
		t.Errorf("Expected type %s, got %s", req.Type, resource.Type)
	}

	if len(resource.Vector) == 0 {
		t.Error("Expected vector to be generated")
	}

	// Test invalid resource creation
	invalidReq := models.CreateResourceRequest{
		Type: "", // Empty type should fail validation
	}

	_, err = service.CreateResource(context.Background(), &invalidReq)
	if err == nil {
		t.Error("Expected validation error for invalid request")
	}
}

func TestResourceService_GetResource(t *testing.T) {
	// Setup
	repo := newMockResourceRepository()
	vectorService := &mockVectorService{}
	blockchainService := &mockBlockchainService{}
	idGenerator := &mockIDGenerator{}

	service := NewResourceService(repo, vectorService, blockchainService, idGenerator)

	// Create a test resource
	testResource := &models.Resource{
		ID:       "test-id",
		Type:     "test-type",
		Provider: "aws",
		Name:     "test-resource",
		Data:     map[string]interface{}{"key": "value"},
		Metadata: models.ResourceMetadata{
			CreatedBy:  "test-user",
			ModifiedBy: "test-user",
		},
		CreatedAt:  time.Now(),
		ModifiedAt: time.Now(),
	}
	repo.resources["test-id"] = testResource

	// Test getting existing resource
	resource, err := service.GetResource(context.Background(), "test-id")
	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}

	if resource.ID != "test-id" {
		t.Errorf("Expected ID 'test-id', got %s", resource.ID)
	}

	// Test getting non-existent resource
	_, err = service.GetResource(context.Background(), "non-existent")
	if err == nil {
		t.Error("Expected error for non-existent resource")
	}

	// Test empty ID
	_, err = service.GetResource(context.Background(), "")
	if err == nil {
		t.Error("Expected error for empty ID")
	}
}

func TestResourceService_UpdateResource(t *testing.T) {
	// Setup
	repo := newMockResourceRepository()
	vectorService := &mockVectorService{}
	blockchainService := &mockBlockchainService{}
	idGenerator := &mockIDGenerator{}

	service := NewResourceService(repo, vectorService, blockchainService, idGenerator)

	// Create a test resource
	testResource := &models.Resource{
		ID:       "test-id",
		Type:     "test-type",
		Provider: "aws",
		Name:     "test-resource",
		Data:     map[string]interface{}{"key": "value"},
		Metadata: models.ResourceMetadata{
			CreatedBy:  "test-user",
			ModifiedBy: "test-user",
		},
		CreatedAt:  time.Now(),
		ModifiedAt: time.Now(),
	}
	repo.resources["test-id"] = testResource

	// Test update
	updateReq := models.UpdateResourceRequest{
		Name: stringPtr("updated-name"),
		Data: map[string]interface{}{"key": "updated-value"},
	}

	updatedResource, err := service.UpdateResource(context.Background(), "test-id", updateReq, "test-modifier")
	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}

	if updatedResource.Name != "updated-name" {
		t.Errorf("Expected name 'updated-name', got %s", updatedResource.Name)
	}

	if updatedResource.Metadata.ModifiedBy != "test-modifier" {
		t.Errorf("Expected modified_by 'test-modifier', got %s", updatedResource.Metadata.ModifiedBy)
	}

	// Test update non-existent resource
	_, err = service.UpdateResource(context.Background(), "non-existent", updateReq, "test-modifier")
	if err == nil {
		t.Error("Expected error for non-existent resource")
	}
}

func TestResourceService_DeleteResource(t *testing.T) {
	// Setup
	repo := newMockResourceRepository()
	vectorService := &mockVectorService{}
	blockchainService := &mockBlockchainService{}
	idGenerator := &mockIDGenerator{}

	service := NewResourceService(repo, vectorService, blockchainService, idGenerator)

	// Create a test resource
	testResource := &models.Resource{
		ID:       "test-id",
		Type:     "test-type",
		Provider: "aws",
		Name:     "test-resource",
		Data:     map[string]interface{}{"key": "value"},
		Metadata: models.ResourceMetadata{
			CreatedBy:  "test-user",
			ModifiedBy: "test-user",
		},
		CreatedAt:  time.Now(),
		ModifiedAt: time.Now(),
	}
	repo.resources["test-id"] = testResource

	// Test delete
	err := service.DeleteResource(context.Background(), "test-id", "test-deleter")
	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}

	// Verify resource is deleted
	_, err = service.GetResource(context.Background(), "test-id")
	if err == nil {
		t.Error("Expected error after resource deletion")
	}

	// Test delete non-existent resource
	err = service.DeleteResource(context.Background(), "non-existent", "test-deleter")
	if err == nil {
		t.Error("Expected error for non-existent resource")
	}
}

// Helper function for string pointers
func stringPtr(s string) *string {
	return &s
}
