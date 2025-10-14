package terraform

import (
	"context"
	"encoding/json"
	"fmt"
	"log"

	"github.com/LederWorks/siros/pkg/types"
	"github.com/LederWorks/siros/internal/storage"
)

// StateImporter handles Terraform state imports
type StateImporter struct {
	storage *storage.Storage
}

// NewStateImporter creates a new Terraform state importer
func NewStateImporter(storage *storage.Storage) *StateImporter {
	return &StateImporter{
		storage: storage,
	}
}

// ImportState imports resources from Terraform state
func (si *StateImporter) ImportState(ctx context.Context, state *types.TerraformState) ([]types.Resource, error) {
	var resources []types.Resource

	for _, tfResource := range state.Resources {
		for _, instance := range tfResource.Instances {
			resource, err := si.convertTerraformResource(tfResource, instance)
			if err != nil {
				log.Printf("Failed to convert Terraform resource %s: %v", tfResource.Name, err)
				continue
			}
			resources = append(resources, *resource)
		}
	}

	// Store resources in database
	for _, resource := range resources {
		if err := si.storage.CreateResource(ctx, &resource); err != nil {
			log.Printf("Failed to store resource %s: %v", resource.ID, err)
		}
	}

	return resources, nil
}

// convertTerraformResource converts a Terraform resource to Siros resource
func (si *StateImporter) convertTerraformResource(tfResource types.TerraformResource, instance types.TerraformInstance) (*types.Resource, error) {
	// Extract common attributes
	id, ok := instance.Attributes["id"].(string)
	if !ok {
		return nil, fmt.Errorf("missing or invalid 'id' attribute")
	}

	name, _ := instance.Attributes["name"].(string)
	if name == "" {
		name = fmt.Sprintf("%s.%s", tfResource.Type, tfResource.Name)
	}

	// Map Terraform resource type to Siros type
	resourceType := mapTerraformType(tfResource.Type)
	provider := extractProvider(tfResource.Provider)

	// Extract tags if present
	tags := make(map[string]string)
	if tagMap, ok := instance.Attributes["tags"].(map[string]interface{}); ok {
		for k, v := range tagMap {
			if strVal, ok := v.(string); ok {
				tags[k] = strVal
			}
		}
	}

	resource := &types.Resource{
		ID:       id,
		Type:     resourceType,
		Provider: provider,
		Name:     name,
		Tags:     tags,
		Metadata: map[string]interface{}{
			"terraform_type":     tfResource.Type,
			"terraform_name":     tfResource.Name,
			"terraform_module":   tfResource.Module,
			"schema_version":     instance.SchemaVersion,
			"dependencies":       instance.Dependencies,
			"attributes":         instance.Attributes,
		},
		State: types.ResourceStateActive, // Assume active if in Terraform state
	}

	// Extract region if available
	if region, ok := instance.Attributes["region"].(string); ok {
		resource.Region = region
	} else if availabilityZone, ok := instance.Attributes["availability_zone"].(string); ok {
		// Extract region from AZ (e.g., "us-east-1a" -> "us-east-1")
		if len(availabilityZone) > 2 {
			resource.Region = availabilityZone[:len(availabilityZone)-1]
		}
	}

	// Extract ARN if available
	if arn, ok := instance.Attributes["arn"].(string); ok {
		resource.ARN = arn
	}

	return resource, nil
}

// mapTerraformType maps Terraform resource types to Siros types
func mapTerraformType(tfType string) string {
	typeMapping := map[string]string{
		"aws_instance":          "ec2.instance",
		"aws_s3_bucket":         "s3.bucket",
		"aws_db_instance":       "rds.instance",
		"aws_lambda_function":   "lambda.function",
		"aws_vpc":               "ec2.vpc",
		"aws_subnet":            "ec2.subnet",
		"aws_security_group":    "ec2.security_group",
		"azurerm_virtual_machine": "azure.virtualmachine",
		"azurerm_storage_account": "azure.storageaccount",
		"google_compute_instance": "gcp.compute.instance",
		"google_storage_bucket":   "gcp.storage.bucket",
	}

	if mapped, exists := typeMapping[tfType]; exists {
		return mapped
	}

	// Default: use terraform type with "terraform." prefix
	return fmt.Sprintf("terraform.%s", tfType)
}

// extractProvider extracts provider name from Terraform provider string
func extractProvider(providerStr string) string {
	// Provider strings are typically like:
	// "provider[\"registry.terraform.io/hashicorp/aws\"]"
	// We want to extract "aws"
	
	if providerStr == "" {
		return "unknown"
	}

	// Simple extraction - look for known providers
	if contains(providerStr, "aws") {
		return "aws"
	}
	if contains(providerStr, "azurerm") {
		return "azure"
	}
	if contains(providerStr, "google") {
		return "gcp"
	}

	return "terraform"
}

// contains checks if a string contains a substring (case-insensitive)
func contains(s, substr string) bool {
	return len(s) >= len(substr) && 
		   (s == substr || 
		    s[:len(substr)] == substr || 
		    s[len(s)-len(substr):] == substr ||
		    findInString(s, substr))
}

func findInString(s, substr string) bool {
	for i := 0; i <= len(s)-len(substr); i++ {
		if s[i:i+len(substr)] == substr {
			return true
		}
	}
	return false
}

// ParseTerraformState parses a Terraform state JSON string
func ParseTerraformState(stateJSON string) (*types.TerraformState, error) {
	var state types.TerraformState
	if err := json.Unmarshal([]byte(stateJSON), &state); err != nil {
		return nil, fmt.Errorf("failed to parse Terraform state: %w", err)
	}
	return &state, nil
}