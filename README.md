
# JMeter Taurus React Demo with Docker & Jenkins

A comprehensive load testing demo project that combines React frontend, Node.js backend, JMeter test plans, Taurus configurations, and Jenkins CI/CD pipeline for automated performance testing.

## 🏗️ Project Architecture

```
jmeter-taurus-react-demo-docker/
├── frontend/                 # React application
│   ├── Dockerfile
│   ├── package.json
│   ├── public/
│   └── src/
├── backend/                  # Node.js API server
│   ├── Dockerfile
│   ├── package.json
│   └── server.js
├── jmeter/                   # JMeter test plans
│   ├── test-plan.jmx
│   └── localhost3000/
├── taurus/                   # Taurus YAML configurations
│   ├── get-quick-message.yml
│   ├── get-delayed-response.yml
│   ├── post-create-data.yml
│   └── test.yml
├── jenkins-docker/           # Custom Jenkins with Docker
│   └── Dockerfile
├── docker-compose.yml        # Complete stack orchestration
└── README.md
```

## 🚀 Quick Start

### Prerequisites

- **Docker & Docker Compose** (v20.10+)
- **Java 8+** (for JMeter GUI)
- **Node.js 14+** (for local development)

### 1. Clone the Repository

```bash
git clone <repository-url>
cd jmeter-taurus-react-demo-docker
```

### 2. Start the Complete Stack

```bash
# Build and start all services
docker-compose up -d --build

# Check services status
docker-compose ps
```

### 3. Access Applications

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:5000
- **Jenkins**: http://localhost:8080

## 📋 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/message` | Quick response |
| GET | `/api/delayed` | Delayed response (customizable delay) |
| POST | `/api/data` | Accepts JSON body (name, email, message) |
| GET | `/api/search` | Query params: query, limit, page |
| PUT | `/api/user/:id` | Update user by ID (JSON body) |
| DELETE | `/api/user/:id` | Delete user by ID |
| GET | `/api/health` | Health check/status |

## 🧪 Testing Approaches

### A. Manual Testing

#### Frontend Testing
```bash
# Access the React app
open http://localhost:3000

# Test API endpoints through the UI
# - Quick Message: Tests /api/message
# - Delayed Response: Tests /api/delayed with configurable delay
# - Create Data: Tests POST /api/data
# - Search: Tests GET /api/search with parameters
```

#### Backend API Testing
```bash
# Health check
curl http://localhost:5000/api/health

# Quick message
curl http://localhost:5000/api/message

# Delayed response (2 second delay)
curl "http://localhost:5000/api/delayed?delay=2000"

# Create data
curl -X POST http://localhost:5000/api/data \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","message":"Hello World"}'

# Search with parameters
curl "http://localhost:5000/api/search?query=test&limit=10&page=1"
```

### B. JMeter Testing

#### Prerequisites
- **Java 8+** installed
- **JMeter 5.4+** installed

#### Running JMeter Tests

1. **Open JMeter GUI**:
```bash
# Download JMeter if not installed
# https://jmeter.apache.org/download_jmeter.cgi

# Start JMeter GUI
jmeter
```

2. **Load Test Plan**:
   - Open `jmeter/test-plan.jmx` in JMeter
   - Update server/port if needed (default: `localhost:3000` for frontend, `localhost:5000` for backend)

3. **Run Tests**:
   - Click the green "Start" button
   - View results in JMeter's "View Results Tree" and "Summary Report"

4. **Command Line Execution**:
```bash
# Run JMeter test from command line
jmeter -n -t jmeter/test-plan.jmx -l results.jtl -e -o report/

# Run specific test plan
jmeter -n -t jmeter/localhost3000/get-quick-message.jmx -l quick-message-results.jtl
```

### C. Taurus Testing

#### Prerequisites
- **Python 3.7+** installed
- **Taurus** installed: `pip install bzt`

#### Running Taurus Tests Locally

```bash
# Install Taurus
pip install bzt

# Run basic test
bzt taurus/test.yml

# Run specific endpoint tests
bzt taurus/get-quick-message.yml
bzt taurus/get-delayed-response.yml
bzt taurus/post-create-data.yml

# Run with custom parameters
bzt -o execution.0.concurrency=10 -o execution.0.hold-for=60s taurus/get-quick-message.yml
```

#### Running Taurus with Docker

```bash
# One-off test (PowerShell syntax)
docker run --rm -v "${PWD}:/bzt" -w /bzt blazemeter/taurus bzt taurus/get-quick-message.yml

# Linux/Mac syntax
docker run --rm -v "$(pwd):/bzt" -w /bzt blazemeter/taurus bzt taurus/get-quick-message.yml

# Run with network access to the application
docker run --rm \
  --network jmeter-taurus-react-demo-docker_default \
  -v "$(pwd):/bzt" \
  -w /bzt \
  blazemeter/taurus bzt taurus/get-quick-message.yml
```

### D. Jenkins Pipeline Testing

#### Initial Setup

1. **Access Jenkins**:
   - Open http://localhost:8080
   - Get initial admin password: `docker-compose exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword`

2. **Install Required Plugins**:
   - Docker Pipeline
   - JUnit
   - Parameterized Trigger

3. **Configure Jenkins**:
   - Go to "Manage Jenkins" > "Configure System"
   - Ensure Docker is accessible from Jenkins

#### Creating Parameterized Build

1. **Create New Job**:
   - Click "New Item"
   - Select "Freestyle project"
   - Name: `taurus-tests-freestyle-parameterized`

2. **Configure Parameters**:
   - Check "This project is parameterized"
   - Add parameters:
     - **Choice Parameter**: `TAURUS_YAML_FILE`
       - Choices: `get-quick-message.yml`, `get-delayed-response.yml`, `post-create-data.yml`, `test.yml`
     - **Number Parameter**: `CONCURRENT_USERS` (Default: 5)
     - **Number Parameter**: `RAMP_UP_TIME` (Default: 5)
     - **Number Parameter**: `HOLD_FOR_TIME` (Default: 30)
     - **String Parameter**: `TARGET_URL` (Default: http://frontend/api/message)

3. **Add Build Step**:
   - Click "Add build step" > "Execute shell"
   - Copy the script from `jenkins-parameterized-script-short.sh`

4. **Add Post-Build Actions**:
   - "Archive the artifacts": `taurus-result/**/*`
   - "Publish JUnit test result report": `taurus-result/*.xml`

#### Running Jenkins Tests

1. **Manual Execution**:
   - Go to the job page
   - Click "Build with Parameters"
   - Select desired parameters
   - Click "Build"

2. **Scheduled Execution**:
   - Configure "Build Triggers" > "Build periodically"
   - Example: `H/15 * * * *` (every 15 minutes)

3. **Pipeline Integration**:
   - Use "Parameterized Trigger" to call from other jobs
   - Integrate with Git webhooks for automatic testing

## 🔧 Local Development Setup

### Frontend Development

```bash
# Navigate to frontend directory
cd frontend

# Install dependencies
npm install

# Start development server
npm start

# Build for production
npm run build
```

### Backend Development

```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Start development server
npm start

# Run with nodemon for auto-reload
npm install -g nodemon
nodemon server.js
```

### Database Setup (if needed)

```bash
# The current setup uses in-memory storage
# For persistent storage, add MongoDB or PostgreSQL to docker-compose.yml
```

## 🐳 Docker Commands

### Individual Services

```bash
# Start only frontend
docker-compose up frontend

# Start only backend
docker-compose up backend

# Start only Jenkins
docker-compose up jenkins

# Start only Taurus
docker-compose up taurus
```

### Development Commands

```bash
# View logs
docker-compose logs -f [service-name]

# Rebuild specific service
docker-compose build [service-name]

# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# Clean up everything
docker-compose down -v --rmi all
```

### Custom Taurus Testing

```bash
# Run Taurus with custom configuration
docker run --rm \
  --network jmeter-taurus-react-demo-docker_default \
  -v "$(pwd)/taurus:/bzt/taurus" \
  -w /bzt \
  blazemeter/taurus bzt taurus/get-quick-message.yml

# Run with environment variables
docker run --rm \
  --network jmeter-taurus-react-demo-docker_default \
  -e CONCURRENT_USERS=10 \
  -e HOLD_FOR_TIME=60 \
  -v "$(pwd):/bzt" \
  -w /bzt \
  blazemeter/taurus bzt taurus/test.yml
```

## 📊 Test Results & Reports

### JMeter Results
- **Location**: Generated in JMeter GUI or specified output directory
- **Format**: `.jtl` files, HTML reports
- **View**: JMeter's "View Results Tree" and "Summary Report"

### Taurus Results
- **Location**: `taurus-result/` directory
- **Format**: JUnit XML, console output, BlazeMeter reports
- **Files**: `taurus-report.xml`, console logs, performance metrics

### Jenkins Results
- **Location**: Jenkins job workspace
- **Format**: Archived artifacts, JUnit reports
- **Access**: Jenkins job page > "Build History" > "Console Output"

## 🔍 Troubleshooting

### Common Issues

1. **Port Conflicts**:
```bash
# Check if ports are in use
netstat -tulpn | grep :3000
netstat -tulpn | grep :5000
netstat -tulpn | grep :8080

# Change ports in docker-compose.yml if needed
```

2. **Docker Permission Issues**:
```bash
# Add user to docker group
sudo usermod -aG docker $USER
# Logout and login again
```

3. **Jenkins Docker Access**:
```bash
# Ensure Jenkins can access Docker
docker-compose exec jenkins docker ps

# If not working, check Docker socket permissions
ls -la /var/run/docker.sock
```

4. **Taurus Network Issues**:
```bash
# Check if Taurus can reach the application
docker-compose exec taurus ping frontend
docker-compose exec taurus ping backend
```

### Performance Tuning

1. **Increase Docker Resources**:
   - Allocate more CPU and memory to Docker
   - Increase Docker daemon limits

2. **Optimize Test Parameters**:
   - Start with low concurrency (1-5 users)
   - Gradually increase load
   - Monitor system resources

3. **Network Optimization**:
   - Use host networking for better performance
   - Consider using `--network host` for Taurus tests

## 📈 Monitoring & Metrics

### Application Metrics
- **Response Times**: Available in Taurus and JMeter reports
- **Throughput**: Requests per second
- **Error Rates**: Failed requests percentage
- **Resource Usage**: CPU, memory, network

### Jenkins Metrics
- **Build Success Rate**: Job completion statistics
- **Test Duration**: Time taken for each test run
- **Artifact Size**: Generated report sizes
- **Parameter Usage**: Most commonly used test configurations

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For issues and questions:
1. Check the troubleshooting section
2. Review Jenkins console logs
3. Check Docker container logs
4. Open an issue in the repository

---

**Happy Load Testing! 🚀**
