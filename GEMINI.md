# Project Context: Data Science at Nushell

## Directory Overview

This repository contains the complete course materials for **Data Science at Nushell** (*Ciencia de Datos en Nushell*), an undergraduate course in the **Statistics Engineering** program at **Universidad del Bío-Bío (UBB)**. The course teaches end-to-end data science workflows built entirely on **Nushell** (and `nu_plugin_polars`) inside a standalone, self-maintained Docker container (**`dsin`**), integrating `Rscript`, `python3`, and external CLI modeling tools (`vw`, `tapkee`, `skll`) into structured Nushell tables.

- **Audience:** Undergraduate Statistics Engineering students
- **Primary Language:** Spanish, with English technical terminology
- **Paradigm:** Nushell-First (100% integrated single-part curriculum), with polyglot modeling in CLI (`vw`/`tapkee`/`skll`), `Rscript`, and `python3` outputting Nushell tables
- **Public Remote:** `git@github.com:kurokirasama/data_science_at_nushell.git` (Agentic files `conductor/`, `GEMINI.md`, `AGENTS.md`, `CLAUDE.md`, `todos.md` are excluded on `main` via `.gitignore` and tracked only on the local `private` branch)

## Key Files

| Path | Purpose |
|------|---------|
| `Files/DataScienceNushell.md` | Main single-part 8-chapter course document (Pandoc Markdown with LaTeX frontmatter) |
| `Files/DataScienceNushell.pdf` | Compiled PDF of the main course document |
| `Files/nu.xml`, `Files/nushell.xml` | Custom XML syntax definitions for highlighting Nushell (`nu` / `nushell`) codeblocks in Pandoc |
| `Files/pandoc_highlight.theme` | Skylighting theme matching the environment's syntax palette |
| `Files/*.csv` & `Files/data/` | Datasets used throughout the course (Wine, IES, COVID-19, video game sales) |
| `Files/*.png` / `*.jpg` | Diagrams and figures for lecture materials |
| `docker/Dockerfile` | Standalone Docker build definition for the `dsin` image (`nu` default shell, `ttt`, `timg`, `nu_plugin_polars`, `vw`, `tapkee`, `skll`) |
| `docker/config.nu` | Default custom Nushell configuration inside `dsin` |
| `docker/update-dsin-nushell.nu` | Automated Nushell script to upgrade Nushell inside `dsin`, rebuild, test, and push |
| `tests/` | Automated verification suites (`test_repo_scaffold.nu`, `test_dsin_container.nu`, `test_md_execution.nu`, `test_modeling_pipelines.nu`) |
| `conductor/` | Private Conductor project management framework (excluded from public `main` branch) |

## Usage

- **Students:** Start with `Files/DataScienceNushell.md` and run `docker run --rm -it -v "$(pwd)/Files:/data" kurokirasama/dsin:latest`.
- **Instructors:** Compile PDF with full Nushell syntax highlighting via: `cd Files && pandoc --pdf-engine=xelatex --syntax-definition=nu.xml --syntax-definition=nushell.xml --syntax-highlighting=pandoc_highlight.theme DataScienceNushell.md -o DataScienceNushell.pdf`. Upgrade `dsin` Nushell version via `nu docker/update-dsin-nushell.nu`.
- **Agents:** Follow `conductor/workflow.md`, the Nushell-first mandate, the 100% in-Docker code execution rule (`tests/test_md_execution.nu`), the Public/Private Git isolation rules, and the `context-mode` routing rules below.

---

## Longterm Memory System

The Longterm Memory System is a multi-tiered architecture designed to provide LLM agents with persistent context across sessions. It consists of:
- **Episodic Memory**: Project-specific logs stored in `AGENTS_MEMORY/DataScienceAtNushell/` in the Obsidian vault.
- **Semantic & Identity Memory**: Global files (`BRAIN.md` and `SOUL.md`) in `AGENTS_MEMORY/`.
- **Orchestration**: `longterm-memory-orchestrator`, `longterm-memory-reader`, and `longterm-memory-writer`.

**MANDATORY PRE-TASK PROTOCOL:** At the beginning of every session, BEFORE proceeding with any user tasks, the agent MUST load project context and global awareness via `init-session` in `longterm-memory-reader` and internalize `BRAIN.md` and `SOUL.md`.

---

# context-mode — MANDATORY routing rules

You have context-mode MCP tools available. These rules are NOT optional — they protect your context window from flooding.

## BLOCKED commands — do NOT attempt these
- **curl / wget / Inline HTTP / WebFetch** — Use `mcp__context-mode__ctx_fetch_and_index(url, source)` or `mcp__context-mode__ctx_execute`.

## REDIRECTED tools — use sandbox equivalents
- **Shell (>20 lines output)** — Use `mcp__context-mode__ctx_batch_execute` or `mcp__context-mode__ctx_execute`.
- **read_file (for analysis)** — Use `mcp__context-mode__ctx_execute_file` for analysis/summarization; use `read_file` when reading to edit.
- **grep / search (large results)** — Use `mcp__context-mode__ctx_execute`.
