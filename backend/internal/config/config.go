package config

import (
	"fmt"
	"os"

	"gopkg.in/yaml.v3"
)

// Config represents the application configuration
type Config struct {
	Server     ServerConfig     `yaml:"server"`
	Database   DatabaseConfig   `yaml:"database"`
	Vector     VectorConfig     `yaml:"vector"`
	Blockchain BlockchainConfig `yaml:"blockchain"`
	Providers  ProvidersConfig  `yaml:"providers"`
}

// ServerConfig contains HTTP server settings
type ServerConfig struct {
	Host         string `yaml:"host" env:"SIROS_HOST"`
	Port         int    `yaml:"port" env:"SIROS_PORT"`
	ReadTimeout  int    `yaml:"read_timeout"`
	WriteTimeout int    `yaml:"write_timeout"`
	TLS          struct {
		Enabled  bool   `yaml:"enabled"`
		CertFile string `yaml:"cert_file"`
		KeyFile  string `yaml:"key_file"`
	} `yaml:"tls"`
}

// DatabaseConfig contains database connection settings
type DatabaseConfig struct {
	Driver   string `yaml:"driver"`
	Host     string `yaml:"host" env:"SIROS_DB_HOST"`
	Port     int    `yaml:"port" env:"SIROS_DB_PORT"`
	Database string `yaml:"database" env:"SIROS_DB_NAME"`
	Username string `yaml:"username" env:"SIROS_DB_USER"`
	Password string `yaml:"password" env:"SIROS_DB_PASSWORD"`
	SSLMode  string `yaml:"ssl_mode"`
	MaxConns int    `yaml:"max_connections"`
}

// VectorConfig contains vector database settings
type VectorConfig struct {
	Provider string            `yaml:"provider"` // "pgvector" or "weaviate"
	Weaviate WeaviateConfig    `yaml:"weaviate"`
	PgVector PostgresConfig    `yaml:"pgvector"`
	Settings map[string]string `yaml:"settings"`
}

// WeaviateConfig contains Weaviate-specific settings
type WeaviateConfig struct {
	Host   string `yaml:"host"`
	Scheme string `yaml:"scheme"`
	APIKey string `yaml:"api_key" env:"WEAVIATE_API_KEY"`
}

// PostgresConfig contains PostgreSQL/pgvector settings
type PostgresConfig struct {
	Host     string `yaml:"host"`
	Port     int    `yaml:"port"`
	Database string `yaml:"database"`
	Username string `yaml:"username"`
	Password string `yaml:"password"`
}

// BlockchainConfig contains blockchain integration settings
type BlockchainConfig struct {
	Enabled  bool   `yaml:"enabled"`
	Provider string `yaml:"provider"` // "ethereum", "polygon", etc.
	Network  string `yaml:"network"`
	Endpoint string `yaml:"endpoint"`
	Contract string `yaml:"contract_address"`
}

// ProvidersConfig contains cloud provider settings
type ProvidersConfig struct {
	AWS   AWSConfig   `yaml:"aws"`
	Azure AzureConfig `yaml:"azure"`
	GCP   GCPConfig   `yaml:"gcp"`
}

// AWSConfig contains AWS-specific settings
type AWSConfig struct {
	Region          string `yaml:"region" env:"AWS_REGION"`
	AccessKeyID     string `yaml:"access_key_id" env:"AWS_ACCESS_KEY_ID"`
	SecretAccessKey string `yaml:"secret_access_key" env:"AWS_SECRET_ACCESS_KEY"`
	SessionToken    string `yaml:"session_token" env:"AWS_SESSION_TOKEN"`
}

// AzureConfig contains Azure-specific settings
type AzureConfig struct {
	TenantID       string `yaml:"tenant_id" env:"AZURE_TENANT_ID"`
	ClientID       string `yaml:"client_id" env:"AZURE_CLIENT_ID"`
	ClientSecret   string `yaml:"client_secret" env:"AZURE_CLIENT_SECRET"`
	SubscriptionID string `yaml:"subscription_id" env:"AZURE_SUBSCRIPTION_ID"`
}

// GCPConfig contains GCP-specific settings
type GCPConfig struct {
	ProjectID             string `yaml:"project_id" env:"GCP_PROJECT_ID"`
	ServiceAccountKeyFile string `yaml:"service_account_key_file"`
	Region                string `yaml:"region"`
}

// Load loads configuration from file with environment variable overrides
func Load(path string) (*Config, error) {
	cfg := &Config{
		Server: ServerConfig{
			Host:         "0.0.0.0",
			Port:         8080,
			ReadTimeout:  30,
			WriteTimeout: 30,
		},
		Database: DatabaseConfig{
			Driver:   "postgres",
			Host:     "localhost",
			Port:     5432,
			Database: "siros",
			Username: "siros",
			SSLMode:  "disable",
			MaxConns: 10,
		},
		Vector: VectorConfig{
			Provider: "pgvector",
		},
	}

	// Load from file if it exists
	if _, err := os.Stat(path); err == nil {
		data, err := os.ReadFile(path)
		if err != nil {
			return nil, fmt.Errorf("failed to read config file: %w", err)
		}

		if err := yaml.Unmarshal(data, cfg); err != nil {
			return nil, fmt.Errorf("failed to parse config file: %w", err)
		}
	}

	// Override with environment variables
	loadEnvVars(cfg)

	return cfg, nil
}

// loadEnvVars loads environment variables into config
func loadEnvVars(cfg *Config) {
	if val := os.Getenv("SIROS_HOST"); val != "" {
		cfg.Server.Host = val
	}
	if val := os.Getenv("SIROS_DB_HOST"); val != "" {
		cfg.Database.Host = val
	}
	if val := os.Getenv("SIROS_DB_PASSWORD"); val != "" {
		cfg.Database.Password = val
	}
	// Add more environment variable mappings as needed
}

// ConnectionString returns the database connection string
func (d *DatabaseConfig) ConnectionString() string {
	return fmt.Sprintf("%s://%s:%s@%s:%d/%s?sslmode=%s",
		d.Driver, d.Username, d.Password, d.Host, d.Port, d.Database, d.SSLMode)
}
