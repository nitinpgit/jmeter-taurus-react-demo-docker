
# JMeter Taurus React Demo with Jenkins

This project demonstrates a complete CI/CD pipeline with JMeter performance testing using Taurus, a React frontend, and a Node.js backend, all orchestrated with Jenkins in Docker containers.

## Features

- **Jenkins CI/CD Server** with persistent data storage
- **JMeter Performance Testing** with Taurus automation
- **React Frontend** application
- **Node.js Backend** API
- **Docker Compose** orchestration

## Quick Start

### Option 1: Using the provided script (Recommended)

```bash
# Make the script executable (Linux/Mac)
chmod +x start-jenkins.sh

# Start all services
./start-jenkins.sh
```

### Option 2: Manual Docker Compose

```bash
# Build and start all containers
docker-compose up -d --build

# View logs
docker-compose logs -f jenkins
```

## Accessing Services

- **Jenkins**: http://localhost:8080
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:5000

## Initial Jenkins Setup

1. Access Jenkins at http://localhost:8080
2. Get the initial admin password:
   ```bash
   docker-compose logs jenkins | grep -A 1 'initialAdminPassword'
   ```
3. Follow the Jenkins setup wizard
4. Install recommended plugins

## Persistent Data Storage

The following data is persisted between container restarts:

- **Jenkins Home** (`jenkins_home` volume): All Jenkins configurations, jobs, and plugins
- **Jenkins Workspace** (`jenkins_workspace` volume): Test files and workspace data
- **JMeter Data** (`jmeter_data` volume): JMeter installations and configurations
- **Taurus Data** (`taurus_data` volume): Taurus installations and configurations

## Container Management

```bash
# Stop all services (data preserved)
docker-compose down

# Stop and remove all data
docker-compose down -v

# Restart services
docker-compose restart

# View running containers
docker-compose ps

# View logs
docker-compose logs -f [service_name]
```

## Project Structure

```
├── backend/                 # Node.js API server
├── frontend/               # React application
├── jmeter/                 # JMeter test plans
├── taurus/                 # Taurus configuration files
├── docker-compose.yml      # Docker orchestration
├── dockerfile              # Jenkins container definition
├── start-jenkins.sh        # Quick start script
└── README.md              # This file
```

## JMeter Test Plans

The `jmeter/` directory contains various test plans:
- Health check tests
- Performance tests
- API endpoint tests
- Data creation and manipulation tests

## Taurus Configuration

The `taurus/` directory contains Taurus YAML configurations for:
- Quick message tests
- Delayed response tests
- Data creation tests
- Comprehensive test suites

## Troubleshooting

### Jenkins won't start
- Check if port 8080 is available
- View logs: `docker-compose logs jenkins`
- Ensure Docker has enough resources allocated

### Data not persisting
- Verify volumes are created: `docker volume ls`
- Check volume mounts: `docker-compose exec jenkins ls -la /var/jenkins_home`

### JMeter/Taurus not working
- Verify installations: `docker-compose exec jenkins which jmeter`
- Check PATH: `docker-compose exec jenkins echo $PATH`

## Development

To modify the setup:

1. Edit `dockerfile` for Jenkins container changes
2. Edit `docker-compose.yml` for service configuration
3. Rebuild: `docker-compose up -d --build`

## License

This project is for educational and demonstration purposes.
