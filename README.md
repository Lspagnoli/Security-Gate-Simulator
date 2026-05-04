# Security Gate Simulator (DevSecOps Pipeline)

## Overview
The **Security Gate Simulator** is a DevSecOps project that demonstrates how security can be integrated directly into a CI/CD pipeline to protect the software supply chain.

This project builds containerized applications, performs automated security checks, and enforces strict **security gates** before deployment. Any insecure artifact (such as vulnerable images, unsigned images, or invalid SBOMs) is automatically blocked.

---

## Key Features

- Automated Docker image build process  
- SBOM (Software Bill of Materials) generation  
- Vulnerability scanning with severity filtering  
- Image signature verification  
- Security gate enforcement (fail-fast mechanism)  
- Kubernetes deployment only after successful validation  
- End-to-end simulation of secure CI/CD pipeline  

---

## System Workflow

1. Build Docker image  
2. Generate SBOM using Syft  
3. Validate SBOM (existence and format)  
4. Scan image using Grype  
5. Verify image signature (Cosign)  
6. Block pipeline if any check fails  
7. Deploy to Kubernetes if all checks pass  

---

## Technology Stack

- CI/CD: Jenkins  
- Containerization: Docker  
- Orchestration: Kubernetes  
- Security Tools:
  - Grype (Vulnerability Scanner)
  - Syft (SBOM Generator)
  - Cosign (Image Signing)

---

## Project Structure
Security-Gate-Simulator/
│
├── Dockerfile                # Clean application image
├── Dockerfile.vuln           # Intentionally vulnerable image
├── Jenkinsfile               # CI/CD pipeline definition
├── app.js                    # Sample Node.js application
├── package.json
│
├── k8s/                      # Kubernetes deployment configs
│   ├── deployment.yaml
│   └── service.yaml
│
├── tests/                    # Security validation scripts
│
├── screenshots/              # Evidence and outputs
│
└── README.md


---

## Security Gates Implemented

- **Vulnerability Gate**: Blocks images with critical vulnerabilities  
- **SBOM Validation Gate**: Ensures SBOM exists, is valid, and not empty  
- **Signature Verification Gate**: Blocks unsigned images  
- **Deployment Gate**: Prevents deployment if any check fails  
- **Pipeline Control Gate**: Stops pipeline execution on failure  

---

## Expected Behavior

- Clean images pass all checks and deploy  
- Vulnerable images are blocked  
- Unsigned images are rejected  
- Invalid or missing SBOM stops the pipeline  
- Deployment occurs only after full validation


---

## Use Case

This project demonstrates how organizations can:

- Secure containerized applications  
- Automate vulnerability detection  
- Enforce security policies in CI/CD  
- Prevent insecure deployments  

---

## Conclusion

The Security Gate Simulator provides a practical implementation of DevSecOps principles, ensuring that security checks are automated and enforced throughout the software delivery lifecycle.
