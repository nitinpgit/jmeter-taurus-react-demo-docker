#!/bin/bash

# Jenkins Freestyle Job Configuration Script
# This script configures the jmeter-freestyle job with Taurus performance testing

set -e

# Jenkins configuration
JENKINS_URL="http://localhost:8080"
JOB_NAME="jmeter-freestyle"
CONTAINER_ID="3d0960f900f812920d9b8ba580d7ff59f308583aa43a01f0abf35ed20586ebdc"

echo "=========================================="
echo "Jenkins Freestyle Job Configuration"
echo "=========================================="
echo "Jenkins URL: $JENKINS_URL"
echo "Job Name: $JOB_NAME"
echo "Container ID: $CONTAINER_ID"
echo "=========================================="

# Function to check if Jenkins is accessible
check_jenkins() {
    echo "Checking Jenkins accessibility..."
    if curl -f -s "$JENKINS_URL" >/dev/null 2>&1; then
        echo "✅ Jenkins is accessible"
        return 0
    else
        echo "❌ Jenkins is not accessible at $JENKINS_URL"
        return 1
    fi
}

# Function to check if job exists
check_job_exists() {
    echo "Checking if job '$JOB_NAME' exists..."
    if curl -f -s "$JENKINS_URL/job/$JOB_NAME/" >/dev/null 2>&1; then
        echo "✅ Job '$JOB_NAME' exists"
        return 0
    else
        echo "❌ Job '$JOB_NAME' does not exist"
        return 1
    fi
}

# Function to create job configuration XML
create_job_config() {
    echo "Creating job configuration XML..."
    
    cat > job-config.xml << 'EOF'
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
          <choices class="java.util.Arrays$ArrayList">
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
if [ "$STOP_APPLICATION" = "true" ]; then
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
EOF

    echo "✅ Job configuration XML created"
}

# Function to update job configuration
update_job_config() {
    echo "Updating job configuration..."
    
    if curl -f -X POST \
        -H "Content-Type: application/xml" \
        --data-binary @job-config.xml \
        "$JENKINS_URL/job/$JOB_NAME/config.xml"; then
        echo "✅ Job configuration updated successfully"
    else
        echo "❌ Failed to update job configuration"
        return 1
    fi
}

# Function to check required plugins
check_plugins() {
    echo "Checking required Jenkins plugins..."
    
    # Check if Git plugin is available
    if curl -f -s "$JENKINS_URL/pluginManager/api/json?depth=1" | grep -q "git"; then
        echo "✅ Git plugin is installed"
    else
        echo "⚠️  Git plugin may not be installed"
    fi
    
    # Check if HTML Publisher plugin is available
    if curl -f -s "$JENKINS_URL/pluginManager/api/json?depth=1" | grep -q "htmlpublisher"; then
        echo "✅ HTML Publisher plugin is installed"
    else
        echo "⚠️  HTML Publisher plugin may not be installed"
    fi
    
    # Check if Timestamper plugin is available
    if curl -f -s "$JENKINS_URL/pluginManager/api/json?depth=1" | grep -q "timestamper"; then
        echo "✅ Timestamper plugin is installed"
    else
        echo "⚠️  Timestamper plugin may not be installed"
    fi
}

# Function to provide manual configuration instructions
manual_config_instructions() {
    echo ""
    echo "=========================================="
    echo "Manual Configuration Instructions"
    echo "=========================================="
    echo ""
    echo "If automatic configuration fails, follow these steps:"
    echo ""
    echo "1. Open Jenkins in your browser: $JENKINS_URL"
    echo "2. Navigate to: $JENKINS_URL/job/$JOB_NAME/configure"
    echo ""
    echo "3. Configure Source Code Management:"
    echo "   - Select 'Git'"
    echo "   - Repository URL: https://github.com/your-username/jmeter-taurus-react-demo-docker.git"
    echo "   - Branch: */main"
    echo ""
    echo "4. Add Build Parameters (check 'This project is parameterized'):"
    echo "   - Choice Parameter: TAURUS_YAML_FILE"
    echo "   - Integer Parameter: THREAD_COUNT (1-100, default: 5)"
    echo "   - Integer Parameter: RAMP_UP_TIME (1-300, default: 5)"
    echo "   - Integer Parameter: HOLD_TIME (10-3600, default: 30)"
    echo "   - Integer Parameter: LOOP_COUNT (1-1000, default: 1)"
    echo "   - String Parameter: BASE_URL (default: http://localhost:3000)"
    echo "   - Boolean Parameter: START_APPLICATION (default: true)"
    echo "   - Boolean Parameter: STOP_APPLICATION (default: true)"
    echo ""
    echo "5. Add Build Step:"
    echo "   - Click 'Add build step' → 'Execute shell'"
    echo "   - Copy the shell script from the configuration"
    echo ""
    echo "6. Add Post-build Actions:"
    echo "   - Archive artifacts: taurus-result/**/*"
    echo "   - Publish HTML reports: taurus-result/index.html"
    echo ""
    echo "7. Add Build Wrapper:"
    echo "   - Check 'Add timestamps to the Console Output'"
    echo ""
    echo "8. Save the configuration"
    echo ""
}

# Main execution
main() {
    echo "Starting Jenkins job configuration..."
    
    # Check Jenkins accessibility
    if ! check_jenkins; then
        echo "Please ensure Jenkins is running and accessible"
        exit 1
    fi
    
    # Check if job exists
    if ! check_job_exists; then
        echo "Please create the job '$JOB_NAME' first in Jenkins"
        manual_config_instructions
        exit 1
    fi
    
    # Check plugins
    check_plugins
    
    # Create job configuration
    create_job_config
    
    # Update job configuration
    if update_job_config; then
        echo ""
        echo "🎉 Job configuration completed successfully!"
        echo ""
        echo "Next steps:"
        echo "1. Visit: $JENKINS_URL/job/$JOB_NAME/"
        echo "2. Click 'Build with Parameters'"
        echo "3. Configure your test parameters"
        echo "4. Click 'Build' to run the test"
        echo ""
        echo "Job URL: $JENKINS_URL/job/$JOB_NAME/"
    else
        echo ""
        echo "⚠️  Automatic configuration failed. Please use manual configuration:"
        manual_config_instructions
    fi
}

# Run main function
main 