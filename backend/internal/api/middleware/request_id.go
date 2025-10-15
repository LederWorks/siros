package middleware

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"net/http"
)

// Context key type to avoid collisions
type requestIDKey string

const contextKeyRequestID requestIDKey = "requestID"

// RequestIDMiddleware adds a unique request ID to each request
func RequestIDMiddleware() Middleware {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			// Check if request ID already exists (e.g., from load balancer)
			requestID := r.Header.Get("X-Request-ID")
			if requestID == "" {
				// Generate a new request ID
				requestID = generateRequestID()
			}

			// Add request ID to response headers
			w.Header().Set("X-Request-ID", requestID)

			// Add request ID to context
			ctx := context.WithValue(r.Context(), contextKeyRequestID, requestID)
			r = r.WithContext(ctx)

			next.ServeHTTP(w, r)
		})
	}
}

// generateRequestID generates a unique request ID
func generateRequestID() string {
	bytes := make([]byte, 16)
	if _, err := rand.Read(bytes); err != nil {
		// Fallback to timestamp-based ID if random fails
		return "req-" + hex.EncodeToString([]byte("fallback"))
	}
	return hex.EncodeToString(bytes)
}

// GetRequestID extracts request ID from context
func GetRequestID(r *http.Request) string {
	if requestID, ok := r.Context().Value(contextKeyRequestID).(string); ok {
		return requestID
	}
	return ""
}
