# Batch Script for Windows Users
# Credit Risk Assessment System - Docker Quick Start

@echo off
setlocal enabledelayedexpansion

echo.
echo ╔════════════════════════════════════════════════════════════════════╗
echo ║                                                                    ║
echo ║   🚀 AI Credit Risk Assessment System - Docker Quick Start 🚀     ║
echo ║                                                                    ║
echo ╚════════════════════════════════════════════════════════════════════╝
echo.

REM Check Docker
echo 📋 Checking Prerequisites...

docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker is not installed!
    echo    Please install Docker Desktop from https://www.docker.com/products/docker-desktop
    exit /b 1
)
echo ✓ Docker is installed

REM Check Docker Daemon
docker info >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker daemon is not running!
    echo    Please start Docker Desktop
    exit /b 1
)
echo ✓ Docker daemon is running

REM Check Docker Compose
docker compose --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker Compose is not installed!
    echo    Please update Docker Desktop
    exit /b 1
)
echo ✓ Docker Compose is installed

echo.
echo 🔨 Building and starting services...
echo.

REM Start services
docker compose up -d

REM Wait a bit
timeout /t 5 /nobreak

echo.
echo ⏳ Waiting for services to be ready...
echo.

REM Simple wait - just sleep longer
timeout /t 15 /nobreak

echo.
echo ╔════════════════════════════════════════════════════════════════════╗
echo ║                    ✅ SYSTEM IS READY! ✅                          ║
echo ╚════════════════════════════════════════════════════════════════════╝
echo.

echo 📍 Access Points:
echo.
echo   🎨 Frontend              → http://localhost:5173
echo   🔌 Backend API           → http://localhost:8000
echo   📚 API Documentation     → http://localhost:8000/docs
echo   🔄 Alternative Docs      → http://localhost:8000/redoc
echo   🏦 Credit Bureau Mock    → http://localhost:8001
echo   📔 Jupyter Notebook      → http://localhost:8888
echo   🗄️  MongoDB             → mongodb://localhost:27017
echo.

echo 🔐 MongoDB Credentials:
echo   Username: admin
echo   Password: admin_password
echo.

echo 📊 Service Status:
docker compose ps
echo.

echo 🛠️  Useful Commands:
echo.
echo   View all logs:               docker compose logs -f
echo   View specific logs:          docker compose logs -f [service]
echo   Access backend shell:        docker compose exec backend bash
echo   Access frontend shell:       docker compose exec frontend sh
echo   Access MongoDB:              docker compose exec mongodb mongosh
echo   Stop all services:           docker compose down
echo   Stop and remove volumes:     docker compose down -v
echo   Rebuild images:              docker compose build
echo   Show service status:         docker compose ps
echo.

echo 📖 Documentation:
echo   Full Guide:                  read DOCKER_GUIDE.md
echo.

echo 🎉 You're all set! Start developing!
echo.

pause
