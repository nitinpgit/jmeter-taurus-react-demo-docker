#!/bin/bash

# Comprehensive Jenkins Build Script for Taurus + React + Node.js Application
# This script handles the complete build and test lifecycle

set -e  # Exit on any error

echo "========================================"
echo "🚀 Starting Comprehensive Build Process"
echo "========================================"

# Function to cleanup processes
cleanup() {
    echo "🧹 Cleaning up processes..."
    
    # Kill backend process
    if [ -f "backend/backend.pid" ]; then
        echo "🛑 Stopping backend..."
        kill $(cat backend/backend.pid) 2>/dev/null || true
        rm -f backend/backend.pid
    fi
    
    # Kill frontend process
    if [ -f "frontend/frontend.pid" ]; then
        echo "🛑 Stopping frontend..."
        kill $(cat frontend/frontend.pid) 2>/dev/null || true
        rm -f frontend/frontend.pid
    fi
    
    echo "✅ Cleanup completed"
}

# Set trap to cleanup on exit
trap cleanup EXIT

# ========================================
# 1. ENVIRONMENT SETUP
# ========================================

echo "🔧 Setting up environment..."

# Check required parameters
if [ -z "$TAURUS_CONFIG" ]; then
    echo "❌ ERROR: TAURUS_CONFIG parameter is not set"
    echo "Please set TAURUS_CONFIG in your Jenkins build parameters"
    exit 1
fi

echo "📋 Build Parameters:"
echo "  - TAURUS_CONFIG: $TAURUS_CONFIG"
echo "  - GIT_BRANCH: ${GIT_BRANCH:-not set}"
echo "  - BUILD_NUMBER: ${BUILD_NUMBER:-not set}"

# Activate Taurus virtual environment
echo "🔧 Activating Taurus virtual environment..."
if [ ! -f "/var/jenkins_home/taurus-venv/bin/activate" ]; then
    echo "❌ ERROR: Taurus virtual environment not found"
    echo "Please run the environment setup script first (see README-1.md)"
    exit 1
fi

source /var/jenkins_home/taurus-venv/bin/activate

# Verify environment
echo "🔍 Verifying environment..."
echo "  - Python: $(python3 --version)"
echo "  - Taurus: $(bzt -v)"
echo "  - Node: $(node -v)"
echo "  - npm: $(npm -v)"

# ========================================
# 2. INSTALL DEPENDENCIES
# ========================================

echo "📦 Installing project dependencies..."

# Install backend dependencies
echo "🔧 Installing backend dependencies..."
if [ -d "backend" ]; then
    cd backend
    npm install
    cd ..
    echo "✅ Backend dependencies installed"
else
    echo "❌ ERROR: Backend directory not found"
    exit 1
fi

# Install frontend dependencies
echo "🔧 Installing frontend dependencies..."
if [ -d "frontend" ]; then
    cd frontend
    npm install
    cd ..
    echo "✅ Frontend dependencies installed"
else
    echo "❌ ERROR: Frontend directory not found"
    exit 1
fi

# ========================================
# 3. START APPLICATIONS
# ========================================

echo "🚀 Starting applications..."

# Start backend
echo "🔧 Starting backend application..."
cd backend
nohup npm start > ../backend.log 2>&1 &
BACKEND_PID=$!
echo $BACKEND_PID > backend.pid
cd ..

echo "⏳ Waiting for backend to start..."
sleep 10

# Check if backend is running
if ! kill -0 $BACKEND_PID 2>/dev/null; then
    echo "❌ ERROR: Backend failed to start"
    echo "📋 Backend log:"
    cat backend.log
    exit 1
fi

echo "✅ Backend started (PID: $BACKEND_PID)"

# Test backend health
echo "🔍 Testing backend health..."
for i in {1..5}; do
    if curl -s http://localhost:5000/api/message > /dev/null 2>&1; then
        echo "✅ Backend is responding"
        break
    else
        echo "⏳ Waiting for backend to be ready... (attempt $i/5)"
        sleep 2
    fi
done

# Start frontend
echo "🔧 Starting frontend application..."
cd frontend
nohup npm start > ../frontend.log 2>&1 &
FRONTEND_PID=$!
echo $FRONTEND_PID > frontend.pid
cd ..

echo "⏳ Waiting for frontend to start..."
sleep 15

# Check if frontend is running
if ! kill -0 $FRONTEND_PID 2>/dev/null; then
    echo "❌ ERROR: Frontend failed to start"
    echo "📋 Frontend log:"
    cat frontend.log
    exit 1
fi

echo "✅ Frontend started (PID: $FRONTEND_PID)"

# ========================================
# 4. RUN TAURUS TESTS
# ========================================

echo "🧪 Running Taurus tests..."

# Check if Taurus config file exists
if [ ! -f "$TAURUS_CONFIG" ]; then
    echo "❌ ERROR: Taurus config file not found: $TAURUS_CONFIG"
    echo "Available Taurus configs:"
    ls -la taurus/*.yml 2>/dev/null || echo "No taurus configs found in taurus/ directory"
    exit 1
fi

# Create results directory
echo "📁 Creating results directory..."
mkdir -p taurus-test-results

# Display current working directory and files
echo "📂 Current directory: $(pwd)"
echo "📂 Contents:"
ls -la

# Run Taurus test
echo "🚀 Running Taurus test: $TAURUS_CONFIG"
echo "⏱️  Test started at: $(date)"

# Capture Taurus exit code
set +e  # Don't exit on Taurus errors
bzt "$TAURUS_CONFIG"
TAURUS_EXIT_CODE=$?
set -e  # Resume exit on error

echo "⏱️  Test completed at: $(date)"

# Check Taurus execution result
if [ $TAURUS_EXIT_CODE -eq 0 ]; then
    echo "✅ Taurus test completed successfully"
else
    echo "⚠️  Taurus test completed with exit code: $TAURUS_EXIT_CODE"
    echo "📋 Check the Taurus logs for details"
fi

# ========================================
# 5. ORGANIZE RESULTS
# ========================================

echo "📦 Organizing test results..."

# Move timestamped results to organized directory
if [ -f "move-taurus-results.sh" ]; then
    echo "🔧 Making move-taurus-results.sh executable..."
    chmod +x move-taurus-results.sh
    
    echo "📁 Moving timestamped result folders..."
    ./move-taurus-results.sh
    
    # Check if move was successful
    if [ $? -eq 0 ]; then
        echo "✅ Results organized successfully"
    else
        echo "⚠️  Warning: Results organization may have had issues"
    fi
else
    echo "⚠️  Warning: move-taurus-results.sh not found"
    echo "📂 Manual result organization may be needed"
fi

# Display final results structure
echo "📂 Final results structure:"
if [ -d "taurus-test-results" ]; then
    ls -la taurus-test-results/
else
    echo "No taurus-test-results directory found"
fi

# Check for timestamped folders that might not have been moved
echo "📂 Checking for unmoved timestamped folders:"
TIMESTAMPED_FOLDERS=$(find . -maxdepth 1 -type d -name "202*" 2>/dev/null || true)
if [ -n "$TIMESTAMPED_FOLDERS" ]; then
    echo "⚠️  Found timestamped folders that may need manual organization:"
    echo "$TIMESTAMPED_FOLDERS"
else
    echo "✅ All timestamped folders appear to be organized"
fi

# ========================================
# 6. BUILD SUMMARY
# ========================================

echo "========================================"
echo "📊 Build Summary"
echo "========================================"
echo "✅ Environment: Ready"
echo "✅ Dependencies: Installed"
echo "✅ Backend: Running (PID: $BACKEND_PID)"
echo "✅ Frontend: Running (PID: $FRONTEND_PID)"
echo "✅ Taurus Test: Completed (Exit: $TAURUS_EXIT_CODE)"
echo "✅ Results: Organized"

# Display application logs for debugging
echo "📋 Application Logs Summary:"
echo "Backend log (last 10 lines):"
tail -10 backend.log 2>/dev/null || echo "No backend log found"

echo "Frontend log (last 10 lines):"
tail -10 frontend.log 2>/dev/null || echo "No frontend log found"

echo "========================================"
echo "🏁 Build Process Complete"
echo "========================================"

# Exit with Taurus exit code to preserve test result
exit $TAURUS_EXIT_CODE 