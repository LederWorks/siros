package repositories

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"

	"github.com/LederWorks/siros/backend/internal/models"
)

// schemaRepository implements SchemaRepository
type schemaRepository struct {
	db *sql.DB
}

// NewSchemaRepository creates a new schema repository
func NewSchemaRepository(db *sql.DB) *schemaRepository {
	return &schemaRepository{db: db}
}

func (r *schemaRepository) Create(ctx context.Context, schema *models.Schema) error {
	schemaJSON, err := json.Marshal(schema.Schema)
	if err != nil {
		return fmt.Errorf("failed to marshal schema: %w", err)
	}

	query := `
		INSERT INTO schemas (name, provider, type, version, schema, description, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
	`

	_, err = r.db.ExecContext(ctx, query,
		schema.Name, schema.Provider, schema.Type, schema.Version,
		schemaJSON, schema.Description, schema.CreatedAt,
	)

	if err != nil {
		return fmt.Errorf("failed to insert schema: %w", err)
	}

	return nil
}

func (r *schemaRepository) GetByID(ctx context.Context, id string) (*models.Schema, error) {
	query := `
		SELECT name, provider, type, version, schema, description, created_at
		FROM schemas WHERE name = $1
	`

	row := r.db.QueryRowContext(ctx, query, id)

	var schema models.Schema
	var schemaJSON []byte

	err := row.Scan(
		&schema.Name, &schema.Provider, &schema.Type, &schema.Version,
		&schemaJSON, &schema.Description, &schema.CreatedAt,
	)

	if err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("schema not found: %s", id)
		}
		return nil, fmt.Errorf("failed to scan schema: %w", err)
	}

	if len(schemaJSON) > 0 {
		if err := json.Unmarshal(schemaJSON, &schema.Schema); err != nil {
			return nil, fmt.Errorf("failed to unmarshal schema: %w", err)
		}
	}

	return &schema, nil
}

func (r *schemaRepository) Update(ctx context.Context, schema *models.Schema) error {
	schemaJSON, err := json.Marshal(schema.Schema)
	if err != nil {
		return fmt.Errorf("failed to marshal schema: %w", err)
	}

	query := `
		UPDATE schemas
		SET provider = $2, type = $3, version = $4, schema = $5, description = $6
		WHERE name = $1
	`

	result, err := r.db.ExecContext(ctx, query,
		schema.Name, schema.Provider, schema.Type, schema.Version,
		schemaJSON, schema.Description,
	)

	if err != nil {
		return fmt.Errorf("failed to update schema: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}

	if rowsAffected == 0 {
		return fmt.Errorf("schema not found: %s", schema.Name)
	}

	return nil
}

func (r *schemaRepository) Delete(ctx context.Context, id string) error {
	query := `DELETE FROM schemas WHERE name = $1`

	result, err := r.db.ExecContext(ctx, query, id)
	if err != nil {
		return fmt.Errorf("failed to delete schema: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}

	if rowsAffected == 0 {
		return fmt.Errorf("schema not found: %s", id)
	}

	return nil
}

func (r *schemaRepository) List(ctx context.Context) ([]models.Schema, error) {
	query := `
		SELECT name, provider, type, version, schema, description, created_at
		FROM schemas
		ORDER BY created_at DESC
	`

	rows, err := r.db.QueryContext(ctx, query)
	if err != nil {
		return nil, fmt.Errorf("failed to query schemas: %w", err)
	}
	defer rows.Close()

	var schemas []models.Schema
	for rows.Next() {
		var schema models.Schema
		var schemaJSON []byte

		err := rows.Scan(
			&schema.Name, &schema.Provider, &schema.Type, &schema.Version,
			&schemaJSON, &schema.Description, &schema.CreatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan schema: %w", err)
		}

		if len(schemaJSON) > 0 {
			if err := json.Unmarshal(schemaJSON, &schema.Schema); err != nil {
				return nil, fmt.Errorf("failed to unmarshal schema: %w", err)
			}
		}

		schemas = append(schemas, schema)
	}

	if err = rows.Err(); err != nil {
		return nil, fmt.Errorf("error iterating schemas: %w", err)
	}

	return schemas, nil
}

func (r *schemaRepository) GetByName(ctx context.Context, name string) (*models.Schema, error) {
	return r.GetByID(ctx, name)
}
