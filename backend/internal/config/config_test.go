package config

import (
	"os"
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
