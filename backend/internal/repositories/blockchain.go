package repositories

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"

	"github.com/LederWorks/siros/backend/internal/models"
)

// blockchainRepository implements BlockchainRepository
type blockchainRepository struct {
	db *sql.DB
}

// NewBlockchainRepository creates a new blockchain repository
func NewBlockchainRepository(db *sql.DB) BlockchainRepository {
	return &blockchainRepository{db: db}
}

func (r *blockchainRepository) CreateRecord(ctx context.Context, record *models.ChangeRecord) error {
	changesJSON, err := json.Marshal(record.Changes)
	if err != nil {
		return fmt.Errorf("failed to marshal changes: %w", err)
	}

	query := `
		INSERT INTO change_records (id, resource_id, operation, changes, timestamp, actor, previous_hash, data_hash, signature)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
	`

	_, err = r.db.ExecContext(ctx, query,
		record.ID, record.ResourceID, record.Operation, changesJSON,
		record.Timestamp, record.Actor, record.PreviousHash, record.DataHash, record.Signature,
	)

	if err != nil {
		return fmt.Errorf("failed to insert change record: %w", err)
	}

	return nil
}

func (r *blockchainRepository) GetRecordsByResourceID(ctx context.Context, resourceID string) ([]models.ChangeRecord, error) {
	query := `
		SELECT id, resource_id, operation, changes, timestamp, actor, previous_hash, data_hash, signature
		FROM change_records
		WHERE resource_id = $1
		ORDER BY timestamp DESC
	`

	rows, err := r.db.QueryContext(ctx, query, resourceID)
	if err != nil {
		return nil, fmt.Errorf("failed to query change records: %w", err)
	}
	defer rows.Close()

	var records []models.ChangeRecord
	for rows.Next() {
		var record models.ChangeRecord
		var changesJSON []byte

		err := rows.Scan(
			&record.ID, &record.ResourceID, &record.Operation, &changesJSON,
			&record.Timestamp, &record.Actor, &record.PreviousHash, &record.DataHash, &record.Signature,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan change record: %w", err)
		}

		if len(changesJSON) > 0 {
			if err := json.Unmarshal(changesJSON, &record.Changes); err != nil {
				return nil, fmt.Errorf("failed to unmarshal changes: %w", err)
			}
		}

		records = append(records, record)
	}

	if err = rows.Err(); err != nil {
		return nil, fmt.Errorf("error iterating change records: %w", err)
	}

	return records, nil
}

func (r *blockchainRepository) GetLatestRecord(ctx context.Context, resourceID string) (*models.ChangeRecord, error) {
	query := `
		SELECT id, resource_id, operation, changes, timestamp, actor, previous_hash, data_hash, signature
		FROM change_records
		WHERE resource_id = $1
		ORDER BY timestamp DESC
		LIMIT 1
	`

	row := r.db.QueryRowContext(ctx, query, resourceID)

	var record models.ChangeRecord
	var changesJSON []byte

	err := row.Scan(
		&record.ID, &record.ResourceID, &record.Operation, &changesJSON,
		&record.Timestamp, &record.Actor, &record.PreviousHash, &record.DataHash, &record.Signature,
	)

	if err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("no change records found for resource: %s", resourceID)
		}
		return nil, fmt.Errorf("failed to scan latest change record: %w", err)
	}

	if len(changesJSON) > 0 {
		if err := json.Unmarshal(changesJSON, &record.Changes); err != nil {
			return nil, fmt.Errorf("failed to unmarshal changes: %w", err)
		}
	}

	return &record, nil
}
