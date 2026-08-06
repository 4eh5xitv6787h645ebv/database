# HDR / Dolby Vision Matching Audit — Dictionarry database (v2)

**Date:** 2026-08-06 · **Repo:** Dictionarry-Hub/database @ v2 (fresh clone, HEAD = op 210) ·
**Deliverable migration:** `database/ops/211.improve-hdr-dv-matching.sql` (local branch
`audit/improve-hdr-dv-matching`, NOT pushed)

## TL;DR

One regex has confirmed, realistic false positives: **`Dolby Vision (Without Fallback)`**
(a −999999 hard ban in 7 quality profiles) wrongly bans hyphenated **Blu-ray** spellings,
which evade the `BLURAY` substring negation despite disc-sourced DV always carrying an
HDR10 base layer:

1. `Movie.2016.2160p.Blu-ray.x265.10bit.DV.TrueHD.7.1-GROUP` (encode form)
2. `Movie.2019.2160p.COMPLETE.UHD.BLU-RAY.DV.HEVC-GROUP` (full-disc form)

The naming class is verified real: `[BD]Dark.Blue.2002.2160p.AUS.UHD.Blu-ray.DV.HDR.HEVC.DTS-HD.MA.5.1-Tux`
(hdencode) shows hyphenated `Blu-ray` + `DV` together, and
`Finding.Nemo.2003.2160p.UHD.BluRay.TrueHD.7.1.DV.x265-W4NK3R` shows disc DV without an
HDR token (only the BLURAY negation saves it).

Migration 211 changes exactly one thing: `BLURAY` → `BLU[-]?RAY` in that regex's
negation list — the same character class the project itself chose for the `UHD Blu-ray`
regex in commit `e39014f` "tweak(regex): improve Blu-ray parsing (#31)" ("Matches only
'BluRay' or 'Blu-Ray', but not 'Blu Ray'"). Git history confirms the WF negation list
was born as `BLURAY` in v1 (commit `a900cde`, tested only against MA WEB-DL titles) and
was never revisited when #31 fixed the same spelling gap in the sibling regex. After the fix: **193/193 .NET-harness checks pass (corpus includes 21
verified real-world titles), 110/110 Profilarr-parser-backed CF tests pass, zero changes
to any other pattern's results** (byte-identical matrix rows outside the 2 fixed cases).
Everything else in the HDR/DV cluster checked out correct or intended (details below).

> **Correction history:** the first draft of this audit also added `SDR` to the negation
> list for `DV.SDR` titles. Withdrawn on re-review: (a) no verified real release uses
> `DV.SDR` naming (web-searched; only DV→SDR conversion tooling surfaces); (b) it was
> mis-framed as an op-200 regression — the WF CF has matched `DV.SDR` since op 0, the
> dropped `dv(?![ .](HLG|SDR))` guard lived on the *main* `Dolby Vision` regex; (c) the
> CF description says "regular **HDR** Fallback" — an SDR base layer is not an HDR
> fallback, so the ban is arguably intended (and symmetric with `DV.HLG` escaping the
> ban because HLG *is* HDR). The corpus now pins `DV.SDR` → matches WF as intended
> behavior.

## Method

1. **State rebuild** — `harness/replay.sh` replays the schema dependency
   (Dictionarry-Hub/schema @ 1.1.0, the version pinned in `pcd.json`) then `ops/0..N`
   in order with `PRAGMA foreign_keys = ON` — exactly what profilarr's cache builder
   does (`src/lib/server/pcd/database/cache.ts`; FK cascades are load-bearing: op 88
   relies on `ON DELETE CASCADE` cleanup of `condition_patterns`). Sanity check: the
   Profilarr container links the same repo and reports the same op counts
   (schema 4 / base 211 pre-patch, 212 post-patch).
2. **Truth corpus** — `harness/corpus.json`: 70 titles × labeled expectations = 193
   checks. Titles come from Radarr's `ParserTests/QualityParserFixture.cs` (fetched,
   in `sources/`), the TRaSH-Guides HDR CF cluster (fetched, in `sources/`), standard
   P5/P7/P8 WEB-DL / hybrid remux naming, and **21 verified real release names**
   harvested from public release-name indexes (hdencode.org, srrdb.com — names only),
   marked `REAL` in the corpus. Highlights: `X-Men.97.S02E08.DV.2160p.WEB.h265-GRACE`
   (scene P5 tag order), `The.Da.Vinci.Code…MA.WEB-DL…SDR…-TheFarm` (letter-collision
   + Movies-Anywhere-exclusion probe), `The.Elephant.Man.1980.SDR.2160p.UHD.BluRay.x265-4KDVS`
   (real 4KDVS release; 'DV' inside the group name must not match),
   `Inception.2010…MA.WEB-DL.DTS-HD.MA.5.1.SDR…` (dts-hd lookbehind),
   `Force.of.Nature…SDR.HEVC.REMUX-FraMeSToR` (real SDR remux validating the SDR
   negation in HDR10 (Missing)), and `007.Contra.Goldfinger…UHD.BluRay.x265-CEBRAY`
   (untagged UHD encode, group ends in "RAY" as a negation probe). Labels cover both regex-level and
   CF-level (condition-graph) semantics — CF-level composites mirror
   `custom_format_conditions` (e.g. `Dolby Vision (Without Fallback)` = WF-regex AND
   NOT `HDR` AND NOT `HDR10+`, per op 182).
3. **.NET matrix** — `harness/RegexMatrix` (net10.0) evaluates every labeled pair with
   `RegexOptions.IgnoreCase`, i.e. Radarr/Sonarr semantics (required because the WF
   regex uses variable-length lookbehind that PCRE/Python `re` cannot compile).
4. **Independent validation** — a Profilarr v2.0.9 + profilarr-parser container pair
   (see below) runs the same cases as native `custom_format_tests` rows through the
   real arr parser, which also exercises the source/resolution conditions the offline
   harness can only approximate. Both runners agree in both directions: pre-patch both
   fail the same Blu-ray titles; post-patch the container passes 110/110.

## Effective patterns audited (fully replayed DB, op 210)

| Regex | Pattern |
|---|---|
| Dolby Vision | `\b(DV\|Dovi\|Dolby[ .]?Vision)\b` |
| Dolby Vision (Without Fallback) | `(?<=^(?!.*(HDR\|HULU\|REMUX\|BLURAY)).*?)\b(DV\|Dovi\|Dolby[ .]?Vision)\b` |
| Basic HDR Formats | `\bHDR(\b\|\d)\|\b(DV\|Dovi\|Dolby[ .]?Vision\|HLG\|PQ(10)?)\b` |
| HDR | `\b(HDR(10\|(?!\d))\|HLG\|PQ(10)?)\b` |
| HDR10+ | `\bHDR10.?(\+\|P(lus)?\b)` |
| SDR | `\bSDR\b` |

Condition graph (release-title parts): `Dolby Vision` CF = DV regex alone;
`Dolby Vision (Without Fallback)` CF = WF regex AND NOT HDR AND NOT HDR10+ (op 182);
`HDR` CF = HDR AND NOT HDR10+; `SDR` CF = 2160p + WEB-DL + NOT Basic HDR Formats +
NOT Movies Anywhere; `HDR (Missing)` = 1080p BluRay + DV + x265 + NOT HDR/HDR10+/SDR;
`HDR10 (Missing)` = 2160p BluRay(+Remux) + NOT HDR/HDR10+/SDR + group ≠ BHDStudio.

Scores that set severity: `Dolby Vision (Without Fallback)` = **−999999** in 1080p
Efficient / 1080p Quality HDR / 1080p Remux / 2160p Balanced / 2160p Efficient /
2160p Quality / 2160p Remux. A false positive there is a hard ban of a legitimate
release.

## Findings

### Fixed by migration 211 (demonstrated by failing tests, then re-proven green)

| # | Title | Before | After | Why it's wrong |
|---|---|---|---|---|
| 1 | `Movie.2016.2160p.Blu-ray.x265.10bit.DV.TrueHD.7.1-GROUP` | WF CF matches → −999999 | no match | "Blu-ray" is a verified real spelling (Radarr fixtures `…720p.Blu-ray.Remux…-SiCFoI`; hdencode `[BD]Dark.Blue…UHD.Blu-ray.DV.HDR…-Tux`, `Cruel.Story.of.Youth…UHD.Blu-ray.Remux…-CiNEPHiLES`); disc-sourced DV is P7 dual-layer (UHD BD mandates an HDR10 base layer) |
| 2 | `Movie.2019.2160p.COMPLETE.UHD.BLU-RAY.DV.HEVC-GROUP` | WF CF matches → −999999 | no match | same, full-disc form |

**The fix** (one guarded UPDATE, house format, optimistic-locked on name + exact old
pattern):

```
(?<=^(?!.*(HDR|HULU|REMUX|BLU[-]?RAY)).*?)\b(DV|Dovi|Dolby[ .]?Vision)\b
```

No false-negative risk: a genuinely fallback-less P5 WEB-DL title never contains a
Blu-ray token (verified by the should-match rows, incl. real `X-Men.97…DV.2160p.WEB…-GRACE`,
`Star.Trek.Strange.New.Worlds…ATV.WEB-DL.DD5.1.DV.HEVC-NTb`, lowercase
`ted.lasso.s04e01.dv.2160p.web.h265-cakes`, `DoVi`, `Dolby.Vision`, WEBRip DV), and the
group `-CEBRAY` (ends in "RAY") does not trip `BLU[-]?RAY`.

### Checked and left alone (intended behavior or unobservable)

- **`DV.SDR` (withdrawn fix)** — matched by the WF CF since op 0 and kept that way: no
  verified real release uses the naming, an SDR base layer is not a "regular HDR
  Fallback" per the CF's own description, and profiles that want SDR flagged have the
  `SDR` CF. Pinned in the corpus as intended behavior.
- **`DV.HLG` and the Without-Fallback regex** — the raw WF regex matches `DV.HLG`
  (HLG missing from its internal negation list), but the CF is saved at the condition
  level: op 182's negated `HDR` condition uses the `HDR` regex, which matches HLG.
  CF-level result is correct today; adding HLG to the regex would change nothing
  observable, so per evidence-backed minimalism it stays. (If the CF-level negation is
  ever removed, this becomes a live bug — noted here for the future.)
- **Op 200 dropping `dv(?![ .](HLG|SDR))` from `Dolby Vision`** — consequences: DV.HLG /
  DV.SDR hybrids now (a) earn the +3000 DV bonus in 2160p profiles and (b) are caught
  by the −999999 DV ban in 1080p Balanced/Compact/Quality/720p Quality (pre-200 a
  `DV.SDR` title escaped both the DV ban and the HDR ban there, which was itself
  dubious). Both directions are defensible; the release *is* DV. Judged an intended
  simplification; no change.
- **`HDRip`** — correctly rejected by both `Basic HDR Formats` (`\bHDR(\b|\d)`, op 206)
  and `HDR` (`HDR(10|(?!\d))` + trailing `\b`). Verified in the matrix.
- **Release group literally named "HDR"** (`Movie.2016.1080p.BluRay.x264-HDR`) — matches
  the HDR cluster. Unfixable at title-regex level without losing real positives;
  TRaSH's `\bHDR(\b|\d)` behaves identically. Documented as accepted limitation.
- **`HDR` regex does not match `HDR10Plus`** (no word boundary between `0` and `P`).
  Harmless everywhere: every consumer either pairs `HDR` with an `HDR10+` negation or
  wants exactly that outcome; `HDR10+` regex (`\bHDR10.?(\+|P(lus)?\b)`) catches
  `HDR10+`/`HDR10Plus`/`HDR10.Plus` — all verified.
- **`HDR10 (Missing)` in Sonarr** — required source `bluray` coexists with non-required
  `bluray_raw` (remux); Sonarr parses remuxes as `bluray_raw`, so the required condition
  can't hold. The CF description already documents "*does not work properly in
  sonarr*" — known, intended-as-documented.
- **Untagged 2160p remux** (`…UHD.BluRay.REMUX…-FraMeSToR`, no HDR token) is classified
  by `HDR10 (Missing)` as assumed-HDR10 (+1000) — matches the format's stated intent;
  verified via the parser-backed container test (source/resolution conditions parse
  correctly).
- **Fake-DV/HDR banned groups** (BiTOR, DepraveD, Flights, SM737, SumVision, 4KDVS,
  plus VECTOR/SasukeducK/tarunk9c/jennaortegaUHD/VisionXpert) — all live in the
  consolidated `Banned Groups` CF as `release_group` conditions (matched against the
  arr-parsed group, where `(?<=^|[\s.-])Name\b` anchors correctly); title-form
  `…HEVC-BiTOR` also matches. Coherent; no change.
- **Orphaned regexes** — `Non Retail HDR Formats`, `Non Retail HDR Groups`,
  `HDR10 (Missing Groups)` are referenced by no condition (leftovers of the pre-190
  banned-group structure). Zero runtime effect; deleting rows is not needed for
  correctness and would violate change-minimalism, so left (cleanup candidate for a
  future housekeeping op).
- **Not covered by any pattern, judged too rare to act on**: underscore separators
  (`Dolby_Vision`), `Dolby-Vision` hyphen (op 200 deliberately reverted `[- .]` to
  `[ .]`), and BDRip-sourced DV encodes without a BluRay/Remux token (genuinely
  ambiguous between P5 conversions and fallback-preserving encodes).

## Extended sweep: is this bug class anywhere else? (3-agent audit of all 533 regexes)

Three parallel audit agents swept every regex (with usage context: which format uses it,
negated or positive) for the same bug class; every candidate was demonstrated under the
.NET harness and the live findings were independently re-verified. Results:

### Fixed by migration 212 (`ops/212.improve-remux-and-german-dl-matching.sql`)

- **`Remux` — `\b(Remux)\b` misses joined `BDRemux`/`BDREMUX`/`UHDremux`** (real
  Russian/Spanish tracker naming; Radarr's QualityParser accepts `(BD|UHD)[-_. ]?Remux`).
  The regex feeds **49 formats**: it is the "Not Remux" gate of every Quality Tier CF and
  the positive trigger of `Remux`/`Banned Remux`. Worst demonstrated compound:
  `Interstellar.2014.1080p.BDRemux.AVC.DTS-HD.MA.5.1-HDCLUB` fires the **Full Disc** CF
  (−999999 in all 11 profiles) because Full Disc's unanchored `AVC` branch matches and the
  broken Remux gate no longer rescues it. Fix: `\b((BD|UHD)[-_. ]?)?Remux\b`
  (Radarr-parser-aligned; control `-LazyRemux` group still unmatched).
- **`German DL` — guard `(?<!WEB-)` only covers the hyphen spelling of WEB-DL.**
  `The.German.Doctor.2013.1080p.WEB.DL.DD5.1.H264-GROUP` / `A German Life 2016 720p WEB DL
  x264-GROUP` (English releases whose titles contain "German") read the `DL` of dotted or
  spaced WEB-DL as Dual Language → **−999999 ban in 11 profiles**. Fix: `(?<!WEB[-_. ])`,
  the separator class used throughout the DB. Controls: hyphen spelling still guarded,
  real `German.DL` dual-language still matches.

### Documented, deliberately NOT fixed (need maintainer judgment — pinned in corpus as KNOWN)

- **`Full Disc` structural flaw**: the trailing `(?i)(DVD9|DVD5|NTSC|PAL|VOB IFO|VC-1|AVC|MPEG-2|…)`
  alternative sits OUTSIDE the regex's own `^(?!…BDRip|XviD|REMUX…)` guard and is largely
  unanchored. Demonstrated CF-level false positives that survive the source-condition
  rescue: `Movie.2005.PAL.DVDRip.XviD-GROUP`, `Movie.1988.NTSC.DVDRip.XviD-GROUP` (DVD
  source is not excluded), plus `PAL` matching inside words ("Palm", "Palace" — those
  specific ones are rescued by the Not-WEB-DL source condition). Migration 212 already
  neutralizes the worst compound (BDRemux.AVC). A full fix requires restructuring the
  alternation (the tail can't simply move under the guard — DVD9/PAL discs must match
  despite `DVD` being a guard token), so it's left for upstream with this analysis.
- **`Dolby Digital` family gaps** (false negatives / partial): spelled-out
  `Jawan.2023…WEB-DL.Dolby.Digital.5.1…-Telly` matches neither DD nor DD+ (the DV cousin
  supports `Dolby[ .]?Vision`; DD only knows the abbreviation); canonical
  `…WEB-DL.E-AC-3.2.0…` also matches neither (`e[-_. ]?ac3` lacks `ac[-_. ]?3`); `E.AC3`
  falsely matches DD but is rescued at CF level by the DD+ negation. Direction: audio CFs
  score 0 / negations fail open on multi-audio titles — no bans, so lower severity.
- **`HDR` regex doesn't match `HDR10Plus`** — safe everywhere (every negated use pairs it
  with `HDR10+`, which does match), already documented above.

### Latent (orphan regexes — zero runtime effect today, fix-or-delete before wiring)

- **`Non Retail HDR Formats`** — its DV branch `dv(?![ .](HLG|SDR))` reproduces the exact
  pre-fix Without-Fallback bug: retail `DV.HDR`/`DV.HDR10Plus` hybrids and even
  `UHD.BluRay.REMUX.DV.HDR10` remuxes are classed "non-retail". Referenced by zero
  conditions.
- **`Non Retail HDR Groups`** — missing parentheses: `(?<=^|[\s.-])VECTOR|BiTOR|…|Flights\b`
  anchors bind only to the first/last alternatives, so the middle six group names match as
  bare substrings (`BiTOR` inside "Inhi**bitor**" — demonstrated). Also orphaned.
- `HDR10 (Missing Groups)`, `TrueHD (Missing Groups)` — unwired group lists.

### Cleared

All other negation-bearing regexes (x264/x265 remux guards, IMAX/NON-IMAX, HBO-Max,
Movies Anywhere dts-hd lookbehind, Opus, DTS family cross-negations, edition guards,
B&W family) and the WEB-DL/streaming-service separator classes were examined and
adjudicated clean; per-regex verdict tables are in the agent reports.

## Proof

- `matrix-before.tsv` — 210 checks against pristine upstream (no 211/212), 9 failures:
  the 2 WF Blu-ray false positives, 3 Remux false negatives, 2 Full Disc compound false
  positives, 2 German DL false positives.
- `matrix-after.tsv` — 210 checks with migrations 211+212, 0 failures. `diff` shows
  exactly those 9 rows flipping to ok;
  every other (title, pattern) row — including Dolby Digital/DD+, iTunes, Movies
  Anywhere, Remux, UHD Bluray, x265 and all fake-DV group regexes — is
  byte-identical, i.e. zero regressions.
- Profilarr container (real arr parser): post-patch **120/120** CF tests pass across 9
  formats incl. `Remux` and `German DL` (pre-patch verified failing the Blu-ray cases in
  an earlier run).

## Reusable harness / how to rerun

```
./harness/replay.sh database/ops current.db          # replay state (add extra .sql args as needed)
python3 harness/build_input.py current.db harness/corpus.json > in.json
cd harness/RegexMatrix && dotnet run -c Release < ../../in.json   # exit 0 = all pass
```
(`DOTNET_ROOT=$HOME/.dotnet`, SDK 10.0.302 used.)

`harness/gen_cf_tests.py` regenerates `database/tweaks/hdr-dv-truth-corpus.sql` — 110
`custom_format_tests` rows — from the corpus.

## Profilarr test container (test cases live in the UI)

`docker-compose.yml` runs Profilarr v2.0.9 + parser at **http://localhost:6869**
(login `audit` / `hdr-audit-2026`). The auto-linked "Dictionarry" database clone (in
`profilarr-config/data/databases/<uuid>/`) carries `ops/211` and
`tweaks/hdr-dv-truth-corpus.sql`; the tweaks layer loads the 110 test cases without
touching append-only ops history. Browse them under **Custom Formats → (any HDR/DV
format) → Testing** — each shows expected vs actual with per-condition evaluation from
the real parser. Note: Profilarr rejects non-GitHub repository URLs, so the patched
repo was injected into the auto-linked clone (base-ops re-import happens on container
restart) rather than linked as a separate database.

## Files

```
database/                        fresh clone, branch audit/improve-hdr-dv-matching (local only)
  ops/211.improve-hdr-dv-matching.sql   HDR/DV fix (committed locally)
  ops/212.improve-remux-and-german-dl-matching.sql   sweep fixes (committed locally)
  tweaks/hdr-dv-truth-corpus.sql        120 profilarr custom_format_tests rows
schema/                          Dictionarry-Hub/schema @ 1.1.0 (replay dependency)
profilarr/                       profilarr source (schema + importer semantics reference)
sources/                         fetched TRaSH CFs + Radarr parser fixtures (citations)
harness/                         replay.sh, corpus.json, build_input.py, RegexMatrix/, gen_cf_tests.py
matrix-before.tsv, matrix-after.tsv, current.db, after.db
docker-compose.yml, profilarr-config/   running validation environment
```
