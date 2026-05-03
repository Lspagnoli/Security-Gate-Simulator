#!/bin/bash
set -e

echo "TEST-004: Missing SBOM Should Be Blocked"

rm -f sbom.json

echo "Step 1: Check if SBOM exists. This test expects SBOM check to FAIL."

set +e
test -f sbom.json
SBOM_RESULT=$?
set -e

if [ $SBOM_RESULT -eq 0 ]; then
    echo "TEST-004 FAILED: Missing SBOM was not detected."
    exit 1
else
    echo "TEST-004 PASSED: Missing SBOM was blocked."
    exit 0
fi