package providers

import (
	"context"
	"fmt"
	"time"

	"github.com/LederWorks/siros/backend/internal/config"
	"github.com/LederWorks/siros/backend/pkg/types"
)

// Manager manages multiple cloud providers
type Manager struct {
	providers map[string]types.Provider
	config    config.ProvidersConfig
}

// NewManager creates a new provider manager
func NewManager(cfg config.ProvidersConfig) *Manager {
	return &Manager{
		providers: make(map[string]types.Provider),
		config:    cfg,
	}
}

// RegisterProvider registers a cloud provider
func (m *Manager) RegisterProvider(name string, provider types.Provider) {
	m.providers[name] = provider
}

// GetProvider returns a provider by name
func (m *Manager) GetProvider(name string) (types.Provider, error) {
	provider, exists := m.providers[name]
	if !exists {
		return nil, fmt.Errorf("provider %s not found", name)
	}
	return provider, nil
}

// ScanAll scans all registered providers for resources
func (m *Manager) ScanAll(ctx context.Context) ([]types.Resource, error) {
	var allResources []types.Resource

	for name, provider := range m.providers {
		resources, err := provider.Scan(ctx)
		if err != nil {
			return nil, fmt.Errorf("failed to scan provider %s: %w", name, err)
		}

		// Set scan timestamp
		now := time.Now()
		for i := range resources {
			resources[i].LastScannedAt = &now
		}

		allResources = append(allResources, resources...)
	}

	return allResources, nil
}

// ValidateAll validates all registered providers
func (m *Manager) ValidateAll() error {
	for name, provider := range m.providers {
		if err := provider.Validate(); err != nil {
			return fmt.Errorf("provider %s validation failed: %w", name, err)
		}
	}
	return nil
}
