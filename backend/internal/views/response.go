package views

import (
	"encoding/json"
	"net/http"
	"time"

	"github.com/LederWorks/siros/backend/internal/models"
)

// APIResponse represents the standard API response format
type APIResponse struct {
	Data  interface{} `json:"data,omitempty"`
	Error *APIError   `json:"error,omitempty"`
	Meta  *Meta       `json:"meta,omitempty"`
}

// APIError represents error information in API responses
type APIError struct {
	Code    string `json:"code"`
	Message string `json:"message"`
	Details string `json:"details,omitempty"`
}

// Meta contains metadata about the response
type Meta struct {
	Timestamp time.Time `json:"timestamp"`
	Version   string    `json:"version"`
	Count     *int      `json:"count,omitempty"`
}

// WriteJSONResponse writes a standardized JSON response
func WriteJSONResponse(w http.ResponseWriter, status int, response APIResponse) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)

	if err := json.NewEncoder(w).Encode(response); err != nil {
		// Fallback error response
		http.Error(w, `{"error":{"code":"E500","message":"Failed to encode response"}}`, http.StatusInternalServerError)
	}
}

// WriteResourceResponse writes a single resource response
func WriteResourceResponse(w http.ResponseWriter, status int, resource *models.Resource) {
	response := APIResponse{
		Data: resource,
		Meta: &Meta{
			Timestamp: time.Now(),
			Version:   "1.0",
		},
	}
	WriteJSONResponse(w, status, response)
}

// WriteResourceListResponse writes a list of resources response
func WriteResourceListResponse(w http.ResponseWriter, status int, resources []models.Resource) {
	count := len(resources)
	response := APIResponse{
		Data: resources,
		Meta: &Meta{
			Timestamp: time.Now(),
			Version:   "1.0",
			Count:     &count,
		},
	}
	WriteJSONResponse(w, status, response)
}

// WriteSchemaResponse writes a schema response
func WriteSchemaResponse(w http.ResponseWriter, status int, schema *models.Schema) {
	response := APIResponse{
		Data: schema,
		Meta: &Meta{
			Timestamp: time.Now(),
			Version:   "1.0",
		},
	}
	WriteJSONResponse(w, status, response)
}

// WriteSchemaListResponse writes a list of schemas response
func WriteSchemaListResponse(w http.ResponseWriter, status int, schemas []models.Schema) {
	count := len(schemas)
	response := APIResponse{
		Data: schemas,
		Meta: &Meta{
			Timestamp: time.Now(),
			Version:   "1.0",
			Count:     &count,
		},
	}
	WriteJSONResponse(w, status, response)
}

// WriteSearchResponse writes a search result response
func WriteSearchResponse(w http.ResponseWriter, status int, results []models.Resource) {
	count := len(results)
	response := APIResponse{
		Data: results,
		Meta: &Meta{
			Timestamp: time.Now(),
			Version:   "1.0",
			Count:     &count,
		},
	}
	WriteJSONResponse(w, status, response)
}

// WriteError writes a standardized error response
func WriteError(w http.ResponseWriter, status int, message string, err error) {
	var details string
	if err != nil {
		details = err.Error()
	}

	response := APIResponse{
		Error: &APIError{
			Code:    generateErrorCode(status),
			Message: message,
			Details: details,
		},
		Meta: &Meta{
			Timestamp: time.Now(),
			Version:   "1.0",
		},
	}
	WriteJSONResponse(w, status, response)
}

// WriteNotFound writes a 404 not found response
func WriteNotFound(w http.ResponseWriter, resource string) {
	WriteError(w, http.StatusNotFound, resource+" not found", nil)
}

// WriteBadRequest writes a 400 bad request response
func WriteBadRequest(w http.ResponseWriter, message string, err error) {
	WriteError(w, http.StatusBadRequest, message, err)
}

// WriteInternalError writes a 500 internal server error response
func WriteInternalError(w http.ResponseWriter, message string, err error) {
	WriteError(w, http.StatusInternalServerError, message, err)
}

// WriteUnauthorized writes a 401 unauthorized response
func WriteUnauthorized(w http.ResponseWriter, message string) {
	WriteError(w, http.StatusUnauthorized, message, nil)
}

// WriteForbidden writes a 403 forbidden response
func WriteForbidden(w http.ResponseWriter, message string) {
	WriteError(w, http.StatusForbidden, message, nil)
}

// WriteConflict writes a 409 conflict response
func WriteConflict(w http.ResponseWriter, message string, err error) {
	WriteError(w, http.StatusConflict, message, err)
}

// WriteNoContent writes a 204 no content response
func WriteNoContent(w http.ResponseWriter) {
	w.WriteHeader(http.StatusNoContent)
}

// generateErrorCode generates a standardized error code from HTTP status
func generateErrorCode(status int) string {
	switch status {
	case http.StatusBadRequest:
		return "E400"
	case http.StatusUnauthorized:
		return "E401"
	case http.StatusForbidden:
		return "E403"
	case http.StatusNotFound:
		return "E404"
	case http.StatusConflict:
		return "E409"
	case http.StatusInternalServerError:
		return "E500"
	default:
		return "E" + string(rune(status))
	}
}
