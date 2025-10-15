package middleware

import (
	"log"
	"net/http"
	"runtime/debug"
	"time"
)

// LoggingMiddleware logs HTTP requests and responses
func LoggingMiddleware(logger *log.Logger) Middleware {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			start := time.Now()

			// Create a response writer wrapper to capture status code
			wrapped := &responseWriter{ResponseWriter: w, statusCode: http.StatusOK}

			// Get request ID from context
			requestID, _ := r.Context().Value("requestID").(string)

			// Log request
			logger.Printf("[%s] %s %s %s - Started", requestID, r.Method, r.URL.Path, r.RemoteAddr)

			// Process request
			next.ServeHTTP(wrapped, r)

			// Log response
			duration := time.Since(start)
			logger.Printf("[%s] %s %s %s - %d %s (%v)",
				requestID, r.Method, r.URL.Path, r.RemoteAddr,
				wrapped.statusCode, http.StatusText(wrapped.statusCode), duration)
		})
	}
}

// RecoveryMiddleware recovers from panics and returns a 500 error
func RecoveryMiddleware(logger *log.Logger) Middleware {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			defer func() {
				if err := recover(); err != nil {
					requestID, _ := r.Context().Value("requestID").(string)

					logger.Printf("[%s] PANIC: %v\n%s", requestID, err, debug.Stack())

					w.Header().Set("Content-Type", "application/json")
					w.WriteHeader(http.StatusInternalServerError)
					if _, writeErr := w.Write([]byte(`{"success":false,"error":"Internal server error"}`)); writeErr != nil {
						logger.Printf("[%s] Failed to write panic response: %v", requestID, writeErr)
					}
				}
			}()

			next.ServeHTTP(w, r)
		})
	}
}

// responseWriter wraps http.ResponseWriter to capture status code
type responseWriter struct {
	http.ResponseWriter
	statusCode int
}

func (rw *responseWriter) WriteHeader(code int) {
	rw.statusCode = code
	rw.ResponseWriter.WriteHeader(code)
}
