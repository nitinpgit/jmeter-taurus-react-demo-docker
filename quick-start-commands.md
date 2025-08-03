# Quick Start Commands

## 🚀 Immediate Commands to Run Tests

### Windows Users:
```cmd
# Run JMeter tests
run-jmeter-tests.bat

# Run Taurus tests  
run-taurus-tests.bat
```

### Linux/Mac Users:
```bash
# Make scripts executable (first time only)
chmod +x run-jmeter-tests.sh
chmod +x run-taurus-tests.sh

# Run JMeter tests
./run-jmeter-tests.sh

# Run Taurus tests
./run-taurus-tests.sh
```

## 📋 Manual Commands (If Scripts Don't Work)

### JMeter Commands:
```bash
# Quick message test
jmeter -n -t jmeter/localhost3000/get-quick-message.jmx -l results.jtl -e -o html-report

# Health check test
jmeter -n -t jmeter/localhost3000/get-health-check.jmx -l results.jtl -e -o html-report

# All tests
jmeter -n -t jmeter/test-plan.jmx -l results.jtl -e -o html-report
```

### Taurus Commands:
```bash
# Quick message test
bzt taurus/get-quick-message.yml

# Delayed response test
bzt taurus/get-delayed-response.yml

# Create data test
bzt taurus/post-create-data.yml

# Complete test suite
bzt taurus/test.yml
```

## 🔧 Installation Commands

### Install JMeter:
```bash
# Windows: Download from https://jmeter.apache.org/download_jmeter.cgi
# Linux:
sudo apt-get install jmeter

# Mac:
brew install jmeter
```

### Install Taurus:
```bash
# Using pip (recommended)
pip install bzt

# Using Docker (alternative)
docker run --rm -v $(pwd):/bzt blazemeter/taurus:latest
```

## 🌐 Start Application (If Needed)

```bash
# Start backend
cd backend && npm start

# Start frontend (in new terminal)
cd frontend && npm start
```

## 📊 View Results

### JMeter Results:
- **HTML Report**: `jmeter-results/html-report_YYYYMMDD_HHMMSS/index.html`
- **JTL File**: `jmeter-results/results_YYYYMMDD_HHMMSS.jtl`

### Taurus Results:
- **Local Results**: `taurus-results/`
- **BlazeMeter Dashboard**: https://a.blazemeter.com/app/#/projects

## 🛠️ Troubleshooting

### Check Installations:
```bash
# Check JMeter
jmeter -v

# Check Taurus
bzt --version

# Check Java
java -version
```

### Environment Variables:
```bash
# Set JMeter home
export JMETER_HOME=/path/to/jmeter

# Set BlazeMeter credentials
export BLAZEMETER_TOKEN="BLAZEMETER_API_KEY"
export BLAZEMETER_SECRET="BLAZEMETER_SECRET_KEY"
```

## 📁 Project Structure
```
jmeter-taurus-react-demo-docker/
├── jmeter/
│   ├── localhost3000/
│   │   ├── get-quick-message.jmx
│   │   ├── get-delayed-response.jmx
│   │   ├── get-health-check.jmx
│   │   ├── post-create-data.jmx
│   │   ├── put-update-user.jmx
│   │   ├── delete-user.jmx
│   │   └── get-search-with-parameter.jmx
│   └── test-plan.jmx
├── taurus/
│   ├── get-quick-message.yml
│   ├── get-delayed-response.yml
│   ├── post-create-data.yml
│   └── test.yml
├── run-jmeter-tests.bat/.sh
├── run-taurus-tests.bat/.sh
└── setup-local-environment.md
```

## 🎯 Quick Test Checklist

1. ✅ Java installed and in PATH
2. ✅ JMeter installed and in PATH  
3. ✅ Taurus installed (`pip install bzt`)
4. ✅ Application running (frontend:3000, backend:5000)
5. ✅ Run test script or manual command
6. ✅ Check results in generated reports

## 🔗 Useful Links

- **JMeter Download**: https://jmeter.apache.org/download_jmeter.cgi
- **Taurus Installation**: https://gettaurus.org/install/Installation/
- **Java Download**: https://adoptium.net/
- **BlazeMeter Dashboard**: https://a.blazemeter.com/app/#/projects 