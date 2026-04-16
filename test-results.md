# Security Gate Simulator - Test Results

## Test 1: Clean Image

Image: security-gate-clean  
Port: localhost:3000  

Result:
- Application runs successfully
- Container starts without errors
- Uses updated Node.js base image

Screenshot:
![Clean Image](./screenshots/clean.png)

---

## Test 2: Vulnerable Image

Image: security-gate-vuln  
Port: localhost:3001  

Result:
- Application runs successfully
- Uses outdated Node.js base image (Node 12)
- Intended to simulate a vulnerable container

Screenshot:
![Vulnerable Image](./screenshots/vuln.png)

---

## Test 3: Vulnerability Scan

Tool: Grype  

Result:
- Multiple vulnerabilities detected in the vulnerable image
- Medium severity vulnerabilities found (e.g., Node.js CVEs)
- High and Critical vulnerabilities present in system libraries
- Large number of packages from End-of-Life OS (Debian 9)
- Several vulnerabilities marked as “won’t fix”

Key Finding:
- Image is based on outdated Debian 9 with significant security risks

Screenshot:
![Grype Scan](./screenshots/grype.png)

---

## Docker Images

Result:
- Both clean and vulnerable images are successfully built
- Vulnerable image shows larger size due to outdated dependencies

Screenshot:
![Docker Images](./screenshots/docker-images.png)

---

## Observations

- Both images run successfully on different ports
- Clean image uses modern and secure dependencies
- Vulnerable image uses outdated Node.js and Debian 9 (EOL)
- Grype scan detects multiple vulnerabilities in the vulnerable image
- Presence of High and Critical CVEs increases attack surface
- “Won’t fix” vulnerabilities indicate unsupported components

---

## Conclusion

The project successfully demonstrates the difference between secure and vulnerable container images.

- Clean image runs with updated and secure dependencies
- Vulnerable image contains multiple known vulnerabilities
- Grype effectively identifies security risks in the container

This highlights the importance of:
- Using updated base images
- Regular vulnerability scanning
- Integrating security checks into CI/CD pipelines (DevSecOps)& "C:\Users\HP LAPTOP\AppData\Local\Microsoft\WinGet\Packages\Anchore.Grype_Microsoft.Winget.Source_8wekyb3d8bbwe\grype.exe" security-gate-vuln