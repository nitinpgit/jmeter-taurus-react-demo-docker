# Jenkins Freestyle Job Setup for Taurus Performance Testing

This guide provides detailed steps to set up a Jenkins freestyle project that runs Taurus performance tests against your Docker-based frontend and backend applications with persistent data storage.

## Prerequisites

- Docker and Docker Compose installed
- Git repository with your application code
- Jenkins server (can be run via Docker as provided in this setup)
- Basic knowledge of Jenkins and Docker

## Project Structure

```
jmeter-taurus-react-demo-docker/
├── frontend/                 # React frontend application
├── backend/                  # Node.js backend application
├── taurus/                   # Taurus test configurations
├── jenkins-data/            # Persistent Jenkins data (created by setup script)
├── app-data/                # Application persistent data
├── test-data/               # Test data persistence
├── docker-compose.yml       # Basic Docker Compose
├── docker-compose-persistent.yml  # Enhanced with data persistence
├── jenkins-job-config.xml   # Jenkins job configuration
├── setup-persistent-data.sh # Setup script for persistent data
└── JENKINS_SETUP_GUIDE.md   # This guide
```

## Step-by-Step Setup Instructions

### Step 1: Initialize Persistent Data Directories

Run the setup script to create persistent data directories:

```bash
# Make the script executable
chmod +x setup-persistent-data.sh

# Run the setup script
./setup-persistent-data.sh
```

This creates the following directory structure:
- `jenkins-data/` - Jenkins home, workspace, and test results
- `app-data/` - Application data and logs
- `test-data/` - JMeter and Taurus data

### Step 2: Start the Jenkins Environment

Use the enhanced Docker Compose file for better data persistence:

```bash
# Start all services with persistent data
docker-compose -f docker-compose-persistent.yml up -d

# Verify all containers are running
docker-compose -f docker-compose-persistent.yml ps
```

### Step 3: Access Jenkins and Install Required Plugins

1. **Access Jenkins**: Open your browser and go to `http://localhost:8080`

2. **Initial Setup**: 
   - Get the initial admin password from: `docker-compose -f docker-compose-persistent.yml logs jenkins`
   - Follow the Jenkins setup wizard

3. **Install Required Plugins**:
   - Go to **Manage Jenkins** → **Manage Plugins** → **Available**
   - Install the following plugins:
     - Git plugin
     - Pipeline plugin
     - JUnit plugin
     - HTML Publisher plugin
     - Email Extension plugin
     - Timestamper plugin
     - AnsiColor plugin
     - Docker plugin
     - Docker Pipeline plugin

### Step 4: Configure Jenkins Global Tools

1. **Configure Git**:
   - Go to **Manage Jenkins** → **Global Tool Configuration**
   - Add Git installation (use default settings)

2. **Configure Docker**:
   - Ensure Docker is accessible from Jenkins container
   - The Docker socket is already mounted in the compose file

### Step 5: Create Jenkins Credentials

1. **Git Credentials** (if using private repository):
   - Go to **Manage Jenkins** → **Manage Credentials**
   - Add your Git credentials (SSH key or username/password)

2. **Email Configuration** (optional):
   - Configure SMTP settings for email notifications

### Step 6: Create the Freestyle Job

#### Option A: Using the Provided Configuration File

1. **Create New Job**:
   - Click **New Item** in Jenkins
   - Enter job name (e.g., "Taurus Performance Tests")
   - Select **Freestyle project**
   - Click **OK**

2. **Import Configuration**:
   - Copy the contents of `jenkins-job-config.xml`
   - Go to **Manage Jenkins** → **Manage Configuration as Code**
   - Or manually configure using the XML structure

#### Option B: Manual Configuration

1. **General Settings**:
   - **Description**: "Jenkins Freestyle Job for Taurus Performance Testing with Docker Applications"
   - **Discard old builds**: Keep 30 days, keep 50 builds
   - **This project is parameterized**: Check this box

2. **Parameters**:
   - **String Parameter**: `TAURUS_TEST_FILE` (default: `test.yml`)
   - **String Parameter**: `TEST_DURATION` (default: `60`)
   - **String Parameter**: `CONCURRENT_USERS` (default: `5`)
   - **Boolean Parameter**: `CLEANUP_CONTAINERS` (default: `false`)

3. **Source Code Management**:
   - Select **Git**
   - Repository URL: Your Git repository URL
   - Credentials: Select your Git credentials
   - Branch: `*/main`

4. **Build Triggers**:
   - **Poll SCM**: `H/15 * * * *` (every 15 minutes)

5. **Build Environment**:
   - **Add timestamps to the Console Output**
   - **Color ANSI Console Output**

6. **Build Steps**:
   - **Execute shell**: Use the shell script from the configuration file

7. **Post-build Actions**:
   - **Publish JUnit test result report**: `test-results/*.xml`
   - **Archive the artifacts**: `test-results/**`
   - **Publish HTML reports**: `test-results` with `*.html` files
   - **Editable Email Notification**: Configure email notifications

### Step 7: Configure the Build Script

The build script performs the following steps:

1. **Stop existing containers** (if any)
2. **Build and start application containers** (frontend, backend)
3. **Wait for applications to be ready** (health checks)
4. **Update Taurus test configuration** with build parameters
5. **Run Taurus tests**
6. **Copy test results** to workspace
7. **Generate test summary**
8. **Optional cleanup** of containers

### Step 8: Test the Job

1. **Run the Job**:
   - Click **Build with Parameters**
   - Set your desired parameters
   - Click **Build**

2. **Monitor the Build**:
   - Click on the build number to view progress
   - Check the console output for detailed logs

3. **View Results**:
   - After completion, view test results in the build artifacts
   - Check the HTML reports for detailed performance metrics

## Data Persistence Features

### What Data is Preserved

1. **Jenkins Data**:
   - Jenkins home directory (configurations, plugins, jobs)
   - Workspace files
   - Test results and artifacts

2. **Application Data**:
   - Backend application data
   - Frontend logs
   - Application logs

3. **Test Data**:
   - JMeter configurations and data
   - Taurus configurations and results
   - Historical test results

### Data Location

- **Jenkins Home**: `./jenkins-data/home/`
- **Jenkins Workspace**: `./jenkins-data/workspace/`
- **Test Results**: `./jenkins-data/test-results/`
- **Application Data**: `./app-data/`
- **Test Data**: `./test-data/`

## Available Taurus Test Files

The job supports multiple Taurus test configurations:

- `test.yml` - Main test suite (default)
- `get-quick-message.yml` - Quick message endpoint test
- `get-delayed-response.yml` - Delayed response test
- `post-create-data.yml` - POST data creation test

## Customization Options

### Test Parameters

- **TAURUS_TEST_FILE**: Choose which test file to run
- **TEST_DURATION**: Set test duration in seconds
- **CONCURRENT_USERS**: Set number of concurrent users
- **CLEANUP_CONTAINERS**: Whether to stop containers after test

### Adding New Test Scenarios

1. Create new Taurus test files in the `taurus/` directory
2. Follow the existing format and structure
3. The job will automatically pick up new test files

### Modifying Application Endpoints

1. Update the backend API endpoints in `backend/server.js`
2. Update the frontend configuration if needed
3. Update Taurus test files to match new endpoints

## Troubleshooting

### Common Issues

1. **Container Startup Issues**:
   ```bash
   # Check container logs
   docker-compose -f docker-compose-persistent.yml logs [service-name]
   
   # Restart specific service
   docker-compose -f docker-compose-persistent.yml restart [service-name]
   ```

2. **Permission Issues**:
   ```bash
   # Fix permissions for Jenkins data
   sudo chown -R 1000:1000 jenkins-data/
   ```

3. **Port Conflicts**:
   - Ensure ports 3000, 5000, 8080 are available
   - Modify ports in docker-compose file if needed

4. **Git Repository Issues**:
   - Verify Git credentials in Jenkins
   - Check repository URL and branch name

### Health Checks

The build script includes health checks for:
- Backend API: `http://localhost:5000/api/health`
- Frontend: `http://localhost:3000`

### Logs and Debugging

- **Jenkins Logs**: `docker-compose -f docker-compose-persistent.yml logs jenkins`
- **Application Logs**: Check `app-data/logs/` directory
- **Test Logs**: Available in build artifacts and `test-data/` directory

## Best Practices

1. **Regular Backups**: Backup the `jenkins-data/` directory regularly
2. **Resource Monitoring**: Monitor Docker resource usage during tests
3. **Test Data Management**: Clean up old test results periodically
4. **Security**: Use proper credentials and avoid hardcoding sensitive data
5. **Scaling**: Consider using Jenkins agents for distributed testing

## Advanced Configuration

### Using Jenkins Pipeline

For more complex workflows, consider converting to a Jenkins Pipeline:

```groovy
pipeline {
    agent any
    parameters {
        string(name: 'TAURUS_TEST_FILE', defaultValue: 'test.yml')
        string(name: 'TEST_DURATION', defaultValue: '60')
        string(name: 'CONCURRENT_USERS', defaultValue: '5')
        booleanParam(name: 'CLEANUP_CONTAINERS', defaultValue: false)
    }
    stages {
        stage('Setup') {
            steps {
                // Setup steps
            }
        }
        stage('Deploy Applications') {
            steps {
                // Deploy frontend and backend
            }
        }
        stage('Run Tests') {
            steps {
                // Run Taurus tests
            }
        }
        stage('Collect Results') {
            steps {
                // Collect and archive results
            }
        }
    }
    post {
        always {
            // Cleanup steps
        }
    }
}
```

### Integration with External Tools

- **Grafana**: For performance monitoring dashboards
- **Prometheus**: For metrics collection
- **Slack/Teams**: For notifications
- **JIRA**: For test case management

## Support and Maintenance

### Regular Maintenance Tasks

1. **Update Jenkins Plugins**: Monthly
2. **Clean Old Builds**: Weekly
3. **Backup Jenkins Data**: Daily
4. **Update Docker Images**: As needed
5. **Review Test Results**: After each test run

### Monitoring

- Monitor Jenkins build queue and performance
- Track test execution times and success rates
- Monitor Docker resource usage
- Review application logs for errors

This setup provides a robust, persistent, and scalable environment for running Taurus performance tests with your Docker applications through Jenkins. 