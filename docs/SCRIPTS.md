# Siros Development Scripts Documentation

## Overview

The `/scripts` directory contains build, development, and testing scripts for the Siros platform. These scripts are available in both bash (Linux/macOS) and PowerShell (Windows) versions for cross-platform development.

## Available Scripts

### Cross-Platform Script Matrix

| Function | Bash (Linux/macOS) | PowerShell (Windows) | Description |
|----------|--------------------|--------------------|-------------|
| Development | `dev.sh` | `dev.ps1` | Start development environment |
| Full Build | `build_all.sh` | `build_all.ps1` | Production build with embedded frontend |
| Backend Only | `build.sh` | *(use build_all.ps1)* | Backend build with placeholder frontend |
| Testing | `test.sh` | `test.ps1` | Comprehensive test runner |
| Database Init | `init.sql` | `init.sql` | PostgreSQL initialization |

---

## Scripts Reference

### 🚀 Development Scripts

#### `dev.sh` / `dev.ps1` - Development Environment

**Purpose**: Starts both backend and frontend in development mode with hot reload.

**Usage**:

```bash
# Linux/macOS
./scripts/dev.sh

# Windows
.\scripts\dev.ps1
```

**What it does**:

- Starts backend server on port 8080 (Go with hot reload)
- Starts frontend dev server on port 5173 (Vite with hot reload)
- Automatically installs npm dependencies if needed
- Handles cleanup on Ctrl+C

**Endpoints**:

- Frontend (dev): <http://localhost:5173>
- Backend API: <http://localhost:8080/api/v1>
- API Health: <http://localhost:8080/api/v1/health>

**Requirements**:

- Go 1.21+
- Node.js 18+
- PostgreSQL with pgvector extension

---

### 🔨 Build Scripts

#### `build_all.sh` / `build_all.ps1` - Full Production Build

**Purpose**: Builds the complete Siros platform with embedded frontend.

**Usage**:

```bash
# Linux/macOS
./scripts/build_all.sh

# Windows
.\scripts\build_all.ps1
```

**What it does**:

1. Builds React frontend (`npm run build`)
2. Copies frontend build to `backend/static/`
3. Embeds frontend in Go binary using `embed.FS`
4. Creates production binary `siros-server` (or `siros-server.exe` on Windows)

**Output**: Single binary with embedded frontend at `backend/siros-server`

**Note**: This is the recommended build method for production deployments.

---

#### `build.sh` - Backend Only Build (Bash Only)

**Purpose**: Builds backend only with placeholder frontend.

**Usage**:

```bash
./scripts/build.sh
```

**What it does**:

- Creates minimal placeholder frontend in `backend/static/`
- Builds backend binary with embedded placeholder
- Suitable for API-only deployments or testing

---

### 🧪 Testing Scripts

#### `test.sh` / `test.ps1` - Comprehensive Test Runner

**Purpose**: Runs unit tests with various options and coverage reporting.

**Usage**:

```bash
# Linux/macOS
./scripts/test.sh [options]

# Windows
.\scripts\test.ps1 [options]
```

**Options**:

- `--suite <suite>` / `-TestSuite <suite>`: Run specific test suite
- `--coverage` / `-Coverage`: Generate coverage report
- `--verbose` / `-Verbose`: Show verbose output
- `--help` / `-Help`: Show help message

**Available Test Suites**:

- `all`: Run all tests (default)
- `models`: Business logic and data structures
- `services`: Business logic orchestration
- `controllers`: HTTP handlers and API endpoints
- `repositories`: Data access layer
- `integration`: End-to-end tests (coming soon)

**Examples**:

```bash
# Run all tests
./scripts/test.sh

# Run specific test suite
./scripts/test.sh --suite models

# Run with coverage report
./scripts/test.sh --coverage

# Windows equivalents
.\scripts\test.ps1 -TestSuite models -Verbose
.\scripts\test.ps1 -Coverage
```

---

### 🗄️ Database Scripts

#### `init.sql` - Database Initialization

**Purpose**: Initializes PostgreSQL database with required extensions.

**Usage**:

```sql
psql -d siros -f scripts/init.sql
```

**What it does**:

- Enables pgvector extension for vector operations
- Sets up database for vector similarity search
- Provides placeholder for custom schema insertions

---

## Development Workflow

### Daily Development

```bash
# 1. Start development environment
./scripts/dev.sh                    # or .\scripts\dev.ps1

# 2. Run tests during development
./scripts/test.sh --suite models    # or .\scripts\test.ps1 -TestSuite models

# 3. Run full test suite before commit
./scripts/test.sh --coverage        # or .\scripts\test.ps1 -Coverage
```

### Production Deployment

```bash
# 1. Build production binary
./scripts/build_all.sh              # or .\scripts\build_all.ps1

# 2. Initialize database (if needed)
psql -d siros -f scripts/init.sql

# 3. Run server
cd backend && ./siros-server        # or .\siros-server.exe
```

---

## Environment Variables

The scripts support these environment variables:

### Development (`dev.sh` / `dev.ps1`)

- `SIROS_BACKEND_PORT` (default: 8080)
- `SIROS_FRONTEND_PORT` (default: 5173)
- `SIROS_DB_HOST` (default: localhost)
- `SIROS_DB_PORT` (default: 5432)

### Build (`build_all.sh` / `build_all.ps1`)

- `SIROS_BUILD_OUTPUT` (default: backend/siros-server)
- `SIROS_FRONTEND_DIST` (default: frontend/dist)
- `SIROS_STATIC_DIR` (default: backend/static)

---

## Test Coverage Results

Current test coverage for MVC layers:

```txt
✅ Models:      50.5% coverage (8 test functions)
✅ Services:    50.6% coverage (4 test functions)
✅ Controllers: 47.8% coverage (6 test functions)
✅ Config:      62.5% coverage
⚪ Repositories: 0.0% coverage (tests needed)
⚪ Providers:    0.0% coverage (tests needed)
```

---

## Troubleshooting

### Common Issues

#### "Command not found: npm"

**Solution**: Install Node.js 18+ from <https://nodejs.org/>

#### "No such file or directory: frontend/dist"

**Solution**: Run `npm run build` in the frontend directory first

#### "Permission denied: ./scripts/dev.sh"

**Solution**: Make script executable: `chmod +x ./scripts/dev.sh`

#### "pgvector extension not found"

**Solution**: Install pgvector extension:

```bash
# Ubuntu/Debian
sudo apt install postgresql-15-pgvector

# macOS
brew install pgvector

# Windows
# Use PostgreSQL installer with pgvector support
```

#### Port already in use (8080 or 5173)

**Solution**: Kill existing processes:

```bash
# Linux/macOS
lsof -i :8080
lsof -i :5173
kill -9 <PID>

# Windows
netstat -ano | findstr :8080
taskkill /PID <PID> /F
```

#### PowerShell execution policy error (Windows)

**Solution**: Allow script execution:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## Next Steps

### Planned Improvements

1. **Integration Tests**: Add end-to-end testing with real database
2. **Performance Tests**: Load testing for vector operations
3. **Docker Scripts**: Containerized development and deployment
4. **CI/CD Integration**: GitHub Actions compatible scripts
5. **Database Migrations**: Automated schema migration scripts
6. **Monitoring Scripts**: Health check and monitoring utilities

### Contributing

When adding new scripts:

1. Create both bash and PowerShell versions
2. Add comprehensive error handling
3. Include help documentation
4. Update this documentation
5. Test on both platforms

---

## Script Implementation Status

### ✅ Completed

- Development environment scripts
- Production build scripts
- Comprehensive test runners
- Cross-platform compatibility
- Error handling and help documentation

### 🔄 In Progress

- Coverage reporting improvements
- Integration test framework

### ⏳ Planned

- Docker containerization scripts
- Database migration scripts
- Performance testing scripts
- Monitoring and health check scripts
