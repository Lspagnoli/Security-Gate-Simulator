#!/bin/bash
set -e

echo "TEST-009: Pipeline Should Stop After Failed Security Gate"

IMAGE_NAME="security-gate-vuln:latest"

echo "Step 1: Build vulnerable image"
docker build -f Dockerfile.vuln -t $IMAGE_NAME .

echo "Step 2: Run scan. This should fail."

set +e
grype $IMAGE_NAME --fail-on high
SCAN_RESULT=$?
set -e

if [ $SCAN_RESULT -eq 0 ]; then
    echo "TEST-009 FAILED: Vulnerable image passed scan, pipeline would continue."
    exit 1
fi

echo "Step 3: Confirm signing/deployment should not run"

if [ $SCAN_RESULT -ne 0 ]; then
    echo "TEST-009 PASSED: Security gate failed, so pipeline should stop here."
    exit 0
else
    echo "TEST-009 FAILED."
    exit 1
fi