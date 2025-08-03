#!/bin/bash

echo "========================================"
echo "Stopping Jenkins with Docker Compose"
echo "========================================"
echo ""

# Navigate to jenkins directory
cd jenkins

echo "Stopping Jenkins container..."
docker-compose down

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================"
    echo "Jenkins stopped successfully!"
    echo "========================================"
    echo ""
    echo "Jenkins data is preserved in Docker volume"
    echo "To completely remove data, run:"
    echo "docker-compose down -v"
else
    echo ""
    echo "========================================"
    echo "Failed to stop Jenkins!"
    echo "========================================"
    exit 1
fi 