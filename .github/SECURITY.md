# Security Policy

> *Para la versión en español de esta política de seguridad, consulte [SECURITY.es.md](SECURITY.es.md).*

## Scope & Supported Versions

This project provides an open-source book on data science workflows in the Linux terminal along with a companion Docker image (`ghcr.io/kurokirasama/dsin:latest`).

Security considerations primarily apply to:
1. The **`dsin` container image** published on GitHub Container Registry (base image packages, third-party binary tool vulnerabilities, file permissions, and environment defaults).
2. The **automation and build scripts** (`docker/update-dsin-nushell.nu`, setup scripts) that execute on user or host workstations.

| Component | Supported / Maintained |
| :--- | :--- |
| `ghcr.io/kurokirasama/dsin:latest` | :white_check_mark: Active support |
| `docker/Dockerfile` and scripts | :white_check_mark: Active support |
| Older tagged image releases | :x: Untracked |

---

## Reporting a Vulnerability

We take the security of our users and learners seriously. If you discover a potential security vulnerability (e.g., insecure container permissions, critical CVEs in shipped tooling, or malicious script vectors):

1. **Do NOT open a public GitHub issue.**
2. Report the vulnerability privately via **GitHub Private Vulnerability Reporting** on the repository page under `Security > Report a vulnerability`.
3. Alternatively, send an email directly to the maintainer at [kurokirasama@gmail.com](mailto:kurokirasama@gmail.com) with:
   - A description of the vulnerability.
   - Steps to reproduce or proof-of-concept.
   - Affected component (Docker image tag, script path).
   - Potential impact.

---

## Response & Resolution Process

- **Acknowledgement:** We will acknowledge receipt of your vulnerability report within 48 hours.
- **Assessment:** We will confirm the issue, evaluate its severity, and determine the remediation path.
- **Patching:** If a fix is required in the container image or build scripts, an updated image will be built, tested, and published to `ghcr.io/kurokirasama/dsin:latest`.
- **Disclosure:** Once the security patch is live, a public advisory or release note will be published acknowledging the reporter (if desired).
