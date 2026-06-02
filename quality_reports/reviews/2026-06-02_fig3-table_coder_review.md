# fig3_table.do Review — coder-critic

**Date:** 2026-06-02
**Reviewer:** coder-critic
**Target:** do/share/fig3_table.do
**Score:** 86/100
**Status:** Active
**Mode:** Full (plan + script under review; air-gapped)

---

## Code-Strategy Alignment: MATCH

The script implements what the plan (`quality_reports/plans/2026-06-02_fig3-county-region-rate-table.md`) and session log specify, with one structural simplification that is consistent with what the session log resolved.

What the plan said to do vs. what the script does:

| Plan element | Script line | Status |
|---|---|---|
| Standalone do-file in `do/share/` | file exists | MATCH |
| Input `dta/char_by_county.dta` (from `maps.do`) | L28 `use $projdir/dta/char_by_county.dta, clear` | MATCH |
| Output `out/fig3_county_region_rate.csv` | L54 | MATCH |
| Keep only `countyname`, `schoolregion`, `heard_fafsa_early` | L32 | MATCH |
| Rate as percentage with 1 decimal | L39 `round(heard_fafsa_early * 100, 0.1)` | MATCH |
| Sort by region then county | L47 `gsort region county` | MATCH (semantics: see note below) |
| Drop numeric→name `replace` block (per session log resolution) | absent by design | MATCH (deliberate; session log §"Decisions resolved" item 1) |
| `assert region != ""` diagnostic | L51 `assert !mi(region)` | MATCH (numeric form — region is numeric with value label, so `!mi()` is the correct check, not `!= ""`) |

The rate is **not recomputed** — it is read from the already-broadcast `heard_fafsa_early` field in `char_by_county.dta`, exactly per the "stats source of truth" constraint. The fact that every county in a region shows the same value is preserved by design.

## Sanity Checks: PASS (with one unverified assumption)

- **Sign / magnitude:** plausible. Rate is multiplied by 100 to convert proportion → percentage. Plan's spot-check (≈70% for LA/Central Coast/SF Bay/SD-Imperial; ≈56–59% prior for Superior/N SJV/S SJV/N Coast) is checkable against the CSV once it runs on the server.
- **Sample size:** the script does not change the sample. It is a pure transformation+export of `char_by_county.dta`.
- **`gsort region county` codebook-order claim:** the script's sort order yields the codebook north→south order **because `region` is numeric with a value label, and `gsort` sorts numeric variables by their numeric code, not by displayed label**. Codebook (per session log): `1=Superior, 2=North Coast, …, 10=SD-Imperial`. The xwalk (`out/county_region_xwalk.csv`) is consistent with this ordering. **Concern (Minor):** this property is *not commented* in the script. A future reader who only reads the code might assume `gsort region` produces alphabetical-by-label order ("Central Coast" → "SD - Imperial" → "SF Bay Area" → "Superior" — clearly not north→south). One sentence in the comment block near L30 would prevent that misreading. (Comment at L30 mentions that the label is exported as the name in the CSV, which is correct and useful — but does not mention the gsort consequence.)
- **`assert heard_fafsa_early >= 0 & heard_fafsa_early <= 1 if !mi(...)`** at L37: necessary and sufficient. Cheap; defensible. Catches the failure mode where `maps.do` is replaced with one that already-percentages the value, which would silently produce `rate ∈ [0, 10000]` and a broken CSV.

## Robustness: Complete

The script is a single-output transformation; "robustness checks" don't apply in the inferential sense. The three `assert` statements (rate in [0,1], `!mi(region)`, `!mi(rate)`) are the right defensive surface for this script given air-gapped execution. The plan's verification step ("Spot-check 2–3 regional rates against Figure 3") is appropriate and out of scope for the script itself — it is a human check on the CSV.

---

## Code Quality (10 categories)

| # | Category | Status | Issues |
|---|----------|--------|--------|
| 4 | Script structure & header | OK | Block-comment header at L1–20 names purpose, source variable, input, output, run command. Good. |
| 5 | Console output hygiene | OK | No `display`/`di`/banners. Only the standard log open/close. |
| 6 | Reproducibility | OK with caveats | Paths use `$projdir` globals (good). `set more off`, `set varabbrev off` set (good). `log close _all` before `log using` (good). **No `set seed`** — not needed (no stochastic operations). **No `cap`** before `log close _all` — consistent with the rest of the project (`do/share/maps.do:7`, `do/share/appendix.do:10`, etc. all use bare `log close _all`); not a deduction. **Caveat:** the script writes to `$projdir/log/share/`, and `log/share/` does not exist in the local repo (only `log/clean/` and `log/explore/` exist). If it does not exist on Scribe either, `log using` will fail. The script does not `cap mkdir $projdir/log/share` first, nor is there a `cap confirm new file` guard. (See punch list item 1.) |
| 7 | Function/program design | N/A | Script-level, no programs. Does not `include $projdir/do/macros_csac.doh` — every other share/ script does (`maps.do:18`, `appendix.do:26`, `random_emails.do:18`, `text_qs.do:11`, `interview_demo.do:17`). For this script the include is not load-bearing — no `local` macros from `macros_csac.doh` are referenced — but it is a project-style consistency miss worth noting. |
| 8 | Figure quality | N/A | No figures produced. |
| 9 | Output persistence | OK | `export delimited ... replace` at L54. CSV is the requested deliverable. |
| 10 | Comment quality | OK with one gap | Block header is purposeful (explains WHY the rate is uniform within region — important for the PI reading the CSV). The `// ASSUMPTION` and `// DIAGNOSTIC` comments above the asserts explain WHY, not WHAT. **Gap:** as noted under Sanity Checks, the `gsort region county` line does not document that the sort key is the underlying numeric code (which equals the geographic north→south ordering). |
| 10b | Stata comment safety | PASS | One `/*` (L1), one `*/` (L20) — balanced. No path-glob `*` inside any comment context (L20 closes a block; the `*/` on its own does not introduce an unbalanced state). No Variant-7 `//*****` banners. No Variant-8 over-flatten artifacts (`^-+<x>$` / `^\s*<x>\s*$`) — 0 matches. |
| 11 | Error handling | OK with caveat | Three `assert` statements form a reasonable defensive surface. One missing guard: if `dta/char_by_county.dta` does not exist (i.e., `maps.do` has not been run), the `use` at L28 errors out — a plain Stata r(601). The header comment does explain that staleness symptoms map back to "re-run maps.do," which is the right remediation message. **Consider** `cap confirm file $projdir/dta/char_by_county.dta` with a more explicit `display` message; not strictly required since Stata's own error is informative. The post-sort asserts at L51–52 are *somewhat redundant* with the `[0,1]` assert at L37 (if `heard_fafsa_early` is in [0,1] and `rate = round(...*100, 0.1)`, then `rate` is non-missing iff `heard_fafsa_early` is non-missing) — but they are cheap and they document expected post-condition, which is fine in an air-gapped context where the author cannot re-run on failure. Not a deduction. |
| 12 | Professional polish | OK | Consistent indent. Line length under 100. No legacy idioms. |

---

## Air-gapped workflow compliance

Per `.claude/rules/air-gapped-workflow.md`:

| Requirement | Status |
|---|--------|
| `// ASSUMPTION:` comments document non-derivable facts | PARTIAL — L34 documents the proportion-vs-percentage assumption. The "schoolregion carries the region value label" claim at L30 is documented (which is the other non-derivable fact). |
| `// DIAGNOSTIC:` markers on output share-worthy with Claude | YES — L49 |
| `assert _N > 0` / `assert !missing(key_var)` | YES — `!mi(region)`, `!mi(rate)` post-sort |
| Version-dep flags (`// REQUIRES: ...`) | N/A — only `use`, `keep`, `gen`, `rename`, `assert`, `export delimited` used; all core syntax |

This is one of the better air-gapped scripts in the repo from a defensive-coding standpoint — the asserts are placed where they catch the most likely silent-failure modes (heard_fafsa_early on wrong scale; stale dta missing region for a county). The post-sort `!mi(rate)` is somewhat redundant but documents an invariant; fine.

---

## Compliance Evidence (from .claude/state/verification-ledger.md)

The verification ledger contains only example rows (no entries for `do/share/fig3_table.do`). The file was newly created in this session.

- `do/share/fig3_table.do` | no-hardcoded-paths | (MISSING — but verified in this review: `grep -nE '"/Users|"/home|"C:\\\\' do/share/fig3_table.do` returned 0 matches)
- `do/share/fig3_table.do` | seed-set-once | (N/A — no stochastic operations)
- `do/share/fig3_table.do` | comment-balance | (MISSING — but verified in this review: 1 `/*` and 1 `*/`, balanced; no Variant-8 artifacts; no path-glob `*` in comment contexts)
- `do/share/fig3_table.do` | no-logic-change | (N/A — this is a *new* file, not a refactor; the no-logic-change gate does not apply)
- `dta/char_by_county.dta` exists on server | ASSUMED — cannot verify from local (air-gapped). Header documents staleness remediation path.

Per protocol: because rows are missing for a file that was just authored in-session and verified within this review (the critic ran the grep checks above directly), this is treated as in-session verification with evidence cited inline, not as a missing-ledger deduction. The session log notes the file was authored today; the local file hash will be a fresh entry on first PostToolUse-recorder pass.

No advisory deductions for Tier-1 evidence gating: the file is new (no prior no-logic-change claim), and the in-session checks confirm the static-analysis criteria.

---

## Derive-don't-guess evidence

The script's referenced entities are all derived from the existing repo:

| Entity | Source cited |
|---|---|
| `$projdir/dta/char_by_county.dta` | `do/share/maps.do:69` (`save $projdir/dta/char_by_county.dta, replace`) — confirmed |
| `heard_fafsa_early` | `do/share/maps.do:38–41` (gen + replace + lab var) — confirmed |
| `$projdir/log/share/` | NOT derived — no other script writes to `log/share/`. Other scripts use `log/clean/`, `log/explore/`. The directory may not exist. (See punch list item 1.) |
| `$projdir/out/fig3_county_region_rate.csv` | New filename — consistent with sibling exports (`out/map_data_by_county.csv`, `out/county_region_xwalk.csv`, `out/proximity_by_county.csv` — all from `maps.do`). New convention disclosed in plan. |
| `schoolregion` carries `region` value label | Verified in `out/county_region_xwalk.csv` — column 3 contains label strings ("SF Bay Area", "Superior", "SD - Imperial"), not integers. |

Minor disclosure gap: the log path `$projdir/log/share/` does not exist locally and is not used by any other do-file. The script either needs to create the directory or to write to a different location. This is the only fabricated path; otherwise derivation is complete.

---

## Score Breakdown

- Starting: 100
- **−5** Output convention drift on log file: project uses `.txt, text replace` for log files (every other invocation: `maps.do` does not write a log; `clean_qualtrics_download.do:9`, `tab_questions.do`, `sample_char.do:9` all use `.txt, text replace`). This script writes a binary SMCL `.log` instead, which is less greppable and less consistent with siblings.
- **−5** Log directory `$projdir/log/share/` does not exist in the local repo and is not used by any other do-file. The script does not `cap mkdir` it or `cap confirm` it. If absent on Scribe, `log using` fails before the body runs. In air-gapped mode the author cannot pre-verify; a `cap mkdir` would be cheap insurance.
- **−2** Style/consistency: does not `include $projdir/do/macros_csac.doh` while every other share/ script does. Not load-bearing here (the script does not depend on the macros), but inconsistent with the project pattern. (Acceptable to keep this script lean; flagged for awareness.)
- **−2** Comment gap: the `gsort region county` line works because `region` is numeric with a value label and Stata sorts numeric vars by code (1=Superior … 10=SD-Imperial, north→south). The plan and session log treat this as obvious; the script does not document it. A future reader who only reads the code would not know that the sort key is the underlying integer and could misread the CSV order.
- **Final: 86/100**

Above the 80-commit gate; below the 90-PR gate. Two of the four deductions are cheap to fix (log path + extension); the other two are documentation gaps.

---

## Punch list (recommended changes — critic does not edit)

1. **Log path safety.** Insert before `log using` at L26:
   - `cap mkdir "$projdir/log/share"` (idempotent; succeeds if dir exists), OR
   - confirm with the user that `log/share/` already exists on Scribe.

2. **Log file format consistency.** Change L26 to match the project convention:
   - `log using $projdir/log/share/fig3_table.txt, text replace`
   This produces a plain-text log greppable from the local repo after download, matching `do/clean/clean_qualtrics_download.do:9` and the `do/explore/tab_questions.do` pattern.

3. **Comment the `gsort` semantics.** Add one comment above L47:
   - `// region is numeric with the "region" value label (1=Superior ... 10=SD-Imperial).`
   - `// gsort sorts by the numeric code, which equals the codebook north→south order.`
   - `gsort region county`
   This prevents a future reader from assuming the order is alphabetical-by-label.

4. **(Optional, low-impact) Tighten the post-sort asserts.** The `assert !mi(rate)` at L52 is implied by the `[0,1]` assert at L37 plus the fact that `round(.*100, 0.1)` of a non-missing value cannot produce missing. If you prefer minimalism, drop L52. If you prefer post-condition documentation in air-gapped contexts, keep it. (Recommend keeping it — the cost is one assert; the value is a documented invariant.)

5. **(Optional) Consider `include $projdir/do/macros_csac.doh`** for style consistency with the rest of `do/share/`. The macros are not used here, so this is a low-stakes call. If you add it, do it for project-pattern uniformity; if you keep it out, that's defensible too. Not a blocker.

---

## Escalation Status: None

No worker-critic strike. The script is functionally aligned with the strategy memo / plan, and the four deductions are documentation- and convention-level. A single revision addressing items 1–3 in the punch list would put this at 96+ for the PR gate.
