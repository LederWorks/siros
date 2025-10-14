package main

import (
	"log"
	"net/http"

	"github.com/LederWorks/siros/backend/internal/api"
)

func main() {
	mux := http.NewServeMux()

	// API routes
	api.RegisterRoutes(mux)

	// Default handler
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/html")
		w.Write([]byte(`<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Siros - Multi-Cloud Resource Platform</title>
</head>
<body>
    <h1>Siros Backend</h1>
    <p>Multi-cloud resource platform running successfully.</p>
</body>
</html>`))
	})

	log.Println("Siros server running on :8080")
	log.Fatal(http.ListenAndServe(":8080", mux))
}
