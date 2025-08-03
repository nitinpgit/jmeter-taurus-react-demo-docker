#!/bin/bash

echo "========================================"
echo "Starting Jenkins with Docker Compose"
echo "========================================"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker is not installed or not in PATH"
    echo "Please install Docker first: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "ERROR: Docker Compose is not installed or not in PATH"
    echo "Please install Docker Compose first: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "Docker and Docker Compose found"
echo ""

# Create jenkins directory if it doesn't exist
if [ ! -d "jenkins" ]; then
    echo "Creating jenkins directory..."
    mkdir -p jenkins
fi

# Navigate to jenkins directory
cd jenkins

echo "Building Jenkins image..."
docker-compose build

echo "Starting Jenkins container..."
echo "container name: jenkins-taurus-demo"
docker-compose up -d

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================"
    echo "Jenkins started successfully!"
    echo "========================================"
    echo ""
    echo "Jenkins URL: http://localhost:8080"
    echo ""
    echo "To get the initial admin password, run:"
    echo "docker exec jenkins-taurus-demo cat /var/jenkins_home/secrets/initialAdminPassword"
    echo ""
    echo "To view logs:"
    echo "docker-compose logs -f"
    echo ""
    echo "To stop Jenkins:"
    echo "docker-compose down"
else
    echo ""
    echo "========================================"
    echo "Failed to start Jenkins!"
    echo "========================================"
    exit 1
fi 