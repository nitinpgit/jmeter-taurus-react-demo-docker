#!/bin/bash

# Quick Start Script for Jenkins Taurus Performance Testing Setup
# This script automates the entire setup process

set -e

echo "=== Jenkins Taurus Performance Testing - Quick Start ==="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed
check_docker() {
    print_status "Checking Docker installation..."
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    print_success "Docker and Docker Compose are installed"
}

# Check if ports are available
check_ports() {
    print_status "Checking if required ports are available..."
    
    local ports=(3000 5000 8080)
    local unavailable_ports=()
    
    for port in "${ports[@]}"; do
        if netstat -tuln 2>/dev/null | grep -q ":$port "; then
            unavailable_ports+=($port)
        fi
    done
    
    if [ ${#unavailable_ports[@]} -ne 0 ]; then
        print_warning "The following ports are already in use: ${unavailable_ports[*]}"
        print_warning "Please stop the services using these ports or modify the docker-compose file"
        read -p "Do you want to continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        print_success "All required ports are available"
    fi
}

# Setup persistent data directories
setup_persistent_data() {
    print_status "Setting up persistent data directories..."
    
    # Create directories
    mkdir -p jenkins-data/home
    mkdir -p jenkins-data/workspace
    mkdir -p jenkins-data/test-results
    mkdir -p app-data/backend
    mkdir -p app-data/frontend
    mkdir -p app-data/logs
    mkdir -p test-data/jmeter
    mkdir -p test-data/taurus
    mkdir -p test-data/results
    
    # Set permissions (try with sudo if available)
    if command -v sudo &> /dev/null; then
        sudo chown -R 1000:1000 jenkins-data/ 2>/dev/null || true
    fi
    
    chmod -R 755 jenkins-data/
    chmod -R 755 app-data/
    chmod -R 755 test-data/
    
    # Create .gitkeep files
    touch jenkins-data/.gitkeep
    touch app-data/.gitkeep
    touch test-data/.gitkeep
    
    print_success "Persistent data directories created"
}

# Start the services
start_services() {
    print_status "Starting Docker services..."
    
    # Stop any existing containers
    docker-compose -f docker-compose-persistent.yml down --remove-orphans 2>/dev/null || true
    
    # Start services
    docker-compose -f docker-compose-persistent.yml up -d
    
    print_success "Docker services started"
}

# Wait for services to be ready
wait_for_services() {
    print_status "Waiting for services to be ready..."
    
    # Wait for Jenkins
    print_status "Waiting for Jenkins to start..."
    local jenkins_ready=false
    for i in {1..60}; do
        if curl -s http://localhost:8080 > /dev/null 2>&1; then
            jenkins_ready=true
            break
        fi
        sleep 2
    done
    
    if [ "$jenkins_ready" = false ]; then
        print_error "Jenkins failed to start within 2 minutes"
        docker-compose -f docker-compose-persistent.yml logs jenkins
        exit 1
    fi
    
    print_success "Jenkins is ready"
    
    # Wait for backend
    print_status "Waiting for backend to be ready..."
    local backend_ready=false
    for i in {1..30}; do
        if curl -s http://localhost:5000/api/health > /dev/null 2>&1; then
            backend_ready=true
            break
        fi
        sleep 2
    done
    
    if [ "$backend_ready" = false ]; then
        print_warning "Backend health check failed, but continuing..."
    else
        print_success "Backend is ready"
    fi
    
    # Wait for frontend
    print_status "Waiting for frontend to be ready..."
    local frontend_ready=false
    for i in {1..30}; do
        if curl -s http://localhost:3000 > /dev/null 2>&1; then
            frontend_ready=true
            break
        fi
        sleep 2
    done
    
    if [ "$frontend_ready" = false ]; then
        print_warning "Frontend health check failed, but continuing..."
    else
        print_success "Frontend is ready"
    fi
}

# Display final information
display_info() {
    echo ""
    echo "=== Setup Complete! ==="
    echo ""
    echo "Services are now running:"
    echo "  • Jenkins: http://localhost:8080"
    echo "  • Frontend: http://localhost:3000"
    echo "  • Backend API: http://localhost:5000"
    echo ""
    echo "Next steps:"
    echo "1. Access Jenkins at http://localhost:8080"
    echo "2. Get the initial admin password:"
    echo "   docker-compose -f docker-compose-persistent.yml logs jenkins"
    echo "3. Follow the Jenkins setup wizard"
    echo "4. Install required plugins (see JENKINS_SETUP_GUIDE.md)"
    echo "5. Create the freestyle job using jenkins-job-config.xml"
    echo ""
    echo "Useful commands:"
    echo "  • View logs: docker-compose -f docker-compose-persistent.yml logs [service]"
    echo "  • Stop services: docker-compose -f docker-compose-persistent.yml down"
    echo "  • Restart services: docker-compose -f docker-compose-persistent.yml restart"
    echo ""
    echo "Data persistence:"
    echo "  • Jenkins data: ./jenkins-data/"
    echo "  • Application data: ./app-data/"
    echo "  • Test data: ./test-data/"
    echo ""
    print_success "Setup completed successfully!"
}

# Main execution
main() {
    echo "This script will set up the complete Jenkins Taurus performance testing environment."
    echo "It will:"
    echo "  • Check prerequisites"
    echo "  • Create persistent data directories"
    echo "  • Start Docker services"
    echo "  • Wait for services to be ready"
    echo ""
    read -p "Do you want to continue? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo "Setup cancelled."
        exit 0
    fi
    
    check_docker
    check_ports
    setup_persistent_data
    start_services
    wait_for_services
    display_info
}

# Run main function
main "$@" 