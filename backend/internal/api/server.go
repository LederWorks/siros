package api

import (
	"embed"
	"encoding/json"
	"fmt"
	"io/fs"
	"net/http"
	"strconv"
	"strings"

	"github.com/LederWorks/siros/backend/internal/config"
	"github.com/LederWorks/siros/backend/internal/storage"
	"github.com/LederWorks/siros/backend/pkg/types"
	"github.com/gorilla/mux"
	"github.com/rs/cors"
)

// Server represents the HTTP API server
type Server struct {
	config   *config.Config
	storage  *storage.Storage
	router   *mux.Router
	webAssets embed.FS
}

// NewServer creates a new API server
func NewServer(cfg *config.Config, storage *storage.Storage, webAssets embed.FS) *Server {
	s := &Server{
		config:    cfg,
		storage:   storage,
		router:    mux.NewRouter(),
		webAssets: webAssets,
	}

	s.setupRoutes()
	return s
}

// Router returns the HTTP router
func (s *Server) Router() http.Handler {
	// Setup CORS
	c := cors.New(cors.Options{
		AllowedOrigins: []string{"*"},
		AllowedMethods: []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowedHeaders: []string{"*"},
	})

	return c.Handler(s.router)
}

// setupRoutes configures the API routes
func (s *Server) setupRoutes() {
	// API routes
	api := s.router.PathPrefix("/api/v1").Subrouter()
	
	// Resources
	api.HandleFunc("/resources", s.listResources).Methods("GET")
	api.HandleFunc("/resources", s.createResource).Methods("POST")
	api.HandleFunc("/resources/{id}", s.getResource).Methods("GET")
	api.HandleFunc("/resources/{id}", s.updateResource).Methods("PUT")
	api.HandleFunc("/resources/{id}", s.deleteResource).Methods("DELETE")
	
	// Search
	api.HandleFunc("/search", s.searchResources).Methods("POST")
	
	// Schemas
	api.HandleFunc("/schemas", s.listSchemas).Methods("GET")
	api.HandleFunc("/schemas", s.createSchema).Methods("POST")
	api.HandleFunc("/schemas/{id}", s.getSchema).Methods("GET")
	
	// Health check
	api.HandleFunc("/health", s.healthCheck).Methods("GET")
	
	// Terraform integration
	api.HandleFunc("/terraform/state", s.importTerraformState).Methods("POST")
	
	// MCP protocol endpoints
	api.HandleFunc("/mcp/initialize", s.mcpInitialize).Methods("POST")
	api.HandleFunc("/mcp/resources/list", s.mcpListResources).Methods("POST")
	api.HandleFunc("/mcp/resources/read", s.mcpReadResource).Methods("POST")
	
	// Serve embedded web assets
	s.setupWebRoutes()
}

// setupWebRoutes serves the embedded React frontend
func (s *Server) setupWebRoutes() {
	// Serve static files from embedded filesystem
	webFS, err := fs.Sub(s.webAssets, "web/dist")
	if err == nil {
		s.router.PathPrefix("/").Handler(http.FileServer(http.FS(webFS)))
	} else {
		// Fallback for development
		s.router.PathPrefix("/").HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.Header().Set("Content-Type", "text/html")
			if _, err := w.Write([]byte(`
<!DOCTYPE html>
<html>
<head>
    <title>Siros - Multi-Cloud Resource Platform</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .header { text-align: center; margin-bottom: 40px; }
        .api-link { display: inline-block; margin: 10px; padding: 10px 20px; background: #007cba; color: white; text-decoration: none; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🌐 Siros</h1>
            <p>Multi-Cloud Resource Platform</p>
        </div>
        <h2>API Endpoints</h2>
        <a href="/api/v1/health" class="api-link">Health Check</a>
        <a href="/api/v1/resources" class="api-link">Resources</a>
        <a href="/api/v1/schemas" class="api-link">Schemas</a>
        <h2>Features</h2>
        <ul>
            <li>✅ HTTP API for resource management</li>
            <li>✅ PostgreSQL with pgvector for semantic search</li>
            <li>✅ Multi-cloud provider support (AWS, Azure, GCP)</li>
            <li>✅ Terraform integration</li>
            <li>✅ MCP (Model Context Protocol) API</li>
            <li>🔄 Blockchain change tracking</li>
            <li>🔄 React frontend (embedded in binary)</li>
        </ul>
    </div>
</body>
</html>
			`)); err != nil {
				http.Error(w, "Failed to write response", http.StatusInternalServerError)
			}
		})
	}
}

// RegisterRoutes registers HTTP routes for the API
func RegisterRoutes(mux *http.ServeMux) {
	// Health check endpoint
	mux.HandleFunc("/api/v1/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		if err := json.NewEncoder(w).Encode(map[string]string{
			"status": "healthy",
			"service": "siros-backend",
		}); err != nil {
			http.Error(w, "Failed to encode response", http.StatusInternalServerError)
		}
	})

	// Resources endpoint
	mux.HandleFunc("/api/v1/resources", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		if err := json.NewEncoder(w).Encode(map[string]interface{}{
			"resources": []map[string]string{},
			"total": 0,
		}); err != nil {
			http.Error(w, "Failed to encode response", http.StatusInternalServerError)
		}
	})

	// Schemas endpoint
	mux.HandleFunc("/api/v1/schemas", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		if err := json.NewEncoder(w).Encode(map[string]interface{}{
			"schemas": []string{"ec2.instance", "s3.bucket", "rds.instance"},
		}); err != nil {
			http.Error(w, "Failed to encode response", http.StatusInternalServerError)
		}
	})
}

// listResources handles GET /api/v1/resources
func (s *Server) listResources(w http.ResponseWriter, r *http.Request) {
	query := r.URL.Query()
	
	// Parse filters
	filters := make(map[string]string)
	for key, values := range query {
		if len(values) > 0 && key != "limit" && key != "offset" {
			filters[key] = values[0]
		}
	}
	
	// Parse pagination
	limit := 50
	offset := 0
	
	if l := query.Get("limit"); l != "" {
		if parsed, err := strconv.Atoi(l); err == nil && parsed > 0 {
			limit = parsed
		}
	}
	
	if o := query.Get("offset"); o != "" {
		if parsed, err := strconv.Atoi(o); err == nil && parsed >= 0 {
			offset = parsed
		}
	}
	
	resources, err := s.storage.ListResources(r.Context(), filters, limit, offset)
	if err != nil {
		s.writeError(w, http.StatusInternalServerError, "Failed to list resources", err)
		return
	}
	
	s.writeJSON(w, types.APIResponse{
		Success: true,
		Data:    resources,
		Meta: &types.Meta{
			Total:  len(resources),
			Limit:  limit,
			Offset: offset,
		},
	})
}

// getResource handles GET /api/v1/resources/{id}
func (s *Server) getResource(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]
	
	resource, err := s.storage.GetResource(r.Context(), id)
	if err != nil {
		if strings.Contains(err.Error(), "not found") {
			s.writeError(w, http.StatusNotFound, "Resource not found", err)
		} else {
			s.writeError(w, http.StatusInternalServerError, "Failed to get resource", err)
		}
		return
	}
	
	s.writeJSON(w, types.APIResponse{
		Success: true,
		Data:    resource,
	})
}

// createResource handles POST /api/v1/resources
func (s *Server) createResource(w http.ResponseWriter, r *http.Request) {
	var resource types.Resource
	if err := json.NewDecoder(r.Body).Decode(&resource); err != nil {
		s.writeError(w, http.StatusBadRequest, "Invalid JSON", err)
		return
	}
	
	if err := s.storage.CreateResource(r.Context(), &resource); err != nil {
		s.writeError(w, http.StatusInternalServerError, "Failed to create resource", err)
		return
	}
	
	s.writeJSON(w, types.APIResponse{
		Success: true,
		Data:    resource,
	})
}

// updateResource handles PUT /api/v1/resources/{id}
func (s *Server) updateResource(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]
	
	var resource types.Resource
	if err := json.NewDecoder(r.Body).Decode(&resource); err != nil {
		s.writeError(w, http.StatusBadRequest, "Invalid JSON", err)
		return
	}
	
	resource.ID = id
	if err := s.storage.UpdateResource(r.Context(), &resource); err != nil {
		s.writeError(w, http.StatusInternalServerError, "Failed to update resource", err)
		return
	}
	
	s.writeJSON(w, types.APIResponse{
		Success: true,
		Data:    resource,
	})
}

// deleteResource handles DELETE /api/v1/resources/{id}
func (s *Server) deleteResource(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]
	
	if err := s.storage.DeleteResource(r.Context(), id); err != nil {
		s.writeError(w, http.StatusInternalServerError, "Failed to delete resource", err)
		return
	}
	
	s.writeJSON(w, types.APIResponse{
		Success: true,
	})
}

// searchResources handles POST /api/v1/search
func (s *Server) searchResources(w http.ResponseWriter, r *http.Request) {
	var query types.SearchQuery
	if err := json.NewDecoder(r.Body).Decode(&query); err != nil {
		s.writeError(w, http.StatusBadRequest, "Invalid JSON", err)
		return
	}
	
	// For now, this is a placeholder - semantic search would require vector embeddings
	filters := query.Filters
	if filters == nil {
		filters = make(map[string]string)
	}
	
	limit := query.Limit
	if limit == 0 {
		limit = 50
	}
	
	resources, err := s.storage.ListResources(r.Context(), filters, limit, query.Offset)
	if err != nil {
		s.writeError(w, http.StatusInternalServerError, "Search failed", err)
		return
	}
	
	result := types.SearchResult{
		Resources: resources,
		Total:     len(resources),
		Query:     query.Query,
		Took:      10, // Placeholder
	}
	
	s.writeJSON(w, types.APIResponse{
		Success: true,
		Data:    result,
	})
}

// healthCheck handles GET /api/v1/health
func (s *Server) healthCheck(w http.ResponseWriter, r *http.Request) {
	s.writeJSON(w, types.APIResponse{
		Success: true,
		Data: map[string]interface{}{
			"status":  "healthy",
			"version": "1.0.0",
			"time":    fmt.Sprintf("%d", r.Context().Value("time")),
		},
	})
}

// Placeholder handlers for schemas
func (s *Server) listSchemas(w http.ResponseWriter, r *http.Request) {
	s.writeJSON(w, types.APIResponse{
		Success: true,
		Data:    []types.Schema{},
	})
}

func (s *Server) createSchema(w http.ResponseWriter, r *http.Request) {
	s.writeError(w, http.StatusNotImplemented, "Schema creation not implemented", nil)
}

func (s *Server) getSchema(w http.ResponseWriter, r *http.Request) {
	s.writeError(w, http.StatusNotImplemented, "Schema retrieval not implemented", nil)
}

// Placeholder handlers for Terraform
func (s *Server) importTerraformState(w http.ResponseWriter, r *http.Request) {
	s.writeError(w, http.StatusNotImplemented, "Terraform import not implemented", nil)
}

// Placeholder handlers for MCP
func (s *Server) mcpInitialize(w http.ResponseWriter, r *http.Request) {
	s.writeJSON(w, map[string]interface{}{
		"protocolVersion": "1.0.0",
		"serverInfo": map[string]string{
			"name":    "siros",
			"version": "1.0.0",
		},
		"capabilities": map[string]interface{}{
			"resources": map[string]bool{
				"subscribe": true,
				"listChanged": true,
			},
		},
	})
}

func (s *Server) mcpListResources(w http.ResponseWriter, r *http.Request) {
	resources, err := s.storage.ListResources(r.Context(), nil, 100, 0)
	if err != nil {
		s.writeError(w, http.StatusInternalServerError, "Failed to list resources", err)
		return
	}
	
	mcpResources := make([]map[string]interface{}, len(resources))
	for i, resource := range resources {
		mcpResources[i] = map[string]interface{}{
			"uri":  fmt.Sprintf("resource://siros/%s", resource.ID),
			"name": resource.Name,
			"description": fmt.Sprintf("%s resource in %s", resource.Type, resource.Provider),
			"mimeType": "application/json",
		}
	}
	
	s.writeJSON(w, map[string]interface{}{
		"resources": mcpResources,
	})
}

func (s *Server) mcpReadResource(w http.ResponseWriter, r *http.Request) {
	var req map[string]interface{}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		s.writeError(w, http.StatusBadRequest, "Invalid JSON", err)
		return
	}
	
	uri, ok := req["uri"].(string)
	if !ok {
		s.writeError(w, http.StatusBadRequest, "Missing uri parameter", nil)
		return
	}
	
	// Extract resource ID from URI
	parts := strings.Split(uri, "/")
	if len(parts) < 3 {
		s.writeError(w, http.StatusBadRequest, "Invalid resource URI", nil)
		return
	}
	
	id := parts[len(parts)-1]
	resource, err := s.storage.GetResource(r.Context(), id)
	if err != nil {
		s.writeError(w, http.StatusNotFound, "Resource not found", err)
		return
	}
	
	content, err := json.Marshal(resource)
	if err != nil {
		s.writeError(w, http.StatusInternalServerError, "Failed to serialize resource", err)
		return
	}
	s.writeJSON(w, map[string]interface{}{
		"contents": []map[string]interface{}{
			{
				"uri":      uri,
				"mimeType": "application/json",
				"text":     string(content),
			},
		},
	})
}

// Helper methods
func (s *Server) writeJSON(w http.ResponseWriter, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(data); err != nil {
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
	}
}

func (s *Server) writeError(w http.ResponseWriter, status int, message string, err error) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	
	response := types.APIResponse{
		Success: false,
		Error:   message,
	}
	
	if err != nil {
		response.Error = fmt.Sprintf("%s: %v", message, err)
	}
	
	if encodeErr := json.NewEncoder(w).Encode(response); encodeErr != nil {
		// If we can't encode the error response, just write plain text
		if _, writeErr := w.Write([]byte(message)); writeErr != nil {
			// Log this error, but don't try to handle it further
			_ = writeErr
		}
	}
}