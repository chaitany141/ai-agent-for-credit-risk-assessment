# System Architecture & Dockerization Overview

## 🏛️ System Architecture

### High-Level Process Flow

```
USER INTERFACE (React Frontend)
    ↓
AUTHENTICATION & ROUTING (React Router)
    ↓
API CALLS (Axios to Backend)
    ↓
BACKEND API GATEWAY (FastAPI)
    ├→ Request Validation (Pydantic)
    ├→ KYC Verification Service
    ├→ Loan Application Processing
    └→ Agent Decision Making
         ↓
      AI AGENT (LoanAgent)
         ├→ Risk Assessment
         ├→ SHAP Explainability
         └→ Decision Memory
      ↓
    MACHINE LEARNING ENGINE
         ├→ Risk Model (XGBoost)
         ├→ Feature Engineering
         └→ SHAP Explanations
      ↓
    CREDIT BUREAU SERVICE
         ├→ Credit Score Lookup
         ├→ Debt Information
         └→ Payment History
      ↓
    PRIMARY DATABASE (MongoDB)
         ├→ Users Collection
         ├→ Applications Collection
         ├→ Decisions Collection
         └→ KYC Documents Collection
         
DATABASE RESPONSE → BACKEND → FRONTEND → USER RESULTS
```

---

## 🔌 Root Repository & Branch Services

### Root Level (Backend)
```
ai-agent-for-credit-risk-assessment/ [Root]
├── main.py ...................... Entry point (FastAPI app)
├── config.py ..................... Configuration & settings
├── database.py ................... MongoDB connection manager
├── requirements.txt .............. Python dependencies
├── runtime.txt ................... Python version specification
└── Procfile ...................... Heroku deployment config
```

### Branch 1: Agent Layer (`/agent`)
**Purpose**: AI decision-making logic
```
agent/
├── core.py ....................... LoanAgent class - main AI logic
│   ├─ analyze_application()      - Orchestrates risk assessment
│   ├─ explain_decision()        - Generates SHAP explanations
│   └─ suggest_conditions()      - Custom loan conditions
└── memory.py ..................... Decision history management
    ├─ save_decision()          - Persist decisions to DB
    └─ get_similar_decisions()  - Retrieve past decisions
```

### Branch 2: API Layer (`/api`)
**Purpose**: HTTP API endpoints
```
api/
├── routes.py ..................... All API endpoints
│   ├─ POST /analyze-loan       - Main loan analysis endpoint
│   ├─ POST /verify-kyc        - KYC verification
│   ├─ POST /verify-income     - Income verification from documents
│   ├─ GET /user/{user_id}     - Get user profile
│   └─ POST /download-report   - Generate PDF report
└── schemas.py ..................... Pydantic data models
    ├─ LoanApplicationRequest    - Input validation
    ├─ AgentDecisionResponse     - Output structure
    └─ KYCRequest/Response      - KYC data models
```

### Branch 3: Services Layer (`/services`)
**Purpose**: External integrations and business logic
```
services/
├── ai_engine.py ................... ML model & SHAP integration
│   ├─ CreditRiskModel class     - Wraps XGBoost model
│   ├─ predict()                 - Risk prediction
│   └─ explain_prediction()      - Feature importance via SHAP
├── credit_bureau_service.py ....... Credit bureau integration
│   ├─ get_credit_data()         - Fetch credit info
│   └─ Credit score, debt, payment history
├── kyc_service.py ................. KYC document handling
├── plaid_service.py ............... Plaid financial API integration
└── [Additional services]
```

### Branch 4: ML Tools (`/tools`)
**Purpose**: Machine learning and decision utilities
```
tools/
├── risk_model.py .................. Risk prediction functions
├── explainability.py .............. SHAP explanations
├── decision.py .................... Decision logic (approve/reject/conditions)
└── user_data.py ................... User data aggregation
```

### Branch 5: Models (`/models`)
**Purpose**: Pre-trained ML models and initialization
```
models/
├── dummy_model.pkl ................ Trained XGBoost model
├── schemas.py ..................... Model feature definitions
└── train_dummy.py ................. Model training script
```

### Branch 6: KYC Layer (`/kyc`)
**Purpose**: Know Your Customer verification
```
kyc/
└── kyc_service.py ................. KYC verification service
    ├─ Aadhaar verification
    ├─ PAN verification
    └─ Document validation
```

### Branch 7: Frontend (`/frontend`)
**Purpose**: React application and UI
```
frontend/
├── package.json ................... Dependencies & build config
├── vite.config.js ................. Vite build configuration
├── src/
│   ├── main.jsx ................... App entry point
│   ├── App.jsx .................... Root component
│   ├── services/
│   │   └── api.js ................. Axios configuration & API calls
│   ├── components/ ................ Reusable React components
│   │   ├── LoanForm.jsx
│   │   ├── KYCUpload.jsx
│   │   ├── ResultCard.jsx
│   │   └── [Other components]
│   ├── pages/ ..................... Page-level components
│   │   ├── Home.jsx
│   │   ├── Login.jsx
│   │   ├── Dashboard.jsx
│   │   └── [Other pages]
│   ├── contexts/ .................. React Context for state
│   │   └── AuthContext.jsx
│   └── layouts/ ................... Layout wrappers
│       └── MainLayout.jsx
└── public/ ........................ Static assets
```

### Branch 8: Utilities (`/utils`)
**Purpose**: Helper functions and shared logic
```
utils/
├── db.py .......................... Database CRUD operations
├── logger.py ...................... Logging setup
└── report_generator.py ............ PDF report generation
```

### Branch 9: Data Directory (`/uploads`)
**Purpose**: User-uploaded files storage
```
uploads/
├── kyc/ ........................... KYC document uploads
├── payslip/ ....................... Payslip for income verification
└── [Other document types]
```

---

## 🐳 Dockerization Strategy

### Why Containerize?

✅ **Consistency**: Same environment everywhere (dev, staging, prod)  
✅ **Isolation**: Services don't interfere with each other  
✅ **Scalability**: Easy to scale individual services  
✅ **Deployment**: Single command deploys entire system  
✅ **Dependency Management**: All dependencies packaged  

---

## 📦 Docker Components Breakdown

### 1. **Dockerfile** (Multi-Stage Build)

#### Stage 1: Backend Base
```dockerfile
FROM python:3.11-slim AS backend-base
# Installs all Python dependencies
# Copies entire backend code
# Exposes port 8000
# Health checks enabled
```

**Features:**
- Python 3.11 slim image (optimized)
- All 19 dependencies from requirements.txt
- Auto-creates directories: uploads/, models/
- Health check every 30s
- CMD runs uvicorn with reload enabled

#### Stage 2: Frontend Builder
```dockerfile
FROM node:20-alpine AS frontend-builder
# Installs npm dependencies
# Runs build process
# Creates optimized production bundle
```

#### Stage 3: Frontend Runtime
```dockerfile
FROM node:20-alpine AS frontend-runtime
# Copies dependencies and source
# Runs Vite dev server
# Exposes port 5173
```

#### Stage 4: Credit Bureau Mock
```dockerfile
FROM python:3.11-slim AS credit-bureau
# Standalone FastAPI mock service
# Exposes port 8001
# Simulates external credit bureau API
```

### 2. **docker-compose.yml** (Orchestration)

#### Service 1: MongoDB Container
```yaml
Service: mongodb
Image: mongo:7.0-alpine
Port: 27017
Volumes:
  - mongodb_data (persistence)
  - init-mongodb.js (initialization script)
Init Script Creates:
  - users collection
  - loan_applications collection
  - agent_decisions collection
  - kyc_documents collection
  - credit_checks collection
  + Validation schemas & indexes
Health Check: Every 10s, max 5 retries
```

#### Service 2: Backend Container
```yaml
Service: credit_risk_backend
Build: Multi-stage Dockerfile (backend-base)
Port: 8000
Volumes:
  - . (source code - hot reload)
  - ml_models (model persistence)
  - uploads_data (file uploads)
Environment:
  - MONGO_URI pointing to mongodb service
  - CREDIT_BUREAU_API_URL pointing to credit_bureau service
  - All config from config.py
Depends On: mongodb (with health check)
Health Check: Every 30s, max 3 retries
Startup: 
  1. Train ML model
  2. Run uvicorn with reload
```

#### Service 3: Frontend Container
```yaml
Service: credit_risk_frontend
Build: Multi-stage Dockerfile (frontend-runtime)
Port: 5173
Volumes:
  - ./frontend (source code - hot reload)
Environment:
  - VITE_API_URL for backend communication
Depends On: backend (started, not necessarily healthy)
Health Check: Checks port 5173 every 30s
Startup: npm run dev
```

#### Service 4: Credit Bureau Container
```yaml
Service: credit_bureau
Build: Multi-stage Dockerfile (credit-bureau)
Port: 8001
Provides Mock APIs:
  - GET /health
  - POST /api/v1/credit-check
Health Check: Every 30s, max 3 retries
```

#### Service 5: Jupyter Container (Optional)
```yaml
Service: jupyter
Image: jupyter/datascience-notebook
Port: 8888
Volumes:
  - models, services, tools, notebooks
Purpose: ML development & exploration
```

---

## 💾 Volumes & Data Persistence

### Volume 1: `mongodb_data`
- **Mount**: `/data/db` in MongoDB container
- **Purpose**: Database persistence across container restarts
- **Size**: Grows with data, typically 100MB-1GB for dev
- **Backup**: Use `mongodump` to backup

### Volume 2: `ml_models`
- **Mount**: `/app/models/` in backend
- **Files**: `dummy_model.pkl` (trained XGBoost)
- **Purpose**: Share trained models between sessions
- **Backup**: Essential to backup before model updates

### Volume 3: `uploads_data`
- **Mount**: `/app/uploads/` in backend
- **Structure**: 
  - `kyc/` - KYC documents
  - `payslip/` - Income verification documents
- **Purpose**: Persistent storage of user uploads
- **Backup**: Regular backups recommended

### Volume 4: `pip_cache`
- **Mount**: `/.cache/pip`
- **Purpose**: Speed up Docker rebuilds
- **Safe to Delete**: Yes, will be regenerated

---

## 🌐 Network Architecture

### Docker Compose Network: `credit_risk_network`

```
┌─────────────────────────────────────────────┐
│       credit_risk_network (bridge)          │
├─────────────────────────────────────────────┤
│                                             │
│  mongodb:27017                              │
│  ↑    ↓                                      │
│  └── credit_risk_backend:8000 ──────┐      │
│       ↑                              ↓      │
│       │                   credit_risk_bureau:8001
│       │                                    │
│       └────── credit_risk_frontend:5173    │
│                                             │
│  (Optional)                                 │
│  jupyter:8888                               │
│                                             │
└─────────────────────────────────────────────┘

All services communicate via service names:
- mongodb (not localhost)
- backend (not localhost)
- credit_bureau (not localhost)
```

### Service Communication

| From | To | Protocol | Internal URL |
|------|----|----|---|
| Frontend | Backend | HTTP | `http://backend:8000` |
| Backend | MongoDB | Async | `mongodb://admin:pass@mongodb:27017` |
| Backend | Credit Bureau | HTTP | `http://credit_bureau:8001` |
| External (You) | Frontend | HTTP | `http://localhost:5173` |
| External (You) | Backend | HTTP | `http://localhost:8000` |
| External (You) | MongoDB | RESP | `mongodb://localhost:27017` |

---

## 🚀 Complete Startup Process

### Step-by-Step (docker compose up -d)

```
1. docker compose reads docker-compose.yml
   └─ Recognizes 5 services

2. Docker builds/prepares images (if not cached)
   ├─ Dockerfile backend stage
   ├─ Dockerfile frontend stages
   ├─ Dockerfile credit-bureau stage
   └─ Pulls mongo:7.0-alpine, jupyter images

3. Creates network: credit_risk_network

4. Creates volumes:
   ├─ mongodb_data
   ├─ ml_models
   ├─ uploads_data
   └─ pip_cache

5. Starts MongoDB container
   ├─ Runs init-mongodb.js
   │  ├─ Creates database
   │  ├─ Creates collections
   │  └─ Creates indexes
   └─ Health check passes

6. Starts Backend container
   ├─ mounts: source code, volumes
   ├─ Runs: python models/train_dummy.py
   ├─ Runs: uvicorn main:app (reload enabled)
   ├─ Connects to mongodb:27017
   └─ Health check passes

7. Starts Frontend container
   ├─ Mounts source code
   ├─ Runs: npm run dev
   └─ Serves on 0.0.0.0:5173

8. Starts Credit Bureau container
   ├─ Runs mock FastAPI
   └─ Serves on 0.0.0.0:8001

9. Starts Jupyter container (optional)
   └─ Serves on 0.0.0.0:8888

All services now accessible from host machine:
- Frontend: http://localhost:5173
- Backend: http://localhost:8000
- MongoDB: mongodb://localhost:27017
- Credit Bureau: http://localhost:8001
- Jupyter: http://localhost:8888
```

---

## 📊 Request Flow in Docker

### Typical Loan Application Request

```
1. USER INTERACTION (Frontend at localhost:5173)
   └─ Fills loan form
   └─ Clicks "Analyze Loan"
   
2. FRONTEND CODE (React component)
   └─ Calls: axios.post('http://localhost:8000/analyze-loan', data)
   └─ Browser makes HTTP request to localhost:8000
   
3. DOCKER NETWORK ROUTING
   Docker translates: localhost:8000 → backend:8000
   └─ Request reaches backend container through port mapping
   
4. BACKEND PROCESSING (FastAPI in backend container)
   └─ Receives request at /analyze-loan endpoint
   └─ Validates input (Pydantic schemas)
   └─ Calls LoanAgent.analyze_application()
   
5. AGENT ORCHESTRATION (agent/core.py)
   ├─ Calls risk_model.predict()
   │  └─ Backend connects to ml_models volume → loads dummy_model.pkl
   │  └─ XGBoost predicts risk score
   │  └─ SHAP explains feature importance
   ├─ Calls credit_bureau_service.get_credit_data()
   │  └─ HTTP request to http://credit_bureau:8001
   │  └─ Gets mock credit data from credit_bureau container
   └─ Calls decision_engine()
      └─ Compares risk_score against thresholds
      └─ Generates decision: Approved/Rejected/Conditions
      
6. DATABASE OPERATIONS (Motor async driver)
   ├─ Saves application to users collection
   ├─ Saves loan_applications record
   ├─ Saves agent_decisions record
   └─ All in MongoDB container at mongodb:27017
   
7. RESPONSE GENERATION (Backend)
   └─ Creates AgentDecisionResponse
   └─ Returns JSON with decision, explanation, feature impacts
   
8. NETWORK RESPONSE
   Response travels: backend:8000 → localhost:8000 → Frontend
   
9. FRONTEND DISPLAY (React)
   └─ Receives JSON response
   └─ Updates UI with decision
   └─ Displays SHAP feature importance chart
   └─ Shows loan conditions if applicable
```

---

## 🔄 Data Flow in Persistence

### Model Training & Persistence

```
1. Backend startup runs: python models/train_dummy.py
   ├─ Loads training data
   ├─ Trains XGBoost model
   └─ Saves to models/dummy_model.pkl

2. Pickle file saved to ml_models volume
   └─ Persists even after container restart
   
3. Once saved, ai_engine.py:
   ├─ Loads model from ml_models/dummy_model.pkl
   ├─ Keeps in memory during runtime
   └─ Uses for predictions
```

### Document Upload & Persistence

```
1. User uploads KYC document
   └─ Frontend sends multipart/form-data to /upload-kyc

2. Backend receives:
   ├─ Saves file to uploads_data/kyc/{user_id}/{filename}
   ├─ Stores reference in MongoDB (kyc_documents collection)
   └─ Returns file path in response

3. uploads_data volume:
   └─ Persists files across restarts
   └─ Can be backed up via docker compose cp

4. Later retrieval:
   ├─ Query kyc_documents collection for file path
   ├─ Read from uploads_data volume
   ├─ Serve to user or process
```

### Loan Application Persistence

```
1. Application received and analyzed

2. Result saved to MongoDB:
   └─ loan_applications collection
   ├─ user_id
   ├─ loan_amount, tenure
   ├─ income, credit_score, DTI
   ├─ risk_score (predicted)
   ├─ decision (Approved/Rejected/Conditions)
   ├─ agent_explanation (SHAP feature impacts)
   └─ timestamps

3. MongoDB stored in mongodb_data volume
   └─ Persists across container restarts
   └─ Can be backed up/restored

4. Historical queries:
   ├─ get_similar_decisions() uses mongo queries
   ├─ Retrieves past decisions for same user
   └─ Helps agent make consistent decisions
```

---

## 🔧 Development Workflow

### Hot Reload During Development

```
1. Frontend Changes (React/JSX):
   ├─ Edit src/App.jsx
   ├─ Save file
   ├─ Vite hot-module replacement detects change
   ├─ Browser auto-refreshes at http://localhost:5173
   └─ Change visible immediately

2. Backend Changes (Python):
   ├─ Edit api/routes.py
   ├─ Save file
   ├─ Uvicorn --reload detects change
   ├─ Restarts application
   ├─ Must refresh browser to see changes
   └─ API response updated

3. ML Model Changes:
   ├─ Edit tools/risk_model.py
   ├─ Restart backend: docker compose restart backend
   ├─ Retrains model (runs models/train_dummy.py)
   └─ New model used in predictions
```

---

## ✨ Features of This Dockerization

### ✓ Production-Ready
- Multi-stage Docker builds for optimization
- Health checks for all services
- Volume persistence for critical data
- Proper logging and error handling
- Service dependencies managed

### ✓ Development-Friendly
- Hot-reload for frontend and backend
- Easy shell access into containers
- Database initialization with schemas
- Mock services included
- Jupyter for ML exploration

### ✓ Scalable
- Independent services easily scalable
- Database separate from compute
- Clear separation of concerns
- Environment-based configuration
- Easy to add more services

### ✓ Maintainable
- Clear docker-compose structure
- Self-documenting Dockerfile
- Comprehensive initialization scripts
- Detailed guides and documentation
- Easy troubleshooting

---

## 📚 Quick Reference

| Command | Purpose |
|---------|---------|
| `docker compose up -d` | Start all services |
| `docker compose down` | Stop all services |
| `docker compose logs -f backend` | Watch backend logs |
| `docker compose exec backend bash` | Shell into backend |
| `docker compose ps` | Show service status |
| `docker compose build` | Rebuild images |
| `docker system prune -a` | Clean up unused resources |

---

## 🎯 Next Steps

1. **Start the system**: `docker compose up -d`
2. **Check services**: `docker compose ps`
3. **View documentation**: Open http://localhost:8000/docs
4. **Test the API**: Click "Try it out" in Swagger UI
5. **Access frontend**: http://localhost:5173
6. **Explore MongoDB**: `docker compose exec mongodb mongosh`
7. **View logs**: `docker compose logs -f`
8. **Stop when done**: `docker compose down`

---

**Your system is now fully containerized and ready for development and deployment!** 🐳
