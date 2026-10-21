## Description of Changes

> *Para la versión en español de esta plantilla de Pull Request, consulte [pull_request_template.es.md](pull_request_template.es.md).*

Please provide a clear, concise summary of the changes proposed in this Pull Request:

- **What:**
- **Why:**

Closes # (issue number, if applicable)

---

## Type of Change

Please mark the applicable option:

- [ ] **Book Errata / Content Polish:** Typos, grammatical fixes, or pedagogical improvements in [Files/DataScienceNushell.md](file:///home/kira/Dropbox/Documentos/Clases/UBB/DataScienceAtNushell/Files/DataScienceNushell.md).
- [ ] **Nushell Pipeline Fix:** Correcting broken commands, updating pipelines for Nushell compatibility.
- [ ] **Docker & Tooling:** Improvements to [Dockerfile](file:///home/kira/Dropbox/Documentos/Clases/UBB/DataScienceAtNushell/docker/Dockerfile), image tools, or update automation scripts.
- [ ] **Documentation & Governance:** Updates to README, contributing guidelines, or repository metadata.

---

## Technical Verification Checklist

Before submitting your PR, please verify each of the following:

- [ ] **In-Container Execution:** All terminal commands, Nushell pipelines, and scripts were tested and executed with exit code 0 inside `ghcr.io/kurokirasama/dsin:latest`.
- [ ] **Code Block Line Width (<80 Characters):** Every line inside markdown code blocks is formatted to strictly fewer than 80 characters (no horizontal PDF margin overflow).
- [ ] **Pipeline Formatting:** Multiline Nushell pipelines use trailing pipes (`|`) for copy-paste terminal compatibility.
- [ ] **Terminology Adherence:** Conforms to project terminology conventions (*pipe* for operator, *pipeline* for workflows).
- [ ] **PDF Compilation:** Tested clean compilation of [Files/DataScienceNushell.pdf](file:///home/kira/Dropbox/Documentos/Clases/UBB/DataScienceAtNushell/Files/DataScienceNushell.pdf) using Pandoc and [Files/hide_skip.lua](file:///home/kira/Dropbox/Documentos/Clases/UBB/DataScienceAtNushell/Files/hide_skip.lua) with zero fatal errors.
