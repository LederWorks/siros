package controllers

import (
	"encoding/json"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/gorilla/mux"

	"github.com/LederWorks/siros/backend/internal/models"
	"github.com/LederWorks/siros/backend/internal/services"
	"github.com/LederWorks/siros/backend/internal/views"
)

// ResourceController handles HTTP requests for resources
type ResourceController struct {
	resourceService services.ResourceService
	logger          Logger
}

// Logger defines the interface for logging
type Logger interface {
	Printf(format string, v ...interface{})
}

// NewResourceController creates a new resource controller
func NewResourceController(resourceService services.ResourceService, logger Logger) *ResourceController {
	return &ResourceController{
		resourceService: resourceService,
		logger:          logger,
	}
}

// CreateResource handles POST /api/v1/resources
func (c *ResourceController) CreateResource(w http.ResponseWriter, r *http.Request) {
	var req models.CreateResourceRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		c.logger.Printf("Failed to decode create resource request: %v", err)
		views.WriteBadRequest(w, "Invalid request body", err)
		return
	}

	resource, err := c.resourceService.CreateResource(r.Context(), &req)
	if err != nil {
		c.logger.Printf("Failed to create resource: %v", err)

		// Check if it's a validation error
		if strings.Contains(err.Error(), "validation") {
			views.WriteBadRequest(w, "Validation failed", err)
			return
		}

		views.WriteInternalError(w, "Failed to create resource", err)
		return
	}

	c.logger.Printf("Created resource: %s", resource.ID)
	views.WriteResourceResponse(w, http.StatusCreated, resource)
}

// GetResource handles GET /api/v1/resources/{id}
func (c *ResourceController) GetResource(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]

	if id == "" {
		views.WriteBadRequest(w, "Resource ID is required", nil)
		return
	}

	resource, err := c.resourceService.GetResource(r.Context(), id)
	if err != nil {
		c.logger.Printf("Failed to get resource %s: %v", id, err)

		if strings.Contains(err.Error(), "not found") {
			views.WriteNotFound(w, "Resource")
			return
		}

		views.WriteInternalError(w, "Failed to get resource", err)
		return
	}

	views.WriteResourceResponse(w, http.StatusOK, resource)
}

// UpdateResource handles PUT /api/v1/resources/{id}
func (c *ResourceController) UpdateResource(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]

	if id == "" {
		views.WriteBadRequest(w, "Resource ID is required", nil)
		return
	}

	var req models.UpdateResourceRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		c.logger.Printf("Failed to decode update resource request: %v", err)
		views.WriteBadRequest(w, "Invalid request body", err)
		return
	}

	// TODO: Get modifiedBy from authentication context
	modifiedBy := "system" // Default for now
	if authUser := r.Header.Get("X-User"); authUser != "" {
		modifiedBy = authUser
	}

	resource, err := c.resourceService.UpdateResource(r.Context(), id, req, modifiedBy)
	if err != nil {
		c.logger.Printf("Failed to update resource %s: %v", id, err)

		if strings.Contains(err.Error(), "not found") {
			views.WriteNotFound(w, "Resource")
			return
		}

		if strings.Contains(err.Error(), "validation") {
			views.WriteBadRequest(w, "Validation failed", err)
			return
		}

		views.WriteInternalError(w, "Failed to update resource", err)
		return
	}

	c.logger.Printf("Updated resource: %s", resource.ID)
	views.WriteResourceResponse(w, http.StatusOK, resource)
}

// DeleteResource handles DELETE /api/v1/resources/{id}
func (c *ResourceController) DeleteResource(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]

	if id == "" {
		views.WriteBadRequest(w, "Resource ID is required", nil)
		return
	}

	// TODO: Get deletedBy from authentication context
	deletedBy := "system" // Default for now
	if authUser := r.Header.Get("X-User"); authUser != "" {
		deletedBy = authUser
	}

	if err := c.resourceService.DeleteResource(r.Context(), id, deletedBy); err != nil {
		c.logger.Printf("Failed to delete resource %s: %v", id, err)

		if strings.Contains(err.Error(), "not found") {
			views.WriteNotFound(w, "Resource")
			return
		}

		views.WriteInternalError(w, "Failed to delete resource", err)
		return
	}

	c.logger.Printf("Deleted resource: %s", id)
	views.WriteNoContent(w)
}

// ListResources handles GET /api/v1/resources (alias for route compatibility)
func (c *ResourceController) List(w http.ResponseWriter, r *http.Request) {
	c.ListResources(w, r)
}

// CreateResource handles POST /api/v1/resources (alias for route compatibility)
func (c *ResourceController) Create(w http.ResponseWriter, r *http.Request) {
	c.CreateResource(w, r)
}

// GetResource handles GET /api/v1/resources/{id} (alias for route compatibility)
func (c *ResourceController) Get(w http.ResponseWriter, r *http.Request) {
	c.GetResource(w, r)
}

// UpdateResource handles PUT /api/v1/resources/{id} (alias for route compatibility)
func (c *ResourceController) Update(w http.ResponseWriter, r *http.Request) {
	c.UpdateResource(w, r)
}

// DeleteResource handles DELETE /api/v1/resources/{id} (alias for route compatibility)
func (c *ResourceController) Delete(w http.ResponseWriter, r *http.Request) {
	c.DeleteResource(w, r)
}

// GetChildren handles GET /api/v1/resources/{id}/children (alias for route compatibility)
func (c *ResourceController) GetChildren(w http.ResponseWriter, r *http.Request) {
	c.GetResourcesByParent(w, r)
}

// GetRelationships handles GET /api/v1/resources/{id}/relationships
func (c *ResourceController) GetRelationships(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]

	if id == "" {
		views.WriteBadRequest(w, "Resource ID is required", nil)
		return
	}

	// TODO: Implement relationship discovery using vector similarity
	c.logger.Printf("Getting relationships for resource %s", id)

	// Placeholder response for now
	relationships := []map[string]interface{}{
		{
			"resource_id": "related-resource-1",
			"type":        "depends_on",
			"strength":    0.95,
			"direction":   "outbound",
		},
	}

	response := views.APIResponse{
		Data: map[string]interface{}{
			"resource_id":   id,
			"relationships": relationships,
			"total":         len(relationships),
		},
		Meta: &views.Meta{
			Timestamp: time.Now(),
			Version:   "1.0",
		},
	}
	views.WriteJSONResponse(w, http.StatusOK, response)
}

// GetParents handles GET /api/v1/resources/{id}/parents
func (c *ResourceController) GetParents(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]

	if id == "" {
		views.WriteBadRequest(w, "Resource ID is required", nil)
		return
	}

	// TODO: Implement parent resource discovery
	c.logger.Printf("Getting parents for resource %s", id)

	// Placeholder response for now
	parents := []map[string]interface{}{
		{
			"id":   "parent-resource-1",
			"name": "parent-resource",
			"type": "aws_vpc",
		},
	}

	response := views.APIResponse{
		Data: map[string]interface{}{
			"resource_id": id,
			"parents":     parents,
			"total":       len(parents),
		},
		Meta: &views.Meta{
			Timestamp: time.Now(),
			Version:   "1.0",
		},
	}
	views.WriteJSONResponse(w, http.StatusOK, response)
}

// ListResources handles GET /api/v1/resources
func (c *ResourceController) ListResources(w http.ResponseWriter, r *http.Request) {
	query := c.parseSearchQuery(r)

	resources, err := c.resourceService.ListResources(r.Context(), &query)
	if err != nil {
		c.logger.Printf("Failed to list resources: %v", err)

		if strings.Contains(err.Error(), "validation") {
			views.WriteBadRequest(w, "Invalid query parameters", err)
			return
		}

		views.WriteInternalError(w, "Failed to list resources", err)
		return
	}

	views.WriteResourceListResponse(w, http.StatusOK, resources)
}

// SearchResources handles POST /api/v1/search
func (c *ResourceController) SearchResources(w http.ResponseWriter, r *http.Request) {
	var query models.SearchQuery

	if err := json.NewDecoder(r.Body).Decode(&query); err != nil {
		c.logger.Printf("Failed to decode search request: %v", err)
		views.WriteBadRequest(w, "Invalid request body", err)
		return
	}

	resources, err := c.resourceService.SearchResources(r.Context(), &query)
	if err != nil {
		c.logger.Printf("Failed to search resources: %v", err)

		if strings.Contains(err.Error(), "validation") {
			views.WriteBadRequest(w, "Invalid search query", err)
			return
		}

		views.WriteInternalError(w, "Failed to search resources", err)
		return
	}

	views.WriteSearchResponse(w, http.StatusOK, resources)
}

// GetResourcesByParent handles GET /api/v1/resources/{id}/children
func (c *ResourceController) GetResourcesByParent(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	parentID := vars["id"]

	if parentID == "" {
		views.WriteBadRequest(w, "Parent ID is required", nil)
		return
	}

	resources, err := c.resourceService.GetResourcesByParent(r.Context(), parentID)
	if err != nil {
		c.logger.Printf("Failed to get resources by parent %s: %v", parentID, err)
		views.WriteInternalError(w, "Failed to get child resources", err)
		return
	}

	views.WriteResourceListResponse(w, http.StatusOK, resources)
}

// parseSearchQuery parses query parameters into a SearchQuery model
func (c *ResourceController) parseSearchQuery(r *http.Request) models.SearchQuery {
	query := models.SearchQuery{
		Filters: make(map[string]string),
	}

	queryParams := r.URL.Query()

	// Parse basic parameters
	query.Query = queryParams.Get("q")
	query.Provider = queryParams.Get("provider")
	query.Type = queryParams.Get("type")
	query.SortBy = queryParams.Get("sort_by")
	query.SortOrder = queryParams.Get("sort_order")

	// Parse limit and offset
	if limitStr := queryParams.Get("limit"); limitStr != "" {
		if limit, err := strconv.Atoi(limitStr); err == nil {
			query.Limit = limit
		}
	}

	if offsetStr := queryParams.Get("offset"); offsetStr != "" {
		if offset, err := strconv.Atoi(offsetStr); err == nil {
			query.Offset = offset
		}
	}

	// Parse filters (any parameter starting with "filter_")
	for key, values := range queryParams {
		if strings.HasPrefix(key, "filter_") && len(values) > 0 {
			filterKey := strings.TrimPrefix(key, "filter_")
			query.Filters[filterKey] = values[0]
		}
	}

	// Set defaults
	query.SetDefaults()

	return query
}

// RegisterRoutes registers all resource routes
func (c *ResourceController) RegisterRoutes(r *mux.Router) {
	r.HandleFunc("/api/v1/resources", c.ListResources).Methods("GET")
	r.HandleFunc("/api/v1/resources", c.CreateResource).Methods("POST")
	r.HandleFunc("/api/v1/resources/{id}", c.GetResource).Methods("GET")
	r.HandleFunc("/api/v1/resources/{id}", c.UpdateResource).Methods("PUT")
	r.HandleFunc("/api/v1/resources/{id}", c.DeleteResource).Methods("DELETE")
	r.HandleFunc("/api/v1/resources/{id}/children", c.GetResourcesByParent).Methods("GET")
	r.HandleFunc("/api/v1/search", c.SearchResources).Methods("POST")
}
