#!/bin/sh -xe

WORKDIR=$(pwd)
echo "Using workdir: $WORKDIR"

# Check if taurus directory exists and has files
echo "Checking taurus directory:"
ls -la taurus/ || echo "taurus directory not found or empty"

# Copy files from host taurus directory to workspace
echo "Copying files from host taurus directory..."
cp -r /var/jenkins_home/workspace/taurus-tests-freestyle/taurus/* . 2>/dev/null || echo "Could not copy from workspace taurus directory"

# If that didn't work, try copying from the host path
if [ ! -f "get-quick-message.yml" ]; then
    echo "Trying to copy from host path..."
    # This assumes the host taurus directory is mounted somewhere accessible
    find /var/jenkins_home -name "get-quick-message.yml" -exec cp {} . \; 2>/dev/null || echo "Could not find get-quick-message.yml"
fi

echo "Current directory contents:"
ls -la

# If we still don't have the file, create it manually
if [ ! -f "get-quick-message.yml" ]; then
    echo "Creating get-quick-message.yml manually..."
    cat > get-quick-message.yml << 'EOF'
artifacts-dir: ./taurus-result

execution:
  - concurrency: 5
    hold-for: 30s
    ramp-up: 5s
    scenario: get-quick-message

scenarios:
  get-quick-message:
    requests:
      - url: http://frontend/api/message
        method: GET
        headers:
          Accept: application/json

reporting:
  - module: console
  - module: final-stats
  - module: junit-xml
    filename: ./taurus-result/taurus-report.xml
  - module: blazemeter
    report-name: "Taurus Get Message"
    test: "get-message-test"
EOF
fi

echo "Testing file existence:"
ls -la get-quick-message.yml

# Create the file inside the container and run Taurus
echo "Creating Taurus config inside container and running test..."
docker run --rm \
  --network jmeter-taurus-react-demo-docker_default \
  --entrypoint sh \
  blazemeter/taurus -c "
cat > /tmp/get-quick-message.yml << 'EOF'
$(cat get-quick-message.yml)
EOF
echo 'Config file created:'
cat /tmp/get-quick-message.yml
echo '---'
bzt /tmp/get-quick-message.yml
" 