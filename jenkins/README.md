# Jenkins Freestyle Project Setup

This guide provides step-by-step instructions to set up Jenkins with Docker and create a freestyle project for running Taurus tests on the JMeter Taurus React Demo.

## 🚀 Quick Start

### 1. Start Jenkins with Docker

```bash
# Make scripts executable
chmod +x jenkins/start-jenkins.sh
chmod +x jenkins/stop-jenkins.sh

# Start Jenkins
./jenkins/start-jenkins.sh
```

### 2. Access Jenkins

- **URL**: http://localhost:8080
- **Get initial password**:
  ```bash
  docker exec jenkins-taurus-demo cat /var/jenkins_home/secrets/initialAdminPassword
  ```

### 3. Install Required Plugins

After initial setup, install these plugins:
- **Git plugin** (usually pre-installed)
- **Pipeline** (usually pre-installed)
- **Credentials Binding** (usually pre-installed)

## 🔧 Jenkins Freestyle Project Setup

### Step 1: Create New Freestyle Project

1. Go to Jenkins Dashboard
2. Click **"New Item"**
3. Enter project name: `Taurus-Test-Pipeline`
4. Select **"Freestyle project"**
5. Click **"OK"**

### Step 2: Configure Project

#### General Settings
- **Description**: `Automated Taurus testing pipeline for JMeter Taurus React Demo`
- **Discard old builds**: Keep 10 builds

#### Source Code Management
- **Repository URL**: `https://github.com/your-username/jmeter-taurus-react-demo-docker.git`
- **Branch**: `working/jmeter-taurus-blazemeter-local`
- **Credentials**: Add your Git credentials if needed

#### Build Triggers
- **Poll SCM**: `H/15 * * * *` (every 15 minutes)
- Or **Build periodically**: `H/5 * * * *` (every 5 minutes)

#### Build Environment
- **Delete workspace before build starts**: ✓
- **Add timestamps to the Console Output**: ✓

#### Build Steps

**Step 1: Setup Environment**
```bash
# Create .bzt-rc file for BlazeMeter configuration
cat > ~/.bzt-rc << EOF
modules:
  blazemeter:
    token: "1f57f44b33ab29df65126dc1:c0d07b2ae9f8d63d3806520dd79eeb69c26ea1376775ea743e81bcb091be3ddf5d03e559"
EOF
echo "BlazeMeter configuration created"

# Install dependencies
echo "Installing backend dependencies..."
cd backend && npm install

echo "Installing frontend dependencies..."
cd ../frontend && npm install
```

**Step 2: Start Backend Application**
```bash
echo "Starting backend application..."
cd backend
nohup npm start > ../backend.log 2>&1 &
echo $! > backend.pid

# Wait for backend to start
sleep 10

# Check if backend is running
if curl -f http://localhost:5000/api/health; then
    echo "Backend started successfully"
else
    echo "Backend failed to start"
    exit 1
fi
```

**Step 3: Start Frontend Application**
```bash
echo "Starting frontend application..."
cd frontend
nohup npm start > ../frontend.log 2>&1 &
echo $! > frontend.pid

# Wait for frontend to start
sleep 15

# Check if frontend is running
if curl -f http://localhost:3000; then
    echo "Frontend started successfully"
else
    echo "Frontend failed to start"
    exit 1
fi
```

**Step 4: Run Taurus Tests**
```bash
# Parameter: TAURUS_CONFIG (set in build parameters)
echo "Running Taurus test: $TAURUS_CONFIG"

# Create results directory
mkdir -p taurus-test-results

# Run Taurus test
bzt $TAURUS_CONFIG

# Move timestamped results to organized directory
if [ -f move-taurus-results.sh ]; then
    chmod +x move-taurus-results.sh
    ./move-taurus-results.sh
fi

echo "Taurus test completed"
```

**Step 5: Stop Applications**
```bash
echo "Stopping applications..."

# Stop backend
if [ -f backend/backend.pid ]; then
    kill $(cat backend/backend.pid) 2>/dev/null || true
    rm -f backend/backend.pid
fi

# Stop frontend
if [ -f frontend/frontend.pid ]; then
    kill $(cat frontend/frontend.pid) 2>/dev/null || true
    rm -f frontend/frontend.pid
fi

echo "Applications stopped"
```

#### Post-build Actions

**Archive the artifacts**
- **Files to archive**: `taurus-test-results/**/*, *.log, taurus-result/**/*`
- **Allow empty archive**: ✓

**Publish JUnit test result report**
- **Test report XMLs**: `taurus-result/taurus-report.xml`

## 📋 Build Parameters

Add these parameters to your freestyle project:

### Choice Parameter: TAURUS_CONFIG
- **Name**: `TAURUS_CONFIG`
- **Choices**:
  - `taurus/get-quick-message.yml`
  - `taurus/get-delayed-response.yml`
  - `taurus/post-create-data.yml`
  - `taurus/test.yml`
- **Description**: `Select Taurus configuration file to run`

### String Parameter: GIT_BRANCH
- **Name**: `GIT_BRANCH`
- **Default Value**: `working/jmeter-taurus-blazemeter-local`
- **Description**: `Git branch to clone`

## 🔧 Prerequisites

### Jenkins Node Requirements
- **Java 8+**
- **Node.js 14+**
- **Python 3.7+**
- **Taurus**: `pip install bzt`
- **Git**
- **curl**

### Install Dependencies on Jenkins Node
```bash
# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Python and pip
sudo apt-get install -y python3 python3-pip

# Install Taurus
pip3 install bzt

# Install curl
sudo apt-get install -y curl
```

## 📊 Test Results

### BlazeMeter Reports
- **Project**: `jmeter-taurus-blazemeter-react-demo-project`
- **Reports**: Available in BlazeMeter dashboard
- **URL**: https://a.blazemeter.com/app/#/projects

### Local Reports
- **JUnit XML**: `taurus-result/taurus-report.xml`
- **Console Logs**: `backend.log`, `frontend.log`
- **Organized Results**: `taurus-test-results/` directory

## 🛠️ Troubleshooting

### Common Issues

1. **Port Conflicts**
   ```bash
   # Check if ports are in use
   netstat -tulpn | grep :3000
   netstat -tulpn | grep :5000
   ```

2. **Taurus not found**
   ```bash
   # Install Taurus
   pip3 install bzt
   ```

3. **Node.js not found**
   ```bash
   # Install Node.js
   curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
   sudo apt-get install -y nodejs
   ```

4. **Git credentials**
   - Add Git credentials in Jenkins Credentials Manager
   - Use SSH keys or username/password

### Jenkins Logs
```bash
# View Jenkins logs
docker-compose logs -f

# Access Jenkins container
docker exec -it jenkins-taurus-demo bash
```

## 📁 File Structure

```
jenkins/
├── docker-compose.yml          # Jenkins Docker setup
├── Jenkinsfile                 # Pipeline definition
├── start-jenkins.sh           # Start Jenkins script
├── stop-jenkins.sh            # Stop Jenkins script
└── README.md                  # This file
```

## 🚀 Usage

### Manual Build
1. Go to Jenkins Dashboard
2. Select your project
3. Click **"Build with Parameters"**
4. Select Taurus configuration
5. Click **"Build"**

### Automated Build
- Configure build triggers for automatic execution
- Set up webhooks for Git repository changes
- Use cron expressions for scheduled builds

## 🔄 Continuous Integration

### Webhook Setup
1. In your Git repository, add webhook
2. **URL**: `http://your-jenkins-url/github-webhook/`
3. **Events**: Push events
4. **Content type**: application/json

### Build Triggers
- **Poll SCM**: Check repository every 15 minutes
- **Build periodically**: Run tests every 5 minutes
- **GitHub hook trigger**: Trigger on push events

---

**Happy Testing! 🚀** 