#!/bin/bash

# Stop script if error happens
set -e

# Variables
NAMESPACE="image-classifier"
SERVICE_NAME="image-classifier"
TEST_IMAGE_PATH="load-testing/images.jpeg"

# Default values
HOST="localhost"
PORT=""

# Read arguments from command line
while getopts "h:p:" opt; do
  case $opt in
    h) HOST="$OPTARG" ;;
    p) PORT="$OPTARG" ;;
    *) 
       echo "Usage: $0 [-h host] -p port"
       echo "Default host is localhost if not specified"
       exit 1
       ;;
  esac
done

echo "===== Sending Test Traffic to Image Classifier ====="

# Check if test image exists
if [ ! -f "$TEST_IMAGE_PATH" ]; then
    echo "Error: Test image not found at $TEST_IMAGE_PATH"
    echo "Please put a test image in load-testing/images.jpeg"
    exit 1
fi

# Check if port was given
if [ -z "$PORT" ]; then
    echo "Error: PORT is not provided"
    echo "Usage: $0 [-h host] -p port"
    echo "Example: $0 -h localhost -p 8000"
    exit 1
fi

# Build service URL
SERVICE_URL="http://${HOST}:${PORT}"

echo "Sending requests to: ${SERVICE_URL}/api/v1/classify"
echo "Using test image: ${TEST_IMAGE_PATH}"
echo "Sending 100 requests with 0.1 second sleep between them..."

# Loop 100 times and send request each time
for i in {1..1000}; do
    echo -n "Request $i: "
    RESPONSE=$(curl -s -X POST -F "file=@${TEST_IMAGE_PATH}" "${SERVICE_URL}/api/v1/classify")
    echo "$RESPONSE" | grep -o '"execution_time_ms":[0-9.]\+' || echo "Failed"
    sleep 0.1
done

echo "===== Load Test Finished ====="
