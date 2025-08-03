# 🧪 Jenkins + Taurus + Node Environment Setup (Manual Bootstrap)

This README documents the manual steps performed inside the Jenkins Docker container to fix build failures caused by missing `npm`, `python`, and `bzt` (Taurus). The final environment supports both running a React frontend and executing Taurus performance tests.

---

## 🚨 Problem Summary

The Jenkins job failed due to:

- `npm` not found (Node.js missing)
- `python3` and `pip` missing
- `bzt` not installed
- Jenkins shell step was trying to activate a virtual environment from `/opt/taurus-venv`, which did not exist

---

## ✅ Steps Performed (Inside Jenkins Container)

### 1. Enter Jenkins container

```bash
docker exec -u 0 -it jenkins-taurus-demo bash
```

### 2. Install prerequisites

```bash
apt-get update
apt-get install -y curl gnupg build-essential
```

### 3. Install Node.js and npm (for React frontend)

```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs
```

**Verify:**
```bash
node -v
npm -v
```

### 4. Install Python 3 and pip

```bash
apt-get install -y python3 python3-pip python3-venv
```

**Verify:**
```bash
python3 --version
pip3 --version
```

### 5. Create and activate Python virtual environment

```bash
python3 -m venv /var/jenkins_home/taurus-venv
source /var/jenkins_home/taurus-venv/bin/activate
```

🟢 **This is the correct path used in Jenkins**: `/var/jenkins_home/taurus-venv/bin/activate`

### 6. Install Taurus (bzt)

```bash
pip install bzt
```

**Verify:**
```bash
bzt -v
```

---

## 🛠️ Jenkins Job Fix

### Replace this line in the shell step:

```bash
. /opt/taurus-venv/bin/activate  # ❌ Wrong path
```

### With the correct one:

```bash
. /var/jenkins_home/taurus-venv/bin/activate  # ✅ Correct path
```

### Then run:

```bash
bzt your-test.yaml
```

---

## 📋 Complete Environment Setup Script

Here's a complete script that can be run inside the Jenkins container to set up the entire environment:

```bash
#!/bin/bash

echo "========================================"
echo "Setting up Jenkins Environment"
echo "========================================"

# Update package list
echo "Updating package list..."
apt-get update

# Install prerequisites
echo "Installing prerequisites..."
apt-get install -y curl gnupg build-essential

# Install Node.js and npm
echo "Installing Node.js and npm..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Install Python 3 and pip
echo "Installing Python 3 and pip..."
apt-get install -y python3 python3-pip python3-venv

# Create Python virtual environment
echo "Creating Python virtual environment..."
python3 -m venv /var/jenkins_home/taurus-venv

# Activate virtual environment
echo "Activating virtual environment..."
source /var/jenkins_home/taurus-venv/bin/activate

# Install Taurus
echo "Installing Taurus..."
pip install bzt

# Verify installations
echo "========================================"
echo "Verifying installations..."
echo "========================================"
echo "Node.js version: $(node -v)"
echo "npm version: $(npm -v)"
echo "Python version: $(python3 --version)"
echo "pip version: $(pip3 --version)"
echo "Taurus version: $(bzt -v)"

echo "========================================"
echo "Environment setup completed!"
echo "========================================"
```

---

## 🔧 Jenkins Build Script Update

### Updated Build Step for Jenkins:

```bash
# Activate Taurus virtual environment
source /var/jenkins_home/taurus-venv/bin/activate

# Verify environment
echo "Python: $(python3 --version)"
echo "Taurus: $(bzt -v)"
echo "Node: $(node -v)"
echo "npm: $(npm -v)"

# Install project dependencies
echo "Installing backend dependencies..."
cd backend && npm install

echo "Installing frontend dependencies..."
cd ../frontend && npm install

# Start backend
echo "Starting backend..."
cd backend
nohup npm start > ../backend.log 2>&1 &
echo $! > backend.pid
cd ..

# Wait for backend to start
sleep 10

# Start frontend
echo "Starting frontend..."
cd frontend
nohup npm start > ../frontend.log 2>&1 &
echo $! > frontend.pid
cd ..

# Wait for frontend to start
sleep 15

# Run Taurus tests
echo "Running Taurus tests..."
bzt $TAURUS_CONFIG

# Cleanup
echo "Cleaning up..."
if [ -f backend/backend.pid ]; then
    kill $(cat backend/backend.pid) 2>/dev/null || true
    rm -f backend/backend.pid
fi

if [ -f frontend/frontend.pid ]; then
    kill $(cat frontend/frontend.pid) 2>/dev/null || true
    rm -f frontend/frontend.pid
fi
```

---

## 📊 Environment Verification

### Check if everything is working:

```bash
# Enter Jenkins container
docker exec -u 0 -it jenkins-taurus-demo bash

# Activate virtual environment
source /var/jenkins_home/taurus-venv/bin/activate

# Test Node.js
node -v
npm -v

# Test Python
python3 --version
pip3 --version

# Test Taurus
bzt -v

# Test curl (for health checks)
curl --version
```

---

## 🚨 Troubleshooting

### Common Issues:

1. **Permission Denied**
   ```bash
   # Run as root inside container
   docker exec -u 0 -it jenkins-taurus-demo bash
   ```

2. **Virtual Environment Not Found**
   ```bash
   # Check if virtual environment exists
   ls -la /var/jenkins_home/taurus-venv/bin/activate
   
   # Recreate if missing
   python3 -m venv /var/jenkins_home/taurus-venv
   ```

3. **Taurus Not Found**
   ```bash
   # Activate virtual environment first
   source /var/jenkins_home/taurus-venv/bin/activate
   
   # Then install Taurus
   pip install bzt
   ```

4. **Node.js Not Found**
   ```bash
   # Reinstall Node.js
   curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
   apt-get install -y nodejs
   ```

---

## 📁 File Locations

### Important Paths:

- **Jenkins Home**: `/var/jenkins_home`
- **Taurus Virtual Environment**: `/var/jenkins_home/taurus-venv`
- **Activation Script**: `/var/jenkins_home/taurus-venv/bin/activate`
- **Project Workspace**: `/var/jenkins_home/workspace/[project-name]`

---

## 🔄 Persistent Setup

### To make the setup persistent across container restarts:

1. **Create a custom Dockerfile**:
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

2. **Update docker-compose.yml**:
   ```yaml
   version: '3.8'
   services:
     jenkins:
       build: .
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

---

## ✅ Success Criteria

After completing the setup, you should be able to:

1. ✅ Run `node -v` and `npm -v` successfully
2. ✅ Run `python3 --version` and `pip3 --version` successfully
3. ✅ Activate virtual environment: `source /var/jenkins_home/taurus-venv/bin/activate`
4. ✅ Run `bzt -v` successfully
5. ✅ Execute Taurus tests: `bzt taurus/get-quick-message.yml`
6. ✅ Run npm commands: `npm install` and `npm start`

---

## 📚 Additional Resources

- **Taurus Documentation**: https://gettaurus.org/
- **Jenkins Docker**: https://github.com/jenkinsci/docker
- **Node.js Installation**: https://nodejs.org/en/download/package-manager/
- **Python Virtual Environments**: https://docs.python.org/3/tutorial/venv.html

---

**Happy Testing! 🚀** 