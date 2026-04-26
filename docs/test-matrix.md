# Security Gate Simulator - Comprehensive Test Matrix

## TEST-008: Clean vs Vulnerable vs Unsigned vs Missing SBOM

| Test Case ID | Scenario | Image / Artifact | Security Condition | Expected Result | Current Status |
|---|---|---|---|---|---|
| TC-001 | Clean image deployment | security-gate-clean:latest | No critical vulnerabilities, valid SBOM, signed image | PASS and deploy | Ready |
| TC-002 | Vulnerable image blocked | security-gate-vuln:latest | Critical/high CVEs detected | FAIL and block deployment | Pending Jenkins gate |
| TC-003 | Unsigned image blocked | security-gate-clean:latest | Missing Cosign signature | FAIL and block deployment | Pending Cosign verify stage |
| TC-004 | Missing SBOM blocked | clean image without SBOM artifact | SBOM missing or unavailable | FAIL and block deployment | Pending SBOM gate |
| TC-005 | Tampered SBOM blocked | modified SBOM file | SBOM does not match image contents | FAIL and block deployment | Planned |

---

## Validation Rules

The pipeline should allow deployment only when:

- Image has no critical vulnerabilities
- SBOM is generated and valid
- Image is signed using Cosign
- Signature verification passes
- Kubernetes deployment succeeds

---

## Summary

This matrix defines positive and negative test scenarios for the Security Gate Simulator. It will be used during final Jenkins/Cosign integration testing.