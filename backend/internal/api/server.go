package api

import (
	"embed"
	"io/fs"
	"log"
	"net/http"

	"github.com/LederWorks/siros/backend/internal/api/middleware"
	"github.com/LederWorks/siros/backend/internal/api/routes"
	"github.com/LederWorks/siros/backend/internal/config"
	"github.com/LederWorks/siros/backend/internal/controllers"
	"github.com/LederWorks/siros/backend/internal/services"
	"github.com/LederWorks/siros/backend/internal/storage"
	"github.com/gorilla/mux"
)

// Server represents the HTTP API server
type Server struct {
	config      *config.Config
	storage     *storage.Storage
	router      *mux.Router
	controllers *controllers.Controllers
	services    *services.Services
	webAssets   embed.FS
	logger      *log.Logger
}

// NewServer creates a new API server.
func NewServer(cfg *config.Config, storage *storage.Storage, webAssets embed.FS, logger *log.Logger) *Server {
	s := &Server{
		config:    cfg,
		storage:   storage,
		router:    mux.NewRouter(),
		webAssets: webAssets,
		logger:    logger,
	}

	// Initialize services (simplified for now)
	s.services = &services.Services{
		// TODO: Initialize with proper repositories
	}

	// Initialize controllers
	s.controllers = controllers.NewControllers(s.services, logger)

	s.setupRoutes()
	return s
}

// Router returns the HTTP router with middleware applied
func (s *Server) Router() http.Handler {
	// Apply middleware
	middlewareConfig := middleware.DefaultConfig(s.logger)
	return middlewareConfig.Apply(s.router)
}

// setupRoutes configures all routes
func (s *Server) setupRoutes() {
	// Setup API routes using the correct function
	routes.SetupAPIRoutes(s.router, s.controllers)

	// Setup web routes for frontend
	s.setupWebRoutes()
}

// setupWebRoutes serves the embedded React frontend.
func (s *Server) setupWebRoutes() {
	// Try to serve static files from embedded filesystem
	webFS, err := fs.Sub(s.webAssets, "static")
	if err == nil {
		s.router.PathPrefix("/").Handler(http.FileServer(http.FS(webFS)))
	} else {
		// Fallback for development
		s.router.PathPrefix("/").HandlerFunc(s.serveDevelopmentPage)
	}
}

// serveDevelopmentPage serves a development placeholder page.
func (s *Server) serveDevelopmentPage(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/html")
	htmlContent := []byte(`
<!DOCTYPE html>
<html>
<head>
    <title>Siros - Multi-Cloud Resource Platform</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .header { text-align: center; margin-bottom: 40px; }
        .api-link {
            display: inline-block; margin: 10px; padding: 10px 20px;
            background: #007cba; color: white; text-decoration: none; border-radius: 5px;
        }
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
        <a href="/api/v1/version" class="api-link">Version</a>
        <a href="/api/v1/resources" class="api-link">Resources</a>
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
	`)
	if _, err := w.Write(htmlContent); err != nil {
		http.Error(w, "Failed to write response", http.StatusInternalServerError)
	}
}
