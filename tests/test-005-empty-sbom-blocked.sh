#!/bin/bash
set -e

echo "TEST-005: Empty SBOM Should Be Blocked"

echo "" > sbom.json

echo "Step 1: Check if SBOM is not empty. This test expects check to FAIL."

set +e
test -s sbom.json
SBOM_RESULT=$?
set -e

if [ $SBOM_RESULT -eq 0 ]; then
    echo "TEST-005 FAILED: Empty SBOM was accepted."
    exit 1
else
    echo "TEST-005 PASSED: Empty SBOM was blocked."
    exit 0
fi