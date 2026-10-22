# Contributing to Data Science at the Linux Terminal with Nushell

Thank you for your interest in contributing to *Data Science at the Linux Terminal with Nushell* (*Ciencia de Datos en la Terminal Linux con Nushell*)! This repository hosts an open-access book and an accompanying reproducible Docker environment (`dsin`) designed to teach modern, structured data science workflows in the Linux terminal using [Nushell](https://www.nushell.sh/).

> *Para consultar esta guía de contribución en español, revise [translations/CONTRIBUTING.es.md](translations/CONTRIBUTING.es.md).*

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can You Contribute?](#how-can-you-contribute)
  - [1. Book Text & Errata](#1-book-text--errata)
  - [2. Nushell Pipelines & Code Fixes](#2-nushell-pipelines--code-fixes)
  - [3. Docker Environment & Tooling](#3-docker-environment--tooling)
- [Technical Contribution Guidelines](#technical-contribution-guidelines)
  - [In-Container Execution Verification](#in-container-execution-verification)
  - [Code Block Width (<80 Characters)](#code-block-width-80-characters)
  - [Pipeline Syntax & Terminology](#pipeline-syntax--terminology)
  - [PDF Compilation Verification](#pdf-compilation-verification)
- [Pull Request Workflow](#pull-request-workflow)

---

## Code of Conduct

All contributors and participants are expected to adhere to our [Code of Conduct](CODE_OF_CONDUCT.md). Please report any unacceptable behavior to [kurokirasama@gmail.com](mailto:kurokirasama@gmail.com).

---

## How Can You Contribute?

### 1. Book Text & Errata
If you find typos, grammatical mistakes, broken explanations, or opportunities for conceptual clarity in [Files/DataScienceNushell.md](file:///home/kira/Dropbox/Documentos/Clases/UBB/DataScienceAtNushell/Files/DataScienceNushell.md):
- Open an issue using the **📖 Book Errata & Content** template.
- Or submit a pull request with targeted revisions.
- Prose must be written in professional, neutral Latin American Spanish.

### 2. Nushell Pipelines & Code Fixes
As Nushell evolves across releases, some commands, plugin flags, or syntax forms may change:
- If a pipeline fails or can be written more idiomatically using modern Nushell constructs, submit an issue or PR.
- Every code example must produce structured data (tables, records, lists) rather than unstructured text where possible.

### 3. Docker Environment & Tooling
The companion container image `ghcr.io/kurokirasama/dsin:latest` packages Nushell along with CLI modeling tools, editors, and data utilities:
- Suggestions for new terminal data utilities, package updates, or Dockerfile optimizations are welcome via the **💡 Feature Request** issue template.

---

## Technical Contribution Guidelines

To ensure the highest editorial and computational standards, all contributions must satisfy the following criteria:

### In-Container Execution Verification
All terminal commands, Nushell scripts, Python/R scripts, and CLI modeling examples must execute with exit code 0 inside the official `dsin:latest` Docker image.

Before submitting a PR, test your commands directly inside the container:

```bash
docker run --rm -v $(pwd)/Files/data:/data ghcr.io/kurokirasama/dsin:latest \
  nu -c "cd /data/ch04; open iris.csv | first 5"
```

For interactive verification:
```bash
docker run --rm -it -v $(pwd)/Files/data:/data ghcr.io/kurokirasama/dsin:latest nu
```

### Code Block Width (<80 Characters)
The book is compiled into a print-ready XeLaTeX PDF. Long lines inside markdown code blocks do not automatically wrap and will overflow the page margins:
- Keep all lines inside code blocks under **80 characters**.
- Split long pipelines across multiple lines using trailing pipes (`|`).
- When breaking strings or flags, format them cleanly for readability.

### Pipeline Syntax & Terminology
1. **Interactive Copy-Paste Compatibility:** For multiline pipelines, place the pipe symbol (`|`) at the end of the line:
   ```nu
   open iris.csv |
     where sepal_length > 5.0 |
     select species sepal_length |
     first 3
   ```
2. **Terminology Consistency:**
   - Use **«pipe»** to refer to the individual operator or redirection symbol.
   - Use **«pipeline»** to refer to the end-to-end processing sequence or workflow.
   - Maintain the initial formal pedagogical introduction (*«tuberías o pipes de Unix»*) on first mention.

### PDF Compilation Verification
Ensure your changes do not break Pandoc PDF generation. Pandoc uses a custom Lua filter ([Files/hide_skip.lua](file:///home/kira/Dropbox/Documentos/Clases/UBB/DataScienceAtNushell/Files/hide_skip.lua)) to strip internal automated test annotations (`# skip-docker-exec`) from the compiled output:

```bash
cd Files
pandoc --pdf-engine=xelatex \
  --syntax-definition=nu.xml \
  --syntax-definition=nushell.xml \
  --syntax-highlighting=pandoc_highlight.theme \
  --lua-filter=hide_skip.lua \
  DataScienceNushell.md -o DataScienceNushell.pdf
```

Verify that the generated PDF compiles with 0 errors and preserves formatting.

---

## Pull Request Workflow

1. Fork the repository and create your branch from `main`:
   ```bash
   git checkout -b fix/chapter-04-pipeline
   ```
2. Make your edits and commit with clear, conventional messages (`docs: ...`, `fix: ...`, `refactor: ...`).
3. Ensure all tests and verification steps pass.
4. Push to your fork and submit a Pull Request to `main`.
5. Complete the checklist provided in the [Pull Request Template](pull_request_template.md).
