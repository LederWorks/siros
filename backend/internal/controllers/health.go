package controllers

import (
	"log"
	"net/http"
	"time"

	"github.com/LederWorks/siros/backend/internal/views"
)

// HealthController handles health check endpoints
type HealthController struct {
	logger *log.Logger
}

// NewHealthController creates a new HealthController
func NewHealthController(logger *log.Logger) *HealthController {
	return &HealthController{
		logger: logger,
	}
}

// Check handles GET /api/v1/health
func (h *HealthController) Check(w http.ResponseWriter, r *http.Request) {
	response := map[string]interface{}{
		"status":    "healthy",
		"service":   "siros-backend",
		"timestamp": time.Now().Unix(),
		"version":   "1.0.0",
	}

	views.WriteJSONResponse(w, http.StatusOK, views.APIResponse{
		Data: response,
		Meta: &views.Meta{
			Timestamp: time.Now(),
			Version:   "1.0",
		},
	})
}

// Version handles GET /api/v1/version
func (h *HealthController) Version(w http.ResponseWriter, r *http.Request) {
	response := map[string]interface{}{
		"name":        "siros",
		"version":     "1.0.0",
		"description": "Multi-cloud resource management platform",
		"api_version": "v1",
		"build_time":  time.Now().Unix(), // TODO: Set at build time
	}

	views.WriteJSONResponse(w, http.StatusOK, views.APIResponse{
		Data: response,
		Meta: &views.Meta{
			Timestamp: time.Now(),
			Version:   "1.0",
		},
	})
}
