package controllers

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"

	"github.com/LederWorks/siros/backend/internal/models"
	"github.com/gorilla/mux"
)

// Mock ResourceService for testing
type mockResourceService struct {
	resources map[string]*models.Resource
}

func newMockResourceService() *mockResourceService {
	return &mockResourceService{
		resources: make(map[string]*models.Resource),
	}
}

func (m *mockResourceService) CreateResource(_ context.Context, req *models.CreateResourceRequest) (*models.Resource, error) {
	resource := &models.Resource{
		ID:       "test-id",
		Type:     req.Type,
		Provider: req.Provider,
		Name:     req.Name,
		Data:     req.Data,
		Metadata: req.Metadata,
		Vector:   []float32{1.0, 2.0, 3.0},
	}
	m.resources[resource.ID] = resource
	return resource, nil
}

func (m *mockResourceService) GetResource(_ context.Context, id string) (*models.Resource, error) {
	if resource, exists := m.resources[id]; exists {
		return resource, nil
	}
	return nil, fmt.Errorf("resource not found: %s", id)
}

func (m *mockResourceService) UpdateResource(_ context.Context, id string, req models.UpdateResourceRequest, _ string) (*models.Resource, error) {
	if resource, exists := m.resources[id]; exists {
		if req.Name != nil {
			resource.Name = *req.Name
		}
		if req.Data != nil {
			resource.Data = req.Data
		}
		return resource, nil
	}
	return nil, fmt.Errorf("resource not found: %s", id)
}

func (m *mockResourceService) DeleteResource(_ context.Context, id, _ string) error {
	if _, exists := m.resources[id]; exists {
		delete(m.resources, id)
		return nil
	}
	return fmt.Errorf("resource not found: %s", id)
}

func (m *mockResourceService) ListResources(_ context.Context, _ *models.SearchQuery) ([]models.Resource, error) {
	var result []models.Resource
	for _, resource := range m.resources {
		result = append(result, *resource)
	}
	return result, nil
}

func (m *mockResourceService) SearchResources(_ context.Context, query *models.SearchQuery) ([]models.Resource, error) {
	return m.ListResources(context.Background(), query)
}

func (m *mockResourceService) GetResourcesByParent(_ context.Context, parentID string) ([]models.Resource, error) {
	var result []models.Resource
	for _, resource := range m.resources {
		if resource.ParentID != nil && *resource.ParentID == parentID {
			result = append(result, *resource)
		}
	}
	return result, nil
}

func (m *mockResourceService) VectorSearchResources(_ context.Context, _ []float32, _ float32, _ int) ([]models.Resource, error) {
	return []models.Resource{}, nil
}

func TestResourceController_CreateResource(t *testing.T) {
	// Setup
	mockService := newMockResourceService()
	logger := log.New(os.Stderr, "test: ", log.LstdFlags)
	controller := NewResourceController(mockService, logger)

	// Test valid request
	requestBody := models.CreateResourceRequest{
		Type:     "test-type",
		Provider: "aws",
		Name:     "test-resource",
		Data:     map[string]interface{}{"key": "value"},
		Metadata: models.ResourceMetadata{
			CreatedBy:  "test-user",
			ModifiedBy: "test-user",
		},
	}

	body, _ := json.Marshal(requestBody)
	req := httptest.NewRequest("POST", "/api/v1/resources", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()

	controller.CreateResource(w, req)

	// Check response
	if w.Code != http.StatusCreated {
		t.Errorf("Expected status %d, got %d", http.StatusCreated, w.Code)
	}

	var response map[string]interface{}
	if err := json.Unmarshal(w.Body.Bytes(), &response); err != nil {
		t.Fatalf("Failed to unmarshal response: %v", err)
	}

	data := response["data"].(map[string]interface{})
	if data["id"] != "test-id" {
		t.Errorf("Expected ID 'test-id', got %v", data["id"])
	}

	// Test invalid JSON
	req = httptest.NewRequest("POST", "/api/v1/resources", bytes.NewBuffer([]byte("invalid json")))
	req.Header.Set("Content-Type", "application/json")
	w = httptest.NewRecorder()

	controller.CreateResource(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("Expected status %d for invalid JSON, got %d", http.StatusBadRequest, w.Code)
	}
}

func TestResourceController_GetResource(t *testing.T) {
	// Setup
	mockService := newMockResourceService()
	logger := log.New(os.Stderr, "test: ", log.LstdFlags)
	controller := NewResourceController(mockService, logger)

	// Add a test resource
	testResource := &models.Resource{
		ID:       "test-id",
		Type:     "test-type",
		Provider: "aws",
		Name:     "test-resource",
		Data:     map[string]interface{}{"key": "value"},
	}
	mockService.resources["test-id"] = testResource

	// Test valid request
	req := httptest.NewRequest("GET", "/api/v1/resources/test-id", http.NoBody)
	req = mux.SetURLVars(req, map[string]string{"id": "test-id"})
	w := httptest.NewRecorder()

	controller.GetResource(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("Expected status %d, got %d", http.StatusOK, w.Code)
	}

	var response map[string]interface{}
	if err := json.Unmarshal(w.Body.Bytes(), &response); err != nil {
		t.Fatalf("Failed to unmarshal response: %v", err)
	}

	data := response["data"].(map[string]interface{})
	if data["id"] != "test-id" {
		t.Errorf("Expected ID 'test-id', got %v", data["id"])
	}

	// Test non-existent resource
	req = httptest.NewRequest("GET", "/api/v1/resources/non-existent", http.NoBody)
	req = mux.SetURLVars(req, map[string]string{"id": "non-existent"})
	w = httptest.NewRecorder()

	controller.GetResource(w, req)

	if w.Code != http.StatusNotFound {
		t.Errorf("Expected status %d for non-existent resource, got %d", http.StatusNotFound, w.Code)
	}
}

func TestResourceController_UpdateResource(t *testing.T) {
	// Setup
	mockService := newMockResourceService()
	logger := log.New(os.Stderr, "test: ", log.LstdFlags)
	controller := NewResourceController(mockService, logger)

	// Add a test resource
	testResource := &models.Resource{
		ID:       "test-id",
		Type:     "test-type",
		Provider: "aws",
		Name:     "test-resource",
		Data:     map[string]interface{}{"key": "value"},
	}
	mockService.resources["test-id"] = testResource

	// Test valid update
	updateReq := models.UpdateResourceRequest{
		Name: stringPtr("updated-name"),
		Data: map[string]interface{}{"key": "updated-value"},
	}

	body, _ := json.Marshal(updateReq)
	req := httptest.NewRequest("PUT", "/api/v1/resources/test-id", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	req = mux.SetURLVars(req, map[string]string{"id": "test-id"})
	w := httptest.NewRecorder()

	controller.UpdateResource(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("Expected status %d, got %d", http.StatusOK, w.Code)
	}

	var response map[string]interface{}
	if err := json.Unmarshal(w.Body.Bytes(), &response); err != nil {
		t.Fatalf("Failed to unmarshal response: %v", err)
	}

	data := response["data"].(map[string]interface{})
	if data["name"] != "updated-name" {
		t.Errorf("Expected name 'updated-name', got %v", data["name"])
	}
}

func TestResourceController_DeleteResource(t *testing.T) {
	// Setup
	mockService := newMockResourceService()
	logger := log.New(os.Stderr, "test: ", log.LstdFlags)
	controller := NewResourceController(mockService, logger)

	// Add a test resource
	testResource := &models.Resource{
		ID:       "test-id",
		Type:     "test-type",
		Provider: "aws",
		Name:     "test-resource",
		Data:     map[string]interface{}{"key": "value"},
	}
	mockService.resources["test-id"] = testResource

	// Test valid delete
	req := httptest.NewRequest("DELETE", "/api/v1/resources/test-id", http.NoBody)
	req = mux.SetURLVars(req, map[string]string{"id": "test-id"})
	w := httptest.NewRecorder()

	controller.DeleteResource(w, req)

	if w.Code != http.StatusNoContent {
		t.Errorf("Expected status %d, got %d", http.StatusNoContent, w.Code)
	}

	// Verify resource is deleted
	if _, exists := mockService.resources["test-id"]; exists {
		t.Error("Resource should have been deleted")
	}

	// Test delete non-existent resource
	req = httptest.NewRequest("DELETE", "/api/v1/resources/non-existent", http.NoBody)
	req = mux.SetURLVars(req, map[string]string{"id": "non-existent"})
	w = httptest.NewRecorder()

	controller.DeleteResource(w, req)

	if w.Code != http.StatusNotFound {
		t.Errorf("Expected status %d for non-existent resource, got %d", http.StatusNotFound, w.Code)
	}
}

func TestResourceController_ListResources(t *testing.T) {
	// Setup
	mockService := newMockResourceService()
	logger := log.New(os.Stderr, "test: ", log.LstdFlags)
	controller := NewResourceController(mockService, logger)

	// Add test resources
	mockService.resources["test-1"] = &models.Resource{
		ID:       "test-1",
		Type:     "test-type",
		Provider: "aws",
		Name:     "test-resource-1",
	}
	mockService.resources["test-2"] = &models.Resource{
		ID:       "test-2",
		Type:     "test-type",
		Provider: "azure",
		Name:     "test-resource-2",
	}

	// Test list all resources
	req := httptest.NewRequest("GET", "/api/v1/resources", http.NoBody)
	w := httptest.NewRecorder()

	controller.ListResources(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("Expected status %d, got %d", http.StatusOK, w.Code)
	}

	var response map[string]interface{}
	if err := json.Unmarshal(w.Body.Bytes(), &response); err != nil {
		t.Fatalf("Failed to unmarshal response: %v", err)
	}

	data := response["data"].([]interface{})
	if len(data) != 2 {
		t.Errorf("Expected 2 resources, got %d", len(data))
	}
}

func TestResourceController_SearchResources(t *testing.T) {
	// Setup
	mockService := newMockResourceService()
	logger := log.New(os.Stderr, "test: ", log.LstdFlags)
	controller := NewResourceController(mockService, logger)

	// Add test resources
	mockService.resources["test-1"] = &models.Resource{
		ID:       "test-1",
		Type:     "test-type",
		Provider: "aws",
		Name:     "test-resource-1",
	}

	// Test search
	req := httptest.NewRequest("POST", "/api/v1/search", bytes.NewBuffer([]byte(`{"query":"test"}`)))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()

	controller.SearchResources(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("Expected status %d, got %d", http.StatusOK, w.Code)
	}
}

// Helper function for string pointers
func stringPtr(s string) *string {
	return &s
}
