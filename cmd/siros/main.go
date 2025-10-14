package main

import (
	"context"
	"flag"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/LederWorks/siros/internal/api"
	"github.com/LederWorks/siros/internal/config"
	"github.com/LederWorks/siros/internal/storage"
	"github.com/LederWorks/siros"
)

func main() {
	var configPath = flag.String("config", "config.yaml", "path to configuration file")
	var addr = flag.String("addr", ":8080", "server address")
	flag.Parse()

	// Load configuration
	cfg, err := config.Load(*configPath)
	if err != nil {
		log.Fatalf("Failed to load config: %v", err)
	}

	// Initialize storage
	storage, err := storage.New(cfg.Database)
	if err != nil {
		log.Fatalf("Failed to initialize storage: %v", err)
	}
	defer storage.Close()

	// Initialize API server
	server := api.NewServer(cfg, storage, siros.WebAssets)

	// Start HTTP server
	httpServer := &http.Server{
		Addr:    *addr,
		Handler: server.Router(),
	}

	// Graceful shutdown
	_, cancel := context.WithCancel(context.Background())
	defer cancel()

	go func() {
		log.Printf("Starting Siros server on %s", *addr)
		if err := httpServer.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Server failed: %v", err)
		}
	}()

	// Wait for interrupt signal
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)
	<-sigChan

	log.Println("Shutting down server...")

	// Graceful shutdown with timeout
	shutdownCtx, shutdownCancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer shutdownCancel()

	if err := httpServer.Shutdown(shutdownCtx); err != nil {
		log.Fatalf("Server shutdown failed: %v", err)
	}

	log.Println("Server stopped")
}