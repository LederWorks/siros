package storage

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"time"

	"github.com/LederWorks/siros/internal/config"
	"github.com/LederWorks/siros/pkg/types"
	"github.com/lib/pq"
	_ "github.com/lib/pq"
)

// Storage provides database operations
type Storage struct {
	db     *sql.DB
	config config.DatabaseConfig
}

// New creates a new storage instance
func New(cfg config.DatabaseConfig) (*Storage, error) {
	db, err := sql.Open(cfg.Driver, cfg.ConnectionString())
	if err != nil {
		return nil, fmt.Errorf("failed to open database: %w", err)
	}

	// Configure connection pool
	db.SetMaxOpenConns(cfg.MaxConns)
	db.SetMaxIdleConns(cfg.MaxConns / 2)
	db.SetConnMaxLifetime(time.Hour)

	// Test connection
	if err := db.Ping(); err != nil {
		return nil, fmt.Errorf("failed to ping database: %w", err)
	}

	storage := &Storage{
		db:     db,
		config: cfg,
	}

	// Initialize database schema
	if err := storage.migrate(); err != nil {
		return nil, fmt.Errorf("failed to migrate database: %w", err)
	}

	return storage, nil
}

// Close closes the database connection
func (s *Storage) Close() error {
	return s.db.Close()
}

// migrate creates the database schema
func (s *Storage) migrate() error {
	queries := []string{
		// Enable pgvector extension
		`CREATE EXTENSION IF NOT EXISTS vector`,
		
		// Create resources table
		`CREATE TABLE IF NOT EXISTS resources (
			id VARCHAR(255) PRIMARY KEY,
			type VARCHAR(100) NOT NULL,
			provider VARCHAR(50) NOT NULL,
			region VARCHAR(100),
			name VARCHAR(255) NOT NULL,
			arn VARCHAR(1024),
			tags JSONB,
			metadata JSONB,
			state VARCHAR(50) NOT NULL DEFAULT 'unknown',
			parent_id VARCHAR(255) REFERENCES resources(id),
			children TEXT[],
			links JSONB,
			vector vector(1536), -- OpenAI embedding dimension
			created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
			updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
			last_scanned_at TIMESTAMP WITH TIME ZONE
		)`,
		
		// Create schemas table
		`CREATE TABLE IF NOT EXISTS schemas (
			id VARCHAR(255) PRIMARY KEY,
			name VARCHAR(255) NOT NULL,
			version VARCHAR(50) NOT NULL,
			provider VARCHAR(50) NOT NULL,
			type VARCHAR(100) NOT NULL,
			properties JSONB NOT NULL,
			required TEXT[],
			is_custom BOOLEAN DEFAULT FALSE,
			created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
			updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
		)`,
		
		// Create change_records table
		`CREATE TABLE IF NOT EXISTS change_records (
			id VARCHAR(255) PRIMARY KEY,
			resource_id VARCHAR(255) NOT NULL REFERENCES resources(id),
			operation VARCHAR(20) NOT NULL,
			changes JSONB NOT NULL,
			block_hash VARCHAR(255),
			transaction_id VARCHAR(255),
			timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
			actor VARCHAR(255)
		)`,
		
		// Create indexes
		`CREATE INDEX IF NOT EXISTS idx_resources_provider ON resources(provider)`,
		`CREATE INDEX IF NOT EXISTS idx_resources_type ON resources(type)`,
		`CREATE INDEX IF NOT EXISTS idx_resources_state ON resources(state)`,
		`CREATE INDEX IF NOT EXISTS idx_resources_parent ON resources(parent_id)`,
		`CREATE INDEX IF NOT EXISTS idx_resources_tags ON resources USING GIN(tags)`,
		`CREATE INDEX IF NOT EXISTS idx_resources_metadata ON resources USING GIN(metadata)`,
		`CREATE INDEX IF NOT EXISTS idx_resources_vector ON resources USING ivfflat (vector vector_cosine_ops) WITH (lists = 100)`,
		`CREATE INDEX IF NOT EXISTS idx_change_records_resource ON change_records(resource_id)`,
		`CREATE INDEX IF NOT EXISTS idx_change_records_timestamp ON change_records(timestamp)`,
	}

	for _, query := range queries {
		if _, err := s.db.Exec(query); err != nil {
			log.Printf("Migration query failed: %s", query)
			return fmt.Errorf("failed to execute migration: %w", err)
		}
	}

	return nil
}

// CreateResource creates a new resource
func (s *Storage) CreateResource(ctx context.Context, resource *types.Resource) error {
	tagsJSON, _ := json.Marshal(resource.Tags)
	metadataJSON, _ := json.Marshal(resource.Metadata)
	linksJSON, _ := json.Marshal(resource.Links)

	query := `
		INSERT INTO resources (id, type, provider, region, name, arn, tags, metadata, state, parent_id, children, links, vector, last_scanned_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
	`
	
	_, err := s.db.ExecContext(ctx, query,
		resource.ID, resource.Type, resource.Provider, resource.Region, resource.Name,
		resource.ARN, tagsJSON, metadataJSON, resource.State, resource.ParentID,
		pq.Array(resource.Children), linksJSON, pq.Array(resource.Vector), resource.LastScannedAt,
	)
	
	return err
}

// GetResource retrieves a resource by ID
func (s *Storage) GetResource(ctx context.Context, id string) (*types.Resource, error) {
	query := `
		SELECT id, type, provider, region, name, arn, tags, metadata, state, parent_id, children, links, created_at, updated_at, last_scanned_at
		FROM resources WHERE id = $1
	`
	
	row := s.db.QueryRowContext(ctx, query, id)
	
	var resource types.Resource
	var tagsJSON, metadataJSON, linksJSON []byte
	var children pq.StringArray
	
	err := row.Scan(
		&resource.ID, &resource.Type, &resource.Provider, &resource.Region, &resource.Name,
		&resource.ARN, &tagsJSON, &metadataJSON, &resource.State, &resource.ParentID,
		&children, &linksJSON, &resource.CreatedAt, &resource.UpdatedAt, &resource.LastScannedAt,
	)
	
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("resource not found: %s", id)
		}
		return nil, err
	}
	
	// Unmarshal JSON fields
	json.Unmarshal(tagsJSON, &resource.Tags)
	json.Unmarshal(metadataJSON, &resource.Metadata)
	json.Unmarshal(linksJSON, &resource.Links)
	resource.Children = []string(children)
	
	return &resource, nil
}

// UpdateResource updates an existing resource
func (s *Storage) UpdateResource(ctx context.Context, resource *types.Resource) error {
	tagsJSON, _ := json.Marshal(resource.Tags)
	metadataJSON, _ := json.Marshal(resource.Metadata)
	linksJSON, _ := json.Marshal(resource.Links)

	query := `
		UPDATE resources 
		SET type = $2, provider = $3, region = $4, name = $5, arn = $6, tags = $7, 
		    metadata = $8, state = $9, parent_id = $10, children = $11, links = $12, 
		    vector = $13, updated_at = NOW(), last_scanned_at = $14
		WHERE id = $1
	`
	
	_, err := s.db.ExecContext(ctx, query,
		resource.ID, resource.Type, resource.Provider, resource.Region, resource.Name,
		resource.ARN, tagsJSON, metadataJSON, resource.State, resource.ParentID,
		pq.Array(resource.Children), linksJSON, pq.Array(resource.Vector), resource.LastScannedAt,
	)
	
	return err
}

// DeleteResource deletes a resource
func (s *Storage) DeleteResource(ctx context.Context, id string) error {
	query := `DELETE FROM resources WHERE id = $1`
	_, err := s.db.ExecContext(ctx, query, id)
	return err
}

// ListResources lists resources with optional filters
func (s *Storage) ListResources(ctx context.Context, filters map[string]string, limit, offset int) ([]types.Resource, error) {
	query := `SELECT id, type, provider, region, name, arn, tags, metadata, state, parent_id, children, links, created_at, updated_at, last_scanned_at FROM resources`
	args := []interface{}{}
	argIndex := 1

	// Add filters
	if len(filters) > 0 {
		query += " WHERE "
		conditions := []string{}
		
		for key, value := range filters {
			switch key {
			case "provider", "type", "state", "region":
				conditions = append(conditions, fmt.Sprintf("%s = $%d", key, argIndex))
				args = append(args, value)
				argIndex++
			}
		}
		
		if len(conditions) > 0 {
			query += fmt.Sprintf("(%s)", conditions[0])
			for _, condition := range conditions[1:] {
				query += fmt.Sprintf(" AND (%s)", condition)
			}
		}
	}

	// Add pagination
	query += fmt.Sprintf(" ORDER BY created_at DESC LIMIT $%d OFFSET $%d", argIndex, argIndex+1)
	args = append(args, limit, offset)

	rows, err := s.db.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var resources []types.Resource
	for rows.Next() {
		var resource types.Resource
		var tagsJSON, metadataJSON, linksJSON []byte
		var children pq.StringArray

		err := rows.Scan(
			&resource.ID, &resource.Type, &resource.Provider, &resource.Region, &resource.Name,
			&resource.ARN, &tagsJSON, &metadataJSON, &resource.State, &resource.ParentID,
			&children, &linksJSON, &resource.CreatedAt, &resource.UpdatedAt, &resource.LastScannedAt,
		)
		if err != nil {
			return nil, err
		}

		// Unmarshal JSON fields
		json.Unmarshal(tagsJSON, &resource.Tags)
		json.Unmarshal(metadataJSON, &resource.Metadata)
		json.Unmarshal(linksJSON, &resource.Links)
		resource.Children = []string(children)

		resources = append(resources, resource)
	}

	return resources, rows.Err()
}

// VectorSearch performs semantic search using vector similarity
func (s *Storage) VectorSearch(ctx context.Context, queryVector []float32, limit int) ([]types.Resource, error) {
	query := `
		SELECT id, type, provider, region, name, arn, tags, metadata, state, parent_id, children, links, created_at, updated_at, last_scanned_at,
		       vector <=> $1 AS distance
		FROM resources 
		WHERE vector IS NOT NULL
		ORDER BY distance
		LIMIT $2
	`

	rows, err := s.db.QueryContext(ctx, query, pq.Array(queryVector), limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var resources []types.Resource
	for rows.Next() {
		var resource types.Resource
		var tagsJSON, metadataJSON, linksJSON []byte
		var children pq.StringArray
		var distance float64

		err := rows.Scan(
			&resource.ID, &resource.Type, &resource.Provider, &resource.Region, &resource.Name,
			&resource.ARN, &tagsJSON, &metadataJSON, &resource.State, &resource.ParentID,
			&children, &linksJSON, &resource.CreatedAt, &resource.UpdatedAt, &resource.LastScannedAt,
			&distance,
		)
		if err != nil {
			return nil, err
		}

		// Unmarshal JSON fields
		json.Unmarshal(tagsJSON, &resource.Tags)
		json.Unmarshal(metadataJSON, &resource.Metadata)
		json.Unmarshal(linksJSON, &resource.Links)
		resource.Children = []string(children)

		resources = append(resources, resource)
	}

	return resources, rows.Err()
}

// CreateChangeRecord creates a new change record
func (s *Storage) CreateChangeRecord(ctx context.Context, record *types.ChangeRecord) error {
	changesJSON, _ := json.Marshal(record.Changes)
	
	query := `
		INSERT INTO change_records (id, resource_id, operation, changes, block_hash, transaction_id, timestamp, actor)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
	`
	
	_, err := s.db.ExecContext(ctx, query,
		record.ID, record.ResourceID, record.Operation, changesJSON,
		record.BlockHash, record.TransactionID, record.Timestamp, record.Actor,
	)
	
	return err
}