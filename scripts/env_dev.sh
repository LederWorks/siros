#!/bin/bash

echo "🔧 Starting Siros development environment..."

# Function to kill background processes on exit
cleanup() {
    echo ""
    echo "🛑 Stopping development servers..."
    kill $BACKEND_PID $FRONTEND_PID 2>/dev/null || true
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Start backend server
echo "🚀 Starting backend server on :8080..."
cd backend
go run ./cmd/siros-server &
BACKEND_PID=$!

# Wait a moment for backend to start
sleep 2

# Start frontend dev server
echo "🌐 Starting frontend dev server on :5173..."
cd ../frontend

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "📥 Installing frontend dependencies..."
    npm install
fi

npm run dev &
FRONTEND_PID=$!

echo ""
echo "✅ Development environment started!"
echo ""
echo "🌐 Frontend (dev): http://localhost:5173"
echo "🔧 Backend API:    http://localhost:8080/api/v1"
echo "📊 API Health:     http://localhost:8080/api/v1/health"
echo ""
echo "Press Ctrl+C to stop both servers"

# Wait for either process to exit
wait