pipeline {
    agent any
    
    parameters {
        choice(
            name: 'YAML_FILE',
            choices: [
                'taurus/get-quick-message.yml',
                'taurus/get-delayed-response.yml',
                'taurus/post-create-data.yml',
                'taurus/test.yml'
            ],
            description: 'Select Taurus YAML configuration file'
        )
        string(
            name: 'THREADS',
            defaultValue: '10',
            description: 'Number of concurrent users'
        )
        string(
            name: 'RAMPUP',
            defaultValue: '30',
            description: 'Ramp-up time in seconds'
        )
        string(
            name: 'DURATION',
            defaultValue: '60',
            description: 'Test duration in seconds'
        )
        string(
            name: 'TARGET_URL',
            defaultValue: 'http://host.docker.internal:3000',
            description: 'Target application URL'
        )
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'staging', 'prod'],
            description: 'Test environment'
        )
    }
    
    environment {
        JMETER_HOME = '/opt/apache-jmeter-5.6.3'
        PATH = "/opt/apache-jmeter-5.6.3/bin:/opt/taurus/bin:${env.PATH}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Validate Parameters') {
            steps {
                script {
                    // Validate numeric parameters
                    if (!params.THREADS.isNumber()) {
                        error "THREADS must be a number. Got: ${params.THREADS}"
                    }
                    if (!params.RAMPUP.isNumber()) {
                        error "RAMPUP must be a number. Got: ${params.RAMPUP}"
                    }
                    if (!params.DURATION.isNumber()) {
                        error "DURATION must be a number. Got: ${params.DURATION}"
                    }
                    
                    echo "Parameter validation passed:"
                    echo "YAML_FILE: ${params.YAML_FILE}"
                    echo "THREADS: ${params.THREADS}"
                    echo "RAMPUP: ${params.RAMPUP}"
                    echo "DURATION: ${params.DURATION}"
                    echo "TARGET_URL: ${params.TARGET_URL}"
                    echo "ENVIRONMENT: ${params.ENVIRONMENT}"
                }
            }
        }
        
        stage('Create Dynamic Config') {
            steps {
                script {
                    // Create dynamic Taurus configuration
                    sh """
                        cat > dynamic-test.yml << 'EOF'
execution:
  - concurrency: ${params.THREADS}
    ramp-up: ${params.RAMPUP}s
    hold-for: ${params.DURATION}s
    scenario: main

scenarios:
  main:
    requests:
      - url: ${params.TARGET_URL}
        method: GET
        label: health-check

modules:
  jmeter:
    path: /opt/apache-jmeter-5.6.3/bin/jmeter

reporting:
  - module: final-stats
  - module: console
  - module: passfail
    criteria:
      - avg-rt<2000ms
      - p95<5000ms
      - fail<10%

settings:
  env: ${params.ENVIRONMENT}
EOF
                        
                        echo "Dynamic Taurus configuration created:"
                        cat dynamic-test.yml
                    """
                }
            }
        }
        
        stage('Run Taurus Test') {
            steps {
                script {
                    sh """
                        mkdir -p taurus-result
                        
                        echo "Starting Taurus test with:"
                        echo "YAML: ${params.YAML_FILE}"
                        echo "Threads: ${params.THREADS}"
                        echo "Ramp-up: ${params.RAMPUP}s"
                        echo "Duration: ${params.DURATION}s"
                        echo "Target: ${params.TARGET_URL}"
                        echo "Environment: ${params.ENVIRONMENT}"
                        
                        bzt -o modules.jmeter.path=/opt/apache-jmeter-5.6.3/bin/jmeter \\
                            -o execution.0.concurrency=${params.THREADS} \\
                            -o execution.0.ramp-up=${params.RAMPUP}s \\
                            -o execution.0.hold-for=${params.DURATION}s \\
                            -o scenarios.main.requests.0.url=${params.TARGET_URL} \\
                            ${params.YAML_FILE}
                    """
                }
            }
        }
        
        stage('Process Results') {
            steps {
                script {
                    sh """
                        # Find Taurus artifacts directory
                        TAURUS_ARTIFACTS_DIR=\$(find . -maxdepth 1 -type d -name "*_*" | grep -E "[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2}" | head -1)
                        
                        if [ -n "\$TAURUS_ARTIFACTS_DIR" ]; then
                            echo "Found Taurus artifacts in: \$TAURUS_ARTIFACTS_DIR"
                            
                            # Copy all files from Taurus artifacts to our results directory
                            cp -r "\$TAURUS_ARTIFACTS_DIR"/* taurus-result/ 2>/dev/null || true
                            
                            # Create a summary file
                            echo "Test Summary" > taurus-result/test-summary.txt
                            echo "============" >> taurus-result/test-summary.txt
                            echo "YAML File: ${params.YAML_FILE}" >> taurus-result/test-summary.txt
                            echo "Threads: ${params.THREADS}" >> taurus-result/test-summary.txt
                            echo "Ramp-up: ${params.RAMPUP} seconds" >> taurus-result/test-summary.txt
                            echo "Duration: ${params.DURATION} seconds" >> taurus-result/test-summary.txt
                            echo "Target URL: ${params.TARGET_URL}" >> taurus-result/test-summary.txt
                            echo "Environment: ${params.ENVIRONMENT}" >> taurus-result/test-summary.txt
                            echo "Build Number: ${env.BUILD_NUMBER}" >> taurus-result/test-summary.txt
                            echo "Build Time: \$(date)" >> taurus-result/test-summary.txt
                            
                            echo "Results copied to taurus-result directory"
                            ls -la taurus-result/
                        else
                            echo "Warning: Could not find Taurus artifacts directory"
                            # Create a basic summary anyway
                            echo "Test Summary" > taurus-result/test-summary.txt
                            echo "============" >> taurus-result/test-summary.txt
                            echo "YAML File: ${params.YAML_FILE}" >> taurus-result/test-summary.txt
                            echo "Threads: ${params.THREADS}" >> taurus-result/test-summary.txt
                            echo "Ramp-up: ${params.RAMPUP} seconds" >> taurus-result/test-summary.txt
                            echo "Duration: ${params.DURATION} seconds" >> taurus-result/test-summary.txt
                            echo "Target URL: ${params.TARGET_URL}" >> taurus-result/test-summary.txt
                            echo "Environment: ${params.ENVIRONMENT}" >> taurus-result/test-summary.txt
                            echo "Build Number: ${env.BUILD_NUMBER}" >> taurus-result/test-summary.txt
                            echo "Build Time: \$(date)" >> taurus-result/test-summary.txt
                        fi
                    """
                }
            }
        }
    }
    
    post {
        always {
            // Archive artifacts
            archiveArtifacts artifacts: 'taurus-result/**/*', fingerprint: true
            
            // Publish test results
            publishTestResults testResultsPattern: 'taurus-result/**/*.xml'
            
            // Clean up workspace
            cleanWs()
        }
        success {
            echo "🎉 Taurus test completed successfully!"
            script {
                // Send notification or update status
                currentBuild.description = "✅ ${params.ENVIRONMENT.toUpperCase()} - ${params.THREADS} threads, ${params.DURATION}s duration"
            }
        }
        failure {
            echo "❌ Taurus test failed!"
            script {
                currentBuild.description = "❌ ${params.ENVIRONMENT.toUpperCase()} - Test Failed"
            }
        }
        unstable {
            echo "⚠️ Taurus test completed with warnings!"
            script {
                currentBuild.description = "⚠️ ${params.ENVIRONMENT.toUpperCase()} - Test Unstable"
            }
        }
    }
} 