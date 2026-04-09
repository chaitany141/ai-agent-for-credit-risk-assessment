#!/bin/bash

# ============================================================================
# Docker Compose Startup Script for Credit Risk Assessment System
# ============================================================================
# This script starts the entire system with Docker Compose
# Usage: ./start-docker.sh [options]
#
# Options:
#   build       - Rebuild all images before starting
#   down        - Completely stop and clean up all containers
#   logs        - Show logs from all services
#   logs-follow - Follow logs from all services in real-time
#   reset       - Stop, remove volumes, and start fresh
#   status      - Show status of all services
#   shell-backend  - Open shell in backend container
#   shell-frontend - Open shell in frontend container

# ============================================================================

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    print_success "Docker is installed"
    
    if ! command -v docker compose &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    print_success "Docker Compose is installed"
}

# Main startup function
start_system() {
    print_header "Starting AI Credit Risk Assessment System"
    
    check_docker
    
    echo ""
    print_header "Starting Services"
    
    docker compose up -d
    
    echo ""
    print_success "All services are starting..."
    echo ""
    
    sleep 3
    
    # Wait for services to be healthy
    print_header "Waiting for Services to be Ready"
    
    echo "Waiting for MongoDB..."
    for i in {1..30}; do
        if docker compose exec -T mongodb echo 'db.runCommand("ping").ok' | docker compose exec -T mongodb mongosh mongodb://admin:admin_password@localhost:27017/admin 2>/dev/null; then
            print_success "MongoDB is ready"
            break
        fi
        echo -n "."
        sleep 1
    done
    
    echo ""
    echo "Waiting for Backend API..."
    for i in {1..30}; do
        if docker compose exec -T backend curl -s http://localhost:8000/health > /dev/null 2>&1; then
            print_success "Backend API is ready"
            break
        fi
        echo -n "."
        sleep 1
    done
    
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}✓ System is Ready!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "Access Points:"
    echo -e "  ${BLUE}Frontend:${NC}         http://localhost:5173"
    echo -e "  ${BLUE}Backend API:${NC}      http://localhost:8000"
    echo -e "  ${BLUE}API Docs:${NC}         http://localhost:8000/docs"
    echo -e "  ${BLUE}API Redoc:${NC}        http://localhost:8000/redoc"
    echo -e "  ${BLUE}Credit Bureau:${NC}    http://localhost:8001"
    echo -e "  ${BLUE}Jupyter Notebook:${NC} http://localhost:8888"
    echo -e "  ${BLUE}MongoDB:${NC}          mongodb://localhost:27017"
    echo ""
    echo "Credentials:"
    echo -e "  ${BLUE}MongoDB User:${NC}     admin"
    echo -e "  ${BLUE}MongoDB Password:${NC} admin_password"
    echo ""
    echo "Useful Commands:"
    echo "  View logs:           docker compose logs -f [service_name]"
    echo "  Stop all services:   docker compose down"
    echo "  Stop and remove data: docker compose down -v"
    echo "  Rebuild images:      docker compose build"
    echo "  Shell in backend:    docker compose exec backend bash"
    echo "  Shell in frontend:   docker compose exec frontend sh"
    echo ""
}

# Rebuild and start
build_and_start() {
    print_header "Building Images and Starting System"
    check_docker
    
    docker compose build
    start_system
}

# Stop system
stop_system() {
    print_header "Stopping All Services"
    docker compose down
    print_success "All services stopped"
}

# Show logs
show_logs() {
    print_header "Showing Logs (Press Ctrl+C to exit)"
    docker compose logs -f "$1"
}

# Show status
show_status() {
    print_header "Services Status"
    docker compose ps
}

# Reset system
reset_system() {
    print_warning "This will remove all containers and volumes (including data)"
    read -p "Are you sure? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_header "Resetting System"
        docker compose down -v
        print_success "System reset complete"
        start_system
    else
        print_warning "Reset cancelled"
    fi
}

# Shell access
shell_backend() {
    print_header "Opening Backend Shell"
    docker compose exec backend bash
}

shell_frontend() {
    print_header "Opening Frontend Shell"
    docker compose exec frontend sh
}

# Handle command line arguments
case "$1" in
    build)
        build_and_start
        ;;
    down)
        stop_system
        ;;
    logs)
        show_logs "$2"
        ;;
    logs-follow)
        show_logs "$2"
        ;;
    status)
        show_status
        ;;
    reset)
        reset_system
        ;;
    shell-backend)
        shell_backend
        ;;
    shell-frontend)
        shell_frontend
        ;;
    *)
        start_system
        ;;
esac
