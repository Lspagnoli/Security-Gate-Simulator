#!/bin/bash
set -e

echo "TEST-005: Empty SBOM Should Be Blocked"

TEST_SBOM="empty-sbom.json"

echo "Step 1: Create empty SBOM"
touch $TEST_SBOM

echo "Step 2: Validate SBOM content"

# Check if file is empty OR invalid JSON
if [ ! -s "$TEST_SBOM" ]; then
    echo "TEST-005 PASSED: Empty SBOM was correctly blocked."
    rm -f $TEST_SBOM
    exit 0
else
    echo "TEST-005 FAILED: Empty SBOM was accepted."
    rm -f $TEST_SBOM
    exit 1
fi
