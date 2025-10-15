package main

import (
	"context"
	"database/sql"
	"embed"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	_ "github.com/lib/pq"
	"github.com/rs/cors"

	"github.com/LederWorks/siros/backend/internal/api"
	"github.com/LederWorks/siros/backend/internal/config"
	"github.com/LederWorks/siros/backend/internal/storage"
)

// Version information (set during build)
var (
	version = "dev"
	commit  = "unknown"
	date    = "unknown"
)

//go:embed static
var webAssets embed.FS

// App holds the application dependencies
type App struct {
	logger *log.Logger
	config *config.Config
	db     *sql.DB
	server *api.Server
}

func main() {
	if err := run(); err != nil {
		log.Fatalf("Application failed: %v", err)
	}
}

func run() error {
	// Initialize logger
	logger := log.New(os.Stdout, "siros: ", log.LstdFlags|log.Lshortfile)

	// Log version information
	logger.Printf("Siros version %s (commit: %s, built: %s)", version, commit, date)

	// Load configuration
	cfg, err := config.Load("config.yaml")
	if err != nil {
		return fmt.Errorf("failed to load config: %w", err)
	}

	// Connect to database
	db, err := connectDB(&cfg.Database)
	if err != nil {
		return fmt.Errorf("failed to connect to database: %w", err)
	}
	defer func() {
		if err := db.Close(); err != nil {
			logger.Printf("Error closing database: %v", err)
		}
	}()

	// Initialize storage
	storageInstance, err := storage.New(&cfg.Database)
	if err != nil {
		return fmt.Errorf("failed to initialize storage: %w", err)
	}

	// Initialize API server
	server := api.NewServer(cfg, storageInstance, webAssets, logger)

	// Create app instance
	app := &App{
		logger: logger,
		config: cfg,
		db:     db,
		server: server,
	}

	// Start server
	return app.startServer()
}

func connectDB(cfg *config.DatabaseConfig) (*sql.DB, error) {
	dsn := fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=%s",
		cfg.Host, cfg.Port, cfg.Username, cfg.Password, cfg.Database, cfg.SSLMode)

	db, err := sql.Open("postgres", dsn)
	if err != nil {
		return nil, fmt.Errorf("failed to open database: %w", err)
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := db.PingContext(ctx); err != nil {
		return nil, fmt.Errorf("failed to ping database: %w", err)
	}

	return db, nil
}

func (app *App) startServer() error {
	// Setup CORS
	c := cors.New(cors.Options{
		AllowedOrigins:   []string{"*"}, // Configure appropriately for production
		AllowedMethods:   []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowedHeaders:   []string{"*"},
		AllowCredentials: true,
	})

	// Apply CORS middleware
	handler := c.Handler(app.server.Router())

	// Create HTTP server
	srv := &http.Server{
		Addr:         fmt.Sprintf(":%d", app.config.Server.Port),
		Handler:      handler,
		ReadTimeout:  30 * time.Second,
		WriteTimeout: 30 * time.Second,
		IdleTimeout:  120 * time.Second,
	}

	// Channel to listen for interrupt/terminate signals
	stop := make(chan os.Signal, 1)
	signal.Notify(stop, os.Interrupt, syscall.SIGTERM)

	// Start server in a goroutine
	go func() {
		app.logger.Printf("Starting server on port %d", app.config.Server.Port)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			app.logger.Fatalf("Server failed to start: %v", err)
		}
	}()

	// Wait for interrupt signal
	<-stop
	app.logger.Println("Shutting down server...")

	// Create a deadline for shutdown
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	// Shutdown server gracefully
	if err := srv.Shutdown(ctx); err != nil {
		return fmt.Errorf("server shutdown failed: %w", err)
	}

	app.logger.Println("Server stopped")
	return nil
}
