package routes

import (
	"github.com/gorilla/mux"

	"github.com/LederWorks/siros/backend/internal/controllers"
)

// SetupAPIRoutes configures all API routes
func SetupAPIRoutes(router *mux.Router, controllers *controllers.Controllers) {
	// API routes with /api/v1 prefix
	api := router.PathPrefix("/api/v1").Subrouter()

	// Health endpoints
	api.HandleFunc("/health", controllers.Health.Check).Methods("GET")
	api.HandleFunc("/version", controllers.Health.Version).Methods("GET")

	// Resource endpoints
	resources := api.PathPrefix("/resources").Subrouter()
	resources.HandleFunc("", controllers.Resource.List).Methods("GET")
	resources.HandleFunc("", controllers.Resource.Create).Methods("POST")
	resources.HandleFunc("/{id}", controllers.Resource.Get).Methods("GET")
	resources.HandleFunc("/{id}", controllers.Resource.Update).Methods("PUT")
	resources.HandleFunc("/{id}", controllers.Resource.Delete).Methods("DELETE")

	// Search endpoints
	search := api.PathPrefix("/search").Subrouter()
	search.HandleFunc("", controllers.Search.Semantic).Methods("POST") // Use Semantic instead of Resources
	search.HandleFunc("/semantic", controllers.Search.Semantic).Methods("POST")
	search.HandleFunc("/text", controllers.Search.Text).Methods("POST")
	search.HandleFunc("/similarity", controllers.Search.Similarity).Methods("POST")

	// Discovery endpoints
	discovery := api.PathPrefix("/discovery").Subrouter()
	discovery.HandleFunc("/scan", controllers.Search.ScanProviders).Methods("POST")
	discovery.HandleFunc("/relationships", controllers.Search.DiscoverRelationships).Methods("POST")

	// Schema endpoints
	schemas := api.PathPrefix("/schemas").Subrouter()
	schemas.HandleFunc("", controllers.Schema.List).Methods("GET")
	schemas.HandleFunc("", controllers.Schema.Create).Methods("POST")
	schemas.HandleFunc("/{id}", controllers.Schema.Get).Methods("GET")
	schemas.HandleFunc("/{id}", controllers.Schema.Update).Methods("PUT")
	schemas.HandleFunc("/{id}", controllers.Schema.Delete).Methods("DELETE")

	// Terraform endpoints
	terraform := api.PathPrefix("/terraform").Subrouter()
	terraform.HandleFunc("/import", controllers.Terraform.ImportState).Methods("POST")
	terraform.HandleFunc("/state", controllers.Terraform.GetState).Methods("GET")
	terraform.HandleFunc("/coverage", controllers.Terraform.AnalyzeCoverage).Methods("GET")
	terraform.HandleFunc("/plan", controllers.Terraform.Plan).Methods("POST")
	terraform.HandleFunc("/apply", controllers.Terraform.Apply).Methods("POST")

	// Terraform siros_key endpoints
	terraform.HandleFunc("/siros_key", controllers.Terraform.CreateKey).Methods("POST")
	terraform.HandleFunc("/siros_key/{key}", controllers.Terraform.GetKey).Methods("GET")
	terraform.HandleFunc("/siros_key/{key}", controllers.Terraform.UpdateKey).Methods("PUT")
	terraform.HandleFunc("/siros_key/{key}", controllers.Terraform.DeleteKey).Methods("DELETE")
	terraform.HandleFunc("/siros_key_path", controllers.Terraform.QueryByPath).Methods("POST")

	// MCP endpoints
	mcp := api.PathPrefix("/mcp").Subrouter()
	mcp.HandleFunc("/initialize", controllers.MCP.Initialize).Methods("POST")
	mcp.HandleFunc("/resources/list", controllers.MCP.ListResources).Methods("POST")
	mcp.HandleFunc("/resources/read", controllers.MCP.ReadResource).Methods("POST")
	mcp.HandleFunc("/tools/list", controllers.MCP.ListTools).Methods("POST")
	mcp.HandleFunc("/tools/call", controllers.MCP.CallTool).Methods("POST")
	mcp.HandleFunc("/prompts/list", controllers.MCP.ListPrompts).Methods("POST")
	mcp.HandleFunc("/prompts/get", controllers.MCP.GetPrompt).Methods("POST")
}
