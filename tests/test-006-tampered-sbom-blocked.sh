#!/bin/bash
set -e

echo "TEST-006: Tampered SBOM Should Be Blocked"

echo "tampered sbom data" > sbom.json

echo "Step 1: Validate SBOM JSON. This test expects JSON validation to FAIL."

set +e
jq empty sbom.json
JSON_RESULT=$?
set -e

if [ $JSON_RESULT -eq 0 ]; then
    echo "TEST-006 FAILED: Tampered SBOM was accepted."
    exit 1
else
    echo "TEST-006 PASSED: Tampered SBOM was blocked."
    exit 0
fi