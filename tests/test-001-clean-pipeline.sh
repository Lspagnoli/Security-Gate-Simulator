#!/bin/bash
set -e

echo "TEST-001: Clean Image Pipeline Success"

IMAGE_NAME="security-gate-clean:latest"
NAMESPACE="securechain-dev"
DEPLOYMENT="securechain-app"
SERVICE="securechain-service"

echo "Step 1: Building clean Docker image..."
docker build -t $IMAGE_NAME .

echo "Step 2: Running vulnerability scan..."
grype $IMAGE_NAME --fail-on high

echo "Step 3: Generating SBOM..."
syft $IMAGE_NAME -o cyclonedx-json > sbom.json

echo "Step 4: Checking SBOM exists and is not empty..."
test -s sbom.json

echo "Step 5: Checking SBOM is valid JSON..."
jq empty sbom.json

echo "Step 6: Deploying to Kubernetes..."
kubectl apply -f k8s/deployment.yaml -n $NAMESPACE

echo "Step 7: Checking Kubernetes rollout..."
kubectl rollout status deployment/$DEPLOYMENT -n $NAMESPACE --timeout=120s

echo "Step 8: Checking pod is running..."
kubectl get pods -n $NAMESPACE

echo "Step 9: Checking application response..."
kubectl port-forward service/$SERVICE 3000:3000 -n $NAMESPACE > port-forward.log 2>&1 &
PF_PID=$!

sleep 5

curl -f http://localhost:3000

kill $PF_PID

echo "TEST-001 PASSED"