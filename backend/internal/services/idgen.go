package services

import (
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"time"
)

// uuidGenerator implements IDGenerator using a simple UUID-like approach
type uuidGenerator struct{}

// NewIDGenerator creates a new ID generator
func NewIDGenerator() IDGenerator {
	return &uuidGenerator{}
}

func (g *uuidGenerator) Generate() string {
	// Generate 16 random bytes
	bytes := make([]byte, 16)
	if _, err := rand.Read(bytes); err != nil {
		// Fallback to timestamp-based ID if random fails
		return fmt.Sprintf("siros-%d", time.Now().UnixNano())
	}

	// Convert to hex string
	return fmt.Sprintf("siros-%s", hex.EncodeToString(bytes))
}

// hashGenerator implements a hash-based ID generator
type hashGenerator struct {
	prefix string
}

// NewHashIDGenerator creates a new hash-based ID generator
func NewHashIDGenerator(prefix string) IDGenerator {
	return &hashGenerator{prefix: prefix}
}

func (g *hashGenerator) Generate() string {
	// Generate hash from current timestamp and random bytes
	timestamp := time.Now().UnixNano()
	randomBytes := make([]byte, 8)
	if _, err := rand.Read(randomBytes); err != nil {
		// Fall back to timestamp-based ID if random generation fails
		timestamp := time.Now().UnixNano()
		data := fmt.Sprintf("%d", timestamp)
		hash := sha256.Sum256([]byte(data))
		return fmt.Sprintf("%s-%s", g.prefix, hex.EncodeToString(hash[:8]))
	}

	data := fmt.Sprintf("%d-%s", timestamp, hex.EncodeToString(randomBytes))
	hash := sha256.Sum256([]byte(data))

	return fmt.Sprintf("%s-%s", g.prefix, hex.EncodeToString(hash[:8]))
}
