#!/bin/bash

# Setup script for persistent data directories
# This script creates the necessary directories for data persistence

set -e

echo "=== Setting up persistent data directories ==="

# Create Jenkins data directories
echo "Creating Jenkins data directories..."
mkdir -p jenkins-data/home
mkdir -p jenkins-data/workspace
mkdir -p jenkins-data/test-results

# Set proper permissions for Jenkins
echo "Setting permissions for Jenkins directories..."
sudo chown -R 1000:1000 jenkins-data/
chmod -R 755 jenkins-data/

# Create application data directories
echo "Creating application data directories..."
mkdir -p app-data/backend
mkdir -p app-data/frontend
mkdir -p app-data/logs

# Create test data directories
echo "Creating test data directories..."
mkdir -p test-data/jmeter
mkdir -p test-data/taurus
mkdir -p test-data/results

# Set permissions for test data
chmod -R 755 test-data/
chmod -R 755 app-data/

# Create a .gitkeep file to ensure directories are tracked
echo "Creating .gitkeep files..."
touch jenkins-data/.gitkeep
touch app-data/.gitkeep
touch test-data/.gitkeep

echo "=== Persistent data directories setup completed ==="
echo ""
echo "Directory structure created:"
echo "├── jenkins-data/"
echo "│   ├── home/          (Jenkins home directory)"
echo "│   ├── workspace/     (Jenkins workspace)"
echo "│   └── test-results/  (Test results storage)"
echo "├── app-data/"
echo "│   ├── backend/       (Backend application data)"
echo "│   ├── frontend/      (Frontend application data)"
echo "│   └── logs/          (Application logs)"
echo "└── test-data/"
echo "    ├── jmeter/        (JMeter data)"
echo "    ├── taurus/        (Taurus data)"
echo "    └── results/       (Test results)"
echo ""
echo "Note: These directories will persist data even when containers are restarted." 