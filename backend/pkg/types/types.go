package types

import (
	"time"
)

// Resource represents a cloud resource
type Resource struct {
	ID            string                 `json:"id" db:"id"`
	Type          string                 `json:"type" db:"type"`
	Provider      string                 `json:"provider" db:"provider"`
	Region        string                 `json:"region" db:"region"`
	Name          string                 `json:"name" db:"name"`
	ARN           string                 `json:"arn,omitempty" db:"arn"`
	Tags          map[string]string      `json:"tags" db:"tags"`
	Metadata      map[string]interface{} `json:"metadata" db:"metadata"`
	State         ResourceState          `json:"state" db:"state"`
	ParentID      *string                `json:"parent_id,omitempty" db:"parent_id"`
	Children      []string               `json:"children,omitempty" db:"children"`
	Links         []ResourceLink         `json:"links,omitempty" db:"links"`
	Vector        []float32              `json:"-" db:"vector"`
	CreatedAt     time.Time              `json:"created_at" db:"created_at"`
	UpdatedAt     time.Time              `json:"updated_at" db:"updated_at"`
	LastScannedAt *time.Time             `json:"last_scanned_at" db:"last_scanned_at"`
}

// ResourceState represents the current state of a resource
type ResourceState string

const (
	ResourceStateActive     ResourceState = "active"
	ResourceStateInactive   ResourceState = "inactive"
	ResourceStateTerminated ResourceState = "terminated"
	ResourceStateError      ResourceState = "error"
	ResourceStateUnknown    ResourceState = "unknown"
)

// ResourceLink represents a link between resources
type ResourceLink struct {
	TargetID   string            `json:"target_id" db:"target_id"`
	Type       string            `json:"type" db:"type"`
	Direction  string            `json:"direction" db:"direction"` // "inbound", "outbound", "bidirectional"
	Properties map[string]string `json:"properties,omitempty" db:"properties"`
}

// Schema represents a resource schema
type Schema struct {
	ID         string                 `json:"id" db:"id"`
	Name       string                 `json:"name" db:"name"`
	Version    string                 `json:"version" db:"version"`
	Provider   string                 `json:"provider" db:"provider"`
	Type       string                 `json:"type" db:"type"`
	Properties map[string]interface{} `json:"properties" db:"properties"`
	Required   []string               `json:"required" db:"required"`
	IsCustom   bool                   `json:"is_custom" db:"is_custom"`
	CreatedAt  time.Time              `json:"created_at" db:"created_at"`
	UpdatedAt  time.Time              `json:"updated_at" db:"updated_at"`
}

// ChangeRecord represents a blockchain change record
type ChangeRecord struct {
	ID            string                 `json:"id" db:"id"`
	ResourceID    string                 `json:"resource_id" db:"resource_id"`
	Operation     string                 `json:"operation" db:"operation"` // "create", "update", "delete"
	Changes       map[string]interface{} `json:"changes" db:"changes"`
	BlockHash     string                 `json:"block_hash" db:"block_hash"`
	TransactionID string                 `json:"transaction_id" db:"transaction_id"`
	Timestamp     time.Time              `json:"timestamp" db:"timestamp"`
	Actor         string                 `json:"actor" db:"actor"`
}

// SearchQuery represents a semantic search query
type SearchQuery struct {
	Query     string            `json:"query"`
	Filters   map[string]string `json:"filters,omitempty"`
	Providers []string          `json:"providers,omitempty"`
	Types     []string          `json:"types,omitempty"`
	Limit     int               `json:"limit,omitempty"`
	Offset    int               `json:"offset,omitempty"`
}

// SearchResult represents search results
type SearchResult struct {
	Resources []Resource `json:"resources"`
	Total     int        `json:"total"`
	Query     string     `json:"query"`
	Took      int64      `json:"took_ms"`
}

// Provider represents a cloud service provider
type Provider interface {
	Name() string
	Scan(ctx interface{}) ([]Resource, error)
	GetResource(id string) (*Resource, error)
	Validate() error
}

// APIResponse represents a standard API response
type APIResponse struct {
	Success bool        `json:"success"`
	Data    interface{} `json:"data,omitempty"`
	Error   string      `json:"error,omitempty"`
	Meta    *Meta       `json:"meta,omitempty"`
}

// Meta represents response metadata
type Meta struct {
	Total  int `json:"total,omitempty"`
	Page   int `json:"page,omitempty"`
	Limit  int `json:"limit,omitempty"`
	Offset int `json:"offset,omitempty"`
}

// TerraformState represents Terraform state information
type TerraformState struct {
	Version   int                    `json:"version"`
	Serial    int64                  `json:"serial"`
	Lineage   string                 `json:"lineage"`
	Outputs   map[string]interface{} `json:"outputs"`
	Resources []TerraformResource    `json:"resources"`
}

// TerraformResource represents a Terraform-managed resource
type TerraformResource struct {
	Module    string              `json:"module"`
	Mode      string              `json:"mode"`
	Type      string              `json:"type"`
	Name      string              `json:"name"`
	Provider  string              `json:"provider"`
	Instances []TerraformInstance `json:"instances"`
}

// TerraformInstance represents a Terraform resource instance
type TerraformInstance struct {
	SchemaVersion int                    `json:"schema_version"`
	Attributes    map[string]interface{} `json:"attributes"`
	Dependencies  []string               `json:"dependencies"`
}
