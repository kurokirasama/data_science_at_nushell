# Upstream Audit: `datasciencetoolbox/dsatcl2e` & `data-science-at-the-command-line`

This document records the technical audit of the upstream repositories (`jeroenjanssens/data-science-at-the-command-line` and `datasciencetoolbox/datasciencetoolbox`) and the base container image (`datasciencetoolbox/dsatcl2e:latest`), along with the remediations implemented in our standalone **`dsin`** (*Data Science in Nushell*) Docker image.

---

## 1. Upstream Build Architecture Discovery

Inspection of `datasciencetoolbox/dsatcl2e:latest` and `github.com/datasciencetoolbox/datasciencetoolbox` revealed that the upstream image was built via Packer (`template.json`) and Ansible (`playbook-tools.yml`, `playbook-user.yml`) on top of **`ubuntu:21.04` (`hirsute`, GLIBC 2.33)**.

---

## 2. Catalog of Open Upstream Issues & Remediations in `dsin`

| ID | Upstream Source | Issue Summary | Root Cause | Remediation in `dsin` |
|----|-----------------|---------------|------------|-----------------------|
| **DSIN-01** | `dsatcl#150`, `dsatcl#132` | `sudo apt update` fails with `The repository 'http://security.ubuntu.com/ubuntu hirsute-security Release' no longer has a Release file` | Ubuntu 21.04 (`hirsute`) reached EOL in Jan 2022 and was moved from `archive.ubuntu.com` / `security.ubuntu.com` to `old-releases.ubuntu.com`. | Rewrite `/etc/apt/sources.list` to `http://old-releases.ubuntu.com/ubuntu/` so `apt-get update` and package installation work reliably. |
| **DSIN-02** | `dsatcl#127` | `display` (ImageMagick X11 viewer) fails in headless Docker containers on Linux/WSL2 | Container lacks X11 server forwarding by default. | Install **`timg`** (`apt-get install -y timg`) for native ANSI/Unicode/Kitty/Sixel terminal image and plot rendering directly inside the CLI. |
| **DSIN-03** | `dst#15`, `dst#17` | `/data` directory missing when launching container without `-v` or in default working dir | Upstream image sets `WORKDIR /home/dst` without pre-creating `/data` or symlinking. | Create `/data` owned by `dst:dst` and configure default volume mount compatibility. |
| **DSIN-04** | `dsatcl#148` | Excel `.xlsx` conversion errors (`in2csv` / `openpyxl` incompatibilities) | Old `csvkit`/`openpyxl` versions fail on modern `.xlsx` files. | Use Nushell's native `open file.xlsx` (and updated Python `openpyxl`/`polars` in container). |
| **DSIN-05** | `dsatcl#141`, `dst#20` | `csvlook` function undefined or breaks on multiline paste | Zsh wrapper function fragility in `.zshrc`. | Replaced entirely by Nushell's native structured table renderer (`table`, `table -e`, `grid`). |
| **DSIN-06** | `dsatcl#135` | Permission denied when executing custom CLI scripts in Ch04 | Missing executable bits and `PATH` configuration across subshells. | Configure `~/.config/nushell/config.nu` with `$env.NU_LIB_DIRS` and `/home/dst/bin` in `$env.PATH`, plus custom `export def` commands. |
| **DSIN-07** | `dsatcl#145`, `dst#16`, `dsatcl#126` | Dead external URLs in Ch03 (`top2000.xlsx`, Dutch Radio) | External third-party URLs changed over time. | Provide local cached copies in `Files/data/` and verified live endpoints (GitHub API, UCI, Open-Meteo, PokéAPI) via `http get`. |
| **DSIN-08** | Course Audit (2026-10) | Missing modern shell, dataframe engine, and terminal text editor | Upstream image boots into `zsh` (`5.8`) with only `nano` installed and no Nushell or Polars support. | Install latest static **Nushell (`nu`) + `nu_plugin_polars`** (`musl` build for zero GLIBC mismatch), register Polars plugin, set `nu` as default `ENTRYPOINT`/`SHELL` with custom `config.nu`, and install **`ttt`** with user's `ttt_config.7z`. |
