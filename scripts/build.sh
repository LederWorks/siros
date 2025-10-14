#!/bin/bash

# Ensure web/dist directory exists with at least one file for embed
mkdir -p web/dist
if [ ! -f web/dist/index.html ]; then
    echo "Creating placeholder web assets..."
    cat > web/dist/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Siros - Multi-Cloud Resource Platform</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body { 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; 
            margin: 0; 
            padding: 20px; 
            background: #f5f5f5; 
        }
        .container { 
            max-width: 1200px; 
            margin: 0 auto; 
            background: white; 
            border-radius: 8px; 
            padding: 30px; 
            box-shadow: 0 2px 10px rgba(0,0,0,0.1); 
        }
        .header { 
            text-align: center; 
            margin-bottom: 40px; 
            border-bottom: 2px solid #007cba; 
            padding-bottom: 20px; 
        }
        .api-link { 
            display: inline-block; 
            margin: 10px; 
            padding: 12px 24px; 
            background: #007cba; 
            color: white; 
            text-decoration: none; 
            border-radius: 6px; 
            transition: background 0.3s; 
        }
        .api-link:hover { 
            background: #005a8b; 
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🌐 Siros</h1>
            <p>Multi-Cloud Resource Platform</p>
        </div>
        
        <h2>🔗 API Endpoints</h2>
        <div style="text-align: center; margin: 20px 0;">
            <a href="/api/v1/health" class="api-link">🔍 Health Check</a>
            <a href="/api/v1/resources" class="api-link">📦 Resources</a>
            <a href="/api/v1/schemas" class="api-link">📋 Schemas</a>
        </div>
        
        <h2>✨ Features</h2>
        <ul>
            <li>✅ HTTP API for resource management</li>
            <li>✅ PostgreSQL with pgvector for semantic search</li>
            <li>✅ Multi-cloud provider support (AWS, Azure, GCP)</li>
            <li>✅ Terraform integration</li>
            <li>✅ MCP (Model Context Protocol) API</li>
            <li>🔄 Blockchain change tracking</li>
            <li>🔄 React frontend (embedded in binary)</li>
        </ul>
    </div>
</body>
</html>
EOF
fi

# Build the binary
mkdir -p build
echo "Building Siros..."
CGO_ENABLED=1 go build -o build/siros ./cmd/siros

if [ $? -eq 0 ]; then
    echo "✅ Build successful! Binary created at build/siros"
    echo "🚀 Run with: ./build/siros"
else
    echo "❌ Build failed"
    exit 1
fi