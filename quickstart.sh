#!/bin/bash

# ============================================================================
# Quick Start - One Command to Rule Them All
# ============================================================================
# This script handles prerequisites and starts the entire system
# 
# Usage: bash quickstart.sh
# OR: chmod +x quickstart.sh && ./quickstart.sh
# ============================================================================

set -e

echo ""
echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║                                                                    ║"
echo "║   🚀 AI Credit Risk Assessment System - Docker Quick Start 🚀     ║"
echo "║                                                                    ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo ""

# Check prerequisites
echo "📋 Checking Prerequisites..."

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed!"
    echo "   Please install Docker Desktop from: https://www.docker.com/products/docker-desktop"
    exit 1
fi
echo "✓ Docker is installed"

# Check Docker Daemon
if ! docker info &> /dev/null; then
    echo "❌ Docker daemon is not running!"
    echo "   Please start Docker Desktop"
    exit 1
fi
echo "✓ Docker daemon is running"

# Check Docker Compose
if ! command -v docker compose &> /dev/null; then
    echo "❌ Docker Compose is not installed!"
    echo "   Please update Docker Desktop"
    exit 1
fi
echo "✓ Docker Compose is installed"

echo ""
echo "🔨 Building and starting services..."
echo ""

# Start services
docker compose up -d

# Wait a bit for services to initialize
sleep 5

echo ""
echo "⏳ Waiting for services to be ready..."
echo ""

# Counter for timeout
counter=0
max_tries=60

# Wait for backend
echo -n "Waiting for Backend API... "
while [ $counter -lt $max_tries ]; do
    if curl -s http://localhost:8000/health > /dev/null 2>&1; then
        echo "✓"
        break
    fi
    echo -n "."
    sleep 1
    counter=$((counter + 1))
done

if [ $counter -eq $max_tries ]; then
    echo "❌"
    echo "Backend API did not start. Check logs:"
    echo "  docker compose logs backend"
else
    echo ""
fi

# Wait for frontend
counter=0
echo -n "Waiting for Frontend... "
while [ $counter -lt $max_tries ]; do
    if curl -s http://localhost:5173 > /dev/null 2>&1; then
        echo "✓"
        break
    fi
    echo -n "."
    sleep 1
    counter=$((counter + 1))
done

if [ $counter -eq $max_tries ]; then
    echo "❌"
    echo "Frontend did not start. Check logs:"
    echo "  docker compose logs frontend"
else
    echo ""
fi

# Show status
echo ""
echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║                    ✅ SYSTEM IS READY! ✅                          ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo ""

echo "📍 Access Points:"
echo ""
echo "  🎨 Frontend              → http://localhost:5173"
echo "  🔌 Backend API           → http://localhost:8000"
echo "  📚 API Documentation     → http://localhost:8000/docs"
echo "  🔄 Alternative Docs      → http://localhost:8000/redoc"
echo "  🏦 Credit Bureau Mock    → http://localhost:8001"
echo "  📔 Jupyter Notebook      → http://localhost:8888"
echo "  🗄️  MongoDB             → mongodb://localhost:27017"
echo ""

echo "🔐 MongoDB Credentials:"
echo "  Username: admin"
echo "  Password: admin_password"
echo ""

echo "📊 Service Status:"
docker compose ps
echo ""

echo "🛠️  Useful Commands:"
echo ""
echo "  View all logs:               docker compose logs -f"
echo "  View specific logs:          docker compose logs -f [service]"
echo "  Access backend shell:        docker compose exec backend bash"
echo "  Access frontend shell:       docker compose exec frontend sh"
echo "  Access MongoDB:              docker compose exec mongodb mongosh"
echo "  Stop all services:           docker compose down"
echo "  Stop and remove volumes:     docker compose down -v"
echo "  Rebuild images:              docker compose build"
echo "  Show service status:         docker compose ps"
echo ""

echo "📖 Documentation:"
echo "  Full Guide:                  read DOCKER_GUIDE.md"
echo ""

echo "🎉 You're all set! Start developing!"
echo ""
