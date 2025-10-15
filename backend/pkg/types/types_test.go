package types

import (
	"testing"
	"time"
)

func TestResourceState(t *testing.T) {
	states := []ResourceState{
		ResourceStateActive,
		ResourceStateInactive,
		ResourceStateTerminated,
		ResourceStateError,
		ResourceStateUnknown,
	}

	expectedValues := []string{
		"active",
		"inactive",
		"terminated",
		"error",
		"unknown",
	}

	for i, state := range states {
		if string(state) != expectedValues[i] {
			t.Errorf("Expected state '%s', got: '%s'", expectedValues[i], string(state))
		}
	}
}

func TestResourceCreation(t *testing.T) {
	now := time.Now()
	resource := Resource{
		ID:       "test-resource-1",
		Type:     "test.resource",
		Provider: "test",
		Region:   "us-east-1",
		Name:     "Test Resource",
		Tags: map[string]string{
			"environment": "test",
			"team":        "platform",
		},
		Metadata: map[string]interface{}{
			"test_key": "test_value",
			"count":    42,
		},
		State:     ResourceStateActive,
		CreatedAt: now,
		UpdatedAt: now,
	}

	// Test basic properties
	if resource.ID != "test-resource-1" {
		t.Errorf("Expected ID 'test-resource-1', got: %s", resource.ID)
	}

	if resource.State != ResourceStateActive {
		t.Errorf("Expected state 'active', got: %s", string(resource.State))
	}

	if len(resource.Tags) != 2 {
		t.Errorf("Expected 2 tags, got: %d", len(resource.Tags))
	}

	if resource.Tags["environment"] != "test" {
		t.Errorf("Expected tag 'environment' = 'test', got: %s", resource.Tags["environment"])
	}
}

func TestAPIResponse(t *testing.T) {
	response := APIResponse{
		Success: true,
		Data:    "test data",
		Meta: &Meta{
			Total:  100,
			Page:   1,
			Limit:  50,
			Offset: 0,
		},
	}

	if !response.Success {
		t.Error("Expected success to be true")
	}

	if response.Data != "test data" {
		t.Errorf("Expected data 'test data', got: %v", response.Data)
	}

	if response.Meta.Total != 100 {
		t.Errorf("Expected total 100, got: %d", response.Meta.Total)
	}
}

func TestSearchQuery(t *testing.T) {
	query := SearchQuery{
		Query: "web servers",
		Filters: map[string]string{
			"provider": "aws",
			"type":     "ec2.instance",
		},
		Providers: []string{"aws", "azure"},
		Types:     []string{"ec2.instance", "azure.vm"},
		Limit:     50,
		Offset:    0,
	}

	if query.Query != "web servers" {
		t.Errorf("Expected query 'web servers', got: %s", query.Query)
	}

	if len(query.Filters) != 2 {
		t.Errorf("Expected 2 filters, got: %d", len(query.Filters))
	}

	if query.Filters["provider"] != "aws" {
		t.Errorf("Expected filter provider 'aws', got: %s", query.Filters["provider"])
	}
}
