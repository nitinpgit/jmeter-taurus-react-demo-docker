#!/bin/bash

echo "Starting JMeter Taurus React Demo with Jenkins..."
echo "This will start Jenkins with persistent data storage"

# Build and start the containers
docker-compose up -d --build

echo ""
echo "Jenkins is starting up..."
echo "Access Jenkins at: http://localhost:8080"
echo ""
echo "To get the initial admin password, run:"
echo "docker-compose logs jenkins | grep -A 1 'initialAdminPassword'"
echo ""
echo "To stop the containers:"
echo "docker-compose down"
echo ""
echo "To stop and remove all data:"
echo "docker-compose down -v"
echo ""
echo "To view logs:"
echo "docker-compose logs -f jenkins" 