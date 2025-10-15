package repositories

import (
	"context"
	"database/sql"
	"log"

	"github.com/LederWorks/siros/backend/internal/models"
)

// Repositories holds all repository instances
type Repositories struct {
	Resource   ResourceRepository
	Schema     SchemaRepository
	Blockchain BlockchainRepository
}

// ResourceRepository defines the interface for resource data access
type ResourceRepository interface {
	Create(ctx context.Context, resource *models.Resource) error
	GetByID(ctx context.Context, id string) (*models.Resource, error)
	Update(ctx context.Context, resource *models.Resource) error
	Delete(ctx context.Context, id string) error
	List(ctx context.Context, query *models.SearchQuery) ([]models.Resource, error)
	Search(ctx context.Context, query *models.SearchQuery) ([]models.Resource, error)
	GetByParentID(ctx context.Context, parentID string) ([]models.Resource, error)
	VectorSearch(ctx context.Context, vector []float32, threshold float32, limit int) ([]models.Resource, error)
}

// SchemaRepository defines the interface for schema data access
type SchemaRepository interface {
	Create(ctx context.Context, schema *models.Schema) error
	GetByID(ctx context.Context, id string) (*models.Schema, error)
	Update(ctx context.Context, schema *models.Schema) error
	Delete(ctx context.Context, id string) error
	List(ctx context.Context) ([]models.Schema, error)
	GetByName(ctx context.Context, name string) (*models.Schema, error)
}

// BlockchainRepository defines the interface for blockchain audit data access
type BlockchainRepository interface {
	CreateRecord(ctx context.Context, record *models.ChangeRecord) error
	GetRecordsByResourceID(ctx context.Context, resourceID string) ([]models.ChangeRecord, error)
	GetLatestRecord(ctx context.Context, resourceID string) (*models.ChangeRecord, error)
}

// NewRepositories creates a new Repositories instance with all repositories
func NewRepositories(db *sql.DB, _ *log.Logger) *Repositories {
	return &Repositories{
		Resource:   NewResourceRepository(db),
		Schema:     NewSchemaRepository(db),
		Blockchain: NewBlockchainRepository(db),
	}
}
