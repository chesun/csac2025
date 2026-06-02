<!-- primary-source-ok: census_2020 -->
<!-- Reason: "California Census 2020" is referenced as the data source for region naming conventions cited in the report's Table 5 note, not as a framing claim about a research paper. -->

# Plan: County–Region–Rate Table for CSAC Report Figure 3

**Date:** 2026-06-02
**Status:** DRAFT — awaiting approval
**Requestor:** PI (CSAC 2025 Survey Report, copy-editing phase)
**Deliverable:** A CSV table backing Figure 3 with columns `county`, `region`, `rate`.

---

## Goal

Produce a table of California counties paired with their region and the Figure 3 rate (percentage of students who learned about FAFSA/CADAA prior to senior year, by region). Output as CSV for the PI to include in the report.

## What I derived from the codebase

| Fact | Source |
|---|---|
| Figure 3 variable is `heard_fafsa_early`, labeled "Heard FAFSA Junior Year or Prior" | `do/share/maps.do:38-41` |
| Figure 3 N = 4,826 | `paper/CSAC 2025 Survey Report_CE-2.docx`, Figure 3 note |
| Rate is computed at the **region** level (collapse by `schoolregion`), then broadcast to every county in the region via `merge m:1 schoolregion` | `do/share/maps.do:50, 65` |
| Region names appear in the report (Table 5): Superior, North Coast, San Francisco Bay Area, Northern San Joaquin Valley, Central Coast, Southern San Joaquin Valley, Inland Empire, Los Angeles County, Orange County, San Diego–Imperial (10 regions) | `paper/CSAC 2025 Survey Report_CE-2.docx`, Table 5 |
| `schoolregion` in the data is **numeric** (1–10); no name labels are defined in `do/clean/clean_qualtrics_download.do` or `do/macros_csac.doh` | `grep schoolregion` across `do/` |
| Existing exports in `out/`: `map_data_by_county.csv` (geoid + rates as proportions), `county_region_xwalk.csv` (geoid + countyname + schoolregion numeric) | `do/share/maps.do:70, 72, 90` |
| Counties are CA only (filter `strpos(geoid,"06")==1`); San Joaquin (06077) hardcoded to region 4 | `do/share/maps.do:61, 63` |

## Structural property the PI should know

Because the rate in Figure 3 is computed at the region level, **every county in the same region will display the same `rate` value** in the table. If region X is 65.4%, all 7 counties in region X show 65.4%. That is the truth of the figure — not a bug. If the PI actually wants county-level rates (computed only from respondents within each county), that is a different analysis and the current sample sizes are likely too thin for county-level estimates in low-population counties.

## Open questions to confirm before I write code

1. **Rate format** — percentage with 1 decimal (e.g., `68.4`) or proportion (e.g., `0.684`)? The Figure 3 caption uses "Percentage." **Default: percentage, 1 decimal.**
2. **Granularity** — county-level table (≈58 rows, rate repeats within region) or region-level summary (10 rows)? PI's wording "county, region, rate" implies county-level. **Default: county-level.**
3. **Region label source** — I plan to use the report's Table 5 names (Superior, North Coast, …). However, Table 5 as printed has an apparent **inconsistency**: the "Central Coast" row lists Riverside and San Bernardino, which also appear in the next row under "Inland Empire." The authoritative source cited is the California Census 2020 regions page. **Question for PI: which county→region list should I treat as authoritative?** Options I see:
    - The numeric `schoolregion` codes already in the cleaned data (we'd map them to names — I need the PI or a quick `tab schoolregion countyname` from the server to lock the numeric→name mapping)
    - A hardcoded list from the California Census 2020 regions page (10 regions)
    - The list as printed in the report (with the Riverside/San Bernardino duplication corrected)
4. **Sort order** — region (in the same order as Figure 3's legend) then county alphabetically? **Default: yes.**
5. **Output filename** — `out/fig3_county_region_rate.csv`? **Default: yes.**

## Implementation plan (after PI confirms)

### Step 1 — Write a standalone do-file `do/share/fig3_table.do`

Standalone (not appended to `maps.do`) so it can be re-run without re-generating maps, and doesn't depend on the shapefile merge.

```stata
* fig3_table.do — county–region–rate table backing Figure 3
* Input:  $projdir/dta/char_by_county.dta (produced by maps.do)
* Output: $projdir/out/fig3_county_region_rate.csv

include $projdir/do/macros_csac.doh

use $projdir/dta/char_by_county.dta, clear
keep countyname schoolregion heard_fafsa_early

* attach region names (numeric→name mapping to be confirmed by PI / server tab)
gen region = ""
replace region = "Superior"                    if schoolregion == <code>
replace region = "North Coast"                 if schoolregion == <code>
replace region = "San Francisco Bay Area"      if schoolregion == <code>
replace region = "Northern San Joaquin Valley" if schoolregion == <code>
replace region = "Central Coast"               if schoolregion == <code>
replace region = "Southern San Joaquin Valley" if schoolregion == <code>
replace region = "Inland Empire"               if schoolregion == <code>
replace region = "Los Angeles County"          if schoolregion == <code>
replace region = "Orange County"               if schoolregion == <code>
replace region = "San Diego-Imperial"          if schoolregion == <code>

assert region != ""   // diagnostic: every county must map to a region

* rate as percentage with 1 decimal
gen rate = round(heard_fafsa_early * 100, 0.1)
rename countyname county
keep county region rate
order county region rate
gsort region county

export delimited using $projdir/out/fig3_county_region_rate.csv, replace
```

The `<code>` placeholders need the numeric → name mapping. Resolution path: PI (or you) runs `tab schoolregion countyname` on the server one time and shares output; I lock the mapping in the do-file.

### Step 2 — User runs on Scribe server

```
do $projdir/do/share/fig3_table.do
```

(Requires `dta/char_by_county.dta`, which `maps.do` already produces. If that file is stale, `maps.do` should be re-run first.)

### Step 3 — User downloads `out/fig3_county_region_rate.csv` from Scribe and reviews

## Verification

- `out/fig3_county_region_rate.csv` exists and has ~58 rows + header.
- Three columns: `county`, `region`, `rate`.
- Every county in the same region shows the same `rate`.
- `assert region != ""` passes — proves the numeric→name mapping covers every county.
- Spot-check 2–3 regional rates against Figure 3 in the report (≈70% for LA County, Central Coast, SF Bay Area, San Diego–Imperial; 41–44% senior-year-only for Superior, Northern SJV, Southern SJV, North Coast — implying ≈56–59% prior).

## Risks / constraints

- **Server-only execution** (per `air-gapped-workflow.md`) — I write the do-file; the PI or you runs it on Scribe and shares the CSV.
- **Numeric → region-name mapping is the one fact I can't fully derive from the local repo.** Plan: have you (or the PI) run `tab schoolregion countyname` plus a spot-check on the server before I finalize the code, OR confirm the numeric ordering matches a known list.
- **Report Table 5 inconsistency** — Riverside/San Bernardino appear under both "Central Coast" and "Inland Empire." Flag to PI; awaiting authoritative resolution.
- **Stats source rule** — the rate values come directly from the existing `heard_fafsa_early` collapse; no new numbers invented.
