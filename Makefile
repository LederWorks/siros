.PHONY: build clean test run docker help install-deps

# Build configuration
APP_NAME := siros
BUILD_DIR := build
BINARY := $(BUILD_DIR)/$(APP_NAME)
VERSION := $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
BUILD_TIME := $(shell date -u +%Y-%m-%dT%H:%M:%SZ)
LDFLAGS := -ldflags "-X main.version=$(VERSION) -X main.buildTime=$(BUILD_TIME)"

# Default target
all: build

# Help target
help: ## Show this help message
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Install dependencies
install-deps: ## Install Go dependencies
	go mod tidy
	go mod download

# Build the application
build: install-deps ## Build the application
	@mkdir -p $(BUILD_DIR)
	CGO_ENABLED=1 go build $(LDFLAGS) -o $(BINARY) ./cmd/siros

# Build for production with optimizations
build-prod: install-deps ## Build optimized production binary
	@mkdir -p $(BUILD_DIR)
	CGO_ENABLED=1 go build $(LDFLAGS) -trimpath -o $(BINARY) ./cmd/siros
	upx --best $(BINARY) 2>/dev/null || true

# Run the application
run: build ## Build and run the application
	$(BINARY)

# Run in development mode
dev: ## Run with live reload (requires air)
	air -c .air.toml

# Test the application
test: ## Run tests
	go test -v ./...

# Test with coverage
test-coverage: ## Run tests with coverage
	go test -v -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html

# Lint the code
lint: ## Run linter
	golangci-lint run

# Format the code
fmt: ## Format code
	go fmt ./...
	goimports -w .

# Clean build artifacts
clean: ## Clean build artifacts
	rm -rf $(BUILD_DIR)
	rm -f coverage.out coverage.html

# Generate mocks
generate: ## Generate code (mocks, etc.)
	go generate ./...

# Run security scan
security: ## Run security scan
	gosec ./...

# Docker targets
docker-build: ## Build Docker image
	docker build -t $(APP_NAME):$(VERSION) .

docker-run: docker-build ## Build and run Docker container
	docker run -p 8080:8080 $(APP_NAME):$(VERSION)

# Database targets
db-migrate: ## Run database migrations
	$(BINARY) -migrate

db-reset: ## Reset database
	$(BINARY) -reset-db

# Development targets
init-db: ## Initialize development database (requires Docker)
	docker run --name siros-postgres -e POSTGRES_PASSWORD=siros -e POSTGRES_USER=siros -e POSTGRES_DB=siros -p 5432:5432 -d postgres:15-alpine
	sleep 5
	docker exec siros-postgres psql -U siros -d siros -c "CREATE EXTENSION IF NOT EXISTS vector;"

stop-db: ## Stop development database
	docker stop siros-postgres || true
	docker rm siros-postgres || true

# Frontend targets
web-build: ## Build React frontend
	cd web && npm install && npm run build

web-dev: ## Run React frontend in development mode
	cd web && npm start

# Release targets
release: clean test lint build-prod ## Prepare release build

# Install development tools
install-tools: ## Install development tools
	go install github.com/cosmtrek/air@latest
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	go install golang.org/x/tools/cmd/goimports@latest
	go install github.com/securecodewarrior/gosec/v2/cmd/gosec@latest
