# Security Gate Simulator - Demo Script

## Introduction

Hello everyone. Our project is Security Gate Simulator, a DevSecOps solution that prevents insecure container images from reaching production environments.

The goal is to automate security checks before deployment.

---

## Problem Statement

Many teams deploy container images without verifying:

- vulnerabilities
- software bill of materials (SBOM)
- digital signatures
- deployment readiness

This creates software supply chain risk.

---

## Our Solution

We designed a pipeline with these stages:

1. Source Code Checkout  
2. Docker Build  
3. Generate SBOM  
4. Vulnerability Scan using Grype  
5. Sign Image using Cosign  
6. Verify Signature  
7. Deploy to Kubernetes only if all checks pass

---

## My Contribution (Person 2)

My responsibilities focused on Kubernetes deployment and validation.

Completed work:

- Kubernetes cluster setup
- Namespaces creation
- deployment.yaml and service.yaml
- Manual deployment testing
- Pod verification
- Application access validation

---

## Live Demo

We deployed the application to Kubernetes.

Results:

- Pod status: Running
- Service exposed successfully
- Application accessible on localhost:3000

---

## Security Benefits

This system helps block:

- vulnerable images
- unsigned images
- tampered artifacts
- unsafe deployments

---

## Conclusion

Security Gate Simulator demonstrates how DevOps and security can be integrated into one automated release pipeline.