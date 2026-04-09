# 🐳 Docker Containerization - AI Credit Risk Assessment System

> **Complete Docker setup for the AI Credit Risk Assessment System with Frontend, Backend, Database, and all services containerized**

---

## 📋 What's Included

This Docker setup provides:

✅ **Frontend Container** - React/Vite development server on port 5173  
✅ **Backend Container** - FastAPI with all Python services on port 8000  
✅ **MongoDB Container** - Data persistence with auto-initialization on port 27017  
✅ **Credit Bureau Mock Service** - Simulated external API on port 8001  
✅ **Jupyter Container** - ML exploration (optional) on port 8888  

✅ **3 Volumes** - For models, uploads, and database persistence  
✅ **Health Checks** - Automated service readiness monitoring  
✅ **Hot Reload** - Frontend and backend auto-reload during development  
✅ **Network Isolation** - Internal Docker network for service communication  
✅ **Database Schemas** - Auto-initialized with collections and indexes  

---

## 🚀 Quick Start (30 seconds)

### Option 1: Automated Script

**Linux / macOS:**
```bash
chmod +x quickstart.sh
./quickstart.sh
```

**Windows:**
```bash
quickstart.bat
```

### Option 2: Manual

```bash
# Start everything
docker compose up -d

# Check status (wait a few seconds)
docker compose ps
```

That's it! Your system is running.

---

## 🌐 Access Your System

| Component | URL | Purpose |
|-----------|-----|---------|
| **Frontend** | http://localhost:5173 | User interface |
| **Backend API** | http://localhost:8000 | REST API |
| **API Docs** | http://localhost:8000/docs | Interactive API documentation |
| **API Redoc** | http://localhost:8000/redoc | Alternative API docs |
| **Credit Bureau** | http://localhost:8001 | Mock API |
| **Jupyter** | http://localhost:8888 | ML development |
| **MongoDB** | mongodb://localhost:27017 | Database (User: admin, Pass: admin_password) |

---

## 📦 Files Created

### Core Docker Files

1. **`Dockerfile`** - Multi-stage build
   - Backend service (Python/FastAPI)
   - Frontend service (Node/React)
   - Credit Bureau mock service
   - 160+ lines, production-ready

2. **`docker-compose.yml`** - Orchestration file
   - 5 services configuration
   - Volume mappings
   - Network setup
   - Health checks
   - Environment variables
   - 300+ lines with extensive comments

3. **`.dockerignore`** - Optimize build context
   - Excludes unnecessary files from Docker builds
   - Reduces image sizes

### Supporting Files

4. **`scripts/init-mongodb.js`** - Database initialization
   - Creates 5 collections (users, applications, decisions, kyc, credit_checks)
   - Adds validation schemas
   - Creates performance indexes
   - Auto-runs on MongoDB startup

5. **`.env.docker`** - Environment configuration
   - Pre-configured for Docker Compose
   - Service names instead of localhost
   - Development credentials

### Startup Scripts

6. **`start-docker.sh`** - Advanced startup script (Linux/macOS)
   - Health checks
   - Colored output
   - Multiple commands (build, down, logs, reset, shell)
   - Helpful information

7. **`quickstart.sh`** - Simple startup (Linux/macOS)
   - One-command system ready
   - Prerequisite checks
   - Friendly output

8. **`quickstart.bat`** - Windows startup
   - Same as quickstart.sh for Windows
   - Batch script format

### Documentation

9. **`ARCHITECTURE.md`** - Complete system design (400+ lines)
   - System architecture overview
   - Root repository structure
   - Branch services breakdown
   - Docker components explanation
   - Volume management
   - Request flow & data persistence
   - Development workflows

10. **`DOCKER_GUIDE.md`** - Comprehensive user guide (500+ lines)
    - Quick start instructions
    - System architecture diagram
    - Component breakdown
    - Volume management
    - Common commands
    - Troubleshooting guide
    - Development workflows
    - Production deployment checklist

11. **`DOCKER_CHEATSHEET.md`** - Quick reference (300+ lines)
    - Most used commands
    - File operations
    - Database operations
    - Debugging tips
    - Common issues & fixes
    - Monitoring commands
    - Useful scripts
    - Emergency commands

---

## 🛠️ Common Commands

### Start & Stop

```bash
# Start all services
docker compose up -d

# Stop all services (keeps data)
docker compose down

# Stop and remove all data
docker compose down -v

# View status
docker compose ps
```

### Logs & Debugging

```bash
# View all logs
docker compose logs -f

# View specific service logs
docker compose logs -f backend

# Access container shell
docker compose exec backend bash
```

### Development

```bash
# Rebuild images
docker compose build

# Restart specific service
docker compose restart backend

# Run command in container
docker compose exec backend python models/train_dummy.py
```

### Database

```bash
# Access MongoDB shell
docker compose exec mongodb mongosh mongodb://admin:admin_password@localhost:27017

# Once in MongoDB:
use loan_agent_db
db.users.find()
```

**→ See `DOCKER_CHEATSHEET.md` for 100+ more commands**

---

## 📁 Volume Management

### What Gets Persisted

| Volume | Location | Purpose | Size |
|--------|----------|---------|------|
| `mongodb_data` | `/data/db` | Database | 100MB-1GB |
| `ml_models` | `/app/models` | Trained models | 50-200MB |
| `uploads_data` | `/app/uploads` | User files | Grows with usage |
| `pip_cache` | `/.cache/pip` | Package cache | Auto-managed |

### Copy Files

```bash
# Copy FROM container TO host
docker compose cp backend:/app/models ./backup/

# Copy FROM host TO container
docker compose cp ./model.pkl backend:/app/models/
```

---

## 🔌 Service Architecture

```
┌────────────────────────────────────────────────────────┐
│                 Docker Compose Network                 │
├────────────────────────────────────────────────────────┤
│                                                        │
│  Frontend (port 5173)  Backend (port 8000)  Bureau     │
│        React/Vite          FastAPI        (port 8001)  │
│           ↓                  ↓  ↑            ↑          │
│           └─────────────────┘   │            │         │
│                                 ↓            │         │
│                            MongoDB          └─ Mock    │
│                            (port 27017)          API   │
│                                                        │
│         Jupyter (Optional - port 8888)                 │
│                                                        │
└────────────────────────────────────────────────────────┘

All services communicate via Docker internal network
All accessible from host via localhost:PORT
```

---

## 🚦 Service Dependencies

```
Frontend (5173)
     ↓
     → Backend (8000) depends on:
         ├→ MongoDB (27017)
         └→ Credit Bureau (8001)
         
MongoDB auto-initializes with schemas on first start
Credit Bureau is a mock service included in stack
```

---

## 🔄 Development Workflow

### Frontend Changes (React)
```
1. Edit src/components/*.jsx
2. Save file
3. Vite detects change → auto-refresh
4. http://localhost:5173 updates immediately
```

### Backend Changes (Python)
```
1. Edit api/routes.py or services/*.py
2. Save file
3. Uvicorn --reload detects change → restarts
4. Refresh API call in frontend
```

### ML Model Changes
```
1. Edit tools/risk_model.py or models/train_dummy.py
2. Run: docker compose exec backend python models/train_dummy.py
3. Model reloaded on next prediction request
```

---

## 🐛 Troubleshooting

### Services Won't Start
```bash
# Check logs
docker compose logs backend

# Restart everything
docker compose down && docker compose up -d
```

### Port Already in Use
```bash
# Find process using port 8000
lsof -i :8000

# Change port in docker-compose.yml (ports section)
# Then restart
docker compose down && docker compose up -d
```

### MongoDB Connection Failed
```bash
# Check MongoDB logs
docker compose logs mongodb

# Restart MongoDB
docker compose restart mongodb

# Test connection
docker compose exec backend mongosh mongodb://admin:admin_password@mongodb:27017
```

### Out of Space
```bash
# Clean up Docker resources
docker system prune -a --volumes

# Or specifically remove volumes
docker volume prune
```

**→ See `DOCKER_GUIDE.md` for 20+ troubleshooting solutions**

---

## 📊 System Requirements

### Minimum
- **CPU**: 2 cores
- **RAM**: 4GB
- **Disk**: 10GB free space
- **OS**: Linux, macOS, or Windows with Docker Desktop

### Recommended
- **CPU**: 4+ cores
- **RAM**: 8GB+
- **Disk**: 20GB+ free space

---

## 🔐 Security Note

⚠️ **This setup is for LOCAL DEVELOPMENT ONLY**

**Not for production as-is:**
- Default MongoDB credentials in compose file
- No authentication on services
- CORS allows all origins
- No HTTPS/SSL

**For production:**
- Use managed MongoDB service (MongoDB Atlas, AWS DocumentDB)
- Set strong credentials in `.env` files
- Use environment variables for secrets
- Enable HTTPS/SSL with reverse proxy
- Restrict CORS origins
- Implement API authentication

**→ See `DOCKER_GUIDE.md` Production section for checklist**

---

## 📚 Documentation

| Document | Contents |
|----------|----------|
| **ARCHITECTURE.md** | System design, service breakdown, data flow (400+ lines) |
| **DOCKER_GUIDE.md** | Complete user guide, troubleshooting, production deployment (500+ lines) |
| **DOCKER_CHEATSHEET.md** | Quick command reference, common tasks, emergency commands (300+ lines) |
| **This README** | Quick start and overview |

---

## 🎯 What's Running Inside Each Container

### Backend Container
- **Image**: `python:3.11-slim`
- **Services**: 
  - FastAPI main application
  - ML engine with XGBoost
  - SHAP explanations
  - KYC verification
  - Plaid integration
  - Credit bureau client
  - PDF report generation
- **Port**: 8000
- **Features**: Hot-reload enabled, health checks

### Frontend Container
- **Image**: `node:20-alpine`
- **Stack**:
  - React 19.2.4
  - Vite 8.0.4
  - React Router 7.14.0
  - Axios for API calls
  - Tailwind CSS
- **Port**: 5173
- **Features**: Hot-reload with HMR

### MongoDB Container
- **Image**: `mongo:7.0-alpine`
- **Port**: 27017
- **Collections**: 5 pre-created with schemas
- **Indexes**: Optimized for queries
- **Persistence**: mongodb_data volume
- **Auto-Init**: Runs init-mongodb.js script

### Credit Bureau Container
- **Image**: `python:3.11-slim`
- **Framework**: FastAPI
- **Port**: 8001
- **Purpose**: Mock external API
- **Endpoints**:
  - `/health` - Health check
  - `/api/v1/credit-check` - Credit data simulation

### Jupyter Container (Optional)
- **Image**: `jupyter/datascience-notebook:latest`
- **Port**: 8888
- **Volumes**: models, services, tools, notebooks
- **Purpose**: ML development and exploration

---

## ✨ Key Features

### ✓ One-Command Deployment
```bash
docker compose up -d
```
Everything starts automatically with proper dependencies and health checks.

### ✓ Data Persistence
Models, uploads, and database data survive container restarts and updates.

### ✓ Development-Friendly
Hot-reload for both frontend and backend. Make changes, see them immediately.

### ✓ Debugging Support
Shell access into any container, view logs, inspect databases.

### ✓ Scalable Design
Services are independent. Easy to add more instances or external services.

### ✓ Production-Ready Code
Multi-stage builds, health checks, proper error handling, logging.

### ✓ Comprehensive Documentation
Architecture docs, user guide, cheat sheet, and inline comments.

---

## 📈 Next Steps

1. **Start the system**
   ```bash
   docker compose up -d
   ```

2. **Verify it's working**
   ```bash
   docker compose ps
   ```

3. **Access the frontend**
   - Open http://localhost:5173

4. **View API documentation**
   - Open http://localhost:8000/docs

5. **Explore the database**
   ```bash
   docker compose exec mongodb mongosh
   ```

6. **Read full documentation**
   - Start with `DOCKER_GUIDE.md`
   - Reference `DOCKER_CHEATSHEET.md` for commands
   - See `ARCHITECTURE.md` for deep dive

---

## 🆘 Need Help?

### Quick Health Check
```bash
# Check all services
docker compose ps

# View errors
docker compose logs --tail=50

# Test API health
curl http://localhost:8000/health

# Test frontend
curl http://localhost:5173
```

### Common Issues
- **Can't start?** → Check `DOCKER_GUIDE.md` Troubleshooting section
- **Don't know a command?** → See `DOCKER_CHEATSHEET.md`
- **Want to understand architecture?** → Read `ARCHITECTURE.md`
- **Setup questions?** → Check `DOCKER_GUIDE.md` FAQ

---

## 🚢 Deployment Checklist

- ✅ Docker Compose file created
- ✅ Dockerfile with multi-stage builds
- ✅ MongoDB initialization scripts
- ✅ Volumes for persistence
- ✅ Health checks configured
- ✅ Environment variables setup
- ✅ Documentation complete
- ✅ Startup scripts provided

**Ready to deploy!** 🚀

---

## 📝 File Statistics

| File | Lines | Purpose |
|------|-------|---------|
| Dockerfile | 160 | Multi-stage container definitions |
| docker-compose.yml | 300 | Service orchestration |
| ARCHITECTURE.md | 400 | System design documentation |
| DOCKER_GUIDE.md | 500 | Comprehensive user guide |
| DOCKER_CHEATSHEET.md | 300 | Command reference |
| init-mongodb.js | 120 | Database initialization |
| start-docker.sh | 150 | Advanced startup script |
| quickstart.sh | 100 | Simple startup (Linux/macOS) |
| quickstart.bat | 100 | Simple startup (Windows) |

**Total: ~2000 lines of code & documentation**

---

## 🎉 You're All Set!

Your credit risk assessment system is now fully containerized and ready to use.

```bash
# Start it
docker compose up -d

# That's it! 🐳
```

---

**Happy containerizing!** 🚀  
For detailed information, check the documentation files.
