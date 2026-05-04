#!/bin/bash
set -e

echo "TEST-001: Clean Image Pipeline Success"

IMAGE_NAME="security-gate-clean:test"

echo "Step 1: Build clean Docker image"
docker build -t $IMAGE_NAME .

echo "Step 2: Run Grype scan (check only critical vulnerabilities)"

SCAN_OUTPUT=$(grype $IMAGE_NAME -o json)

CRITICAL_COUNT=$(echo "$SCAN_OUTPUT" | jq '[.matches[] | select(.vulnerability.severity=="Critical")] | length')

echo "Critical vulnerabilities found: $CRITICAL_COUNT"

if [ "$CRITICAL_COUNT" -eq 0 ]; then
    echo "TEST-001 PASSED: No critical vulnerabilities. Pipeline would pass."
    docker rmi $IMAGE_NAME || true
    exit 0
else
    echo "TEST-001 FAILED: Critical vulnerabilities detected."
    docker rmi $IMAGE_NAME || true
    exit 1
fi