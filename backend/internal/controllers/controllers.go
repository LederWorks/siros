package controllers

import (
	"log"

	"github.com/LederWorks/siros/backend/internal/services"
)

// Controllers holds all controller instances
type Controllers struct {
	Health    *HealthController
	Resource  *ResourceController
	Search    *SearchController
	Schema    *SchemaController
	Terraform *TerraformController
	MCP       *MCPController
	Audit     *AuditController
}

// NewControllers creates a new Controllers instance with all controllers
func NewControllers(services *services.Services, logger *log.Logger) *Controllers {
	return &Controllers{
		Health:    NewHealthController(logger),
		Resource:  NewResourceController(services.Resource, logger),
		Search:    NewSearchController(logger),    // TODO: Add services.Search when available
		Schema:    NewSchemaController(logger),    // TODO: Add services.Schema when available
		Terraform: NewTerraformController(logger), // TODO: Add services.Terraform when available
		MCP:       NewMCPController(logger),       // TODO: Add services.MCP when available
		Audit:     NewAuditController(logger),
	}
}
