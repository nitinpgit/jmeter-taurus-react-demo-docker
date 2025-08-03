#!/bin/bash

echo "========================================"
echo "JMeter Test Runner (Local Machine)"
echo "========================================"
echo

# Check if JMeter is installed
if ! command -v jmeter &> /dev/null; then
    echo "ERROR: JMeter is not installed or not in PATH"
    echo "Please install JMeter from: https://jmeter.apache.org/download_jmeter.cgi"
    echo "Add JMeter bin directory to your PATH"
    exit 1
fi

echo "JMeter found at: $(which jmeter)"
echo

# Set JMeter home if not set
if [ -z "$JMETER_HOME" ]; then
    echo "Setting JMETER_HOME to current directory"
    export JMETER_HOME=$(pwd)
fi

echo "Available JMeter test files:"
echo
echo "1. get-quick-message.jmx"
echo "2. get-delayed-response.jmx"
echo "3. get-health-check.jmx"
echo "4. post-create-data.jmx"
echo "5. put-update-user.jmx"
echo "6. delete-user.jmx"
echo "7. get-search-with-parameter.jmx"
echo "8. test-plan.jmx (runs all tests)"
echo

read -p "Enter test number (1-8) or press Enter for quick message test: " choice

if [ -z "$choice" ]; then
    choice=1
fi

case $choice in
    1)
        TEST_FILE="jmeter/localhost3000/get-quick-message.jmx"
        TEST_NAME="Quick Message Test"
        ;;
    2)
        TEST_FILE="jmeter/localhost3000/get-delayed-response.jmx"
        TEST_NAME="Delayed Response Test"
        ;;
    3)
        TEST_FILE="jmeter/localhost3000/get-health-check.jmx"
        TEST_NAME="Health Check Test"
        ;;
    4)
        TEST_FILE="jmeter/localhost3000/post-create-data.jmx"
        TEST_NAME="Create Data Test"
        ;;
    5)
        TEST_FILE="jmeter/localhost3000/put-update-user.jmx"
        TEST_NAME="Update User Test"
        ;;
    6)
        TEST_FILE="jmeter/localhost3000/delete-user.jmx"
        TEST_NAME="Delete User Test"
        ;;
    7)
        TEST_FILE="jmeter/localhost3000/get-search-with-parameter.jmx"
        TEST_NAME="Search with Parameter Test"
        ;;
    8)
        TEST_FILE="jmeter/test-plan.jmx"
        TEST_NAME="Complete Test Plan"
        ;;
    *)
        echo "Invalid choice. Using quick message test."
        TEST_FILE="jmeter/localhost3000/get-quick-message.jmx"
        TEST_NAME="Quick Message Test"
        ;;
esac

echo
echo "Running: $TEST_NAME"
echo "Test file: $TEST_FILE"
echo

# Create results directory
mkdir -p jmeter-results

# Generate timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Run JMeter test
echo "Starting JMeter test..."
jmeter -n -t "$TEST_FILE" -l "jmeter-results/results_${TIMESTAMP}.jtl" -e -o "jmeter-results/html-report_${TIMESTAMP}"

if [ $? -eq 0 ]; then
    echo
    echo "========================================"
    echo "Test completed successfully!"
    echo "========================================"
    echo "Results saved to: jmeter-results/"
    echo "HTML report generated in: jmeter-results/html-report_${TIMESTAMP}"
    echo
    echo "Opening HTML report..."
    if command -v xdg-open &> /dev/null; then
        xdg-open "jmeter-results/html-report_${TIMESTAMP}/index.html"
    elif command -v open &> /dev/null; then
        open "jmeter-results/html-report_${TIMESTAMP}/index.html"
    else
        echo "Please open: jmeter-results/html-report_${TIMESTAMP}/index.html"
    fi
else
    echo
    echo "========================================"
    echo "Test failed with error code: $?"
    echo "========================================"
fi

echo 