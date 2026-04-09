# Docker Setup and Deployment Guide
# AI Credit Risk Assessment System

## 📋 Table of Contents
- Quick Start
- System Architecture
- Docker Components
- Volume Management
- Common Commands
- Troubleshooting
- Production Deployment

---

## 🚀 Quick Start

### Prerequisites
- [Docker Desktop](https://www.docker.com/products/docker-desktop) installed and running
- Docker Compose v2.0 or higher
- At least 4GB free RAM
- At least 10GB free disk space

### Start Everything in One Command

```bash
# On Linux/macOS - make script executable
chmod +x start-docker.sh

# Start all services
./start-docker.sh

# On Windows (PowerShell or Git Bash)
docker compose up -d
```

The system will be ready in 30-60 seconds. Access points:
- 🎨 **Frontend**: http://localhost:5173
- 🔌 **Backend API**: http://localhost:8000
- 📚 **API Documentation**: http://localhost:8000/docs
- 🏦 **Credit Bureau Mock**: http://localhost:8001
- 📔 **Jupyter Notebook**: http://localhost:8888

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Network                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Frontend    │  │   Backend    │  │   Credit     │      │
│  │  React/Vite │  │   FastAPI    │  │   Bureau     │      │
│  │  :5173       │  │   :8000      │  │   :8001      │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                          │                                  │
│  ┌────────────────────────────────────────────────────┐    │
│  │              MongoDB Container                     │    │
│  │              Port: 27017                           │    │
│  └────────────────────────────────────────────────────┘    │
│                                                             │
│  ┌──────────────────────────────────────────────────┐      │
│  │  Jupyter (Optional - for ML exploration)        │      │
│  │  http://localhost:8888                          │      │
│  └──────────────────────────────────────────────────┘      │
│                                                             │
└─────────────────────────────────────────────────────────────┘

All services communicate via internal Docker network
```

---

## 📦 Docker Components

### 1. **Dockerfile** (Multi-stage)
- **Backend Stage**: Python 3.11 slim + FastAPI + all dependencies
- **Frontend Stage**: Node 20 Alpine + React/Vite dev server
- **Credit Bureau Stage**: FastAPI mock service
- Multi-stage build optimizes image sizes

### 2. **docker-compose.yml** (Orchestration)
- **Services**: 5 containers (MongoDB, Backend, Frontend, Credit Bureau, Jupyter)
- **Networks**: Single internal bridge network
- **Volumes**: Persistent storage for models, uploads, database
- **Health Checks**: Automated service readiness monitoring
- **Environment Variables**: Pre-configured for inter-service communication

### 3. **Services Breakdown**

#### MongoDB (Port 27017)
```yaml
Container: credit_risk_mongodb
Image: mongo:7.0-alpine
Database: loan_agent_db
Default User: admin / admin_password
```

**Auto-initialized with:**
- Collections: users, loan_applications, agent_decisions, kyc_documents, credit_checks
- Validation schemas for data integrity
- Indexes for query performance
- TTL indexes (optional) for automatic data cleanup

#### Backend (Port 8000)
```yaml
Container: credit_risk_backend
Build: Multi-stage Dockerfile
Framework: FastAPI
Dependencies: All Python requirements.txt packages pre-installed
Features:
  - Auto-trains ML model on startup
  - Hot-reload enabled for development
  - Health checks every 30s
  - Connects to MongoDB and Credit Bureau internally
```

#### Frontend (Port 5173)
```yaml
Container: credit_risk_frontend
Build: Node 20 Alpine
Framework: React/Vite
Features:
  - Hot-reload for development
  - Connects to Backend at http://backend:8000 (internal)
  - Exposed at http://localhost:5173 (external)
```

#### Credit Bureau Mock (Port 8001)
```yaml
Container: credit_risk_bureau
Framework: FastAPI
Purpose: Simulates external credit bureau service
Endpoints:
  - GET /health
  - POST /api/v1/credit-check
```

#### Jupyter (Port 8888)
```yaml
Container: Optional for ML development
Features:
  - Full data science stack
  - Access to models/ and services/
  - No authentication required (for local development only)
```

---

## 💾 Volume Management

### What Gets Persisted?

| Volume | Mount Point | Purpose |
|--------|-------------|---------|
| `mongodb_data` | `/data/db` | MongoDB database persistence |
| `ml_models` | `/app/models` | ML model files (pickle) |
| `uploads_data` | `/app/uploads` | User documents, KYC files |
| `pip_cache` | `/.cache/pip` | Python package cache |

### Copy Files to/from Container

```bash
# Copy model from container to host
docker compose cp backend:/app/models/dummy_model.pkl ./models/

# Copy uploads from container
docker compose cp backend:/app/uploads/ ./local_uploads/

# Copy into container
docker compose cp ./my_model.pkl backend:/app/models/
```

### View Volume Usage

```bash
# List all volumes
docker volume ls

# Inspect specific volume
docker volume inspect ai-agent-for-credit-risk-assessment_ml_models

# Show disk usage
docker system df
```

---

## 🎮 Common Commands

### Start/Stop Services

```bash
# Start all services in background
docker compose up -d

# Start and see logs
docker compose up

# Stop all services
docker compose down

# Stop and remove volumes (WARNING: deletes data!)
docker compose down -v

# Rebuild and restart
docker compose restart
```

### View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f backend
docker compose logs -f frontend
docker compose logs -f mongodb

# Last 50 lines
docker compose logs --tail=50

# Since specific time
docker compose logs --since 2024-01-15
```

### Access Containers

```bash
# Backend bash shell
docker compose exec backend bash

# Frontend shell
docker compose exec frontend sh

# MongoDB shell
docker compose exec mongodb mongosh mongodb://admin:admin_password@localhost:27017/admin

# Run commands in container
docker compose exec backend python models/train_dummy.py
docker compose exec frontend npm run build
```

### Check Service Status

```bash
# Show all services and status
docker compose ps

# Detailed information
docker compose ps -a

# Show resource usage
docker stats
```

### Rebuild Images

```bash
# Build without cache (clean build)
docker compose build --no-cache

# Build specific service
docker compose build backend

# Build and start
docker compose up -d --build
```

---

## 🔧 Troubleshooting

### Issue: Port Already in Use

```bash
# Find what's using port 8000
lsof -i :8000  # macOS/Linux
netstat -ano | findstr :8000  # Windows

# Kill process
kill -9 <PID>  # macOS/Linux
taskkill /PID <PID> /F  # Windows

# Or use different ports in docker-compose.yml
```

### Issue: MongoDB Connection Failed

```bash
# Check MongoDB logs
docker compose logs mongodb

# Verify MongoDB is running
docker compose ps mongodb

# Test connection
docker compose exec backend mongosh mongodb://admin:admin_password@mongodb:27017

# Restart MongoDB
docker compose restart mongodb
```

### Issue: Backend Can't Connect to MongoDB

- **Cause**: Services not on same network
- **Solution**: Ensure `docker-compose.yml` uses service name `mongodb` not `localhost`
- **Check**: `docker compose exec backend ping mongodb`

### Issue: Frontend Can't Reach Backend

```bash
# Verify backend is running
docker compose ps backend

# Check backend logs
docker compose logs backend

# Test connection from frontend
docker compose exec frontend curl http://backend:8000/health

# Frontend .env should have: VITE_API_URL=http://localhost:8000
```

### Issue: Out of Space / High Disk Usage

```bash
# Clean up unused images
docker image prune -a

# Clean up volumes
docker volume prune

# Clean up all unused resources
docker system prune -a --volumes
```

### Issue: Models Directory Not Syncing

```bash
# Manually train model
docker compose exec backend python models/train_dummy.py

# Copy trained model
docker compose cp backend:/app/models/ ./models/

# Check volume
docker volume inspect <volume_name>
```

### View Real-time Metrics

```bash
# CPU, Memory, Network I/O
docker stats

# Specific container
docker stats credit_risk_backend
```

---

## 📊 Database Management

### Access MongoDB

```bash
# Interactive MongoDB shell
docker compose exec mongodb mongosh

# Commands
use loan_agent_db
db.users.find()
db.users.count()
db.loan_applications.find()
```

### Backup Database

```bash
# Backup to file
docker compose exec mongodb mongodump --uri="mongodb://admin:admin_password@localhost:27017" --out=/backup

# Copy backup out
docker compose cp mongodb:/backup ./backup

# Restore from backup
docker compose exec mongodb mongorestore --uri="mongodb://admin:admin_password@localhost:27017" /backup
```

### Reset Database

```bash
# Drop entire database
docker compose exec mongodb mongosh << EOF
use loan_agent_db
db.dropDatabase()
EOF

# This will recreate schema on next application start
```

---

## 📈 Development Workflows

### Watch Logs While Developing

```bash
# Terminal 1: Watch all logs
docker compose logs -f

# Terminal 2: Work on code (changes auto-reload)
# Frontend changes auto-reflect at http://localhost:5173
# Backend changes need container restart
```

### Train New ML Model

```bash
# Inside container
docker compose exec backend python models/train_dummy.py

# Or rebuild backend
docker compose build backend
```

### Debug with Print Statements

```bash
# Python
print("Debug message")
docker compose logs -f backend | grep "Debug"

# JavaScript/Vite
console.log("Debug")
# Check browser console or:
docker compose logs -f frontend
```

### Performance Testing

```bash
# Monitor resources during load
docker stats credit_risk_backend

# Load test the API
docker compose exec backend python -m pytest tests/
```

---

## 🚀 Production Deployment

### Environment Variables for Production

Create `.env.prod`:
```bash
# Use strong credentials
MONGO_URI=mongodb://produser:STRONG_PASSWORD@mongodb:27017
MONGODB_DB_NAME=loan_agent_db

# Security
OPENAI_API_KEY=sk-xxxxxxxxxxxxx

# Frontend
FRONTEND_ORIGIN=https://yourdomain.com

# Thresholds
THRESHOLD_APPROVE=0.35
THRESHOLD_REJECT=0.75

# File uploads limit
MAX_FILE_SIZE=10485760  # 10MB
```

### Production Checklist

```
[ ] Use production MongoDB (not in Docker)
[ ] Set strong passwords for MongoDB
[ ] Use SSL/TLS for all connections
[ ] Configure CORS with specific domains
[ ] Set up monitoring/alerting
[ ] Enable backup schedules
[ ] Use health checks in production
[ ] Rotate logs
[ ] Set resource limits
[ ] Use reverse proxy (nginx)
[ ] Implement API rate limiting
[ ] Add authentication to Jupyter (disable or secure)
[ ] Update FRONTEND_ORIGIN to production domain
[ ] Use environment-specific configuration
```

### Scale for Production

```bash
# Increase replicas
docker compose up -d --scale backend=3

# Use Docker Swarm or Kubernetes for orchestration
# Consider cloud deployments (AWS ECS, Azure Container Instances, etc.)
```

---

## 🔐 Security Notes

⚠️ **Development Only**: Current setup is for LOCAL DEVELOPMENT
- Default MongoDB credentials exposed in compose file
- No authentication on Jupyter
- CORS allows all origins
- No HTTPS/SSL

### For Production:
1. Use external managed MongoDB (AWS DocumentDB, MongoDB Atlas)
2. Use environment files for secrets (never commit .env)
3. Restrict CORS origins
4. Enable SSL/TLS
5. Set up firewall rules
6. Use container registry with access control
7. Scan images for vulnerabilities
8. Implement API authentication (OAuth, JWT)
9. Enable audit logging
10. Regular security updates

---

## 📞 Support & Help

### Check Everything is Running

```bash
curl http://localhost:8000/health
curl http://localhost:5173
curl http://localhost:8001/health
```

### Useful Files
- `docker-compose.yml` - Service definitions
- `Dockerfile` - Container build instructions
- `scripts/init-mongodb.js` - Database initialization
- `.env.docker` - Environment variables for Docker

### Need to Debug?

```bash
# Complete system status
docker compose ps -a
docker compose logs

# Rebuild everything fresh
docker compose down -v
docker compose up -d --build

# Check Docker daemon
docker info
```

---

## ✨ Next Steps

1. **Access the Frontend**: http://localhost:5173
2. **View API Docs**: http://localhost:8000/docs
3. **Train Models**: `docker compose exec backend python models/train_dummy.py`
4. **Explore Data**: `docker compose exec mongodb mongosh`
5. **Deploy to Production**: See Production Deployment section

---

**Happy containerizing! 🐳**
