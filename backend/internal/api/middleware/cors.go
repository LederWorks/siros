package middleware

import (
	"net/http"
	"time"

	"github.com/rs/cors"
)

// CORSMiddleware handles Cross-Origin Resource Sharing
func CORSMiddleware() Middleware {
	c := cors.New(cors.Options{
		AllowedOrigins: []string{"*"}, // TODO: Configure properly for production
		AllowedMethods: []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowedHeaders: []string{
			"Origin",
			"Content-Type",
			"Accept",
			"Authorization",
			"X-Requested-With",
			"X-Request-ID",
		},
		ExposedHeaders: []string{
			"X-Request-ID",
		},
		AllowCredentials: true,
		MaxAge:           int((24 * time.Hour).Seconds()),
	})

	return func(next http.Handler) http.Handler {
		return c.Handler(next)
	}
}

// CORSConfig holds CORS configuration options
type CORSConfig struct {
	AllowedOrigins   []string
	AllowedMethods   []string
	AllowedHeaders   []string
	ExposedHeaders   []string
	AllowCredentials bool
	MaxAge           time.Duration
}

// DefaultCORSConfig returns a default CORS configuration
func DefaultCORSConfig() *CORSConfig {
	return &CORSConfig{
		AllowedOrigins: []string{"*"}, // TODO: Configure for production
		AllowedMethods: []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowedHeaders: []string{
			"Origin",
			"Content-Type",
			"Accept",
			"Authorization",
			"X-Requested-With",
			"X-Request-ID",
		},
		ExposedHeaders: []string{
			"X-Request-ID",
		},
		AllowCredentials: true,
		MaxAge:           24 * time.Hour,
	}
}

// CORSMiddlewareWithConfig creates CORS middleware with custom configuration
func CORSMiddlewareWithConfig(config *CORSConfig) Middleware {
	c := cors.New(cors.Options{
		AllowedOrigins:   config.AllowedOrigins,
		AllowedMethods:   config.AllowedMethods,
		AllowedHeaders:   config.AllowedHeaders,
		ExposedHeaders:   config.ExposedHeaders,
		AllowCredentials: config.AllowCredentials,
		MaxAge:           int(config.MaxAge.Seconds()),
	})

	return func(next http.Handler) http.Handler {
		return c.Handler(next)
	}
}
