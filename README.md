# CSAC / C2C 2025 California High School Senior Survey

> **Part of the [CEL Resource Hub](https://christinasun.net/cel_resource_hub/)** — Christina Sun's index of CEL code handoffs plus setup and workflow guides for inheriting them. Hub page for this repo: <https://christinasun.net/cel_resource_hub/repositories/csac-2025/>.

Code, outputs, and documentation for the **2025 California high school senior survey**, a collaboration between the California Education Lab (CEL, UC Davis), the California Student Aid Commission (CSAC), and the California Cradle to Career Data System (C2C).

Every California high school senior who filed a FAFSA or CADAA (California Dream Act Application) was invited by CSAC, via email, to take the survey. It focuses on the financial-aid experience and the transition to college. This repo cleans the Qualtrics export, tabulates it, and produces the appendix tables and source data that back the two 2025 reports.

This is the 2025 iteration of the survey. It reuses the conventions and much of the code of the [2024 wave](https://github.com/chesun/csac_2024) (project `csac_survey2024`; local sibling repo `csac_2024/`) and the [2023 wave](https://github.com/chesun/csac) (`csac_survey2023`; sibling repo `csac/`).

**Lab:** California Education Lab (CEL), UC Davis
**PI:** Jacob Jackson ("Jake")
**Code author:** Christina Sun (CS, `christinasun101@gmail.com` / `ucsun@ucdavis.edu`)
**Status:** Offboarding complete (2026-06-23)

**Offboarding note (2026-06-23):** `do/main.do` was fully wired and `interview_demo.do` debugged. The full pipeline ran end to end on the Scribe server with no errors; the run logs and shareable outputs were synced back to this repo (commit `c4a2b16`).

---

## 1. What this repo is

A single survey wave fielded to California high school seniors in 2025. The data was exported from Qualtrics in two cuts — **July** and **August**; the **August export is the analysis cut** (it has the full set of responses). Everything runs from one entry point:

```stata
do do/main.do
```

`do/main.do` runs the whole pipeline in order: settings → clean → explore → share. It produces the cleaned analysis dataset, a large suite of tabulation logs, the shareable open-text and email exports, the county maps and Figure 3 source data, and the tabulation **appendix** referenced by both reports.

### Research outputs

This survey supports two reports — the final products of the project:

| Report | Status | Code that feeds it |
|---|---|---|
| [C2C Student Experience Report (2025 Academic Year)](https://c2c.ca.gov/resources/student-experience-report-2025-academic-year/) | **Published** | `do/clean/`, `do/explore/`, `do/share/maps.do` (Figure 3 + county maps), `do/share/appendix.do` (tabulation appendix) |
| CSAC 2025 Survey Report | **Forthcoming** (under revision by lab directors and agency partners) | Same pipeline; same tabulation appendix |

The report narratives, and most report graphs, are written and assembled **outside this repo** — most figures come from `Main Report Tables.xlsx` (kept on Box). This repo's shipped artifacts are the **tabulation appendix** (`out/check/appendix_c2c.doc`), the **county maps and Figure 3 source data** (`do/share/maps.do`), and the exploratory tabulation logs the report numbers are drawn from.

> **Both reports use the same appendix.** `appendix.do` builds one tabulation appendix (`appendix_c2c.doc`); it serves the C2C report and the forthcoming CSAC report alike. There is no separate CSAC appendix to build.

---

## 2. How to run

All Stata code runs on the **remote Linux research server ("Scribe")**, not locally. The restricted survey data lives on the server only; this local repo holds the code, the synced-back outputs (logs and shareable tables/figures/CSVs), and the documentation. File transfer is via FileZilla or scp.

Workflow: edit do files locally, upload to Scribe, run in Stata. There is no local build or test command.

```stata
* On Scribe, in Stata, from the project folder:
do do/main.do
```

`do/main.do` `cd`s to the project directory, sources `do/settings.do`, and runs every step in order. It was verified end to end on Scribe on **2026-06-23** with no errors.

### One-time setup on a fresh server

- **SSC packages.** `main.do` has an install toggle near the top (`local installssc = 0`). On a fresh machine, set it to `1` for the first run to install `randomtag`, `spmap`, `shp2dta`, and `geo2xy`. Set it back to `0` afterward.
- **`asdoc` (separate).** `appendix.do` needs `asdoc`, which is **not** in the install toggle. Install it once by hand: `ssc install asdoc, replace`.
- The server needs internet access on the first run for the SSC installs.

### Running only part of the pipeline

Every do file is self-contained: it loads the dataset it needs and `include`s `do/macros_csac.doh` itself. To re-run one step, just `do` that file (after `do/settings.do` has defined the path globals in the session). For example, to rebuild only the appendix:

```stata
do do/settings.do
do do/share/appendix.do
```

---

## 3. Project structure

Local repo (code + synced-back outputs):

```
do/                                Stata do files (all executable code)
  main.do                            Master pipeline (settings -> clean -> explore -> share)
  settings.do                        Global path macros (Scribe server paths)
  macros_csac.doh                    Per-question variable lists + human-readable label strings
  clean/                             Data cleaning (Qualtrics import + recode + geo merge)
  explore/                           Sample characteristics + question tabulations
  share/                             Report appendix, maps, open-text exports, interview lists
log/                               Stata logs (.txt), mirroring do/ subdirs
out/                               Shareable CSV / Excel exports
  check/                             appendix_c2c.doc (the tabulation appendix)
dta/                               Committed inputs only (see below); cleaned data is Scribe-only
  ca_counties/                       Public CA county shapefile (for maps.do)
  interview_email_random150_batch1_flag.csv   From interview recruitment (Stephanie Luna-Lopez); input to interview_demo.do
paper/                             CSAC report draft (forthcoming)
figures/                           Report figures
Main Report Tables.xlsx            Source for most report graphs (master copy on Box)
.claude/  CLAUDE.md                 Claude Code workflow scaffolding (not part of the analysis)
```

On Scribe, the project directory (`$projdir`) additionally holds the cleaned datasets and the geographic crosswalks (`survey_25_nces.csv`, `nces_to_merge.dta`). The cleaned `.dta` files are **restricted and not committed** to this repo.

---

## 4. Inputs and outputs of each do file

The core of the handoff. Paths use the `do/settings.do` globals. Inputs marked **[external]** are not produced by any code in this repo.

### Setup

| File | Purpose |
|---|---|
| `do/settings.do` | Defines the global path macros (`$projdir`, `$rawdtadir`, `$csac2023projdir`, `$csac2024projdir`). Sourced first by `main.do`. No data I/O. |
| `do/macros_csac.doh` | Defines the per-question variable lists (`q<n>_subqs`, the grouped `*_qs` lists, `all_qs`, `demo_qs`, `other_tab_qs`, `text_qs`, `location_qs`, etc.) and the human-readable question/label strings the tabulation scripts consume. `include` it **after** a `use` — the scripts iterate its lists over the loaded variables. |

### Stage 1 — Cleaning (`do/clean/`)

| File | Purpose | Input | Output |
|---|---|---|---|
| `clean_qualtrics_download.do` | First-pass clean, run for **both** the July and August exports in a loop: import the raw Qualtrics value + label CSVs, drop system/PII columns, recode and label every survey question (FAFSA reasons, college applications, transfer intentions, demographics, etc.), build the race codings, merge in the NCES code and the public geographic crosswalk (locale / region / county FIPS) | `$rawdtadir/csac_2025_value_<jul\|aug>.csv` **[external]**; `$rawdtadir/csac_2025_label_<jul\|aug>.csv` **[external]** (label file supplies the UC/CSU campus text for Q33/Q34); `$projdir/dta/survey_25_nces.csv` **[external]**; `$projdir/dta/nces_to_merge.dta` **[external]** | `$projdir/dta/csac_2025_initial_clean_jul.dta` and `csac_2025_initial_clean_aug.dta`; `log/clean/clean_qualtrics_download.{txt,smcl,log}` |

> **The August dataset is the analysis cut.** `csac_2025_initial_clean_aug.dta` is the single dataset every downstream script reads (see the stale-name note in §6).

### Stage 2 — Exploration (`do/explore/`)

| File | Purpose | Input | Output |
|---|---|---|---|
| `sample_char.do` | Tabulate sample characteristics for HS seniors: college-going, the three race codings, parent education, first-gen (two definitions), home language, employment, gender, school locale and region | `csac_2025_initial_clean.dta` **(stale name — see §6; resolves to the August cut)** | `log/explore/explore_sample_char.txt` |
| `tab_questions.do` | The main tabulation engine. For both July and August: one-way tab of every question, and two-way tabs of every question by each demographic and other characteristic. Then, on the August cut: demographics by region/locale, college-contact crosstabs, the corrected FAFSA-challenge tabs, pay-plan and college-worry tabs by college intention, and the "why FAFSA" summary | `csac_2025_initial_clean_<jul\|aug>.dta`; `macros_csac.doh` | A large suite of `log/explore/tab_questions_*.txt`, `tab_demo_*_aug.txt`, `tab_contact_coll_applied.txt`, `tab_fafsa_challenge.txt`, `tab_pay_plan_worry_*.txt`, `why_fafsa_require_assign_expect.txt` |
| `atog_check.do` | Spot check: of students who said a-g was "not required for my college," where do they plan to attend? | `csac_2025_initial_clean_aug.dta`; `macros_csac.doh` | Console / batch log only (no dedicated `log using`) |

### Stage 3 — Research products (`do/share/`)

| File | Purpose | Input | Output |
|---|---|---|---|
| `random_emails.do` | Draw random interview-recruitment samples (seed `1984` via `randomtag`): a random 150, a second batch of 150 with demographics, and a 150 sample of transfer-intending students | `csac_2025_initial_clean_aug.dta`; `macros_csac.doh` | `$projdir/out/interview_email_random150.csv`; `interview_email_random150_batch2_withdemo.csv`; `interview_email_random150_xfer_withdemo.csv`; `$projdir/dta/email_list_withdemo.dta` |
| `text_qs.do` | Export every open-text response to a multi-sheet workbook (one sheet per text question in the `text_qs` macro), plus the full list of interview-volunteer emails | `csac_2025_initial_clean.dta` **(stale name — see §6)**; `macros_csac.doh` | `$projdir/out/text_qs.xlsx` (multi-sheet); `$projdir/out/interview_email.csv` |
| `maps.do` | Build the county-level maps and the Figure 3 source data: convert the CA county shapefile, collapse selected question rates by region/county, draw four `spmap` choropleths (transfer intention, proximity-to-home transfer factor, dual enrollment, heard-of-FAFSA-early) | `$projdir/dta/ca_counties/CA_Counties.shp` **[external, public]**; `csac_2025_initial_clean_aug.dta`; `$projdir/dta/nces_to_merge.dta` **[external]** | `$projdir/out/{proximity_by_county,map_data_by_county,county_region_xwalk,fig3_county_region_rate}.csv`; `$projdir/dta/char_by_county.dta`; `counties.dta` + `coord.dta` and the four `*.png` maps **written to the project root** (see §6) |
| `interview_demo.do` | Attach survey demographics to the flagged batch-1 list from interview recruitment | `$projdir/dta/interview_email_random150_batch1_flag.csv` **[external — from interview recruitment (Stephanie Luna-Lopez, lab GSR)]**; `csac_2025_initial_clean.dta` **(stale name — see §6)** | `$projdir/out/interview_email_random150_batch1_withdemo.csv` |
| `appendix.do` | Build the report tabulation appendix: for each referenced question, a one-way tab plus two-way tabs by race, gender, first-gen, region, locale, and HS grades, written to a Word doc with `asdoc`. **This one appendix serves both reports.** | `csac_2025_initial_clean_aug.dta`; `macros_csac.doh` | `$projdir/out/check/appendix_c2c.doc` |

> **Key intermediate dataset:** `csac_2025_initial_clean_aug.dta` (in `$projdir/dta/`) is the August cleaned dataset that every Stage 2–3 script reads. `clean_qualtrics_download.do` must run first.

---

## 5. Where outputs go

| Location | Tracked in git? | Contents |
|---|---|---|
| `$projdir/dta/` | **No** (Scribe-only, restricted) | Cleaned `.dta` files (`csac_2025_initial_clean_aug.dta` etc.), `email_list_withdemo.dta`, `char_by_county.dta`, and the geographic crosswalks |
| `log/` | Yes | All tabulation logs (PII-free) — the version history of the analysis |
| `out/` | Yes | Shareable CSV/Excel exports (interview lists, open-text workbook, map source data) |
| `out/check/` | Yes | `appendix_c2c.doc` — the tabulation appendix for both reports |
| `dta/ca_counties/`, `dta/interview_email_random150_batch1_flag.csv` | Yes | The committed **inputs** (shapefile, interview-team file) |
| project root (Scribe) | No | `maps.do` writes `counties.dta`, `coord.dta`, and the four `*.png` maps here (see §6) |

Most **report graphs** are produced in `Main Report Tables.xlsx` (master copy on Box), not by this code. The Stata-generated figures are the four county maps and the Figure 3 source table from `maps.do`.

---

## 6. What NOT to touch / gotchas for the next person

- **Stale un-suffixed dataset name.** `sample_char.do`, `text_qs.do`, and `interview_demo.do` read `csac_2025_initial_clean.dta` (no suffix), which the cleaning script does **not** save — it only saves `_jul` and `_aug`. Those references are **stale: they should point to `csac_2025_initial_clean_aug.dta`** (the analysis cut). The pipeline ran clean on the server because an un-suffixed copy existed in `$projdir/dta/`. If you re-clone or clear `dta/`, either recreate that copy or (better) update those three `use`/`merge` lines to read `..._aug.dta` explicitly.
- **`asdoc` is not in the install toggle.** `appendix.do` needs it. Install separately: `ssc install asdoc, replace`. The toggle only covers `randomtag`, `spmap`, `shp2dta`, `geo2xy`.
- **`maps.do` writes to the project root.** `counties.dta`, `coord.dta`, and the four `*.png` maps land in the current working directory (`$projdir` after `main.do`'s `cd`), not in `out/` or `figures/`. Look there for the maps; move them deliberately if you want them tracked.
- **Two project paths to update if relocating.** The project path is hardcoded both in `main.do` (the `cd`) and in `settings.do` (`$projdir`). Change both.
- **The cleaning step processes two exports.** `clean_qualtrics_download.do` loops over `jul` and `aug` to compare response counts; downstream analysis uses **August only**. Don't delete the July branch expecting the August output to change.
- **Don't overwrite the raw data.** The raw Qualtrics CSVs in `$rawdtadir` are the inputs; nothing should write back there.
- **No `version` is set.** Run on Scribe (the project's standard Stata install) to match the authoring environment.

---

## 7. Why it's built this way (load-bearing choices)

- **One cleaned dataset feeds everything.** All analysis reads the August cleaned dataset, so cleaning runs first and exactly once. This is the same pattern as the 2023 and 2024 waves.
- **`macros_csac.doh` centralizes the question structure.** Variable lists and human-readable labels live in one include file so the tabulation scripts stay short and the question groupings (FAFSA, college apps, transfer, demographics, open-text) are defined once.
- **One shared appendix.** Rather than maintaining separate C2C and CSAC appendices, a single `asdoc` appendix covers every referenced question; both reports cite it.
- **Geographic attributes from public NCES data.** School locale, region, and county FIPS come from the public NCES crosswalk (`nces_to_merge.dta`), merged on each respondent's high-school NCES code (`survey_25_nces.csv`). No restricted geographic data is involved. The geographic merge and the locale/region recodes (marked "jake add" in `clean_qualtrics_download.do`) were contributed by the PI, Jacob Jackson.
- **Reproducible random draws.** `set seed 1984` in every do file; the interview samples in `random_emails.do` are reproducible.

For deeper history and conventions, see `CLAUDE.md`, `CHANGELOG.md`, and the prior waves' repos (`csac_2024/`, `csac/`).

---

## 8. When something breaks

- **First look:** the per-step logs in `log/clean/` and `log/explore/`. Each script opens its own `log using`, so a failure is localized to the step whose log is truncated or missing.
- **"file ... not found" on a cleaned dataset:** almost always the stale un-suffixed name (§6) — point the read at `csac_2025_initial_clean_aug.dta`, or confirm the un-suffixed copy exists in `$projdir/dta/`.
- **`appendix.do` errors on `asdoc`:** `asdoc` isn't installed — `ssc install asdoc, replace` (§2).
- **`maps.do` errors on `spmap`/`shp2dta`:** set `local installssc = 1` in `main.do` for one run, or install those packages by hand.
- **Empty / wrong tabulations:** check that `macros_csac.doh` was `include`d *after* the `use` — the macros list variables that must already exist in memory.

### Who to ask

- **Jacob Jackson ("Jake")** — principal investigator on the project; contributed the geographic/NCES processing.
- **Christina Sun** — code author (`christinasun101@gmail.com` / `ucsun@ucdavis.edu`).
- **Stephanie Luna-Lopez** — lab GSR; ran the interview recruitment that produced the `interview_email_random150_batch1_flag.csv` input.
