
# JMeter Taurus React Demo - Local Testing

A comprehensive load testing demo project that combines React frontend, Node.js backend, JMeter test plans, and Taurus configurations for performance testing on your local machine.

## 🏗️ Project Architecture

```
jmeter-taurus-react-demo/
├── frontend/                 # React application
│   ├── package.json
│   ├── public/
│   └── src/
├── backend/                  # Node.js API server
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
├── run-jmeter-tests.bat/.sh  # JMeter test runners
├── run-taurus-tests.bat/.sh  # Taurus test runners
├── move-taurus-results.bat/.sh  # Taurus results organizer
├── setup-local-environment.md # Setup guide
├── quick-start-commands.md   # Quick reference
└── README.md
```

## 🚀 Quick Start

### Prerequisites

- **Java 8+** (for JMeter)
- **Node.js 14+** (for application)
- **Python 3.7+** (for Taurus)
- **JMeter 5.4+** installed
- **Taurus** installed: `pip install bzt`

### 1. Clone the Repository

```bash
git clone <repository-url>
cd jmeter-taurus-react-demo
```

### 2. Start the Application

```bash
# Start backend
cd backend && npm install && npm start

# Start frontend (in new terminal)
cd frontend && npm install && npm start
```

### 3. Access Applications

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:5000

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

**Option 1: Using the provided script**
```bash
# Windows
run-jmeter-tests.bat

# Linux/Mac
chmod +x run-jmeter-tests.sh
./run-jmeter-tests.sh
```

**Option 2: Manual execution**
```bash
# Run JMeter test from command line
jmeter -n -t jmeter/test-plan.jmx -l results.jtl -e -o report/

# Run specific test plan
jmeter -n -t jmeter/localhost3000/get-quick-message.jmx -l quick-message-results.jtl

# Run with GUI (for development)
jmeter -t jmeter/localhost3000/get-quick-message.jmx
```

### C. Taurus Testing

#### Prerequisites
- **Python 3.7+** installed
- **Taurus** installed: `pip install bzt`

#### BlazeMeter Configuration
To enable cloud reporting and avoid the "No BlazeMeter API key provided" warning, create a `.bzt-rc` file in your home directory with your BlazeMeter credentials:

**Windows**: `C:\Users\<username>\.bzt-rc`
**Linux/Mac**: `~/.bzt-rc`

```yaml
modules:
  blazemeter:
    token: "your_blazemeter_token:your_blazemeter_secret"
```

**Example configuration:**
```yaml
modules:
  blazemeter:
    token: "1ff44b3357ab29df65126dc1:c0d0769c26ea13767b2ae9f8d63d3806520dd79eeb75ea743e81bcb091be3ddf5d03e559"
```

#### Running Taurus Tests

**Option 1: Using the provided script**
```bash
# Windows
run-taurus-tests.bat

# Linux/Mac
chmod +x run-taurus-tests.sh
./run-taurus-tests.sh
```

**Note**: The scripts automatically organize test results using `move-taurus-results.bat/.sh`

**Option 2: Manual execution**
```bash
# Run basic test
bzt taurus/test.yml

# Run specific endpoint tests
bzt taurus/get-quick-message.yml
bzt taurus/get-delayed-response.yml
bzt taurus/post-create-data.yml

# Run with custom parameters
bzt -o execution.0.concurrency=10 -o execution.0.hold-for=60s taurus/get-quick-message.yml
```

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

## 📊 Test Results & Reports

### JMeter Results
- **Location**: `jmeter-results/` directory
- **Format**: `.jtl` files, HTML reports
- **Files**: `results_YYYYMMDD_HHMMSS.jtl`, `html-report_YYYYMMDD_HHMMSS/`

### Taurus Results
- **Location**: `taurus-result/` directory (JUnit XML reports)
- **Timestamped Folders**: Created at root level (e.g., `2025-08-03_18-23-43.550097/`)
- **Format**: JUnit XML, console output, BlazeMeter reports
- **Files**: `taurus-report.xml`, console logs, performance metrics, KPI data

#### Organizing Taurus Results
Taurus creates timestamped folders at the root level. Use the provided scripts to organize them:

```bash
# Windows
move-taurus-results.bat

# Linux/Mac
chmod +x move-taurus-results.sh
./move-taurus-results.sh
```

This moves all timestamped Taurus result folders into the `taurus-test-results/` directory for better organization.

## 🔍 Troubleshooting

### Common Issues

1. **Port Conflicts**:
```bash
# Check if ports are in use
netstat -tulpn | grep :3000
netstat -tulpn | grep :5000

# Change ports in package.json if needed
```

2. **JMeter not found**:
```bash
# Ensure JMeter is installed and in PATH
jmeter -v

# Set JMETER_HOME environment variable
export JMETER_HOME=/path/to/jmeter
```

3. **Taurus not found**:
```bash
# Install Taurus
pip install bzt

# Verify installation
bzt --version
```

4. **BlazeMeter API key warning**:
```bash
# Create .bzt-rc file in your home directory
# Windows: C:\Users\<username>\.bzt-rc
# Linux/Mac: ~/.bzt-rc

modules:
  blazemeter:
    token: "your_token:your_secret"
```

5. **Java not found**:
```bash
# Install Java 8+ and add to PATH
java -version

# Set JAVA_HOME environment variable
export JAVA_HOME=/path/to/java
```

### Performance Tuning

1. **Optimize Test Parameters**:
   - Start with low concurrency (1-5 users)
   - Gradually increase load
   - Monitor system resources

2. **System Resources**:
   - Ensure sufficient RAM for JMeter
   - Monitor CPU usage during tests
   - Check network connectivity

## 📈 Monitoring & Metrics

### Application Metrics
- **Response Times**: Available in Taurus and JMeter reports
- **Throughput**: Requests per second
- **Error Rates**: Failed requests percentage
- **Resource Usage**: CPU, memory, network

### Test Metrics
- **Test Duration**: Time taken for each test run
- **Artifact Size**: Generated report sizes
- **Success Rate**: Test completion statistics

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
2. Review test logs and reports
3. Check application logs
4. Open an issue in the repository

## 📚 Additional Resources

- **JMeter Documentation**: https://jmeter.apache.org/usermanual/
- **Taurus Documentation**: https://gettaurus.org/
- **React Documentation**: https://reactjs.org/docs/
- **Node.js Documentation**: https://nodejs.org/docs/

---

**Happy Load Testing! 🚀**
