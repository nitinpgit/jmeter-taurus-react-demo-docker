#!/bin/sh -xe

WORKDIR=$(pwd)
echo "Using workdir: $WORKDIR"
ls -R taurus
cat taurus/get-quick-message.yml

# Copy taurus files to the workspace root for easier access
cp -r taurus/* .

echo "Current directory contents:"
ls -la

# Create a simple test to verify the file exists
echo "Testing file existence:"
ls -la get-quick-message.yml

# Try a different approach - create the file inside the container
echo "Creating Taurus config inside container..."
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