# Multi-stage Dockerfile for the entire AI Credit Risk Assessment System
# Supports both Frontend and Backend containerization

# ============================================================================
# STAGE 1: Backend - Build and Runtime
# ============================================================================
FROM python:3.11-slim AS backend-base

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    g++ \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better layer caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend application code
COPY . .

# Create necessary directories
RUN mkdir -p uploads/kyc uploads/payslip models && \
    chmod -R 755 uploads models

# Expose backend port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8000/health', timeout=5)" || exit 1

# Default command - Main FastAPI Application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]

# ============================================================================
# STAGE 2: Frontend - Builder
# ============================================================================
FROM node:20-alpine AS frontend-builder

WORKDIR /app/frontend

# Copy frontend dependencies
COPY frontend/package.json frontend/package-lock.json ./

# Install dependencies
RUN npm install --legacy-peer-deps

# Copy frontend source code
COPY frontend/ .

# Build for production
RUN npm run build

# ============================================================================
# STAGE 3: Frontend - Runtime (Nginx)
# ============================================================================
FROM node:20-alpine AS frontend-runtime

WORKDIR /app/frontend

# Copy installed dependencies and source from builder
COPY --from=frontend-builder /app/frontend/node_modules ./node_modules
COPY --from=frontend-builder /app/frontend/package.json ./package.json
COPY frontend/ .

# Expose frontend port
EXPOSE 5173

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:5173/ || exit 1

# Run Vite dev server
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0", "--port", "5173"]

# ============================================================================
# STAGE 4: Credit Bureau Mock Service (Optional FastAPI)
# ============================================================================
FROM python:3.11-slim AS credit-bureau

WORKDIR /app

# Install Python
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .

# Install basic FastAPI + uvicorn
RUN pip install --no-cache-dir fastapi uvicorn pydantic pydantic-settings

# Copy services
COPY services/credit_bureau_service.py .
COPY config.py .
COPY utils/ ./utils/

# Create a simple mock API
RUN cat > credit_bureau_api.py << 'EOF'
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional

app = FastAPI(
    title="Mock Credit Bureau API",
    description="Mock API for credit bureau service",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

class CreditCheckRequest(BaseModel):
    user_id: str
    ssn_last_4: str = ""
    full_name: Optional[str] = ""

@app.get("/health")
async def health():
    return {"status": "ok", "service": "credit_bureau_api"}

@app.post("/api/v1/credit-check")
async def credit_check(request: CreditCheckRequest):
    """Mock credit check endpoint"""
    return {
        "user_id": request.user_id,
        "credit_velocity": 680,
        "debt_index": 0.32,
        "credit_history_months": 84,
        "total_accounts": 6,
        "delinquent_accounts": 0,
        "credit_utilization": 0.28,
        "payment_history_score": 78,
        "bureau_name": "MockExperian"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)
EOF

EXPOSE 8001

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8001/health', timeout=5)" || exit 1

CMD ["python", "credit_bureau_api.py"]
