# CLAUDE.MD -- Applied Microeconomics Research with Claude Code

**Project:** 2025 California High School Senior Survey
**Institution:** California Education Lab, UC Davis
**Partners:** California Student Aid Commission (CSAC), Cradle to Career Data System (C2C)
**Branch:** main

---

## Project Overview

Survey of every California high school senior who filed a FAFSA or CADAA (Dream Act application), distributed by CSAC via email. Focuses on financial aid experience and transition to college.

### Deliverables

| Deliverable | Status | Format | Link |
|-------------|--------|--------|------|
| C2C Student Experience Report | Published | Web report | [c2c.ca.gov](https://c2c.ca.gov/resources/student-experience-report-2025-academic-year/) |
| CSAC Report | Under revision | Word/Google Doc | Under review by lab directors and agency partners |

### Key Constraints

- **Remote data:** Survey data lives on the Scribe server at UC Davis. Claude cannot access the server directly. Do files are uploaded and executed there.
- **Figures from Excel:** Most report graphs are produced in `Main Report Tables.xlsx` (on Box).
- **Stata on server:** Claude reviews code and generates new do files with documented assumptions.
- **Stats source of truth:** All stats come from the draft text or `Main Report Tables.xlsx`. Mental math on existing numbers is fine. Never invent numbers. If a stat can't be found, ask.
- **No assumptions:** Do not guess or assume details about workflow, infrastructure, tools, or preferences. Only state what was explicitly provided. If a detail is missing and relevant, leave it out or ask.

---

## Core Principles

- **Plan first** -- enter plan mode before non-trivial tasks; save plans to `quality_reports/plans/`
- **Verify after** -- compile and confirm output at the end of every task
- **Quality gates** -- weighted aggregate score; nothing ships below 80/100; see `quality.md`
- **Worker-critic pairs** -- every creator has a paired critic; critics never edit files
- **[LEARN] tags** -- when corrected, save `[LEARN:category] wrong -> right` to MEMORY.md

---

## Folder Structure

```
csac2025/
├── CLAUDE.md                    # This file
├── .claude/                     # Rules, skills, agents, hooks
├── Bibliography_base.bib        # Centralized bibliography
├── do/                          # Stata do files (primary analysis code)
│   ├── main.do                  # Master file -- runs all do files
│   ├── settings.do              # Globals for paths, machine-specific branching
│   ├── macros_csac.doh          # Helper macros (included via `include`)
│   ├── clean/                   # Data cleaning scripts
│   ├── explore/                 # Exploratory analysis
│   └── share/                   # Output for sharing (maps, appendix, etc.)
├── dta/                         # Datasets (shapefiles, crosswalks, intermediates)
├── doc/                         # Documentation
├── out/                         # Output files (CSVs, docs for sharing)
├── log/                         # Stata log files
├── figures/                     # Final figures (.pdf, .png) referenced in reports
├── tables/                      # Final tables (.tex) referenced in paper
├── paper/                       # LaTeX manuscript (if applicable)
│   └── sections/                # Section-level .tex files
├── slides/                      # Presentation files (PowerPoint, Beamer)
├── preambles/                   # LaTeX headers / shared preamble
├── supplementary/               # Online appendix and supplements
├── replication/                 # Replication package for deposit
├── py/                          # Python scripts and utilities
├── explorations/                # Research sandbox
├── quality_reports/             # Plans, session logs, reviews, scores
├── templates/                   # Session log, quality report templates
├── master_supporting_docs/      # Reference papers and data docs
└── venv/                        # Python virtual environment (gitignored)
```

---

## Server Paths

The remote server uses these paths (defined in `do/settings.do`):

```stata
global projdir  "/home/research/ca_ed_lab/projects/csac_survey2025"
global rawdtadir "/home/research/ca_ed_lab/data/restricted_access/raw/csac_survey/2025"
global csac2023projdir "/home/research/ca_ed_lab/projects/csac_survey2023"
global csac2024projdir "/home/research/ca_ed_lab/projects/csac_survey2024"
```

---

## Commands

```bash
# Paper compilation (3-pass, pdflatex)
cd paper && pdflatex -interaction=nonstopmode main.tex
BIBINPUTS=..:$BIBINPUTS bibtex main
pdflatex -interaction=nonstopmode main.tex
pdflatex -interaction=nonstopmode main.tex

# Talk compilation (pdflatex with preambles)
cd slides && TEXINPUTS=../preambles:$TEXINPUTS pdflatex -interaction=nonstopmode talk.tex
```

---

## Quality Thresholds

| Score | Gate | Applies To |
|-------|------|------------|
| 80 | Commit | Weighted aggregate (blocking) |
| 90 | PR | Weighted aggregate (blocking) |
| 95 | Submission | Aggregate + all components >= 80 |
| -- | Advisory | Talks (reported, non-blocking) |

See `quality.md` for weighted aggregation formula.

---

## Skills Quick Reference

| Command | What It Does |
|---------|-------------|
| `/new-project [topic]` | Full pipeline: idea -> paper (orchestrated) |
| `/discover [mode] [topic]` | Discovery: interview, literature, data, ideation |
| `/strategize [question]` | Identification strategy or pre-analysis plan |
| `/analyze [dataset]` | End-to-end data analysis |
| `/write [section]` | Draft paper sections + humanizer pass |
| `/review [file/--flag]` | Quality reviews (routes by target: paper, code, peer) |
| `/revise [report]` | R&R cycle: classify + route referee comments |
| `/talk [mode] [format]` | Create, audit, or compile Beamer presentations |
| `/submit [mode]` | Journal targeting -> package -> audit -> final gate |
| `/challenge [file --mode]` | Devil's advocate: `--paper`, `--identification`, `--fresh` |
| `/balance [treatment]` | Generate balance tables (Stata/R) |
| `/event-study [spec]` | Event study plots with pre-trends and CIs |
| `/compile-latex [file]` | 3-pass pdflatex + bibtex (papers and talks) |
| `/tools [subcommand]` | Utilities: commit, validate-bib, context-status, learn, etc. |

---

## Current Project State

| Component | Location | Status | Description |
|-----------|----------|--------|-------------|
| C2C Report | Published externally | Complete | Student experience report, 2025 academic year |
| CSAC Report | `paper/csac_2025_draft_apr_09_2026.docx` | Under revision | Being reviewed by lab directors and agency partners |
| Stata Code | `do/` | Active | Cleaning, exploration, and sharing scripts |
| Figures | `Main Report Tables.xlsx` (Box) / `figures/` | Active | Most graphs from Excel; some Stata-generated |
| Replication | `replication/` | Not started | -- |
