package models

import (
	"testing"
	"time"
)

func TestResource_Validate(t *testing.T) {
	tests := []struct {
		name      string
		resource  Resource
		wantError bool
	}{
		{
			name: "valid resource",
			resource: Resource{
				ID:       "test-id",
				Type:     "test-type",
				Provider: "aws",
				Name:     "test-resource",
				Data:     map[string]interface{}{"key": "value"},
				Metadata: ResourceMetadata{
					CreatedBy:  "test-user",
					ModifiedBy: "test-user",
				},
				CreatedAt:  time.Now(),
				ModifiedAt: time.Now(),
			},
			wantError: false,
		},
		{
			name: "empty ID",
			resource: Resource{
				Type:     "test-type",
				Provider: "aws",
				Name:     "test-resource",
				Metadata: ResourceMetadata{
					CreatedBy:  "test-user",
					ModifiedBy: "test-user",
				},
			},
			wantError: true,
		},
		{
			name: "empty type",
			resource: Resource{
				ID:       "test-id",
				Provider: "aws",
				Name:     "test-resource",
				Metadata: ResourceMetadata{
					CreatedBy:  "test-user",
					ModifiedBy: "test-user",
				},
			},
			wantError: true,
		},
		{
			name: "invalid provider",
			resource: Resource{
				ID:       "test-id",
				Type:     "test-type",
				Provider: "invalid-provider",
				Name:     "test-resource",
				Metadata: ResourceMetadata{
					CreatedBy:  "test-user",
					ModifiedBy: "test-user",
				},
			},
			wantError: true,
		},
		{
			name: "empty metadata created_by",
			resource: Resource{
				ID:       "test-id",
				Type:     "test-type",
				Provider: "aws",
				Name:     "test-resource",
				Metadata: ResourceMetadata{
					ModifiedBy: "test-user",
				},
			},
			wantError: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tt.resource.Validate()
			if (err != nil) != tt.wantError {
				t.Errorf("Resource.Validate() error = %v, wantError %v", err, tt.wantError)
			}
		})
	}
}

func TestResource_IsVectorized(t *testing.T) {
	resource := Resource{}

	// Test without vector
	if resource.IsVectorized() {
		t.Error("Resource should not be vectorized when vector is empty")
	}

	// Test with vector
	resource.Vector = []float32{1.0, 2.0, 3.0}
	if !resource.IsVectorized() {
		t.Error("Resource should be vectorized when vector is not empty")
	}
}

func TestResource_HasParent(t *testing.T) {
	resource := Resource{}

	// Test without parent
	if resource.HasParent() {
		t.Error("Resource should not have parent when parent_id is nil")
	}

	// Test with empty parent
	empty := ""
	resource.ParentID = &empty
	if resource.HasParent() {
		t.Error("Resource should not have parent when parent_id is empty")
	}

	// Test with parent
	parent := "parent-id"
	resource.ParentID = &parent
	if !resource.HasParent() {
		t.Error("Resource should have parent when parent_id is set")
	}
}

func TestResource_TagOperations(t *testing.T) {
	resource := Resource{
		Metadata: ResourceMetadata{},
	}

	// Test getting non-existent tag
	value := resource.GetTag("env")
	if value != "" {
		t.Errorf("Expected empty string for non-existent tag, got %s", value)
	}

	// Test setting tag
	resource.SetTag("env", "production")
	value = resource.GetTag("env")
	if value != "production" {
		t.Errorf("Expected 'production', got %s", value)
	}

	// Test overwriting tag
	resource.SetTag("env", "staging")
	value = resource.GetTag("env")
	if value != "staging" {
		t.Errorf("Expected 'staging', got %s", value)
	}
}

func TestCreateResourceRequest_Validate(t *testing.T) {
	tests := []struct {
		name      string
		request   CreateResourceRequest
		wantError bool
	}{
		{
			name: "valid request",
			request: CreateResourceRequest{
				Type:     "test-type",
				Provider: "aws",
				Name:     "test-resource",
				Data:     map[string]interface{}{"key": "value"},
				Metadata: ResourceMetadata{
					CreatedBy:  "test-user",
					ModifiedBy: "test-user",
				},
			},
			wantError: false,
		},
		{
			name: "empty type",
			request: CreateResourceRequest{
				Provider: "aws",
				Name:     "test-resource",
				Data:     map[string]interface{}{"key": "value"},
				Metadata: ResourceMetadata{
					CreatedBy:  "test-user",
					ModifiedBy: "test-user",
				},
			},
			wantError: true,
		},
		{
			name: "nil data",
			request: CreateResourceRequest{
				Type:     "test-type",
				Provider: "aws",
				Name:     "test-resource",
				Metadata: ResourceMetadata{
					CreatedBy:  "test-user",
					ModifiedBy: "test-user",
				},
			},
			wantError: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tt.request.Validate()
			if (err != nil) != tt.wantError {
				t.Errorf("CreateResourceRequest.Validate() error = %v, wantError %v", err, tt.wantError)
			}
		})
	}
}

func TestCreateResourceRequest_ToResource(t *testing.T) {
	request := CreateResourceRequest{
		Type:     "test-type",
		Provider: "aws",
		Name:     "test-resource",
		Data:     map[string]interface{}{"key": "value"},
		Metadata: ResourceMetadata{
			CreatedBy:  "test-user",
			ModifiedBy: "test-user",
		},
	}

	resource := request.ToResource()

	if resource.Type != request.Type {
		t.Errorf("Expected type %s, got %s", request.Type, resource.Type)
	}

	if resource.Provider != request.Provider {
		t.Errorf("Expected provider %s, got %s", request.Provider, resource.Provider)
	}

	if resource.Name != request.Name {
		t.Errorf("Expected name %s, got %s", request.Name, resource.Name)
	}

	if resource.CreatedAt.IsZero() {
		t.Error("CreatedAt should be set")
	}

	if resource.ModifiedAt.IsZero() {
		t.Error("ModifiedAt should be set")
	}
}

func TestSearchQuery_Validate(t *testing.T) {
	tests := []struct {
		name      string
		query     SearchQuery
		wantError bool
	}{
		{
			name: "valid query",
			query: SearchQuery{
				Query:     "test",
				Limit:     10,
				Offset:    0,
				SortOrder: "asc",
			},
			wantError: false,
		},
		{
			name: "negative limit",
			query: SearchQuery{
				Limit: -1,
			},
			wantError: true,
		},
		{
			name: "negative offset",
			query: SearchQuery{
				Offset: -1,
			},
			wantError: true,
		},
		{
			name: "invalid sort order",
			query: SearchQuery{
				SortOrder: "invalid",
			},
			wantError: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tt.query.Validate()
			if (err != nil) != tt.wantError {
				t.Errorf("SearchQuery.Validate() error = %v, wantError %v", err, tt.wantError)
			}
		})
	}
}

func TestSearchQuery_SetDefaults(t *testing.T) {
	query := SearchQuery{}
	query.SetDefaults()

	if query.Limit != 50 {
		t.Errorf("Expected default limit 50, got %d", query.Limit)
	}

	if query.SortBy != "created_at" {
		t.Errorf("Expected default sort_by 'created_at', got %s", query.SortBy)
	}

	if query.SortOrder != "desc" {
		t.Errorf("Expected default sort_order 'desc', got %s", query.SortOrder)
	}

	// Test limit capping
	query.Limit = 2000
	query.SetDefaults()
	if query.Limit != 1000 {
		t.Errorf("Expected capped limit 1000, got %d", query.Limit)
	}
}
