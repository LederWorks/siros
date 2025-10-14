package middleware

import (
	"context"
	"log"
	"net/http"
	"strings"
)

// Context key types to avoid collisions
type contextKey string

const (
	contextKeyAPIKey contextKey = "apiKey"
	contextKeyToken  contextKey = "token"
	contextKeyUser   contextKey = "user"
)

// AuthMiddleware handles authentication
func AuthMiddleware() Middleware {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			// TODO: Implement proper authentication
			// For now, just pass through all requests

			next.ServeHTTP(w, r)
		})
	}
}

// APIKeyMiddleware handles API key authentication
func APIKeyMiddleware(validAPIKeys []string) Middleware {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			apiKey := r.Header.Get("X-API-Key")
			if apiKey == "" {
				apiKey = r.URL.Query().Get("api_key")
			}

			if apiKey == "" {
				writeAuthError(w, "Missing API key")
				return
			}

			// Validate API key
			valid := false
			for _, validKey := range validAPIKeys {
				if apiKey == validKey {
					valid = true
					break
				}
			}

			if !valid {
				writeAuthError(w, "Invalid API key")
				return
			}

			// Add API key to context
			ctx := context.WithValue(r.Context(), contextKeyAPIKey, apiKey)
			r = r.WithContext(ctx)

			next.ServeHTTP(w, r)
		})
	}
}

// JWTMiddleware handles JWT token authentication (placeholder)
func JWTMiddleware(_ string) Middleware {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			// TODO: Implement JWT validation
			// This is a placeholder for JWT authentication

			authHeader := r.Header.Get("Authorization")
			if authHeader == "" {
				writeAuthError(w, "Missing authorization header")
				return
			}

			// Extract Bearer token
			token := extractToken(authHeader)
			if token == "" {
				writeAuthError(w, "Invalid authorization header format")
				return
			}

			// TODO: Validate JWT token with secretKey
			// For now, just pass through

			// Add token to context
			ctx := context.WithValue(r.Context(), contextKeyToken, token)
			r = r.WithContext(ctx)

			next.ServeHTTP(w, r)
		})
	}
}

// OptionalAuthMiddleware makes authentication optional
func OptionalAuthMiddleware() Middleware {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			// Extract user info if present, but don't require it
			authHeader := r.Header.Get("Authorization")
			if authHeader != "" {
				// Extract token if present and add to context
				token := extractToken(authHeader)
				if token != "" {
					ctx := context.WithValue(r.Context(), contextKeyToken, token)
					r = r.WithContext(ctx)
				}
			}

			next.ServeHTTP(w, r)
		})
	}
}

// writeAuthError writes a standardized authentication error response
func writeAuthError(w http.ResponseWriter, message string) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusUnauthorized)

	response := `{"error":{"code":"E401","message":"` + message + `"}}`
	if _, err := w.Write([]byte(response)); err != nil {
		// Log error but don't try to handle it further
		log.Printf("Failed to write auth error response: %v", err)
	}
}

// extractToken extracts token from Authorization header
func extractToken(authHeader string) string {
	parts := strings.Split(authHeader, " ")
	if len(parts) == 2 && parts[0] == "Bearer" {
		return parts[1]
	}
	return ""
}
