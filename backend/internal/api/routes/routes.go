package routes

import (
	"github.com/LederWorks/siros/backend/internal/controllers"
	"github.com/gorilla/mux"
)

// Router handles all API route configuration
type Router struct {
	controllers *controllers.Controllers
}

// NewRouter creates a new router with the provided controllers
func NewRouter(controllers *controllers.Controllers) *Router {
	return &Router{
		controllers: controllers,
	}
}

// SetupRoutes configures all API routes
func (r *Router) SetupRoutes() *mux.Router {
	router := mux.NewRouter()

	// API base path
	api := router.PathPrefix("/api/v1").Subrouter()

	// Setup route groups
	r.setupHealthRoutes(api)
	r.setupResourceRoutes(api)
	r.setupSearchRoutes(api)
	r.setupSchemaRoutes(api)
	r.setupTerraformRoutes(api)
	r.setupMCPRoutes(api)
	r.setupAuditRoutes(api)

	return router
}

// setupHealthRoutes configures health check and system status routes
func (r *Router) setupHealthRoutes(api *mux.Router) {
	// Root health endpoint
	api.HandleFunc("/health", r.controllers.Health.Check).Methods("GET")

	health := api.PathPrefix("/health").Subrouter()
	health.HandleFunc("/check", r.controllers.Health.Check).Methods("GET")
	health.HandleFunc("/version", r.controllers.Health.Version).Methods("GET")
}

// setupResourceRoutes configures resource management routes
func (r *Router) setupResourceRoutes(api *mux.Router) {
	resources := api.PathPrefix("/resources").Subrouter()

	// CRUD operations
	resources.HandleFunc("", r.controllers.Resource.List).Methods("GET")
	resources.HandleFunc("", r.controllers.Resource.Create).Methods("POST")
	resources.HandleFunc("/{id}", r.controllers.Resource.Get).Methods("GET")
	resources.HandleFunc("/{id}", r.controllers.Resource.Update).Methods("PUT")
	resources.HandleFunc("/{id}", r.controllers.Resource.Delete).Methods("DELETE")

	// Resource relationships
	resources.HandleFunc("/{id}/relationships", r.controllers.Resource.GetRelationships).Methods("GET")
	resources.HandleFunc("/{id}/children", r.controllers.Resource.GetChildren).Methods("GET")
	resources.HandleFunc("/{id}/parents", r.controllers.Resource.GetParents).Methods("GET")
}

// setupSearchRoutes configures search and discovery routes
func (r *Router) setupSearchRoutes(api *mux.Router) {
	search := api.PathPrefix("/search").Subrouter()

	// Semantic search using vector embeddings
	search.HandleFunc("", r.controllers.Search.Semantic).Methods("POST")
	search.HandleFunc("/text", r.controllers.Search.Text).Methods("POST")
	search.HandleFunc("/similarity", r.controllers.Search.Similarity).Methods("POST")

	// Discovery endpoints
	discovery := api.PathPrefix("/discovery").Subrouter()
	discovery.HandleFunc("/scan", r.controllers.Search.ScanProviders).Methods("POST")
	discovery.HandleFunc("/relationships", r.controllers.Search.DiscoverRelationships).Methods("POST")
}

// setupSchemaRoutes configures schema management routes
func (r *Router) setupSchemaRoutes(api *mux.Router) {
	schemas := api.PathPrefix("/schemas").Subrouter()

	schemas.HandleFunc("", r.controllers.Schema.List).Methods("GET")
	schemas.HandleFunc("", r.controllers.Schema.Create).Methods("POST")
	schemas.HandleFunc("/{name}", r.controllers.Schema.Get).Methods("GET")
	schemas.HandleFunc("/{name}", r.controllers.Schema.Update).Methods("PUT")
	schemas.HandleFunc("/{name}", r.controllers.Schema.Delete).Methods("DELETE")
	schemas.HandleFunc("/{name}/validate", r.controllers.Schema.Validate).Methods("POST")
}

// setupTerraformRoutes configures Terraform integration routes
func (r *Router) setupTerraformRoutes(api *mux.Router) {
	terraform := api.PathPrefix("/terraform").Subrouter()

	// Terraform state import and management
	terraform.HandleFunc("/import", r.controllers.Terraform.ImportState).Methods("POST")
	terraform.HandleFunc("/state", r.controllers.Terraform.GetState).Methods("GET")
	terraform.HandleFunc("/coverage", r.controllers.Terraform.AnalyzeCoverage).Methods("GET")

	// siros_key resource management (for Terraform provider)
	terraform.HandleFunc("/siros_key", r.controllers.Terraform.CreateKey).Methods("POST")
	terraform.HandleFunc("/siros_key/{key}", r.controllers.Terraform.GetKey).Methods("GET")
	terraform.HandleFunc("/siros_key/{key}", r.controllers.Terraform.UpdateKey).Methods("PUT")
	terraform.HandleFunc("/siros_key/{key}", r.controllers.Terraform.DeleteKey).Methods("DELETE")
	terraform.HandleFunc("/siros_key_path", r.controllers.Terraform.QueryByPath).Methods("POST")
}

// setupMCPRoutes configures Model Context Protocol routes
func (r *Router) setupMCPRoutes(api *mux.Router) {
	mcp := api.PathPrefix("/mcp").Subrouter()

	// MCP protocol endpoints
	mcp.HandleFunc("/initialize", r.controllers.MCP.Initialize).Methods("POST")
	mcp.HandleFunc("/resources/list", r.controllers.MCP.ListResources).Methods("POST")
	mcp.HandleFunc("/resources/read", r.controllers.MCP.ReadResource).Methods("POST")
	mcp.HandleFunc("/tools/list", r.controllers.MCP.ListTools).Methods("POST")
	mcp.HandleFunc("/tools/call", r.controllers.MCP.CallTool).Methods("POST")
	mcp.HandleFunc("/prompts/list", r.controllers.MCP.ListPrompts).Methods("POST")
	mcp.HandleFunc("/prompts/get", r.controllers.MCP.GetPrompt).Methods("POST")
}

// setupAuditRoutes configures blockchain audit trail routes
func (r *Router) setupAuditRoutes(api *mux.Router) {
	audit := api.PathPrefix("/audit").Subrouter()

	audit.HandleFunc("/trail/{id}", r.controllers.Audit.GetAuditTrail).Methods("GET")
	audit.HandleFunc("/changes", r.controllers.Audit.ListChanges).Methods("GET")
	audit.HandleFunc("/verify/{id}", r.controllers.Audit.VerifyIntegrity).Methods("GET")
}
