# Jenkins Setup Summary

## 🎯 Overview

This Jenkins setup provides a complete CI/CD pipeline for running Taurus tests on the JMeter Taurus React Demo project. It includes Docker-based Jenkins with persistent storage and a freestyle project configuration.

## 📁 Files Created

```
jenkins/
├── docker-compose.yml              # Jenkins Docker setup with volume storage
├── Jenkinsfile                     # Pipeline definition (alternative to freestyle)
├── freestyle-build-script.sh       # Single script for freestyle project
├── start-jenkins.sh               # Start Jenkins container
├── stop-jenkins.sh                # Stop Jenkins container
├── README.md                      # Detailed setup guide
└── JENKINS_SETUP_SUMMARY.md       # This summary
```

## 🚀 Quick Start (3 Steps)

### 1. Build and Start Jenkins
```bash
# Navigate to jenkins directory
cd jenkins

# Build custom Jenkins image and start container with name jenkins-taurus-demo
docker-compose build
docker-compose up -d

# Or use the start script (includes build)
chmod +x jenkins/start-jenkins.sh
./jenkins/start-jenkins.sh
```

### 2. Access Jenkins
- **URL**: http://localhost:8080
- **Get Password**: `docker exec jenkins-taurus-demo cat /var/jenkins_home/secrets/initialAdminPassword`

### 3. Create Freestyle Project
Follow the detailed guide in `jenkins/README.md`

## 🔧 Key Features

### ✅ What's Included
- **Custom Docker-based Jenkins** with pre-installed dependencies
- **Persistent volume storage** for Jenkins data
- **Freestyle project** configuration with build parameters
- **Automated application startup** (backend + frontend)
- **Taurus test execution** with configurable YAML files
- **BlazeMeter integration** with automatic .bzt-rc creation
- **Result organization** using move-taurus-results scripts
- **Artifact archiving** for test results and logs
- **Process cleanup** to prevent resource leaks

### 📋 Build Parameters
- **TAURUS_CONFIG**: Choose which Taurus YAML file to run
- **GIT_BRANCH**: Specify Git branch to clone
- **GIT_REPO**: Repository URL

### 🎯 Supported Taurus Configs
- `taurus/get-quick-message.yml`
- `taurus/get-delayed-response.yml`
- `taurus/post-create-data.yml`
- `taurus/test.yml`

## 📊 Results & Reports

### Local Results
- **JUnit XML**: `taurus-result/taurus-report.xml`
- **Organized Results**: `taurus-test-results/` directory
- **Application Logs**: `backend.log`, `frontend.log`

### BlazeMeter Reports
- **Project**: `jmeter-taurus-blazemeter-react-demo-project`
- **Dashboard**: https://a.blazemeter.com/app/#/projects

## 🔄 Usage Options

### Option 1: Freestyle Project (Recommended)
1. Use `freestyle-build-script.sh` as single build step
2. Set build parameters for Taurus config selection
3. Configure post-build actions for artifact archiving

### Option 2: Pipeline
1. Use `Jenkinsfile` for declarative pipeline
2. More structured approach with stages
3. Better visualization of build progress

### Option 3: Manual Execution
```bash
# Set environment variable and run
export TAURUS_CONFIG=taurus/get-quick-message.yml
./jenkins/freestyle-build-script.sh
```

## 🛠️ Prerequisites

### Jenkins Node Requirements
- **Java 8+** (included in Jenkins LTS image)
- **Node.js 14+** (pre-installed in custom image)
- **Python 3.7+** (pre-installed in custom image)
- **Taurus**: `pip install bzt` (pre-installed in custom image)
- **Git** (pre-installed in custom image)
- **curl** (pre-installed in custom image)
- **Docker** (pre-installed in custom image)

### Docker Requirements
- **Docker**
- **Docker Compose**

## 🔧 Configuration

### BlazeMeter Token
The BlazeMeter token is automatically configured in the build script:
```yaml
modules:
  blazemeter:
    token: "BLAZEMETER_API_KEY:BLAZEMETER_SECRET_KEY"
```

### Ports
- **Backend**: 5000
- **Frontend**: 3000
- **Jenkins**: 8080

## 🚨 Troubleshooting

### Common Issues
1. **Port conflicts**: Check if ports 3000, 5000, 8080 are available
2. **Dependencies missing**: Install Node.js, Python, Taurus on Jenkins node
3. **Git credentials**: Add credentials in Jenkins Credentials Manager

### Useful Commands
```bash
# View Jenkins logs
docker-compose logs -f

# Access Jenkins container
docker exec -it jenkins-taurus-demo bash

# Stop Jenkins
./jenkins/stop-jenkins.sh
```

## 📈 Next Steps

1. **Customize**: Update Git repository URL and branch
2. **Scale**: Add more Taurus configurations
3. **Integrate**: Set up webhooks for automatic builds
4. **Monitor**: Configure email notifications
5. **Secure**: Add proper authentication and authorization

---

**Ready to test! 🚀** 