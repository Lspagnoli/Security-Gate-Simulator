# Security Gate Simulator - Q&A Preparation

## 1. Why did you choose this project?

We chose this project to solve container security and software supply chain risks using DevSecOps automation.

---

## 2. What problem does your project solve?

It prevents insecure or untrusted container images from being deployed into production environments.

---

## 3. Why use Kubernetes?

Kubernetes helps manage container deployment, scaling, service exposure, and reliability.

---

## 4. Why use Jenkins?

Jenkins automates build, security checks, and deployment stages in CI/CD pipelines.

---

## 5. Why use Grype?

Grype scans container images for known vulnerabilities and helps block risky deployments.

---

## 6. Why use Cosign?

Cosign signs container images and verifies authenticity to prevent tampering.

---

## 7. What is SBOM?

SBOM means Software Bill of Materials. It lists packages and dependencies inside the image.

---

## 8. What was your contribution?

My role focused on Kubernetes setup, manifests, deployment testing, pod validation, and application access verification.

---

## 9. What happens if an image fails checks?

The pipeline should stop deployment until issues are resolved.

---

## 10. Why run locally instead of AWS?

Local deployment was used for fast testing and proof of concept. The same design can be extended to AWS.

---

## 11. What did you learn?

We learned DevSecOps integration, Kubernetes deployment, container security, and CI/CD workflows.

---

## 12. Future Improvements

- Full AWS EKS deployment
- Real-time monitoring dashboards
- Automatic rollback
- Multi-environment promotion workflow