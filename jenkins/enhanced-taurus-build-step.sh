#!/bin/bash

# Enhanced Taurus Test Execution for Jenkins
# This script provides robust Taurus test execution with proper error handling

set -e  # Exit on any error

echo "========================================"
echo "🧪 Starting Taurus Test Execution"
echo "========================================"

# Parameter: TAURUS_CONFIG (set in build parameters)
if [ -z "$TAURUS_CONFIG" ]; then
    echo "❌ ERROR: TAURUS_CONFIG parameter is not set"
    echo "Please set TAURUS_CONFIG in your Jenkins build parameters"
    exit 1
fi

echo "📋 Test Configuration: $TAURUS_CONFIG"

# Check if Taurus config file exists
if [ ! -f "$TAURUS_CONFIG" ]; then
    echo "❌ ERROR: Taurus config file not found: $TAURUS_CONFIG"
    echo "Available Taurus configs:"
    ls -la taurus/*.yml 2>/dev/null || echo "No taurus configs found in taurus/ directory"
    exit 1
fi

# Activate Taurus virtual environment
echo "🔧 Activating Taurus virtual environment..."
if [ ! -f "/var/jenkins_home/taurus-venv/bin/activate" ]; then
    echo "❌ ERROR: Taurus virtual environment not found"
    echo "Please run the environment setup script first"
    exit 1
fi

source /var/jenkins_home/taurus-venv/bin/activate

# Verify Taurus installation
echo "🔍 Verifying Taurus installation..."
if ! command -v bzt &> /dev/null; then
    echo "❌ ERROR: Taurus (bzt) not found in virtual environment"
    echo "Please install Taurus: pip install bzt"
    exit 1
fi

echo "✅ Taurus version: $(bzt -v)"

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

# Move timestamped results to organized directory
echo "📦 Organizing test results..."
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

echo "========================================"
echo "🏁 Taurus Test Execution Complete"
echo "========================================"

# Exit with Taurus exit code to preserve test result
exit $TAURUS_EXIT_CODE 