# Parameterized Taurus Performance Testing - Jenkins Freestyle Setup

This guide explains how to set up a Jenkins freestyle project that allows you to select Taurus YAML files and configure test parameters through a user-friendly interface.

## 🎯 Features

✅ **YAML File Dropdown** - Select from available Taurus test files  
✅ **Thread Count** - Configure number of concurrent users  
✅ **Ramp-up Time** - Set how quickly to ramp up users  
✅ **Hold Time** - Define test duration  
✅ **Loop Count** - Set iterations per user  
✅ **Base URL** - Configure target application URL  
✅ **Application Control** - Start/stop application automatically  

## 📋 Prerequisites

### Jenkins Server Requirements
- Jenkins 2.387+ (LTS recommended)
- Docker and Docker Compose installed on Jenkins server
- Python 3.7+ installed on Jenkins server

### Required Jenkins Plugins
1. **Git plugin** - For source code management
2. **HTML Publisher plugin** - For publishing test reports
3. **Timestamper plugin** - For timestamped logs
4. **Parameterized Trigger plugin** - For parameterized builds

## 🚀 Setup Instructions

### Step 1: Create New Freestyle Project

1. Go to Jenkins Dashboard
2. Click "New Item"
3. Enter job name (e.g., "Taurus-Parameterized-Tests")
4. Select "Freestyle project"
5. Click "OK"

### Step 2: Configure Source Code Management

1. In the job configuration, scroll to "Source Code Management"
2. Select "Git"
3. Enter your repository URL
4. Set branch to `*/main` (or your default branch)
5. Save the configuration

### Step 3: Add Build Parameters

1. Check "This project is parameterized"
2. Add the following parameters:

#### YAML File Selection (Dropdown)
- **Parameter Type:** Choice Parameter
- **Name:** `TAURUS_YAML_FILE`
- **Description:** Select the Taurus YAML file to execute
- **Choices:**
  ```
  taurus/get-quick-message.yml
  taurus/post-create-data.yml
  taurus/get-delayed-response.yml
  taurus/test.yml
  ```

#### Thread Count (Integer)
- **Parameter Type:** Integer Parameter
- **Name:** `THREAD_COUNT`
- **Description:** Number of concurrent users (threads)
- **Default Value:** `5`
- **Min:** `1`
- **Max:** `100`

#### Ramp-up Time (Integer)
- **Parameter Type:** Integer Parameter
- **Name:** `RAMP_UP_TIME`
- **Description:** Ramp-up time in seconds
- **Default Value:** `5`
- **Min:** `1`
- **Max:** `300`

#### Hold Time (Integer)
- **Parameter Type:** Integer Parameter
- **Name:** `HOLD_TIME`
- **Description:** Test duration in seconds
- **Default Value:** `30`
- **Min:** `10`
- **Max:** `3600`

#### Loop Count (Integer)
- **Parameter Type:** Integer Parameter
- **Name:** `LOOP_COUNT`
- **Description:** Number of iterations per user
- **Default Value:** `1`
- **Min:** `1`
- **Max:** `1000`

#### Base URL (String)
- **Parameter Type:** String Parameter
- **Name:** `BASE_URL`
- **Description:** Base URL for the application
- **Default Value:** `http://localhost:3000`

#### Start Application (Boolean)
- **Parameter Type:** Boolean Parameter
- **Name:** `START_APPLICATION`
- **Description:** Start the application using Docker Compose
- **Default Value:** `true`

#### Stop Application (Boolean)
- **Parameter Type:** Boolean Parameter
- **Name:** `STOP_APPLICATION`
- **Description:** Stop the application after test completion
- **Default Value:** `true`

### Step 4: Add Build Step

1. Scroll to "Build" section
2. Click "Add build step" → "Execute shell"
3. Copy and paste the shell script from the configuration file

### Step 5: Add Post-build Actions

#### Archive Artifacts
1. Click "Add post-build action" → "Archive the artifacts"
2. Set "Files to archive" to: `taurus-result/**/*`
3. Check "Allow empty archive"

#### Publish HTML Reports
1. Click "Add post-build action" → "Publish HTML reports"
2. Set "HTML directory to archive" to: `taurus-result`
3. Set "Index page[s]" to: `index.html`
4. Set "Report title" to: `Taurus Test Report`
5. Check "Keep past HTML reports"

### Step 6: Add Build Wrapper

1. Scroll to "Build Environment"
2. Check "Add timestamps to the Console Output"

## 🎮 How to Use

### Running the Job

1. **Navigate to your job** in Jenkins
2. **Click "Build with Parameters"**
3. **Configure your test parameters:**

#### Example Configurations

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

### Understanding the Output

#### Build Parameters
The job will display all selected parameters at the start:
```
Test Configuration:
- YAML File: taurus/get-quick-message.yml
- Thread Count: 5
- Ramp-up Time: 5 seconds
- Hold Time: 30 seconds
- Loop Count: 1
- Base URL: http://localhost:3000
```

#### Modified YAML
The job creates a temporary YAML file with your parameters:
```yaml
execution:
  - concurrency: 5
    ramp-up: 5s
    hold-for: 30s
    iterations: 1
    scenario: get-quick-message
```

#### Test Results
- **HTML Reports:** Available in the build page
- **Artifacts:** Downloadable test results
- **Console Log:** Full execution details with timestamps

## 🔧 Customization

### Adding New YAML Files

1. **Add your YAML file** to the `taurus/` directory
2. **Update the dropdown choices** in the job configuration:
   ```
   taurus/get-quick-message.yml
   taurus/post-create-data.yml
   taurus/get-delayed-response.yml
   taurus/test.yml
   taurus/your-new-test.yml
   ```

### Modifying Parameter Ranges

Adjust the min/max values in the job configuration:
- **Thread Count:** 1-200 (for high-load testing)
- **Ramp-up Time:** 1-600 (for longer ramp-up periods)
- **Hold Time:** 10-7200 (for extended test duration)

### Environment-Specific URLs

Use different base URLs for different environments:
- **Development:** `http://localhost:3000`
- **Staging:** `http://staging-app.example.com`
- **Production:** `http://prod-app.example.com`

## 📊 Test Reports

### Available Reports
- **HTML Reports:** Interactive Taurus reports with charts and metrics
- **Summary Report:** Text summary with test configuration and results
- **Console Output:** Detailed execution log with timestamps
- **Artifacts:** All test files and results for download

### Report Locations
- **Jenkins Build Page:** HTML reports and artifacts
- **Workspace:** `taurus-result/` directory
- **Console Log:** Full execution details

## 🛠️ Troubleshooting

### Common Issues

1. **YAML file not found:**
   ```
   Error: Test file taurus/xxx.yml not found
   ```
   **Solution:** Ensure the YAML file exists in the repository

2. **Parameter validation fails:**
   ```
   Invalid parameter value
   ```
   **Solution:** Check parameter ranges and ensure valid values

3. **Application fails to start:**
   ```
   Application failed to start properly
   ```
   **Solution:** Check Docker Compose logs and port availability

4. **Taurus installation fails:**
   ```
   Error: pip not found
   ```
   **Solution:** Install Python and pip on Jenkins server

### Debugging Steps

1. **Check parameter values** in the build log
2. **Verify YAML file modification** in the console output
3. **Review Taurus execution** for test-specific errors
4. **Check application logs** if startup fails

## 🎯 Best Practices

1. **Use descriptive job names** for easy identification
2. **Set appropriate parameter ranges** to prevent invalid values
3. **Archive artifacts** to preserve test results
4. **Use timestamps** for better log analysis
5. **Monitor resource usage** during high-load tests
6. **Clean up resources** after test completion
7. **Document test scenarios** for team reference

## 🔄 Automation

### Scheduled Builds
Add build triggers for automated testing:
- **Poll SCM:** Check for code changes
- **Build periodically:** Run tests on schedule
- **Trigger builds remotely:** External triggers

### Pipeline Integration
Use this job as a step in larger pipelines:
- **Multi-stage testing** with different parameters
- **Environment promotion** with increasing load
- **Regression testing** with consistent parameters

## 📈 Advanced Features

### Dynamic Parameter Loading
For more advanced setups, you can:
- **Scan directory** for available YAML files
- **Load parameters** from external configuration
- **Validate parameters** before execution
- **Generate reports** with custom metrics

### Integration with Other Tools
- **JMeter integration** for complex scenarios
- **Grafana dashboards** for real-time monitoring
- **Slack notifications** for test completion
- **Email reports** for stakeholders 