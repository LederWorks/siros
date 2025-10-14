package middleware

import (
	"log"
	"net/http"

	"github.com/gorilla/mux"
)

// Config holds middleware configuration
type Config struct {
	EnableCORS    bool
	EnableLogging bool
	EnableAuth    bool
	Logger        *log.Logger
}

// DefaultConfig returns a default middleware configuration
func DefaultConfig(logger *log.Logger) *Config {
	return &Config{
		EnableCORS:    true,
		EnableLogging: true,
		EnableAuth:    false, // TODO: Implement authentication
		Logger:        logger,
	}
}

// Apply applies all configured middleware to the router
func (c *Config) Apply(router *mux.Router) http.Handler {
	var handler http.Handler = router

	// Apply middleware in reverse order (last applied is first executed)

	// Recovery middleware (should be last/first to catch panics)
	handler = RecoveryMiddleware(c.Logger)(handler)

	// Request ID middleware
	handler = RequestIDMiddleware()(handler)

	// Logging middleware
	if c.EnableLogging {
		handler = LoggingMiddleware(c.Logger)(handler)
	}

	// Authentication middleware
	if c.EnableAuth {
		handler = AuthMiddleware()(handler)
	}

	// CORS middleware
	if c.EnableCORS {
		handler = CORSMiddleware()(handler)
	}

	return handler
}

// Middleware is a function type for HTTP middleware
type Middleware func(http.Handler) http.Handler

// Chain chains multiple middleware together
func Chain(middlewares ...Middleware) Middleware {
	return func(handler http.Handler) http.Handler {
		for i := len(middlewares) - 1; i >= 0; i-- {
			handler = middlewares[i](handler)
		}
		return handler
	}
}
