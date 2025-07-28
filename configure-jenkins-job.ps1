# Jenkins Freestyle Job Configuration Script for Windows PowerShell
# This script configures the jmeter-freestyle job with Taurus performance testing

# Jenkins configuration
$JenkinsUrl = "http://localhost:8080"
$JobName = "jmeter-freestyle"
$ContainerId = "3d0960f900f812920d9b8ba580d7ff59f308583aa43a01f0abf35ed20586ebdc"

Write-Host "==========================================" -ForegroundColor Green
Write-Host "Jenkins Freestyle Job Configuration" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host "Jenkins URL: $JenkinsUrl" -ForegroundColor Yellow
Write-Host "Job Name: $JobName" -ForegroundColor Yellow
Write-Host "Container ID: $ContainerId" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Green

# Function to check if Jenkins is accessible
function Test-JenkinsAccess {
    Write-Host "Checking Jenkins accessibility..." -ForegroundColor Cyan
    try {
        $response = Invoke-WebRequest -Uri $JenkinsUrl -UseBasicParsing -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Jenkins is accessible" -ForegroundColor Green
            return $true
        }
    }
    catch {
        Write-Host "❌ Jenkins is not accessible at $JenkinsUrl" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to check if job exists
function Test-JobExists {
    Write-Host "Checking if job '$JobName' exists..." -ForegroundColor Cyan
    try {
        $response = Invoke-WebRequest -Uri "$JenkinsUrl/job/$JobName/" -UseBasicParsing -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Job '$JobName' exists" -ForegroundColor Green
            return $true
        }
    }
    catch {
        Write-Host "❌ Job '$JobName' does not exist" -ForegroundColor Red
        return $false
    }
}

# Function to create job configuration XML
function New-JobConfig {
    Write-Host "Creating job configuration XML..." -ForegroundColor Cyan
    
    $jobConfigXml = @"
<?xml version='1.1' encoding='UTF-8'?>
<project>
  <actions/>
  <description>Parameterized Taurus Performance Testing - Select YAML file and configure test parameters</description>
  <keepDependencies>false</keepDependencies>
  <properties>
    <hudson.model.ParametersDefinitionProperty>
      <parameterDefinitions>
        <hudson.model.ChoiceParameterDefinition>
          <name>TAURUS_YAML_FILE</name>
          <description>Select the Taurus YAML file to execute</description>
          <choices class="java.util.Arrays`$ArrayList">
            <a class="string-array">
              <string>taurus/get-quick-message.yml</string>
              <string>taurus/post-create-data.yml</string>
              <string>taurus/get-delayed-response.yml</string>
              <string>taurus/test.yml</string>
            </a>
          </choices>
        </hudson.model.ChoiceParameterDefinition>
        <hudson.model.IntParameterDefinition>
          <name>THREAD_COUNT</name>
          <description>Number of concurrent users (threads)</description>
          <defaultValue>5</defaultValue>
          <min>1</min>
          <max>100</max>
        </hudson.model.IntParameterDefinition>
        <hudson.model.IntParameterDefinition>
          <name>RAMP_UP_TIME</name>
          <description>Ramp-up time in seconds</description>
          <defaultValue>5</defaultValue>
          <min>1</min>
          <max>300</max>
        </hudson.model.IntParameterDefinition>
        <hudson.model.IntParameterDefinition>
          <name>HOLD_TIME</name>
          <description>Test duration in seconds</description>
          <defaultValue>30</defaultValue>
          <min>10</min>
          <max>3600</max>
        </hudson.model.IntParameterDefinition>
        <hudson.model.IntParameterDefinition>
          <name>LOOP_COUNT</name>
          <description>Number of iterations per user</description>
          <defaultValue>1</defaultValue>
          <min>1</min>
          <max>1000</max>
        </hudson.model.IntParameterDefinition>
        <hudson.model.StringParameterDefinition>
          <name>BASE_URL</name>
          <description>Base URL for the application (default: http://localhost:3000)</description>
          <defaultValue>http://localhost:3000</defaultValue>
          <trim>true</trim>
        </hudson.model.StringParameterDefinition>
        <hudson.model.BooleanParameterDefinition>
          <name>START_APPLICATION</name>
          <description>Start the application using Docker Compose before running tests</description>
          <defaultValue>true</defaultValue>
        </hudson.model.BooleanParameterDefinition>
        <hudson.model.BooleanParameterDefinition>
          <name>STOP_APPLICATION</name>
          <description>Stop the application after test completion</description>
          <defaultValue>true</defaultValue>
        </hudson.model.BooleanParameterDefinition>
      </parameterDefinitions>
    </hudson.model.ParametersDefinitionProperty>
    <jenkins.model.BuildDiscarderProperty>
      <strategy class="hudson.tasks.LogRotator">
        <daysToKeep>30</daysToKeep>
        <numToKeep>50</numToKeep>
        <artifactDaysToKeep>-1</artifactDaysToKeep>
        <artifactNumToKeep>-1</artifactNumToKeep>
      </strategy>
    </jenkins.model.BuildDiscarderProperty>
  </properties>
  <scm class="hudson.plugins.git.GitSCM" plugin="git@4.15.0">
    <configVersion>2</configVersion>
    <userRemoteConfigs>
      <hudson.plugins.git.UserRemoteConfig>
        <url>https://github.com/your-username/jmeter-taurus-react-demo-docker.git</url>
      </hudson.plugins.git.UserRemoteConfig>
    </userRemoteConfigs>
    <branches>
      <hudson.plugins.git.BranchSpec>
        <name>*/main</name>
      </hudson.plugins.git.BranchSpec>
    </branches>
    <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
    <submoduleCfg class="empty-list"/>
    <extensions/>
  </scm>
  <canRoam>true</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
  <triggers/>
  <concurrentBuild>false</concurrentBuild>
  <builders>
    <hudson.tasks.Shell>
      <command>#!/bin/bash

# Taurus Parameterized Test Runner for Jenkins
# This script runs Taurus performance tests with configurable parameters

set -e  # Exit on any error

echo "=========================================="
echo "Taurus Parameterized Test Runner"
echo "=========================================="
echo "Build Number: `$BUILD_NUMBER"
echo "Job Name: `$JOB_NAME"
echo "Workspace: `$WORKSPACE"
echo "Date: `$(date)"
echo ""
echo "Test Configuration:"
echo "- YAML File: `$TAURUS_YAML_FILE"
echo "- Thread Count: `$THREAD_COUNT"
echo "- Ramp-up Time: `$RAMP_UP_TIME seconds"
echo "- Hold Time: `$HOLD_TIME seconds"
echo "- Loop Count: `$LOOP_COUNT"
echo "- Base URL: `$BASE_URL"
echo "- Start Application: `$START_APPLICATION"
echo "- Stop Application: `$STOP_APPLICATION"
echo "=========================================="

# Function to check if command exists
command_exists() {
    command -v "`$1" >/dev/null 2>&1
}

# Function to wait for service to be ready
wait_for_service() {
    local url=`$1
    local max_attempts=30
    local attempt=1
    
    echo "Waiting for service at `$url to be ready..."
    
    while [ `$attempt -le `$max_attempts ]; do
        if curl -f -s "`$url" >/dev/null 2>&1; then
            echo "Service is ready!"
            return 0
        fi
        
        echo "Attempt `$attempt/`$max_attempts: Service not ready yet..."
        sleep 10
        attempt=`$((attempt + 1))
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
if [ "`$START_APPLICATION" = "true" ]; then
    echo "Starting application with Docker Compose..."
    docker-compose up --build -d
    
    # Wait for application to be ready
    if ! wait_for_service "`$BASE_URL/api/health"; then
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
TEMP_YAML="taurus-result/temp_`$(basename `$TAURUS_YAML_FILE)"

echo "Creating temporary YAML file with updated parameters..."
echo "Original file: `$TAURUS_YAML_FILE"
echo "Temporary file: `$TEMP_YAML"

# Copy the original YAML and update parameters
cp "`$TAURUS_YAML_FILE" "`$TEMP_YAML"

# Update the YAML file with new parameters using sed
echo "Updating YAML parameters..."

# Update concurrency (thread count)
sed -i "s/concurrency: [0-9]*/concurrency: `$THREAD_COUNT/g" "`$TEMP_YAML"

# Update ramp-up time
sed -i "s/ramp-up: [0-9]*s/ramp-up: `$`{RAMP_UP_TIME}s/g" "`$TEMP_YAML"

# Update hold-for time
sed -i "s/hold-for: [0-9]*s/hold-for: `$`{HOLD_TIME}s/g" "`$TEMP_YAML"

# Update loop count if it exists, otherwise add it
if grep -q "iterations:" "`$TEMP_YAML"; then
    sed -i "s/iterations: [0-9]*/iterations: `$LOOP_COUNT/g" "`$TEMP_YAML"
else
    # Add iterations after concurrency line
    sed -i "/concurrency: `$THREAD_COUNT/a\    iterations: `$LOOP_COUNT" "`$TEMP_YAML"
fi

# Update base URL in requests if it's not localhost:3000
if [ "`$BASE_URL" != "http://localhost:3000" ]; then
    sed -i "s|http://localhost:3000|`$BASE_URL|g" "`$TEMP_YAML"
fi

echo "Updated YAML file contents:"
echo "=========================================="
cat "`$TEMP_YAML"
echo "=========================================="

# Run Taurus test
echo "Running Taurus test with updated parameters..."
echo "Command: bzt `$TEMP_YAML"

bzt "`$TEMP_YAML"

echo "=========================================="
echo "Taurus test completed!"
echo "=========================================="

# Generate summary report
echo "Generating test summary..."
cat > taurus-result/summary.txt << EOF
Taurus Parameterized Test Summary
================================
Date: `$(date)
Build Number: `$BUILD_NUMBER
Job Name: `$JOB_NAME
Workspace: `$WORKSPACE

Test Configuration:
- YAML File: `$TAURUS_YAML_FILE
- Thread Count: `$THREAD_COUNT
- Ramp-up Time: `$RAMP_UP_TIME seconds
- Hold Time: `$HOLD_TIME seconds
- Loop Count: `$LOOP_COUNT
- Base URL: `$BASE_URL
- Start Application: `$START_APPLICATION
- Stop Application: `$STOP_APPLICATION

Test Results:
- Results Directory: taurus-result/
- HTML Reports: taurus-result/index.html
- Console Output: Available in Jenkins build log

Application Status:
- Frontend: `$BASE_URL
- Backend API: `$BASE_URL/api
- Health Check: `$BASE_URL/api/health

Docker Containers:
`$(docker-compose ps)

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
</command>
    </hudson.tasks.Shell>
  </builders>
  <publishers>
    <hudson.tasks.ArtifactArchiver>
      <artifacts>taurus-result/**/*</artifacts>
      <allowEmptyArchive>true</allowEmptyArchive>
      <onlyIfSuccessful>false</onlyIfSuccessful>
      <fingerprint>false</fingerprint>
      <defaultExcludes>true</defaultExcludes>
      <caseSensitive>true</caseSensitive>
    </hudson.tasks.ArtifactArchiver>
    <htmlpublisher.HtmlPublisher plugin="htmlpublisher@1.25">
      <reportTargets>
        <htmlpublisher.HtmlPublisherTarget>
          <reportName>Taurus Test Report</reportName>
          <reportDir>taurus-result</reportDir>
          <reportFiles>index.html</reportFiles>
          <keepAll>true</keepAll>
          <alwaysLinkToLastBuild>true</alwaysLinkToLastBuild>
          <allowMissing>false</allowMissing>
          <wrapperName>htmlpublisher-wrapper.html</wrapperName>
        </htmlpublisher.HtmlPublisherTarget>
      </reportTargets>
    </htmlpublisher.HtmlPublisher>
    <hudson.tasks.Shell>
      <command>#!/bin/bash

# Stop the application if requested
if [ "`$STOP_APPLICATION" = "true" ]; then
    echo "Stopping application..."
    docker-compose down
    echo "Application stopped successfully"
else
    echo "Skipping application shutdown (STOP_APPLICATION=false)"
fi

echo "Build completed successfully!"
</command>
    </hudson.tasks.Shell>
  </publishers>
  <buildWrappers>
    <hudson.plugins.timestamper.TimestamperBuildWrapper plugin="timestamper@1.20"/>
  </buildWrappers>
</project>
"@

    $jobConfigXml | Out-File -FilePath "job-config.xml" -Encoding UTF8
    Write-Host "✅ Job configuration XML created" -ForegroundColor Green
}

# Function to update job configuration
function Update-JobConfig {
    Write-Host "Updating job configuration..." -ForegroundColor Cyan
    try {
        $headers = @{
            'Content-Type' = 'application/xml'
        }
        
        $jobConfigContent = Get-Content -Path "job-config.xml" -Raw -Encoding UTF8
        
        $response = Invoke-WebRequest -Uri "$JenkinsUrl/job/$JobName/config.xml" -Method POST -Headers $headers -Body $jobConfigContent -UseBasicParsing -TimeoutSec 30
        
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Job configuration updated successfully" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ Failed to update job configuration. Status: $($response.StatusCode)" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "❌ Failed to update job configuration" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to check required plugins
function Test-RequiredPlugins {
    Write-Host "Checking required Jenkins plugins..." -ForegroundColor Cyan
    try {
        $response = Invoke-WebRequest -Uri "$JenkinsUrl/pluginManager/api/json?depth=1" -UseBasicParsing -TimeoutSec 10
        $plugins = $response.Content | ConvertFrom-Json
        
        $requiredPlugins = @("git", "htmlpublisher", "timestamper")
        
        foreach ($plugin in $requiredPlugins) {
            if ($plugins.plugins.name -contains $plugin) {
                Write-Host "✅ $plugin plugin is installed" -ForegroundColor Green
            } else {
                Write-Host "⚠️  $plugin plugin may not be installed" -ForegroundColor Yellow
            }
        }
    }
    catch {
        Write-Host "⚠️  Could not check plugins: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Function to provide manual configuration instructions
function Show-ManualConfigInstructions {
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host "Manual Configuration Instructions" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "If automatic configuration fails, follow these steps:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Open Jenkins in your browser: $JenkinsUrl" -ForegroundColor White
    Write-Host "2. Navigate to: $JenkinsUrl/job/$JobName/configure" -ForegroundColor White
    Write-Host ""
    Write-Host "3. Configure Source Code Management:" -ForegroundColor Cyan
    Write-Host "   - Select 'Git'" -ForegroundColor White
    Write-Host "   - Repository URL: https://github.com/your-username/jmeter-taurus-react-demo-docker.git" -ForegroundColor White
    Write-Host "   - Branch: */main" -ForegroundColor White
    Write-Host ""
    Write-Host "4. Add Build Parameters (check 'This project is parameterized'):" -ForegroundColor Cyan
    Write-Host "   - Choice Parameter: TAURUS_YAML_FILE" -ForegroundColor White
    Write-Host "   - Integer Parameter: THREAD_COUNT (1-100, default: 5)" -ForegroundColor White
    Write-Host "   - Integer Parameter: RAMP_UP_TIME (1-300, default: 5)" -ForegroundColor White
    Write-Host "   - Integer Parameter: HOLD_TIME (10-3600, default: 30)" -ForegroundColor White
    Write-Host "   - Integer Parameter: LOOP_COUNT (1-1000, default: 1)" -ForegroundColor White
    Write-Host "   - String Parameter: BASE_URL (default: http://localhost:3000)" -ForegroundColor White
    Write-Host "   - Boolean Parameter: START_APPLICATION (default: true)" -ForegroundColor White
    Write-Host "   - Boolean Parameter: STOP_APPLICATION (default: true)" -ForegroundColor White
    Write-Host ""
    Write-Host "5. Add Build Step:" -ForegroundColor Cyan
    Write-Host "   - Click 'Add build step' → 'Execute shell'" -ForegroundColor White
    Write-Host "   - Copy the shell script from the configuration" -ForegroundColor White
    Write-Host ""
    Write-Host "6. Add Post-build Actions:" -ForegroundColor Cyan
    Write-Host "   - Archive artifacts: taurus-result/**/*" -ForegroundColor White
    Write-Host "   - Publish HTML reports: taurus-result/index.html" -ForegroundColor White
    Write-Host ""
    Write-Host "7. Add Build Wrapper:" -ForegroundColor Cyan
    Write-Host "   - Check 'Add timestamps to the Console Output'" -ForegroundColor White
    Write-Host ""
    Write-Host "8. Save the configuration" -ForegroundColor White
    Write-Host ""
}

# Main execution
function Main {
    Write-Host "Starting Jenkins job configuration..." -ForegroundColor Green
    
    # Check Jenkins accessibility
    if (-not (Test-JenkinsAccess)) {
        Write-Host "Please ensure Jenkins is running and accessible" -ForegroundColor Red
        exit 1
    }
    
    # Check if job exists
    if (-not (Test-JobExists)) {
        Write-Host "Please create the job '$JobName' first in Jenkins" -ForegroundColor Red
        Show-ManualConfigInstructions
        exit 1
    }
    
    # Check plugins
    Test-RequiredPlugins
    
    # Create job configuration
    New-JobConfig
    
    # Update job configuration
    if (Update-JobConfig) {
        Write-Host ""
        Write-Host "🎉 Job configuration completed successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Yellow
        Write-Host "1. Visit: $JenkinsUrl/job/$JobName/" -ForegroundColor White
        Write-Host "2. Click 'Build with Parameters'" -ForegroundColor White
        Write-Host "3. Configure your test parameters" -ForegroundColor White
        Write-Host "4. Click 'Build' to run the test" -ForegroundColor White
        Write-Host ""
        Write-Host "Job URL: $JenkinsUrl/job/$JobName/" -ForegroundColor Cyan
    } else {
        Write-Host ""
        Write-Host "⚠️  Automatic configuration failed. Please use manual configuration:" -ForegroundColor Yellow
        Show-ManualConfigInstructions
    }
}

# Run main function
Main 