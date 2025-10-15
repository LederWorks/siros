package models

import (
	"errors"
	"fmt"
	"strings"
	"time"
)

// Sort order constants
const (
	SortOrderAsc  = "asc"
	SortOrderDesc = "desc"
)

// Resource represents a cloud resource with vector-based storage
type Resource struct {
	ID         string                 `json:"id" db:"id"`
	Type       string                 `json:"type" db:"type"`
	Provider   string                 `json:"provider" db:"provider"`
	Name       string                 `json:"name" db:"name"`
	Data       map[string]interface{} `json:"data" db:"data"`
	Metadata   ResourceMetadata       `json:"metadata" db:"metadata"`
	Vector     []float32              `json:"vector,omitempty" db:"vector"`
	ParentID   *string                `json:"parent_id,omitempty" db:"parent_id"`
	CreatedAt  time.Time              `json:"created_at" db:"created_at"`
	ModifiedAt time.Time              `json:"modified_at" db:"modified_at"`
}

// ResourceMetadata contains enriched metadata for resources
type ResourceMetadata struct {
	CreatedBy   string                 `json:"created_by"`
	ModifiedBy  string                 `json:"modified_by"`
	IAM         map[string]interface{} `json:"iam,omitempty"`
	Tags        map[string]string      `json:"tags,omitempty"`
	Region      string                 `json:"region,omitempty"`
	Environment string                 `json:"environment,omitempty"`
	CostCenter  string                 `json:"cost_center,omitempty"`
	Custom      map[string]interface{} `json:"custom,omitempty"`
}

// Validate performs business rule validation on the resource
func (r *Resource) Validate() error {
	if strings.TrimSpace(r.ID) == "" {
		return errors.New("resource ID is required")
	}

	if strings.TrimSpace(r.Type) == "" {
		return errors.New("resource type is required")
	}

	if strings.TrimSpace(r.Provider) == "" {
		return errors.New("resource provider is required")
	}

	if strings.TrimSpace(r.Name) == "" {
		return errors.New("resource name is required")
	}

	// Validate provider is supported
	validProviders := map[string]bool{
		"aws":    true,
		"azure":  true,
		"gcp":    true,
		"oci":    true,
		"custom": true,
	}

	if !validProviders[strings.ToLower(r.Provider)] {
		return fmt.Errorf("unsupported provider: %s", r.Provider)
	}

	// Validate metadata
	if err := r.Metadata.Validate(); err != nil {
		return fmt.Errorf("metadata validation failed: %w", err)
	}

	return nil
}

// Validate performs validation on resource metadata
func (rm *ResourceMetadata) Validate() error {
	if strings.TrimSpace(rm.CreatedBy) == "" {
		return errors.New("created_by is required in metadata")
	}

	if strings.TrimSpace(rm.ModifiedBy) == "" {
		return errors.New("modified_by is required in metadata")
	}

	return nil
}

// IsVectorized returns true if the resource has vector data
func (r *Resource) IsVectorized() bool {
	return len(r.Vector) > 0
}

// HasParent returns true if the resource has a parent
func (r *Resource) HasParent() bool {
	return r.ParentID != nil && *r.ParentID != ""
}

// GetTag returns a tag value by key, or empty string if not found
func (r *Resource) GetTag(key string) string {
	if r.Metadata.Tags == nil {
		return ""
	}
	return r.Metadata.Tags[key]
}

// SetTag sets a tag value
func (r *Resource) SetTag(key, value string) {
	if r.Metadata.Tags == nil {
		r.Metadata.Tags = make(map[string]string)
	}
	r.Metadata.Tags[key] = value
}

// UpdateModified updates the modified timestamp and user
func (r *Resource) UpdateModified(modifiedBy string) {
	r.ModifiedAt = time.Now()
	r.Metadata.ModifiedBy = modifiedBy
}

// Schema represents a resource schema definition
type Schema struct {
	Name        string                 `json:"name" db:"name"`
	Provider    string                 `json:"provider" db:"provider"`
	Type        string                 `json:"type" db:"type"`
	Version     string                 `json:"version" db:"version"`
	Schema      map[string]interface{} `json:"schema" db:"schema"`
	Description string                 `json:"description" db:"description"`
	CreatedAt   time.Time              `json:"created_at" db:"created_at"`
}

// Validate performs validation on the schema
func (s *Schema) Validate() error {
	if strings.TrimSpace(s.Name) == "" {
		return errors.New("schema name is required")
	}

	if strings.TrimSpace(s.Provider) == "" {
		return errors.New("schema provider is required")
	}

	if strings.TrimSpace(s.Type) == "" {
		return errors.New("schema type is required")
	}

	if strings.TrimSpace(s.Version) == "" {
		return errors.New("schema version is required")
	}

	if len(s.Schema) == 0 {
		return errors.New("schema definition is required")
	}

	return nil
}

// ChangeRecord represents a blockchain change record
type ChangeRecord struct {
	ID           string                 `json:"id" db:"id"`
	ResourceID   string                 `json:"resource_id" db:"resource_id"`
	Operation    string                 `json:"operation" db:"operation"`
	Changes      map[string]interface{} `json:"changes" db:"changes"`
	Timestamp    time.Time              `json:"timestamp" db:"timestamp"`
	Actor        string                 `json:"actor" db:"actor"`
	PreviousHash string                 `json:"previous_hash" db:"previous_hash"`
	DataHash     string                 `json:"data_hash" db:"data_hash"`
	Signature    string                 `json:"signature" db:"signature"`
}

// Validate performs validation on the change record
func (cr *ChangeRecord) Validate() error {
	if strings.TrimSpace(cr.ResourceID) == "" {
		return errors.New("resource_id is required for change record")
	}

	if strings.TrimSpace(cr.Operation) == "" {
		return errors.New("operation is required for change record")
	}

	// Validate operation type
	validOps := map[string]bool{
		"CREATE": true,
		"UPDATE": true,
		"DELETE": true,
	}

	if !validOps[strings.ToUpper(cr.Operation)] {
		return fmt.Errorf("invalid operation: %s", cr.Operation)
	}

	if strings.TrimSpace(cr.Actor) == "" {
		return errors.New("actor is required for change record")
	}

	return nil
}

// SearchQuery represents a search query with filters
type SearchQuery struct {
	Query     string            `json:"query"`
	Filters   map[string]string `json:"filters,omitempty"`
	Limit     int               `json:"limit,omitempty"`
	Offset    int               `json:"offset,omitempty"`
	Provider  string            `json:"provider,omitempty"`
	Type      string            `json:"type,omitempty"`
	SortBy    string            `json:"sort_by,omitempty"`
	SortOrder string            `json:"sort_order,omitempty"`
}

// Validate performs validation on the search query
func (sq *SearchQuery) Validate() error {
	if sq.Limit < 0 {
		return errors.New("limit cannot be negative")
	}

	if sq.Offset < 0 {
		return errors.New("offset cannot be negative")
	}

	if sq.SortOrder != "" && sq.SortOrder != SortOrderAsc && sq.SortOrder != SortOrderDesc {
		return errors.New("sort_order must be 'asc' or 'desc'")
	}

	return nil
}

// SetDefaults sets default values for the search query
func (sq *SearchQuery) SetDefaults() {
	if sq.Limit == 0 {
		sq.Limit = 50 // Default limit
	}

	if sq.Limit > 1000 {
		sq.Limit = 1000 // Max limit
	}

	if sq.SortBy == "" {
		sq.SortBy = "created_at"
	}

	if sq.SortOrder == "" {
		sq.SortOrder = "desc"
	}
}

// TerraformKey represents a Terraform-managed resource key
type TerraformKey struct {
	Key       string                 `json:"key" db:"key"`
	Path      string                 `json:"path" db:"path"`
	Data      map[string]interface{} `json:"data" db:"data"`
	Metadata  map[string]interface{} `json:"metadata" db:"metadata"`
	CreatedAt time.Time              `json:"created_at" db:"created_at"`
	UpdatedAt time.Time              `json:"updated_at" db:"updated_at"`
}

// Validate performs validation on the Terraform key
func (tk *TerraformKey) Validate() error {
	if strings.TrimSpace(tk.Key) == "" {
		return errors.New("terraform key is required")
	}

	if strings.TrimSpace(tk.Path) == "" {
		return errors.New("terraform path is required")
	}

	if tk.Data == nil {
		return errors.New("terraform data is required")
	}

	return nil
}

// CreateResourceRequest represents a request to create a new resource
type CreateResourceRequest struct {
	Type     string                 `json:"type"`
	Provider string                 `json:"provider"`
	Name     string                 `json:"name"`
	Data     map[string]interface{} `json:"data"`
	Metadata ResourceMetadata       `json:"metadata"`
	ParentID *string                `json:"parent_id,omitempty"`
}

// Validate performs validation on the create resource request
func (crr *CreateResourceRequest) Validate() error {
	if strings.TrimSpace(crr.Type) == "" {
		return errors.New("type is required")
	}

	if strings.TrimSpace(crr.Provider) == "" {
		return errors.New("provider is required")
	}

	if strings.TrimSpace(crr.Name) == "" {
		return errors.New("name is required")
	}

	if crr.Data == nil {
		return errors.New("data is required")
	}

	return crr.Metadata.Validate()
}

// ToResource converts the request to a Resource model
func (crr *CreateResourceRequest) ToResource() *Resource {
	now := time.Now()

	return &Resource{
		Type:       crr.Type,
		Provider:   crr.Provider,
		Name:       crr.Name,
		Data:       crr.Data,
		Metadata:   crr.Metadata,
		ParentID:   crr.ParentID,
		CreatedAt:  now,
		ModifiedAt: now,
	}
}

// UpdateResourceRequest represents a request to update a resource
type UpdateResourceRequest struct {
	Name     *string                `json:"name,omitempty"`
	Data     map[string]interface{} `json:"data,omitempty"`
	Metadata *ResourceMetadata      `json:"metadata,omitempty"`
	ParentID *string                `json:"parent_id,omitempty"`
}

// Validate performs validation on the update resource request
func (urr *UpdateResourceRequest) Validate() error {
	if urr.Metadata != nil {
		return urr.Metadata.Validate()
	}
	return nil
}

// ApplyTo applies the update request to a resource
func (urr *UpdateResourceRequest) ApplyTo(resource *Resource, modifiedBy string) {
	if urr.Name != nil {
		resource.Name = *urr.Name
	}

	if urr.Data != nil {
		resource.Data = urr.Data
	}

	if urr.Metadata != nil {
		resource.Metadata = *urr.Metadata
	}

	if urr.ParentID != nil {
		resource.ParentID = urr.ParentID
	}

	resource.UpdateModified(modifiedBy)
}
