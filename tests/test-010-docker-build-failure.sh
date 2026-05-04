#!/bin/bash
set -e

echo "TEST-010: Docker Build Failure Should Stop Pipeline"

cat > Dockerfile.broken <<EOF
FROM node:18
COPY missing-file.js .
CMD ["node", "missing-file.js"]
EOF

echo "Step 1: Try to build broken Dockerfile. This test expects build to FAIL."

set +e
docker build -f Dockerfile.broken -t security-gate-broken:latest .
BUILD_RESULT=$?
set -e

rm -f Dockerfile.broken

if [ $BUILD_RESULT -eq 0 ]; then
    echo "TEST-010 FAILED: Broken Dockerfile built successfully."
    exit 1
else
    echo "TEST-010 PASSED: Docker build failure was detected."
    exit 0
fi