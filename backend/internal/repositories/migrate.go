package repositories

import (
	"database/sql"
	"fmt"
	"log"
)

// Migrate runs database migrations to ensure schema compatibility with MVC models
func Migrate(db *sql.DB) error {
	queries := []string{
		// Enable pgvector extension
		`CREATE EXTENSION IF NOT EXISTS vector`,

		// Drop old tables if they exist (development only)
		// TODO: Remove this in production and use proper migrations
		`DROP TABLE IF EXISTS change_records CASCADE`,
		`DROP TABLE IF EXISTS resources CASCADE`,
		`DROP TABLE IF EXISTS schemas CASCADE`,

		// Create resources table with MVC-compatible schema
		`CREATE TABLE IF NOT EXISTS resources (
			id VARCHAR(255) PRIMARY KEY,
			type VARCHAR(100) NOT NULL,
			provider VARCHAR(50) NOT NULL,
			name VARCHAR(255) NOT NULL,
			data JSONB NOT NULL,
			metadata JSONB NOT NULL,
			vector vector(1536), -- OpenAI embedding dimension
			parent_id VARCHAR(255) REFERENCES resources(id),
			created_at TIMESTAMP WITH TIME ZONE NOT NULL,
			modified_at TIMESTAMP WITH TIME ZONE NOT NULL
		)`,

		// Create schemas table
		`CREATE TABLE IF NOT EXISTS schemas (
			name VARCHAR(255) NOT NULL,
			provider VARCHAR(50) NOT NULL,
			type VARCHAR(100) NOT NULL,
			version VARCHAR(50) NOT NULL,
			schema JSONB NOT NULL,
			description TEXT,
			created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
			PRIMARY KEY (name, provider)
		)`,

		// Create change_records table for blockchain
		`CREATE TABLE IF NOT EXISTS change_records (
			id VARCHAR(255) PRIMARY KEY,
			resource_id VARCHAR(255) NOT NULL,
			operation VARCHAR(20) NOT NULL,
			changes JSONB NOT NULL,
			timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
			actor VARCHAR(255) NOT NULL,
			previous_hash VARCHAR(255),
			data_hash VARCHAR(255),
			signature VARCHAR(255)
		)`,

		// Create terraform_keys table
		`CREATE TABLE IF NOT EXISTS terraform_keys (
			key VARCHAR(255) PRIMARY KEY,
			path VARCHAR(500) NOT NULL,
			data JSONB NOT NULL,
			metadata JSONB,
			created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
			updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
		)`,

		// Create indexes for performance
		`CREATE INDEX IF NOT EXISTS idx_resources_provider ON resources(provider)`,
		`CREATE INDEX IF NOT EXISTS idx_resources_type ON resources(type)`,
		`CREATE INDEX IF NOT EXISTS idx_resources_parent ON resources(parent_id)`,
		`CREATE INDEX IF NOT EXISTS idx_resources_created ON resources(created_at)`,
		`CREATE INDEX IF NOT EXISTS idx_resources_data ON resources USING GIN(data)`,
		`CREATE INDEX IF NOT EXISTS idx_resources_metadata ON resources USING GIN(metadata)`,
		`CREATE INDEX IF NOT EXISTS idx_resources_vector ON resources USING ivfflat (vector vector_cosine_ops) WITH (lists = 100)`,

		`CREATE INDEX IF NOT EXISTS idx_change_records_resource ON change_records(resource_id)`,
		`CREATE INDEX IF NOT EXISTS idx_change_records_timestamp ON change_records(timestamp)`,
		`CREATE INDEX IF NOT EXISTS idx_change_records_operation ON change_records(operation)`,

		`CREATE INDEX IF NOT EXISTS idx_terraform_keys_path ON terraform_keys(path)`,
		`CREATE INDEX IF NOT EXISTS idx_terraform_keys_created ON terraform_keys(created_at)`,
	}

	for _, query := range queries {
		log.Printf("Executing migration: %s", query[:50]+"...")
		if _, err := db.Exec(query); err != nil {
			log.Printf("Migration query failed: %s", query)
			return fmt.Errorf("failed to execute migration: %w", err)
		}
	}

	log.Printf("Database migration completed successfully")
	return nil
}
