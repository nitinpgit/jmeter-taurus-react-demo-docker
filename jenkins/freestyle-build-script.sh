#!/bin/bash

# Jenkins Freestyle Build Script for Taurus Testing
# This script can be used as a single build step in Jenkins

set -e  # Exit on any error

echo "========================================"
echo "Jenkins Taurus Test Pipeline"
echo "========================================"
echo ""

# Configuration
TAURUS_CONFIG=${TAURUS_CONFIG:-"taurus/get-quick-message.yml"}
BACKEND_PORT=5000
FRONTEND_PORT=3000

echo "Configuration:"
echo "  Taurus Config: $TAURUS_CONFIG"
echo "  Backend Port: $BACKEND_PORT"
echo "  Frontend Port: $FRONTEND_PORT"
echo ""

# Function to cleanup processes
cleanup() {
    echo "Cleaning up processes..."
    
    # Stop backend
    if [ -f backend/backend.pid ]; then
        kill $(cat backend/backend.pid) 2>/dev/null || true
        rm -f backend/backend.pid
    fi
    
    # Stop frontend
    if [ -f frontend/frontend.pid ]; then
        kill $(cat frontend/frontend.pid) 2>/dev/null || true
        rm -f frontend/frontend.pid
    fi
    
    # Kill any remaining processes
    pkill -f "npm start" || true
    pkill -f "node server.js" || true
    
    echo "Cleanup completed"
}

# Set trap to cleanup on exit
trap cleanup EXIT

# Step 1: Setup Environment
echo "Step 1: Setting up environment..."

# Create .bzt-rc file for BlazeMeter configuration
cat > ~/.bzt-rc << EOF
modules:
  blazemeter:
    token: "1f57f44b33ab29df65126dc1:c0d07b2ae9f8d63d3806520dd79eeb69c26ea1376775ea743e81bcb091be3ddf5d03e559"
EOF
echo "✓ BlazeMeter configuration created"

# Install dependencies
echo "Installing backend dependencies..."
cd backend && npm install
echo "✓ Backend dependencies installed"

echo "Installing frontend dependencies..."
cd ../frontend && npm install
echo "✓ Frontend dependencies installed"

cd ..

# Step 2: Start Backend Application
echo ""
echo "Step 2: Starting backend application..."
cd backend
nohup npm start > ../backend.log 2>&1 &
echo $! > backend.pid
cd ..

# Wait for backend to start
echo "Waiting for backend to start..."
sleep 10

# Check if backend is running
if curl -f http://localhost:$BACKEND_PORT/api/health > /dev/null 2>&1; then
    echo "✓ Backend started successfully"
else
    echo "✗ Backend failed to start"
    echo "Backend logs:"
    tail -20 backend.log
    exit 1
fi

# Step 3: Start Frontend Application
echo ""
echo "Step 3: Starting frontend application..."
cd frontend
nohup npm start > ../frontend.log 2>&1 &
echo $! > frontend.pid
cd ..

# Wait for frontend to start
echo "Waiting for frontend to start..."
sleep 15

# Check if frontend is running
if curl -f http://localhost:$FRONTEND_PORT > /dev/null 2>&1; then
    echo "✓ Frontend started successfully"
else
    echo "✗ Frontend failed to start"
    echo "Frontend logs:"
    tail -20 frontend.log
    exit 1
fi

# Step 4: Run Taurus Tests
echo ""
echo "Step 4: Running Taurus tests..."
echo "Running Taurus test: $TAURUS_CONFIG"

# Create results directory
mkdir -p taurus-test-results

# Run Taurus test
bzt $TAURUS_CONFIG

# Move timestamped results to organized directory
if [ -f move-taurus-results.sh ]; then
    chmod +x move-taurus-results.sh
    ./move-taurus-results.sh
    echo "✓ Test results organized"
fi

echo "✓ Taurus test completed"

# Step 5: Stop Applications
echo ""
echo "Step 5: Stopping applications..."
cleanup

echo ""
echo "========================================"
echo "Pipeline completed successfully!"
echo "========================================"
echo ""
echo "Test results available in:"
echo "  - taurus-test-results/"
echo "  - taurus-result/"
echo "  - backend.log"
echo "  - frontend.log"
echo ""
echo "BlazeMeter reports: https://a.blazemeter.com/app/#/projects" 