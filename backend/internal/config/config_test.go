package config

import (
	"os"
	"strings"
	"testing"
)

func TestLoad(t *testing.T) {
	// Test loading default config
	cfg, err := Load("nonexistent.yaml")
	if err != nil {
		t.Fatalf("Expected no error for nonexistent file, got: %v", err)
	}

	// Test default values
	if cfg.Server.Host != "0.0.0.0" {
		t.Errorf("Expected default host '0.0.0.0', got: %s", cfg.Server.Host)
	}

	if cfg.Server.Port != 8080 {
		t.Errorf("Expected default port 8080, got: %d", cfg.Server.Port)
	}

	if cfg.Database.Driver != "postgres" {
		t.Errorf("Expected default driver 'postgres', got: %s", cfg.Database.Driver)
	}
}

func TestEnvironmentVariableOverrides(t *testing.T) {
	// Set environment variables
	os.Setenv("SIROS_HOST", "127.0.0.1")
	os.Setenv("SIROS_DB_HOST", "testhost")
	defer func() {
		os.Unsetenv("SIROS_HOST")
		os.Unsetenv("SIROS_DB_HOST")
	}()

	cfg, err := Load("nonexistent.yaml")
	if err != nil {
		t.Fatalf("Expected no error, got: %v", err)
	}

	if cfg.Server.Host != "127.0.0.1" {
		t.Errorf("Expected host '127.0.0.1' from env var, got: %s", cfg.Server.Host)
	}

	if cfg.Database.Host != "testhost" {
		t.Errorf("Expected db host 'testhost' from env var, got: %s", cfg.Database.Host)
	}
}

func TestConnectionString(t *testing.T) {
	cfg := DatabaseConfig{
		Driver:   "postgres",
		Host:     "localhost",
		Port:     5432,
		Database: "testdb",
		Username: "testuser",
		Password: "testpass",
		SSLMode:  "disable",
	}

	expected := "postgres://testuser:testpass@localhost:5432/testdb?sslmode=disable"
	actual := cfg.ConnectionString()

	if actual != expected {
		t.Errorf("Expected connection string '%s', got: '%s'", expected, actual)
	}
}

func TestValidateConfigPath(t *testing.T) {
	tests := []struct {
		name    string
		path    string
		wantErr bool
		errMsg  string
	}{
		{
			name:    "valid yaml file",
			path:    "config.yaml",
			wantErr: false,
		},
		{
			name:    "valid yml file",
			path:    "config.yml",
			wantErr: false,
		},
		{
			name:    "valid json file",
			path:    "config.json",
			wantErr: false,
		},
		{
			name:    "empty path",
			path:    "",
			wantErr: true,
			errMsg:  "config path cannot be empty",
		},
		{
			name:    "directory traversal attempt",
			path:    "../../../etc/passwd.yaml",
			wantErr: true,
			errMsg:  "config path cannot contain directory traversal sequences",
		},
		{
			name:    "invalid extension",
			path:    "config.txt",
			wantErr: true,
			errMsg:  "config file must have .yaml, .yml, or .json extension",
		},
		{
			name:    "path with dots but valid",
			path:    "my.config.yaml",
			wantErr: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := validateConfigPath(tt.path)

			if tt.wantErr {
				if err == nil {
					t.Errorf("validateConfigPath() expected error but got none")
					return
				}
				if !strings.Contains(err.Error(), tt.errMsg) {
					t.Errorf("validateConfigPath() error = %v, want error containing %v", err, tt.errMsg)
				}
			} else {
				if err != nil {
					t.Errorf("validateConfigPath() unexpected error = %v", err)
				}
			}
		})
	}
}

func TestLoadWithInvalidPath(t *testing.T) {
	// Test that Load properly handles invalid paths
	_, err := Load("../../../etc/passwd.yaml")
	if err == nil {
		t.Error("Expected error for directory traversal attempt, got none")
	}

	if !strings.Contains(err.Error(), "invalid config file path") {
		t.Errorf("Expected error about invalid config file path, got: %v", err)
	}
}
