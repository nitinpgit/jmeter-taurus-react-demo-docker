#!/bin/bash

echo "========================================"
echo "Taurus Test Runner (Local Machine)"
echo "========================================"
echo

# Check if Taurus is installed
if ! command -v bzt &> /dev/null; then
    echo "ERROR: Taurus is not installed or not in PATH"
    echo "Please install Taurus using one of these methods:"
    echo
    echo "Method 1 - Using pip:"
    echo "  pip install bzt"
    echo
    echo "Method 2 - Using Docker:"
    echo "  docker run --rm -v \$(pwd):/bzt blazemeter/taurus:latest"
    echo
    echo "Method 3 - Download from: https://gettaurus.org/install/Installation/"
    echo
    exit 1
fi

echo "Taurus found at: $(which bzt)"
echo

echo "Available Taurus test files:"
echo
echo "1. get-quick-message.yml"
echo "2. get-delayed-response.yml"
echo "3. post-create-data.yml"
echo "4. test.yml (complete test suite)"
echo

read -p "Enter test number (1-4) or press Enter for quick message test: " choice

if [ -z "$choice" ]; then
    choice=1
fi

case $choice in
    1)
        TEST_FILE="taurus/get-quick-message.yml"
        TEST_NAME="Quick Message Test"
        ;;
    2)
        TEST_FILE="taurus/get-delayed-response.yml"
        TEST_NAME="Delayed Response Test"
        ;;
    3)
        TEST_FILE="taurus/post-create-data.yml"
        TEST_NAME="Create Data Test"
        ;;
    4)
        TEST_FILE="taurus/test.yml"
        TEST_NAME="Complete Test Suite"
        ;;
    *)
        echo "Invalid choice. Using quick message test."
        TEST_FILE="taurus/get-quick-message.yml"
        TEST_NAME="Quick Message Test"
        ;;
esac

echo
echo "Running: $TEST_NAME"
echo "Test file: $TEST_FILE"
echo

# Create results directory
mkdir -p taurus-results

# Set BlazeMeter credentials (optional - for cloud reporting)
export BLAZEMETER_TOKEN="1f57f44b33ab29df65126dc1"
export BLAZEMETER_SECRET="c0d07b2ae9f8d63d3806520dd79eeb69c26ea1376775ea743e81bcb091be3ddf5d03e559"
export BLAZEMETER_WORKSPACE_ID="2229371"

echo "BlazeMeter credentials set for cloud reporting"
echo

# Run Taurus test
echo "Starting Taurus test..."
bzt "$TEST_FILE"

if [ $? -eq 0 ]; then
    echo
    echo "========================================"
    echo "Test completed successfully!"
    echo "========================================"
    echo "Results saved to: taurus-results/"
    echo
    echo "If you have BlazeMeter credentials configured, check your dashboard:"
    echo "https://a.blazemeter.com/app/#/projects"
else
    echo
    echo "========================================"
    echo "Test failed with error code: $?"
    echo "========================================"
fi

echo 