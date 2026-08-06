# Audit-and-fix loop ledger

started_at: 2026-08-06T15:35:00Z
consecutive_dry: 0
iteration: 3

Repo: fork `4eh5xitv6787h645ebv/jakes-profilarr-database`, branch `fix/regex-audit` (based on upstream v2 @ op 210).
NOTE: this fork also hosts the user's LIVE v1 profilarr branches `stable` and `custom` — NEVER touch those branches.
Harness: `audit/harness/` (schema dependency clone expected at `../../schema` relative to repo root, i.e. `~/work/dictionarry-fix-loop/schema`).
Prowlarr (metadata search ONLY): http://localhost:9696, API key via `docker exec prowlarr sh -c 'grep -oE "<ApiKey>[^<]*</ApiKey>" /config/config.xml'`. Never download content; names only. If names can't settle a hypothesis → NEEDS-MANUAL-VERIFICATION.

## Settled verdicts (do NOT re-test)

### TRUE-BUG-FIXED
- **Dolby Vision (Without Fallback): BLURAY negation missed Blu-ray/BLU-RAY spellings** → op 211 (`BLU[-]?RAY`, matching house precedent PR #31/e39014f). Titles: `Movie.2016.2160p.Blu-ray.x265.10bit.DV.TrueHD.7.1-GROUP`, `Movie.2019.2160p.COMPLETE.UHD.BLU-RAY.DV.HEVC-GROUP`; class proven real by `[BD]Dark.Blue.2002.2160p.AUS.UHD.Blu-ray.DV.HDR.HEVC.DTS-HD.MA.5.1-Tux` (hdencode).
- **Remux: `\b(Remux)\b` missed joined BDRemux/BDREMUX/UHDremux** → op 212 (`\b((BD|UHD)[-_. ]?)?Remux\b`, Radarr-parser-aligned). Feeds 49 CFs; worst compound was Full Disc −999999 on `Interstellar.2014.1080p.BDRemux.AVC.DTS-HD.MA.5.1-HDCLUB`. Control: `-LazyRemux` group still unmatched.
- **Special Edition: token list missing `Redux`** → op 213 (post-year-anchored `|Redux`). Real titles: `Apocalypse.Now.1979.Redux.1080p.BluRay.DD.7.1.x264-playHD`, `…REDUX.2160p.UHD.BLURAY.REMUX…-EXTREME` (Prowlarr metadata). No group named REDUX (srrdb group search empty) → no new FP surface. Note: Radarr's EditionRegex does NOT know Redux either — evidence is real-title based. Pre-year "Apocalypse Now Redux (1979)" intentionally unmatched (year-lookbehind design, same as all tokens).
- **Dolby Digital +: missed canonical `E-AC-3` and spelled-out `Dolby.Digital.Plus`** → op 214 (`e[-_. ]?ac[-_. ]?3` + `Dolby[ ._-]?Digital[ ._-]?(P(lus)?\b|\+)`). Real titles: `Hamilton.2020.2160p.WEB-DL.DSNP.Dolby.Vision.HEVC.E-AC-3.5.1-LEWIS`, `The.Browns.S01.1080p.WEB-DL.E-AC-3.H.264-BTN` (hdencode), `Agent.Elvis...NF.WEBRip.Dolby.Digital.Plus.with.Dolby.Atmos...-iVy`, `Black.Widow.2021...-CAPTCHA` (Prowlarr). DD's `(?<!e-?)` guard keeps these out of plain DD. Control: `Dolby.Atmos` alone stays unmatched.
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
- **Dolby Digital (plain, spelled-out)**: `Dolby.Digital.5.1` without Plus still matches neither DD nor DD+ — NO real title found yet (Prowlarr "Dolby Digital Plus" search returned only Plus forms). Fix direction ready (`Dolby[ ._-]?Digital\b(?![ ._-]?(P(lus)?\b|\+))` on the DD regex) but held for real-title evidence. E-AC-3/DDP-spelled-out half FIXED in op 214.
- **Orphan regexes** (zero conditions reference them; fix-or-delete before wiring): `Non Retail HDR Formats` (DV branch reproduces the pre-fix WF bug — flags retail DV.HDR/DV.HDR10Plus/REMUX hybrids), `Non Retail HDR Groups` (missing parens: `(?<=^|[\s.-])VECTOR|BiTOR|…|Flights\b` — middle six names match as bare substrings, e.g. BiTOR inside "Inhibitor"), `HDR10 (Missing Groups)`, `TrueHD (Missing Groups)`.
- `2160p Quality Tier 6` description says "Tier 5" (cosmetic copy-paste).

### CLEARED areas (3-agent sweep of all 533 regexes, 2026-08-06 — don't redo without a NEW hypothesis)
- Blu-ray/BD/WEB token spellings in all other regexes (incl. `WEB-DL` = `\b(WEB[ ._-]?DL)\b`, streaming-service `web[ ._-]?(dl|rip)` classes, x264/x265 substring remux guards).
- All 24 negation-bearing regexes adjudicated (IMAX/NON guards, HBO-Max, Movies Anywhere dts-hd lookbehind incl. both-directions tests, Opus res-guard, DTS-X, edition `{edition-` guard, B&W family end-guards, iTunes Rename).
- HDR/DV long tail: DTS family cross-negations, Atmos, TrueHD, 4KDVS anchoring, HDR10 (Negation), group-name lists other than NRHG all correctly parenthesize anchors.
- Main HDR/DV cluster (Dolby Vision, Basic HDR Formats, HDR, HDR10+, SDR + their CF graphs) — deep-audited with 210-check corpus incl. 21 real titles; all green post-211/212.

- Prowlarr search "E-AC-3 1080p" (noise, no E-AC-3 titles), "Dolby Digital Plus 1080p" (iVy/CAPTCHA spelled-out titles) (2026-08-06)
- hdencode.org ?s=E-AC-3 (6 real E-AC-3 titles) (2026-08-06)

## Searched sources/queries (exhausted — don't repeat)
- Prowlarr search "Apocalypse Now Redux" (2026-08-06, 85 titles)
- api.srrdb.com/v1/search/group:redux (EMPTY — no such group)
- Radarr Parser.cs EditionRegex (fetched; no Redux token)
- hdencode.org `?s=2160p+DV`, `?s=2160p+SDR` (2026-08-06)
- api.srrdb.com/v1/search/2160p/hlg, /2160p/pq (pq query useless — returns alphabetical list) (2026-08-06)
- Web search: "DV.SDR"/"DoVi.SDR" release names (negative result, 2026-08-06)
- TRaSH radarr CF JSONs (dv*, hdr*, hlg, sdr*); Radarr QualityParserFixture.cs (in audit/harness sources notes)

## Iteration log
- **Iteration 1 (2026-08-06)**: setup (fork branches v2 + fix/regex-audit pushed additively; live stable/custom untouched), ops 211+212 + tweaks + harness + REPORT ported and pushed, harness verified green in fork (213 ops, 210/210). Prowlarr access verified (health 200, metadata only). Area picked: edition regexes. Result: **1 new bug fixed (op 213, Special Edition + Redux)**; `Theatrical Edition`/`Extended Edition`/`Extended Clip`/`Shush Cut`/`Criterion Channel` examined clean (year-anchored, no realistic spelling variants missed); "Remastered/Restored not in Special Edition" judged INTENDED (they are not cut changes; Radarr classes them separately). consecutive_dry reset to 0. Next area suggestion: streaming-service long tail or resolution+source tokens.
- **Iteration 2 (2026-08-06)**: area = audio family (pre-scoped OPEN item). Result: **1 new bug fixed (op 214, Dolby Digital + spellings)** — E-AC-3 + spelled-out DDP, 6 corpus rows flipped, gate clean (229/229). Plain spelled-out DD kept OPEN (no real title evidence). consecutive_dry stays 0.
