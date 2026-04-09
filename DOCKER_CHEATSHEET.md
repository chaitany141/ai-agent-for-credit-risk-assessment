# Docker Cheat Sheet for Credit Risk Assessment System

## 🚀 Quick Start

```bash
# One command to start everything
docker compose up -d

# Check if everything is running
docker compose ps

# View logs
docker compose logs -f
```

---

## 🔧 Most Used Commands

### Starting and Stopping

```bash
# Start all services in background
docker compose up -d

# Start and see logs
docker compose up

# Start specific service
docker compose up -d backend

# Stop all services
docker compose stop

# Stop and remove containers (data persists)
docker compose down

# Stop, remove containers AND volumes (careful - deletes data!)
docker compose down -v

# Restart all services
docker compose restart

# Restart specific service
docker compose restart backend
```

### Viewing Logs

```bash
# All services
docker compose logs

# Follow logs for one service
docker compose logs -f backend
docker compose logs -f frontend
docker compose logs -f mongodb

# Last 50 lines
docker compose logs --tail=50

# Specific time
docker compose logs --since 2024-01-15

# Specific service and time
docker compose logs -f backend --since 30m
```

### Accessing Containers

```bash
# Bash shell in backend
docker compose exec backend bash

# Shell in frontend
docker compose exec frontend sh

# Python shell in backend
docker compose exec backend python

# MongoDB shell
docker compose exec mongodb mongosh mongodb://admin:admin_password@localhost:27017/admin

# Run single command in container
docker compose exec backend python models/train_dummy.py

# Run with no TTY (better for scripts)
docker compose exec -T backend python models/train_dummy.py
```

### Building and Rebuilding

```bash
# Build all images
docker compose build

# Build without cache (fresh build)
docker compose build --no-cache

# Build specific service
docker compose build backend

# Build and start
docker compose up -d --build

# Build with specific target (multi-stage)
docker build --target backend-base -t my-backend:latest .
```

### Health and Status

```bash
# Show services and status
docker compose ps

# Detailed status
docker compose ps -a

# Inspect service
docker compose config

# Resource usage (real-time)
docker stats

# Resource usage for one container
docker stats credit_risk_backend

# Full environment info
docker compose debug
```

---

## 📁 File Operations

### Copy Files to/from Containers

```bash
# Copy file FROM container TO host
docker compose cp backend:/app/models/dummy_model.pkl ./backup/

# Copy file FROM host TO container
docker compose cp ./new_model.pkl backend:/app/models/

# Copy entire directory FROM container
docker compose cp backend:/app/uploads/ ./backup_uploads/

# Copy to running container
docker compose cp ./config.json backend:/app/config.json
```

### View File Within Container

```bash
# View file
docker compose exec backend cat /app/config.py

# List files
docker compose exec backend ls -la /app/

# Check file size
docker compose exec backend du -sh /app/models/
```

---

## 🗄️ Database Operations

### Access MongoDB

```bash
# Interactive MongoDB shell
docker compose exec mongodb mongosh

# Once in mongosh:
use loan_agent_db
db.users.find()
db.users.count()
db.loan_applications.find().limit(5)
show collections
```

### Backup and Restore

```bash
# Backup entire database
docker compose exec mongodb mongodump \
  --uri="mongodb://admin:admin_password@mongodb:27017" \
  --out=/backup_dir/

# Copy backup to host
docker compose cp mongodb:/backup_dir ./backup/

# Restore from backup
docker compose exec mongodb mongorestore \
  --uri="mongodb://admin:admin_password@mongodb:27017" \
  /backup_dir/
```

### Database Cleanup

```bash
# Drop entire database (careful!)
docker compose exec mongodb mongosh << EOF
use loan_agent_db
db.dropDatabase()
EOF

# Drop specific collection
docker compose exec mongodb mongosh << EOF
use loan_agent_db
db.users.deleteMany({})
EOF

# Show database size
docker compose exec mongodb mongosh << EOF
use loan_agent_db
db.stats()
EOF
```

---

## 🔍 Debugging

### Check Service Health

```bash
# Check if backend is responding
docker compose exec backend curl http://localhost:8000/health

# Check if frontend is up
docker compose exec frontend wget -q -O- http://localhost:3000

# Check if MongoDB is responsive
docker compose exec mongodb mongosh --eval "db.runCommand('ping')"

# Check if services can reach each other
docker compose exec backend ping mongodb
docker compose exec backend curl http://credit_bureau:8001/health
```

### View Port Mappings

```bash
# See which host ports are mapped
docker compose ps

# Or detailed:
docker port credit_risk_backend
docker port credit_risk_frontend
```

### Check Environment Variables

```bash
# Show environment in container
docker compose exec backend env

# Filter specific var
docker compose exec backend env | grep MONGO

# Inside container
echo $MONGO_URI
```

### Inspect Network

```bash
# List all networks
docker network ls

# Inspect specific network
docker network inspect credit_risk_network

# Test connectivity
docker compose exec backend nslookup mongodb
```

---

## 🧹 Cleanup Commands

### Remove Stopped Containers

```bash
docker container prune
```

### Remove Unused Images

```bash
docker image prune
docker image prune -a
```

### Remove Unused Volumes

```bash
docker volume prune
```

### Remove Everything (CAREFUL!)

```bash
# Remove all stopped containers, networks, dangling images
docker system prune

# Also remove unused images and volumes
docker system prune -a --volumes

# See what will be removed
docker system prune -a --volumes --dry-run
```

### List and Manage Volumes

```bash
# List all volumes
docker volume ls

# Inspect volume
docker volume inspect credit_risk_assessment_mongodb_data

# Remove specific volume
docker volume rm credit_risk_assessment_mongodb_data

# Show volume usage
docker system df
```

---

## 🐛 Common Issues & Quick Fixes

### Port Already in Use

```bash
# Find what's using port 8000
lsof -i :8000  # macOS/Linux

# Kill the process
kill -9 <PID>

# Or use different port in docker-compose.yml:
# ports:
#   - "8001:8000"  # Use 8001 instead
```

### Cannot Connect to MongoDB

```bash
# Check MongoDB is running
docker compose ps mongodb

# View MongoDB logs
docker compose logs mongodb

# Restart MongoDB
docker compose restart mongodb

# Test connection
docker compose exec backend mongosh mongodb://admin:admin_password@mongodb:27017
```

### Backend Can't Connect to MongoDB

```bash
# Check services are on same network
docker compose exec backend ping mongodb

# Check MONGO_URI environment variable
docker compose exec backend echo $MONGO_URI

# Should output: mongodb://admin:admin_password@mongodb:27017
```

### Frontend Can't Reach Backend

```bash
# In frontend container
docker compose exec frontend curl http://backend:8000/health

# Check backend is running
docker compose ps backend

# Check backend logs for errors
docker compose logs backend

# Check CORS settings in backend
docker compose exec backend grep -n "CORS" main.py
```

### Out of Disk Space

```bash
# Check disk usage
docker system df

# Clean up
docker system prune -a --volumes

# Specifically remove volumes
docker volume prune
```

### Models Not Loading

```bash
# Check if model file exists
docker compose exec backend ls -la /app/models/

# If missing, retrain
docker compose exec backend python models/train_dummy.py

# Check model size
docker compose exec backend du -sh /app/models/*
```

---

## 📊 Monitoring

### Watch Real-time Statistics

```bash
# All containers
docker stats

# Specific container
docker stats credit_risk_backend

# Update every 5 seconds
docker stats --no-stream=false --interval=5
```

### View Event Logs

```bash
# See all Docker events in real-time
docker events

# Filter by container
docker events --filter container=credit_risk_backend
```

### Performance Profiling

```bash
# Check CPU/Memory limits
docker inspect credit_risk_backend | grep -A 5 "Memory"

# View startup time
docker compose run --rm backend time python main:app
```

---

## 🔐 Security Quick Checks

```bash
# Scan image for vulnerabilities
docker scan credit_risk_backend

# Check exposed ports
docker port credit_risk_backend

# View running processes in container
docker compose exec backend ps aux

# Check file permissions
docker compose exec backend ls -la /app/

# View secrets/env vars (careful with sensitive data)
docker compose exec backend env
```

---

## 📝 Useful Scripts

### Show Everything

```bash
# One command to see system status
docker compose ps && echo && docker stats --no-stream

# Show all important ports and URLs
docker compose exec backend curl -s http://localhost:8000/health | jq .
```

### Backup Everything

```bash
#!/bin/bash
# Backup script
BACKUP_DIR="./backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p $BACKUP_DIR

echo "Backing up databases..."
docker compose cp mongodb:/data/db $BACKUP_DIR/

echo "Backing up models..."
docker compose cp backend:/app/models $BACKUP_DIR/

echo "Backing up uploads..."
docker compose cp backend:/app/uploads $BACKUP_DIR/

echo "✓ Backup complete: $BACKUP_DIR"
```

### Restart with Logs

```bash
#!/bin/bash
# Restart and watch logs
docker compose restart
sleep 2
docker compose logs -f
```

---

## 🎯 Common Task Workflows

### "I made changes and want to rebuild"

```bash
# Option 1: Quick restart (only if small changes)
docker compose restart backend

# Option 2: Rebuild from source
docker compose build backend
docker compose up -d backend

# Option 3: Full rebuild with no cache
docker compose build --no-cache backend
docker compose up -d backend
```

### "I want to completely reset the system"

```bash
# Stop everything and remove data
docker compose down -v

# Start fresh (will reinitialize everything)
docker compose up -d

# System will be like new!
```

### "I want to backup before making changes"

```bash
# Create timestamped backup
mkdir backup-$(date +%Y%m%d)

# Backup database
docker compose exec mongodb mongodump \
  --uri="mongodb://admin:admin_password@mongodb:27017" \
  --out=backup-$(date +%Y%m%d)/

# Backup models and uploads
docker compose cp backend:/app/models backup-$(date +%Y%m%d)/
docker compose cp backend:/app/uploads backup-$(date +%Y%m%d)/

# Safe to proceed with changes!
```

### "I want to see what's happening in detail"

```bash
# Terminal 1: Watch logs
docker compose logs -f

# Terminal 2: Monitor resources
docker stats

# Terminal 3: Work on code or test
# (changes auto-reload)
```

---

## 🚨 Emergency Commands

```bash
# Kill everything and start over
docker compose down -v && docker compose up -d

# Restart specific service
docker compose restart backend

# View error logs only
docker compose logs --tail=100 backend | grep -i error

# Force remove container
docker container rm --force credit_risk_backend

# Enter safe mode (no auto-restart)
docker compose up --no-restart frontend
```

---

## ✅ Health Check

```bash
# Is the system working?
echo "Frontend:" && curl -s http://localhost:5173 -o /dev/null && echo "✓" || echo "✗"
echo "Backend:" && curl -s http://localhost:8000/health | jq . && echo "✓" || echo "✗"
echo "MongoDB:" && docker compose exec -T mongodb mongosh --eval "db.runCommand('ping')" 2>/dev/null && echo "✓" || echo "✗"
echo "Credit Bureau:" && curl -s http://localhost:8001/health | jq . && echo "✓" || echo "✗"
```

---

**Pro Tip**: Bookmark this sheet for quick reference! 🚀
