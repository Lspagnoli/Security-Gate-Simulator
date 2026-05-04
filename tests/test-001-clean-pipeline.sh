#!/bin/bash
set -e

echo "TEST-001: Clean Image Pipeline Success"

IMAGE_NAME="security-gate-clean:test"
SBOM_FILE="sbom-clean-test001.json"

cleanup() {
    echo "Cleaning up..."
    rm -f "$SBOM_FILE"
    docker rmi "$IMAGE_NAME" || true
}

trap cleanup EXIT

echo "Step 1: Check required tools"
command -v docker >/dev/null 2>&1 || { echo "Docker is not installed"; exit 1; }
command -v grype >/dev/null 2>&1 || { echo "Grype is not installed"; exit 1; }
command -v syft >/dev/null 2>&1 || { echo "Syft is not installed"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq is not installed"; exit 1; }

echo "Step 2: Build clean Docker image"
docker build -t "$IMAGE_NAME" .

echo "Step 3: Generate SBOM"
syft "$IMAGE_NAME" -o json > "$SBOM_FILE"

if [ ! -s "$SBOM_FILE" ]; then
    echo "TEST-001 FAILED: SBOM file was not created or is empty."
    exit 1
fi

if ! jq empty "$SBOM_FILE" >/dev/null 2>&1; then
    echo "TEST-001 FAILED: SBOM file is not valid JSON."
    exit 1
fi

echo "Step 4: Run Grype scan and check Critical vulnerabilities only"
SCAN_OUTPUT=$(grype "$IMAGE_NAME" -o json)

CRITICAL_COUNT=$(echo "$SCAN_OUTPUT" | jq '[.matches[] | select(.vulnerability.severity=="Critical")] | length')

echo "Critical vulnerabilities found: $CRITICAL_COUNT"

if [ "$CRITICAL_COUNT" -eq 0 ]; then
    echo "TEST-001 PASSED: No critical vulnerabilities. Clean image pipeline would pass."
    exit 0
else
    echo "TEST-001 FAILED: Critical vulnerabilities detected. Pipeline would block this image."
    exit 1
fi
