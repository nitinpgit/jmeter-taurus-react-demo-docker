# Manual Jenkins Configuration Guide

Since Jenkins requires authentication, here's the step-by-step manual configuration for your `jmeter-freestyle` job.

## 🎯 Current Status
- ✅ Jenkins is running at `http://localhost:8080`
- ✅ Job `jmeter-freestyle` exists
- ⚠️ Jenkins requires authentication (403 Forbidden)

## 📋 Step-by-Step Configuration

### Step 1: Access Jenkins Job Configuration

1. **Open your browser** and go to: `http://localhost:8080`
2. **Login** to Jenkins with your credentials
3. **Navigate to your job**: `http://localhost:8080/job/jmeter-freestyle/`
4. **Click "Configure"** in the left sidebar

### Step 2: Configure Source Code Management

1. **Scroll down** to "Source Code Management" section
2. **Select "Git"**
3. **Configure Git settings:**
   - **Repository URL**: `https://github.com/your-username/jmeter-taurus-react-demo-docker.git`
   - **Branch**: `*/main`
   - **Credentials**: Add your Git credentials if needed

### Step 3: Add Build Parameters

1. **Check "This project is parameterized"**
2. **Add the following parameters:**

#### YAML File Selection (Choice Parameter)
- **Parameter Type**: Choice Parameter
- **Name**: `TAURUS_YAML_FILE`
- **Description**: Select the Taurus YAML file to execute
- **Choices** (one per line):
  ```
  taurus/get-quick-message.yml
  taurus/post-create-data.yml
  taurus/get-delayed-response.yml
  taurus/test.yml
  ```

#### Thread Count (Integer Parameter)
- **Parameter Type**: Integer Parameter
- **Name**: `THREAD_COUNT`
- **Description**: Number of concurrent users (threads)
- **Default Value**: `5`
- **Min**: `1`
- **Max**: `100`

#### Ramp-up Time (Integer Parameter)
- **Parameter Type**: Integer Parameter
- **Name**: `RAMP_UP_TIME`
- **Description**: Ramp-up time in seconds
- **Default Value**: `5`
- **Min**: `1`
- **Max**: `300`

#### Hold Time (Integer Parameter)
- **Parameter Type**: Integer Parameter
- **Name**: `HOLD_TIME`
- **Description**: Test duration in seconds
- **Default Value**: `30`
- **Min**: `10`
- **Max**: `3600`

#### Loop Count (Integer Parameter)
- **Parameter Type**: Integer Parameter
- **Name**: `LOOP_COUNT`
- **Description**: Number of iterations per user
- **Default Value**: `1`
- **Min**: `1`
- **Max**: `1000`

#### Base URL (String Parameter)
- **Parameter Type**: String Parameter
- **Name**: `BASE_URL`
- **Description**: Base URL for the application
- **Default Value**: `http://localhost:3000`

#### Start Application (Boolean Parameter)
- **Parameter Type**: Boolean Parameter
- **Name**: `START_APPLICATION`
- **Description**: Start the application using Docker Compose
- **Default Value**: `true`

#### Stop Application (Boolean Parameter)
- **Parameter Type**: Boolean Parameter
- **Name**: `STOP_APPLICATION`
- **Description**: Stop the application after test completion
- **Default Value**: `true`

### Step 4: Add Build Step

1. **Scroll to "Build" section**
2. **Click "Add build step"** → **"Execute shell"**
3. **Copy and paste this shell script:**

```bash
#!/bin/bash

# Taurus Parameterized Test Runner for Jenkins
# This script runs Taurus performance tests with configurable parameters

set -e  # Exit on any error

echo "=========================================="
echo "Taurus Parameterized Test Runner"
echo "=========================================="
echo "Build Number: $BUILD_NUMBER"
echo "Job Name: $JOB_NAME"
echo "Workspace: $WORKSPACE"
echo "Date: $(date)"
echo ""
echo "Test Configuration:"
echo "- YAML File: $TAURUS_YAML_FILE"
echo "- Thread Count: $THREAD_COUNT"
echo "- Ramp-up Time: $RAMP_UP_TIME seconds"
echo "- Hold Time: $HOLD_TIME seconds"
echo "- Loop Count: $LOOP_COUNT"
echo "- Base URL: $BASE_URL"
echo "- Start Application: $START_APPLICATION"
echo "- Stop Application: $STOP_APPLICATION"
echo "=========================================="

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to wait for service to be ready
wait_for_service() {
    local url=$1
    local max_attempts=30
    local attempt=1
    
    echo "Waiting for service at $url to be ready..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f -s "$url" >/dev/null 2>&1; then
            echo "Service is ready!"
            return 0
        fi
        
        echo "Attempt $attempt/$max_attempts: Service not ready yet..."
        sleep 10
        attempt=$((attempt + 1))
    done
    
    echo "Service failed to start within expected time"
    return 1
}

# Install Taurus if not present
if ! command_exists bzt; then
    echo "Installing Taurus..."
    if command_exists pip3; then
        pip3 install bzt==1.16.0
    elif command_exists pip; then
        pip install bzt==1.16.0
    else
        echo "Error: pip not found. Please install Python and pip first."
        exit 1
    fi
else
    echo "Taurus is already installed"
    bzt --version
fi

# Check if Docker is available
if ! command_exists docker; then
    echo "Error: Docker is not installed or not in PATH"
    exit 1
fi

if ! command_exists docker-compose; then
    echo "Error: Docker Compose is not installed or not in PATH"
    exit 1
fi

# Start the application if requested
if [ "$START_APPLICATION" = "true" ]; then
    echo "Starting application with Docker Compose..."
    docker-compose up --build -d
    
    # Wait for application to be ready
    if ! wait_for_service "$BASE_URL/api/health"; then
        echo "Application failed to start properly"
        docker-compose logs
        exit 1
    fi
else
    echo "Skipping application startup (START_APPLICATION=false)"
fi

# Create results directory
mkdir -p taurus-result

# Create a temporary YAML file with updated parameters
TEMP_YAML="taurus-result/temp_$(basename $TAURUS_YAML_FILE)"

echo "Creating temporary YAML file with updated parameters..."
echo "Original file: $TAURUS_YAML_FILE"
echo "Temporary file: $TEMP_YAML"

# Copy the original YAML and update parameters
cp "$TAURUS_YAML_FILE" "$TEMP_YAML"

# Update the YAML file with new parameters using sed
echo "Updating YAML parameters..."

# Update concurrency (thread count)
sed -i "s/concurrency: [0-9]*/concurrency: $THREAD_COUNT/g" "$TEMP_YAML"

# Update ramp-up time
sed -i "s/ramp-up: [0-9]*s/ramp-up: ${RAMP_UP_TIME}s/g" "$TEMP_YAML"

# Update hold-for time
sed -i "s/hold-for: [0-9]*s/hold-for: ${HOLD_TIME}s/g" "$TEMP_YAML"

# Update loop count if it exists, otherwise add it
if grep -q "iterations:" "$TEMP_YAML"; then
    sed -i "s/iterations: [0-9]*/iterations: $LOOP_COUNT/g" "$TEMP_YAML"
else
    # Add iterations after concurrency line
    sed -i "/concurrency: $THREAD_COUNT/a\    iterations: $LOOP_COUNT" "$TEMP_YAML"
fi

# Update base URL in requests if it's not localhost:3000
if [ "$BASE_URL" != "http://localhost:3000" ]; then
    sed -i "s|http://localhost:3000|$BASE_URL|g" "$TEMP_YAML"
fi

echo "Updated YAML file contents:"
echo "=========================================="
cat "$TEMP_YAML"
echo "=========================================="

# Run Taurus test
echo "Running Taurus test with updated parameters..."
echo "Command: bzt $TEMP_YAML"

bzt "$TEMP_YAML"

echo "=========================================="
echo "Taurus test completed!"
echo "=========================================="

# Generate summary report
echo "Generating test summary..."
cat > taurus-result/summary.txt << EOF
Taurus Parameterized Test Summary
================================
Date: $(date)
Build Number: $BUILD_NUMBER
Job Name: $JOB_NAME
Workspace: $WORKSPACE

Test Configuration:
- YAML File: $TAURUS_YAML_FILE
- Thread Count: $THREAD_COUNT
- Ramp-up Time: $RAMP_UP_TIME seconds
- Hold Time: $HOLD_TIME seconds
- Loop Count: $LOOP_COUNT
- Base URL: $BASE_URL
- Start Application: $START_APPLICATION
- Stop Application: $STOP_APPLICATION

Test Results:
- Results Directory: taurus-result/
- HTML Reports: taurus-result/index.html
- Console Output: Available in Jenkins build log

Application Status:
- Frontend: $BASE_URL
- Backend API: $BASE_URL/api
- Health Check: $BASE_URL/api/health

Docker Containers:
$(docker-compose ps)

EOF

# Display test results summary
echo "=========================================="
echo "Test Results Summary"
echo "=========================================="
if [ -f "taurus-result/summary.txt" ]; then
    cat taurus-result/summary.txt
fi

echo "=========================================="
echo "Taurus test execution completed successfully!"
echo "Results are available in: taurus-result/"
echo "=========================================="
```

### Step 5: Add Post-build Actions

#### Archive Artifacts
1. **Click "Add post-build action"** → **"Archive the artifacts"**
2. **Set "Files to archive"** to: `taurus-result/**/*`
3. **Check "Allow empty archive"**

#### Publish HTML Reports
1. **Click "Add post-build action"** → **"Publish HTML reports"**
2. **Set "HTML directory to archive"** to: `taurus-result`
3. **Set "Index page[s]"** to: `index.html`
4. **Set "Report title"** to: `Taurus Test Report`
5. **Check "Keep past HTML reports"**

#### Additional Shell Script (Cleanup)
1. **Click "Add post-build action"** → **"Execute shell"**
2. **Copy and paste this script:**

```bash
#!/bin/bash

# Stop the application if requested
if [ "$STOP_APPLICATION" = "true" ]; then
    echo "Stopping application..."
    docker-compose down
    echo "Application stopped successfully"
else
    echo "Skipping application shutdown (STOP_APPLICATION=false)"
fi

echo "Build completed successfully!"
```

### Step 6: Add Build Wrapper

1. **Scroll to "Build Environment" section**
2. **Check "Add timestamps to the Console Output"**

### Step 7: Save Configuration

1. **Click "Save"** at the bottom of the page
2. **Verify** the configuration was saved successfully

## 🎮 How to Use the Configured Job

### Running Tests

1. **Go to your job page**: `http://localhost:8080/job/jmeter-freestyle/`
2. **Click "Build with Parameters"**
3. **Configure your test parameters:**

#### Example Test Scenarios

**Quick Smoke Test:**
- YAML File: `taurus/get-quick-message.yml`
- Thread Count: `2`
- Ramp-up Time: `2`
- Hold Time: `10`
- Loop Count: `1`

**Load Test:**
- YAML File: `taurus/test.yml`
- Thread Count: `20`
- Ramp-up Time: `30`
- Hold Time: `300`
- Loop Count: `5`

**Stress Test:**
- YAML File: `taurus/post-create-data.yml`
- Thread Count: `50`
- Ramp-up Time: `60`
- Hold Time: `600`
- Loop Count: `10`

4. **Click "Build"** to start the test

### Viewing Results

- **Console Output**: Click on the build number to see detailed logs
- **HTML Reports**: Available in the build page sidebar
- **Artifacts**: Downloadable test results and reports

## 🔧 Troubleshooting

### Common Issues

1. **Git repository not found:**
   - Verify the repository URL is correct
   - Ensure you have access to the repository
   - Check if credentials are configured properly

2. **Taurus installation fails:**
   - Ensure Python and pip are installed on Jenkins server
   - Check if Jenkins has internet access for pip install

3. **Docker not available:**
   - Ensure Docker and Docker Compose are installed
   - Check if Jenkins user has Docker permissions

4. **Application fails to start:**
   - Check if port 3000 is available
   - Verify Docker Compose configuration
   - Check application logs

### Required Jenkins Plugins

Make sure these plugins are installed:
- **Git plugin**
- **HTML Publisher plugin**
- **Timestamper plugin**

## 📊 Expected Output

After successful configuration, you should see:

1. **Parameterized build interface** with dropdowns and input fields
2. **Test execution logs** with timestamps
3. **HTML test reports** with charts and metrics
4. **Downloadable artifacts** with test results
5. **Summary reports** with test configuration details

## 🎯 Next Steps

1. **Test the configuration** with a simple smoke test
2. **Customize parameters** based on your testing needs
3. **Set up scheduled builds** if needed
4. **Configure notifications** for test completion
5. **Integrate with other tools** in your CI/CD pipeline 