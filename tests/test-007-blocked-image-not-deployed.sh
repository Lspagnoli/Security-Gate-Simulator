#!/bin/bash
set -e

echo "TEST-007: Blocked Image Should Not Deploy"

IMAGE_NAME="security-gate-vuln:latest"
NAMESPACE="securechain-dev"

echo "Step 1: Build vulnerable image"
docker build -f Dockerfile.vuln -t $IMAGE_NAME .

echo "Step 2: Run vulnerability scan. Deployment should not happen if scan fails."

set +e
grype $IMAGE_NAME --fail-on high
SCAN_RESULT=$?
set -e

if [ $SCAN_RESULT -eq 0 ]; then
    echo "TEST-007 FAILED: Vulnerable image scan passed, deployment could continue."
    exit 1
else
    echo "Scan failed as expected."
fi

echo "Step 3: Confirm deployment is not updated with vulnerable image"

CURRENT_IMAGE=$(kubectl get deployment securechain-app -n $NAMESPACE -o=jsonpath='{.spec.template.spec.containers[0].image}')

if [ "$CURRENT_IMAGE" = "$IMAGE_NAME" ]; then
    echo "TEST-007 FAILED: Vulnerable image was deployed."
    exit 1
else
    echo "TEST-007 PASSED: Vulnerable image was not deployed."
    exit 0
fi