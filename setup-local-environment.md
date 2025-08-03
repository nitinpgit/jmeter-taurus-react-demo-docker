# Local Test Environment Setup

This guide will help you set up and run JMeter and Taurus tests directly on your local machine without Docker.

## Prerequisites

### 1. Java (Required for JMeter)
- Download and install Java 8 or higher from: https://adoptium.net/
- Add Java to your PATH environment variable

### 2. JMeter Installation

#### Windows:
1. Download JMeter from: https://jmeter.apache.org/download_jmeter.cgi
2. Extract to a directory (e.g., `C:\apache-jmeter`)
3. Add `C:\apache-jmeter\bin` to your PATH environment variable
4. Verify installation: `jmeter -v`

#### Linux/Mac:
```bash
# Using package manager (Ubuntu/Debian)
sudo apt-get install jmeter

# Or download manually
wget https://downloads.apache.org/jmeter/binaries/apache-jmeter-5.6.3.tgz
tar -xzf apache-jmeter-5.6.3.tgz
sudo mv apache-jmeter-5.6.3 /opt/
echo 'export PATH=$PATH:/opt/apache-jmeter-5.6.3/bin' >> ~/.bashrc
source ~/.bashrc
```

### 3. Taurus Installation

#### Method 1: Using pip (Recommended)
```bash
pip install bzt
```

#### Method 2: Using Docker (Alternative)
```bash
docker run --rm -v $(pwd):/bzt blazemeter/taurus:latest
```

#### Method 3: Manual Installation
- Download from: https://gettaurus.org/install/Installation/
- Follow platform-specific instructions

## Running Tests

### Windows Users:
1. **JMeter Tests**: Double-click `run-jmeter-tests.bat`
2. **Taurus Tests**: Double-click `run-taurus-tests.bat`

### Linux/Mac Users:
1. **Make scripts executable**:
   ```bash
   chmod +x run-jmeter-tests.sh
   chmod +x run-taurus-tests.sh
   ```

2. **Run JMeter Tests**:
   ```bash
   ./run-jmeter-tests.sh
   ```

3. **Run Taurus Tests**:
   ```bash
   ./run-taurus-tests.sh
   ```

## Manual Commands

### JMeter Commands:
```bash
# Run a specific JMeter test
jmeter -n -t jmeter/localhost3000/get-quick-message.jmx -l results.jtl -e -o html-report

# Run with GUI (for development)
jmeter -t jmeter/localhost3000/get-quick-message.jmx
```

### Taurus Commands:
```bash
# Run a specific Taurus test
bzt taurus/get-quick-message.yml

# Run with BlazeMeter integration
export BLAZEMETER_TOKEN="your-token"
export BLAZEMETER_SECRET="your-secret"
bzt taurus/get-quick-message.yml
```

## Test Files Available

### JMeter Tests:
- `jmeter/localhost3000/get-quick-message.jmx` - Quick message endpoint test
- `jmeter/localhost3000/get-delayed-response.jmx` - Delayed response test
- `jmeter/localhost3000/get-health-check.jmx` - Health check endpoint
- `jmeter/localhost3000/post-create-data.jmx` - POST data creation test
- `jmeter/localhost3000/put-update-user.jmx` - PUT user update test
- `jmeter/localhost3000/delete-user.jmx` - DELETE user test
- `jmeter/localhost3000/get-search-with-parameter.jmx` - Search with parameters
- `jmeter/test-plan.jmx` - Complete test plan (runs all tests)

### Taurus Tests:
- `taurus/get-quick-message.yml` - Quick message endpoint test
- `taurus/get-delayed-response.yml` - Delayed response test
- `taurus/post-create-data.yml` - POST data creation test
- `taurus/test.yml` - Complete test suite

## Results and Reports

### JMeter Results:
- **JTL Files**: `jmeter-results/results_YYYYMMDD_HHMMSS.jtl`
- **HTML Reports**: `jmeter-results/html-report_YYYYMMDD_HHMMSS/`
- **Log Files**: `jmeter.log`

### Taurus Results:
- **Artifacts**: `taurus-results/`
- **BlazeMeter Dashboard**: https://a.blazemeter.com/app/#/projects (if configured)

## Troubleshooting

### Common Issues:

1. **JMeter not found**:
   - Ensure JMeter is installed and in PATH
   - Set JMETER_HOME environment variable

2. **Taurus not found**:
   - Install Taurus using pip: `pip install bzt`
   - Or use Docker: `docker run --rm -v $(pwd):/bzt blazemeter/taurus:latest`

3. **Java not found**:
   - Install Java 8+ and add to PATH
   - Set JAVA_HOME environment variable

4. **Permission denied (Linux/Mac)**:
   - Make scripts executable: `chmod +x *.sh`

5. **Test files not found**:
   - Ensure you're running from the project root directory
   - Check that test files exist in the specified paths

### Environment Variables:
```bash
# JMeter
export JMETER_HOME=/path/to/jmeter
export JAVA_HOME=/path/to/java

# Taurus (for BlazeMeter integration)
export BLAZEMETER_TOKEN="your-token"
export BLAZEMETER_SECRET="your-secret"
export BLAZEMETER_WORKSPACE_ID="your-workspace-id"
```

## Next Steps

1. **Start the application** (if not already running):
   ```bash
   # Frontend (React)
   cd frontend && npm start
   
   # Backend (Node.js)
   cd backend && npm start
   ```

2. **Run tests** using the provided scripts

3. **View results** in the generated HTML reports or BlazeMeter dashboard

4. **Customize tests** by modifying the JMeter (.jmx) or Taurus (.yml) files 