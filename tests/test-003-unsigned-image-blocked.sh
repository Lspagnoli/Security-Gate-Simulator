#!/bin/bash
set -e

echo "TEST-003: Unsigned Image Should Be Blocked"

IMAGE_NAME="security-gate-unsigned:latest"

echo "Step 1: Build unsigned image"
docker build -t $IMAGE_NAME .

echo "Step 2: Verify image signature. This test expects verification to FAIL."

set +e
cosign verify --key cosign.pub $IMAGE_NAME
VERIFY_RESULT=$?
set -e

if [ $VERIFY_RESULT -eq 0 ]; then
    echo "TEST-003 FAILED: Unsigned image passed signature verification."
    exit 1
else
    echo "TEST-003 PASSED: Unsigned image was blocked."
    exit 0
fi