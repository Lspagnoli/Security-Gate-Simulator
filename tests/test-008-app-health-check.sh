#!/bin/bash
set -e

echo "TEST-008: Application Health Check"

NAMESPACE="securechain-dev"
SERVICE="securechain-service"

echo "Step 1: Start port-forward"
kubectl port-forward service/$SERVICE 3000:3000 -n $NAMESPACE > port-forward.log 2>&1 &
PF_PID=$!

sleep 5

echo "Step 2: Check app response"
set +e
curl -f http://localhost:3000
CURL_RESULT=$?
set -e

kill $PF_PID || true

if [ $CURL_RESULT -eq 0 ]; then
    echo "TEST-008 PASSED: Application is reachable."
    exit 0
else
    echo "TEST-008 FAILED: Application is not reachable."
    exit 1
fi