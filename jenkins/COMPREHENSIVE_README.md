# 🚀 Jenkins + Taurus + React + Node.js Complete Setup Guide

## 📋 Table of Contents

1. [Overview](#-overview)
2. [Quick Start](#-quick-start)
3. [Prerequisites](#-prerequisites)
4. [Environment Setup](#-environment-setup)
5. [Jenkins Installation](#-jenkins-installation)
6. [Project Configuration](#-project-configuration)
7. [Build Scripts](#-build-scripts)
8. [Troubleshooting](#-troubleshooting)
9. [Advanced Configuration](#-advanced-configuration)
10. [File Structure](#-file-structure)
11. [Usage Examples](#-usage-examples)
12. [API Reference](#-api-reference)

---

## 🎯 Overview

This comprehensive guide provides everything you need to set up Jenkins with Docker for running Taurus performance tests on a React + Node.js application. The setup includes:

- **Docker-based Jenkins** with persistent volume storage
- **Automated application lifecycle** management (start/stop backend & frontend)
- **Taurus performance testing** with multiple configuration options
- **BlazeMeter integration** for cloud-based reporting
- **Result organization** and artifact archiving
- **Multiple deployment options** (Freestyle, Pipeline, Manual)

### 🎯 Key Features

✅ **Complete Automation**: From code checkout to test execution  
✅ **Multiple Taurus Configs**: Support for various test scenarios  
✅ **BlazeMeter Integration**: Cloud-based test reporting  
✅ **Result Organization**: Automatic timestamped folder management  
✅ **Process Management**: Proper startup/shutdown with health checks  
✅ **Error Handling**: Robust error detection and recovery  
✅ **Artifact Archiving**: Comprehensive result collection  

---

## 🚀 Quick Start

### Step 1: Start Jenkins
```bash
# Make scripts executable
chmod +x jenkins/start-jenkins.sh
chmod +x jenkins/stop-jenkins.sh

# Start Jenkins
./jenkins/start-jenkins.sh
```

### Step 2: Access Jenkins
- **URL**: http://localhost:8080
- **Get initial password**:
  ```bash
  docker exec jenkins-taurus-demo cat /var/jenkins_home/secrets/initialAdminPassword
  ```

### Step 3: Create Project
Follow the detailed setup in [Project Configuration](#-project-configuration)

---

## 🔧 Prerequisites

### System Requirements
- **Docker** and **Docker Compose**
- **Git** for version control
- **Internet connection** for downloading dependencies

### Jenkins Node Requirements
- **Java 8+**
- **Node.js 14+**
- **Python 3.7+**
- **Taurus**: `pip install bzt`
- **curl** for health checks

### Port Requirements
- **Jenkins**: 8080
- **Backend**: 5000
- **Frontend**: 3000

---

## 🛠️ Environment Setup

### Manual Environment Setup (If Needed)

If your Jenkins container doesn't have the required dependencies, follow these steps:

#### 1. Enter Jenkins Container
```bash
docker exec -it jenkins-taurus-demo /bin/bash
```

#### 2. Install Prerequisites
```bash
apt-get update
apt-get install -y curl gnupg build-essential
```

#### 3. Install Node.js and npm
```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs
```

#### 4. Install Python 3 and pip
```bash
apt-get install -y python3 python3-pip python3-venv
```

#### 5. Create Taurus Virtual Environment
```bash
python3 -m venv /var/jenkins_home/taurus-venv
source /var/jenkins_home/taurus-venv/bin/activate
pip install bzt
```

#### 6. Verify Installation
```bash
node -v
npm -v
python3 --version
bzt -v
```

### Automated Environment Setup

Use the complete setup script:
```bash
#!/bin/bash
echo "========================================"
echo "Setting up Jenkins Environment"
echo "========================================"

# Update package list
apt-get update

# Install prerequisites
apt-get install -y curl gnupg build-essential

# Install Node.js and npm
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Install Python 3 and pip
apt-get install -y python3 python3-pip python3-venv

# Create Python virtual environment
python3 -m venv /var/jenkins_home/taurus-venv

# Activate virtual environment
source /var/jenkins_home/taurus-venv/bin/activate

# Install Taurus
pip install bzt

# Verify installations
echo "Node.js version: $(node -v)"
echo "npm version: $(npm -v)"
echo "Python version: $(python3 --version)"
echo "Taurus version: $(bzt -v)"

echo "Environment setup completed!"
```

---

## 🐳 Jenkins Installation

### Docker Compose Setup

The `docker-compose.yml` file provides a complete Jenkins setup:

```yaml
version: '3.8'

services:
  jenkins:
    image: jenkins/jenkins:lts-jdk17
    container_name: jenkins-taurus-demo
    restart: unless-stopped
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - JENKINS_OPTS=--httpPort=8080
    networks:
      - jenkins-network

volumes:
  jenkins_home:
    driver: local

networks:
  jenkins-network:
    driver: bridge
```

### Start/Stop Scripts

#### Start Jenkins
```bash
#!/bin/bash
# jenkins/start-jenkins.sh

echo "🚀 Starting Jenkins with Docker..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker-compose > /dev/null 2>&1; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Create jenkins directory if it doesn't exist
mkdir -p jenkins

# Start Jenkins
cd jenkins
docker-compose up -d

echo "✅ Jenkins is starting..."
echo "🌐 Access Jenkins at: http://localhost:8080"
echo "🔑 Get initial password: docker exec jenkins-taurus-demo cat /var/jenkins_home/secrets/initialAdminPassword"
```

#### Stop Jenkins
```bash
#!/bin/bash
# jenkins/stop-jenkins.sh

echo "🛑 Stopping Jenkins..."

cd jenkins
docker-compose down

echo "✅ Jenkins stopped"
```

---
## 📜 Project Configuration

### Freestyle Project Setup

#### 1. Create New Project
1. Go to Jenkins Dashboard
2. Click **"New Item"**
3. Enter project name: `Taurus-Test-Pipeline`
4. Select **"Freestyle project"**
5. Click **"OK"**

#### 2. General Settings
- **Description**: `Automated Taurus testing pipeline for JMeter Taurus React Demo`
- **Discard old builds**: Keep 10 builds
- **This project is parameterized**: ✓

#### 3. Build Parameters

**Choice Parameter: TAURUS_CONFIG**
- **Name**: `TAURUS_CONFIG`
- **Choices**:
  - `taurus/get-quick-message.yml`
  - `taurus/get-delayed-response.yml`
  - `taurus/post-create-data.yml`
  - `taurus/test.yml`
- **Description**: `Select Taurus configuration file to run`

**String Parameter: GIT_BRANCH**
- **Name**: `GIT_BRANCH`
- **Default Value**: `working/jmeter-taurus-blazemeter-local`
- **Description**: `Git branch to clone`

#### 4. Source Code Management
- **Repository URL**: `https://github.com/your-username/jmeter-taurus-react-demo-docker.git`
- **Branch**: `${GIT_BRANCH}`
- **Credentials**: Add your Git credentials if needed

#### 5. Build Triggers
- **Poll SCM**: `H/15 * * * *` (every 15 minutes)
- Or **Build periodically**: `H/5 * * * *` (every 5 minutes)

#### 6. Build Environment
- **Delete workspace before build starts**: ✓
- **Add timestamps to the Console Output**: ✓

#### 7. Build Steps

**Option A: Use Comprehensive Script (Recommended)**
```bash
# Copy comprehensive-build-script.sh to workspace and run
chmod +x comprehensive-build-script.sh
./comprehensive-build-script.sh
```

**Option B: Individual Steps**
```bash
# Step 1: Setup Environment
cat > ~/.bzt-rc << EOF
modules:
  blazemeter:
    token: "1f57f44b33ab29df65126dc1:c0d07b2ae9f8d63d3806520dd79eeb69c26ea1376775ea743e81bcb091be3ddf5d03e559"
EOF

# Step 2: Install Dependencies
cd backend && npm install
cd ../frontend && npm install

# Step 3: Start Applications
cd backend
nohup npm start > ../backend.log 2>&1 &
echo $! > backend.pid
cd ..

cd frontend
nohup npm start > ../frontend.log 2>&1 &
echo $! > frontend.pid
cd ..

# Step 4: Run Taurus Tests
. /var/jenkins_home/taurus-venv/bin/activate
mkdir -p taurus-test-results
bzt $TAURUS_CONFIG

# Step 5: Organize Results
if [ -f move-taurus-results.sh ]; then
    chmod +x move-taurus-results.sh
    ./move-taurus-results.sh
fi

# Step 6: Cleanup
if [ -f backend/backend.pid ]; then
    kill $(cat backend/backend.pid) 2>/dev/null || true
    rm -f backend/backend.pid
fi

if [ -f frontend/frontend.pid ]; then
    kill $(cat frontend/frontend.pid) 2>/dev/null || true
    rm -f frontend/frontend.pid
fi
```

#### 8. Post-build Actions

**Archive the artifacts**
- **Files to archive**: `taurus-test-results/**/*, *.log, taurus-result/**/*`
- **Allow empty archive**: ✓

**Publish JUnit test result report**
- **Test report XMLs**: `taurus-result/taurus-report.xml`

### Pipeline Setup (Alternative)

Use the provided `Jenkinsfile` for a declarative pipeline approach:

```groovy
pipeline {
    agent any
    
    parameters {
        choice(
            name: 'TAURUS_CONFIG',
            choices: [
                'taurus/get-quick-message.yml',
                'taurus/get-delayed-response.yml',
                'taurus/post-create-data.yml',
                'taurus/test.yml'
            ],
            description: 'Select Taurus configuration file to run'
        )
        string(
            name: 'GIT_BRANCH',
            defaultValue: 'working/jmeter-taurus-blazemeter-local',
            description: 'Git branch to clone'
        )
        string(
            name: 'GIT_REPO',
            defaultValue: 'https://github.com/nitinpgit/jmeter-taurus-react-demo-docker.git',
            description: 'Git repository URL'
        )
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: "${params.GIT_BRANCH}"]], userRemoteConfigs: [[url: "${params.GIT_REPO}"]]])
            }
        }
        
        stage('Setup Environment') {
            steps {
                script {
                    // Create .bzt-rc file
                    writeFile file: '.bzt-rc', text: '''
modules:
  blazemeter:
    token: "1f57f44b33ab29df65126dc1:c0d07b2ae9f8d63d3806520dd79eeb69c26ea1376775ea743e81bcb091be3ddf5d03e559"
'''
                }
            }
        }
        
        stage('Start Backend') {
            steps {
                dir('backend') {
                    sh 'npm install'
                    sh 'nohup npm start > ../backend.log 2>&1 & echo $! > backend.pid'
                }
                sleep 10
            }
        }
        
        stage('Start Frontend') {
            steps {
                dir('frontend') {
                    sh 'npm install'
                    sh 'nohup npm start > ../frontend.log 2>&1 & echo $! > frontend.pid'
                }
                sleep 15
            }
        }
        
        stage('Run Taurus Tests') {
            steps {
                script {
                    sh '''
                        . /var/jenkins_home/taurus-venv/bin/activate
                        mkdir -p taurus-test-results
                        bzt ${TAURUS_CONFIG}
                    '''
                }
            }
        }
        
        stage('Stop Applications') {
            steps {
                script {
                    sh '''
                        if [ -f backend/backend.pid ]; then
                            kill $(cat backend/backend.pid) 2>/dev/null || true
                            rm -f backend/backend.pid
                        fi
                        if [ -f frontend/frontend.pid ]; then
                            kill $(cat frontend/frontend.pid) 2>/dev/null || true
                            rm -f frontend/frontend.pid
                        fi
                    '''
                }
            }
        }
    }
    
    post {
        always {
            archiveArtifacts artifacts: 'taurus-test-results/**/*, *.log, taurus-result/**/*', allowEmptyArchive: true
            publishTestResults testResultsPattern: 'taurus-result/taurus-report.xml'
        }
    }
}
```

---

## 📜 Build Scripts

### 1. Comprehensive Build Script

The `comprehensive-build-script.sh` provides a complete solution:

**Features:**
- ✅ Environment validation
- ✅ Dependency installation
- ✅ Application lifecycle management
- ✅ Health checks
- ✅ Error handling
- ✅ Automatic cleanup
- ✅ Result organization

**Usage:**
```bash
chmod +x comprehensive-build-script.sh
./comprehensive-build-script.sh
```

### 2. Enhanced Taurus Build Step

The `enhanced-taurus-build-step.sh` focuses on Taurus execution:

**Features:**
- ✅ Parameter validation
- ✅ Virtual environment activation
- ✅ Taurus installation verification
- ✅ Result organization
- ✅ Exit code preservation

**Usage:**
```bash
chmod +x enhanced-taurus-build-step.sh
./enhanced-taurus-build-step.sh
```

### 3. Freestyle Build Script

The `freestyle-build-script.sh` is designed for Jenkins freestyle projects:

**Features:**
- ✅ Single script solution
- ✅ Environment setup
- ✅ Application management
- ✅ Taurus execution
- ✅ Cleanup procedures

**Usage:**
```bash
chmod +x freestyle-build-script.sh
./freestyle-build-script.sh
```

---

## 🚨 Troubleshooting

### Common Issues and Solutions

#### 1. Virtual Environment Not Found
**Error**: `No such file or directory: /var/jenkins_home/taurus-venv/bin/activate`

**Solution**:
```bash
# Enter Jenkins container
docker exec -u 0 -it jenkins-taurus-demo bash

# Create virtual environment
python3 -m venv /var/jenkins_home/taurus-venv
source /var/jenkins_home/taurus-venv/bin/activate
pip install bzt
```

#### 2. Taurus Not Found
**Error**: `bzt: command not found`

**Solution**:
```bash
# Activate virtual environment
source /var/jenkins_home/taurus-venv/bin/activate

# Install Taurus
pip install bzt
```

#### 3. Node.js Not Found
**Error**: `npm: command not found`

**Solution**:
```bash
# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs
```

#### 4. Port Conflicts
**Error**: `EADDRINUSE` or port already in use

**Solution**:
```bash
# Check port usage
netstat -tulpn | grep :3000
netstat -tulpn | grep :5000
netstat -tulpn | grep :8080

# Kill processes using ports
kill -9 <PID>
```

#### 5. Permission Denied
**Error**: `Permission denied` when running scripts

**Solution**:
```bash
# Make scripts executable
chmod +x *.sh

# Run as root if needed
sudo ./script.sh
```

#### 6. Git Credentials
**Error**: Git authentication failed

**Solution**:
1. Go to Jenkins → Manage Jenkins → Credentials
2. Add new credentials (SSH key or username/password)
3. Configure credentials in project settings

#### 7. BlazeMeter API Issues
**Error**: `WARNING: No BlazeMeter API key provided`

**Solution**:
```bash
# Create .bzt-rc file
cat > ~/.bzt-rc << EOF
modules:
  blazemeter:
    token: "your-blazemeter-token-here"
EOF
```

### Debugging Commands

#### View Jenkins Logs
```bash
# View Docker Compose logs
docker-compose logs -f

# View Jenkins container logs
docker logs jenkins-taurus-demo

# Access Jenkins container
docker exec -it jenkins-taurus-demo /bin/bash
```

#### Check Application Status
```bash
# Check if applications are running
ps aux | grep node
ps aux | grep npm

# Check port usage
netstat -tulpn | grep -E ':(3000|5000|8080)'

# Test application endpoints
curl http://localhost:5000/api/message
curl http://localhost:3000
```

#### Verify Environment
```bash
# Check Node.js
node -v
npm -v

# Check Python
python3 --version
pip3 --version

# Check Taurus
source /var/jenkins_home/taurus-venv/bin/activate
bzt -v
```

---

## 🔧 Advanced Configuration

### Custom Dockerfile

For persistent environment setup, create a custom Dockerfile:

```dockerfile
FROM jenkins/jenkins:lts-jdk17

USER root

# Install prerequisites
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    build-essential \
    python3 \
    python3-pip \
    python3-venv

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Create Taurus virtual environment
RUN python3 -m venv /var/jenkins_home/taurus-venv && \
    /var/jenkins_home/taurus-venv/bin/pip install bzt

USER jenkins
```

### Environment Variables

Set these environment variables in your Jenkins container:

```bash
# Taurus configuration
export TAURUS_CONFIG=taurus/get-quick-message.yml

# BlazeMeter configuration
export BLAZEMETER_TOKEN="your-token-here"

# Application ports
export BACKEND_PORT=5000
export FRONTEND_PORT=3000

# Git configuration
export GIT_BRANCH=working/jmeter-taurus-blazemeter-local
export GIT_REPO=https://github.com/your-username/jmeter-taurus-react-demo-docker.git
```

### Webhook Configuration

For automatic builds on Git changes:

1. **GitHub Webhook**:
   - URL: `http://your-jenkins-url/github-webhook/`
   - Events: Push events
   - Content type: application/json

2. **GitLab Webhook**:
   - URL: `http://your-jenkins-url/project/your-project-name`
   - Events: Push events
   - Secret token: (optional)

### Email Notifications

Configure email notifications in Jenkins:

1. Go to **Manage Jenkins** → **Configure System**
2. Set up **Extended E-mail Notification**
3. Configure SMTP settings
4. Add post-build action to your project

### Security Configuration

#### Authentication
1. **Install Security Plugin**: Go to **Manage Jenkins** → **Manage Plugins**
2. **Configure Security**: Go to **Manage Jenkins** → **Configure Global Security**
3. **Enable Security**: Check "Enable security"
4. **Add Users**: Create admin and regular users

#### Authorization
1. **Role-based Strategy**: Install "Role-based Authorization Strategy" plugin
2. **Configure Roles**: Define roles for different user types
3. **Assign Roles**: Assign roles to users

---

## 📁 File Structure

```
jenkins/
├── docker-compose.yml                    # Jenkins Docker setup
├── Jenkinsfile                           # Pipeline definition
├── comprehensive-build-script.sh         # Complete build automation
├── enhanced-taurus-build-step.sh         # Enhanced Taurus execution
├── freestyle-build-script.sh             # Freestyle project script
├── start-jenkins.sh                      # Start Jenkins container
├── stop-jenkins.sh                       # Stop Jenkins container
├── README.md                             # Basic setup guide
├── README-1.md                           # Environment setup guide
├── JENKINS_SETUP_SUMMARY.md              # Quick reference
└── COMPREHENSIVE_README.md               # This complete guide
```

### File Descriptions

| File | Purpose | Usage |
|------|---------|-------|
| `docker-compose.yml` | Jenkins container configuration | Start Jenkins with Docker |
| `Jenkinsfile` | Declarative pipeline definition | Alternative to freestyle project |
| `comprehensive-build-script.sh` | Complete build automation | Single script for all operations |
| `enhanced-taurus-build-step.sh` | Enhanced Taurus execution | Focused Taurus testing |
| `freestyle-build-script.sh` | Freestyle project script | Jenkins freestyle build step |
| `start-jenkins.sh` | Start Jenkins container | Quick Jenkins startup |
| `stop-jenkins.sh` | Stop Jenkins container | Clean Jenkins shutdown |
| `README.md` | Basic setup guide | Quick start instructions |
| `README-1.md` | Environment setup guide | Manual environment configuration |
| `JENKINS_SETUP_SUMMARY.md` | Quick reference | Overview and summary |
| `COMPREHENSIVE_README.md` | Complete guide | This comprehensive documentation |

---

## 🚀 Usage Examples

### Example 1: Quick Start with Freestyle Project

```bash
# 1. Start Jenkins
./jenkins/start-jenkins.sh

# 2. Get initial password
docker exec jenkins-taurus-demo cat /var/jenkins_home/secrets/initialAdminPassword

# 3. Access Jenkins at http://localhost:8080

# 4. Create freestyle project with comprehensive script
# 5. Set build parameter TAURUS_CONFIG=taurus/get-quick-message.yml
# 6. Run build
```

### Example 2: Pipeline Approach

```bash
# 1. Start Jenkins
./jenkins/start-jenkins.sh

# 2. Create pipeline project
# 3. Point to Jenkinsfile in repository
# 4. Set build parameters
# 5. Run pipeline
```

### Example 3: Manual Execution

```bash
# 1. Clone repository
git clone https://github.com/your-username/jmeter-taurus-react-docker.git
cd jmeter-taurus-react-docker

# 2. Set environment variable
export TAURUS_CONFIG=taurus/get-quick-message.yml

# 3. Run comprehensive script
chmod +x jenkins/comprehensive-build-script.sh
./jenkins/comprehensive-build-script.sh
```

### Example 4: Custom Taurus Configuration

```yaml
# taurus/custom-test.yml
execution:
  - concurrency: 10
    ramp-up: 1m
    hold-for: 5m
    scenario: quick-test

scenarios:
  quick-test:
    requests:
      - http://localhost:5000/api/message
      - http://localhost:5000/api/health

reporting:
  - module: blazemeter
    project: "my-custom-project"
    report-name: "Custom Test Run"
    test: "custom-test-suite"
  - module: junit-xml
    filename: ./taurus-result/custom-report.xml

settings:
  artifacts-dir: ./taurus-result
```

---

## 📊 API Reference

### Taurus Configuration Parameters

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `execution` | Object | Test execution configuration | `concurrency: 10, ramp-up: 1m` |
| `scenarios` | Object | Test scenarios definition | `requests: [http://...]` |
| `reporting` | Array | Reporting modules | `blazemeter, junit-xml` |
| `settings` | Object | Global settings | `artifacts-dir: ./results` |

### Jenkins Build Parameters

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `TAURUS_CONFIG` | Choice | Taurus configuration file | `taurus/get-quick-message.yml` |
| `GIT_BRANCH` | String | Git branch to clone | `working/jmeter-taurus-blazemeter-local` |
| `GIT_REPO` | String | Git repository URL | Repository URL |

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `JENKINS_OPTS` | Jenkins startup options | `--httpPort=8080` |
| `TAURUS_CONFIG` | Taurus configuration file | None (required) |
| `BLAZEMETER_TOKEN` | BlazeMeter API token | None (required) |

### Port Configuration

| Service | Port | Description |
|---------|------|-------------|
| Jenkins | 8080 | Jenkins web interface |
| Backend | 5000 | Node.js API server |
| Frontend | 3000 | React development server |

### File Paths

| Path | Description |
|------|-------------|
| `/var/jenkins_home` | Jenkins home directory |
| `/var/jenkins_home/taurus-venv` | Taurus virtual environment |
| `/var/jenkins_home/workspace/[project]` | Project workspace |
| `./taurus-result` | Taurus results directory |
| `./taurus-test-results` | Organized test results |

---

## 🎉 Conclusion

This comprehensive guide provides everything you need to set up and run Jenkins with Taurus for performance testing your React + Node.js application. The setup includes:

- ✅ **Complete automation** from code checkout to test execution
- ✅ **Multiple deployment options** (Freestyle, Pipeline, Manual)
- ✅ **Robust error handling** and troubleshooting
- ✅ **Comprehensive documentation** and examples
- ✅ **Advanced configuration** options
- ✅ **Security considerations** and best practices

### Next Steps

1. **Start with Quick Start** section for immediate setup
2. **Choose your preferred approach** (Freestyle or Pipeline)
3. **Customize configuration** for your specific needs
4. **Set up monitoring** and notifications
5. **Scale and optimize** based on your requirements

### Support

For additional support:
- Check the troubleshooting section
- Review the API reference
- Examine the example configurations
- Use the debugging commands provided

---

**Happy Testing! 🚀**

*This comprehensive guide consolidates all information from the existing Jenkins README files into one complete reference document.* 