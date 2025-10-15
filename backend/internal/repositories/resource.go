package repositories

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"strings"

	"github.com/lib/pq"

	"github.com/LederWorks/siros/backend/internal/models"
)

// resourceRepository implements ResourceRepository
type resourceRepository struct {
	db *sql.DB
}

// NewResourceRepository creates a new resource repository
func NewResourceRepository(db *sql.DB) ResourceRepository {
	return &resourceRepository{db: db}
}

func (r *resourceRepository) Create(ctx context.Context, resource *models.Resource) error {
	// Marshal JSON fields
	dataJSON, err := json.Marshal(resource.Data)
	if err != nil {
		return fmt.Errorf("failed to marshal data: %w", err)
	}

	metadataJSON, err := json.Marshal(resource.Metadata)
	if err != nil {
		return fmt.Errorf("failed to marshal metadata: %w", err)
	}

	query := `
		INSERT INTO resources (id, type, provider, name, data, metadata, vector, parent_id, created_at, modified_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
	`

	_, err = r.db.ExecContext(ctx, query,
		resource.ID, resource.Type, resource.Provider, resource.Name,
		dataJSON, metadataJSON, pq.Array(resource.Vector), resource.ParentID,
		resource.CreatedAt, resource.ModifiedAt,
	)

	if err != nil {
		return fmt.Errorf("failed to insert resource: %w", err)
	}

	return nil
}

func (r *resourceRepository) GetByID(ctx context.Context, id string) (*models.Resource, error) {
	query := `
		SELECT id, type, provider, name, data, metadata, vector, parent_id, created_at, modified_at
		FROM resources WHERE id = $1
	`

	row := r.db.QueryRowContext(ctx, query, id)

	var resource models.Resource
	var dataJSON, metadataJSON []byte
	var vector pq.Float32Array

	err := row.Scan(
		&resource.ID, &resource.Type, &resource.Provider, &resource.Name,
		&dataJSON, &metadataJSON, &vector, &resource.ParentID,
		&resource.CreatedAt, &resource.ModifiedAt,
	)

	if err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("resource not found: %s", id)
		}
		return nil, fmt.Errorf("failed to scan resource: %w", err)
	}

	// Unmarshal JSON fields
	if len(dataJSON) > 0 {
		if err := json.Unmarshal(dataJSON, &resource.Data); err != nil {
			return nil, fmt.Errorf("failed to unmarshal data: %w", err)
		}
	}

	if len(metadataJSON) > 0 {
		if err := json.Unmarshal(metadataJSON, &resource.Metadata); err != nil {
			return nil, fmt.Errorf("failed to unmarshal metadata: %w", err)
		}
	}

	resource.Vector = []float32(vector)

	return &resource, nil
}

func (r *resourceRepository) Update(ctx context.Context, resource *models.Resource) error {
	// Marshal JSON fields
	dataJSON, err := json.Marshal(resource.Data)
	if err != nil {
		return fmt.Errorf("failed to marshal data: %w", err)
	}

	metadataJSON, err := json.Marshal(resource.Metadata)
	if err != nil {
		return fmt.Errorf("failed to marshal metadata: %w", err)
	}

	query := `
		UPDATE resources
		SET type = $2, provider = $3, name = $4, data = $5, metadata = $6,
		    vector = $7, parent_id = $8, modified_at = $9
		WHERE id = $1
	`

	result, err := r.db.ExecContext(ctx, query,
		resource.ID, resource.Type, resource.Provider, resource.Name,
		dataJSON, metadataJSON, pq.Array(resource.Vector), resource.ParentID,
		resource.ModifiedAt,
	)

	if err != nil {
		return fmt.Errorf("failed to update resource: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}

	if rowsAffected == 0 {
		return fmt.Errorf("resource not found: %s", resource.ID)
	}

	return nil
}

func (r *resourceRepository) Delete(ctx context.Context, id string) error {
	query := `DELETE FROM resources WHERE id = $1`

	result, err := r.db.ExecContext(ctx, query, id)
	if err != nil {
		return fmt.Errorf("failed to delete resource: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}

	if rowsAffected == 0 {
		return fmt.Errorf("resource not found: %s", id)
	}

	return nil
}

func (r *resourceRepository) List(ctx context.Context, query *models.SearchQuery) ([]models.Resource, error) {
	// Build the SQL query with filters
	sqlQuery := `
		SELECT id, type, provider, name, data, metadata, vector, parent_id, created_at, modified_at
		FROM resources
	`

	var conditions []string
	var args []interface{}
	argIndex := 1

	// Add filters
	if query.Provider != "" {
		conditions = append(conditions, fmt.Sprintf("provider = $%d", argIndex))
		args = append(args, query.Provider)
		argIndex++
	}

	if query.Type != "" {
		conditions = append(conditions, fmt.Sprintf("type = $%d", argIndex))
		args = append(args, query.Type)
		argIndex++
	}

	if len(query.Filters) > 0 {
		for key, value := range query.Filters {
			// Use JSONB path queries for filtering by metadata/data fields
			if key == "region" || key == "environment" || key == "cost_center" {
				conditions = append(conditions, fmt.Sprintf("metadata->>%d = $%d", argIndex, argIndex+1))
				args = append(args, key, value)
				argIndex += 2
			}
		}
	}

	// Add WHERE clause if there are conditions
	if len(conditions) > 0 {
		sqlQuery += " WHERE " + strings.Join(conditions, " AND ")
	}

	// Add ORDER BY
	sqlQuery += fmt.Sprintf(" ORDER BY %s %s", query.SortBy, strings.ToUpper(query.SortOrder))

	// Add LIMIT and OFFSET
	sqlQuery += fmt.Sprintf(" LIMIT $%d OFFSET $%d", argIndex, argIndex+1)
	args = append(args, query.Limit, query.Offset)

	rows, err := r.db.QueryContext(ctx, sqlQuery, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to query resources: %w", err)
	}
	defer rows.Close()

	return r.scanResources(rows)
}

func (r *resourceRepository) Search(ctx context.Context, query *models.SearchQuery) ([]models.Resource, error) {
	// For semantic search, we'll use vector similarity when available
	// For now, implement text search on name and data fields
	sqlQuery := `
		SELECT id, type, provider, name, data, metadata, vector, parent_id, created_at, modified_at
		FROM resources
		WHERE (name ILIKE $1 OR data::text ILIKE $1)
	`

	var args []interface{}
	searchPattern := "%" + query.Query + "%"
	args = append(args, searchPattern)
	argIndex := 2

	// Add additional filters
	var conditions []string

	if query.Provider != "" {
		conditions = append(conditions, fmt.Sprintf("provider = $%d", argIndex))
		args = append(args, query.Provider)
		argIndex++
	}

	if query.Type != "" {
		conditions = append(conditions, fmt.Sprintf("type = $%d", argIndex))
		args = append(args, query.Type)
		argIndex++
	}

	if len(conditions) > 0 {
		sqlQuery += " AND " + strings.Join(conditions, " AND ")
	}

	// Add ORDER BY
	sqlQuery += fmt.Sprintf(" ORDER BY %s %s", query.SortBy, strings.ToUpper(query.SortOrder))

	// Add LIMIT and OFFSET
	sqlQuery += fmt.Sprintf(" LIMIT $%d OFFSET $%d", argIndex, argIndex+1)
	args = append(args, query.Limit, query.Offset)

	rows, err := r.db.QueryContext(ctx, sqlQuery, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to search resources: %w", err)
	}
	defer rows.Close()

	return r.scanResources(rows)
}

func (r *resourceRepository) GetByParentID(ctx context.Context, parentID string) ([]models.Resource, error) {
	query := `
		SELECT id, type, provider, name, data, metadata, vector, parent_id, created_at, modified_at
		FROM resources WHERE parent_id = $1
		ORDER BY created_at DESC
	`

	rows, err := r.db.QueryContext(ctx, query, parentID)
	if err != nil {
		return nil, fmt.Errorf("failed to query resources by parent: %w", err)
	}
	defer rows.Close()

	return r.scanResources(rows)
}

func (r *resourceRepository) VectorSearch(ctx context.Context, vector []float32, threshold float32, limit int) ([]models.Resource, error) {
	query := `
		SELECT id, type, provider, name, data, metadata, vector, parent_id, created_at, modified_at,
		       1 - (vector <=> $1) AS similarity
		FROM resources
		WHERE vector IS NOT NULL AND 1 - (vector <=> $1) > $2
		ORDER BY similarity DESC
		LIMIT $3
	`

	rows, err := r.db.QueryContext(ctx, query, pq.Array(vector), threshold, limit)
	if err != nil {
		return nil, fmt.Errorf("failed to perform vector search: %w", err)
	}
	defer rows.Close()

	var resources []models.Resource
	for rows.Next() {
		var resource models.Resource
		var dataJSON, metadataJSON []byte
		var vectorArray pq.Float32Array
		var similarity float32

		err := rows.Scan(
			&resource.ID, &resource.Type, &resource.Provider, &resource.Name,
			&dataJSON, &metadataJSON, &vectorArray, &resource.ParentID,
			&resource.CreatedAt, &resource.ModifiedAt, &similarity,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan vector search result: %w", err)
		}

		// Unmarshal JSON fields
		if len(dataJSON) > 0 {
			if err := json.Unmarshal(dataJSON, &resource.Data); err != nil {
				return nil, fmt.Errorf("failed to unmarshal data: %w", err)
			}
		}

		if len(metadataJSON) > 0 {
			if err := json.Unmarshal(metadataJSON, &resource.Metadata); err != nil {
				return nil, fmt.Errorf("failed to unmarshal metadata: %w", err)
			}
		}

		resource.Vector = []float32(vectorArray)
		resources = append(resources, resource)
	}

	if err = rows.Err(); err != nil {
		return nil, fmt.Errorf("error iterating vector search results: %w", err)
	}

	return resources, nil
}

func (r *resourceRepository) scanResources(rows *sql.Rows) ([]models.Resource, error) {
	var resources []models.Resource

	for rows.Next() {
		var resource models.Resource
		var dataJSON, metadataJSON []byte
		var vector pq.Float32Array

		err := rows.Scan(
			&resource.ID, &resource.Type, &resource.Provider, &resource.Name,
			&dataJSON, &metadataJSON, &vector, &resource.ParentID,
			&resource.CreatedAt, &resource.ModifiedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan resource: %w", err)
		}

		// Unmarshal JSON fields
		if len(dataJSON) > 0 {
			if err := json.Unmarshal(dataJSON, &resource.Data); err != nil {
				return nil, fmt.Errorf("failed to unmarshal data: %w", err)
			}
		}

		if len(metadataJSON) > 0 {
			if err := json.Unmarshal(metadataJSON, &resource.Metadata); err != nil {
				return nil, fmt.Errorf("failed to unmarshal metadata: %w", err)
			}
		}

		resource.Vector = []float32(vector)
		resources = append(resources, resource)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("error iterating resources: %w", err)
	}

	return resources, nil
}
