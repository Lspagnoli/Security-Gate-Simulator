#!/bin/bash
set -e

echo "TEST-002: Vulnerable Image Should Be Blocked"

IMAGE_NAME="security-gate-vuln:latest"

echo "Step 1: Build vulnerable image"
docker build -f Dockerfile.vuln -t $IMAGE_NAME .

echo "Step 2: Run Grype scan. This test expects Grype to FAIL."

set +e
grype $IMAGE_NAME --fail-on high
SCAN_RESULT=$?
set -e

if [ $SCAN_RESULT -eq 0 ]; then
    echo "TEST-002 FAILED: Vulnerable image passed security scan."
    exit 1
else
    echo "TEST-002 PASSED: Vulnerable image was blocked."
    exit 0
fi