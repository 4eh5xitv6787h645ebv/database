# Audit-and-fix loop ledger

started_at: 2026-08-06T15:35:00Z
consecutive_dry: 0
iteration: 1

Repo: fork `4eh5xitv6787h645ebv/jakes-profilarr-database`, branch `fix/regex-audit` (based on upstream v2 @ op 210).
NOTE: this fork also hosts the user's LIVE v1 profilarr branches `stable` and `custom` — NEVER touch those branches.
Harness: `audit/harness/` (schema dependency clone expected at `../../schema` relative to repo root, i.e. `~/work/dictionarry-fix-loop/schema`).
Prowlarr (metadata search ONLY): http://localhost:9696, API key via `docker exec prowlarr sh -c 'grep -oE "<ApiKey>[^<]*</ApiKey>" /config/config.xml'`. Never download content; names only. If names can't settle a hypothesis → NEEDS-MANUAL-VERIFICATION.

## Settled verdicts (do NOT re-test)

### TRUE-BUG-FIXED
- **Dolby Vision (Without Fallback): BLURAY negation missed Blu-ray/BLU-RAY spellings** → op 211 (`BLU[-]?RAY`, matching house precedent PR #31/e39014f). Titles: `Movie.2016.2160p.Blu-ray.x265.10bit.DV.TrueHD.7.1-GROUP`, `Movie.2019.2160p.COMPLETE.UHD.BLU-RAY.DV.HEVC-GROUP`; class proven real by `[BD]Dark.Blue.2002.2160p.AUS.UHD.Blu-ray.DV.HDR.HEVC.DTS-HD.MA.5.1-Tux` (hdencode).
- **Remux: `\b(Remux)\b` missed joined BDRemux/BDREMUX/UHDremux** → op 212 (`\b((BD|UHD)[-_. ]?)?Remux\b`, Radarr-parser-aligned). Feeds 49 CFs; worst compound was Full Disc −999999 on `Interstellar.2014.1080p.BDRemux.AVC.DTS-HD.MA.5.1-HDCLUB`. Control: `-LazyRemux` group still unmatched.
- **German DL: guard `(?<!WEB-)` missed WEB.DL / WEB DL spellings** → op 212 (`(?<!WEB[-_. ])`). Titles: `The.German.Doctor.2013.1080p.WEB.DL.DD5.1.H264-GROUP`, `A German Life 2016 720p WEB DL x264-GROUP` (−999999 in 11 profiles). Controls: hyphen spelling still guarded; real `German.DL` still matches.

### FALSE-ALARM (withdrawn — do not re-propose)
- **DV.SDR added to Without-Fallback negation**: withdrawn. No verified real `DV.SDR` release names (web-searched; only DV→SDR conversion tooling exists); WF has matched DV.SDR since op 0 (NOT an op-200 regression — that guard lived on the main `Dolby Vision` regex); CF description says "regular HDR Fallback" — SDR base is not an HDR fallback. Corpus pins DV.SDR → WF matches, as intended.

### INTENDED (leave alone)
- `DV.HLG` raw-WF-regex gap — rescued at CF level by op-182 negated `HDR` condition (HDR regex matches HLG). Unobservable; becomes live only if that condition is removed.
- Op 200 dropping `dv(?![ .](HLG|SDR))` from main `Dolby Vision` — deliberate simplification; both scoring directions defensible.
- Release group literally named "HDR" matches HDR cluster — unfixable at title level; TRaSH identical.
- `HDR` regex not matching `HDR10Plus` — safe: every negated use pairs with `HDR10+` regex which does match; positive layering arguably intended.
- `HDRip` correctly rejected (op 206 `\bHDR(\b|\d)`); `UHD Bluray` excluding "Blu Ray"-with-space is documented project choice (PR #31).
- `HDR10 (Missing)` broken in Sonarr (required source bluray vs bluray_raw remuxes) — documented in its own CF description.
- `E.AC3` falsely matches `Dolby Digital` regex but rescued at CF level by DD+ negation.

### OPEN (documented, not fixed — needs maintainer-grade judgment or better evidence)
- **Full Disc structural flaw**: trailing `(?i)(DVD9|DVD5|NTSC|PAL|VOB IFO|VC-1|AVC|MPEG-2|…)` alternative sits OUTSIDE the `^(?!…)` guard, largely unanchored. Demonstrated CF-level FPs surviving source-condition rescue: `Movie.2005.PAL.DVDRip.XviD-GROUP`, `Movie.1988.NTSC.DVDRip.XviD-GROUP` (DVD source not excluded). CANNOT simply move tail under guard (DVD9/PAL discs must survive the `DVD` guard token). A safe fix = \b-bound the loose tokens + add a scoped rip-exclusion to the tail only; needs a full-disc-titles corpus before attempting.
- **Dolby Digital family**: spelled-out `Dolby.Digital` (Jawan-style Indian WEB naming) matches neither DD nor DD+; canonical `E-AC-3` matches neither (`e[-_. ]?ac3` lacks `ac[-_. ]?3`). False negatives (score 0) + negated uses fail open on multi-audio titles. Fix direction: `e[-_. ]?ac[-_. ]?3` + spelled-out alternation; needs decision on DD vs DD+ boundary for spelled-out form.
- **Orphan regexes** (zero conditions reference them; fix-or-delete before wiring): `Non Retail HDR Formats` (DV branch reproduces the pre-fix WF bug — flags retail DV.HDR/DV.HDR10Plus/REMUX hybrids), `Non Retail HDR Groups` (missing parens: `(?<=^|[\s.-])VECTOR|BiTOR|…|Flights\b` — middle six names match as bare substrings, e.g. BiTOR inside "Inhibitor"), `HDR10 (Missing Groups)`, `TrueHD (Missing Groups)`.
- `2160p Quality Tier 6` description says "Tier 5" (cosmetic copy-paste).

### CLEARED areas (3-agent sweep of all 533 regexes, 2026-08-06 — don't redo without a NEW hypothesis)
- Blu-ray/BD/WEB token spellings in all other regexes (incl. `WEB-DL` = `\b(WEB[ ._-]?DL)\b`, streaming-service `web[ ._-]?(dl|rip)` classes, x264/x265 substring remux guards).
- All 24 negation-bearing regexes adjudicated (IMAX/NON guards, HBO-Max, Movies Anywhere dts-hd lookbehind incl. both-directions tests, Opus res-guard, DTS-X, edition `{edition-` guard, B&W family end-guards, iTunes Rename).
- HDR/DV long tail: DTS family cross-negations, Atmos, TrueHD, 4KDVS anchoring, HDR10 (Negation), group-name lists other than NRHG all correctly parenthesize anchors.
- Main HDR/DV cluster (Dolby Vision, Basic HDR Formats, HDR, HDR10+, SDR + their CF graphs) — deep-audited with 210-check corpus incl. 21 real titles; all green post-211/212.

## Searched sources/queries (exhausted — don't repeat)
- hdencode.org `?s=2160p+DV`, `?s=2160p+SDR` (2026-08-06)
- api.srrdb.com/v1/search/2160p/hlg, /2160p/pq (pq query useless — returns alphabetical list) (2026-08-06)
- Web search: "DV.SDR"/"DoVi.SDR" release names (negative result, 2026-08-06)
- TRaSH radarr CF JSONs (dv*, hdr*, hlg, sdr*); Radarr QualityParserFixture.cs (in audit/harness sources notes)

## Iteration log
- **Iteration 1 (2026-08-06)**: setup (fork branches v2 + fix/regex-audit pushed additively; live stable/custom untouched), ops 211+212 + tweaks + harness + REPORT ported and pushed, harness verified green in fork (213 ops, 210/210). Prowlarr access verified (health 200, metadata only). Area picked: edition regexes (IMAX/Special Edition already cleared; auditing the rest). Result: recorded below after run.
